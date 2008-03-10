Subject: Re: [PATCH 00/28] Swap over NFS -v16
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <18388.50188.552322.780524@notabene.brown>
References: <20080220144610.548202000@chello.nl>
	 <20080223000620.7fee8ff8.akpm@linux-foundation.org>
	 <18371.43950.150842.429997@notabene.brown>
	 <1204023042.6242.271.camel@lappy>
	 <18372.64081.995262.986841@notabene.brown>
	 <1204099113.6242.353.camel@lappy> <1837 <1204626509.6241.39.camel@lappy>
	 <18384.46967.583615.711455@notabene.brown>
	 <1204888675.8514.102.camel@twins>
	 <18388.50188.552322.780524@notabene.brown>
Content-Type: text/plain
Date: Mon, 10 Mar 2008 10:17:54 +0100
Message-Id: <1205140674.8514.152.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-03-10 at 16:15 +1100, Neil Brown wrote:

> > On Fri, 2008-03-07 at 14:33 +1100, Neil Brown wrote:
> > > 
> > > [I don't find the above wholly satisfying.  There seems to be too much
> > >  hand-waving.  If someone can provide better text explaining why
> > >  swapout is a special case, that would be great.]
> > 
> > Anonymous pages are dirty by definition (except the zero page, but I
> > think we recently ditched it). So shrinking of the anonymous pool will
> > require swapping.
> 
> Well, there is the swap cache.  That's probably what I was thinking of
> when I said "clean anonymous pages".  I suspect they are the first to
> go!

Ah, right, we could consider those clean anonymous. Alas, they are just
part of the aging lists and do not get special priority.

> > It is indeed the last refuge for those with GFP_NOFS. Allong with the
> > strict limit on the amount of dirty file pages it also ensures writing
> > those out will never deadlock the machine as there are always clean file
> > pages and or anonymous pages to launder.
> 
> The difficulty I have is justifying exactly why page-cache writeout
> will not deadlock.  What if all the memory that is not dirty-pagecache
> is anonymous, and if swap isn't enabled?

Ah, I never considered the !SWAP case.

> Maybe the number returned by "determine_dirtyable_memory" in
> page-writeback.c excludes anonymous pages?  I wonder if the meaning of
> NR_FREE_PAGES, NR_INACTIVE, etc is documented anywhere....

I don't think they are, but it should be obvious once you know the VM,
har har har :-)

NR_FREE_PAGES are the pages in the page allocators free lists.
NR_INACTIVE are the pages on the inactive list
NR_ACTIVE are the pageso on the active list

NR_INACTIVE+NR_ACTIVE are the number of pages on the page reclaim lists.

So, if you consider !SWAP, we could get in a deadlock when all of memory
is anonymous except for a few (<=dirty limit) dirty file pages.

But I guess the !SWAP people know what they're doing, large anon usage
without swap is asking for trouble.
 
> > Right. I've had a long conversation on PG_emergency with Pekka. And I
> > think the conclusion was that PG_emergency will create more head-aches
> > than it solves. I probably have the conversation in my IRC logs and
> > could email it if you're interested (and Pekka doesn't object).
> 
> Maybe that depends on the exact semantic of PG_emergency ??
> I remember you being concerned that PG_emergency never changes between
> allocation and freeing, and that wouldn't work well with slub.
> My envisioned semantic has it possibly changing quite often.
> What it means is:
>    The last allocation done from this page was in a low-memory
>    condition.

Yes, that works, except that we'd need to iterate all pages and clear
PG_emergency - which would imply tracking all these pages etc..

Hence it would be better not to keep persistent state and do as we do
now; use some non-persistent state on allocation.

> You really need some way to tell if the result of kmalloc/kmemalloc
> should be treated as reserved.
> I think you had code which first tried the allocation without
> GFP_MEMALLOC and then if that failed, tried again *with*
> GFP_MEMALLOC.  If that then succeeded, it is assumed to be an
> allocation from reserves.  That seemed rather ugly, though I guess you
> could wrap it in a function to hide the ugliness:
> 
> void *kmalloc_reserve(size_t size, int *reserve, gfp_t gfp_flags)
> {
> 	void *result = kmalloc(size, gfp_flags & ~GFP_MEMALLOC);
> 	if (result) {
> 		*reserve = 0;
> 		return result;
> 	}
> 	result = kmalloc(size, gfp_flags | GFP_MEMALLOC);
> 	if (result) {
> 		*reserve = 1;
> 		return result;
> 	}
> 	return NULL;
> }
> ???

Yeah, I this this is the best we can do, just split this part out into
helper functions. I've been thinking of doing this - just haven't gotten
around to implementing it. Hope to do so this week and send out a new
series.

> > I've already heard interest from other people to use these hooks to
> > provide swap on other non-block filesystems such as jffs2, logfs and the
> > like.
> 
> I'm interested in the swap_in/swap_out interface for external
> write-intent bitmaps for md/raid arrays.
> You can have a write-intent bitmap which records which blocks might be
> dirty if the host crashes, so that resync is much faster.
> It can be stored in a file in a separate filesystem, but that is
> currently implemented by using bmap to enumerate the blocks and then
> reading/writing directly to the device (like swap).  Your interface
> would be much nicer for that (not that I think having a
> write-intent-bitmap on an NFS filesystem would be a clever idea ;-)

Hmm, right. But for that purpose the names swap_* are a tad misleading.
I remember hch mentioning this at some point. What would be a more
suitable naming scheme so we can both use it?

> I'll look forward to your next patch set....
> 
> One thing I had thought odd while reading the patches, but haven't
> found an opportunity to mention before, is the "IS_SWAPFILE" test in
> nfs-swapper.patch.
> This seems like a layering violation.  It would be better if the test
> was based on whether  ->swapfile had been called on the file.  That way
> my write-intent-bitmaps would get the same benefit.

I'll look into this, I didn't thing using a inode test inside a
filesystem implementation was too weird..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
