Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CFC586B0069
	for <linux-mm@kvack.org>; Sat, 30 Dec 2017 18:26:57 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id n21so19633793wrb.11
        for <linux-mm@kvack.org>; Sat, 30 Dec 2017 15:26:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h18sor7550306wre.84.2017.12.30.15.26.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 30 Dec 2017 15:26:56 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH V5 2/2] ksm: replace jhash2 with faster hash
Date: Sun, 31 Dec 2017 02:26:43 +0300
Message-Id: <20171230232643.12315-2-nefelim4ag@gmail.com>
In-Reply-To: <20171230232643.12315-1-nefelim4ag@gmail.com>
References: <20171230232643.12315-1-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, Timofey Titovets <nefelim4ag@gmail.com>, leesioh <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>

1. Pickup, Sioh Lee crc32 patch, after some long conversation
2. Merge with my work on xxhash
3. Add autoselect code to choice fastest hash helper.

Base idea are same, replace jhash2 with something faster.

Perf numbers:
Intel(R) Xeon(R) CPU E5-2420 v2 @ 2.20GHz
ksm: crc32c   hash() 12081 MB/s
ksm: xxh64    hash()  8770 MB/s
ksm: xxh32    hash()  4529 MB/s
ksm: jhash2   hash()  1569 MB/s

As jhash2 always will be slower (For data size like PAGE_SIZE),
just drop it from choice.

Add function to autoselect hash algo on boot,
based on hashing speed, like raid6 code does.

Move init of zero_checksum from init, to first call of fasthash():
  1. KSM Init run on early kernel init,
     run perf testing stuff on main kernel boot thread looks bad to me.
  2. Crypto subsystem not avaliable at that early booting,
     so crc32c even, compiled in, not avaliable

Output after first try of KSM to hash page:
ksm: crc32c hash() 15218 MB/s
ksm: xxhash hash()  8640 MB/s
ksm: choise crc32c as hash function

Thanks.

Changes:
  v1 -> v2:
    - Move xxhash() to xxhash.h/c and separate patches
  v2 -> v3:
    - Move xxhash() xxhash.c -> xxhash.h
    - replace xxhash_t with 'unsigned long'
    - update kerneldoc above xxhash()
  v3 -> v4:
    - Merge xxhash/crc32 patches
    - Replace crc32 with crc32c (crc32 have same as jhash2 speed)
    - Add auto speed test and auto choice of fastest hash function
  v4 -> v5:
    - Pickup missed xxhash patch
    - Update code with compile time choicen xxhash
    - Add more macros to make code more readable
    - As now that only possible use xxhash or crc32c,
      on crc32c allocation error, skip speed test and fallback to xxhash
    - For workaround too early init problem (crc32c not avaliable),
      move zero_checksum init to first call of fastcall()
    - Don't alloc page for hash testing, use arch zero pages for that

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
Signed-off-by: leesioh <solee@os.korea.ac.kr>
CC: Andrea Arcangeli <aarcange@redhat.com>
CC: linux-mm@kvack.org
CC: kvm@vger.kernel.org
---
 mm/Kconfig |   4 +++
 mm/ksm.c   | 114 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 109 insertions(+), 9 deletions(-)

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
index be8f4576f842..b90ad6903dc6 100644
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
@@ -41,6 +40,13 @@
 #include <linux/numa.h>
 
 #include <asm/tlbflush.h>
+
+/* Support for xxhash and crc32c */
+#include <linux/crypto.h>
+#include <crypto/hash.h>
+#include <linux/xxhash.h>
+#include <linux/sizes.h>
+
 #include "internal.h"
 
 #ifdef CONFIG_NUMA
@@ -186,7 +192,7 @@ struct rmap_item {
 	};
 	struct mm_struct *mm;
 	unsigned long address;		/* + low bits used for flags below */
-	unsigned int oldchecksum;	/* when unstable */
+	unsigned long oldchecksum;	/* when unstable */
 	union {
 		struct rb_node node;	/* when node of unstable tree */
 		struct {		/* when listed from stable tree */
@@ -255,7 +261,7 @@ static unsigned int ksm_thread_pages_to_scan = 100;
 static unsigned int ksm_thread_sleep_millisecs = 20;
 
 /* Checksum of an empty (zeroed) page */
-static unsigned int zero_checksum __read_mostly;
+static unsigned long zero_checksum __read_mostly;
 
 /* Whether to merge empty (zeroed) pages with actual zero pages */
 static bool ksm_use_zero_pages __read_mostly;
@@ -284,6 +290,98 @@ static DEFINE_SPINLOCK(ksm_mmlist_lock);
 		sizeof(struct __struct), __alignof__(struct __struct),\
 		(__flags), NULL)
 
+#define TIME_125MS  (HZ >> 3)
+#define PERF_TO_MBS(X) (X*PAGE_SIZE*(1 << 3)/(SZ_1M))
+
+#define HASH_NONE   0
+#define HASH_CRC32C 1
+#define HASH_XXHASH 2
+
+static struct shash_desc desc;
+
+static int fastest_hash = 0;
+
+static void __init choice_fastest_hash(void)
+{
+	void *page = ZERO_PAGE(0);
+	unsigned long checksum, perf, je;
+	unsigned long best_perf = 0;
+
+	desc.tfm = crypto_alloc_shash("crc32c", 0, 0);
+	desc.flags = 0;
+
+	if (IS_ERR(desc.tfm)) {
+		pr_warn("ksm: alloc crc32c shash error %ld\n",
+			-PTR_ERR(desc.tfm));
+		fastest_hash = HASH_XXHASH;
+		goto out;
+	}
+
+	perf = 0;
+	preempt_disable();
+	je = jiffies + TIME_125MS;
+	while (time_before(jiffies, je)) {
+		crypto_shash_digest(&desc, page, PAGE_SIZE, (u8 *)&checksum);
+		perf++;
+	}
+	preempt_enable();
+
+	if (best_perf < perf) {
+		best_perf = perf;
+		fastest_hash = HASH_CRC32C;
+	}
+
+	pr_info("ksm: crc32c hash() %5ld MB/s\n", PERF_TO_MBS(perf));
+
+	perf = 0;
+	preempt_disable();
+	je = jiffies + TIME_125MS;
+	while (time_before(jiffies, je)) {
+		checksum = xxhash(page, PAGE_SIZE, 0);
+		perf++;
+	}
+	preempt_enable();
+
+	if (best_perf < perf) {
+		best_perf = perf;
+		fastest_hash = HASH_XXHASH;
+	}
+
+	pr_info("ksm: xxhash hash() %5ld MB/s\n", PERF_TO_MBS(perf));
+
+	if (fastest_hash != HASH_CRC32C)
+		crypto_free_shash(desc.tfm);
+
+out:
+	if (fastest_hash == HASH_CRC32C)
+		pr_info("ksm: choice crc32c as hash function\n");
+	else
+		pr_info("ksm: choice xxhash as hash function\n");
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
+		/* The correct value depends on page size and endianness */
+		zero_checksum = fasthash(ZERO_PAGE(0), PAGE_SIZE);
+		break;
+	case HASH_CRC32C:
+		crypto_shash_digest(&desc, input, length,
+			    (u8 *)&checksum);
+		break;
+	case HASH_XXHASH:
+		checksum = xxhash(input, length, 0);
+		break;
+	}
+
+	return checksum;
+}
+
 static int __init ksm_slab_init(void)
 {
 	rmap_item_cache = KSM_KMEM_CACHE(rmap_item, 0);
@@ -982,11 +1080,11 @@ static int unmerge_and_remove_all_rmap_items(void)
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
@@ -2006,7 +2104,7 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	struct page *tree_page = NULL;
 	struct stable_node *stable_node;
 	struct page *kpage;
-	unsigned int checksum;
+	unsigned long checksum;
 	int err;
 	bool max_page_sharing_bypass = false;
 
@@ -3068,8 +3166,6 @@ static int __init ksm_init(void)
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
