Message-ID: <46120254.9080205@yahoo.com.au>
Date: Tue, 03 Apr 2007 17:29:24 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [SLUB 1/2] SLUB core
References: <20070331193056.1800.68058.sendpatchset@schroedinger.engr.sgi.com> <20070331193102.1800.29162.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20070331193102.1800.29162.sendpatchset@schroedinger.engr.sgi.com>
Content-Type: multipart/mixed;
 boundary="------------030709000406090007070102"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, mpm@selenic.com, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------030709000406090007070102
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Christoph Lameter wrote:
> SLUB Core patch V6
> 
> This provides basic SLUB functionality and allows a choice of
> slab allocators during kernel configuration. The default is still
> slab. SLUB has been tested in various configurations but I think we
> can be quite sure that there are still remaining issues.
> 
> SLUB is not selectable on platforms that modify the page structs of
> slab memory (i386, FRV) but see the next patch for a i386 fix.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.21-rc5-mm3/include/linux/mm_types.h
> ===================================================================
> --- linux-2.6.21-rc5-mm3.orig/include/linux/mm_types.h	2007-03-30 21:50:18.000000000 -0700
> +++ linux-2.6.21-rc5-mm3/include/linux/mm_types.h	2007-03-30 21:50:42.000000000 -0700
> @@ -19,10 +19,16 @@ struct page {
>  	unsigned long flags;		/* Atomic flags, some possibly
>  					 * updated asynchronously */
>  	atomic_t _count;		/* Usage count, see below. */
> -	atomic_t _mapcount;		/* Count of ptes mapped in mms,
> +	union {
> +		atomic_t _mapcount;	/* Count of ptes mapped in mms,
>  					 * to show when page is mapped
>  					 * & limit reverse map searches.
>  					 */
> +		struct {	/* SLUB uses */
> +			short unsigned int inuse;
> +			short unsigned int offset;
> +		};
> +	};
>  	union {
>  	    struct {
>  		unsigned long private;		/* Mapping-private opaque data:
> @@ -43,8 +49,15 @@ struct page {
>  #if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
>  	    spinlock_t ptl;
>  #endif
> +	    struct {			/* SLUB uses */
> +		struct page *first_page;	/* Compound pages */
> +		struct kmem_cache *slab;	/* Pointer to slab */
> +	    };
> +	};
> +	union {
> +		pgoff_t index;		/* Our offset within mapping. */
> +		void *freelist;		/* SLUB: pointer to free object */
>  	};
> -	pgoff_t index;			/* Our offset within mapping. */
>  	struct list_head lru;		/* Pageout list, eg. active_list
>  					 * protected by zone->lru_lock !
>  					 */

I have an alternate suggestion for the struct page overloading issue.

I think anonymous unions are probably better than nothing, because they
make the .c code more readable, but they clutter up the header badly
and don't provide so strong type checking as we could implement.

This is just an incomplete RFC patch, because it actually requires a
fair amount of types in .c code to be changed if we are to implement it
(which I didn't want to do if nobody likes the idea).

(sorry it's an attachment, this mailer is broken)

-- 
SUSE Labs, Novell Inc.

--------------030709000406090007070102
Content-Type: text/plain;
 name="mm-multi-page.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-multi-page.patch"

Index: linux-2.6/include/linux/mm_types.h
===================================================================
--- linux-2.6.orig/include/linux/mm_types.h
+++ linux-2.6/include/linux/mm_types.h
@@ -23,27 +23,20 @@ struct page {
 					 * to show when page is mapped
 					 * & limit reverse map searches.
 					 */
-	union {
-	    struct {
-		unsigned long private;		/* Mapping-private opaque data:
-					 	 * usually used for buffer_heads
-						 * if PagePrivate set; used for
-						 * swp_entry_t if PageSwapCache;
-						 * indicates order in the buddy
-						 * system if PG_buddy is set.
-						 */
-		struct address_space *mapping;	/* If low bit clear, points to
-						 * inode address_space, or NULL.
-						 * If page mapped as anonymous
-						 * memory, low bit is set, and
-						 * it points to anon_vma object:
-						 * see PAGE_MAPPING_ANON below.
-						 */
-	    };
-#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
-	    spinlock_t ptl;
-#endif
-	};
+	unsigned long private;		/* Mapping-private opaque data:
+				 	 * usually used for buffer_heads
+					 * if PagePrivate set; used for
+					 * swp_entry_t if PageSwapCache;
+					 * indicates order in the buddy
+					 * system if PG_buddy is set.
+					 */
+	struct address_space *mapping;	/* If low bit clear, points to
+					 * inode address_space, or NULL.
+					 * If page mapped as anonymous
+					 * memory, low bit is set, and
+					 * it points to anon_vma object:
+					 * see PAGE_MAPPING_ANON below.
+					 */
 	pgoff_t index;			/* Our offset within mapping. */
 	struct list_head lru;		/* Pageout list, eg. active_list
 					 * protected by zone->lru_lock !
@@ -64,4 +57,45 @@ struct page {
 #endif /* WANT_PAGE_VIRTUAL */
 };
 
+/*
+ * We can provide alternate delcarations for 'struct page', instead of
+ * overloading fields that we would like to use for non-pagecache (eg.
+ * page tables or slab pages). However flags and _count must always be
+ * in the correct position, and not overloaded, because they might be
+ * accessed by thing without a direct reference (eg. buddy allocator,
+ * swsusp). So flags and _count get defined for us, and our struct is
+ * automatically padded out to the size of struct page. A compile time
+ * check ensures that this size isn't exceeded.
+ */
+#define DEFINE_PAGE_STRUCT(name)	\
+struct name {				\
+	union {				\
+		struct {		\
+			unsigned long flags; \
+			atomic_t _count; \
+			struct
+
+#define END_PAGE_STRUCT(name)		\
+			;		\
+		};			\
+		struct page ___page;	\
+	};				\
+};					\
+					\
+static inline void struct_##name##_build_bug_on(void) \
+{					\
+	BUILD_BUG_ON(sizeof(struct name) > sizeof(struct page)); \
+}
+
+DEFINE_PAGE_STRUCT(pt_page) {
+#if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
+	spinlock_t ptl;
+#endif
+} END_PAGE_STRUCT(pt_page)
+
+DEFINE_PAGE_STRUCT(buddy_page) {
+	unsigned int order;
+	struct list_head list;
+} END_PAGE_STRUCT(buddy_page)
+
 #endif /* _LINUX_MM_TYPES_H */
Index: linux-2.6/mm/slab.c
===================================================================
--- linux-2.6.orig/mm/slab.c
+++ linux-2.6/mm/slab.c
@@ -446,6 +446,11 @@ struct kmem_cache {
 #endif
 };
 
+DEFINE_PAGE_STRUCT(slab_page) {
+	struct list_head *cache;
+	struct list_head *slab;
+} END_PAGE_STRUCT(slab_page)
+
 #define CFLGS_OFF_SLAB		(0x80000000UL)
 #define	OFF_SLAB(x)	((x)->flags & CFLGS_OFF_SLAB)
 

--------------030709000406090007070102--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
