Date: Wed, 14 Feb 2007 16:00:24 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Use ZVC counters to establish exact size of dirtyable pages
In-Reply-To: <20070214154438.4a80b403.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0702141559020.3615@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702121014500.15560@schroedinger.engr.sgi.com>
 <20070213000411.a6d76e0c.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702130933001.23798@schroedinger.engr.sgi.com>
 <20070214142432.a7e913fa.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702141433190.3228@schroedinger.engr.sgi.com>
 <20070214151931.852766f9.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702141521090.3615@schroedinger.engr.sgi.com>
 <20070214154438.4a80b403.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 14 Feb 2007, Andrew Morton wrote:

> On Wed, 14 Feb 2007 15:35:59 -0800 (PST)
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > If you want to be safe we can make sure that the number returned is > 0.
> 
> Yes, something like that (with a suitable comment) sounds like the suitable way
> to avoid these problems.



Insure that dirtyable memory calculation always returns positive number

In order to avoid division by zero and strange results we insure that
the memory calculation of dirtyable memory always returns at least 1.

We need to make sure that highmem_dirtyable_memory() never returns a number
larger than the total dirtyable memory. Counter deferrals and strange VM
situations with unimagiably small lowmem may make the count go negative.

Also base the calculation of the mapped_ratio on the amount of dirtyable
memory.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2007-02-14 15:58:42.000000000 -0800
+++ linux-2.6/mm/page-writeback.c	2007-02-14 15:58:45.000000000 -0800
@@ -120,7 +120,7 @@ static void background_writeout(unsigned
  * clamping level.
  */
 
-static unsigned long highmem_dirtyable_memory(void)
+static unsigned long highmem_dirtyable_memory(unsigned long total)
 {
 #ifdef CONFIG_HIGHMEM
 	int node;
@@ -134,7 +134,13 @@ static unsigned long highmem_dirtyable_m
 			+ zone_page_state(z, NR_INACTIVE)
 			+ zone_page_state(z, NR_ACTIVE);
 	}
-	return x;
+	/*
+	 * Make sure that the number of highmem pages is never larger
+	 * than the number of the total dirtyable memory. This can only
+	 * occur in very strange VM situations but we want to make sure
+	 * that this does not occur.
+	 */
+	return min(x, total);
 #else
 	return 0;
 #endif
@@ -146,9 +152,9 @@ static unsigned long determine_dirtyable
 
 	x = global_page_state(NR_FREE_PAGES)
 		+ global_page_state(NR_INACTIVE)
-		+ global_page_state(NR_ACTIVE)
-		- highmem_dirtyable_memory();
-	return x;
+		+ global_page_state(NR_ACTIVE);
+	x -= highmem_dirtyable_memory(x);
+	return x + 1;	/* Insure that we never return 0 */
 }
 
 static void
@@ -165,7 +171,7 @@ get_dirty_limits(long *pbackground, long
 
 	unmapped_ratio = 100 - ((global_page_state(NR_FILE_MAPPED) +
 				global_page_state(NR_ANON_PAGES)) * 100) /
-					vm_total_pages;
+					available_memory;
 
 	dirty_ratio = vm_dirty_ratio;
 	if (dirty_ratio > unmapped_ratio / 2)
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
