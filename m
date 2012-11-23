Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 34D256B005D
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 20:26:10 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id lz20so10856688obb.14
        for <linux-mm@kvack.org>; Thu, 22 Nov 2012 17:26:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121120160918.GA18167@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
	<20121119162909.GL8218@suse.de>
	<20121119191339.GA11701@gmail.com>
	<20121119211804.GM8218@suse.de>
	<20121119223604.GA13470@gmail.com>
	<CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
	<20121120071704.GA14199@gmail.com>
	<20121120152933.GA17996@gmail.com>
	<20121120160918.GA18167@gmail.com>
Date: Fri, 23 Nov 2012 09:26:08 +0800
Message-ID: <CAGjg+kHtdFE9Nc9ZTRjf73zwrOV77T=uX3ojsP=FWt8wbc2WBQ@mail.gmail.com>
Subject: Re: [PATCH, v2] mm, numa: Turn 4K pte NUMA faults into effective
 hugepage ones
From: Alex Shi <lkml.alex@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Alex Shi <alex.shi@intel.com>

This patch cause boot hang on our SNB EP 2 sockets machine with some
segmentation fault.
revert it recovers booting.

============
[    8.290147] Freeing unused kernel memory: 1264k freed
[    8.306140] Freeing unused kernel memory: 1592k freed
[    8.342668] init[250]: segfault at 20da510 ip 00000000020da510 sp
00007fff26788040 error 15[    8.350983] usb 2-1: New USB device found,
idVendor=8087, idProduct=0024
[    8.350987] usb 2-1: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[    8.351266] hub 2-1:1.0: USB hub found
[    8.351346] hub 2-1:1.0: 8 ports detected

Segmentation fault
[    8.626633] usb 2-1.4: new full-speed USB device number 3 using ehci_hcd
[    8.721391] usb 2-1.4: New USB device found, idVendor=046b, idProduct=ff10
[    8.729536] usb 2-1.4: New USB device strings: Mfr=1, Product=2,
SerialNumber=3
[    8.738540] usb 2-1.4: Product: Virtual Keyboard and Mouse
[    8.745134] usb 2-1.4: Manufacturer: American Megatrends Inc.
[    8.752026] usb 2-1.4: SerialNumber: serial
[    8.758877] input: American Megatrends Inc. Virtual Keyboard and
Mouse as /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.0/input/input1
[    8.774428] hid-generic 0003:046B:FF10.0001: input,hidraw0: USB HID
v1.10 Keyboard [American Megatrends Inc. Virtual Keyboard and Mouse]
on usb-0000:00:1d.0-1.4/input0
[    8.793393] input: American Megatrends Inc. Virtual Keyboard and
Mouse as /devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.4/2-1.4:1.1/input/input2
[    8.809140] hid-generic 0003:046B:FF10.0002: input,hidraw1: USB HID
v1.10 Mouse [American Megatrends Inc. Virtual Keyboard and Mouse] on
usb-0000:00:1d.0-1.4/input1
[    8.899511] usb 2-1.7: new low-speed USB device number 4 using ehci_hcd
[    9.073473] usb 2-1.7: New USB device found, idVendor=0557, idProduct=2220
[    9.081633] usb 2-1.7: New USB device strings: Mfr=1, Product=2,
SerialNumber=0
[    9.090643] usb 2-1.7: Product: ATEN  CS-1758/54
[    9.096258] usb 2-1.7: Manufacturer: ATEN
[    9.134093] input: ATEN ATEN  CS-1758/54 as
/devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.7/2-1.7:1.0/input/input3
[    9.146804] hid-generic 0003:0557:2220.0003: input,hidraw2: USB HID
v1.10 Keyboard [ATEN ATEN  CS-1758/54] on usb-0000:00:1d.0-1.7/input0
[    9.184396] input: ATEN ATEN  CS-1758/54 as
/devices/pci0000:00/0000:00:1d.0/usb2/2-1/2-1.7/2-1.7:1.1/input/input4
[    9.197210] hid-generic 0003:0557:2220.0004: input,hidraw3: USB HID
v1.10 Mouse [ATEN ATEN  CS-1758/54] on usb-0000:00:1d.0-1.7/input1

<hang here>

On Wed, Nov 21, 2012 at 12:09 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> Ok, the patch withstood a bit more testing as well. Below is a
> v2 version of it, with a couple of cleanups (no functional
> changes).
>
> Thanks,
>
>         Ingo
>
> ----------------->
> Subject: mm, numa: Turn 4K pte NUMA faults into effective hugepage ones
> From: Ingo Molnar <mingo@kernel.org>
> Date: Tue Nov 20 15:48:26 CET 2012
>
> Reduce the 4K page fault count by looking around and processing
> nearby pages if possible.
>
> To keep the logic and cache overhead simple and straightforward
> we do a couple of simplifications:
>
>  - we only scan in the HPAGE_SIZE range of the faulting address
>  - we only go as far as the vma allows us
>
> Also simplify the do_numa_page() flow while at it and fix the
> previous double faulting we incurred due to not properly fixing
> up freshly migrated ptes.
>
> Suggested-by: Mel Gorman <mgorman@suse.de>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Ingo Molnar <mingo@kernel.org>
> ---
>  mm/memory.c |   99 ++++++++++++++++++++++++++++++++++++++----------------------
>  1 file changed, 64 insertions(+), 35 deletions(-)
>
> Index: linux/mm/memory.c
> ===================================================================
> --- linux.orig/mm/memory.c
> +++ linux/mm/memory.c
> @@ -3455,64 +3455,93 @@ static int do_nonlinear_fault(struct mm_
>         return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
>  }
>
> -static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +static int __do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
>                         unsigned long address, pte_t *ptep, pmd_t *pmd,
> -                       unsigned int flags, pte_t entry)
> +                       unsigned int flags, pte_t entry, spinlock_t *ptl)
>  {
> -       struct page *page = NULL;
> -       int node, page_nid = -1;
> -       int last_cpu = -1;
> -       spinlock_t *ptl;
> -
> -       ptl = pte_lockptr(mm, pmd);
> -       spin_lock(ptl);
> -       if (unlikely(!pte_same(*ptep, entry)))
> -               goto out_unlock;
> +       struct page *page;
> +       int new_node;
>
>         page = vm_normal_page(vma, address, entry);
>         if (page) {
> -               get_page(page);
> -               page_nid = page_to_nid(page);
> -               last_cpu = page_last_cpu(page);
> -               node = mpol_misplaced(page, vma, address);
> -               if (node != -1 && node != page_nid)
> +               int page_nid = page_to_nid(page);
> +               int last_cpu = page_last_cpu(page);
> +
> +               task_numa_fault(page_nid, last_cpu, 1);
> +
> +               new_node = mpol_misplaced(page, vma, address);
> +               if (new_node != -1 && new_node != page_nid)
>                         goto migrate;
>         }
>
> -out_pte_upgrade_unlock:
> +out_pte_upgrade:
>         flush_cache_page(vma, address, pte_pfn(entry));
> -
>         ptep_modify_prot_start(mm, address, ptep);
>         entry = pte_modify(entry, vma->vm_page_prot);
> +       if (pte_dirty(entry))
> +               entry = pte_mkwrite(entry);
>         ptep_modify_prot_commit(mm, address, ptep, entry);
> -
>         /* No TLB flush needed because we upgraded the PTE */
> -
>         update_mmu_cache(vma, address, ptep);
> -
> -out_unlock:
> -       pte_unmap_unlock(ptep, ptl);
> -
> -       if (page) {
> -               task_numa_fault(page_nid, last_cpu, 1);
> -               put_page(page);
> -       }
>  out:
>         return 0;
>
>  migrate:
> +       get_page(page);
>         pte_unmap_unlock(ptep, ptl);
>
> -       if (migrate_misplaced_page(page, node)) {
> +       migrate_misplaced_page(page, new_node); /* Drops the page reference */
> +
> +       /* Re-check after migration: */
> +
> +       ptl = pte_lockptr(mm, pmd);
> +       spin_lock(ptl);
> +       entry = ACCESS_ONCE(*ptep);
> +
> +       if (!pte_numa(vma, entry))
>                 goto out;
> -       }
> -       page = NULL;
>
> -       ptep = pte_offset_map_lock(mm, pmd, address, &ptl);
> -       if (!pte_same(*ptep, entry))
> -               goto out_unlock;
> +       goto out_pte_upgrade;
> +}
> +
> +/*
> + * Add a simple loop to also fetch ptes within the same pmd:
> + */
> +static int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
> +                       unsigned long addr0, pte_t *ptep0, pmd_t *pmd,
> +                       unsigned int flags, pte_t entry0)
> +{
> +       unsigned long addr0_pmd;
> +       unsigned long addr_start;
> +       unsigned long addr;
> +       spinlock_t *ptl;
> +       pte_t *ptep;
> +
> +       addr0_pmd = addr0 & PMD_MASK;
> +       addr_start = max(addr0_pmd, vma->vm_start);
>
> -       goto out_pte_upgrade_unlock;
> +       ptep = pte_offset_map(pmd, addr_start);
> +       ptl = pte_lockptr(mm, pmd);
> +       spin_lock(ptl);
> +
> +       for (addr = addr_start; addr < vma->vm_end; addr += PAGE_SIZE, ptep++) {
> +               pte_t entry;
> +
> +               entry = ACCESS_ONCE(*ptep);
> +
> +               if ((addr & PMD_MASK) != addr0_pmd)
> +                       break;
> +               if (!pte_present(entry))
> +                       continue;
> +               if (!pte_numa(vma, entry))
> +                       continue;
> +
> +               __do_numa_page(mm, vma, addr, ptep, pmd, flags, entry, ptl);
> +       }
> +
> +       pte_unmap_unlock(ptep, ptl);
> +
> +       return 0;
>  }
>
>  /*
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
