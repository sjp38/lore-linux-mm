Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3F8BD6B0038
	for <linux-mm@kvack.org>; Mon,  9 Nov 2015 18:29:59 -0500 (EST)
Received: by pasz6 with SMTP id z6so220230677pas.2
        for <linux-mm@kvack.org>; Mon, 09 Nov 2015 15:29:59 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id is2si567295pbc.241.2015.11.09.15.29.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Nov 2015 15:29:57 -0800 (PST)
Subject: Re: [PATCH] mm/hugetlbfs Fix bugs in fallocate hole punch of areas
 with holes
References: <1446247932-11348-1-git-send-email-mike.kravetz@oracle.com>
 <alpine.LSU.2.11.1511082005270.15826@eggly.anvils>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56412B42.8020205@oracle.com>
Date: Mon, 9 Nov 2015 15:24:50 -0800
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.11.1511082005270.15826@eggly.anvils>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>

On 11/08/2015 11:09 PM, Hugh Dickins wrote:
> Sorry for the delay, I needed some time set aside to look through.

No problem.  I really appreciate your comments.

> On Fri, 30 Oct 2015, Mike Kravetz wrote:
> 
>> Hugh Dickins pointed out problems with the new hugetlbfs fallocate
>> hole punch code.  These problems are in the routine remove_inode_hugepages
>> and mostly occur in the case where there are holes in the range of
>> pages to be removed.  These holes could be the result of a previous hole
>> punch or simply sparse allocation.
>>
>> remove_inode_hugepages handles both hole punch and truncate operations.
>> Page index handling was fixed/cleaned up so that holes are properly
>> handled.  In addition, code was changed to ensure multiple passes of the
>> address range only happens in the truncate case.  More comments were added
>> to explain the different actions in each case.  A cond_resched() was added
>> after removing up to PAGEVEC_SIZE pages.
>>
>> Some totally unnecessary code in hugetlbfs_fallocate() that remained from
>> early development was also removed.
> 
> Yes, I agree with most of that comment, and with removing the unnecessary
> leftover; and you were right to make the patch against v4.3 as you did.
> 
>>
> 
> Should have
> Fixes: b5cec28d36f5 ("hugetlbfs: truncate_hugepages() takes a range of pages")
> Cc: stable@vger.kernel.org [4.3]
> when it's finished.

Will do.

> 
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>  fs/hugetlbfs/inode.c | 44 +++++++++++++++++++++++++++++---------------
>>  1 file changed, 29 insertions(+), 15 deletions(-)
>>
> 
> I agree that this is an improvement, but I'm afraid it still
> has (perhaps) a serious bug that I didn't notice before.

Yes, I think most of the issues revolve around the question of whether
or not page faults can race with truncate.  As mentioned in the other
e-mail, this may not be an issue and would result in simpler/cleaner code.

> It'll be clearer if I comment, not on your patch, but on the patched
> remove_inode_hugepages() itself.  Yes, most of what I say could have
> been said when you asked for review of that originally - sorry,
> but I just didn't have time to spare.
> 
> static void remove_inode_hugepages(struct inode *inode, loff_t lstart,
> 				   loff_t lend)
> {
> 	struct hstate *h = hstate_inode(inode);
> 	struct address_space *mapping = &inode->i_data;
> 	const pgoff_t start = lstart >> huge_page_shift(h);
> 	const pgoff_t end = lend >> huge_page_shift(h);
> 	struct vm_area_struct pseudo_vma;
> 	struct pagevec pvec;
> 	pgoff_t next;
> 	int i, freed = 0;
> 	long lookup_nr = PAGEVEC_SIZE;
> 	bool truncate_op = (lend == LLONG_MAX);
> 
> 	memset(&pseudo_vma, 0, sizeof(struct vm_area_struct));
> 	pseudo_vma.vm_flags = (VM_HUGETLB | VM_MAYSHARE | VM_SHARED);
> 
> (I have to say in passing that this is horrid: what's needed is to
> replace hugetlb_fault_mutex_hash()'s "vma" arg by a "bool shared";
> or something else - it's irritating how half its args are irrelevant.
> But you're absolutely right not to do so in this patch, this being
> a fix for stable which should be kept minimal.  Maybe even leave
> out your i_lock/i_private cleanup for now.)

Ok, I'm happy to drop the i_lock/i_private cleanup as well.

> 
> 	pagevec_init(&pvec, 0);
> 	next = start;
> 	while (next < end) {
> 
> Okay: that confused me, but I think you're right to keep it that way for
> the holepunch break (and you don't expect to reach "end" in truncation).
> 
> 		/*
> 		 * Make sure to never grab more pages that we
> 
> The next comment makes clear that you cannot "Make sure" of that:
> "Try not to grab more pages than we would need" perhaps.

Agree, comment will be updated.

> 
> 		 * might possibly need.
> 		 */
> 		if (end - next < lookup_nr)
> 			lookup_nr = end - next;
> 
> If you are going to restart for truncation (but it's not clear to me
> that you should), then you ought to reinit lookup_nr to PAGEVEC_SIZE
> before restarting; though I suppose that restart finding anything
> will be so rare as not to matter in practice.

I'm pretty sure we will not need to restart once I confirm that this
routine does not need to handle races with faults in the truncate case.

> 
> 		/*
> 		 * When no more pages are found, take different action for
> 		 * hole punch and truncate.
> 		 *
> 		 * For hole punch, this indicates we have removed each page
> 		 * within the range and are done.  Note that pages may have
> 		 * been faulted in after being removed in the hole punch case.
> 		 * This is OK as long as each page in the range was removed
> 		 * once.
> 		 *
> 		 * For truncate, we need to make sure all pages within the
> 		 * range are removed when exiting this routine.  We could
> 		 * have raced with a fault that brought in a page after it
> 		 * was first removed.  Check the range again until no pages
> 		 * are found.
> 		 */
> 
> Good comment, but I don't know if it's going to stay.
> The big question is, whether it's possible for pages to get faulted
> back in in the truncation case: checks on i_size ought to protect from
> that, but yes, many filesystems will have races there; hugetlbfs perhaps
> not because of the fault_mutex, but I've not looked deeply enough into it.

As previously mentioned, I think this will go away once I confirm that
hugetlb_no_page() handles the race.

> 		if (!pagevec_lookup(&pvec, mapping, next, lookup_nr)) {
> 			if (!truncate_op)
> 				break;
> 
> 			if (next == start)
> 				break;
> 			next = start;
> 			continue;
> 		}
> 
> 		for (i = 0; i < pagevec_count(&pvec); ++i) {
> 			struct page *page = pvec.pages[i];
> 			u32 hash;
> 
> 			/*
> 			 * The page (index) could be beyond end.  This is
> 			 * only possible in the punch hole case as end is
> 
> "lend" is LLONG_MAX for truncate, "end" is something less;
> but I believe it's still a safe ending condition,
> for an in-RAM filesystem if not for a disk-based one.

Yes, I will at least update the comment.

> 
> 			 * LLONG_MAX for truncate.
> 			 */
> 			if (page->index >= end) {
> 				next = end;	/* we are done */
> 				break;
> 			}
> 			next = page->index;
> 
> Okay: it would have been neater to move that up and test "next >= end",
> then no need to set "next = end" above; but it's okay how you have it.

I like it better as you suggested.

> 
> 			hash = hugetlb_fault_mutex_hash(h, current->mm,
> 							&pseudo_vma,
> 							mapping, next, 0);
> 			mutex_lock(&hugetlb_fault_mutex_table[hash]);
> 
> 			lock_page(page);
> 			/*
> 			 * If page is mapped, it was faulted in after being
> 			 * unmapped.  Do nothing in this race case.  In the
> 			 * normal case page is not mapped.
> 			 */
> 			if (!page_mapped(page)) {
> 
> This is worrying.  If !page_mapped(page) can only happen in the
> the holepunch case, you're now okay.  But if it can happen in the
> truncation case, then this function is going to loop around and
> around restarting, until those processes which have page mapped
> finally unmap it; which is not how truncation is supposed to work.
> 
> So I think you need to have something like a BUG_ON(truncate_op)
> in the page_mapped(page) case, after you've made sure that i_size
> and fault_mutex and lock_page are guaranteeing that a page beyond
> i_size cannot be faulted in.

Yes, I am pretty the truncate/fault race is handled outside this routine.
When I confirm this, I like the idea of a BUG_ON.

> But if that's the case, is there any need to loop back to restart?
> Normally, if a hugetlbfs page is instantiated, it's by faulting into
> userspace; though (I haven't looked) there could easily be races
> whereby the page is put into cache for a fault, then tbe fault
> abandoned because beyond i_size, but page left behind in cache;
> and of course you've just added the fallocate possibility.

It appears that the fault code recehcks i_size and backs out before
adding the page to the cache.  So, I think this will not be an issue.
Again, I just want to look closer the fault code to make sure this
really is the case.

> 
> Ideally, I think you should be able to eliminate the restarting
> altogether: if the locks you take don't already give the necessary
> guarantee, I hope that they can easily be made to do so.
> 
> Alternatively, could you add a single-page hugetlb_vmdelete_list()
> under page lock, to match what ordinary truncation does?  I don't
> recall why you left that out.  But would still prefer that you check,
> and if necessary tighten, the locking to avoid any need for that.

I'm hoping that all that complexity will not be needed.  The 'unmap
single page' was not added because it was not in the original code.
When doing the original hole punch code, my idea was to ignore races
with page faults.  The reasoning (perhaps incorrect) is that there
was no way to tell from user space if the fault or hole punch came
first.  So, just take the easy way out and leave any pages that raced.
It was thinking about adding support for userfaultfd in the future
that forced the issue of actually removing all pages within the hole.
That requires the unmap of single pages within this routine.  So, it
would be added as a requisite for userfaultfd.

> 				bool rsv_on_error = !PagePrivate(page);
> 				/*
> 				 * We must free the huge page and remove
> 				 * from page cache (remove_huge_page) BEFORE
> 				 * removing the region/reserve map
> 				 * (hugetlb_unreserve_pages).  In rare out
> 				 * of memory conditions, removal of the
> 				 * region/reserve map could fail.  Before
> 				 * free'ing the page, note PagePrivate which
> 				 * is used in case of error.
> 				 */
> 				remove_huge_page(page);
> 				freed++;
> 				if (!truncate_op) {
> 					if (unlikely(hugetlb_unreserve_pages(
> 							inode, next,
> 							next + 1, 1)))
> 						hugetlb_fix_reserve_counts(
> 							inode, rsv_on_error);
> 
> Just a note to say that I've never got into the hugetlb reserve business,
> so don't imagine that I'm reviewing or understanding this difficult part.

No worries.

I'll put together another patch.  However, I will first put together an
explanation as to why we do not need to handle truncation/page fault issues
in this routine.  My hope is that will make this much simpler.

-- 
Mike Kravetz

> 
> Hugh
> 
> 				}
> 			}
> 
> 			++next;
> 			unlock_page(page);
> 
> 			mutex_unlock(&hugetlb_fault_mutex_table[hash]);
> 		}
> 		huge_pagevec_release(&pvec);
> 		cond_resched();
> 	}
> 
> 	if (truncate_op)
> 		(void)hugetlb_unreserve_pages(inode, start, LONG_MAX, freed);
> }
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
