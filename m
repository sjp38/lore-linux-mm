Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 71D796B00AE
	for <linux-mm@kvack.org>; Sun, 10 May 2009 10:46:52 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [RFC][PATCH 6/6] PM/Hibernate: Estimate hard core working set size
Date: Sun, 10 May 2009 16:12:23 +0200
References: <200905070040.08561.rjw@sisk.pl> <200905072348.59856.rjw@sisk.pl> <200905101548.57557.rjw@sisk.pl>
In-Reply-To: <200905101548.57557.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905101612.24764.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: pm list <linux-pm@lists.linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

From: Rafael J. Wysocki <rjw@sisk.pl>

We want to avoid attempting to free too much memory too hard, so
estimate the size of the hard core working set and use it as the
lower limit for preallocating memory.

Not-yet-signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---

The formula used in this patch appears to return numbers that are too lower.

Namely, after applying a debug patch printing the values of the variables used
for the preallocation of memory, I got the following results for two test
systems:

i386, MSI Wind U100, 1 GB of RAM total

PM: Preallocating image memory...
count = 253198, max_size = 125563, saveable = 192367
Requested image size: 113064 pages
Hard working set size: 59551 pages
pages_highmem = 16091, alloc = 111544
alloc_highmem = 1612, alloc = 12499
count - pages = 113064
done (allocated 140134 pages)
PM: Allocated 560536 kbytes in 2.84 seconds (197.37 MB/s)

PM: Preallocating image memory...
count = 253178, max_size = 125553, saveable = 123191
Requested image size: 1 pages
Hard working set size: 14684 pages
pages_highmem = 16090, alloc = 111535
alloc_highmem = 14292, alloc = 110869
count - pages = 50135
done (allocated 203043 pages)

In the first run the hard working set size was irrelevant, because the
requested image size was much greater.  In the second run the requested
image size was very small and the hard working set size was used as the image
size, but the number of pages that were still allocated after the preallocation
was much greater than the hard working set size (should be smaller).

x86_64, HP nx6325, 1,5 GB of RAM total

[  250.386721] PM: Preallocating image memory...
count = 486414, max_size = 242165, saveable = 186947
[  256.844235] Requested image size: 1 pages
[  256.844392] Hard working set size: 10211 pages
[  256.844537] pages_highmem = 0, alloc = 244249
[  257.328347] alloc_highmem = 0, alloc = 231954
[  258.084074] count - pages = 24330
[  259.050589] done (allocated 462084 pages)
[  259.050653] PM: Allocated 1848336 kbytes in 8.66 seconds (213.43 MB/s)

In this case the hard core working set size was also used as the requested
image size, but the number of pages that were not freed after the preallocation
was still more than twice greater than this number.

---
 kernel/power/snapshot.c |   46 +++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 45 insertions(+), 1 deletion(-)

Index: linux-2.6/kernel/power/snapshot.c
===================================================================
--- linux-2.6.orig/kernel/power/snapshot.c
+++ linux-2.6/kernel/power/snapshot.c
@@ -1090,6 +1090,8 @@ void swsusp_free(void)
 /* Helper functions used for the shrinking of memory. */
 
 #define GFP_IMAGE	(GFP_KERNEL | __GFP_NOWARN | __GFP_NO_OOM_KILL)
+/* Typical desktop does not have more than 100MB of mapped pages. */
+#define MAX_MMAP_PAGES	(100 << (20 - PAGE_SHIFT))
 
 /**
  * preallocate_image_pages - Allocate a number of pages for hibernation image
@@ -1194,6 +1196,40 @@ static void free_unnecessary_pages(unsig
 }
 
 /**
+ * hard_core_working_set_size - Estimate the size of the hard core working set
+ *
+ * We want to avoid attempting to free too much memory too hard, so estimate the
+ * size of the hard core working set and use it as the lower limit for
+ * preallocating memory.
+ */
+static unsigned long hard_core_working_set_size(void)
+{
+	unsigned long size;
+
+	/*
+	 * Mapped pages are normally few and precious, but their number should
+	 * be bounded for safety.
+	 */
+	size = global_page_state(NR_FILE_MAPPED);
+	size = min_t(unsigned long, size, MAX_MMAP_PAGES);
+
+	/*
+	 * Disk I/O can be much faster than swap I/O, so optimize for
+	 * performance.
+	 */
+	size += global_page_state(NR_ACTIVE_ANON);
+	size += global_page_state(NR_INACTIVE_ANON);
+
+	/* Hard (but normally small) memory requests. */
+	size += global_page_state(NR_SLAB_UNRECLAIMABLE);
+	size += global_page_state(NR_UNEVICTABLE);
+	size += global_page_state(NR_PAGETABLE);
+
+	return size;
+}
+
+
+/**
  * hibernate_preallocate_memory - Preallocate memory for hibernation image
  *
  * To create a hibernation image it is necessary to make a copy of every page
@@ -1282,6 +1318,14 @@ int hibernate_preallocate_memory(void)
 	shrink_all_memory(saveable - size);
 
 	/*
+	 * Estimate the size of the hard core working set and use it as the
+	 * minimum image size.
+	 */
+	pages = hard_core_working_set_size();
+	if (size < pages)
+		size = pages;
+
+	/*
 	 * The number of saveable pages in memory was too high, so apply some
 	 * pressure to decrease it.  First, make room for the largest possible
 	 * image and fail if that doesn't work.  Next, try to decrease the size

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
