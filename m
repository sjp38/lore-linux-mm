Date: Tue, 10 Apr 2007 17:15:49 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 3/5] Validation of slabs (metadata and guard zones)
In-Reply-To: <20070410133137.e366a16b.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0704101715050.3850@schroedinger.engr.sgi.com>
References: <20070410191910.8011.76133.sendpatchset@schroedinger.engr.sgi.com>
 <20070410191921.8011.16929.sendpatchset@schroedinger.engr.sgi.com>
 <20070410133137.e366a16b.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Apr 2007, Andrew Morton wrote:

> We should force -mm testers to use slub by default, while providing them a
> way of going back to slab if they hit problems.  Can you please cook up a
> -mm-only patch for that?


SLUB: mm-only: Make SLUB the default slab allocator

Make SLUB the default slab allocator

WARNING: This is a new allocator. No guarantees.

Known areas of concern:

A. i386 and FRV arches have been disabled by setting
   ARCH_USES_SLAB_PAGE_STRUCT. SLUB cannot be enabled on those platforms.

   The issue is that both arches use the page->index and page->private field
   of memory allocated via the slab. SLUB uses these fields too. There are
   a variety of patches out there (some by me, some by Bill Irwin) to address
   this but without those you may be stuck until Bill Irwin comes up with a
   definite solution.

B. There may be undiscovered locations in arch code that are as badly
   behaved as i386 and FRV which will likely cause the arch not to boot
   and fail with mysterious error messages.

C. Unlike SLAB, SLUB does not special case page sized allocations. SLAB
   aligns kmallocs of page sized allocation on page boundaries.
   SLUB also does that most of the time but does not guarantee alignment
   beyond KMALLOC_ARCH_MINALIGN that is valid for other kmalloc slabs.
   In particular enabling debugging will add some tracking information
   to slabs which will usually cause page sized slabs to become no longer
   aligned on page boundaries.

   If there is arch code that relies on this behavior then we are likely
   to see funky behavior. Code that uses page sized allocations via kmalloc
   should either use the page allocator or explictly request page aligned
   data from the slab by creating a custom slab with the needed alignment.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/init/Kconfig
===================================================================
--- linux-2.6.21-rc6.orig/init/Kconfig	2007-04-10 17:00:56.000000000 -0700
+++ linux-2.6.21-rc6/init/Kconfig	2007-04-10 17:01:24.000000000 -0700
@@ -521,7 +521,7 @@ config PROC_KPAGEMAP
 
 choice
 	prompt "Choose SLAB allocator"
-	default SLAB
+	default SLUB
 	help
 	   This option allows to select a slab allocator.
 
@@ -534,7 +534,7 @@ config SLAB
 	  slab allocator.
 
 config SLUB
-	depends on EXPERIMENTAL && !ARCH_USES_SLAB_PAGE_STRUCT
+	depends on !ARCH_USES_SLAB_PAGE_STRUCT
 	bool "SLUB (Unqueued Allocator)"
 	help
 	   SLUB is a slab allocator that minimizes cache line usage

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
