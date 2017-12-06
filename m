Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id B6DD26B036B
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 03:44:09 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id q12so629375pli.12
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 00:44:09 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id f9si1502072pgt.544.2017.12.06.00.44.06
        for <linux-mm@kvack.org>;
        Wed, 06 Dec 2017 00:44:07 -0800 (PST)
Date: Wed, 6 Dec 2017 19:44:04 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
Message-ID: <20171206084404.GF4094@dastard>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206004159.3755-73-willy@infradead.org>
 <20171206012901.GZ4094@dastard>
 <20171206020208.GK26021@bombadil.infradead.org>
 <20171206031456.GE4094@dastard>
 <20171206044549.GO26021@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206044549.GO26021@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Dec 05, 2017 at 08:45:49PM -0800, Matthew Wilcox wrote:
> On Wed, Dec 06, 2017 at 02:14:56PM +1100, Dave Chinner wrote:
> > > The other conversions use the normal API instead of the advanced API, so
> > > all of this gets hidden away.  For example, the inode cache does this:
> > 
> > Ah, OK, that's not obvious from the code changes. :/
> 
> Yeah, it's a lot easier to understand (I think!) if you build the
> docs in that tree and look at
> file:///home/willy/kernel/xarray-3/Documentation/output/core-api/xarray.html
> (mutatis mutandi).  I've tried to tell a nice story about how to put
> all the pieces together from the normal to the advanced API.
> 
> > However, it's probably overkill for XFS. In all the cases, when we
> > insert there should be no entry in the tree - the
> > radix tree insert error handling code there was simply catching
> > "should never happen" cases and handling it without crashing.
> 
> I thought it was probably overkill to be using xa_cmpxchg() in the
> pag_ici patch.  I didn't want to take away your error handling as part
> of the conversion, but I think a rational person implementing it today
> would just call xa_store() and not even worry about the return value
> except to check it for IS_ERR().

*nod*

> That said, using xa_cmpxchg() in the dquot code looked like the right
> thing to do?  Since we'd dropped the qi mutex and the ILOCK, it looks
> entirely reasonable for another thread to come in and set up the dquot.
> But I'm obviously quite ignorant of the XFS internals, so maybe there's
> something else going on that makes this essentially a "can't happen".

It's no different to the inode cache code, which drops the RCU
lock on lookup miss, instantiates the new inode (maybe reading it
off disk), then locks the tree and attempts to insert it. Both cases
use "insert if empty, otherwise retry lookup from start" semantics.

cmpxchg is for replacing a known object in a store - it's not really
intended for doing initial inserts after a lookup tells us there is
nothing in the store.  The radix tree "insert only if empty" makes
sense here, because it naturally takes care of lookup/insert races
via the -EEXIST mechanism.

I think that providing xa_store_excl() (which would return -EEXIST
if the entry is not empty) would be a better interface here, because
it matches the semantics of lookup cache population used all over
the kernel....

> > Now that I've looked at this, I have to say that having a return
> > value of NULL meaning "success" is quite counter-intuitive. That's
> > going to fire my "that looks so wrong" detector every time I look at
> > the code and notice it's erroring out on a non-null return value
> > that isn't a PTR_ERR case....
> 
> It's the same convention as cmpxchg().  I think it's triggering your
> "looks so wrong" detector because it's fundamentally not the natural
> thing to write.

Most definitely the case, and this is why it's a really bad
interface for the semantics we have. This how we end up with code
that makes it easy for programmers to screw up pointer checks in
error handling... :/

> I'm quite happy to have normal API variants that don't save/restore
> interrupts.  Just need to come up with good names ... I don't think
> xa_store_noirq() is a good name, but maybe you do?

I'd prefer not to have to deal with such things at all. :P

How many subsystems actually require irq safety in the XA locking
code? Make them use irqsafe versions, not make everyone else use
"noirq" versions, as is the convention for the rest of the kernel
code....

> > > It's the design pattern I've always intended to use.  Naturally, the
> > > xfs radix trees weren't my initial target; it was the page cache, and
> > > the page cache does the same thing; uses the tree_lock to protect both
> > > the radix tree and several other fields in that same data structure.
> > > 
> > > I'm open to argument on this though ... particularly if you have a better
> > > design pattern in mind!
> > 
> > I don't mind structures having internal locking - I have a problem
> > with leaking them into contexts outside the structure they protect.
> > That way lies madness - you can't change the internal locking in
> > future because of external dependencies, and the moment you need
> > something different externally we've got to go back to an external
> > lock anyway.
> > 
> > This is demonstrated by the way you converted the XFS dquot tree -
> > you didn't replace the dquot tree lock with the internal xa_lock
> > because it's a mutex and we have to sleep holding it. IOWs, we've
> > added another layer of locking here, not simplified the code.
> 
> I agree the dquot code is no simpler than it was, but it's also no more
> complicated from a locking analysis point of view; the xa_lock is just
> not providing you with any useful exclusion.

Sure, that's fine. All I'm doing is pointing out that we can't use
the internal xa_lock to handle everything the indexed objects
require, and so we're going to still need external locks in
many cases.

> At least, not today.  One of the future plans is to allow xa_nodes to
> be allocated from ZONE_MOVABLE.  In order to do that, we have to be
> able to tell which lock protects any given node.  With the XArray,
> we can find that out (xa_node->root->xa_lock); with the radix tree,
> we don't even know what kind of lock protects the tree.

Yup, this is a prime example of why we shouldn't be creating
external dependencies by smearing the locking context outside the XA
structure itself. It's not a stretch to see something like a
ZONE_MOVEABLE dependency because some other object indexed in a XA
is stored in the same page as the xa_node that points to it, and
both require the same xa_lock to move/update...

> There are other costs to not having a lock.  The lockdep/RCU
> analysis done on the radix tree code is none.  Because we have
> no idea what lock might protect any individual radix tree, we use
> rcu_dereference_raw(), disabling lockdep's ability to protect us.

Unfortunately for you, I don't find arguments along the lines of
"lockdep will save us" at all convincing.  lockdep already throws
too many false positives to be useful as a tool that reliably and
accurately points out rare, exciting, complex, intricate locking
problems.

> It's funny that you see the hodgepodge of different locking strategies
> in the XFS code base as being a problem with the XArray.  I see it as
> being a consequence of XFS's different needs.  No, the XArray can't
> solve all of your problems, but it hasn't made your locking more complex.

I'm not worried about changes in locking complexity here because, as
you point out, there isn't a change. What I'm mostly concerned about
is the removal of abstraction, modularity and isolation between
the XFS code and the library infrastructure it uses.

> 
> And I don't agree that the existing radix tree code has clear, consistent
> locking patterns.  For example, this use of RCU was unnecessary:
> 
>  xfs_queue_eofblocks(
>         struct xfs_mount *mp)
>  {
> -       rcu_read_lock();
> -       if (radix_tree_tagged(&mp->m_perag_tree, XFS_ICI_EOFBLOCKS_TAG))
> +       if (xa_tagged(&mp->m_perag_xa, XFS_ICI_EOFBLOCKS_TAG))
>                 queue_delayed_work(mp->m_eofblocks_workqueue,
>                                    &mp->m_eofblocks_work,
>                                    msecs_to_jiffies(xfs_eofb_secs * 1000));
> -       rcu_read_unlock();
>  }
> 
> radix_tree_tagged never required the RCU lock (commit 7cf9c2c76c1a).
> I think you're just used to the radix tree pattern of "we provide no
> locking for you, come up with your own scheme".

No, I'm used to having no-one really understand how "magic lockless
RCU lookups" actually work.  When i originally wrote the lockless
lookup code, I couldn't find anyone who both understood RCU and the
XFS inode cache to review the code for correctness.  Hence it had to
be dumbed down to the point that it was "stupidly obvious that it's
safe".

That problem has not gone away - very few people who read and have
to maintain this code understandxs all the nasty little intricacies
of RCU lookups.  Hiding /more/ of the locking semantics from the
programmers makes it even harder to explain why the algorithm is
safe. If the rules are basic (e.g. all radix tree lookups use RCU
locking) then it's easier for everyone to understand, review and
keep the code working correctly because there's almost no scope for
getting it wrong.

That's one of the advantages of the "we provide no locking for you,
come up with your own scheme" approach - we can dumb it down to the
point of being understandable and maintainable without anyone
needing to hurt their brain on memory-barriers.txt every time
someone changes the code.

Also, it's worth keeping in mind that this dumb code provides the
fastest and most scalable inode cache infrastructure in the kernel.
i.e. it's the structures and algorithms iused that make the code
fast, but it's the simplicity of the code that makes it
understandable and maintainable. The XArray code is a good
algorithm, we've just got to make the API suitable for dumb idiots
like me to be able to write reliable, maintainable code that uses
it.

> What might make more sense for XFS is coming up with something
> intermediate between the full on xa_state-based API and the "we handle
> everything for you" normal API.  For example, how would you feel about
> xfs_mru_cache_insert() looking like this:
> 
> 	xa_lock(&mru->store);
> 	error = PTR_ERR_OR_ZERO(__xa_store(&mru->store, key, elem, GFP_NOFS));
> 	if (!error)
> 		_xfs_mru_cache_list_insert(mru, elem);
> 	xa_unlock(&mru->store);
> 
> 	return error;
> 
> xfs_mru_cache_lookup would look like:
> 
> 	xa_lock(&mru->store);
> 	elem = __xa_load(&mru->store, key);
> 	....
> There's no real need for the mru code to be using the full-on xa_state
> API.  For something like DAX or the page cache, there's a real advantage,
> but the mru code is, I think, a great example of a user who has somewhat
> more complex locking requirements, but doesn't use the array in a
> complex way.

Yes, that's because the radix tree is not central to it's algorithm
or purpose.  The MRU cache (Most Recently Used Cache) is mostly
about the management of the items on lists in the priority
reclaimation array.  The radix tree is just there to provide a fast
"is there an item for this key already being aged" lookup so we
don't have to scan lists to do this.

i.e. Right now we could just as easily replace the radix tree with a
rbtree or resizing hash table as an XArray - the radix tree was just
a convenient "already implemented" key-based indexing mechanism that
was in the kernel when the MRU cache was implemented. Put simply:
the radix tree is not a primary structure in the MRU cache - it's
only an implementation detail and that's another reason why I'm not
a fan of smearing the internal locking of the replacement structure
all through the MRU code....

/me shrugs

BTW, something else I just noticed: all the comments in XFS that
talk about the radix trees would need updating.

$ git grep radix fs/xfs
fs/xfs/xfs_dquot.c:             /* uninit / unused quota found in radix tree, keep looking  */
fs/xfs/xfs_icache.c:    /* propagate the reclaim tag up into the perag radix tree */
fs/xfs/xfs_icache.c:    /* clear the reclaim tag from the perag radix tree */
fs/xfs/xfs_icache.c: * We set the inode flag atomically with the radix tree tag.
fs/xfs/xfs_icache.c: * Once we get tag lookups on the radix tree, this inode flag
fs/xfs/xfs_icache.c:     * radix tree nodes not being updated yet. We monitor for this by
fs/xfs/xfs_icache.c:     * Because the inode hasn't been added to the radix-tree yet it can't
fs/xfs/xfs_icache.c:     * These values must be set before inserting the inode into the radix
fs/xfs/xfs_icache.c:     * radix tree traversal here.  It assumes this function
fs/xfs/xfs_icache.c: * radix tree lookups to a minimum. The batch size is a trade off between
fs/xfs/xfs_icache.c:     * The radix tree lock here protects a thread in xfs_iget from racing
fs/xfs/xfs_icache.c:     * Remove the inode from the per-AG radix tree.
fs/xfs/xfs_icache.c:     * with inode cache radix tree lookups.  This is because the lookup
fs/xfs/xfs_icache.c:     * Don't bother locking the AG and looking up in the radix trees
fs/xfs/xfs_icache.c:            /* propagate the eofblocks tag up into the perag radix tree */
fs/xfs/xfs_icache.c:            /* clear the eofblocks tag from the perag radix tree */
fs/xfs/xfs_icache.h: * tags for inode radix tree
fs/xfs/xfs_qm.c: * currently is the only interface into the radix tree code that allows
$

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
