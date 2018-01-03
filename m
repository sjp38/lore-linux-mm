Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3A256B02EC
	for <linux-mm@kvack.org>; Tue,  2 Jan 2018 22:10:04 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id p8so177346wrh.17
        for <linux-mm@kvack.org>; Tue, 02 Jan 2018 19:10:04 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k23sor25761wrc.81.2018.01.02.19.10.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Jan 2018 19:10:03 -0800 (PST)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH V6 2/2] ksm: replace jhash2 with faster hash
Date: Wed,  3 Jan 2018 06:09:50 +0300
Message-Id: <20180103030950.10573-2-nefelim4ag@gmail.com>
In-Reply-To: <20180103030950.10573-1-nefelim4ag@gmail.com>
References: <20180103030950.10573-1-nefelim4ag@gmail.com>
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

As jhash2 always will be slower (for data size like PAGE_SIZE),
just drop it from choice.

Add function to autoselect hash algo on boot,
based on hashing speed, like raid6 code does.

Move init of zero_checksum from init, to first call of fasthash():
  1. KSM Init run on early kernel init,
     run perf testing stuff on main kernel boot thread looks bad to me.
  2. Crypto subsystem not avaliable at that early booting,
     so crc32c even, compiled in, not avaliable
     As crypto and ksm init, run at subsys_initcall() (4) kernel level of init,
     all possible consumers will run later at 5+ levels

Output after first try of KSM to hash page:
ksm: crc32c hash() 15218 MB/s
ksm: xxhash hash()  8640 MB/s
ksm: choice crc32c as hash function

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
  v5 -> v6:
    - Use libcrc32c instead of CRYPTO API, mainly for
      code/Kconfig deps Simplification
    - Add crc32c_available():
      libcrc32c will BUG_ON on crc32c problems,
      so test crc32c avaliable by crc32c_available()
    - Simplify choice_fastest_hash()
    - Simplify fasthash()
    - struct rmap_item && stable_node have sizeof == 64 on x86_64,
      that makes them cache friendly. As we don't suffer from hash collisions,
      change hash type from unsigned long back to u32.
    - Fix kbuild robot warning, make all local functions static

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
Signed-off-by: leesioh <solee@os.korea.ac.kr>
CC: Andrea Arcangeli <aarcange@redhat.com>
CC: linux-mm@kvack.org
CC: kvm@vger.kernel.org
---
 mm/Kconfig |  2 ++
 mm/ksm.c   | 93 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 91 insertions(+), 4 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 03ff7703d322..b60bee4bb07e 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -305,6 +305,8 @@ config MMU_NOTIFIER
 config KSM
 	bool "Enable KSM for page merging"
 	depends on MMU
+	select XXHASH
+	select LIBCRC32C
 	help
 	  Enable Kernel Samepage Merging: KSM periodically scans those areas
 	  of an application's address space that an app has advised may be
diff --git a/mm/ksm.c b/mm/ksm.c
index be8f4576f842..65665bce2dce 100644
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
+#include <crypto/hash.h>
+#include <linux/crc32c.h>
+#include <linux/xxhash.h>
+#include <linux/sizes.h>
+
 #include "internal.h"
 
 #ifdef CONFIG_NUMA
@@ -284,6 +290,87 @@ static DEFINE_SPINLOCK(ksm_mmlist_lock);
 		sizeof(struct __struct), __alignof__(struct __struct),\
 		(__flags), NULL)
 
+#define TIME_125MS  (HZ >> 3)
+#define PERF_TO_MBS(X) (X*PAGE_SIZE*(1 << 3)/(SZ_1M))
+
+#define HASH_NONE   0
+#define HASH_CRC32C 1
+#define HASH_XXHASH 2
+
+static int fastest_hash = HASH_NONE;
+
+static bool __init crc32c_available(void)
+{
+	static struct shash_desc desc;
+
+	desc.tfm = crypto_alloc_shash("crc32c", 0, 0);
+	desc.flags = 0;
+
+	if (IS_ERR(desc.tfm)) {
+		pr_warn("ksm: alloc crc32c shash error %ld\n",
+			-PTR_ERR(desc.tfm));
+		return false;
+	}
+
+	crypto_free_shash(desc.tfm);
+	return true;
+}
+
+static void __init choice_fastest_hash(void)
+{
+
+	unsigned long je;
+	unsigned long perf_crc32c = 0;
+	unsigned long perf_xxhash = 0;
+
+	fastest_hash = HASH_XXHASH;
+	if (!crc32c_available())
+		goto out;
+
+	preempt_disable();
+	je = jiffies + TIME_125MS;
+	while (time_before(jiffies, je)) {
+		crc32c(0, ZERO_PAGE(0), PAGE_SIZE);
+		perf_crc32c++;
+	}
+	preempt_enable();
+
+	preempt_disable();
+	je = jiffies + TIME_125MS;
+	while (time_before(jiffies, je)) {
+		xxhash(ZERO_PAGE(0), PAGE_SIZE, 0);
+		perf_xxhash++;
+	}
+	preempt_enable();
+
+	pr_info("ksm: crc32c hash() %5ld MB/s\n", PERF_TO_MBS(perf_crc32c));
+	pr_info("ksm: xxhash hash() %5ld MB/s\n", PERF_TO_MBS(perf_xxhash));
+
+	if (perf_crc32c > perf_xxhash)
+		fastest_hash = HASH_CRC32C;
+out:
+	if (fastest_hash == HASH_CRC32C)
+		pr_info("ksm: choice crc32c as hash function\n");
+	else
+		pr_info("ksm: choice xxhash as hash function\n");
+}
+
+static u32 fasthash(const void *input, size_t length)
+{
+again:
+	switch (fastest_hash) {
+	case HASH_CRC32C:
+		return crc32c(0, input, length);
+	case HASH_XXHASH:
+		return xxhash(input, length, 0);
+	default:
+		choice_fastest_hash();
+		/* The correct value depends on page size and endianness */
+		zero_checksum = fasthash(ZERO_PAGE(0), PAGE_SIZE);
+		goto again;
+	}
+}
+
 static int __init ksm_slab_init(void)
 {
 	rmap_item_cache = KSM_KMEM_CACHE(rmap_item, 0);
@@ -986,7 +1073,7 @@ static u32 calc_checksum(struct page *page)
 {
 	u32 checksum;
 	void *addr = kmap_atomic(page);
-	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
+	checksum = fasthash(addr, PAGE_SIZE);
 	kunmap_atomic(addr);
 	return checksum;
 }
@@ -3068,8 +3155,6 @@ static int __init ksm_init(void)
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
