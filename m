Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BABCA6B0047
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 12:14:25 -0500 (EST)
Date: Wed, 3 Feb 2010 18:14:13 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100203171413.GB5959@random.random>
References: <20100202141036.GL4135@random.random>
 <20100202142130.GI6616@sgi.com>
 <20100202145911.GM4135@random.random>
 <20100202152142.GQ6653@sgi.com>
 <20100202160146.GO4135@random.random>
 <20100202163930.GR6653@sgi.com>
 <20100202165224.GP4135@random.random>
 <20100202165903.GN6616@sgi.com>
 <20100202201718.GQ4135@random.random>
 <20100203004833.GS6653@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100203004833.GS6653@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Robin Holt <holt@sgi.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 02, 2010 at 06:48:33PM -0600, Robin Holt wrote:
> In the _invalidate_page case, it is called by the kernel from sites where
> the kernel is relying upon the reference count to eliminate the page from
> use while maintaining the page's data as clean and ready to be released.
> If the page is marked as dirty, etc. then the kernel will "do the right
> thing" with the page to maintain data consistency.
>
> The _invalidate_range_start/end pairs are used in places where the
> caller's address space is being modified.  If we allow the attachers
> to continue to use the old pages from the old mapping even for a short
> time after the process has started to use the new pages, there would be
> silent data corruption.

Just to show how fragile your assumption is, your code is already
generating mm corruption in fork and in ksm... the set_pte_at_notify
invalidate_page has to run immediately and be effective immediately
despite being called with the PT lock hold.

> A difference is the kernel's expectations.  The truncate case is the one

do_wp_page and ksm ->invalidate_page or ->change_pte have expectations
different than what the ones you expect it to have.

It's the first time I hear about the semantics of invalidate_page and
range_start/end being different. The only reason why there are two
different calls is that start/end wants to run a single tlb flush for
many ptes teardown. While this isn't doable with the ptep_clear_flush
or set_pte_at versions beacuse there is a single pte to invalidate and
not multiple. So for the latter we simply have a single call and
there's no need of a start/stop range.

> place where the kernel's expectation for _invalidate_range_start/end
> more closely matches those of _invalidate_page.  When I was babbling
> about a new version of the patch, it basically adds that concept to the
> _invalidate_range_start callout as a parameter.  Essentially changing
> the bool atomic into a flag indicating the kernel does not expect this
> step to be complete prior finishing this callout.

I don't get it sorry.

> I don't like that second patch which is why I have not posted it.
> It relies upon the fuzzy quantity of an "adequate" period of time between
> when the file is truncated down before it may be extended again to ensure
> data consistency.  Shrink and extend too quickly and problems will ensue.

Not sure I get it, it's all i_mutex serialized so i_size can't change
under the code under discussion, I don't see the shrink and extend too
quick.

> > can't schedule inside the anon_vma->lock and uses the range calls to
> > be safer (then maybe we can require the mmu notifier users to check
> > PageTransHuge against the pages and handle the invalidate through
> > ->invalidate_page or we can add ->invalidate_transhuge_page.
> 
> I don't think that is a problem.  I don't think the GRU has any issues
> at all.  I believe that the invalidate even of a standard page size will
> eliminate the entire TLB.  Jack was going to verify that the last time
> I talked with him.  If it behaved any differently, I would be surprised
> as it would be inconsistent with nearly every other TLB out there.

GRU sure is fine as it has no sleepability requirement. My
pmdp_clear_flush_notify calls invalidate_range_start/end to flush the
entire mmu range in case the secondary mmu couldn't map the hugepage
in a single hugetlb (like kvm does).

> XPMEM will currently not work, but I believe I can get it to work quite
> easily as I can walk the segment's PFN table without acquiring any
> sleeping locks and decide to expand the page size for any invalidation
> within that range.  With that, at the time of the callout, I can schedule
> an invalidation of the appropriate size.

Schedule or/and do it later isn't safe in khugepaged, ksm, do_wp_page
etc.. all running under PT lock. It also isn't ok for
pmdp_clear_flush_notify calling the
mmu_notifier_invalidate_range_start/end(atomic=0), it's unacceptable
to fail and not flush sptes as I have to migrate a writable page in
khugepaged and data writes will be lost if you don't really stop the
remote dma before pmdp_clear_flush_notify returns!

> As for the transparent huge page patches, I have just skimmed them
> lightly as I really don't have much time to understand your intention.
> I do think I am agreeing with Christoph Lameter that using the migration
> style mechanism is probably better in that it handles the invalidate_page
> callouts, follows the page reference counts, and allows my asynchronous
> invalidation expectation to persist.

I think your asynchronous invalidation expectation are invalid
regardless of khugepaged and pmdp_clear_flush_notify.

> If I read it correctly, your patch would now require invalidate_page
> to be complete and have reference counts pushed back down upon return.
> I probably missed a key portion of that patch and would welcome the
> chance to be informed.

The problem aren't the reference counts. The problem is that the
writes coming from remote must not go to a page regardless of its page
count, this isn't about khugepaged only. The reads coming from remote
also must not read from local memory after invalidate or do_wp_page
will break as the writes through the pte will go to the copied page
while the remote mapping still reads from the old page.

It's a pure accident it works ok in swap (because swap won't alter the
pte->pnf mapping after the invalidate and it won't actually lose the
swap entry until the refcount is only the one for the lru). Every
other place where invalidate_page is called and the pte->pfn mapping
is altered (and it's not only marked nonpresent and remapped on the
same pfn in case of swapcache fault) requires synchronous updating of
secondary sptes in invalidate_page too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
