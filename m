From: Wanpeng Li <wanpeng.li@hotmail.com>
Subject: [PATCH] mm/hwpoison: fix race between soft_offline_page and unpoison_memory
Date: Thu, 13 Aug 2015 15:09:07 +0800
Message-ID: <BLU436-SMTP256072767311DFB0FD3AE1B807D0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <wanpeng.li@hotmail.com>
List-Id: linux-mm.kvack.org

[   61.572584] BUG: Bad page state in process bash  pfn:97000
[   61.578106] page:ffffea00025c0000 count:0 mapcount:1 mapping:          (null) index:0x7f4fdbe00
[   61.586803] flags: 0x1fffff80080048(uptodate|active|swapbacked)
[   61.592809] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
[   61.599250] bad because of flags:
[   61.602567] flags: 0x40(active)
[   61.605746] Modules linked in: snd_hda_codec_hdmi i915 rpcsec_gss_krb5 nfsv4 dns_resolver bnep rfcomm nfsd bluetooth auth_rpcgss nfs_acl nfs rfkill lockd grace sunrpc i2c_algo_bit drm_kms_helper snd_hda_codec_realtek snd_hda_codec_generic drm snd_hda_intel fscache snd_hda_codec x86_pkg_temp_thermal coretemp kvm_intel snd_hda_core snd_hwdep kvm snd_pcm snd_seq_dummy snd_seq_oss crct10dif_pclmul snd_seq_midi crc32_pclmul snd_seq_midi_event ghash_clmulni_intel snd_rawmidi aesni_intel lrw gf128mul snd_seq glue_helper ablk_helper snd_seq_device cryptd fuse snd_timer dcdbas serio_raw mei_me parport_pc snd mei ppdev i2c_core video lp soundcore parport lpc_ich shpchp mfd_core ext4 mbcache jbd2 sd_mod e1000e ahci ptp libahci crc32c_intel libata pps_core
[   61.605827] CPU: 3 PID: 2211 Comm: bash Not tainted 4.2.0-rc5-mm1+ #45
[   61.605829] Hardware name: Dell Inc. OptiPlex 7020/0F5C5X, BIOS A03 01/08/2015
[   61.605832]  ffffffff818b3be8 ffff8800da373ad8 ffffffff8165ceb4 0000000001313ce1
[   61.605837]  ffffea00025c0000 ffff8800da373b08 ffffffff8117bdd6 ffff88021edd4b00
[   61.605842]  0000000000000001 001fffff80080048 0000000000000000 ffff8800da373b88
[   61.605847] Call Trace:
[   61.605858]  [<ffffffff8165ceb4>] dump_stack+0x48/0x5c
[   61.605865]  [<ffffffff8117bdd6>] bad_page+0xe6/0x140
[   61.605870]  [<ffffffff8117dfc9>] free_pages_prepare+0x2f9/0x320
[   61.605876]  [<ffffffff811e817d>] ? uncharge_list+0xdd/0x100
[   61.605882]  [<ffffffff8117ff20>] free_hot_cold_page+0x40/0x170
[   61.605888]  [<ffffffff81185dd0>] __put_single_page+0x20/0x30
[   61.605892]  [<ffffffff81186675>] put_page+0x25/0x40
[   61.605897]  [<ffffffff811dc276>] unmap_and_move+0x1a6/0x1f0
[   61.605908]  [<ffffffff811dc3c0>] migrate_pages+0x100/0x1d0
[   61.605914]  [<ffffffff811eb710>] ? kill_procs+0x100/0x100
[   61.605918]  [<ffffffff811764af>] ? unlock_page+0x6f/0x90
[   61.605923]  [<ffffffff811ecf37>] __soft_offline_page+0x127/0x2a0
[   61.605928]  [<ffffffff811ed156>] soft_offline_page+0xa6/0x200

There is a race window between soft_offline_page() and unpoison_memory():

		CPU0 					CPU1

soft_offline_page
__soft_offline_page
TestSetPageHWPoison   
					unpoison_memory
					PageHWPoison check (true)
					TestClearPageHWPoison
					put_page    -> release refcount held by get_hwpoison_page in unpoison_memory
					put_page    -> release refcount held by isolate_lru_page in __soft_offline_page
migrate_pages

The second put_page() releases refcount held by isolate_lru_page() which 
will lead to unmap_and_move() releases the last refcount of page and w/ 
mapcount still 1 since try_to_unmap() is not called if there is only 
one user map the page. Anyway, the page refcount and mapcount will 
still mess if the page is mapped by multiple users. Commit (4491f712606: 
mm/memory-failure: set PageHWPoison before migrate_pages()) is introduced 
to avoid to reuse just successful migrated page, however, it also incurs 
this race window.

Fix it by continue to use migratetype to guarantee the source page which 
is successful migration does not reused before PG_hwpoison is set.

Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
---
 include/linux/page-isolation.h |    5 +++++
 mm/memory-failure.c            |   16 ++++++++++++----
 mm/migrate.c                   |    3 +--
 mm/page_isolation.c            |    4 ++--
 4 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/include/linux/page-isolation.h b/include/linux/page-isolation.h
index 047d647..ff5751e 100644
--- a/include/linux/page-isolation.h
+++ b/include/linux/page-isolation.h
@@ -65,6 +65,11 @@ undo_isolate_page_range(unsigned long start_pfn, unsigned long end_pfn,
 int test_pages_isolated(unsigned long start_pfn, unsigned long end_pfn,
 			bool skip_hwpoisoned_pages);
 
+/*
+ *  Internal functions. Changes pageblock's migrate type.
+ */
+int set_migratetype_isolate(struct page *page, bool skip_hwpoisoned_pages);
+void unset_migratetype_isolate(struct page *page, unsigned migratetype);
 struct page *alloc_migrate_target(struct page *page, unsigned long private,
 				int **resultp);
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index eca613e..0ed3814 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -1647,8 +1647,6 @@ static int __soft_offline_page(struct page *page, int flags)
 		inc_zone_page_state(page, NR_ISOLATED_ANON +
 					page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
-		if (!TestSetPageHWPoison(page))
-			atomic_long_inc(&num_poisoned_pages);
 		ret = migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
 		if (ret) {
@@ -1663,8 +1661,9 @@ static int __soft_offline_page(struct page *page, int flags)
 				pfn, ret, page->flags);
 			if (ret > 0)
 				ret = -EIO;
-			if (TestClearPageHWPoison(page))
-				atomic_long_dec(&num_poisoned_pages);
+		} else {
+			if (!TestSetPageHWPoison(page))
+				atomic_long_inc(&num_poisoned_pages);
 		}
 	} else {
 		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %lx\n",
@@ -1715,6 +1714,14 @@ int soft_offline_page(struct page *page, int flags)
 
 	get_online_mems();
 
+	/*
+	 * Isolate the page, so that it doesn't get reallocated if it
+	 * was free. This flag should be kept set until the source page
+	 * is freed and PG_hwpoison on it is set.
+	 */
+	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
+		set_migratetype_isolate(page, false);
+
 	ret = get_any_page(page, pfn, flags);
 	put_online_mems();
 	if (ret > 0) { /* for in-use pages */
@@ -1733,5 +1740,6 @@ int soft_offline_page(struct page *page, int flags)
 				atomic_long_inc(&num_poisoned_pages);
 		}
 	}
+	unset_migratetype_isolate(page, MIGRATE_MOVABLE);
 	return ret;
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index 1f8369d..472baf5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -880,8 +880,7 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
 	/* Establish migration ptes or remove ptes */
 	if (page_mapped(page)) {
 		try_to_unmap(page,
-			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS|
-			TTU_IGNORE_HWPOISON);
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 		page_was_mapped = 1;
 	}
 
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 4568fd5..654662a 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -9,7 +9,7 @@
 #include <linux/hugetlb.h>
 #include "internal.h"
 
-static int set_migratetype_isolate(struct page *page,
+int set_migratetype_isolate(struct page *page,
 				bool skip_hwpoisoned_pages)
 {
 	struct zone *zone;
@@ -73,7 +73,7 @@ out:
 	return ret;
 }
 
-static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
+void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 {
 	struct zone *zone;
 	unsigned long flags, nr_pages;
-- 
1.7.1
