Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 61EC46B0255
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 00:33:50 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so99691259pab.0
        for <linux-mm@kvack.org>; Sun, 16 Aug 2015 21:33:50 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id az6si22594100pac.161.2015.08.16.21.33.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 16 Aug 2015 21:33:49 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v2 2/3] mm/hwpoison: fix race between soft_offline_page and
 unpoison_memory
Date: Mon, 17 Aug 2015 04:32:11 +0000
Message-ID: <1439785924-27885-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <BLU436-SMTP2235CDFEDA4DEB534BF8C85807C0@phx.gbl>
 <1439785924-27885-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1439785924-27885-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <wanpeng.li@hotmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

From: Wanpeng Li <wanpeng.li@hotmail.com>

Wanpeng Li reported a race between soft_offline_page() and unpoison_memory(=
),
which causes the following kernel panic:

  [   61.572584] BUG: Bad page state in process bash  pfn:97000
  [   61.578106] page:ffffea00025c0000 count:0 mapcount:1 mapping:         =
 (null) index:0x7f4fdbe00
  [   61.586803] flags: 0x1fffff80080048(uptodate|active|swapbacked)
  [   61.592809] page dumped because: PAGE_FLAGS_CHECK_AT_FREE flag(s) set
  [   61.599250] bad because of flags:
  [   61.602567] flags: 0x40(active)
  [   61.605746] Modules linked in: snd_hda_codec_hdmi i915 rpcsec_gss_krb5=
 nfsv4 dns_resolver bnep rfcomm nfsd bluetooth auth_rpcgss nfs_acl nfs rfki=
ll lockd grace sunrpc i2c_algo_bit drm_kms_helper snd_hda_codec_realtek snd=
_hda_codec_generic drm snd_hda_intel fscache snd_hda_codec x86_pkg_temp_the=
rmal coretemp kvm_intel snd_hda_core snd_hwdep kvm snd_pcm snd_seq_dummy sn=
d_seq_oss crct10dif_pclmul snd_seq_midi crc32_pclmul snd_seq_midi_event gha=
sh_clmulni_intel snd_rawmidi aesni_intel lrw gf128mul snd_seq glue_helper a=
blk_helper snd_seq_device cryptd fuse snd_timer dcdbas serio_raw mei_me par=
port_pc snd mei ppdev i2c_core video lp soundcore parport lpc_ich shpchp mf=
d_core ext4 mbcache jbd2 sd_mod e1000e ahci ptp libahci crc32c_intel libata=
 pps_core
  [   61.605827] CPU: 3 PID: 2211 Comm: bash Not tainted 4.2.0-rc5-mm1+ #45
  [   61.605829] Hardware name: Dell Inc. OptiPlex 7020/0F5C5X, BIOS A03 01=
/08/2015
  [   61.605832]  ffffffff818b3be8 ffff8800da373ad8 ffffffff8165ceb4 000000=
0001313ce1
  [   61.605837]  ffffea00025c0000 ffff8800da373b08 ffffffff8117bdd6 ffff88=
021edd4b00
  [   61.605842]  0000000000000001 001fffff80080048 0000000000000000 ffff88=
00da373b88
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

This race is explained like below:

  CPU0                    CPU1

  soft_offline_page
  __soft_offline_page
  TestSetPageHWPoison
                        unpoison_memory
                        PageHWPoison check (true)
                        TestClearPageHWPoison
                        put_page    -> release refcount held by get_hwpoiso=
n_page in unpoison_memory
                        put_page    -> release refcount held by isolate_lru=
_page in __soft_offline_page
  migrate_pages

The second put_page() releases refcount held by isolate_lru_page() which
will lead to unmap_and_move() releases the last refcount of page and w/
mapcount still 1 since try_to_unmap() is not called if there is only
one user map the page. Anyway, the page refcount and mapcount will
still mess if the page is mapped by multiple users.

This race was introduced by commit 4491f71260 ("mm/memory-failure: set
PageHWPoison before migrate_pages()"), which focuses on preventing the reus=
e
of successfully migrated page. Before this commit we prevent the reuse by
changing the migratetype to MIGRATE_ISOLATE during soft offlining, which ha=
s
the following problems, so simply reverting the commit is not a best option=
:
  1) it doesn't eliminate the reuse completely, because set_migratetype_iso=
late()
     can fail to set MIGRATE_ISOLATE to the target page if the pageblock of
     the page contains one or more unmovable pages (i.e. has_unmovable_page=
s()
     returns true).
  2) the original code changes migratetype to MIGRATE_ISOLATE forcibly,
     and sets it to MIGRATE_MOVABLE forcibly after soft offline, regardless
     of the original migratetype state, which could impact other subsystems
     like memory hotplug or compaction.

This patch moves PageSetHWPoison just after put_page() in unmap_and_move(),
which closes up the reported race window and minimizes another race window =
b/w
SetPageHWPoison and reallocation (which causes the reuse of soft-offlined p=
age.)
The latter race window still exists but it's acceptable, because it's rare =
and
effectively the same as ordinary "containment failure" case even if it happ=
ens,
so keep the window open is acceptable.

Fixes: 4491f71260 ("mm/memory-failure: set PageHWPoison before migrate_page=
s()")
Reported-by: Wanpeng Li <wanpeng.li@hotmail.com>
Signed-off-by: Wanpeng Li <wanpeng.li@hotmail.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/swapops.h | 14 ++++++++++++++
 mm/memory-failure.c     |  4 ----
 mm/migrate.c            |  9 +++++----
 3 files changed, 19 insertions(+), 8 deletions(-)

diff --git mmotm-2015-08-13-15-29.orig/include/linux/swapops.h mmotm-2015-0=
8-13-15-29/include/linux/swapops.h
index ec04669f2a3b..5c3a5f3e7eec 100644
--- mmotm-2015-08-13-15-29.orig/include/linux/swapops.h
+++ mmotm-2015-08-13-15-29/include/linux/swapops.h
@@ -181,6 +181,11 @@ static inline int is_hwpoison_entry(swp_entry_t entry)
 	return swp_type(entry) =3D=3D SWP_HWPOISON;
 }
=20
+static inline bool test_set_page_hwpoison(struct page *page)
+{
+	return TestSetPageHWPoison(page);
+}
+
 static inline void num_poisoned_pages_inc(void)
 {
 	atomic_long_inc(&num_poisoned_pages);
@@ -211,6 +216,15 @@ static inline int is_hwpoison_entry(swp_entry_t swp)
 {
 	return 0;
 }
+
+static inline bool test_set_page_hwpoison(struct page *page)
+{
+	return false;
+}
+
+static inline void num_poisoned_pages_inc(void)
+{
+}
 #endif
=20
 #if defined(CONFIG_MEMORY_FAILURE) || defined(CONFIG_MIGRATION)
diff --git mmotm-2015-08-13-15-29.orig/mm/memory-failure.c mmotm-2015-08-13=
-15-29/mm/memory-failure.c
index ac3056c6fe9f..7986db56e240 100644
--- mmotm-2015-08-13-15-29.orig/mm/memory-failure.c
+++ mmotm-2015-08-13-15-29/mm/memory-failure.c
@@ -1669,8 +1669,6 @@ static int __soft_offline_page(struct page *page, int=
 flags)
 		inc_zone_page_state(page, NR_ISOLATED_ANON +
 					page_is_file_cache(page));
 		list_add(&page->lru, &pagelist);
-		if (!TestSetPageHWPoison(page))
-			num_poisoned_pages_dec();
 		ret =3D migrate_pages(&pagelist, new_page, NULL, MPOL_MF_MOVE_ALL,
 					MIGRATE_SYNC, MR_MEMORY_FAILURE);
 		if (ret) {
@@ -1685,8 +1683,6 @@ static int __soft_offline_page(struct page *page, int=
 flags)
 				pfn, ret, page->flags);
 			if (ret > 0)
 				ret =3D -EIO;
-			if (TestClearPageHWPoison(page))
-				num_poisoned_pages_dec();
 		}
 	} else {
 		pr_info("soft offline: %#lx: isolation failed: %d, page count %d, type %=
lx\n",
diff --git mmotm-2015-08-13-15-29.orig/mm/migrate.c mmotm-2015-08-13-15-29/=
mm/migrate.c
index d3bae49f89cc..fbf17988ab5f 100644
--- mmotm-2015-08-13-15-29.orig/mm/migrate.c
+++ mmotm-2015-08-13-15-29/mm/migrate.c
@@ -886,8 +886,7 @@ static int __unmap_and_move(struct page *page, struct p=
age *newpage,
 	/* Establish migration ptes or remove ptes */
 	if (page_mapped(page)) {
 		try_to_unmap(page,
-			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS|
-			TTU_IGNORE_HWPOISON);
+			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 		page_was_mapped =3D 1;
 	}
=20
@@ -958,9 +957,11 @@ static ICE_noinline int unmap_and_move(new_page_t get_=
new_page,
 		dec_zone_page_state(page, NR_ISOLATED_ANON +
 				page_is_file_cache(page));
 		/* Soft-offlined page shouldn't go through lru cache list */
-		if (reason =3D=3D MR_MEMORY_FAILURE)
+		if (reason =3D=3D MR_MEMORY_FAILURE) {
 			put_page(page);
-		else
+			if (!test_set_page_hwpoison(page))
+				num_poisoned_pages_inc();
+		} else
 			putback_lru_page(page);
 	}
=20
--=20
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
