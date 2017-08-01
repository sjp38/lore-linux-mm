Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6496B052B
	for <linux-mm@kvack.org>; Tue,  1 Aug 2017 08:09:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t187so14889256pfb.0
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:09:50 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id y19si5746337pge.61.2017.08.01.05.09.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Aug 2017 05:09:48 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id y129so2410584pgy.3
        for <linux-mm@kvack.org>; Tue, 01 Aug 2017 05:09:48 -0700 (PDT)
From: leesioh <solee@os.korea.ac.kr>
Subject: [PATCH] mm/ksm : Checksum calculation function change (jhash2 -> crc32)
Date: Tue,  1 Aug 2017 21:07:35 +0900
Message-Id: <1501589255-9389-1-git-send-email-solee@os.korea.ac.kr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, aarcange@redhat.com, mingo@kernel.org, zhongjiang@huawei.com, minchan@kernel.org, arvind.yadav.cs@gmail.com, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, leesioh <solee@os.korea.ac.kr>

In ksm, the checksum values are used to check changes in page content and keep the unstable tree more stable.
KSM implements checksum calculation with jhash2 hash function.
However, because jhash2 is implemented in software,
it consumes high CPU cycles (about 26%, according to KSM thread profiling results)

To reduce CPU consumption, this commit applies the crc32 hash function
which is included in the SSE4.2 CPU instruction set.
This can significantly reduce the page checksum overhead as follows.

I measured checksum computation 300 times to see how fast crc32 is compared to jhash2.
With jhash2, the average checksum calculation time is about 3460ns,
and with crc32, the average checksum calculation time is 888ns. This is about 74% less than jhash2.

Signed-off-by: leesioh <solee@os.korea.ac.kr>
---
 mm/ksm.c | 36 ++++++++++++++++++++++++++++++++----
 1 file changed, 32 insertions(+), 4 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 0c927e3..390a3cb 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -42,7 +42,8 @@
 
 #include <asm/tlbflush.h>
 #include "internal.h"
-
+#include <linux/crypto.h>
+#include <crypto/hash.h>
 #ifdef CONFIG_NUMA
 #define NUMA(x)		(x)
 #define DO_NUMA(x)	do { (x); } while (0)
@@ -260,6 +261,9 @@ static unsigned int zero_checksum __read_mostly;
 /* Whether to merge empty (zeroed) pages with actual zero pages */
 static bool ksm_use_zero_pages __read_mostly;
 
+/* Whether to support crc32 hash function */
+static bool crc32_support;
+
 #ifdef CONFIG_NUMA
 /* Zeroed when merging across nodes is not allowed */
 static unsigned int ksm_merge_across_nodes = 1;
@@ -279,11 +283,27 @@ static void wait_while_offlining(void);
 static DECLARE_WAIT_QUEUE_HEAD(ksm_thread_wait);
 static DEFINE_MUTEX(ksm_thread_mutex);
 static DEFINE_SPINLOCK(ksm_mmlist_lock);
-
+static struct shash_desc desc;
+static struct crypto_shash *tfm;
 #define KSM_KMEM_CACHE(__struct, __flags) kmem_cache_create("ksm_"#__struct,\
 		sizeof(struct __struct), __alignof__(struct __struct),\
 		(__flags), NULL)
 
+static void __init ksm_crc32_init(void)
+{
+	tfm = crypto_alloc_shash("crc32", 0, CRYPTO_ALG_ASYNC);
+
+	if (IS_ERR(tfm) || tfm->base.__crt_alg->cra_priority < 200) {
+		pr_warn("not support crc32 instruction, use jhash2 \n");
+		crc32_support = false;
+		crypto_free_shash(tfm);
+		return;
+	}
+	desc.tfm = tfm;
+	desc.flags = 0;
+	crc32_support = true;
+}
+
 static int __init ksm_slab_init(void)
 {
 	rmap_item_cache = KSM_KMEM_CACHE(rmap_item, 0);
@@ -986,7 +1006,14 @@ static u32 calc_checksum(struct page *page)
 {
 	u32 checksum;
 	void *addr = kmap_atomic(page);
-	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
+	/*
+	* If crc32 is supported, the use crc32 to calculate the checksum
+	* otherwise use jhash2
+	*/
+	if (crc32_support)
+		crypto_shash_digest(&desc, addr, PAGE_SIZE, (u8 *)&checksum);
+	else
+		checksum = jhash2(addr, PAGE_SIZE / 4, 17);
 	kunmap_atomic(addr);
 	return checksum;
 }
@@ -3057,7 +3084,8 @@ static int __init ksm_init(void)
 	zero_checksum = calc_checksum(ZERO_PAGE(0));
 	/* Default to false for backwards compatibility */
 	ksm_use_zero_pages = false;
-
+
+	ksm_crc32_init();
 	err = ksm_slab_init();
 	if (err)
 		goto out;
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
