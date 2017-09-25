Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB3FB6B0253
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 15:33:33 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id d6so10069856wrd.7
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 12:33:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z51sor2397198wrb.5.2017.09.25.12.33.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 25 Sep 2017 12:33:32 -0700 (PDT)
From: Timofey Titovets <nefelim4ag@gmail.com>
Subject: [PATCH v3 2/2] KSM: Replace jhash2 with xxhash
Date: Mon, 25 Sep 2017 22:33:20 +0300
Message-Id: <20170925193320.10009-3-nefelim4ag@gmail.com>
In-Reply-To: <20170925193320.10009-1-nefelim4ag@gmail.com>
References: <20170925193320.10009-1-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, borntraeger@de.ibm.com, kvm@vger.kernel.org, Timofey Titovets <nefelim4ag@gmail.com>

jhash2 used for calculating checksum
for in memory pages, for detect fact of
changes in page.

xxhash much faster then jhash2, some tests:
  x86_64 host:
    CPU: Intel(R) Core(TM) i5-7200U CPU @ 2.50GHz
    PAGE_SIZE: 4096, loop count: 1048576
    jhash2:   0xacbc7a5b            time: 1907 ms,  th:  2251.9 MiB/s
    xxhash32: 0x570da981            time: 739 ms,   th:  5809.4 MiB/s
    xxhash64: 0xa1fa032ab85bbb62    time: 371 ms,   th: 11556.6 MiB/s

    CPU: Intel(R) Xeon(R) CPU E5-2420 0 @ 1.90GHz
    PAGE_SIZE: 4096, loop count: 1048576
    jhash2:   0xe680b382            time: 3722 ms,  th: 1153.896680 MiB/s
    xxhash32: 0x56d00be4            time: 1183 ms,  th: 3629.130689 MiB/s
    xxhash64: 0x8c194cff29cc4dee    time: 725 ms,   th: 5918.003401 MiB/s

xxhash64 on x86_32 work with ~ same speed as jhash2.
xxhash32 on x86_32 work with ~ same speed as for x86_64
jhash2 are faster than xxhash on input data smaller than 32 byte

So use xxhash() which will take appropriate hash version
for target arch

I did some benchmarks (i get cpu load of ksmd from htop):
  CPU: Intel(R) Xeon(R) CPU E5-2420 0 @ 1.90GHz
  ksm: sleep_millisecs = 1
    jhash2:   ~18%
    xxhash64: ~11%
  ksm: sleep_millisecs = 20 - default
    jhash2:   ~4.7%
    xxhash64: ~3.3%

  - 11 / 18 ~= 0.6 -> Profit: ~40%
  - 3.3/4.7 ~= 0.7 -> Profit: ~30%

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
Acked-by: Andi Kleen <ak@linux.intel.com>
Acked-by: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Linux-kernel <linux-kernel@vger.kernel.org>
Cc: Linux-kvm <kvm@vger.kernel.org>
---
 mm/Kconfig |  1 +
 mm/ksm.c   | 14 +++++++-------
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 9c4bdddd80c2..252ab266ac23 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -305,6 +305,7 @@ config MMU_NOTIFIER
 config KSM
 	bool "Enable KSM for page merging"
 	depends on MMU
+	select XXHASH
 	help
 	  Enable Kernel Samepage Merging: KSM periodically scans those areas
 	  of an application's address space that an app has advised may be
diff --git a/mm/ksm.c b/mm/ksm.c
index 15dd7415f7b3..98b86e5cf90e 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -25,7 +25,7 @@
 #include <linux/pagemap.h>
 #include <linux/rmap.h>
 #include <linux/spinlock.h>
-#include <linux/jhash.h>
+#include <linux/xxhash.h>
 #include <linux/delay.h>
 #include <linux/kthread.h>
 #include <linux/wait.h>
@@ -186,7 +186,7 @@ struct rmap_item {
 	};
 	struct mm_struct *mm;
 	unsigned long address;		/* + low bits used for flags below */
-	unsigned int oldchecksum;	/* when unstable */
+	unsigned long oldchecksum;		/* when unstable */
 	union {
 		struct rb_node node;	/* when node of unstable tree */
 		struct {		/* when listed from stable tree */
@@ -255,7 +255,7 @@ static unsigned int ksm_thread_pages_to_scan = 100;
 static unsigned int ksm_thread_sleep_millisecs = 20;

 /* Checksum of an empty (zeroed) page */
-static unsigned int zero_checksum __read_mostly;
+static unsigned long zero_checksum __read_mostly;

 /* Whether to merge empty (zeroed) pages with actual zero pages */
 static bool ksm_use_zero_pages __read_mostly;
@@ -982,11 +982,11 @@ static int unmerge_and_remove_all_rmap_items(void)
 }
 #endif /* CONFIG_SYSFS */

-static u32 calc_checksum(struct page *page)
+static unsigned long calc_checksum(struct page *page)
 {
-	u32 checksum;
+	unsigned long checksum;
 	void *addr = kmap_atomic(page);
-	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
+	checksum = xxhash(addr, PAGE_SIZE, 0);
 	kunmap_atomic(addr);
 	return checksum;
 }
@@ -1994,7 +1994,7 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
 	struct page *tree_page = NULL;
 	struct stable_node *stable_node;
 	struct page *kpage;
-	unsigned int checksum;
+	unsigned long checksum;
 	int err;
 	bool max_page_sharing_bypass = false;

--
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
