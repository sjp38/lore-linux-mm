Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 524F06B025F
	for <linux-mm@kvack.org>; Wed,  6 Dec 2017 19:42:10 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id l14so3636432pgu.17
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 16:42:10 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id d25si2845131plj.693.2017.12.06.16.42.07
        for <linux-mm@kvack.org>;
        Wed, 06 Dec 2017 16:42:08 -0800 (PST)
Date: Thu, 7 Dec 2017 11:38:43 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH v4 72/73] xfs: Convert mru cache to XArray
Message-ID: <20171207003843.GG4094@dastard>
References: <20171206004159.3755-1-willy@infradead.org>
 <20171206004159.3755-73-willy@infradead.org>
 <20171206012901.GZ4094@dastard>
 <20171206020208.GK26021@bombadil.infradead.org>
 <20171206031456.GE4094@dastard>
 <20171206044549.GO26021@bombadil.infradead.org>
 <20171206084404.GF4094@dastard>
 <20171206140648.GB32044@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171206140648.GB32044@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Dec 06, 2017 at 06:06:48AM -0800, Matthew Wilcox wrote:
> On Wed, Dec 06, 2017 at 07:44:04PM +1100, Dave Chinner wrote:
> > On Tue, Dec 05, 2017 at 08:45:49PM -0800, Matthew Wilcox wrote:
> > > That said, using xa_cmpxchg() in the dquot code looked like the right
> > > thing to do?  Since we'd dropped the qi mutex and the ILOCK, it looks
> > > entirely reasonable for another thread to come in and set up the dquot.
> > > But I'm obviously quite ignorant of the XFS internals, so maybe there's
> > > something else going on that makes this essentially a "can't happen".
> > 
> > It's no different to the inode cache code, which drops the RCU
> > lock on lookup miss, instantiates the new inode (maybe reading it
> > off disk), then locks the tree and attempts to insert it. Both cases
> > use "insert if empty, otherwise retry lookup from start" semantics.
> 
> Ah.  I had my focus set a little narrow on the inode cache code and didn't
> recognise the pattern.
> 
> Why do you sleep for one jiffy after encountering a miss, then seeing
> someone else insert the inode for you?

The sleep is a backoff that allows whatever we raced with to
complete, be it a hit that raced with an inode being reclaimed and
removed, or a miss that raced with another insert. Ideally we'd
sleep on the XFS_INEW bit, similar to the vfs I_NEW flag, but it's
not quite that simple with the reclaim side of things...

> > cmpxchg is for replacing a known object in a store - it's not really
> > intended for doing initial inserts after a lookup tells us there is
> > nothing in the store.  The radix tree "insert only if empty" makes
> > sense here, because it naturally takes care of lookup/insert races
> > via the -EEXIST mechanism.
> > 
> > I think that providing xa_store_excl() (which would return -EEXIST
> > if the entry is not empty) would be a better interface here, because
> > it matches the semantics of lookup cache population used all over
> > the kernel....
> 
> I'm not thrilled with xa_store_excl(), but I need to think about that
> a bit more.

Not fussed about the name - I just think we need a function that
matches the insert semantics of the code....

> > > I'm quite happy to have normal API variants that don't save/restore
> > > interrupts.  Just need to come up with good names ... I don't think
> > > xa_store_noirq() is a good name, but maybe you do?
> > 
> > I'd prefer not to have to deal with such things at all. :P
> > 
> > How many subsystems actually require irq safety in the XA locking
> > code? Make them use irqsafe versions, not make everyone else use
> > "noirq" versions, as is the convention for the rest of the kernel
> > code....
> 
> Hard to say how many existing radix tree users require the irq safety.

The mapping tree requires it because it gets called from IO
completion contexts to clear page writeback state, but I don't know
about any of the others.

> Also hard to say how many potential users (people currently using
> linked lists, people using resizable arrays, etc) need irq safety.
> My thinking was "make it safe by default and let people who know better
> have a way to opt out", but there's definitely something to be said for
> "make it fast by default and let people who need the unusual behaviour
> type those extra few letters".
> 
> So, you're arguing for providing xa_store(), xa_store_irq(), xa_store_bh()
> and xa_store_irqsafe()?  (at least on demand, as users come to light?)
> At least the read side doesn't require any variants; everybody can use
> RCU for read side protection.

That would follow the pattern of the rest of the kernel APIs, though
I think it might be cleaner to simply state the locking requirement
to xa_init() and keep all those details completely internal rather
than encoding them into API calls. After all, the "irqsafe-ness" of
the locking needs to be consistent across the entire XA instance....

> ("safe", not "save" because I wouldn't make the caller provide the
> "flags" argument).
> 
> > > At least, not today.  One of the future plans is to allow xa_nodes to
> > > be allocated from ZONE_MOVABLE.  In order to do that, we have to be
> > > able to tell which lock protects any given node.  With the XArray,
> > > we can find that out (xa_node->root->xa_lock); with the radix tree,
> > > we don't even know what kind of lock protects the tree.
> > 
> > Yup, this is a prime example of why we shouldn't be creating
> > external dependencies by smearing the locking context outside the XA
> > structure itself. It's not a stretch to see something like a
> > ZONE_MOVEABLE dependency because some other object indexed in a XA
> > is stored in the same page as the xa_node that points to it, and
> > both require the same xa_lock to move/update...
> 
> That is a bit of a stretch.  Christoph Lameter and I had a discussion about it
> here: https://www.spinics.net/lists/linux-mm/msg122902.html
> 
> There's no situation where you need to acquire two locks in order to
> free an object;

ZONE_MOVEABLE is for moving migratable objects, not freeing
unreferenced objects. i.e. it's used to indicate the active objects
can be moved to a different location whilst it has other objects
pointing to it. This requires atomically swapping all the external
pointer references to the object so everything sees either the old
object before the move or the new object after the move. While the
move is in progress, we have to stall anything that could possibly
reference the object and in general that means we have lock up all
the objects that point to the object being moved.

For things like inodes, we have *lots* of external references to
them, and so we'd have to stall all of those external references
to update them once movement is complete. Lots of locks to hold
there, potentially including the xa_lock for the trees that index
the inode.

Hence if we are trying to migrate multiple objects at a time (i.e.
the bulk slab page clearing case) then we've got to lock up multiple
refrenceing objects and structure that may have overlapping
dependencies and so could end up trying to get the same locks that
other objects in the page already hold.

It's an utter mess - xa_node might be simple, but the general case
for slab objects in ZONE_MOVEABLE is anything but simple.  That's
the reason we've never made any progress on generic slab
defragmentation in the past 12-13 years - we haven't worked out how
to solve this fundamental "atomically update all external references
to the object being moved" problem.

> you'd create odd locking dependencies between objects
> if you did that (eg we already have a locking dependency between pag_ici
> and perag from __xfs_inode_set_eofblocks_tag)

You missed this one: xfs_inode_set_reclaim_tag()

It nests pag->pag_ici_lock - ip->i_flags_lock - mp->m_perag_lock
in one pass because we've got an inode flag and tags in two separate
radix trees we need to update atomically....

Also, that's called in the evict() path so, yeah, we're actually
nesting multiple locks to get the inode into a state where we can
reclaim it...

> It'd be a pretty horrible
> shrinker design where you had to get all the locks on all the objects,
> regardless of what locking order the real code had.

The shrinker (i.e. memory reclaim) doesn't need to do that - only
object migration does. They operate on vastly different object
contexts and should not be conflated.

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
