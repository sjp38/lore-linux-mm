Date: Sat, 17 Apr 2004 07:21:29 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Might refill_inactive_zone () be too aggressive?
Message-ID: <20040417142129.GI743@holomorphy.com>
References: <20040417060920.GC29393@flea> <20040417061847.GC743@holomorphy.com> <20040417140811.GA554@flea>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040417140811.GA554@flea>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marc Singer <elf@buici.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2004 at 11:18:47PM -0700, William Lee Irwin III wrote:
>> A very interesting point there. The tendency to set reclaim_mapped = 1
>> is controlled by /proc/sys/vm/swappiness; setting that to 0 may improve
>> your performance or behave closer to how the case you cited where vmscan.c
>> never sets reclaim_mapped = 1 improved performance.
>> The default value is 60, which begins unmapping mapped memory about
>> when 40% of memory is mapped by userspace.

On Sat, Apr 17, 2004 at 07:08:12AM -0700, Marc Singer wrote:
> I did a little more looking at when reclaim_mapped is set to one.  In
> my case, I don't think that very much memory is mapped.  I've got one
> program running that has one or two code pages, there may be some
> libraries.  The system has 28MiB of free RAM.  I don't see how I could
> be getting more than 20% of RAM mapped.

So adjusting swappiness didn't help? Does adjusting this help?
(uncompiled, untested)


-- wli


Index: singer-2.6.5-mm6/include/linux/sysctl.h
===================================================================
--- singer-2.6.5-mm6.orig/include/linux/sysctl.h	2004-04-14 23:21:18.000000000 -0700
+++ singer-2.6.5-mm6/include/linux/sysctl.h	2004-04-17 07:16:25.000000000 -0700
@@ -161,6 +161,7 @@
 	VM_MAX_MAP_COUNT=22,	/* int: Maximum number of mmaps/address-space */
 	VM_LAPTOP_MODE=23,	/* vm laptop mode */
 	VM_BLOCK_DUMP=24,	/* block dump mode */
+	VM_MAPPED_SCALE_FACTOR=25, /* scale factor for mapped ratio */
 };
 
 
Index: singer-2.6.5-mm6/include/linux/swap.h
===================================================================
--- singer-2.6.5-mm6.orig/include/linux/swap.h	2004-04-14 23:21:18.000000000 -0700
+++ singer-2.6.5-mm6/include/linux/swap.h	2004-04-17 07:17:05.000000000 -0700
@@ -174,7 +174,7 @@
 /* linux/mm/vmscan.c */
 extern int try_to_free_pages(struct zone **, unsigned int, unsigned int);
 extern int shrink_all_memory(int);
-extern int vm_swappiness;
+extern int vm_swappiness, vm_mapped_scale_factor;
 
 #ifdef CONFIG_MMU
 /* linux/mm/shmem.c */
Index: singer-2.6.5-mm6/kernel/sysctl.c
===================================================================
--- singer-2.6.5-mm6.orig/kernel/sysctl.c	2004-04-14 23:21:19.000000000 -0700
+++ singer-2.6.5-mm6/kernel/sysctl.c	2004-04-17 07:16:10.000000000 -0700
@@ -766,6 +766,17 @@
 		.strategy	= &sysctl_intvec,
 		.extra1		= &zero,
 	},
+	{
+		.ctl_name	= VM_MAPPED_SCALE_FACTOR,
+		.procname	= "mapped_scale_factor",
+		.data		= &vm_mapped_scale_factor,
+		.maxlen		= sizeof(vm_mapped_scale_factor),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
 	{ .ctl_name = 0 }
 };
 
Index: singer-2.6.5-mm6/mm/vmscan.c
===================================================================
--- singer-2.6.5-mm6.orig/mm/vmscan.c	2004-04-14 23:21:19.000000000 -0700
+++ singer-2.6.5-mm6/mm/vmscan.c	2004-04-17 07:18:33.000000000 -0700
@@ -43,6 +43,7 @@
  * From 0 .. 100.  Higher means more swappy.
  */
 int vm_swappiness = 60;
+int vm_mapped_scale_factor = 50;
 static long total_memory;
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
@@ -625,7 +626,7 @@
 	 * mapped memory instead of just pagecache.  Work out how much memory
 	 * is mapped.
 	 */
-	mapped_ratio = (ps->nr_mapped * 100) / total_memory;
+	mapped_ratio = (ps->nr_mapped * vm_mapped_scale_factor) / total_memory;
 
 	/*
 	 * Now decide how much we really want to unmap some pages.  The mapped
@@ -636,7 +637,7 @@
 	 *
 	 * A 100% value of vm_swappiness overrides this algorithm altogether.
 	 */
-	swap_tendency = mapped_ratio / 2 + distress + vm_swappiness;
+	swap_tendency = mapped_ratio + distress + vm_swappiness;
 
 	/*
 	 * Now use this metric to decide whether to start moving mapped memory
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
