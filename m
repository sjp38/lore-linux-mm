Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 905616B026A
	for <linux-mm@kvack.org>; Fri, 17 Nov 2017 17:30:54 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id 136so609493qkd.1
        for <linux-mm@kvack.org>; Fri, 17 Nov 2017 14:30:54 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id j39si4561228qtc.112.2017.11.17.14.30.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Nov 2017 14:30:53 -0800 (PST)
From: Wengang Wang <wen.gang.wang@oracle.com>
Subject: [PATCH 4/5] mm/kasan: register check and bind it to memory
Date: Fri, 17 Nov 2017 14:30:42 -0800
Message-Id: <20171117223043.7277-5-wen.gang.wang@oracle.com>
In-Reply-To: <20171117223043.7277-1-wen.gang.wang@oracle.com>
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, aryabinin@virtuozzo.com
Cc: wen.gang.wang@oracle.com, glider@google.com, dvyukov@google.com

This is a part of the Kasan advanced check patch series. This patch
introduces "owner check". It defines the owner of the memory range as a
dozen of functions. Only those functions are allowed of write access to the
bound memory ranges. Write access from other functions are treated as
violation and corresponding error will be reported.

Two APIs are provided. One is used to register a check with owning
functions , the other binds memory ranges to the check. The check token is
stored in the "check" bits in shadow bytes. For each memory access, besides
does poison detects, kasan scans those "check" bits and does violation
check accordingly.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index ba00594..721da3e 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -16,6 +16,7 @@ struct task_struct;
 #include <asm/kasan.h>
 #include <asm/pgtable.h>
 
+#define KASAN_OWNER_MAX	32
 /* advanced check type */
 enum kasan_adv_chk_type {
 	/* write access is allowed only for the owner */
@@ -32,6 +33,11 @@ extern p4d_t kasan_zero_p4d[PTRS_PER_P4D];
 void kasan_populate_zero_shadow(const void *shadow_start,
 				const void *shadow_end);
 
+struct kasan_owner_set {
+	unsigned int	s_nr;	/* # of function pointers in the following */
+	void		*s_ptrs[KASAN_OWNER_MAX];
+};
+
 static inline void *kasan_mem_to_shadow(const void *addr)
 {
 	return (void *)((unsigned long)addr >> KASAN_SHADOW_SCALE_SHIFT)
@@ -87,6 +93,9 @@ size_t kasan_metadata_size(struct kmem_cache *cache);
 bool kasan_save_enable_multi_shot(void);
 void kasan_restore_multi_shot(bool enabled);
 
+extern int kasan_register_adv_check(unsigned int ac_type, void *p);
+extern int kasan_bind_adv_addr(void *addr, size_t size, u8 check);
+
 #else /* CONFIG_KASAN */
 
 static inline void kasan_unpoison_shadow(const void *address, size_t size) {}
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index e945df7..753a285 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -36,6 +36,7 @@
 #include <linux/types.h>
 #include <linux/vmalloc.h>
 #include <linux/bug.h>
+#include <linux/kallsyms.h>
 
 #include "kasan.h"
 #include "../slab.h"
@@ -44,6 +45,139 @@ struct kasan_adv_check kasan_adv_checks[(1 << KASAN_CHECK_BITS)-2];
 static int kasan_adv_nr_checks;
 static DEFINE_SPINLOCK(kasan_adv_lock);
 
+/* owner of the memory, the allowed write-access functions. */
+struct kasan_adv_owner {
+	unsigned long	ao_start;	/* the start of the owning function */
+	unsigned long	ao_end;		/* the end of the owning function */
+};
+
+struct kasan_adv_owners {
+	int	ao_nr;	/* # of kasan_adv_owner in the following */
+	struct kasan_adv_owner ao_owners[KASAN_OWNER_MAX];
+};
+
+static __always_inline bool owner_check(bool write, void *p)
+{
+	if (write) {
+		struct kasan_adv_owners *owners;
+		struct kasan_adv_owner *o;
+		unsigned long caller;
+		int i;
+
+		owners = p;
+		caller = (unsigned long)__builtin_return_address(1);
+
+		for (i = 0; i < owners->ao_nr; i++) {
+			o = &owners->ao_owners[i];
+			if (caller >= o->ao_start && caller <= o->ao_end)
+				return false;
+		}
+		return true;
+	}
+	return false;
+}
+
+static struct kasan_adv_owners *create_new_owners(struct kasan_owner_set *s)
+{
+	struct kasan_adv_owners *owners;
+	struct kasan_adv_owner *owner;
+	unsigned int nr = s->s_nr, i;
+
+	if (nr > KASAN_OWNER_MAX)
+		return ERR_PTR(-EINVAL);
+
+	owners = kmalloc(sizeof(struct kasan_adv_owners), GFP_KERNEL);
+	if (!owners)
+		return ERR_PTR(-ENOMEM);
+
+	owners->ao_nr = nr;
+	for (i = 0; i < nr; i++) {
+		owner = &owners->ao_owners[i];
+		if (!kallsyms_lookup_size_offset((unsigned long)s->s_ptrs[i],
+						 &owner->ao_end, NULL)) {
+			kfree(owners);
+			return ERR_PTR(-EINVAL);
+		}
+		owner->ao_start = (unsigned long)s->s_ptrs[i];
+		owner->ao_end += owner->ao_start;
+	}
+
+	return owners;
+}
+/* don't call this in irq/soft-irq context */
+int kasan_register_adv_check(unsigned int ac_type, void *p)
+{
+	struct kasan_adv_owners *owners;
+	struct kasan_adv_check *pck;
+	int ret;
+
+	if (ac_type >= __KASAN_ADVCHK_TYPE_COUNT)
+		return -EINVAL;
+
+	spin_lock(&kasan_adv_lock);
+	if (kasan_adv_nr_checks >= KASAN_CHECK_LOWMASK - 1) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	pck = &kasan_adv_checks[kasan_adv_nr_checks];
+	pck->ac_violation = false;
+	switch (ac_type) {
+	case	KASAN_ADVCHK_OWNER:
+		pck->ac_check_func = owner_check;
+		owners = create_new_owners((struct kasan_owner_set *)p);
+		if (IS_ERR(owners)) {
+			ret = PTR_ERR(owners);
+			goto out;
+		}
+		pck->ac_data = owners;
+		pck->ac_msg = "Non-owner write access violation";
+		break;
+	}
+
+	ret = ++kasan_adv_nr_checks;
+out:
+	spin_unlock(&kasan_adv_lock);
+	return ret;
+}
+EXPORT_SYMBOL(kasan_register_adv_check);
+
+/* Bind memory to check. The 'check' parameter should be the one returned
+ * by kasan_register_adv_check. The really bound start is aligned with
+ * KASAN_SHADOW_SCALE_SIZE. The real start is aligned higher if it's not
+ * exact on the boundary; the end is aligned lower if it's not exactly on the
+ * boundary - 1.
+ *
+ * return negative if error happened; 0 if fully marked and 1 if partially.
+ */
+int kasan_bind_adv_addr(void *addr, size_t size, u8 check)
+{
+	unsigned long r_start = round_up((unsigned long)addr,
+					 KASAN_SHADOW_SCALE_SIZE);
+	unsigned long r_end = round_down(((unsigned long)addr + size),
+					 KASAN_SHADOW_SCALE_SIZE) - 1;
+	u8 *shadow_start, *shadow_end;
+
+	if (unlikely(check >= KASAN_CHECK_LOWMASK - 1 || check == 0))
+		return -EINVAL;
+
+	if (r_end < r_start)
+		return -EINVAL;
+
+	shadow_start = (u8 *) kasan_mem_to_shadow((void *)r_start);
+	shadow_end = (u8 *) kasan_mem_to_shadow((void *)r_end);
+	check <<= KASAN_CHECK_SHIFT;
+	while (shadow_start <= shadow_end) {
+		*shadow_start |= check;
+		shadow_start++;
+	}
+
+	if ((void *)r_start == addr && (void *)r_end == (addr + size - 1))
+		return 0;
+	return 1;
+}
+EXPORT_SYMBOL(kasan_bind_adv_addr);
+
 /* we don't take lock kasan_adv_lock. Locking can either cause deadload
  * or kill the performance further.
  * We are still safe without lock since kasan_adv_nr_checks increases only.
-- 
2.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
