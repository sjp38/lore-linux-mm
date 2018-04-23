Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51B296B0010
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:55:52 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id r7-v6so8467916ith.5
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 05:55:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v82-v6sor6223329iod.116.2018.04.23.05.55.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 05:55:50 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 7/9] Pmalloc Rare Write: modify selected pools
Date: Mon, 23 Apr 2018 16:54:56 +0400
Message-Id: <20180423125458.5338-8-igor.stoppa@huawei.com>
In-Reply-To: <20180423125458.5338-1-igor.stoppa@huawei.com>
References: <20180423125458.5338-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, keescook@chromium.org, paul@paul-moore.com, sds@tycho.nsa.gov, mhocko@kernel.org, corbet@lwn.net
Cc: labbott@redhat.com, linux-cc=david@fromorbit.com, --cc=rppt@linux.vnet.ibm.com, --security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, igor.stoppa@gmail.com, Igor Stoppa <igor.stoppa@huawei.com>, Carlos Chinea Perez <carlos.chinea.perez@huawei.com>, Remi Denis Courmont <remi.denis.courmont@huawei.com>

While the vanilla version of pmalloc provides support for permanently
transitioning between writable and read-only of a memory pool, this
patch seeks to support a separate class of data, which would still
benefit from write protection, most of the time, but it still needs to
be modifiable. Maybe very seldom, but still cannot be permanently marked
as read-only.

The major changes are:
- extra parameter, at pool creation, to request modifiable memory
- pmalloc_rare_write function, to alter the value of modifiable allocations

The implementation tries to prevent attacks by reducing the aperture
available for modifying the memory, which is also mapped at a random
address, which is harder to retrieve, even in case of another core
racing with the one performing the modification.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
CC: Carlos Chinea Perez <carlos.chinea.perez@huawei.com>
CC: Remi Denis Courmont <remi.denis.courmont@huawei.com>
---
 Documentation/core-api/pmalloc.rst | 46 ++++++++++++++++----
 drivers/misc/lkdtm/perms.c         |  2 +-
 include/linux/pmalloc.h            | 24 ++++++++++-
 include/linux/vmalloc.h            |  3 +-
 mm/pmalloc.c                       | 88 +++++++++++++++++++++++++++++++++++++-
 mm/pmalloc_helpers.h               | 66 +++++++++++++++++++++++++---
 mm/test_pmalloc.c                  |  8 ++--
 7 files changed, 214 insertions(+), 23 deletions(-)

diff --git a/Documentation/core-api/pmalloc.rst b/Documentation/core-api/pmalloc.rst
index 27eb7b3eafc4..e0fa4a5462a9 100644
--- a/Documentation/core-api/pmalloc.rst
+++ b/Documentation/core-api/pmalloc.rst
@@ -10,8 +10,9 @@ Purpose
 
 The pmalloc library is meant to provide read-only status to data that,
 for some reason, could neither be declared as constant, nor could it take
-advantage of the qualifier __ro_after_init, but it is in spirit
-write-once/read-only.
+advantage of the qualifier __ro_after_init.
+But it is in spirit either fully write-once/read-only or at least
+write-seldom/mostly-read-only.
 At some point it might get teared down, however that doesn't affect how it
 is treated, while it's still relevant.
 Pmalloc protects data from both accidental and malicious overwrites.
@@ -57,6 +58,11 @@ When to use pmalloc
 - Pmalloc can be useful also when the amount of data to protect is not
   known at compile time and the memory can only be allocated dynamically.
 
+- When it's not possible to fix a point in time after which the data
+  becomes immutable, but it's still fairly unlikely that it will change,
+  rare write becomes a less vulnerable alternative to leaving the data
+  located in freely rewritable memory.
+
 - Finally, it can be useful also when it is desirable to control
   dynamically (for example throguh the kernel command line) if some
   specific data ought to be protected or not, without having to rebuild
@@ -70,11 +76,20 @@ When to use pmalloc
 When *not* to use pmalloc
 -------------------------
 
-Using pmalloc is not a good idea when optimizing TLB utilization is
-paramount: pmalloc relies on virtual memory areas and will therefore use
-more TLB entries. It still does a better job of it, compared to invoking
-vmalloc for each allocation, but it is undeniably less optimized wrt to
-TLB use than using the physmap directly, through kmalloc or similar.
+Using pmalloc is not a good idea in some cases:
+
+- when optimizing TLB utilization is paramount:
+  pmalloc relies on virtual memory areas and will therefore use more
+  tlb entries. It still does a better job of it, compared to invoking
+  vmalloc for each allocation, but it is undeniably less optimized wrt to
+  TLB use than using the physmap directly, through kmalloc or similar.
+
+- when rare-write is not-so-rare:
+  rare-write does not allow updates in-place, it rather expects to be
+  provided a version of how the data is supposed to be, and then it
+  performs the update accordingly, by modifying the original data.
+  Such procedure takes an amount of time that is proportional to the
+  number of pages affected.
 
 
 Caveats
@@ -112,6 +127,15 @@ Caveats
   But the allocation can take place during init, and its address is known
   and constant.
 
+- The users of rare write must take care of ensuring the atomicity of the
+  action, respect to the way they use the data being altered; for example,
+  take a lock before making a copy of the value to modify (if it's
+  relevant), then alter it, issue the call to rare write and finally
+  release the lock. Some special scenario might be exempt from the need
+  for locking, but in general rare-write must be treated as an operation
+  that can incur into races.
+
+
 
 Utilization
 -----------
@@ -122,7 +146,7 @@ Steps to perforn during init:
 
 #. create an "anchor", with the modifier __ro_after_init
 
-#. create a pool
+#. create a pool, choosing if it can be altered or not, after protection
 
    :c:func:`pmalloc_create_pool`
 
@@ -147,7 +171,11 @@ init, as long as they strictly come after the previous sequence.
 
    :c::func:`pmalloc_protect_pool`
 
-#. iterate over the last 2 points as needed
+#. [optional] modify the pool, if it was created as rewritable
+
+   :c::func:`pmalloc_rare_write`
+
+#. iterate over the last 3 points as needed
 
 #. [optional] destroy the pool
 
diff --git a/drivers/misc/lkdtm/perms.c b/drivers/misc/lkdtm/perms.c
index 3c81e59f9d9d..6dfab1fbc313 100644
--- a/drivers/misc/lkdtm/perms.c
+++ b/drivers/misc/lkdtm/perms.c
@@ -111,7 +111,7 @@ void lkdtm_WRITE_RO_PMALLOC(void)
 	struct pmalloc_pool *pool;
 	int *i;
 
-	pool = pmalloc_create_pool();
+	pool = pmalloc_create_pool(PMALLOC_RO);
 	if (WARN(!pool, "Failed preparing pool for pmalloc test."))
 		return;
 
diff --git a/include/linux/pmalloc.h b/include/linux/pmalloc.h
index eebaf1ebc6f3..0aab95074aa8 100644
--- a/include/linux/pmalloc.h
+++ b/include/linux/pmalloc.h
@@ -23,17 +23,33 @@
  * be destroyed.
  * Upon destruction of a certain pool, all the related memory is released,
  * including its metadata.
+ *
+ * Depending on the type of protection that was chosen, the memory can be
+ * either completely read-only or it can support rare-writes.
+ *
+ * The rare-write mechanism is intended to provide no read overhead and
+ * still some form of protection, while a selected area is modified.
+ * This will incur into a penalty that is partially depending on the
+ * specific architecture, but in general is the price to pay for limiting
+ * the attack surface, while the change takes place.
+ *
+ * For additional safety, it is not possible to have in the same pool both
+ * rare-write and unmodifiable memory.
  */
 
 
 #define PMALLOC_REFILL_DEFAULT (0)
 #define PMALLOC_ALIGN_DEFAULT ARCH_KMALLOC_MINALIGN
+#define PMALLOC_RO 0
+#define PMALLOC_RW 1
 
 struct pmalloc_pool *pmalloc_create_custom_pool(size_t refill,
+						bool rewritable,
 						unsigned short align_order);
 
 /**
  * pmalloc_create_pool() - create a protectable memory pool
+ * @rewritable: can the data be altered after protection
  *
  * Shorthand for pmalloc_create_custom_pool() with default argument:
  * * refill is set to PMALLOC_REFILL_DEFAULT
@@ -43,9 +59,10 @@ struct pmalloc_pool *pmalloc_create_custom_pool(size_t refill,
  * * pointer to the new pool	- success
  * * NULL			- error
  */
-static inline struct pmalloc_pool *pmalloc_create_pool(void)
+static inline struct pmalloc_pool *pmalloc_create_pool(bool rewritable)
 {
 	return pmalloc_create_custom_pool(PMALLOC_REFILL_DEFAULT,
+					  rewritable,
 					  PMALLOC_ALIGN_DEFAULT);
 }
 
@@ -142,7 +159,12 @@ static inline char *pstrdup(struct pmalloc_pool *pool, const char *s)
 	return buf;
 }
 
+bool pmalloc_rare_write(struct pmalloc_pool *pool, const void *destination,
+			const void *source, size_t n_bytes);
+
 void pmalloc_protect_pool(struct pmalloc_pool *pool);
 
+void pmalloc_make_pool_ro(struct pmalloc_pool *pool);
+
 void pmalloc_destroy_pool(struct pmalloc_pool *pool);
 #endif
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 69c12f21200f..d0b747a78271 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -21,7 +21,8 @@ struct notifier_block;		/* in notifier.h */
 #define VM_NO_GUARD		0x00000040      /* don't add guard page */
 #define VM_KASAN		0x00000080      /* has allocated kasan shadow memory */
 #define VM_PMALLOC		0x00000100	/* pmalloc area - see docs */
-#define VM_PMALLOC_PROTECTED	0x00000200	/* protected area - see docs */
+#define VM_PMALLOC_REWRITABLE	0x00000200	/* pmalloc rewritable area */
+#define VM_PMALLOC_PROTECTED	0x00000400	/* pmalloc protected area */
 /* bits [20..32] reserved for arch specific ioremap internals */
 
 /*
diff --git a/mm/pmalloc.c b/mm/pmalloc.c
index ddaef41837f4..ca7f10b50b25 100644
--- a/mm/pmalloc.c
+++ b/mm/pmalloc.c
@@ -34,6 +34,7 @@ static DEFINE_MUTEX(pools_mutex);
  * @refill: the minimum size to allocate when in need of more memory.
  *          It will be rounded up to a multiple of PAGE_SIZE
  *          The value of 0 gives the default amount of PAGE_SIZE.
+ * @rewritable: can the data be altered after protection
  * @align_order: log2 of the alignment to use when allocating memory
  *               Negative values give ARCH_KMALLOC_MINALIGN
  *
@@ -45,6 +46,7 @@ static DEFINE_MUTEX(pools_mutex);
  * * NULL			- error
  */
 struct pmalloc_pool *pmalloc_create_custom_pool(size_t refill,
+						bool rewritable,
 						unsigned short align_order)
 {
 	struct pmalloc_pool *pool;
@@ -54,6 +56,7 @@ struct pmalloc_pool *pmalloc_create_custom_pool(size_t refill,
 		return NULL;
 
 	pool->refill = refill ? PAGE_ALIGN(refill) : DEFAULT_REFILL_SIZE;
+	pool->rewritable = rewritable;
 	pool->align = 1UL << align_order;
 	mutex_init(&pool->mutex);
 
@@ -77,7 +80,7 @@ static int grow(struct pmalloc_pool *pool, size_t min_size)
 		return -ENOMEM;
 
 	area = find_vmap_area((unsigned long)addr);
-	tag_area(area);
+	tag_area(area, pool->rewritable);
 	pool->offset = get_area_pages_size(area);
 	llist_add(&area->area_list, &pool->vm_areas);
 	return 0;
@@ -144,6 +147,88 @@ void pmalloc_protect_pool(struct pmalloc_pool *pool)
 }
 EXPORT_SYMBOL(pmalloc_protect_pool);
 
+static inline bool rare_write(const void *destination,
+			      const void *source, size_t n_bytes)
+{
+	struct page *page;
+	void *base;
+	size_t size;
+	unsigned long offset;
+
+	while (n_bytes) {
+		page = vmalloc_to_page(destination);
+		base = vmap(&page, 1, VM_MAP, PAGE_KERNEL);
+		if (WARN(!base, "failed to remap rewritable page"))
+			return false;
+		offset = (unsigned long)destination & ~PAGE_MASK;
+		size = min(n_bytes, (size_t)PAGE_SIZE - offset);
+		memcpy(base + offset, source, size);
+		vunmap(base);
+		destination += size;
+		source += size;
+		n_bytes -= size;
+	}
+}
+
+/**
+ * pmalloc_rare_write() - alters the content of a rewritable pool
+ * @pool: the pool associated to the memory to write-protect
+ * @destination: where to write the new data
+ * @source: the location of the data to replicate into the pool
+ * @n_bytes: the size of the region to modify
+ *
+ * Return:
+ * * true	- success
+ * * false	- error
+ */
+bool pmalloc_rare_write(struct pmalloc_pool *pool, const void *destination,
+			const void *source, size_t n_bytes)
+{
+	bool retval = false;
+	struct vmap_area *area;
+
+	/*
+	 * The following sanitation is meant to make life harder for
+	 * attempts at using ROP/JOP to call this function against pools
+	 * that are not supposed to be modifiable.
+	 */
+	mutex_lock(&pool->mutex);
+	if (WARN(pool->rewritable != PMALLOC_RW,
+		 "Attempting to modify non rewritable pool"))
+		goto out;
+	area = pool_get_area(pool, destination, n_bytes);
+	if (WARN(!area, "Destination range not in pool"))
+		goto out;
+	if (WARN(!is_area_rewritable(area),
+		 "Attempting to modify non rewritable area"))
+		goto out;
+	rare_write(destination, source, n_bytes);
+	retval = true;
+out:
+	mutex_unlock(&pool->mutex);
+	return retval;
+}
+EXPORT_SYMBOL(pmalloc_rare_write);
+
+/**
+ * pmalloc_make_pool_ro() - drops rare-write permission from a pool
+ * @pool: the pool associated to the memory to make ro
+ *
+ * Drops the possibility to perform controlled writes from both the pool
+ * metadata and all the vm_area structures associated to the pool.
+ */
+void pmalloc_make_pool_ro(struct pmalloc_pool *pool)
+{
+	struct vmap_area *area;
+
+	mutex_lock(&pool->mutex);
+	pool->rewritable = false;
+	llist_for_each_entry(area, pool->vm_areas.first, area_list)
+		protect_area(area);
+	mutex_unlock(&pool->mutex);
+}
+EXPORT_SYMBOL(pmalloc_make_pool_ro);
+
 /**
  * pmalloc_destroy_pool() - destroys a pool and all the associated memory
  * @pool: the pool to destroy
@@ -171,4 +256,3 @@ void pmalloc_destroy_pool(struct pmalloc_pool *pool)
 	}
 }
 EXPORT_SYMBOL(pmalloc_destroy_pool);
-
diff --git a/mm/pmalloc_helpers.h b/mm/pmalloc_helpers.h
index 52d4d899e173..538e37564f8f 100644
--- a/mm/pmalloc_helpers.h
+++ b/mm/pmalloc_helpers.h
@@ -26,19 +26,28 @@ struct pmalloc_pool {
 	size_t refill;
 	size_t offset;
 	size_t align;
+	bool rewritable;
 };
 
 #define VM_PMALLOC_PROTECTED_MASK (VM_PMALLOC | VM_PMALLOC_PROTECTED)
-#define VM_PMALLOC_MASK (VM_PMALLOC | VM_PMALLOC_PROTECTED)
+#define VM_PMALLOC_REWRITABLE_MASK \
+	(VM_PMALLOC | VM_PMALLOC_REWRITABLE)
+#define VM_PMALLOC_PROTECTED_REWRITABLE_MASK \
+	(VM_PMALLOC | VM_PMALLOC_REWRITABLE | VM_PMALLOC_PROTECTED)
+#define VM_PMALLOC_MASK \
+	(VM_PMALLOC | VM_PMALLOC_REWRITABLE | VM_PMALLOC_PROTECTED)
 
 static __always_inline unsigned long area_flags(struct vmap_area *area)
 {
 	return area->vm->flags & VM_PMALLOC_MASK;
 }
 
-static __always_inline void tag_area(struct vmap_area *area)
+static __always_inline void tag_area(struct vmap_area *area, bool rewritable)
 {
-	area->vm->flags |= VM_PMALLOC;
+	if (rewritable == PMALLOC_RW)
+		area->vm->flags |= VM_PMALLOC_REWRITABLE_MASK;
+	else
+		area->vm->flags |= VM_PMALLOC;
 }
 
 static __always_inline void untag_area(struct vmap_area *area)
@@ -52,10 +61,20 @@ static __always_inline struct vmap_area *current_area(struct pmalloc_pool *pool)
 			   area_list);
 }
 
+static __always_inline bool area_matches_mask(struct vmap_area *area,
+					      unsigned long mask)
+{
+	return (area->vm->flags & mask) == mask;
+}
+
 static __always_inline bool is_area_protected(struct vmap_area *area)
 {
-	return (area->vm->flags & VM_PMALLOC_PROTECTED_MASK) ==
-	       VM_PMALLOC_PROTECTED_MASK;
+	return area_matches_mask(area, VM_PMALLOC_PROTECTED_MASK);
+}
+
+static __always_inline bool is_area_rewritable(struct vmap_area *area)
+{
+	return area_matches_mask(area, VM_PMALLOC_REWRITABLE_MASK);
 }
 
 static __always_inline void protect_area(struct vmap_area *area)
@@ -66,6 +85,12 @@ static __always_inline void protect_area(struct vmap_area *area)
 	area->vm->flags |= VM_PMALLOC_PROTECTED_MASK;
 }
 
+static __always_inline void make_area_ro(struct vmap_area *area)
+{
+	area->vm->flags &= ~VM_PMALLOC_REWRITABLE;
+	protect_area(area);
+}
+
 static __always_inline void unprotect_area(struct vmap_area *area)
 {
 	if (likely(is_area_protected(area)))
@@ -150,5 +175,36 @@ static inline void check_pmalloc_object(const void *ptr, unsigned long n,
 	}
 }
 
+static __always_inline size_t get_area_pages_end(struct vmap_area *area)
+{
+	return area->va_start + get_area_pages_size(area);
+}
+
+static __always_inline bool area_contains_range(struct vmap_area *area,
+						const void *addr,
+						size_t n_bytes)
+{
+	size_t area_end = get_area_pages_end(area);
+	size_t range_start = (size_t)addr;
+	size_t range_end = range_start + n_bytes;
+
+	return (area->va_start <= range_start) &&
+	       (range_start < area_end) &&
+	       (area->va_start <= range_end) &&
+	       (range_end <= area_end);
+}
+
+static __always_inline
+struct vmap_area *pool_get_area(struct pmalloc_pool *pool,
+				const void *addr, size_t n_bytes)
+{
+	struct vmap_area *area;
+
+	llist_for_each_entry(area, pool->vm_areas.first, area_list)
+		if (area_contains_range(area, addr,  n_bytes))
+			return area;
+	return NULL;
+}
+
 #endif
 #endif
diff --git a/mm/test_pmalloc.c b/mm/test_pmalloc.c
index 032e9741c5f1..c8835207a400 100644
--- a/mm/test_pmalloc.c
+++ b/mm/test_pmalloc.c
@@ -43,7 +43,7 @@ static bool create_and_destroy_pool(void)
 
 	pr_notice("Testing pool creation and destruction capability");
 
-	pool = pmalloc_create_pool();
+	pool = pmalloc_create_pool(PMALLOC_RO);
 	if (WARN(!pool, "Cannot allocate memory for pmalloc selftest."))
 		return false;
 	pmalloc_destroy_pool(pool);
@@ -58,7 +58,7 @@ static bool test_alloc(void)
 	static void *p;
 
 	pr_notice("Testing allocation capability");
-	pool = pmalloc_create_pool();
+	pool = pmalloc_create_pool(PMALLOC_RO);
 	if (WARN(!pool, "Unable to allocate memory for pmalloc selftest."))
 		return false;
 	p = pmalloc(pool,  SIZE_1 - 1);
@@ -84,7 +84,7 @@ static bool test_is_pmalloc_object(void)
 	if (WARN(!vmalloc_p,
 		 "Unable to allocate memory for pmalloc selftest."))
 		return false;
-	pool = pmalloc_create_pool();
+	pool = pmalloc_create_pool(PMALLOC_RO);
 	if (WARN(!pool, "Unable to allocate memory for pmalloc selftest."))
 		return false;
 	pmalloc_p = pmalloc(pool,  SIZE_1 - 1);
@@ -111,7 +111,7 @@ static void test_oovm(void)
 	unsigned int i;
 
 	pr_notice("Exhaust vmalloc memory with doubling allocations.");
-	pool = pmalloc_create_pool();
+	pool = pmalloc_create_pool(PMALLOC_RO);
 	if (WARN(!pool, "Failed to create pool"))
 		return;
 	for (i = 1; i; i *= 2)
-- 
2.14.1
