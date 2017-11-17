Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2D00E6B026B
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 17:30:55 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id v2so3447396pfa.10
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 14:30:55 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id h185si3826728pfc.277.2017.11.17.14.30.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 14:30:53 -0800 (PST)
From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH 3/5] mm/kasan: do advanced check
Date: Fri, 17 Nov 2017 14:30:41 -0800
Message-Id: <20171117223043.7277-4-wen.gang.wang@oracle.com>
In-Reply-To: <20171117223043.7277-1-wen.gang.wang@oracle.com>
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, aryabinin@virtuozzo.com
Cc: wen.gang.wang@oracle.com, glider@google.com, dvyukov@google.com

This is the 3rd patch in the Kasan advanced check feature.
It does advanced check in the poison check functions and report for
advanced check.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index 5017269..ba00594 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -16,6 +16,13 @@ struct task_struct;
 #include <asm/kasan.h>
 #include <asm/pgtable.h>
 
+/* advanced check type */
+enum kasan_adv_chk_type {
+	/* write access is allowed only for the owner */
+	KASAN_ADVCHK_OWNER,
+	__KASAN_ADVCHK_TYPE_COUNT,
+};
+
 extern unsigned char kasan_zero_page[PAGE_SIZE];
 extern pte_t kasan_zero_pte[PTRS_PER_PTE];
 extern pmd_t kasan_zero_pmd[PTRS_PER_PMD];
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 4501422..e945df7 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -40,6 +40,51 @@
 #include "kasan.h"
 #include "../slab.h"
 
+struct kasan_adv_check kasan_adv_checks[(1 << KASAN_CHECK_BITS)-2];
+static int kasan_adv_nr_checks;
+static DEFINE_SPINLOCK(kasan_adv_lock);
+
+/* we don't take lock kasan_adv_lock. Locking can either cause deadload
+ * or kill the performance further.
+ * We are still safe without lock since kasan_adv_nr_checks increases only.
+ * The worst and rare case is kasan_adv_nr_checks is stale (smaller than it
+ * really is) and we miss a check.
+ */
+struct kasan_adv_check *get_check_by_nr(int nr)
+{
+	if (nr > kasan_adv_nr_checks || nr <= 0)
+		return NULL;
+	return &kasan_adv_checks[nr-1];
+}
+
+static __always_inline bool adv_check(bool write, s8 check)
+{
+	struct kasan_adv_check *chk = get_check_by_nr(check);
+
+	if (likely(chk)) {
+		bool violation = chk->ac_check_func(write, chk->ac_data);
+
+		if (unlikely(violation))
+			chk->ac_violation = violation;
+		return violation;
+	}
+	return false;
+}
+
+static __always_inline unsigned long adv_check_shadow(const s8 *shadow_addr,
+					     size_t shadow_size, bool write)
+{
+	s8 check;
+	int i;
+
+	for (i = 0; i < shadow_size; i++) {
+		check = kasan_get_check(*(shadow_addr + i));
+		if (unlikely(check && adv_check(write, check)))
+			return (unsigned long)(shadow_addr + i);
+	}
+	return 0;
+}
+
 void kasan_enable_current(void)
 {
 	current->kasan_depth++;
@@ -128,8 +173,11 @@ static __always_inline bool memory_is_poisoned_1(unsigned long addr, bool write)
 
 	if (unlikely(shadow_value)) {
 		s8 last_accessible_byte = addr & KASAN_SHADOW_MASK;
-		return unlikely(last_accessible_byte >=
-				KASAN_GET_POISON(shadow_value));
+		if (unlikely(KASAN_GET_POISON(shadow_value) &&
+			last_accessible_byte >= KASAN_GET_POISON(shadow_value)))
+			return true;
+		if (unlikely(kasan_get_check(shadow_value)))
+			return adv_check(write, kasan_get_check(shadow_value));
 	}
 
 	return false;
@@ -145,9 +193,14 @@ static __always_inline bool memory_is_poisoned_2_4_8(unsigned long addr,
 	 * Access crosses 8(shadow size)-byte boundary. Such access maps
 	 * into 2 shadow bytes, so we need to check them both.
 	 */
-	if (unlikely(((addr + size - 1) & KASAN_SHADOW_MASK) < size - 1))
-		return KASAN_GET_POISON(*shadow_addr) ||
-		       memory_is_poisoned_1(addr + size - 1, write);
+	if (unlikely(((addr + size - 1) & KASAN_SHADOW_MASK) < size - 1)) {
+		u8 check = kasan_get_check(*shadow_addr);
+
+		if (unlikely(KASAN_GET_POISON(*shadow_addr)))
+			return true;
+		if (unlikely(check && adv_check(write, check)))
+			return true;
+	}
 
 	return memory_is_poisoned_1(addr + size - 1, write);
 }
@@ -157,21 +210,31 @@ static __always_inline bool memory_is_poisoned_16(unsigned long addr,
 {
 	u16 *shadow_addr = (u16 *)kasan_mem_to_shadow((void *)addr);
 
-	/* Unaligned 16-bytes access maps into 3 shadow bytes. */
-	if (unlikely(!IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
-		return KASAN_GET_POISON_16(*shadow_addr) ||
-		       memory_is_poisoned_1(addr + 15, write);
+	if (unlikely(KASAN_GET_POISON_16(*shadow_addr)))
+		return true;
+
+	if (unlikely(adv_check_shadow((s8 *)shadow_addr, 2, write)))
+		return true;
 
-	return *shadow_addr;
+	if (likely(IS_ALIGNED(addr, KASAN_SHADOW_SCALE_SIZE)))
+		return false;
+
+	/* Unaligned 16-bytes access maps into 3 shadow bytes. */
+	return memory_is_poisoned_1(addr + 15, write);
 }
 
 static __always_inline unsigned long bytes_is_nonzero(const u8 *start,
 						      size_t size,
 						      bool write)
 {
+	int check;
+
 	while (size) {
 		if (unlikely(KASAN_GET_POISON(*start)))
 			return (unsigned long)start;
+		check = kasan_get_check(*start);
+		if (unlikely(check && adv_check(write, check)))
+			return (unsigned long)start;
 		start++;
 		size--;
 	}
@@ -202,6 +265,9 @@ static __always_inline unsigned long memory_is_nonzero(const void *start,
 	while (words) {
 		if (unlikely(KASAN_GET_POISON_64(*(u64 *)start)))
 			return bytes_is_nonzero(start, 8, write);
+		ret = adv_check_shadow(start, sizeof(u64), write);
+		if (unlikely(ret))
+			return (unsigned long)ret;
 		start += 8;
 		words--;
 	}
@@ -227,6 +293,11 @@ static __always_inline bool memory_is_poisoned_n(unsigned long addr,
 			((long)(last_byte & KASAN_SHADOW_MASK) >=
 			KASAN_GET_POISON(*last_shadow))))
 			return true;
+		else {
+			s8 check = kasan_get_check(*last_shadow);
+
+			return unlikely(check && adv_check(write, check));
+		}
 	}
 	return false;
 }
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index df7fbfe..2e2af6d 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -111,6 +111,16 @@ struct kasan_free_meta {
 	struct qlist_node quarantine_link;
 };
 
+struct kasan_adv_check {
+	enum kasan_adv_chk_type	ac_type;
+	bool			(*ac_check_func)(bool, void *);
+	void			*ac_data;
+	char			*ac_msg;
+	bool			ac_violation;
+};
+
+extern struct kasan_adv_check *get_check_by_nr(int nr);
+
 struct kasan_alloc_meta *get_alloc_info(struct kmem_cache *cache,
 					const void *object);
 struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index caf3a13..403bae1 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -57,10 +57,26 @@ static bool addr_has_shadow(struct kasan_access_info *info)
 		kasan_shadow_to_mem((void *)KASAN_SHADOW_START));
 }
 
+static bool is_clean_byte(u8 shadow_val)
+{
+	u8 poison = KASAN_GET_POISON(shadow_val);
+	u8 check = kasan_get_check(shadow_val);
+
+	if (poison > 0 && poison <= KASAN_SHADOW_SCALE_SIZE - 1) {
+		struct kasan_adv_check *chk = get_check_by_nr(check);
+
+		if (chk && chk->ac_violation)
+			return false;
+		return true;
+	}
+
+	return false;
+}
+
 static const char *get_shadow_bug_type(struct kasan_access_info *info)
 {
 	const char *bug_type = "unknown-crash";
-	u8 *shadow_addr;
+	u8 *shadow_addr, check;
 	s8 poison;
 
 	info->first_bad_addr = find_first_bad_addr(info->access_addr,
@@ -68,12 +84,15 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
 
 	shadow_addr = (u8 *)kasan_mem_to_shadow(info->first_bad_addr);
 	poison = KASAN_GET_POISON(*shadow_addr);
+	check = kasan_get_check(*shadow_addr);
 	/*
 	 * If shadow byte value is in [0, KASAN_SHADOW_SCALE_SIZE) we can look
 	 * at the next shadow byte to determine the type of the bad access.
 	 */
-	if (poison > 0 && poison <= KASAN_SHADOW_SCALE_SIZE - 1)
+	if (is_clean_byte(*shadow_addr)) {
 		poison = KASAN_GET_POISON(*(shadow_addr + 1));
+		check = check = kasan_get_check(*(shadow_addr + 1));
+	}
 
 	if (poison < 0)
 		poison |= KASAN_CHECK_MASK;
@@ -108,6 +127,15 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
 		break;
 	}
 
+	if (check) {
+		struct kasan_adv_check *chk = get_check_by_nr(check);
+
+		if (chk && chk->ac_violation) {
+			bug_type = chk->ac_msg;
+			chk->ac_violation = false;
+		}
+	}
+
 	return bug_type;
 }
 
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
