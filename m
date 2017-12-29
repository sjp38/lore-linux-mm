Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 163A26B0033
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 04:52:50 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id 80so11574971wmb.7
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 01:52:50 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d48sor13163620wrd.33.2017.12.29.01.52.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Dec 2017 01:52:48 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH v2] ksm: replace jhash2 with faster hash
Date: Fri, 29 Dec 2017 12:52:41 +0300
Message-Id: <20171229095241.23345-1-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, Timofey Titovets <nefelim4ag@gmail.com>, leesioh <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>

Pickup, Sioh Lee crc32 patch, after some long conversation
and hassles, merge with my work on xxhash, add
choice fastest hash helper.

Base idea are same, replace jhash2 with something faster.

Perf numbers:
Intel(R) Xeon(R) CPU E5-2420 v2 @ 2.20GHz
ksm: crc32c   hash() 12081 MB/s
ksm: jhash2   hash()  1569 MB/s
ksm: xxh64    hash()  8770 MB/s
ksm: xxh32    hash()  4529 MB/s

As jhash2 always will be slower, just drop it from choice.

Add function to autoselect hash algo on boot, based on speed,
like raid6 code does.

Move init of zero_hash from init, to start of ksm thread,
as ksm init run on early kernel init, run perf testing stuff on
main kernel thread looks bad to me.

One problem exists with that patch,
ksm init run too early, and crc32c module, even compiled in
can't be found, so i see:
 - ksm: alloc crc32c shash error 2 in dmesg.

I give up on that, so ideas welcomed.

Only idea that i have, are to avoid early init by moving
zero_checksum to sysfs_store parm,
i.e. that's default to false, and that will work, i think.

Thanks.

Changes:
  v1 -> v2:
    - Merge xxhash/crc32 patches
    - Replace crc32 with crc32c (crc32 have same as jhash2 speed)
    - Add auto speed test and auto choice of fastest hash function
    
Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
Signed-off-by: leesioh <solee@os.korea.ac.kr>
CC: Andrea Arcangeli <aarcange@redhat.com>
CC: linux-mm@kvack.org
CC: kvm@vger.kernel.org
---
 mm/Kconfig |   4 ++
 mm/ksm.c   | 133 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 128 insertions(+), 9 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 03ff7703d322..d4fb147d4a22 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -305,6 +305,10 @@ config MMU_NOTIFIER
 config KSM
 	bool "Enable KSM for page merging"
 	depends on MMU
+	select XXHASH
+	select CRYPTO
+	select CRYPTO_HASH
+	select CONFIG_CRYPTO_CRC32C
 	help
 	  Enable Kernel Samepage Merging: KSM periodically scans those areas
 	  of an application's address space that an app has advised may be
diff --git a/mm/ksm.c b/mm/ksm.c
index be8f4576f842..fd5c9d0f7bc2 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -25,7 +25,6 @@
 #include <linux/pagemap.h>
 #include <linux/rmap.h>
 #include <linux/spinlock.h>
-#include <linux/jhash.h>
 #include <linux/delay.h>
 #include <linux/kthread.h>
 #include <linux/wait.h>
@@ -41,6 +40,12 @@
 #include <linux/numa.h>
 
 #include <asm/tlbflush.h>
+
+/* Support for xxhash and crc32c */
+#include <linux/crypto.h>
+#include <crypto/hash.h>
+#include <linux/xxhash.h>
+
 #include "internal.h"
 
 #ifdef CONFIG_NUMA
@@ -186,7 +191,7 @@ struct rmap_item {
 	};
 	struct mm_struct *mm;
 	unsigned long address;		/* + low bits used for flags below */
-	unsigned int oldchecksum;	/* when unstable */
+	unsigned long oldchecksum;	/* when unstable */
 	union {
 		struct rb_node node;	/* when node of unstable tree */
 		struct {		/* when listed from stable tree */
@@ -255,7 +260,7 @@ static unsigned int ksm_thread_pages_to_scan = 100;
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
 /* Checksum of an empty (zeroed) page */
-static unsigned int zero_checksum __read_mostly;
+static unsigned long zero_checksum __read_mostly;
 
 /* Whether to merge empty (zeroed) pages with actual zero pages */
 static bool ksm_use_zero_pages __read_mostly;
@@ -284,6 +289,115 @@ static DEFINE_SPINLOCK(ksm_mmlist_lock);
 		sizeof(struct __struct), __alignof__(struct __struct),\
 		(__flags), NULL)
 
+#define CRC32C_HASH 1
+#define XXH32_HASH  2
+#define XXH64_HASH  3
+
+const static char *hash_func_names[] = { "", "crc32c", "xxh32", "xxh64" };
+
+static struct shash_desc desc;
+static struct crypto_shash *tfm;
+static uint8_t fastest_hash = 0;
+
+static void __init choice_fastest_hash(void)
+{
+	void *page = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	unsigned long checksum, perf, js, je;
+	unsigned long best_perf = 0;
+
+	tfm = crypto_alloc_shash(hash_func_names[CRC32C_HASH],
+				 CRYPTO_ALG_TYPE_SHASH, 0);
+
+	if (IS_ERR(tfm)) {
+		pr_warn("ksm: alloc %s shash error %ld\n",
+			hash_func_names[CRC32C_HASH], -PTR_ERR(tfm));
+	} else {
+		desc.tfm = tfm;
+		desc.flags = 0;
+
+		perf = 0;
+		preempt_disable();
+		js = jiffies;
+		je = js + (HZ >> 3);
+		while (time_before(jiffies, je)) {
+			crypto_shash_digest(&desc, page, PAGE_SIZE,
+					    (u8 *)&checksum);
+			perf++;
+		}
+		preempt_enable();
+		if (best_perf < perf) {
+			best_perf = perf;
+			fastest_hash = CRC32C_HASH;
+		}
+		pr_info("ksm: %-8s hash() %5ld MB/s\n",
+			hash_func_names[CRC32C_HASH], perf*PAGE_SIZE >> 17);
+	}
+
+	perf = 0;
+	preempt_disable();
+	js = jiffies;
+	je = js + (HZ >> 3);
+	while (time_before(jiffies, je)) {
+		checksum = xxh32(page, PAGE_SIZE, 0);
+		perf++;
+	}
+	preempt_enable();
+	if (best_perf < perf) {
+		best_perf = perf;
+		fastest_hash = XXH32_HASH;
+	}
+	pr_info("ksm: %-8s hash() %5ld MB/s\n",
+		hash_func_names[XXH32_HASH], perf*PAGE_SIZE >> 17);
+
+	perf = 0;
+	preempt_disable();
+	js = jiffies;
+	je = js + (HZ >> 3);
+	while (time_before(jiffies, je)) {
+		checksum = xxh64(page, PAGE_SIZE, 0);
+		perf++;
+	}
+	preempt_enable();
+	if (best_perf < perf) {
+		best_perf = perf;
+		fastest_hash = XXH64_HASH;
+	}
+	pr_info("ksm: %-8s hash() %5ld MB/s\n",
+		hash_func_names[XXH64_HASH], perf*PAGE_SIZE >> 17);
+
+	if (!IS_ERR(tfm) && fastest_hash != CRC32C_HASH)
+		crypto_free_shash(tfm);
+
+	pr_info("ksm: choise %s as hash function\n",
+		hash_func_names[fastest_hash]);
+
+	kfree(page);
+}
+
+unsigned long fasthash(const void *input, size_t length)
+{
+	unsigned long checksum = 0;
+
+	switch (fastest_hash) {
+	case 0:
+		choice_fastest_hash();
+		checksum = fasthash(input, length);
+		break;
+	case CRC32C_HASH:
+		crypto_shash_digest(&desc, input, length,
+			    (u8 *)&checksum);
+		break;
+	case XXH32_HASH:
+		checksum = xxh32(input, length, 0);
+		break;
+	case XXH64_HASH:
+		checksum = xxh64(input, length, 0);
+		break;
+	}
+
+	return checksum;
+}
+
 static int __init ksm_slab_init(void)
 {
 	rmap_item_cache = KSM_KMEM_CACHE(rmap_item, 0);
@@ -982,11 +1096,11 @@ static int unmerge_and_remove_all_rmap_items(void)
 }
 #endif /* CONFIG_SYSFS */
 
-static u32 calc_checksum(struct page *page)
+static unsigned long calc_checksum(struct page *page)
 {
-	u32 checksum;
+	unsigned long checksum;
 	void *addr = kmap_atomic(page);
-	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
+	checksum = fasthash(addr, PAGE_SIZE);
 	kunmap_atomic(addr);
 	return checksum;
 }
@@ -2006,7 +2120,7 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	struct page *tree_page = NULL;
 	struct stable_node *stable_node;
 	struct page *kpage;
-	unsigned int checksum;
+	unsigned long checksum;
 	int err;
 	bool max_page_sharing_bypass = false;
 
@@ -2336,6 +2450,9 @@ static int ksm_scan_thread(void *nothing)
 	set_freezable();
 	set_user_nice(current, 5);
 
+	/* The correct value depends on page size and endianness */
+	zero_checksum = calc_checksum(ZERO_PAGE(0));
+
 	while (!kthread_should_stop()) {
 		mutex_lock(&ksm_thread_mutex);
 		wait_while_offlining();
@@ -3068,8 +3185,6 @@ static int __init ksm_init(void)
 	struct task_struct *ksm_thread;
 	int err;
 
-	/* The correct value depends on page size and endianness */
-	zero_checksum = calc_checksum(ZERO_PAGE(0));
 	/* Default to false for backwards compatibility */
 	ksm_use_zero_pages = false;
 
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
