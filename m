Date: Wed, 26 Apr 2000 06:11:15 -0700
Message-Id: <200004261311.GAA13838@pizda.ninka.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <20000426140031.L3792@redhat.com> (sct@redhat.com)
Subject: Re: [PATCH] 2.3.99-pre6-3+  VM rebalancing
References: <Pine.LNX.4.21.0004251757360.9768-100000@alpha.random> <Pine.LNX.4.21.0004251418520.10408-100000@duckman.conectiva> <20000425113616.A7176@stormix.com> <3905EB26.8DBFD111@mandrakesoft.com> <20000425120657.B7176@stormix.com> <20000426120130.E3792@redhat.com> <200004261125.EAA12302@pizda.ninka.net> <20000426140031.L3792@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sct@redhat.com
Cc: sim@stormix.com, jgarzik@mandrakesoft.com, riel@nl.linux.org, andrea@suse.de, linux-mm@kvack.org, bcrl@redhat.com, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

   Doing it isn't the problem.  Doing it efficiently is, if you have 
   fork() and mremap() in the picture.  With mremap(), you cannot assume
   that the virtual address of an anonymous page is the same in all
   processes which have the page mapped.

Who makes that assumption?  The virtual address of a physical page
is:

	(page->index - vma->vm_pgoff) << PAGE_SHIFT

Add that to vma->vm_start and if the resulting value is not
>= vma->vm_end, then you have the proper virtual address, always.

   So, basically, to find all the ptes for a given page, you have to
   walk every single vma in every single mm which is a fork()ed 
   ancestor or descendent of the mm whose address_space you indexed
   the page against.

If you implement things correctly, this is not true at all.

   Detecting the right vma isn't hard, because the vma's vm_pgoff is
   preserved over mremap().  It's the linear scan that is the danger.

In my implementation there is no linear scan, only VMA's which
can actually contain the anonymous page in question are scanned.

It's called an anonymous layer, and it provides pseudo backing objects
for VMA's which have at least one privatized anonymous page.  Each
such object is no more than a reference count, and an address_space
struct.  The anonymous pages are queued into the address_space page
list, and have their page->index fields set appropriately.

When VMA's move around, get duplicated in fork'd processes, etc.
the anon layer gets called and adjusts things appropriately.

Instead of talk, I'll show some code :-)  The following is the
anon layer I implemented for 2.3.x in my hacks.

--- ./mm/anon.c.~1~	Tue Apr 25 00:39:55 2000
+++ ./mm/anon.c	Tue Apr 25 07:08:28 2000
@@ -0,0 +1,370 @@
+/*
+ *	linux/mm/anon.c
+ *
+ * Written by DaveM.
+ */
+
+#include <linux/kernel.h>
+#include <linux/sched.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/fs.h>
+#include <linux/swap.h>
+#include <linux/pagemap.h>
+#include <linux/spinlock.h>
+#include <linux/highmem.h>
+
+/* The anon layer provides a virtual backing object for anonymous
+ * private pages.  The anon objects hang off of vmas and are created
+ * at the first cow fault into a private mapping.
+ *
+ * The anon address space is just like the page cache, it holds a
+ * reference to each of the pages attached to it.
+ */
+
+/* The layout of this structure is completely private to the
+ * anon layer.  There is no reason to export it so we don't.
+ */
+struct anon_area {
+	atomic_t		count;
+	struct address_space	mapping;
+};
+
+extern spinlock_t pagecache_lock;
+static kmem_cache_t *anon_cachep = NULL;
+
+static __inline__ void anon_insert_vma(struct vm_area_struct *vma,
+				       struct anon_area *anon)
+{
+	struct address_space *mapping = &anon->mapping;
+	struct vm_area_struct *next;
+
+	spin_lock(&mapping->i_shared_lock);
+	next = mapping->i_mmap;
+	if ((vma->vm_anon_next_share = next) != NULL)
+		next->vm_anon_pprev_share = &vma->vm_anon_next_share;
+	mapping->i_mmap = vma;
+	vma->vm_anon_pprev_share = &mapping->i_mmap;
+	spin_unlock(&mapping->i_shared_lock);
+}
+
+static __inline__ void anon_remove_vma(struct vm_area_struct *vma,
+				       struct anon_area *anon)
+{
+	struct address_space *mapping = &anon->mapping;
+	struct vm_area_struct *next;
+
+	spin_lock(&mapping->i_shared_lock);
+	next = vma->vm_anon_next_share;
+	if (next)
+		next->vm_anon_pprev_share = vma->vm_anon_pprev_share;
+	*(vma->vm_anon_pprev_share) = next;
+	spin_unlock(&mapping->i_shared_lock);
+}
+
+/* Attach VMA's anon_area to NEW_VMA */
+void anon_dup(struct vm_area_struct *vma, struct vm_area_struct *new_vma)
+{
+	struct anon_area *anon = vma->vm_anon;
+
+	if (anon == NULL)
+		BUG();
+
+	atomic_inc(&anon->count);
+	anon_insert_vma(new_vma, anon);
+	new_vma->vm_anon = anon;
+}
+
+/* Free up all the pages assosciated with ANON. */
+static void invalidate_anon_pages(struct anon_area *anon)
+{
+	spin_lock(&pagecache_lock);
+
+	for (;;) {
+		struct list_head *entry = anon->mapping.pages.next;
+		struct page *page;
+
+		if (entry == &anon->mapping.pages)
+			break;
+
+		page = list_entry(entry, struct page, list);
+
+		get_page(page);
+		if (TryLockPage(page)) {
+			spin_unlock(&pagecache_lock);
+			lock_page(page);
+			spin_lock(&pagecache_lock);
+		}
+
+		if (PageSwapCache(page)) {
+			spin_unlock(&pagecache_lock);
+			__delete_from_swap_cache(page);
+			spin_lock(&pagecache_lock);
+		}
+
+		put_page(page);
+
+		lru_cache_del(page);
+
+		list_del(&page->list);
+		anon->mapping.nrpages--;
+		ClearPageAnon(page);
+		page->mapping = NULL;
+		UnlockPage(page);
+
+		__free_page(page);
+	}
+
+	spin_unlock(&pagecache_lock);
+
+	if (anon->mapping.nrpages != 0)
+		BUG();
+}
+
+/* VMA has been resized in some way, or one of the anon_area owners
+ * has gone away.  Trim the anonymous pages from the anon_area which
+ * have a reference count of one.  These pages are no longer
+ * referenced validly by any VMA and thus can be safely disposed.
+ *
+ * This is actually an optimization of sorts, we could just
+ * ignore this situation and let the eventual final anon_put
+ * get rid of the pages.
+ *
+ * It is the callers responsibility to unmap and free the
+ * pages from the address space of the process before invoking
+ * this.  It cannot work otherwise.
+ */
+void anon_trim(struct vm_area_struct *vma)
+{
+	struct anon_area *anon = vma->vm_anon;
+	struct list_head *entry;
+
+	spin_lock(&pagecache_lock);
+
+	entry = anon->mapping.pages.next;
+	while (entry != &anon->mapping.pages) {
+		struct page *page = list_entry(entry, struct page, list);
+		struct list_head *next = entry->next;
+
+		entry = next;
+
+		if (page_count(page) != 1)
+			continue;
+
+		if (TryLockPage(page))
+			continue;
+
+		lru_cache_del(page);
+
+		list_del(&page->list);
+		anon->mapping.nrpages--;
+		ClearPageAnon(page);
+		page->mapping = NULL;
+		UnlockPage(page);
+
+		__free_page(page);
+	}
+
+	spin_unlock(&pagecache_lock);
+}
+
+/* Disassosciate VMA with the vm_anon attached to it. */
+void anon_put(struct vm_area_struct *vma)
+{
+	struct anon_area *anon = vma->vm_anon;
+
+	if (anon == NULL)
+		BUG();
+	if (atomic_read(&anon->count) < 1)
+		BUG();
+
+	anon_remove_vma(vma, anon);
+
+	if (atomic_dec_and_test(&anon->count)) {
+		if (anon->mapping.i_mmap != NULL)
+			BUG();
+		invalidate_anon_pages(anon);
+		kmem_cache_free(anon_cachep, anon);
+	} else
+		anon_trim(vma);
+
+	vma->vm_anon = NULL;
+}
+
+
+/* Forcibly delete an anon_area page.  This also kills the
+ * original reference made by anon_cow.
+ */
+void anon_page_kill(struct page *page)
+{
+	spin_lock(&pagecache_lock);
+
+	if (TryLockPage(page)) {
+		spin_unlock(&pagecache_lock);
+
+		lock_page(page);
+
+		spin_lock(&pagecache_lock);
+	}
+
+	lru_cache_del(page);
+
+	page->mapping->nrpages--;
+	list_del(&page->list);
+	ClearPageAnon(page);
+	page->mapping = NULL;
+	UnlockPage(page);
+
+	put_page(page);
+	__free_page(page);
+
+	spin_unlock(&pagecache_lock);
+}
+
+static int anon_try_to_free_page(struct page *page)
+{
+	int ret = 0;
+
+	if (page_count(page) <= 1)
+		BUG();
+	if (!PageLocked(page))
+		BUG();
+
+	spin_lock(&pagecache_lock);
+	if (PageSwapCache(page)) {
+		spin_unlock(&pagecache_lock);
+		__delete_from_swap_cache(page);
+		spin_lock(&pagecache_lock);
+	}
+	if (page_count(page) == 2) {
+		struct address_space *mapping = page->mapping;
+
+		mapping->nrpages--;
+		list_del(&page->list);
+
+		ClearPageAnon(page);
+		page->mapping = NULL;
+		ret = 1;
+	}
+	spin_unlock(&pagecache_lock);
+
+	if (ret == 1)
+		__free_page(page);
+
+	return ret;
+}
+
+struct address_space_operations anon_address_space_operations = {
+	try_to_free_page:	anon_try_to_free_page
+};
+
+/* SLAB constructor for anon_area structs. */
+static void anon_ctor(void *__p, kmem_cache_t *cache, unsigned long flags)
+{
+	struct anon_area *anon = __p;
+	struct address_space *mapping = &anon->mapping;
+
+	INIT_LIST_HEAD(&mapping->pages);
+	mapping->nrpages = 0;
+	mapping->a_ops = &anon_address_space_operations;
+	mapping->host = anon;
+	spin_lock_init(&mapping->i_shared_lock);
+}
+
+/* Create a new anon_area, and attach it to VMA. */
+static struct anon_area *anon_alloc(struct vm_area_struct *vma)
+{
+	struct anon_area *anon = kmem_cache_alloc(anon_cachep, GFP_KERNEL);
+
+	if (anon) {
+		struct address_space *mapping = &anon->mapping;
+
+		atomic_set(&anon->count, 1);
+		mapping->i_mmap = vma;
+		vma->vm_anon = anon;
+		vma->vm_anon_next_share = NULL;
+		vma->vm_anon_pprev_share = &mapping->i_mmap;
+	}
+
+	return anon;
+}
+
+static void anon_page_insert(struct vm_area_struct *vma, unsigned long address, struct address_space *mapping, struct page *page)
+{
+	page->index = ((address - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+
+	get_page(page);
+
+	spin_lock(&pagecache_lock);
+	SetPageAnon(page);
+	mapping->nrpages++;
+	list_add(&page->list, &mapping->pages);
+	page->mapping = mapping;
+	spin_unlock(&pagecache_lock);
+
+	lru_cache_add(page);
+}
+
+static __inline__ struct anon_area *get_anon(struct vm_area_struct *vma)
+{
+	struct anon_area *anon = vma->vm_anon;
+
+	if (anon == NULL)
+		anon = anon_alloc(vma);
+
+	return anon;
+}
+
+int anon_page_add(struct vm_area_struct *vma, unsigned long address, struct page *page)
+{
+	struct anon_area *anon = get_anon(vma);
+
+	if (anon) {
+		anon_page_insert(vma, address, &anon->mapping, page);
+		return 0;
+	}
+
+	return -1;
+}
+
+/*
+ * We special-case the C-O-W ZERO_PAGE, because it's such
+ * a common occurrence (no need to read the page to know
+ * that it's zero - better for the cache and memory subsystem).
+ */
+static inline void copy_cow_page(struct page * from, struct page * to, unsigned long address)
+{
+	if (from == ZERO_PAGE(address)) {
+		clear_user_highpage(to, address);
+		return;
+	}
+	copy_user_highpage(to, from, address);
+}
+
+struct page *anon_cow(struct vm_area_struct *vma, unsigned long address, struct page *orig_page)
+{
+	struct anon_area *anon = get_anon(vma);
+
+	if (anon) {
+		struct page *new_page = alloc_page(GFP_HIGHUSER);
+
+		if (new_page) {
+			copy_cow_page(orig_page, new_page, address);
+			anon_page_insert(vma, address, &anon->mapping, new_page);
+		}
+
+		return new_page;
+	}
+
+	return NULL;
+}
+
+void anon_init(void)
+{
+	anon_cachep = kmem_cache_create("anon_area",
+					sizeof(struct anon_area),
+					0, SLAB_HWCACHE_ALIGN,
+					anon_ctor, NULL);
+	if (!anon_cachep)
+		panic("anon_init: Cannot alloc anon_area cache.");
+}
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
