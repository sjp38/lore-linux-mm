Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 52A376B008C
	for <linux-mm@kvack.org>; Sat,  7 Mar 2009 17:13:52 -0500 (EST)
Date: Sat, 7 Mar 2009 14:13:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-Id: <20090307141316.85cb1f62.akpm@linux-foundation.org>
In-Reply-To: <20090307220055.6f79beb8@mjolnir.ossman.eu>
References: <bug-12832-27@http.bugzilla.kernel.org/>
	<20090307122452.bf43fbe4.akpm@linux-foundation.org>
	<20090307220055.6f79beb8@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Pierre Ossman <drzeus@drzeus.cx>
Cc: bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 7 Mar 2009 22:00:55 +0100 Pierre Ossman <drzeus@drzeus.cx> wrote:

> On Sat, 7 Mar 2009 12:24:52 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > 
> > hm, not a lot to go on there.
> > 
> > We have quite a lot of instrumentation for memory consumption - were
> > you able to work out where it went by comparing /proc/meminfo,
> > /proc/slabinfo, `echo m > /proc/sysrq-trigger', etc?
> > 
> 
> The redhat entry contains all the info, and I've compared meminfo and
> slabinfo without finding anything even close to the chunks of lost
> memory.

Ok.

> I've attached the sysrq memory stats from 2.6.26 and 2.6.27. The only
> difference though is in the reported free pages

Drat.

> I'm not very familiar with all the instrumentation, so pointers are
> very welcome.
> 
> > Is the memory missing on initial boot up, or does it take some time for
> > the problem to become evident?
> > 
> 
> Initial boot as far as I can tell.

OK.  In that case it might be that someone gobbled a lot of bootmem.

Unfortunately we only added the bootmem_debug boot option in 2.6.27.

Below is a super-quick hackport of that patch into 2.6.26.  That will
allow us (ie: you ;)) to compare bootmem allocations between the two
kernels.

Unfortunately bootmem-debugging doesn't tell us _who_ allocated the
memory, so I stuck a dump_stack() in there too.


diff -puN mm/bootmem.c~bdebug mm/bootmem.c
--- a/mm/bootmem.c~bdebug
+++ a/mm/bootmem.c
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
@@ -213,10 +229,10 @@ static void __init free_bootmem_core(boo
 	if (eidx > bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start))
 		eidx = bdata->node_low_pfn - PFN_DOWN(bdata->node_boot_start);
 
-	for (i = sidx; i < eidx; i++) {
-		if (unlikely(!test_and_clear_bit(i, bdata->node_bootmem_map)))
-			BUG();
-	}
+	for (i = sidx; i < eidx; i++)
+		if (test_and_set_bit(i, bdata->node_bootmem_map))
+			bdebug("hm, page %lx reserved twice.\n",
+				PFN_DOWN(bdata->node_boot_start) + i);
 }
 
 /*
@@ -252,6 +268,12 @@ __alloc_bootmem_core(struct bootmem_data
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
@@ -359,6 +381,10 @@ found:
 		ret = phys_to_virt(start * PAGE_SIZE + node_boot_start);
 	}
 
+	bdebug("start=%lx end=%lx\n",
+		start + PFN_DOWN(bdata->node_boot_start),
+		start + areasize + PFN_DOWN(bdata->node_boot_start));
+
 	/*
 	 * Reserve the area now:
 	 */
@@ -432,6 +458,7 @@ static unsigned long __init free_all_boo
 	}
 	total += count;
 	bdata->node_bootmem_map = NULL;
+	bdebug("released=%lx\n", count);
 
 	return total;
 }
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
