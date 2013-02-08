Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id AB9296B0007
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 18:17:06 -0500 (EST)
Received: by mail-vb0-f51.google.com with SMTP id fq11so2610532vbb.24
        for <linux-mm@kvack.org>; Fri, 08 Feb 2013 15:17:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130208202550.GB9817@redhat.com>
References: <1359962232-20811-1-git-send-email-walken@google.com>
	<1359962232-20811-4-git-send-email-walken@google.com>
	<20130208202550.GB9817@redhat.com>
Date: Fri, 8 Feb 2013 15:17:05 -0800
Message-ID: <CANN689EySbVO7Qc5zhpO4A2AazADD8+yx_Mg1Td5KxhxWvGGrw@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] mm: accelerate munlock() treatment of THP pages
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 8, 2013 at 12:25 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Hi Michel,
>
> On Sun, Feb 03, 2013 at 11:17:12PM -0800, Michel Lespinasse wrote:
>> munlock_vma_pages_range() was always incrementing addresses by PAGE_SIZE
>> at a time. When munlocking THP pages (or the huge zero page), this resulted
>> in taking the mm->page_table_lock 512 times in a row.
>>
>> We can do better by making use of the page_mask returned by follow_page_mask
>> (for the huge zero page case), or the size of the page munlock_vma_page()
>> operated on (for the true THP page case).
>>
>> Note - I am sending this as RFC only for now as I can't currently put
>> my finger on what if anything prevents split_huge_page() from operating
>> concurrently on the same page as munlock_vma_page(), which would mess
>> up our NR_MLOCK statistics. Is this a latent bug or is there a subtle
>> point I missed here ?
>
> I agree something looks fishy: nor mmap_sem for writing, nor the page
> lock can stop split_huge_page_refcount.
>
> Now the mlock side was intended to be safe because mlock_vma_page is
> called within follow_page while holding the PT lock or the
> page_table_lock (so split_huge_page_refcount will have to wait for it
> to be released before it can run). See follow_trans_huge_pmd
> assert_spin_locked and the pte_unmap_unlock after mlock_vma_page
> returns.
>
> Problem is, the lock side dependen on the TestSetPageMlocked below to
> be always repeated on the head page (follow_trans_huge_pmd will always
> pass the head page to mlock_vma_page).
>
> void mlock_vma_page(struct page *page)
> {
>         BUG_ON(!PageLocked(page));
>
>         if (!TestSetPageMlocked(page)) {
>
> But what if the head page was split in between two different
> follow_page calls? The second call wouldn't take the pmd_trans_huge
> path anymore and the stats would be increased too much.

Ah, good point. I am getting increasingly scared about the locking
here the more I look at it :/

> The problem on the munlock side is even more apparent as you pointed
> out above but now I think the mlock side was problematic too.
>
> The good thing is, your accelleration code for the mlock side should
> have fixed the mlock race already: not ever risking to end up calling
> mlock_vma_page twice on the head page is not an "accelleration" only,
> it should also be a natural fix for the race.
>
> To fix the munlock side, which is still present, I think one way would
> be to do mlock and unlock within get_user_pages, so they run in the
> same place protected by the PT lock or page_table_lock.

I actually had a quick try at this before submitting this patch
series; the difficulty with it was that we want to have the page lock
before calling munlock_vma_page() and we can't get it while holding
the page table lock. So we'd need to do some gymnastics involving
trylock_page() and if that fails, release the page table lock / lock
the page / reacquire the page table lock / see if we locked the right
page. This looked nasty, and then I noticed the existing
hpage_nr_pages() test in munlock_vma_page() and decided to just ask
you about it :)

> There are few things that stop split_huge_page_refcount:
> page_table_lock, lru_lock, compound_lock, anon_vma lock. So if we keep
> calling munlock_vma_page outside of get_user_pages (so outside of the
> page_table_lock) the other way would be to use the compound_lock.
>
> NOTE: this a purely aesthetical issue in /proc/meminfo, there's
> nothing functional (at least in the kernel) connected to it, so no
> panic :).

Yes.

I think we should try and get the locking right, because wrong code is
just confusing, and it leads people to make incorrect assumptions and
propagate them to places where it may have larger consequences. But
other than that, I agree that the statistics issue we're talking about
here doesn't sound too severe.

I am in a bit of a bind here, as I will be taking a vacation abroad
soon. I would like to get these 3 patches out before then, but I don't
want to do anything too major as I'm not sure what kind of
connectivity I'll have to fix things if needed. I think I'll go with
the simplest option of adding the THP optimizaiton first and fixing
the locking issues at a later stage...

Thanks,

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
