Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E10036B00A3
	for <linux-mm@kvack.org>; Sun,  8 Mar 2009 08:39:31 -0400 (EDT)
Date: Sun, 8 Mar 2009 20:38:25 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090308123825.GA25172@localhost>
References: <bug-12832-27@http.bugzilla.kernel.org/> <20090307122452.bf43fbe4.akpm@linux-foundation.org> <20090307220055.6f79beb8@mjolnir.ossman.eu> <20090307141316.85cb1f62.akpm@linux-foundation.org> <20090308110006.0208932d@mjolnir.ossman.eu> <20090308113619.0b610f31@mjolnir.ossman.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090308113619.0b610f31@mjolnir.ossman.eu>
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 08, 2009 at 11:36:19AM +0100, Pierre Ossman wrote:
> On Sun, 8 Mar 2009 11:00:06 +0100
> Pierre Ossman <drzeus@drzeus.cx> wrote:
> 
> > 
> > I'm having problems booting this machine on a vanilla 2.26.6. Fedora's
> > kernel works nice though, so I guess they have a bug fix for this. I've
> > attached a screenshot in case it rings any bells.
> > 
> 
> It turns out it's your backported patch that's the problem. I'll see if
> I can get it working. :)

Pierre, you can try the following fixed and combined patch and boot kernel
with "initcall_debug bootmem_debug".

The boot hung was due to this chunk floated from reserve_bootmem_core() into
free_bootmem_core()...

        @@ -213,10 +229,10 @@ static void __init free_bootmem_core(boo
                if (eidx > bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start))
                        eidx = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);

        -       for (i = sidx; i < eidx; i++) {
        -               if (unlikely(!test_and_clear_bit(i, bdata->node_bootmem_map)))
        -                       BUG();
        -       }
        +       for (i = sidx; i < eidx; i++)
        +               if (test_and_set_bit(i, bdata->node_bootmem_map))
        +                       bdebug("hm, page %lx reserved twice.\n",
        +                               PFN_DOWN(bdata->node_boot_start) + i);
         }

         /*

Thanks,
Fengguang
---
From: Andrew Morton <akpm@linux-foundation.org>

---
 init/main.c  |    2 ++
 mm/bootmem.c |   35 +++++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

--- mm.orig/mm/bootmem.c
+++ mm/mm/bootmem.c
@@ -48,6 +48,22 @@ unsigned long __init bootmem_bootmap_pag
 	return mapsize;
 }
 
+static int bootmem_debug;
+
+static int __init bootmem_debug_setup(char *buf)
+{
+	bootmem_debug = 1;
+	return 0;
+}
+early_param("bootmem_debug", bootmem_debug_setup);
+
+#define bdebug(fmt, args...) ({				\
+	if (unlikely(bootmem_debug))			\
+		printk(KERN_INFO			\
+			"bootmem::%s " fmt,		\
+			__FUNCTION__, ## args);		\
+})
+
 /*
  * link bdata in order
  */
@@ -172,6 +188,14 @@ static void __init reserve_bootmem_core(
 	if (eidx > bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start))
 		eidx = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
 
+	bdebug("size=%lx [%lu pages] start=%lx end=%lx flags=%x\n",
+		size, PAGE_ALIGN(size) >> PAGE_SHIFT,
+		sidx + PFN_DOWN(bdata->node_boot_start),
+		eidx + PFN_DOWN(bdata->node_boot_start),
+		flags);
+	if (bootmem_debug)
+		dump_stack();
+
 	for (i = sidx; i < eidx; i++) {
 		if (test_and_set_bit(i, bdata->node_bootmem_map)) {
 #ifdef CONFIG_DEBUG_BOOTMEM
@@ -252,6 +276,12 @@ __alloc_bootmem_core(struct bootmem_data
 	if (!bdata->node_bootmem_map)
 		return NULL;
 
+	bdebug("size=%lx [%lu pages] align=%lx goal=%lx limit=%lx\n",
+		size, PAGE_ALIGN(size) >> PAGE_SHIFT,
+		align, goal, limit);
+	if (bootmem_debug)
+		dump_stack();
+
 	/* bdata->node_boot_start is supposed to be (12+6)bits alignment on x86_64 ? */
 	node_boot_start = bdata->node_boot_start;
 	node_bootmem_map = bdata->node_bootmem_map;
@@ -359,6 +389,10 @@ found:
 		ret = phys_to_virt(start * PAGE_SIZE + node_boot_start);
 	}
 
+	bdebug("start=%lx end=%lx\n",
+		start + PFN_DOWN(bdata->node_boot_start),
+		start + areasize + PFN_DOWN(bdata->node_boot_start));
+
 	/*
 	 * Reserve the area now:
 	 */
@@ -432,6 +466,7 @@ static unsigned long __init free_all_boo
 	}
 	total += count;
 	bdata->node_bootmem_map = NULL;
+	bdebug("released=%lx\n", count);
 
 	return total;
 }
--- mm.orig/init/main.c
+++ mm/init/main.c
@@ -60,6 +60,7 @@
 #include <linux/sched.h>
 #include <linux/signal.h>
 #include <linux/idr.h>
+#include <linux/swap.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -714,6 +715,7 @@ static void __init do_one_initcall(initc
 		print_fn_descriptor_symbol("initcall %s", fn);
 		printk(" returned %d after %Ld msecs\n", result,
 			(unsigned long long) delta.tv64 >> 20);
+		printk("remaining memory: %d\n", nr_free_buffer_pages());
 	}
 
 	msgbuf[0] = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
