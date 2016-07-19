Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id B57406B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 05:17:27 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id l89so8093681lfi.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 02:17:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k11si18887152wmb.131.2016.07.19.02.17.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 02:17:26 -0700 (PDT)
Date: Tue, 19 Jul 2016 11:17:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/hugetlb: fix race when migrate pages.
Message-ID: <20160719091724.GD9490@dhcp22.suse.cz>
References: <1468897140-43471-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468897140-43471-1-git-send-email-zhongjiang@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, qiuxishi@huawei.com, linux-mm@kvack.org

On Tue 19-07-16 10:59:00, zhongjiang wrote:
> From: zhong jiang <zhongjiang@huawei.com>
> 
> I hit the following problem when run the database and online-offline memory
> in the system.
> The kernel version is 3.10. but I think the mainline have some question to
> be solved.
> 
>  kernel BUG at arch/x86/mm/hugetlbpage.c:161!
> [154364.730387] invalid opcode: 0000 [#1] SMP
> [154364.734795] Modules linked in: nls_utf8 isofs loop signo_catch(OV) iTCO_wdt iTCO_vendor_support coretemp vfat intel_rapl fat kvm_intel kvm crct10dif_pclmul crc32_pclmul crc32c_intel ghash_clmulni_intel aesni_intel lrw gf128mul       glue_helper ablk_helper cryptd pcspkr sb_edac edac_core i2c_i801 lpc_ich ses i2c_core mfd_core enclosure mei_me mei shpchp wmi ipmi_devintf ipmi_si ipmi_msghandler binfmt_misc xfs libcrc32c sd_mod crc_t10dif crct10dif_common ahci l      ibahci tg3 ptp libata pps_core megaraid_sas dm_mirror dm_region_hash dm_log dm_mod
> [154364.786831] CPU: 171 PID: 700733 Comm: oracle Tainted: G           O   ----V-------   3.10.0-229.30.1.44.hulk.x86_64 #1 SMP Fri Jun 24 13:02:35 CST 2016
> [154364.809927] task: ffff8826bb0cae00 ti: ffff8826a36c4000 task.ti: ffff8826a36c4000
> [154364.817541] RIP: 0010:[<ffffffff81061382>]  [<ffffffff81061382>] huge_pte_alloc+0x452/0x4d0
> [154364.826135] RSP: 0018:ffff8826a36c7c58  EFLAGS: 00010246
> [154364.831583] RAX: ffff882609e16350 RBX: ffff88180845d000 RCX: ffff880000000000
> [154364.838848] RDX: 0000014538fc0000 RSI: 0000005d0d400000 RDI: 0000002609e16067
> [154364.846111] RBP: ffff8826a36c7c98 R08: ffff880000000000 R09: ffff88265b2f83e0
> [154364.853378] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000200000
> [154364.860641] R13: ffff88190475dba0 R14: ffff880000000350 R15: 0000005d0d400000
> [154364.867908] FS:  00007ff87a54a740(0000) GS:ffff88001dc60000(0000) knlGS:0000000000000000
> [154364.876123] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [154364.882004] CR2: 00007f61b8ebee14 CR3: 00000025f3a16000 CR4: 00000000001407e0
> [154364.889270] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [154364.896533] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
> [154364.903797] Stack:
> [154364.905960]  ffff88265b2f83f8 ffff882609e16000 ffff880a8fc88c80 ffff882609e16350
> [154364.914096]  ffff882609e16348 ffffffff81e41060 ffff880a8fc88c80 0000005d0d400000
> [154364.922224]  ffff8826a36c7d18 ffffffff8119c322 0000005e20000000 00000000e0000000
> [154364.930357] Call Trace:
> [154364.933045]  [<ffffffff8119c322>] copy_hugetlb_page_range+0x152/0x2f0
> [154364.939702]  [<ffffffff81180ef9>] copy_page_range+0x3d9/0x480
> [154364.945654]  [<ffffffff8118543e>] ? vma_gap_callbacks_rotate+0x1e/0x30
> [154364.952402]  [<ffffffff812d903f>] ? __rb_insert_augmented+0x8f/0x1f0
> [154364.958957]  [<ffffffff81186118>] ? __vma_link_rb+0xb8/0xe0
> [154364.964743]  [<ffffffff8106c787>] dup_mm+0x357/0x660
> [154364.969915]  [<ffffffff8106d4fb>] copy_process.part.25+0xa3b/0x14b0
> [154364.976384]  [<ffffffff8106e12c>] do_fork+0xbc/0x350
> [154364.981569]  [<ffffffff811e3960>] ? get_unused_fd_flags+0x30/0x40
> [154364.987864]  [<ffffffff8106e446>] SyS_clone+0x16/0x20
> [154364.993140]  [<ffffffff81610059>] stub_clone+0x69/0x90
> [154364.998483]  [<ffffffff8160fd09>] ? system_call_fastpath+0x16/0x1b

OK, so this states the problem. Although it would be helpful to be
specific about which BUG has triggered because the above line doesn't
match any in the current code. I assume this is 

BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte))

in huge_pte_alloc. Now the changelog is silent about what the actual
problem is and what is the fix. Could you add this information please?

> 
> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  mm/hugetlb.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 6384dfd..1b54d7a 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -4213,13 +4213,14 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  	struct vm_area_struct *svma;
>  	unsigned long saddr;
>  	pte_t *spte = NULL;
> -	pte_t *pte;
> +	pte_t *pte, entry;
>  	spinlock_t *ptl;
>  
>  	if (!vma_shareable(vma, addr))
>  		return (pte_t *)pmd_alloc(mm, pud, addr);
>  
>  	i_mmap_lock_write(mapping);
> +retry:
>  	vma_interval_tree_foreach(svma, &mapping->i_mmap, idx, idx) {
>  		if (svma == vma)
>  			continue;
> @@ -4240,6 +4241,12 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>  
>  	ptl = huge_pte_lockptr(hstate_vma(vma), mm, spte);
>  	spin_lock(ptl);
> +	entry = huge_ptep_get(spte);
> + 	if (is_hugetlb_entry_migration(entry) || 
> +			is_hugetlb_entry_hwpoisoned(entry)) {
> +		spin_unlock(ptl);
> +		goto retry;
> +	}	
>  	if (pud_none(*pud)) {
>  		pud_populate(mm, pud,
>  				(pmd_t *)((unsigned long)spte & PAGE_MASK));
> -- 
> 1.8.3.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
