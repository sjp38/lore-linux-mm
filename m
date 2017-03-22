Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C667C6B0333
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 08:29:17 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id g8so10403992wmg.7
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 05:29:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x61si1961376wrb.294.2017.03.22.05.29.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Mar 2017 05:29:16 -0700 (PDT)
Date: Wed, 22 Mar 2017 08:29:09 -0400
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] mm, hugetlb: use pte_present() instead of
 pmd_present() in follow_huge_pmd()
Message-ID: <20170322122909.GA1407@dhcp22.suse.cz>
References: <1490149898-20231-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1490149898-20231-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, Mike Kravetz <mike.kravetz@oracle.com>

[CC Mike]

On Wed 22-03-17 11:31:38, Naoya Horiguchi wrote:
> I found the race condition which triggers the following bug when
> move_pages() and soft offline are called on a single hugetlb page
> concurrently.
> 
>     [61163.578957] Soft offlining page 0x119400 at 0x700000000000
>     [61163.580062] BUG: unable to handle kernel paging request at ffffea0011943820
>     [61163.580791] IP: follow_huge_pmd+0x143/0x190
>     [61163.581203] PGD 7ffd2067
>     [61163.581204] PUD 7ffd1067
>     [61163.581471] PMD 0
>     [61163.581723]
>     [61163.582052] Oops: 0000 [#1] SMP
>     [61163.582349] Modules linked in: binfmt_misc ppdev virtio_balloon parport_pc pcspkr i2c_piix4 parport i2c_core acpi_cpufreq ip_tables xfs libcrc32c ata_generic pata_acpi virtio_blk 8139too crc32c_intel ata_piix serio_raw libata virtio_pci 8139cp virtio_ring virtio mii floppy dm_mirror dm_region_hash dm_log dm_mod [last unloaded: cap_check]
>     [61163.585130] CPU: 0 PID: 22573 Comm: iterate_numa_mo Tainted: P           OE   4.11.0-rc2-mm1+ #2
>     [61163.586055] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2011
>     [61163.586627] task: ffff88007c951680 task.stack: ffffc90004bd8000
>     [61163.587181] RIP: 0010:follow_huge_pmd+0x143/0x190
>     [61163.587622] RSP: 0018:ffffc90004bdbcd0 EFLAGS: 00010202
>     [61163.588096] RAX: 0000000465003e80 RBX: ffffea0004e34d30 RCX: 00003ffffffff000
>     [61163.588818] RDX: 0000000011943800 RSI: 0000000000080001 RDI: 0000000465003e80
>     [61163.589486] RBP: ffffc90004bdbd18 R08: 0000000000000000 R09: ffff880138d34000
>     [61163.590097] R10: ffffea0004650000 R11: 0000000000c363b0 R12: ffffea0011943800
>     [61163.590751] R13: ffff8801b8d34000 R14: ffffea0000000000 R15: 000077ff80000000
>     [61163.591375] FS:  00007fc977710740(0000) GS:ffff88007dc00000(0000) knlGS:0000000000000000
>     [61163.592068] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>     [61163.592627] CR2: ffffea0011943820 CR3: 000000007a746000 CR4: 00000000001406f0
>     [61163.593330] Call Trace:
>     [61163.593556]  follow_page_mask+0x270/0x550
>     [61163.593908]  SYSC_move_pages+0x4ea/0x8f0
>     [61163.594253]  ? lru_cache_add_active_or_unevictable+0x4b/0xd0
>     [61163.594798]  SyS_move_pages+0xe/0x10
>     [61163.595113]  do_syscall_64+0x67/0x180
>     [61163.595434]  entry_SYSCALL64_slow_path+0x25/0x25
>     [61163.595837] RIP: 0033:0x7fc976e03949
>     [61163.596148] RSP: 002b:00007ffe72221d88 EFLAGS: 00000246 ORIG_RAX: 0000000000000117
>     [61163.596940] RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00007fc976e03949
>     [61163.597567] RDX: 0000000000c22390 RSI: 0000000000001400 RDI: 0000000000005827
>     [61163.598177] RBP: 00007ffe72221e00 R08: 0000000000c2c3a0 R09: 0000000000000004
>     [61163.598842] R10: 0000000000c363b0 R11: 0000000000000246 R12: 0000000000400650
>     [61163.599456] R13: 00007ffe72221ee0 R14: 0000000000000000 R15: 0000000000000000
>     [61163.600067] Code: 81 e4 ff ff 1f 00 48 21 c2 49 c1 ec 0c 48 c1 ea 0c 4c 01 e2 49 bc 00 00 00 00 00 ea ff ff 48 c1 e2 06 49 01 d4 f6 45 bc 04 74 90 <49> 8b 7c 24 20 40 f6 c7 01 75 2b 4c 89 e7 8b 47 1c 85 c0 7e 2a
>     [61163.601845] RIP: follow_huge_pmd+0x143/0x190 RSP: ffffc90004bdbcd0
>     [61163.602376] CR2: ffffea0011943820
>     [61163.602767] ---[ end trace e4f81353a2d23232 ]---
>     [61163.603236] Kernel panic - not syncing: Fatal exception
>     [61163.603706] Kernel Offset: disabled
> 
> This bug is triggered when pmd_present() returns true for non-present
> hugetlb, so fixing the present check in follow_huge_pmd() prevents it.
> Using pmd_present() to determine present/non-present for hugetlb is
> not correct, because pmd_present() checks multiple bits (not only
> _PAGE_PRESENT) for historical reason and it can misjudge hugetlb state.
> 
> Fixes: e66f17ff7177 ("mm/hugetlb: take page table lock in follow_huge_pmd()")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: <stable@vger.kernel.org>        [4.0+]
> ---
>  mm/hugetlb.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git v4.11-rc2-mmotm-2017-03-17-15-26/mm/hugetlb.c v4.11-rc2-mmotm-2017-03-17-15-26_patched/mm/hugetlb.c
> index 3d0aab9..f501f14 100644
> --- v4.11-rc2-mmotm-2017-03-17-15-26/mm/hugetlb.c
> +++ v4.11-rc2-mmotm-2017-03-17-15-26_patched/mm/hugetlb.c
> @@ -4651,6 +4651,7 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  {
>  	struct page *page = NULL;
>  	spinlock_t *ptl;
> +	pte_t pte;
>  retry:
>  	ptl = pmd_lockptr(mm, pmd);
>  	spin_lock(ptl);
> @@ -4660,12 +4661,13 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
>  	 */
>  	if (!pmd_huge(*pmd))
>  		goto out;
> -	if (pmd_present(*pmd)) {
> +	pte = huge_ptep_get((pte_t *)pmd);
> +	if (pte_present(pte)) {
>  		page = pmd_page(*pmd) + ((address & ~PMD_MASK) >> PAGE_SHIFT);
>  		if (flags & FOLL_GET)
>  			get_page(page);
>  	} else {
> -		if (is_hugetlb_entry_migration(huge_ptep_get((pte_t *)pmd))) {
> +		if (is_hugetlb_entry_migration(pte)) {
>  			spin_unlock(ptl);
>  			__migration_entry_wait(mm, (pte_t *)pmd, ptl);
>  			goto retry;
> -- 
> 2.7.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
