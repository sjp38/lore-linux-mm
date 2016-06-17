Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F31B06B0253
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 04:40:47 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c82so38979549wme.2
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 01:40:47 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id nj9si10670910wjb.213.2016.06.17.01.40.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jun 2016 01:40:46 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id 187so14962731wmz.1
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 01:40:45 -0700 (PDT)
Date: Fri, 17 Jun 2016 11:40:41 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v1 1/2] mm: thp: move pmd check inside ptl for
 freeze_page()
Message-ID: <20160617084041.GA28105@node.shutemov.name>
References: <1466130604-20484-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1466130604-20484-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Jun 17, 2016 at 11:30:03AM +0900, Naoya Horiguchi wrote:
> I found a race condition triggering VM_BUG_ON() in freeze_page(), when running
> a testcase with 3 processes:
>   - process 1: keep writing thp,
>   - process 2: keep clearing soft-dirty bits from virtual address of process 1
>   - process 3: call migratepages for process 1,
>
> The kernel message is like this:
> 
>   kernel BUG at /src/linux-dev/mm/huge_memory.c:3096!
>   invalid opcode: 0000 [#1] SMP
>   Modules linked in: cfg80211 rfkill crc32c_intel ppdev serio_raw pcspkr virtio_balloon virtio_console parport_pc parport pvpanic acpi_cpufreq tpm_tis tpm i2c_piix4 virtio_blk virtio_net ata_generic pata_acpi floppy virtio_pci virtio_ring virtio
>   CPU: 0 PID: 28863 Comm: migratepages Not tainted 4.6.0-v4.6-160602-0827-+ #2
>   Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
>   task: ffff880037320000 ti: ffff88007cdd0000 task.ti: ffff88007cdd0000
>   RIP: 0010:[<ffffffff811f8e06>]  [<ffffffff811f8e06>] split_huge_page_to_list+0x496/0x590
>   RSP: 0018:ffff88007cdd3b70  EFLAGS: 00010202
>   RAX: 0000000000000001 RBX: ffff88007c7b88c0 RCX: 0000000000000000
>   RDX: 0000000000000000 RSI: 0000000700000200 RDI: ffffea0003188000
>   RBP: ffff88007cdd3bb8 R08: 0000000000000001 R09: 00003ffffffff000
>   R10: ffff880000000000 R11: ffffc000001fffff R12: ffffea0003188000
>   R13: ffffea0003188000 R14: 0000000000000000 R15: 0400000000000080
>   FS:  00007f8ec241d740(0000) GS:ffff88007dc00000(0000) knlGS:0000000000000000             CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>   CR2: 00007f8ec1f3ed20 CR3: 000000003707b000 CR4: 00000000000006f0
>   Stack:
>    ffffffff8139ef6d ffffea00031c6280 ffff88011ffec000 0000000000000000
>    0000700000400000 0000700000200000 ffff88007cdd3d08 ffff8800dbbe3008
>    0400000000000080 ffff88007cdd3c20 ffffffff811dd0b1 ffff88007cdd3d68
>   Call Trace:
>    [<ffffffff8139ef6d>] ? list_del+0xd/0x30
>    [<ffffffff811dd0b1>] queue_pages_pte_range+0x4d1/0x590
>    [<ffffffff811ca1a4>] __walk_page_range+0x204/0x4e0
>    [<ffffffff811ca4f1>] walk_page_range+0x71/0xf0
>    [<ffffffff811db935>] queue_pages_range+0x75/0x90
>    [<ffffffff811dcbe0>] ? queue_pages_hugetlb+0x190/0x190
>    [<ffffffff811dca50>] ? new_node_page+0xc0/0xc0
>    [<ffffffff811ddac0>] ? change_prot_numa+0x40/0x40
>    [<ffffffff811dc001>] migrate_to_node+0x71/0xd0
>    [<ffffffff811ddd73>] do_migrate_pages+0x1c3/0x210
>    [<ffffffff811de0b1>] SyS_migrate_pages+0x261/0x290
>    [<ffffffff816f53f2>] entry_SYSCALL_64_fastpath+0x1a/0xa4
>   Code: e8 b0 87 fb ff 0f 0b 48 c7 c6 30 32 9f 81 e8 a2 87 fb ff 0f 0b 48 c7 c6 b8 46 9f 81 e8 94 87 fb ff 0f 0b 85 c0 0f 84 3e fd ff ff <0f> 0b 85 c0 0f 85 a6 00 00 00 48 8b 75 c0 4c 89 f7 41 be f0 ff
>   RIP  [<ffffffff811f8e06>] split_huge_page_to_list+0x496/0x590
>    RSP <ffff88007cdd3b70>
> 
> I'm not sure of the full scenario of the reproduction, but my debug showed that
> split_huge_pmd_address(freeze=true) returned without running main code of pmd
> splitting because pmd_present(*pmd) was 0. If this happens, the subsequent
> try_to_unmap() fails and returns non-zero (because page_mapcount() still > 0),
> and finally VM_BUG_ON() fires.
> 
> This patch fixes it by adding a separate split_huge_pmd_address()'s variant
> for freeze=true and checking pmd's state within ptl for that case.

Checking pmd under ptl is right thing to do, but I want to understand the
scenario first.

Do you have code to trigger this?

> I think that this change seems to fit the comment in split_huge_pmd_address()
> that says "Caller holds the mmap_sem write mode, so a huge pmd cannot
> materialize from under us." We don't hold mmap_sem write if called from
> split_huge_page(), so maybe there were some different assumptions between
> callers (split_huge_page() and vma_adjust_trans_huge().)
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  include/linux/huge_mm.h |  8 ++++----
>  mm/huge_memory.c        | 50 +++++++++++++++++++++++++++++++++++++------------
>  mm/rmap.c               |  3 +--
>  3 files changed, 43 insertions(+), 18 deletions(-)
> 
> diff --git v4.6/include/linux/huge_mm.h v4.6_patched/include/linux/huge_mm.h
> index d7b9e53..6fa4348 100644
> --- v4.6/include/linux/huge_mm.h
> +++ v4.6_patched/include/linux/huge_mm.h
> @@ -108,8 +108,8 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	}  while (0)
>  
>  
> -void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
> -		bool freeze, struct page *page);
> +void split_huge_pmd_address_freeze(struct vm_area_struct *vma,
> +		unsigned long address, struct page *page);
>  
>  extern int hugepage_madvise(struct vm_area_struct *vma,
>  			    unsigned long *vm_flags, int advice);
> @@ -177,8 +177,8 @@ static inline void deferred_split_huge_page(struct page *page) {}
>  #define split_huge_pmd(__vma, __pmd, __address)	\
>  	do { } while (0)
>  
> -static inline void split_huge_pmd_address(struct vm_area_struct *vma,
> -		unsigned long address, bool freeze, struct page *page) {}
> +static inline void split_huge_pmd_address_freeze(struct vm_area_struct *vma,
> +		unsigned long address, struct page *page) {}
>  
>  static inline int hugepage_madvise(struct vm_area_struct *vma,
>  				   unsigned long *vm_flags, int advice)
> diff --git v4.6/mm/huge_memory.c v4.6_patched/mm/huge_memory.c
> index b49ee12..c48f22c 100644
> --- v4.6/mm/huge_memory.c
> +++ v4.6_patched/mm/huge_memory.c
> @@ -2989,6 +2989,16 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  
>  	mmu_notifier_invalidate_range_start(mm, haddr, haddr + HPAGE_PMD_SIZE);
>  	ptl = pmd_lock(mm, pmd);
> +	if (freeze) {
> +		/*
> +		 * If caller asks to setup a migration entries, we need a page
> +		 * to check pmd against. Otherwise we can end up replacing
> +		 * wrong page.
> +		 */
> +		VM_BUG_ON(freeze && !pmd_page(*pmd));
> +		if (!pmd_present(*pmd))

This looks strange. I guess you need to propagate page from caller to
check pmd_page() against it.

And I'm not sure about !pmd_present() check. Do you say that without the
check pmd_trans_huge() below will be taken? I'm confused.

> +			goto out;
> +	}
>  	if (pmd_trans_huge(*pmd)) {
>  		struct page *page = pmd_page(*pmd);
>  		if (PageMlocked(page))
> @@ -3001,8 +3011,8 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	mmu_notifier_invalidate_range_end(mm, haddr, haddr + HPAGE_PMD_SIZE);
>  }
>  
> -void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
> -		bool freeze, struct page *page)
> +static void split_huge_pmd_address(struct vm_area_struct *vma,
> +		unsigned long address, struct page *page)
>  {
>  	pgd_t *pgd;
>  	pud_t *pud;
> @@ -3019,12 +3029,6 @@ void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
>  	pmd = pmd_offset(pud, address);
>  	if (!pmd_present(*pmd) || (!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)))
>  		return;
> -
> -	/*
> -	 * If caller asks to setup a migration entries, we need a page to check
> -	 * pmd against. Otherwise we can end up replacing wrong page.
> -	 */
> -	VM_BUG_ON(freeze && !page);
>  	if (page && page != pmd_page(*pmd))
>  		return;

This check was introduced only for try_to_unmap_one(). Could you check if
moving it under ptl in __split_huge_pmd() would help?

> @@ -3032,7 +3036,29 @@ void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
>  	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
>  	 * materialize from under us.
>  	 */
> -	__split_huge_pmd(vma, pmd, address, freeze);
> +	__split_huge_pmd(vma, pmd, address, false);
> +}
> +
> +void split_huge_pmd_address_freeze(struct vm_area_struct *vma,
> +				unsigned long address, struct page *page)
> +{
> +	pgd_t *pgd;
> +	pud_t *pud;
> +	pmd_t *pmd;
> +
> +	pgd = pgd_offset(vma->vm_mm, address);
> +	if (!pgd_present(*pgd))
> +		return;
> +
> +	pud = pud_offset(pgd, address);
> +	if (!pud_present(*pud))
> +		return;
> +
> +	pmd = pmd_offset(pud, address);
> +	if (pmd_none(*pmd))
> +		return;
> +
> +	__split_huge_pmd(vma, pmd, address, true);
>  }
>  
>  void vma_adjust_trans_huge(struct vm_area_struct *vma,
> @@ -3048,7 +3074,7 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
>  	if (start & ~HPAGE_PMD_MASK &&
>  	    (start & HPAGE_PMD_MASK) >= vma->vm_start &&
>  	    (start & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= vma->vm_end)
> -		split_huge_pmd_address(vma, start, false, NULL);
> +		split_huge_pmd_address(vma, start, NULL);
>  
>  	/*
>  	 * If the new end address isn't hpage aligned and it could
> @@ -3058,7 +3084,7 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
>  	if (end & ~HPAGE_PMD_MASK &&
>  	    (end & HPAGE_PMD_MASK) >= vma->vm_start &&
>  	    (end & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= vma->vm_end)
> -		split_huge_pmd_address(vma, end, false, NULL);
> +		split_huge_pmd_address(vma, end, NULL);
>  
>  	/*
>  	 * If we're also updating the vma->vm_next->vm_start, if the new
> @@ -3072,7 +3098,7 @@ void vma_adjust_trans_huge(struct vm_area_struct *vma,
>  		if (nstart & ~HPAGE_PMD_MASK &&
>  		    (nstart & HPAGE_PMD_MASK) >= next->vm_start &&
>  		    (nstart & HPAGE_PMD_MASK) + HPAGE_PMD_SIZE <= next->vm_end)
> -			split_huge_pmd_address(next, nstart, false, NULL);
> +			split_huge_pmd_address(next, nstart, NULL);
>  	}
>  }
>  
> diff --git v4.6/mm/rmap.c v4.6_patched/mm/rmap.c
> index 307b555..4282b56 100644
> --- v4.6/mm/rmap.c
> +++ v4.6_patched/mm/rmap.c
> @@ -1418,8 +1418,7 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  		goto out;
>  
>  	if (flags & TTU_SPLIT_HUGE_PMD) {
> -		split_huge_pmd_address(vma, address,
> -				flags & TTU_MIGRATION, page);
> +		split_huge_pmd_address_freeze(vma, address, page);
>  		/* check if we have anything to do after split */
>  		if (page_mapcount(page) == 0)
>  			goto out;
> -- 
> 2.7.0
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
