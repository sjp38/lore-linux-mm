Received: from e1.ny.us.ibm.com (s1 [10.0.3.101])
	by admin.ny.us.ibm.com. (8.9.3/8.9.3) with ESMTP id JAA30634
	for <linux-mm@kvack.org>; Mon, 16 Apr 2001 09:18:20 -0400
Received: from northrelay02.pok.ibm.com (northrelay02.pok.ibm.com [9.117.200.22])
	by e1.ny.us.ibm.com (8.9.3/8.9.3) with ESMTP id JAA92356
	for <linux-mm@kvack.org>; Mon, 16 Apr 2001 09:18:00 -0400
Received: from d01ml233.pok.ibm.com (d01ml233.pok.ibm.com [9.117.200.63])
	by northrelay02.pok.ibm.com (8.8.8m3/NCO v4.96) with ESMTP id JAA120006
	for <linux-mm@kvack.org>; Mon, 16 Apr 2001 09:14:37 -0400
Subject: Linux MXT support code (long posting,  part 2 of 2)
Message-ID: <OF17916151.0CD150BE-ON85256A2F.0053ABC6@pok.ibm.com>
From: "Bulent Abali" <abali@us.ibm.com>
Date: Mon, 16 Apr 2001 09:20:08 -0400
MIME-Version: 1.0
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In this posting I will describe the operation of the kernel
patch and the mxt driver
http://oss.software.ibm.com/pub/mxt/patch-2.4.3-md7

The 2.4.3 kernel with MXT support code has been tested
extensively with stress tools.  If you have suggestions
for a test please write to me.  Comments and contributions are
always welcome.

Thanks

Bulent Abali
abali@us.ibm.com



The software design
-------------------
Memory compression is done entirely in hardware, transparent to
the CPUs, I/O devices, peripherals and all software including apps,
device drivers and the kernel.  Then, why do we need a kernel patch
and a device driver to support MXT?  Here are the two main reasons:

- The kernel patch, at boot time looks for an MXT signature in
  the bios and doubles the size of the address space if signature
  is found.
- The driver handles the corner case when 2 to 1 compressibility
  assumption breaks down.  Without the driver compressed
  memory may run out with incompressible data in memory.

In MXT systems the memory is overcommitted.  There exists X amount of
memory in the system but the system runs with 2X the address space.
For example, you may have 512MB installed but system boots and
runs as if having 1 GB memory.  What happens for example
when you fill the 1 GB memory with incompressible data, for example
a huge zip file which cannot be further compressed in to 512 MB by
the MXT memory controller?  This is handled by the MXT driver
which manages the compressed memory as I explain here.

One important point is that the kernel patch and the driver
are unobtrusive: they can be compiled in to the any i386 kernel
build, and will run on any hardware, MXT or not.  If the system is
not MXT-enabled, neither the patch nor the driver module will
change the operation of the standard kernel.

Which files?
------------
The mxt driver module is in arch/i386/kernel/mxt.c and
include/asm-i386/mxt.h

The kernel patch touches the following files, with the amount
of lines touched/added indicated in parenthesis.

arch/i386/kernel/setup.c  (84 lines)
arch/i386/mm/init.c       (2  lines)
mm/mmap.c                 (6  lines)
mm/page_alloc.c           (10 lines)


Here are the additions to arch/i386/kernel/setup.c
--------------------------------------------------
In the standard kernel, setup_memory_region() determines the size of
the system memory as obtained by bios E820 calls.

If the box is MXT enabled, we must double the size of the address
space using setup_mxt_memory()

--- v2.4.3/linux/arch/i386/kernel/setup.c     Sun Mar 25 21:24:31 2001
+++ linux/arch/i386/kernel/setup.c Tue Apr  3 09:17:23 2001

     setup_memory_region();

+#ifdef CONFIG_MXT
+    setup_mxt_memory();
+#endif


At boot time, the MXT boxes have an address space 2X the size of the
installed memory.  But the BIOS reports only 1X in the E820 call.
This for the safety of the unaware users and will avoid costly support
and help-desk calls.  If BIOS were to report the 2X address space
in E820 and if a user installed a vanilla operating system
(not MXT-enabled) and then started using 1 GB of memory, he could have run
for long time without knowing that there was only 512MB in the system.
And without the compressed memory management software, the system could
eventually run out of compressed memory.  So to avoid potential
problems, we hide this additional memory from non MXT-aware OSes by
reporting only the physical memory size in the E820 call.

But MXT-aware kernels, for example this patch, look for an MXT signature
in the BIOS EBDA area.  MXT bios leaves a special table in the EBDA
area which can be searched for by the MXT-aware kernels and drivers.
The table format is mutually agreed upon by hardware vendors
operating in the MXT space.  The table basically indicates how much
additional "memory" i.e. address space there exist due to MXT.
Here is the format of the MXT table
http://oss.software.ibm.com/developerworks/opensource/mxt/publications/mxt_boot_spec041201.pdf

In summary, the setup_mxt_memory() function looks for an MXT-table
in the EBDA area and if found, it makes add_memory_region() calls
to increase the address space size from 1X to 2X.  After this point
for all practical purposes memory size will appear as 2X the
installed memory.

Now let's look at the compressed memory management code in
arch/i386/kernel/mxt.c
----------------------------------------------------------

Compressed memory management is actually quite simple. The
code needs to perform the following tasks:

1-Measure compressed memory utilization.
2-If utilization exceeds predetermined thresholds, reclaim
  pages from other processes and clear the pages.  This
  will reduce utilization because a 4 KB page filled with
  zeros occupy only 64 bytes in the compressed memory.
3-Steal CPU cycles from processes trying to push up compressed
  memory utilization.

First task is accomplished using an architected register
called Sectors Used Register (SUR) found on the memory controller.
SUR is memory mapped and can be conveniently read by the
device driver as shown.

+        sectors  = READ_CTRL(SUR);
+        numpages = SECTORS_TO_BYTES(sectors) >> PAGE_SHIFT;

This value is different than the value kernel thinks the system
is using.  Kernel might see 800 MB being used but if
the contents are 2x compressible, then SUR will read only
400 MB.

The second task is accomplished by comparing the value of
SUR to a set of predetermined thresholds.  This is done
by a combination of polling and interrupts.  There exist a
register called
Sectors Used Threshold Low Register (SUTLR).  When SUR value
exceeds SUTLR, the memory controller will interrupt the
driver to indicate that compressed memory utilization is too
high.  SUTLR threshold is calculated during driver load time.
It is typically greater than 90% of the installed memory size.
For example, assume a system with 512MB installed memory
and 1 GB address space, and assume that 800 MB of memory is
in use.  When compressed memory utilization exceeds
0.9 x 512 = 460 MB, the memory controller will interrupt
the driver which will start working to reduce the utilization.

The driver will signal its "memory eater" threads named
cmp_eatmem() to start allocating pages using
alloc_clear() function.  The alloc_clear function
uses the kernel alloc_pages() function to get free pages
and then uses the fast-page-op to clear the page contents.
This will reduce compressed memory utilization.

+         page = alloc_pages(gfp_mask,0);
+         if ( ! page )
+              break;
+         mxt_clear_page(page);
+         ++cleared;
+         ++(*held);
+         list_add( &page->list, head );

Allocating pages in this manner puts pressure on the
memory manager which must find free pages to deliver to eatmem
threads.
So alloc_pages() and its friends kswapd and bdflush
will start working to reclaim used pages from other processes.
As it is reclaiming pages, alloc_pages might shrink the page
cache, buffer cache and so forth.  It might also force
processes' pages to be swapped out.  Reclaimed
pages are then delivered to the eatmem threads which will
hold on to them until the compressed memory pressure goes
away.

There are actually several thresholds.  As each threshold
is crossed the driver gets more aggresive in grabbing and holding
more pages.  The thresholds are found in struct mc_th; and named
as release, acquire, danger, intr.  release < acquire <
danger < intr is implied.  Below the release threshold
eatmem threads release all the pages they have been holding.
Above the acquire threshold eatmem threads allocate and clear
some pages but they leave some free memory still available
for allocation by other processes.  Above danger threshold,
eatmem threads allocate all the free pages in the system
and even ask for more.  Above intr threshold it is same as
danger, and additionally cpu blocker threads start running
(more on this later.)  The danger threshold is the target
compressed memory utilization.  To summarize we don't want
compressed mem util to ever exceed danger. Between acquire
and danger we allocate some pages as a guard but leave some
free pages.  Above danger we work very hard to reduce utilization
below danger.

So how many pages eatmem threads must allocate and clear?
This is calculated in the mc_adjust_check() function.
The driver uses linear extrapolation to determine
the number of pages that must be removed from the system.
Assume that the maxmu is the target compressed memory util
and mu is the current compressed memory util.  And assume
that usedpages is the amount of memory currently in use.  Then
the maximum desired used pages count is calculated as
max_pages = (maxmu / mu) * usedpages;

For example, say this is a 512MB installed and 1GB (2X) address
space system.  Say, the current compressed memory utilization is 90%
which is above acquire (88%) but below danger (92%).  And assume
that 700 MB of memory is currently in use.  Therefore
max_pages= (0.92/0.90)x700 = 715 MB.  So, the eatmem threads
grab and hold 1024-715 = 309 MB of pages.  This leaves 15 MB of
free memory.

Now assume that the contents of the 700 MB start becoming
less compressible such that current utilization becomes 0.94
exceeding danger (0.92) threshold.  Then the equation becomes
max_pages= (0.92/0.94)x700 = 685 MB.  It means that the memeater
threads must allocate and clear more memory, a total of
1024-685 = 339MB.   Since 685 MB is smaller than 700 MB, the memory
allocator alloc_pages() must free up 15 MB from somewhere;
this might be the page cache, buffer cache, or might be through
swapping out of process pages.  As pages are allocated by eatmem
threads, they are zeroed and the compressed memory utilization
decreases.

CPU blockers
------------
CPU blockers are needed to stall processes increasing compressed
memory utilization above the highest threshold, intr.
There is one CPU blocker thread per CPU.
As eatmem threads are allocating pages, they might be
descheduled in the alloc_pages() function.  Because allocating
pages might require yielding to kswapd or bdflush to free up some
pages.  For example

mm/page_alloc.c:

     wakeup_kswapd();
     if (gfp_mask & __GFP_WAIT) {
          __set_current_state(TASK_RUNNING);
          current->policy |= SCHED_YIELD;
          schedule();
     }

Furthermore kswapd and bdflush may suspend waiting for
disk I/O to complete (e.g. when swapping).
When alloc_pages routine yields the CPU like shown above, the
nasty process pushing up the compressed mem utilization may
start executing and increase the utilization further.  So, to
avoid positive feedbacks like this, above the intr threshold
the driver signals cpu blockers (called cmp_idle()) to start
spinning and wasting CPU cycles at a high priority.

Granted this approach is heavy handed and one might do a better
job in kernel/sched.c, but my motivation here was to have the
least lines of code change in the kernel.  Also note that it
is not always easy to identify processes pushing up the
compressed mem utilization to suspend them.  Furthermore,
system rarely gets above the intr threshold during normal use.
When we're running stress tests to push up the utilization,
over a one day period the system goes above the intr threshold
may be 5-6 times at most and only few seconds at a time.
So the cpu blockers almost never run under normal use.
I believe this approach is a good tradeoff away from code
complexity.

Swap reservation mm/mmap.c
---------------------------
In MXT systems the memory is overcommitted.  As I stated before,
there exists X amount of memory in the system but the system runs
with 2X the address space.  In the worst case scenario 2X-1X=1X
memory may need to be swapped out to the swap disk if contents
of the memory becomes totally incompressible.  Therefore, swap
space must exist to cover the worst case.  So, we "reserve" some
swap space in the vm_enough_memory() as shown below.

--- v2.4.3/linux/mm/mmap.c    Wed Mar 28 15:55:34 2001
+++ linux/mm/mmap.c Tue Apr  3 09:17:23 2001
-    free += nr_swap_pages;
+    free += nr_swap_pages - swap_reserve;

This is not so wasteful. Disk space is cheap. It costs about $3/GB
these days.  If your system does not need swap, for example
it is a webserver which uses the page cache mostly, then you can
override this reservation thru /proc file system
echo 0 > /proc/sys/mxt/swap_rsrv

One thing worth mentioning is that swap_reserve is set to 0 on
non-MXT systems.  Therefore, the patch will not change the
behaviour of vm_enough_memory() when the kernel is running on
non-MXT systems.

In conclusion, the MXT support patch and driver help keep the
compressed memory utilization down when needed.  The discussion on
cpu blockers, eatmem threads and swapping overcommitted memory
might have given you the impression that there is an ongoing
fight to keep the compressed memory utilization down.  However
these do not happen during normal use.  Most applications are
compressible by a factor of 2 or even better.  The MXT driver
code almost never gets activated.
If you want to see it with your own eyese try the
graphical monitor xcompress on your system
http://oss.software.ibm.com/developerworks/opensource/mxt/tools/xcompress.tar.gz
Xcompress samples the memory and estimates compressibility.
It produces a number between 0.0 to 1.0.  Smaller is better.
For example 0.5 means that memory is compressible by a factor
of 2 (1/0.5).




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
