Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B56E8E000C
	for <linux-mm@kvack.org>; Thu, 13 Sep 2018 17:41:16 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id p105-v6so6925729wrc.11
        for <linux-mm@kvack.org>; Thu, 13 Sep 2018 14:41:16 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y1-v6sor4479736wrd.40.2018.09.13.14.41.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 13 Sep 2018 14:41:14 -0700 (PDT)
From: Timofey Titovets <timofey.titovets@synesis.ru>
Subject: [PATCH V8 2/2] ksm: replace jhash2 with xxhash
Date: Fri, 14 Sep 2018 00:41:02 +0300
Message-Id: <20180913214102.28269-3-timofey.titovets@synesis.ru>
In-Reply-To: <20180913214102.28269-1-timofey.titovets@synesis.ru>
References: <20180913214102.28269-1-timofey.titovets@synesis.ru>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rppt@linux.vnet.ibm.com, Timofey Titovets <nefelim4ag@gmail.com>, leesioh <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org

From: Timofey Titovets <nefelim4ag@gmail.com>

Replace jhash2 with xxhash.

Perf numbers:
Intel(R) Xeon(R) CPU E5-2420 v2 @ 2.20GHz
ksm: crc32c   hash() 12081 MB/s
ksm: xxh64    hash()  8770 MB/s
ksm: xxh32    hash()  4529 MB/s
ksm: jhash2   hash()  1569 MB/s

>From Sioh Lee:
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
  v7 -> v8:
    - Remove empty line changes

Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
Signed-off-by: leesioh <solee@os.korea.ac.kr>
Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
CC: Andrea Arcangeli <aarcange@redhat.com>
CC: linux-mm@kvack.org
CC: kvm@vger.kernel.org
---
 mm/Kconfig | 1 +
 mm/ksm.c   | 4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

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
index 5b0894b45ee5..1a088306ef81 100644
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
@@ -1009,7 +1009,7 @@ static u32 calc_checksum(struct page *page)
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
