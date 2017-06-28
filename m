Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7032F6B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 06:13:01 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s4so53743595pgr.3
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 03:13:01 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id p128si1305236pfb.186.2017.06.28.03.13.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jun 2017 03:13:00 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] thp, mm: Fix crash due race in MADV_FREE handling
Date: Wed, 28 Jun 2017 13:12:49 +0300
Message-Id: <20170628101249.17879-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>

Reinette reported following crash:

  BUG: Bad page state in process log2exe  pfn:57600
  page:ffffea00015d8000 count:0 mapcount:0 mapping:          (null) index:0x20200
  flags: 0x4000000000040019(locked|uptodate|dirty|swapbacked)
  raw: 4000000000040019 0000000000000000 0000000000020200 00000000ffffffff
  raw: ffffea00015d8020 ffffea00015d8020 0000000000000000 0000000000000000
  page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
  bad because of flags: 0x1(locked)
  Modules linked in: rfcomm 8021q bnep intel_rapl x86_pkg_temp_thermal coretemp efivars btusb btrtl btbcm pwm_lpss_pci snd_hda_codec_hdmi btintel pwm_lpss snd_hda_codec_realtek snd_soc_skl snd_hda_codec_generic snd_soc_skl_ipc spi_pxa2xx_platform snd_soc_sst_ipc snd_soc_sst_dsp i2c_designware_platform i2c_designware_core snd_hda_ext_core snd_soc_sst_match snd_hda_intel snd_hda_codec mei_me snd_hda_core mei snd_soc_rt286 snd_soc_rl6347a snd_soc_core efivarfs
  CPU: 1 PID: 354 Comm: log2exe Not tainted 4.12.0-rc7-test-test #19
  Hardware name: Intel corporation NUC6CAYS/NUC6CAYB, BIOS AYAPLCEL.86A.0027.2016.1108.1529 11/08/2016
  Call Trace:
   dump_stack+0x95/0xeb
   bad_page+0x16a/0x1f0
   free_pages_check_bad+0x117/0x190
   ? rcu_read_lock_sched_held+0xa8/0x130
   free_hot_cold_page+0x7b1/0xad0
   __put_page+0x70/0xa0
   madvise_free_huge_pmd+0x627/0x7b0
   madvise_free_pte_range+0x6f8/0x1150
   ? debug_check_no_locks_freed+0x280/0x280
   ? swapin_walk_pmd_entry+0x380/0x380
   __walk_page_range+0x6b5/0xe30
   walk_page_range+0x13b/0x310
   madvise_free_page_range.isra.16+0xad/0xd0
   ? force_swapin_readahead+0x110/0x110
   ? swapin_walk_pmd_entry+0x380/0x380
   ? lru_add_drain_cpu+0x160/0x320
   madvise_free_single_vma+0x2e4/0x470
   ? madvise_free_page_range.isra.16+0xd0/0xd0
   ? vmacache_update+0x100/0x130
   ? find_vma+0x35/0x160
   SyS_madvise+0x8ce/0x1450

If somebody frees the page under us and we hold the last reference to
it, put_page() would attempt to free the page before unlocking it.

The fix is trivial reorder of operations.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Reinette Chatre <reinette.chatre@intel.com>
Fixes: 9818b8cde622 ("madvise_free, thp: fix madvise_free_huge_pmd return value after splitting")
Cc: Huang Ying <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 mm/huge_memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 8624450f7106..25b5965c1130 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1575,8 +1575,8 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
 		get_page(page);
 		spin_unlock(ptl);
 		split_huge_page(page);
-		put_page(page);
 		unlock_page(page);
+		put_page(page);
 		goto out_unlocked;
 	}
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
