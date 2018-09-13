Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 494428E0001
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 17:19:44 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id i11-v6so6890351wrr.10
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 14:19:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w35-v6sor4344321wrc.46.2018.09.13.14.19.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Sep 2018 14:19:42 -0700 (PDT)
From: Timofey Titovets <timofey.titovets@synesis.ru>
Subject: [PATCH V7 2/2] ksm: replace jhash2 with xxhash
Date: Fri, 14 Sep 2018 00:19:23 +0300
Message-Id: <20180913211923.7696-3-timofey.titovets@synesis.ru>
In-Reply-To: <20180913211923.7696-1-timofey.titovets@synesis.ru>
References: <20180913211923.7696-1-timofey.titovets@synesis.ru>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Pavel.Tatashin@microsoft.com, rppt@linux.vnet.ibm.com, Timofey Titovets <nefelim4ag@gmail.com>, leesioh <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org

From: Timofey Titovets <nefelim4ag@gmail.com>

Replace jhash2 with xxhash.

Perf numbers:
Intel(R) Xeon(R) CPU E5-2420 v2 @ 2.20GHz
ksm: crc32c   hash() 12081 MB/s
ksm: xxh64    hash()  8770 MB/s
ksm: xxh32    hash()  4529 MB/s
ksm: jhash2   hash()  1569 MB/s

By sioh Lee tests (copy from other mail):
Test platform: openstack cloud platform (NEWTON version)
Experiment node: openstack based cloud compute node (CPU: xeon E5-2620 v3, memory 64gb)
VM: (2 VCPU, RAM 4GB, DISK 20GB) * 4
Linux kernel: 4.14 (latest version)
KSM setup - sleep_millisecs: 200ms, pages_to_scan: 200

Experiment process
Firstly, we turn off KSM and launch 4 VMs.
Then we turn on the KSM and measure the checksum computation time until full_scans become two.

The experimental results (the experimental value is the average of the measured values)
crc32c_intel: 1084.10ns
crc32c (no hardware acceleration): 7012.51ns
xxhash32: 2227.75ns
xxhash64: 1413.16ns
jhash2: 5128.30ns

As jhash2 always will be slower (for data size like PAGE_SIZE).
Don't use it in ksm at all.

Use only xxhash for now, because for using crc32c,
cryptoapi must be initialized first - that require some
tricky solution to work good in all situations.

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
  v6 -> v7:
    - Drop crc32c for now and use only xxhash in ksm.

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
Signed-off-by: leesioh <solee@os.korea.ac.kr>
CC: Andrea Arcangeli <aarcange@redhat.com>
CC: linux-mm@kvack.org
CC: kvm@vger.kernel.org
---
 mm/Kconfig | 1 +
 mm/ksm.c   | 6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index a550635ea5c3..b5f923081bce 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -297,6 +297,7 @@ config MMU_NOTIFIER
 config KSM
 	bool "Enable KSM for page merging"
 	depends on MMU
+	select XXHASH
 	help
 	  Enable Kernel Samepage Merging: KSM periodically scans those areas
 	  of an application's address space that an app has advised may be
diff --git a/mm/ksm.c b/mm/ksm.c
index 5b0894b45ee5..30c595dd5d87 100644
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
@@ -41,6 +41,7 @@
 #include <linux/numa.h>
 
 #include <asm/tlbflush.h>
+
 #include "internal.h"
 
 #ifdef CONFIG_NUMA
@@ -303,6 +304,7 @@ static DEFINE_SPINLOCK(ksm_mmlist_lock);
 		sizeof(struct __struct), __alignof__(struct __struct),\
 		(__flags), NULL)
 
+
 static int __init ksm_slab_init(void)
 {
 	rmap_item_cache = KSM_KMEM_CACHE(rmap_item, 0);
@@ -1009,7 +1011,7 @@ static u32 calc_checksum(struct page *page)
 {
 	u32 checksum;
 	void *addr = kmap_atomic(page);
-	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
+	checksum = xxhash(addr, PAGE_SIZE, 0);
 	kunmap_atomic(addr);
 	return checksum;
 }
-- 
2.19.0
