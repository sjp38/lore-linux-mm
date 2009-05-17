Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B51006B004F
	for <linux-mm@kvack.org>; Sun, 17 May 2009 17:48:57 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH 6/6] PM/Hibernate: Do not try to allocate too much memory too hard
Date: Sun, 17 May 2009 23:14:29 +0200
References: <200905070040.08561.rjw@sisk.pl> <200905171455.06120.rjw@sisk.pl> <20090517140712.GE3254@localhost>
In-Reply-To: <20090517140712.GE3254@localhost>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905172314.29850.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: pm list <linux-pm@lists.linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sunday 17 May 2009, Wu Fengguang wrote:
> On Sun, May 17, 2009 at 08:55:05PM +0800, Rafael J. Wysocki wrote:
> > On Sunday 17 May 2009, Wu Fengguang wrote:
> 
> > > > +static unsigned long minimum_image_size(unsigned long saveable)
> > > > +{
> > > > +	unsigned long size;
> > > > +
> > > > +	/* Compute the number of saveable pages we can free. */
> > > > +	size = global_page_state(NR_SLAB_RECLAIMABLE)
> > > > +		+ global_page_state(NR_ACTIVE_ANON)
> > > > +		+ global_page_state(NR_INACTIVE_ANON)
> > > > +		+ global_page_state(NR_ACTIVE_FILE)
> > > > +		+ global_page_state(NR_INACTIVE_FILE);
> > > 
> > > For example, we could drop the 1.25 ratio and calculate the above
> > > reclaimable size with more meaningful constraints:
> > > 
> > >         /* slabs are not easy to reclaim */
> > > 	size = global_page_state(NR_SLAB_RECLAIMABLE) / 2;
> > 
> > Why 1/2?
> 
> Also a very coarse value:
> - we don't want to stress icache/dcache too much
>   (unless they grow too large)
> - my experience was that the icache/dcache are scanned in a slower
>   pace than lru pages.
> - most importantly, inside the NR_SLAB_RECLAIMABLE pages, maybe half
>   of the pages are actually *in use* and cannot be freed:
>         % cat /proc/sys/fs/inode-nr     
>         30450   16605
>         % cat /proc/sys/fs/dentry-state 
>         41598   35731   45      0       0       0
>   See? More than half entries are in-use. Sure many of them will actually
>   become unused when dentries are freed, but in the mean time the internal
>   fragmentations in the slabs can go up.
> 
> > >         /* keep NR_ACTIVE_ANON */
> > > 	size += global_page_state(NR_INACTIVE_ANON);
> > 
> > Why exactly did you omit ACTIVE_ANON?
> 
> To keep the "core working set" :)
>   	
> > >         /* keep mapped files */
> > > 	size += global_page_state(NR_ACTIVE_FILE);
> > > 	size += global_page_state(NR_INACTIVE_FILE);
> > >         size -= global_page_state(NR_FILE_MAPPED);
> > > 
> > > That restores the hard core working set logic in the reverse way ;)
> > 
> > I think the 1/2 factor for NR_SLAB_RECLAIMABLE may be too high in some cases,
> > but I'm going to check that.
> 
> Yes, after updatedb. In that case simple magics numbers may not help.
> In that case we should really first call shrink_slab() in a loop to
> cut down the slab pages to a sane number.

I have verified that the appended patch works reasonably well.

The value returned as the minimum image size is usually too high, but not very
much (on x86_64 usually about 20%) and there are no "magic" coefficients
involved any more and the computation of the minimum image size is carried out
before calling shrink_all_memory() (so it's still going to be useful after
we've dropped shrink_all_memory() at one point).

Thanks,
Rafael

---
From: Rafael J. Wysocki <rjw@sisk.pl>
Subject: PM/Hibernate: Do not try to allocate too much memory too hard (rev. 2)

We want to avoid attempting to free too much memory too hard during
hibernation, so estimate the minimum size of the image to use as the
lower limit for preallocating memory.

The approach here is based on the (experimental) observation that we
can't free more page frames than the sum of:

* global_page_state(NR_SLAB_RECLAIMABLE)
* global_page_state(NR_ACTIVE_ANON)
* global_page_state(NR_INACTIVE_ANON)
* global_page_state(NR_ACTIVE_FILE)
* global_page_state(NR_INACTIVE_FILE)

minus

* global_page_state(NR_FILE_MAPPED)

Namely, if this number is subtracted from the number of saveable
pages in the system, we get a good estimate of the minimum reasonable
size of a hibernation image.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 kernel/power/snapshot.c |   43 +++++++++++++++++++++++++++++++++++++++----
 1 file changed, 39 insertions(+), 4 deletions(-)

Index: linux-2.6/kernel/power/snapshot.c
===================================================================
--- linux-2.6.orig/kernel/power/snapshot.c
+++ linux-2.6/kernel/power/snapshot.c
@@ -1204,6 +1204,36 @@ static void free_unnecessary_pages(void)
 }
 
 /**
+ * minimum_image_size - Estimate the minimum acceptable size of an image
+ * @saveable: Number of saveable pages in the system.
+ *
+ * We want to avoid attempting to free too much memory too hard, so estimate the
+ * minimum acceptable size of a hibernation image to use as the lower limit for
+ * preallocating memory.
+ *
+ * We assume that the minimum image size should be proportional to
+ *
+ * [number of saveable pages] - [number of pages that can be freed in theory]
+ *
+ * where the second term is the sum of (1) reclaimable slab pages, (2) active
+ * and (3) inactive anonymouns pages, (4) active and (5) inactive file pages,
+ * minus mapped file pages.
+ */
+static unsigned long minimum_image_size(unsigned long saveable)
+{
+	unsigned long size;
+
+	size = global_page_state(NR_SLAB_RECLAIMABLE)
+		+ global_page_state(NR_ACTIVE_ANON)
+		+ global_page_state(NR_INACTIVE_ANON)
+		+ global_page_state(NR_ACTIVE_FILE)
+		+ global_page_state(NR_INACTIVE_FILE)
+		- global_page_state(NR_FILE_MAPPED);
+
+	return saveable <= size ? 0 : saveable - size;
+}
+
+/**
  * hibernate_preallocate_memory - Preallocate memory for hibernation image
  *
  * To create a hibernation image it is necessary to make a copy of every page
@@ -1220,8 +1250,8 @@ static void free_unnecessary_pages(void)
  *
  * If image_size is set below the number following from the above formula,
  * the preallocation of memory is continued until the total number of saveable
- * pages in the system is below the requested image size or it is impossible to
- * allocate more memory, whichever happens first.
+ * pages in the system is below the requested image size or the minimum
+ * acceptable image size returned by minimum_image_size(), whichever is greater.
  */
 int hibernate_preallocate_memory(void)
 {
@@ -1282,6 +1312,11 @@ int hibernate_preallocate_memory(void)
 		goto out;
 	}
 
+	/* Estimate the minimum size of the image. */
+	pages = minimum_image_size(saveable);
+	if (size < pages)
+		size = min_t(unsigned long, pages, max_size);
+
 	/*
 	 * Let the memory management subsystem know that we're going to need a
 	 * large number of page frames to allocate and make it free some memory.
@@ -1294,8 +1329,8 @@ int hibernate_preallocate_memory(void)
 	 * The number of saveable pages in memory was too high, so apply some
 	 * pressure to decrease it.  First, make room for the largest possible
 	 * image and fail if that doesn't work.  Next, try to decrease the size
-	 * of the image as much as indicated by image_size using allocations
-	 * from highmem and non-highmem zones separately.
+	 * of the image as much as indicated by 'size' using allocations from
+	 * highmem and non-highmem zones separately.
 	 */
 	pages_highmem = preallocate_image_highmem(highmem / 2);
 	max_size += pages_highmem;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
