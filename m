Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE5F66B025E
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 11:38:04 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id v8so4975970otd.4
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 08:38:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p124sor2432523oib.26.2017.12.15.08.38.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 08:38:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171215113838.nqxcjyyhfy4g7ipk@hirez.programming.kicks-ass.net>
References: <20171214112726.742649793@infradead.org> <20171214113851.146259969@infradead.org>
 <20171214124117.wfzcjdczyta2sery@hirez.programming.kicks-ass.net>
 <20171214143730.s6w7sd6c7b5t6fqp@hirez.programming.kicks-ass.net>
 <f0244eb7-bd9f-dce4-68a5-cf5f8b43652e@intel.com> <20171214205450.GI3326@worktop>
 <8eedb9a3-0ba2-52df-58f6-3ed869d18ca3@intel.com> <20171215080041.zftzuxdonxrtmssq@hirez.programming.kicks-ass.net>
 <20171215102529.vtsjhb7h7jiufkr3@hirez.programming.kicks-ass.net> <20171215113838.nqxcjyyhfy4g7ipk@hirez.programming.kicks-ass.net>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 15 Dec 2017 08:38:02 -0800
Message-ID: <CAPcyv4ghxbdWoRF6U=PSLLQaUKGx55MzYSPVrtsBug7ETv5ybg@mail.gmail.com>
Subject: Re: [PATCH v2 01/17] mm/gup: Fixup p*_access_permitted()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, keescook@google.com, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, Linux MM <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Fri, Dec 15, 2017 at 3:38 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Fri, Dec 15, 2017 at 11:25:29AM +0100, Peter Zijlstra wrote:
>> The memory one is also clearly wrong, not having access does not a write
>> fault make. If we have pte_write() set we should not do_wp_page() just
>> because we don't have access. This falls under the "doing anything other
>> than hard failure for !access is crazy" header.
>
> So per the very same reasoning I think the below is warranted too; also
> rename that @dirty variable, because its also wrong.
>
> diff --git a/mm/memory.c b/mm/memory.c
> index 5eb3d2524bdc..0d43b347eb0a 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3987,7 +3987,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>                 .pgoff = linear_page_index(vma, address),
>                 .gfp_mask = __get_fault_gfp_mask(vma),
>         };
> -       unsigned int dirty = flags & FAULT_FLAG_WRITE;
> +       unsigned int write = flags & FAULT_FLAG_WRITE;
>         struct mm_struct *mm = vma->vm_mm;
>         pgd_t *pgd;
>         p4d_t *p4d;
> @@ -4013,7 +4013,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>
>                         /* NUMA case for anonymous PUDs would go here */
>
> -                       if (dirty && !pud_access_permitted(orig_pud, WRITE)) {
> +                       if (write && !pud_write(orig_pud)) {
>                                 ret = wp_huge_pud(&vmf, orig_pud);
>                                 if (!(ret & VM_FAULT_FALLBACK))
>                                         return ret;
> @@ -4046,7 +4046,7 @@ static int __handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>                         if (pmd_protnone(orig_pmd) && vma_is_accessible(vma))
>                                 return do_huge_pmd_numa_page(&vmf, orig_pmd);
>
> -                       if (dirty && !pmd_access_permitted(orig_pmd, WRITE)) {
> +                       if (write && !pmd_write(orig_pmd)) {
>                                 ret = wp_huge_pmd(&vmf, orig_pmd);
>                                 if (!(ret & VM_FAULT_FALLBACK))
>                                         return ret;
>
>
> I still cannot make sense of what the intention behind these changes
> were, the Changelog that went with them is utter crap, it doesn't
> explain anything.

The motivation was that I noticed that get_user_pages_fast() was doing
a full pud_access_permitted() check, but the get_user_pages() slow
path was only doing a pud_write() check. That was inconsistent so I
went to go resolve that across all the pte types and ended up making a
mess of things, I'm fine if the answer is that we should have went the
other way to only do write checks. However, when I was investigating
which way to go the aspect that persuaded me to start sprinkling
p??_access_permitted checks around was that the application behavior
changed between mmap access and direct-i/o access to the same buffer.
I assumed that different access behavior between those would be an
inconsistent surprise to userspace. Although, infinitely looping in
handle_mm_fault is an even worse surprise, apologies for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
