Message-Id: <200205032241.g43MfC39082721@smtpzilla1.xs4all.nl>
Content-Type: text/plain;
  charset="iso-8859-1"
From: Erik van Konijnenburg <ekonijn@xs4all.nl>
Reply-To: ekonijn@xs4all.nl
Subject: Re: page-flags.h
Date: Sat, 4 May 2002 00:41:10 +0200
References: <20020501192737.R29327@suse.de> <20020501200452.S29327@suse.de> <3CD1FB78.B3314F4B@zip.com.au>
In-Reply-To: <3CD1FB78.B3314F4B@zip.com.au>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>, Christoph Hellwig <hch@infradead.org>, Dave Jones <davej@suse.de>, kernel-janitor-discuss@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,

Do you really have to edit 119 files if you just want to avoid
processing the PageFoo macros?  Include page-flags.h in pagemap.h,
and you only have to add include lines to 13 files to get the kernel
compiled, while still getting rid of 1050 times reading of page-flags.h.

Motivation:
    --	linux/mm.h is included in 1163 files
    --	linux/pagemap.h is included in only 109 files.
    --	In pagemap.h, wait_on_page_locked() and PageLocked()
	are mixed rather awkwardly.  Moving wait_on_page_locked()
	to page-flags.h as you suggested doesn't really help:
	you'd have to move the ___wait_on_page_locked declaration
	as well, resulting in other ugliness, so we might as well
	include page-flags.h.
    --	most of the added includes are for page-flags.h, so it makes
	sense not to merge page-flags.h and pagemap.h.
    --	yes, the number 1050 is wrong, since pagemap.h is also
	included indirectly.  I'm not sufficiently familiar with
	the kernel to make a better estimate, so this whole
	thing may be a red herring.

Please don't regard the attached diffs as a patch, more as a suggestion
of what a next intermediate step could look like.  In particular,
putting page_state in page-state.h is bogus, something left over
from earlier experiments.  No idea if it actually works, but at least it
compiles with my limited set of modules.

Of course this does not affect Christoph's remarks regarding 
the need for page.h one way or the other.

Regards,
Erik

> On Thu, May 02, 2002 at 07:52:40PM -0700, Andrew Morton wrote:
> > > That's a good point, and something I completley overlooked.
> > > I wonder if Andrew Morton (who I'm guessing wrote that comment
> > > in mm.h) has some ingenious plan here..
> > 
> > who, me?
> > 
> > I'd envisaged those 119 files doing:
> > 
> > #include <linux/mm.h>
> > #include <linux/page-flags.h>
> > 
> > so then anything which includes mm.h but doesn't do any PageFoo()
> > operations doesn't have to process those macros.
> 
> Okay, that makes some sense.  I still think it's preferrable to
> have <linux/page.h>  - many filesystems only need struct page, the
> flags and few supporting functions, so do drivers using kiobufs.
> 
> Having these no need the rest of the MM internals is a good thing (TM).

--- linux-2.5.13/arch/i386/mm/ioremap.c.org	Fri May  3 23:19:01 2002
+++ linux-2.5.13/arch/i386/mm/ioremap.c	Fri May  3 23:19:18 2002
@@ -9,6 +9,7 @@
  */
 
 #include <linux/vmalloc.h>
+#include <linux/page-flags.h>
 #include <asm/io.h>
 #include <asm/pgalloc.h>
 #include <asm/fixmap.h>
--- linux-2.5.13/include/linux/mm.h.org	Fri May  3 21:33:04 2002
+++ linux-2.5.13/include/linux/mm.h	Fri May  3 22:01:49 2002
@@ -243,7 +243,7 @@
  * FIXME: take this include out, include page-flags.h in
  * files which need it (119 of them)
  */
-#include <linux/page-flags.h>
+/* #include <linux/page-flags.h> */
 
 /*
  * The zone field is never updated after free_area_init_core()
--- linux-2.5.13/include/linux/page-flags.h.org	Fri May  3 21:58:20 2002
+++ linux-2.5.13/include/linux/page-flags.h	Fri May  3 22:44:42 2002
@@ -5,6 +5,8 @@
 #ifndef PAGE_FLAGS_H
 #define PAGE_FLAGS_H
 
+#include <linux/page-state.h>
+
 /*
  * Various page->flags bits:
  *
@@ -67,28 +69,6 @@
 #define PG_writeback		14	/* Page is under writeback */
 
 /*
- * Global page accounting.  One instance per CPU.
- */
-extern struct page_state {
-	unsigned long nr_dirty;
-	unsigned long nr_writeback;
-	unsigned long nr_pagecache;
-} ____cacheline_aligned_in_smp page_states[NR_CPUS];
-
-extern void get_page_state(struct page_state *ret);
-
-#define mod_page_state(member, delta)					\
-	do {								\
-		preempt_disable();					\
-		page_states[smp_processor_id()].member += (delta);	\
-		preempt_enable();					\
-	} while (0)
-
-#define inc_page_state(member)	mod_page_state(member, 1UL)
-#define dec_page_state(member)	mod_page_state(member, 0UL - 1)
-
-
-/*
  * Manipulation of page state flags
  */
 #define PageLocked(page)		\
@@ -219,3 +199,6 @@
 #define PageSwapCache(page) ((page)->mapping == &swapper_space)
 
 #endif	/* PAGE_FLAGS_H */
+
+
+
--- /dev/null	Thu Jan  1 01:00:00 1970
+++ linux-2.5.13/include/linux/page-state.h	Fri May  3 21:57:13 2002
@@ -0,0 +1,25 @@
+/*
+ * Global page accounting.  One instance per CPU.
+ */
+#ifndef PAGE_STATE_H
+#define PAGE_STATE_H
+
+extern struct page_state {
+	unsigned long nr_dirty;
+	unsigned long nr_writeback;
+	unsigned long nr_pagecache;
+} ____cacheline_aligned_in_smp page_states[NR_CPUS];
+
+extern void get_page_state(struct page_state *ret);
+
+#define mod_page_state(member, delta)					\
+	do {								\
+		preempt_disable();					\
+		page_states[smp_processor_id()].member += (delta);	\
+		preempt_enable();					\
+	} while (0)
+
+#define inc_page_state(member)	mod_page_state(member, 1UL)
+#define dec_page_state(member)	mod_page_state(member, 0UL - 1)
+
+#endif	/* PAGE_STATE_H */
--- linux-2.5.13/include/linux/pagemap.h.org	Fri May  3 21:58:57 2002
+++ linux-2.5.13/include/linux/pagemap.h	Fri May  3 22:47:28 2002
@@ -8,6 +8,7 @@
  */
 
 #include <linux/mm.h>
+#include <linux/page-flags.h>
 #include <linux/fs.h>
 #include <linux/list.h>
 
@@ -91,3 +92,4 @@
 extern struct page *read_cache_page(struct address_space *, unsigned long,
 				filler_t *, void *);
 #endif
+
--- linux-2.5.13/drivers/char/drm/radeon_drv.c.org	Fri May  3 23:26:13 2002
+++ linux-2.5.13/drivers/char/drm/radeon_drv.c	Fri May  3 23:26:15 2002
@@ -30,6 +30,7 @@
 #include <linux/config.h>
 #include "radeon.h"
 #include "drmP.h"
+#include <linux/page-flags.h>
 #include "radeon_drv.h"
 #include "ati_pcigart.h"
 
--- linux-2.5.13/drivers/char/drm/drm_memory.h.org	Fri May  3 23:27:48 2002
+++ linux-2.5.13/drivers/char/drm/drm_memory.h	Fri May  3 23:27:52 2002
@@ -32,6 +32,7 @@
 #define __NO_VERSION__
 #include <linux/config.h>
 #include "drmP.h"
+#include <linux/page-flags.h>
 #include <linux/wrapper.h>
 
 typedef struct drm_mem_stats {
--- linux-2.5.13/drivers/usb/class/audio.c.org	Fri May  3 23:31:14 2002
+++ linux-2.5.13/drivers/usb/class/audio.c	Fri May  3 23:31:55 2002
@@ -184,6 +184,7 @@
 #include <linux/soundcard.h>
 #include <linux/list.h>
 #include <linux/vmalloc.h>
+#include <linux/page-flags.h>
 #include <linux/wrapper.h>
 #include <linux/init.h>
 #include <linux/poll.h>
--- linux-2.5.13/sound/pci/rme9652/rme9652_mem.c.org	Fri May  3 23:47:00 2002
+++ linux-2.5.13/sound/pci/rme9652/rme9652_mem.c	Fri May  3 23:47:28 2002
@@ -40,6 +40,7 @@
 #include <linux/pci.h>
 #include <linux/init.h>
 #include <linux/mm.h>
+#include <linux/page-flags.h>
 #include <sound/initval.h>
 
 #define RME9652_CARDS			8
--- linux-2.5.13/sound/core/memory.c.org	Fri May  3 23:10:50 2002
+++ linux-2.5.13/sound/core/memory.c	Fri May  3 23:15:19 2002
@@ -21,6 +21,7 @@
 
 #define __NO_VERSION__
 #include <sound/driver.h>
+#include <linux/page-flags.h>
 #include <asm/io.h>
 #include <asm/uaccess.h>
 #include <linux/init.h>
--- linux-2.5.13/mm/memory.c.org	Fri May  3 22:22:52 2002
+++ linux-2.5.13/mm/memory.c	Fri May  3 22:23:40 2002
@@ -37,6 +37,7 @@
  */
 
 #include <linux/mm.h>
+#include <linux/page-flags.h>
 #include <linux/mman.h>
 #include <linux/swap.h>
 #include <linux/smp_lock.h>
--- linux-2.5.13/mm/slab.c.org	Fri May  3 22:52:59 2002
+++ linux-2.5.13/mm/slab.c	Fri May  3 22:54:12 2002
@@ -72,6 +72,7 @@
 #include	<linux/config.h>
 #include	<linux/slab.h>
 #include	<linux/mm.h>
+#include	<linux/page-flags.h>
 #include	<linux/cache.h>
 #include	<linux/interrupt.h>
 #include	<linux/init.h>
--- linux-2.5.13/mm/vmalloc.c.org	Fri May  3 22:52:46 2002
+++ linux-2.5.13/mm/vmalloc.c	Fri May  3 22:52:51 2002
@@ -9,6 +9,7 @@
 #include <linux/config.h>
 #include <linux/slab.h>
 #include <linux/vmalloc.h>
+#include <linux/page-flags.h>
 #include <linux/spinlock.h>
 #include <linux/highmem.h>
 #include <linux/smp_lock.h>
--- linux-2.5.13/mm/bootmem.c.org	Fri May  3 22:55:56 2002
+++ linux-2.5.13/mm/bootmem.c	Fri May  3 22:56:21 2002
@@ -10,6 +10,7 @@
  */
 
 #include <linux/mm.h>
+#include <linux/page-flags.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
 #include <linux/swapctl.h>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
