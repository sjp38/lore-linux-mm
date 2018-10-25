Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id E8D2C6B0005
	for <linux-mm@kvack.org>; Wed, 24 Oct 2018 21:27:53 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id h16-v6so7515604qto.23
        for <linux-mm@kvack.org>; Wed, 24 Oct 2018 18:27:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e55sor7388987qvd.9.2018.10.24.18.27.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Oct 2018 18:27:52 -0700 (PDT)
From: Rafael David Tinoco <rafael.tinoco@linaro.org>
Subject: [PATCH 1/2] mm/zsmalloc.c: check encoded object value overflow for PAE
Date: Wed, 24 Oct 2018 22:27:44 -0300
Message-Id: <20181025012745.20884-1-rafael.tinoco@linaro.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Rafael David Tinoco <rafael.tinoco@linaro.org>, Russell King <linux@armlinux.org.uk>, Mark Brown <broonie@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>

On 32-bit systems, zsmalloc uses HIGHMEM and, when PAE is enabled, the
physical frame number might be so big that zsmalloc obj encoding (to
location) will break IF architecture does not re-define
MAX_PHYSMEM_BITS, causing:

[  497.097843] ==================================================================
[  497.102365] BUG: KASAN: null-ptr-deref in zs_map_object+0xa4/0x2bc
[  497.105933] Read of size 4 at addr 00000000 by task mkfs.ext4/623
[  497.109684]
[  497.110722] CPU: 2 PID: 623 Comm: mkfs.ext4 Not tainted 4.19.0-rc8-00017-g8239bc6d3307-dirty #15
[  497.116098] Hardware name: Generic DT based system
[  497.119094] [<c0418f7c>] (unwind_backtrace) from [<c0410ca4>] (show_stack+0x20/0x24)
[  497.123819] [<c0410ca4>] (show_stack) from [<c16bd540>] (dump_stack+0xbc/0xe8)
[  497.128299] [<c16bd540>] (dump_stack) from [<c06cab74>] (kasan_report+0x248/0x390)
[  497.132928] [<c06cab74>] (kasan_report) from [<c06c94e8>] (__asan_load4+0x78/0xb4)
[  497.137530] [<c06c94e8>] (__asan_load4) from [<c06ddc24>] (zs_map_object+0xa4/0x2bc)
[  497.142335] [<c06ddc24>] (zs_map_object) from [<bf0bbbd8>] (zram_bvec_rw.constprop.2+0x324/0x8e4 [zram])
[  497.148294] [<bf0bbbd8>] (zram_bvec_rw.constprop.2 [zram]) from [<bf0bc3cc>] (zram_make_request+0x234/0x46c [zram])
[  497.154653] [<bf0bc3cc>] (zram_make_request [zram]) from [<c09aff9c>] (generic_make_request+0x304/0x63c)
[  497.160413] [<c09aff9c>] (generic_make_request) from [<c09b0320>] (submit_bio+0x4c/0x1c8)
[  497.165379] [<c09b0320>] (submit_bio) from [<c0743570>] (submit_bh_wbc.constprop.15+0x238/0x26c)
[  497.170775] [<c0743570>] (submit_bh_wbc.constprop.15) from [<c0746cf8>] (__block_write_full_page+0x524/0x76c)
[  497.176776] [<c0746cf8>] (__block_write_full_page) from [<c07472c4>] (block_write_full_page+0x1bc/0x1d4)
[  497.182549] [<c07472c4>] (block_write_full_page) from [<c0748eb4>] (blkdev_writepage+0x24/0x28)
[  497.187849] [<c0748eb4>] (blkdev_writepage) from [<c064a780>] (__writepage+0x44/0x78)
[  497.192633] [<c064a780>] (__writepage) from [<c064b50c>] (write_cache_pages+0x3b8/0x800)
[  497.197616] [<c064b50c>] (write_cache_pages) from [<c064dd78>] (generic_writepages+0x74/0xa0)
[  497.202807] [<c064dd78>] (generic_writepages) from [<c0748e64>] (blkdev_writepages+0x18/0x1c)
[  497.208022] [<c0748e64>] (blkdev_writepages) from [<c064e890>] (do_writepages+0x68/0x134)
[  497.213002] [<c064e890>] (do_writepages) from [<c06368a4>] (__filemap_fdatawrite_range+0xb0/0xf4)
[  497.218447] [<c06368a4>] (__filemap_fdatawrite_range) from [<c0636b68>] (file_write_and_wait_range+0x64/0xd0)
[  497.224416] [<c0636b68>] (file_write_and_wait_range) from [<c0747af8>] (blkdev_fsync+0x54/0x84)
[  497.229749] [<c0747af8>] (blkdev_fsync) from [<c0739dac>] (vfs_fsync_range+0x70/0xd4)
[  497.234549] [<c0739dac>] (vfs_fsync_range) from [<c0739e98>] (do_fsync+0x4c/0x80)
[  497.239159] [<c0739e98>] (do_fsync) from [<c073a26c>] (sys_fsync+0x1c/0x20)
[  497.243407] [<c073a26c>] (sys_fsync) from [<c0401000>] (ret_fast_syscall+0x0/0x2c)

like in this ARM 32-bit (LPAE enabled), example.

That occurs because, if not set, MAX_POSSIBLE_PHYSMEM_BITS will default
to BITS_PER_LONG (32) in most cases, and, for PAE, _PFN_BITS will be
wrong: which may cause obj variable to overflow if PFN is HIGHMEM and
referencing any page above the 4GB watermark.

This commit exposes the BUG IF the architecture supports PAE AND does
not explicitly set MAX_POSSIBLE_PHYSMEM_BITS to supported value.

Link: https://bugs.linaro.org/show_bug.cgi?id=3765#c17
Signed-off-by: Rafael David Tinoco <rafael.tinoco@linaro.org>
---
 mm/zsmalloc.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 9da65552e7ca..9c3ff8c2ccbc 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -119,6 +119,15 @@
 #define OBJ_INDEX_BITS	(BITS_PER_LONG - _PFN_BITS - OBJ_TAG_BITS)
 #define OBJ_INDEX_MASK	((_AC(1, UL) << OBJ_INDEX_BITS) - 1)
 
+/*
+ * When using PAE, the obj encoding might overflow if arch does
+ * not re-define MAX_PHYSMEM_BITS, since zsmalloc uses HIGHMEM.
+ * This checks for a future bad page access, when de-coding obj.
+ */
+#define OBJ_OVERFLOW(_pfn) \
+	(((unsigned long long) _pfn << (OBJ_INDEX_BITS + OBJ_TAG_BITS)) >= \
+	((_AC(1, ULL)) << MAX_POSSIBLE_PHYSMEM_BITS) ? 1 : 0)
+
 #define FULLNESS_BITS	2
 #define CLASS_BITS	8
 #define ISOLATED_BITS	3
@@ -871,9 +880,14 @@ static void obj_to_location(unsigned long obj, struct page **page,
  */
 static unsigned long location_to_obj(struct page *page, unsigned int obj_idx)
 {
-	unsigned long obj;
+	unsigned long obj, pfn;
+
+	pfn = page_to_pfn(page);
+
+	if (unlikely(OBJ_OVERFLOW(pfn)))
+		BUG();
 
-	obj = page_to_pfn(page) << OBJ_INDEX_BITS;
+	obj = pfn << OBJ_INDEX_BITS;
 	obj |= obj_idx & OBJ_INDEX_MASK;
 	obj <<= OBJ_TAG_BITS;
 
-- 
2.19.1
