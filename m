Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7B0D76B00AD
	for <linux-mm@kvack.org>; Sun, 10 May 2009 10:46:51 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [RFC][PATCH 5/6] PM/Hibernate: Do not release preallocated memory unnecessarily
Date: Sun, 10 May 2009 15:57:47 +0200
References: <200905070040.08561.rjw@sisk.pl> <200905072348.59856.rjw@sisk.pl> <200905101548.57557.rjw@sisk.pl>
In-Reply-To: <200905101548.57557.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905101557.48624.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: pm list <linux-pm@lists.linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

Since the hibernation code is now going to use allocations of memory
to make enough room for the image, it can also use the page frames
allocated at this stage as image page frames.  The low-level
hibernation code needs to be rearranged for this purpose, but it
allows us to avoid freeing a great number of pages and allocating
these same pages once again later, so it generally is worth doing.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 kernel/power/disk.c     |   15 ++-
 kernel/power/power.h    |    2 
 kernel/power/snapshot.c |  186 ++++++++++++++++++++++++++++++------------------
 3 files changed, 130 insertions(+), 73 deletions(-)

Index: linux-2.6/kernel/power/snapshot.c
===================================================================
--- linux-2.6.orig/kernel/power/snapshot.c
+++ linux-2.6/kernel/power/snapshot.c
@@ -1033,6 +1033,25 @@ copy_data_pages(struct memory_bitmap *co
 static unsigned int nr_copy_pages;
 /* Number of pages needed for saving the original pfns of the image pages */
 static unsigned int nr_meta_pages;
+/*
+ * Numbers of normal and highmem page frames allocated for hibernation image
+ * before suspending devices.
+ */
+unsigned int alloc_normal, alloc_highmem;
+/*
+ * Memory bitmap used for marking saveable pages (during hibernation) or
+ * hibernation image pages (during restore)
+ */
+static struct memory_bitmap orig_bm;
+/*
+ * Memory bitmap used during hibernation for marking allocated page frames that
+ * will contain copies of saveable pages.  During restore it is initially used
+ * for marking hibernation image pages, but then the set bits from it are
+ * duplicated in @orig_bm and it is released.  On highmem systems it is next
+ * used for marking "safe" highmem pages, but it has to be reinitialized for
+ * this purpose.
+ */
+static struct memory_bitmap copy_bm;
 
 /**
  *	swsusp_free - free pages allocated for the suspend.
@@ -1064,6 +1083,8 @@ void swsusp_free(void)
 	nr_meta_pages = 0;
 	restore_pblist = NULL;
 	buffer = NULL;
+	alloc_normal = 0;
+	alloc_highmem = 0;
 }
 
 /* Helper functions used for the shrinking of memory. */
@@ -1082,8 +1103,16 @@ static unsigned long preallocate_image_p
 	unsigned long nr_alloc = 0;
 
 	while (nr_pages > 0) {
-		if (!alloc_image_page(mask))
-			break;
+ 		struct page *page;
+
+		page = alloc_image_page(mask);
+ 		if (!page)
+ 			break;
+		memory_bm_set_bit(&copy_bm, page_to_pfn(page));
+		if (PageHighMem(page))
+			alloc_highmem++;
+		else
+			alloc_normal++;
 		nr_pages--;
 		nr_alloc++;
 	}
@@ -1142,7 +1171,30 @@ static inline unsigned long highmem_frac
 #endif /* CONFIG_HIGHMEM */
 
 /**
- * swsusp_shrink_memory -  Make the kernel release as much memory as needed
+ * free_unnecessary_pages - Release preallocated pages not needed for the image
+ * @size: Anticipated hibernation image size
+ */
+static void free_unnecessary_pages(unsigned long size)
+{
+	memory_bm_position_reset(&copy_bm);
+
+	while (alloc_normal + alloc_highmem > size) {
+		unsigned long pfn = memory_bm_next_pfn(&copy_bm);
+		struct page *page = pfn_to_page(pfn);
+
+		memory_bm_clear_bit(&copy_bm, pfn);
+		if (PageHighMem(page))
+			alloc_highmem--;
+		else
+			alloc_normal--;
+		swsusp_unset_page_forbidden(page);
+		swsusp_unset_page_free(page);
+		__free_page(page);
+	}
+}
+
+/**
+ * hibernate_preallocate_memory - Preallocate memory for hibernation image
  *
  * To create a hibernation image it is necessary to make a copy of every page
  * frame in use.  We also need a number of page frames to be free during
@@ -1161,19 +1213,30 @@ static inline unsigned long highmem_frac
  * frames in use is below the requested image size or it is impossible to
  * allocate more memory, whichever happens first.
  */
-int swsusp_shrink_memory(void)
+int hibernate_preallocate_memory(void)
 {
 	struct zone *zone;
 	unsigned long saveable, size, max_size, count, highmem, pages = 0;
-	unsigned long alloc, pages_highmem;
+	unsigned long alloc, save_highmem, pages_highmem;
 	struct timeval start, stop;
-	int error = 0;
+	int error;
 
-	printk(KERN_INFO "PM: Shrinking memory... ");
+	printk(KERN_INFO "PM: Preallocating image memory... ");
 	do_gettimeofday(&start);
 
+	error = memory_bm_create(&orig_bm, GFP_IMAGE, PG_ANY);
+	if (error)
+		goto err_out;
+
+	error = memory_bm_create(&copy_bm, GFP_IMAGE, PG_ANY);
+	if (error)
+		goto err_out;
+
+	alloc_normal = 0;
+	alloc_highmem = 0;
+
 	/* Count the number of saveable data pages. */
-	highmem = count_highmem_pages();
+	save_highmem = count_highmem_pages();
 	saveable = count_data_pages();
 
 	/*
@@ -1181,7 +1244,8 @@ int swsusp_shrink_memory(void)
 	 * number of pages needed for image metadata (size).
 	 */
 	count = saveable;
-	saveable += highmem;
+	saveable += save_highmem;
+	highmem = save_highmem;
 	size = 0;
 	for_each_populated_zone(zone) {
 		size += snapshot_additional_pages(zone);
@@ -1201,10 +1265,13 @@ int swsusp_shrink_memory(void)
 		size = max_size;
 	/*
 	 * If the maximum is not less than the current number of saveable pages
-	 * in memory, we don't need to do anything more.
+	 * in memory, allocate page frames for the image and we're done.
 	 */
-	if (size >= saveable)
+	if (size >= saveable) {
+		pages = preallocate_image_highmem(save_highmem);
+		pages += preallocate_image_memory(saveable - pages);
 		goto out;
+	}
 
 	/*
 	 * Let the memory management subsystem know that we're going to need a
@@ -1225,10 +1292,8 @@ int swsusp_shrink_memory(void)
 	pages_highmem = preallocate_image_highmem(highmem / 2);
 	alloc = count - max_size - pages_highmem;
 	pages = preallocate_image_memory(alloc);
-	if (pages < alloc) {
-		error = -ENOMEM;
-		goto free_out;
-	}
+	if (pages < alloc)
+		goto err_out;
 	size = max_size - size;
 	alloc = size;
 	size = preallocate_image_highmem(
@@ -1238,21 +1303,23 @@ int swsusp_shrink_memory(void)
 	pages += preallocate_image_memory(alloc);
 	pages += pages_highmem;
 
- free_out:
-	/* Release all of the preallocated page frames. */
-	swsusp_free();
-
-	if (error) {
-		printk(KERN_CONT "\n");
-		return error;
-	}
+	/*
+	 * We only need 'size' page frames for the image but we have allocated
+	 * more.  Release the excessive ones now.
+	 */
+	free_unnecessary_pages(size);
 
  out:
 	do_gettimeofday(&stop);
-	printk(KERN_CONT "done (preallocated %lu free pages)\n", pages);
-	swsusp_show_speed(&start, &stop, pages, "Freed");
+	printk(KERN_CONT "done (allocated %lu pages)\n", pages);
+	swsusp_show_speed(&start, &stop, pages, "Allocated");
 
 	return 0;
+
+ err_out:
+	printk(KERN_CONT "\n");
+	swsusp_free();
+	return -ENOMEM;
 }
 
 #ifdef CONFIG_HIGHMEM
@@ -1263,7 +1330,7 @@ int swsusp_shrink_memory(void)
 
 static unsigned int count_pages_for_highmem(unsigned int nr_highmem)
 {
-	unsigned int free_highmem = count_free_highmem_pages();
+	unsigned int free_highmem = count_free_highmem_pages() + alloc_highmem;
 
 	if (free_highmem >= nr_highmem)
 		nr_highmem = 0;
@@ -1285,19 +1352,17 @@ count_pages_for_highmem(unsigned int nr_
 static int enough_free_mem(unsigned int nr_pages, unsigned int nr_highmem)
 {
 	struct zone *zone;
-	unsigned int free = 0, meta = 0;
+	unsigned int free = alloc_normal;
 
-	for_each_zone(zone) {
-		meta += snapshot_additional_pages(zone);
+	for_each_zone(zone)
 		if (!is_highmem(zone))
 			free += zone_page_state(zone, NR_FREE_PAGES);
-	}
 
 	nr_pages += count_pages_for_highmem(nr_highmem);
-	pr_debug("PM: Normal pages needed: %u + %u + %u, available pages: %u\n",
-		nr_pages, PAGES_FOR_IO, meta, free);
+	pr_debug("PM: Normal pages needed: %u + %u, available pages: %u\n",
+		nr_pages, PAGES_FOR_IO, free);
 
-	return free > nr_pages + PAGES_FOR_IO + meta;
+	return free > nr_pages + PAGES_FOR_IO;
 }
 
 #ifdef CONFIG_HIGHMEM
@@ -1319,7 +1384,7 @@ static inline int get_highmem_buffer(int
  */
 
 static inline unsigned int
-alloc_highmem_image_pages(struct memory_bitmap *bm, unsigned int nr_highmem)
+alloc_highmem_pages(struct memory_bitmap *bm, unsigned int nr_highmem)
 {
 	unsigned int to_alloc = count_free_highmem_pages();
 
@@ -1339,7 +1404,7 @@ alloc_highmem_image_pages(struct memory_
 static inline int get_highmem_buffer(int safe_needed) { return 0; }
 
 static inline unsigned int
-alloc_highmem_image_pages(struct memory_bitmap *bm, unsigned int n) { return 0; }
+alloc_highmem_pages(struct memory_bitmap *bm, unsigned int n) { return 0; }
 #endif /* CONFIG_HIGHMEM */
 
 /**
@@ -1358,51 +1423,36 @@ static int
 swsusp_alloc(struct memory_bitmap *orig_bm, struct memory_bitmap *copy_bm,
 		unsigned int nr_pages, unsigned int nr_highmem)
 {
-	int error;
-
-	error = memory_bm_create(orig_bm, GFP_ATOMIC | __GFP_COLD, PG_ANY);
-	if (error)
-		goto Free;
-
-	error = memory_bm_create(copy_bm, GFP_ATOMIC | __GFP_COLD, PG_ANY);
-	if (error)
-		goto Free;
+	int error = 0;
 
 	if (nr_highmem > 0) {
 		error = get_highmem_buffer(PG_ANY);
 		if (error)
-			goto Free;
-
-		nr_pages += alloc_highmem_image_pages(copy_bm, nr_highmem);
+			goto err_out;
+		if (nr_highmem > alloc_highmem) {
+			nr_highmem -= alloc_highmem;
+			nr_pages += alloc_highmem_pages(copy_bm, nr_highmem);
+		}
 	}
-	while (nr_pages-- > 0) {
-		struct page *page = alloc_image_page(GFP_ATOMIC | __GFP_COLD);
-
-		if (!page)
-			goto Free;
+	if (nr_pages > alloc_normal) {
+		nr_pages -= alloc_normal;
+		while (nr_pages-- > 0) {
+			struct page *page;
 
-		memory_bm_set_bit(copy_bm, page_to_pfn(page));
+			page = alloc_image_page(GFP_ATOMIC | __GFP_COLD);
+			if (!page)
+				goto err_out;
+			memory_bm_set_bit(copy_bm, page_to_pfn(page));
+		}
 	}
+
 	return 0;
 
- Free:
+ err_out:
 	swsusp_free();
-	return -ENOMEM;
+	return error;
 }
 
-/* Memory bitmap used for marking saveable pages (during suspend) or the
- * suspend image pages (during resume)
- */
-static struct memory_bitmap orig_bm;
-/* Memory bitmap used on suspend for marking allocated pages that will contain
- * the copies of saveable pages.  During resume it is initially used for
- * marking the suspend image pages, but then its set bits are duplicated in
- * @orig_bm and it is released.  Next, on systems with high memory, it may be
- * used for marking "safe" highmem pages, but it has to be reinitialized for
- * this purpose.
- */
-static struct memory_bitmap copy_bm;
-
 asmlinkage int swsusp_save(void)
 {
 	unsigned int nr_pages, nr_highmem;
Index: linux-2.6/kernel/power/power.h
===================================================================
--- linux-2.6.orig/kernel/power/power.h
+++ linux-2.6/kernel/power/power.h
@@ -74,7 +74,7 @@ extern asmlinkage int swsusp_arch_resume
 
 extern int create_basic_memory_bitmaps(void);
 extern void free_basic_memory_bitmaps(void);
-extern int swsusp_shrink_memory(void);
+extern int hibernate_preallocate_memory(void);
 
 /**
  *	Auxiliary structure used for reading the snapshot image data and
Index: linux-2.6/kernel/power/disk.c
===================================================================
--- linux-2.6.orig/kernel/power/disk.c
+++ linux-2.6/kernel/power/disk.c
@@ -303,8 +303,8 @@ int hibernation_snapshot(int platform_mo
 	if (error)
 		return error;
 
-	/* Free memory before shutting down devices. */
-	error = swsusp_shrink_memory();
+	/* Preallocate image memory before shutting down devices. */
+	error = hibernate_preallocate_memory();
 	if (error)
 		goto Close;
 
@@ -320,6 +320,10 @@ int hibernation_snapshot(int platform_mo
 	/* Control returns here after successful restore */
 
  Resume_devices:
+	/* We may need to release the preallocated image pages here. */
+	if (error || !in_suspend)
+		swsusp_free();
+
 	device_resume(in_suspend ?
 		(error ? PMSG_RECOVER : PMSG_THAW) : PMSG_RESTORE);
 	resume_console();
@@ -593,7 +597,10 @@ int hibernate(void)
 		goto Thaw;
 
 	error = hibernation_snapshot(hibernation_mode == HIBERNATION_PLATFORM);
-	if (in_suspend && !error) {
+	if (error)
+		goto Thaw;
+
+	if (in_suspend) {
 		unsigned int flags = 0;
 
 		if (hibernation_mode == HIBERNATION_PLATFORM)
@@ -605,8 +612,8 @@ int hibernate(void)
 			power_down();
 	} else {
 		pr_debug("PM: Image restored successfully.\n");
-		swsusp_free();
 	}
+
  Thaw:
 	thaw_processes();
  Finish:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
