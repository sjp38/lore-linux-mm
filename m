Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id DA0F86B0009
	for <linux-mm@kvack.org>; Sat, 13 Feb 2016 06:54:24 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id p63so53712185wmp.1
        for <linux-mm@kvack.org>; Sat, 13 Feb 2016 03:54:24 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id i127si10549803wma.103.2016.02.13.03.54.22
        for <linux-mm@kvack.org>;
        Sat, 13 Feb 2016 03:54:22 -0800 (PST)
Date: Sat, 13 Feb 2016 12:54:18 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2] x86/mm/vmfault: Make vmalloc_fault() handle large
 pages
Message-ID: <20160213115418.GB15973@pd.tnic>
References: <1455236836-24579-1-git-send-email-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1455236836-24579-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, henning.schild@siemens.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Feb 11, 2016 at 05:27:16PM -0700, Toshi Kani wrote:
> The following oops was observed when a read syscall was made to
> a pmem device after a huge amount (>512GB) of vmalloc ranges was
> allocated by ioremap() on a x86_64 system.
> 
>  BUG: unable to handle kernel paging request at ffff880840000ff8
>  IP: [<ffffffff810664ae>] vmalloc_fault+0x1be/0x300
>  PGD c7f03a067 PUD 0
>  Oops: 0000 [#1] SM
>    :
>  Call Trace:
>  [<ffffffff81067335>] __do_page_fault+0x285/0x3e0
>  [<ffffffff810674bf>] do_page_fault+0x2f/0x80
>  [<ffffffff810d6d85>] ? put_prev_entity+0x35/0x7a0
>  [<ffffffff817a6888>] page_fault+0x28/0x30
>  [<ffffffff813bb976>] ? memcpy_erms+0x6/0x10
>  [<ffffffff817a0845>] ? schedule+0x35/0x80
>  [<ffffffffa006350a>] ? pmem_rw_bytes+0x6a/0x190 [nd_pmem]
>  [<ffffffff817a3713>] ? schedule_timeout+0x183/0x240
>  [<ffffffffa028d2b3>] btt_log_read+0x63/0x140 [nd_btt]
>    :
>  [<ffffffff811201d0>] ? __symbol_put+0x60/0x60
>  [<ffffffff8122dc60>] ? kernel_read+0x50/0x80
>  [<ffffffff81124489>] SyS_finit_module+0xb9/0xf0
>  [<ffffffff817a4632>] entry_SYSCALL_64_fastpath+0x1a/0xa4

Please remove those virtual addresses and offsets here as they're
meaningless and leave only the callstack.

> Since 4.1, ioremap() supports large page (pud/pmd) mappings in
> x86_64 and PAE.  vmalloc_fault() however assumes that the vmalloc
> range is limited to pte mappings.
> 
> vmalloc faults do not normally happen in ioremap'd ranges since
> ioremap() sets up the kernel page tables, which are shared by
> user processes.  pgd_ctor() sets the kernel's pgd entries to
> user's during fork().  When allocation of the vmalloc ranges
> crosses a 512GB boundary, ioremap() allocates a new pud table
> and updates the kernel pgd entry to point it.  If user process's
> pgd entry does not have this update yet, a read/write syscall
> to the range will cause a vmalloc fault, which hits the Oops
> above as it does not handle a large page properly.
> 
> Following changes are made to vmalloc_fault().
> 
> 64-bit:
> - No change for the pgd sync operation as it handles large
>   pages already.
> - Add pud_huge() and pmd_huge() to the validation code to
>   handle large pages.
> - Change pud_page_vaddr() to pud_pfn() since an ioremap range
>   is not directly mapped (while the if-statement still works
>   with a bogus addr).
> - Change pmd_page() to pmd_pfn() since an ioremap range is not
>   backed by struct page (while the if-statement still works
>   with a bogus addr).
> 
> 32-bit:
> - No change for the sync operation since the index3 pgd entry
>   covers the entire vmalloc range, which is always valid.
>   (A separate change to sync pgd entry is necessary if this
>    memory layout is changed regardless of the page size.)
> - Add pmd_huge() to the validation code to handle large pages.
>   This is for completeness since vmalloc_fault() won't happen
>   in ioremap'd ranges as its pgd entry is always valid.
> 
> Reported-by: Henning Schild <henning.schild@siemens.com>
> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Borislav Petkov <bp@alien8.de>
> ---
> When this patch is accepted, please copy to stable up to 4.1.

You can do that yourself when submitting by adding this to the CC-list
above.

Cc: <stable@vger.kernel.org> # 4.1..

Rest looks ok to me.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
