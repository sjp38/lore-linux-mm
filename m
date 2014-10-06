Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f172.google.com (mail-lb0-f172.google.com [209.85.217.172])
	by kanga.kvack.org (Postfix) with ESMTP id F272B6B0069
	for <linux-mm@kvack.org>; Mon,  6 Oct 2014 11:56:44 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id b6so4605209lbj.3
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 08:56:44 -0700 (PDT)
Received: from mail-lb0-x236.google.com (mail-lb0-x236.google.com [2a00:1450:4010:c04::236])
        by mx.google.com with ESMTPS id l8si19561534lah.23.2014.10.06.08.56.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Oct 2014 08:56:43 -0700 (PDT)
Received: by mail-lb0-f182.google.com with SMTP id z11so4383904lbi.41
        for <linux-mm@kvack.org>; Mon, 06 Oct 2014 08:56:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAM2a4uyQXkuM-yJ5MK1D2E3fjcaohv5Pbb4nSJJ5M=Vsxd-muA@mail.gmail.com>
References: <CAM2a4uyQXkuM-yJ5MK1D2E3fjcaohv5Pbb4nSJJ5M=Vsxd-muA@mail.gmail.com>
Date: Mon, 6 Oct 2014 21:26:42 +0530
Message-ID: <CAM2a4uz9CpP8so+ovCYO5qP_Y+72rW2bsBCvpRJaku=2JWFfKA@mail.gmail.com>
Subject: Re: On page table walk.
From: mind entropy <mindentropy@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

On Fri, Oct 3, 2014 at 1:04 AM, mind entropy <mindentropy@gmail.com> wrote:
> Hi,
>
>   I am experimenting with page table walking. I run a user space
> program and mmap a memory region and pass the address to the module.
>
>   In the kernel module I get the current->mm to get the current task
> memory descriptor and use it to walk the pages. Once I get the pte
> address I reboot and dump the memory at that point using u-boot. (md.b
> <addr> 1)
> but I do not find the values present there. ( I have filled the region
> with incremental value starting from 0 to 255).
>
> My processor is a Samsung S3C2440 ARM920T (mini2440 development
> board). The physical address starts at 0x30000000.
>
> -------------------------------------------------------------------
> Sample code of the page walk: (This is just for illustration and
> experimenting and does
> not contain error checks etc.).
>
> void my_follow_page(struct mm_struct *mm,
>                     unsigned long addr_res)
> {
>     pgd_t *pgd;
>     pmd_t *pmd;
>     pud_t *pud;
>     pte_t *ptep, pte;
>     struct page *page;
>
>
>     down_read(&(mm->mmap_sem));
>
>     pgd = pgd_offset(mm,addr_res);
>
>     if(pgd_none(*pgd) || pgd_bad(*pgd)) {
>         printk(KERN_ALERT "pgd bad\n");
>         return;
>     } else {
>         printk(KERN_ALERT "pgd 0x%lx\n",(unsigned long)pgd);
>     }
>
>     pud = pud_offset(pgd,addr_res);
>
>     if(pud_none(*pud) || pud_bad(*pud)) {
>         printk(KERN_ALERT "pud bad\n");
>         return;
>     } else {
>         printk(KERN_ALERT "pud 0x%lx\n",(unsigned long)pud);
>     }
>
>     pmd = pmd_offset(pud,addr_res);
>
>     if(pmd_none(*pmd) || pmd_bad(*pmd)) {
>         printk(KERN_ALERT "pmd bad\n");
>         return;
>     } else {
>         printk(KERN_ALERT "pmd 0x%lx\n",(unsigned long)pmd);
>     }
>
>
>     ptep = pte_offset_map(pmd,addr_res);
>     if(!ptep) {
>         printk(KERN_ALERT "ptep bad\n");
>     } else {
>         printk(KERN_ALERT "ptep 0x%lx\n",(unsigned long)ptep);
>     }
>
>     pte = *ptep;
>
>
>     if(pte_present(pte)) {
>         printk(KERN_ALERT "pte : 0x%lx\n",(unsigned long)pte);
>         page = pte_page(pte);
>     } else {
>         printk(KERN_ALERT "pte not present\n");
>     }
>
>     printk(KERN_ALERT "pte with offset 0x%lx offset : 0x%lx\n",
>             pte+((addr_res) & ((1<<PAGE_SHIFT)-1)),
>             addr_res & ((1<<PAGE_SHIFT)-1));
>
>     up_read(&(mm->mmap_sem));
> }
>
> -------------------------------------------------------------------
>
> Sample output:
>
> [   86.447788] Current task pid: 2384
> [   86.447885] mm: 0xc3b39a80, active_mm 0xc3b39a80
> [   86.451594] Page global directory : 0xc3af4000
> [   86.456127] mmap base : 0xb6f60000
> [   86.459175] vm_start : 0x8000, vm_end : 0x9000
> [   86.463684] vm_start : 0x10000, vm_end : 0x11000
> [   86.468202] vm_start : 0x100000, vm_end : 0x101000
> [   86.472884] vm_start : 0xb6dfc000, vm_end : 0xb6f25000
> [   86.477975] vm_start : 0xb6f25000, vm_end : 0xb6f2c000
> [   86.483000] vm_start : 0xb6f2c000, vm_end : 0xb6f2e000
> [   86.488070] vm_start : 0xb6f2e000, vm_end : 0xb6f2f000
> [   86.493080] vm_start : 0xb6f2f000, vm_end : 0xb6f32000
> [   86.498089] vm_start : 0xb6f3a000, vm_end : 0xb6f57000
> [   86.503120] vm_start : 0xb6f5a000, vm_end : 0xb6f5d000
> [   86.508149] vm_start : 0xb6f5d000, vm_end : 0xb6f5e000
> [   86.513187] vm_start : 0xb6f5e000, vm_end : 0xb6f5f000
> [   86.518225] vm_start : 0xb6f5f000, vm_end : 0xb6f60000
> [   86.523251] vm_start : 0xbe934000, vm_end : 0xbe956000
> [   86.528299] kval : 3020100
> [   86.530870] addr: 100000
> [   86.533446] pgd 0xc3af4000
> [   86.535992] pud 0xc3af4000
> [   86.538720] pmd 0xc3af4000
> [   86.541281] ptep 0xc3b0e400
> [   86.544071] pte : 0x3278214f
> [   86.546831] pte with offset 0x3278214f offset : 0x0
>
>
> The problem is that when I do a md.b 0x3278214f 100 in u-boot to do a
> memory dump I see the values in it but I don't see the exact value
> filled in that memory location. What am I doing wrong?
>
> Thanks,
> Gautam.


Got it working. Thanks to riel on #mm the pte which I am using
contains other bits not related to the physical address. I have to do
a pte_pfn(pte) to get the page frame number. The pfn to physical addr
can be got by (pfn<<PAGE_SHIFT) + (addr_res & ~PAGE_MASK). The
addr_res & ~PAGE_MASK gives the offset in the physical frame.

So the final code looks as


--------------------------------------------------------
    printk(KERN_ALERT "pfn from pte : 0x%lx\n",pfn = pte_pfn(pte));
    printk(KERN_ALERT "pfn to addr : 0x%lx, addr_res :
0x%lx\n",(pfn<<PAGE_SHIFT),
                    (unsigned long)PAGE_MASK);
    printk(KERN_ALERT "phys_addr : 0x%lx\n",(pfn<<PAGE_SHIFT) +
(addr_res & ~PAGE_MASK));
--------------------------------------------------------


Thanks,
Gautam.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
