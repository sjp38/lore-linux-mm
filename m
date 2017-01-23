Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id F33BA6B0033
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 01:05:52 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id k15so95191181qtg.5
        for <linux-mm@kvack.org>; Sun, 22 Jan 2017 22:05:52 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t5si10092979qki.166.2017.01.22.22.05.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jan 2017 22:05:51 -0800 (PST)
Date: Sun, 22 Jan 2017 22:05:44 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [ATTEND] many topics
Message-ID: <20170123060544.GA12833@bombadil.infradead.org>
References: <20170118054945.GD18349@bombadil.infradead.org>
 <20170118133243.GB7021@dhcp22.suse.cz>
 <20170119110513.GA22816@bombadil.infradead.org>
 <20170119113317.GO30786@dhcp22.suse.cz>
 <20170119115243.GB22816@bombadil.infradead.org>
 <20170119121135.GR30786@dhcp22.suse.cz>
 <878tq5ff0i.fsf@notabene.neil.brown.name>
 <20170121131644.zupuk44p5jyzu5c5@thunk.org>
 <87ziijem9e.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ziijem9e.fsf@notabene.neil.brown.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.com>
Cc: Theodore Ts'o <tytso@mit.edu>, Michal Hocko <mhocko@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sun, Jan 22, 2017 at 03:45:01PM +1100, NeilBrown wrote:
> On Sun, Jan 22 2017, Theodore Ts'o wrote:
> > On Sat, Jan 21, 2017 at 11:11:41AM +1100, NeilBrown wrote:
> >> What are the benefits of GFP_TEMPORARY?  Presumably it doesn't guarantee
> >> success any more than GFP_KERNEL does, but maybe it is slightly less
> >> likely to fail, and somewhat less likely to block for a long time??  But
> >> without some sort of promise, I wonder why anyone would use the
> >> flag.  Is there a promise?  Or is it just "you can be nice to the MM
> >> layer by setting this flag sometimes". ???
> >
> > My understanding is that the idea is to allow short-term use cases not
> > to be mixed with long-term use cases --- in the Java world, to declare
> > that a particular object will never be promoted from the "nursury"
> > arena to the "tenured" arena, so that we don't end up with a situation
> > where a page is used 90% for temporary objects, and 10% for a tenured
> > object, such that later on we have a page which is 90% unused.
> >
> > Many of the existing users may in fact be for things like a temporary
> > bounce buffer for I/O, where declaring this to the mm system could
> > lead to less fragmented pages, but which would violate your proposed
> > contract:

I don't have a clear picture in my mind of when Java promotes objects
from nursery to tenure ... which is not too different from my lack of
understanding of what the MM layer considers "temporary" :-)  Is it
acceptable usage to allocate a SCSI command (guaranteed to be freed
within 30 seconds) from the temporary area?  Or should it only be used
for allocations where the thread of control is not going to sleep between
allocation and freeing?

> You have used terms like "nursery" and "tenured" which don't really help
> without definitions of those terms.
> How about
> 
>    GFP_TEMPORARY should be used when the memory allocated will either be
>    freed, or will be placed in a reclaimable cache, after some sequence
>    of events which is time-limited. i.e. there must be no indefinite
>    wait on the path from allocation to freeing-or-caching.
>    The memory will typically be allocated from a region dedicated to
>    GFP_TEMPORARY allocations, thus ensuring that this region does not
>    become fragmented.  Consequently, the delay imposed on GFP_TEMPORARY
>    allocations is likely to be less than for non-TEMPORARY allocations
>    when memory pressure is high.

I think you're overcomplicating your proposed contract by allowing for
the "adding to a reclaimable cache" case.  If that will happen, the
code should be using GFP_RECLAIMABLE, not GFP_TEMPORARY as a matter of
good documentation.  And to allow the definitions to differ in future.
Maybe they will always be the same bit pattern, but the code should
distinguish the two cases (obviously there is no problem with allocating
memory with GFP_RECLAIMABLE, then deciding you didn't need it after all
and freeing it).

> ??
> I think that for this definition to work, we would need to make it "a
> movable cache", meaning that any item can be either freed or
> re-allocated (presumably to a "tenured" location).  I don't think we
> currently have that concept for slabs do we?  That implies that this
> flag would only apply to whole-page allocations  (which was part of the
> original question).  We could presumably add movability to
> slab-shrinkers if these seemed like a good idea.

Funnily, Christoph Lameter and I are working on just such a proposal.
He put it up as a topic discussion at the LCA Kernel Miniconf, and I've
done a proof of concept implementation for radix tree nodes.  It needs
changes to the radix tree API to make it work, so it's not published yet,
but it's a useful proof of concept for things which can probably work
and be more effective, like the dentry & inode caches.

> I think that it would also make sense to require that the path from
> allocation to freeing (or caching) of GFP_TEMPORARY allocation must not
> wait for a non-TEMPORARY allocation, as that becomes an indefinite wait.

... can it even wait for *another* TEMPORARY allocation?  I really think
this discussion needs to take place in a room with more people present
so we can get misunderstandings hammered out and general acceptance of
the consensus.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
