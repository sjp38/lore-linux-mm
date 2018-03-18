Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id EFC426B0003
	for <linux-mm@kvack.org>; Sat, 17 Mar 2018 21:22:52 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id n67-v6so7760859otn.0
        for <linux-mm@kvack.org>; Sat, 17 Mar 2018 18:22:52 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id m1si2061200oth.245.2018.03.17.18.22.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 17 Mar 2018 18:22:51 -0700 (PDT)
Subject: [PATCH v2] mm: Warn on lock_page() from reclaim context.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1521295866-9670-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180317155437.pcbeigeivn4a23gt@node.shutemov.name>
In-Reply-To: <20180317155437.pcbeigeivn4a23gt@node.shutemov.name>
Message-Id: <201803181022.IAI30275.JOFOQMtFSHLFOV@I-love.SAKURA.ne.jp>
Date: Sun, 18 Mar 2018 10:22:49 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kirill@shutemov.name, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, mhocko@suse.com

>From f43b8ca61b76f9a19c13f6bf42b27fad9554afc0 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sun, 18 Mar 2018 10:18:01 +0900
Subject: [PATCH v2] mm: Warn on lock_page() from reclaim context.

Kirill A. Shutemov noticed that calling lock_page[_killable]() from
reclaim context might cause deadlock. In order to help finding such
lock_page[_killable]() users (including out of tree users), this patch
emits warning messages when CONFIG_PROVE_LOCKING is enabled.

[   81.532721] ------------[ cut here ]------------
[   81.534253] lock_page() from reclaim context might deadlock
[   81.534264] WARNING: CPU: 3 PID: 56 at mm/filemap.c:3340 __warn_lock_page_from_reclaim_context+0x1e/0x30
[   81.539982] Modules linked in: pcspkr sg vmw_vmci shpchp i2c_piix4 sd_mod ata_generic pata_acpi vmwgfx drm_kms_helper syscopyarea sysfillrect mptspi sysimgblt fb_sys_fops ahci ttm libahci e1000 scsi_transport_spi mptscsih drm ata_piix mptbase i2c_core libata serio_raw ipv6
[   81.546750] CPU: 3 PID: 56 Comm: kswapd0 Kdump: loaded Not tainted 4.16.0-rc5-next-20180316+ #698
[   81.549333] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[   81.552256] RIP: 0010:__warn_lock_page_from_reclaim_context+0x1e/0x30
[   81.554164] RSP: 0018:ffffc9000085bbf8 EFLAGS: 00010282
[   81.555833] RAX: 0000000000000000 RBX: ffffea0004b2b880 RCX: 0000000000000007
[   81.558283] RDX: 0000000000000b6d RSI: ffff88013aa0b700 RDI: ffff88013aa0ae80
[   81.562130] RBP: 0000000000000000 R08: 0000000000000001 R09: 0000000000000000
[   81.564291] R10: 0000000000000040 R11: 0000000000000000 R12: ffff8801357b4958
[   81.566551] R13: 0000000000000000 R14: ffffffff82068220 R15: 0000000000000002
[   81.568956] FS:  0000000000000000(0000) GS:ffff88013bcc0000(0000) knlGS:0000000000000000
[   81.571310] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[   81.573193] CR2: 00000000006020bf CR3: 000000000200f005 CR4: 00000000001606e0
[   81.575453] Call Trace:
[   81.577001]  pagecache_get_page+0x22a/0x230
[   81.578497]  ? iput+0x52/0x2f0
[   81.579762]  shmem_unused_huge_shrink+0x2e9/0x380
[   81.581465]  super_cache_scan+0x17a/0x180
[   81.582999]  shrink_slab+0x218/0x590
[   81.584398]  shrink_node+0x346/0x350
[   81.585777]  kswapd+0x322/0x930
[   81.587090]  kthread+0xf0/0x130
[   81.588370]  ? mem_cgroup_shrink_node+0x320/0x320
[   81.589996]  ? kthread_create_on_node+0x60/0x60
[   81.591670]  ret_from_fork+0x3a/0x50
[   81.593716] Code: f0 41 80 8c 24 08 01 00 00 02 eb b3 90 80 3d b8 54 f8 00 00 74 02 f3 c3 48 c7 c7 b0 87 df 81 c6 05 a6 54 f8 00 01 e8 d2 89 ee ff <0f> 0b c3 0f 1f 44 00 00 66 2e 0f 1f 84 00 00 00 00 00 41 55 41
[   81.599356] ---[ end trace d9238c3d53557ed5 ]---

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
---
 include/linux/pagemap.h | 7 +++++++
 mm/filemap.c            | 8 ++++++++
 2 files changed, 15 insertions(+)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 34ce3ebf..694765e 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -466,6 +466,7 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 extern int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
 				unsigned int flags);
 extern void unlock_page(struct page *page);
+extern void __warn_lock_page_from_reclaim_context(void);
 
 static inline int trylock_page(struct page *page)
 {
@@ -479,6 +480,9 @@ static inline int trylock_page(struct page *page)
 static inline void lock_page(struct page *page)
 {
 	might_sleep();
+	if (IS_ENABLED(CONFIG_PROVE_LOCKING) &&
+	    unlikely(current->flags & PF_MEMALLOC))
+		__warn_lock_page_from_reclaim_context();
 	if (!trylock_page(page))
 		__lock_page(page);
 }
@@ -491,6 +495,9 @@ static inline void lock_page(struct page *page)
 static inline int lock_page_killable(struct page *page)
 {
 	might_sleep();
+	if (IS_ENABLED(CONFIG_PROVE_LOCKING) &&
+	    unlikely(current->flags & PF_MEMALLOC))
+		__warn_lock_page_from_reclaim_context();
 	if (!trylock_page(page))
 		return __lock_page_killable(page);
 	return 0;
diff --git a/mm/filemap.c b/mm/filemap.c
index 693f622..de2eb21 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -3328,3 +3328,11 @@ int try_to_release_page(struct page *page, gfp_t gfp_mask)
 }
 
 EXPORT_SYMBOL(try_to_release_page);
+
+#ifdef CONFIG_PROVE_LOCKING
+void __warn_lock_page_from_reclaim_context(void)
+{
+	WARN_ONCE(1, "lock_page() from reclaim context might deadlock");
+}
+EXPORT_SYMBOL(__warn_lock_page_from_reclaim_context);
+#endif
-- 
1.8.3.1
