Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id A67748D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 17:48:56 -0500 (EST)
Received: by iwl42 with SMTP id 42so7204534iwl.14
        for <linux-mm@kvack.org>; Tue, 08 Mar 2011 14:48:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110308125830.GS25641@random.random>
References: <AANLkTikJpr9H2NJHyw_uajL=Ef_p16L3QYgmJSfFynSZ@mail.gmail.com>
	<AANLkTinncv11r3cJnOr0HWZyaSu5NQMz6pEYThMkmFd0@mail.gmail.com>
	<AANLkTikKtxEoXT=Y9d80oYnY7LvfLn8Hwz-XorSxR3Mv@mail.gmail.com>
	<20110308113245.GR25641@random.random>
	<20110308122115.GA28054@google.com>
	<20110308125830.GS25641@random.random>
Date: Wed, 9 Mar 2011 07:48:54 +0900
Message-ID: <AANLkTinNNN2BDnqj9S3PF7goS4tygzmO8ZmC+S5kvH1M@mail.gmail.com>
Subject: Re: THP, rmap and page_referenced_one()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michel Lespinasse <walken@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>

On Tue, Mar 8, 2011 at 9:58 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> On Tue, Mar 08, 2011 at 04:21:15AM -0800, Michel Lespinasse wrote:
>> On Tue, Mar 08, 2011 at 12:32:45PM +0100, Andrea Arcangeli wrote:
>> > I only run some basic testing, please review. I seen no reason to
>> > return "referenced = 0" if the pmd is still splitting. So I let it go
>> > ahead now and test_and_set_bit the accessed bit even on a splitting
>> > pmd. After all the tlb miss could still activate the young bit on a
>> > pmd while it's in splitting state. There's no check for splitting in
>> > the pmdp_clear_flush_young. The secondary mmu has no secondary spte
>> > mapped while it's set to splitting so it shouldn't matter for it if we
>> > clear the young bit (and new secondary mmu page faults will wait on
>> > splitting to clear and __split_huge_page_map to finish before going
>> > ahead creating new secondary sptes with 4k granularity).
>>
>> Agree, the pmd_trans_splitting check didn't seem necessary.
>>
>> Thanks for the patch, looks fine, I only have a couple nitpicks regarding
>> code comments:
>>
>
> Ok, updated comments... thanks for the quick review. Try #2:
>
> ===
> Subject: thp: fix page_referenced to modify mapcount/vm_flags only if page is found
>
> From: Andrea Arcangeli <aarcange@redhat.com>
>
> When vmscan.c calls page_referenced, if an anon page was created before a
> process forked, rmap will search for it in both of the processes, even though
> one of them might have since broken COW. If the child process mlocks the vma
> where the COWed page belongs to, page_referenced() running on the page mapped
> by the parent would lead to *vm_flags getting VM_LOCKED set erroneously (leading
> to the references on the parent page being ignored and evicting the parent page
> too early).
>
> *mapcount would also be decremented by page_referenced_one even if the page
> wasn't found by page_check_address.
>
> This also let pmdp_clear_flush_young_notify() go ahead on a
> pmd_trans_splitting() pmd. We hold the page_table_lock so
> __split_huge_page_map() must wait the pmdp_clear_flush_young_notify() to
> complete before it can modify the pmd. The pmd is also still mapped in userland
> so the young bit may materialize through a tlb miss before split_huge_page_map
> runs. This will provide a more accurate page_referenced() behavior during
> split_huge_page().
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Reported-by: Michel Lespinasse <walken@google.com>
> Reviewed-by: Michel Lespinasse <walken@google.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
