Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 64C936B00C6
	for <linux-mm@kvack.org>; Wed, 13 May 2009 04:16:26 -0400 (EDT)
From: Sheng Yang <sheng@linux.intel.com>
Subject: [PATCH] x86: Extend test_and_set_bit() test_and_clean_bit() to 64 bits in X86_64
Date: Wed, 13 May 2009 16:17:27 +0800
Message-Id: <1242202647-32446-1-git-send-email-sheng@linux.intel.com>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Sheng Yang <sheng@linux.intel.com>
List-ID: <linux-mm.kvack.org>

This fix 44/45 bit width memory can't boot up issue. The reason is
free_bootmem_node()->mark_bootmem_node()->__free() use test_and_clean_bit() to
clean node_bootmem_map, but for 44bits width address, the idx set bit 31 (43 -
12), which consider as a nagetive value for bts.

This patch applied to tip/mm.

Signed-off-by: Sheng Yang <sheng@linux.intel.com>
---
 arch/x86/include/asm/bitops.h |   24 +++++++++++++++---------
 1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/arch/x86/include/asm/bitops.h b/arch/x86/include/asm/bitops.h
index 02b47a6..400dd28 100644
--- a/arch/x86/include/asm/bitops.h
+++ b/arch/x86/include/asm/bitops.h
@@ -41,6 +41,12 @@
 #define CONST_MASK_ADDR(nr, addr)	BITOP_ADDR((void *)(addr) + ((nr)>>3))
 #define CONST_MASK(nr)			(1 << ((nr) & 7))
 
+#ifdef CONFIG_X86_64
+#define REX_X86 "rex "
+#else
+#define REX_X86
+#endif
+
 /**
  * set_bit - Atomically set a bit in memory
  * @nr: the bit to set
@@ -192,11 +198,11 @@ static inline void change_bit(int nr, volatile unsigned long *addr)
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static inline int test_and_set_bit(int nr, volatile unsigned long *addr)
+static inline int test_and_set_bit(long int nr, volatile unsigned long *addr)
 {
 	int oldbit;
 
-	asm volatile(LOCK_PREFIX "bts %2,%1\n\t"
+	asm volatile(LOCK_PREFIX REX_X86 "bts %2,%1\n\t"
 		     "sbb %0,%0" : "=r" (oldbit), ADDR : "Ir" (nr) : "memory");
 
 	return oldbit;
@@ -224,11 +230,11 @@ test_and_set_bit_lock(int nr, volatile unsigned long *addr)
  * If two examples of this operation race, one can appear to succeed
  * but actually fail.  You must protect multiple accesses with a lock.
  */
-static inline int __test_and_set_bit(int nr, volatile unsigned long *addr)
+static inline int __test_and_set_bit(long int nr, volatile unsigned long *addr)
 {
 	int oldbit;
 
-	asm("bts %2,%1\n\t"
+	asm(REX_X86 "bts %2,%1\n\t"
 	    "sbb %0,%0"
 	    : "=r" (oldbit), ADDR
 	    : "Ir" (nr));
@@ -243,14 +249,13 @@ static inline int __test_and_set_bit(int nr, volatile unsigned long *addr)
  * This operation is atomic and cannot be reordered.
  * It also implies a memory barrier.
  */
-static inline int test_and_clear_bit(int nr, volatile unsigned long *addr)
+static inline int test_and_clear_bit(long int nr, volatile unsigned long *addr)
 {
 	int oldbit;
 
-	asm volatile(LOCK_PREFIX "btr %2,%1\n\t"
+	asm volatile(LOCK_PREFIX REX_X86 "btr %2,%1\n\t"
 		     "sbb %0,%0"
 		     : "=r" (oldbit), ADDR : "Ir" (nr) : "memory");
-
 	return oldbit;
 }
 
@@ -263,11 +268,12 @@ static inline int test_and_clear_bit(int nr, volatile unsigned long *addr)
  * If two examples of this operation race, one can appear to succeed
  * but actually fail.  You must protect multiple accesses with a lock.
  */
-static inline int __test_and_clear_bit(int nr, volatile unsigned long *addr)
+static inline int __test_and_clear_bit(long int nr,
+				       volatile unsigned long *addr)
 {
 	int oldbit;
 
-	asm volatile("btr %2,%1\n\t"
+	asm volatile(REX_X86 "btr %2,%1\n\t"
 		     "sbb %0,%0"
 		     : "=r" (oldbit), ADDR
 		     : "Ir" (nr));
-- 
1.5.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
