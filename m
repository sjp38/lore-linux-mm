Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8CC6B01EE
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 03:35:52 -0400 (EDT)
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o3L7ZmIM021448
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 07:35:48 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3L7ZeOJ1421508
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 08:35:48 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o3L7ZdGN016566
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 08:35:40 +0100
Message-ID: <4BCEAAC6.7070602@linux.vnet.ibm.com>
Date: Wed, 21 Apr 2010 09:35:34 +0200
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone pressure
References: <20100322235053.GD9590@csn.ul.ie> <4BA940E7.2030308@redhat.com> <20100324145028.GD2024@csn.ul.ie> <4BCC4B0C.8000602@linux.vnet.ibm.com> <20100419214412.GB5336@cmpxchg.org> <4BCD55DA.2020000@linux.vnet.ibm.com> <20100420153202.GC5336@cmpxchg.org> <4BCDE2F0.3010009@redhat.com> <4BCE7DD1.70900@linux.vnet.ibm.com>
In-Reply-To: <4BCE7DD1.70900@linux.vnet.ibm.com>
Content-Type: multipart/mixed;
 boundary="------------010109070601080809080006"
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com, Corrado Zoccolo <czoccolo@gmail.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010109070601080809080006
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit



Christian Ehrhardt wrote:
> 
> 
> Rik van Riel wrote:
>> On 04/20/2010 11:32 AM, Johannes Weiner wrote:
>>
>>> The idea is that it pans out on its own.  If the workload changes, new
>>> pages get activated and when that set grows too large, we start 
>>> shrinking
>>> it again.
>>>
>>> Of course, right now this unscanned set is way too large and we can end
>>> up wasting up to 50% of usable page cache on false active pages.
>>
>> Thing is, changing workloads often change back.
>>
>> Specifically, think of a desktop system that is doing
>> work for the user during the day and gets backed up
>> at night.
>>
>> You do not want the backup to kick the working set
>> out of memory, because when the user returns in the
>> morning the desktop should come back quickly after
>> the screensaver is unlocked.
> 
> IMHO it is fine to prevent that nightly backup job from not being 
> finished when the user arrives at morning because we didn't give him 
> some more cache - and e.g. a 30 sec transition from/to both optimized 
> states is fine.
> But eventually I guess the point is that both behaviors are reasonable 
> to achieve - depending on the users needs.
> 
> What we could do is combine all our thoughts we had so far:
> a) Rik could create an experimental patch that excludes the in flight pages
> b) Johannes could create one for his suggestion to "always scan active 
> file pages but only deactivate them when the ratio is off and otherwise 
> strip buffers of clean pages"
> c) I would extend the patch from Johannes setting the ratio of 
> active/inactive pages to be a userspace tunable

A first revision of patch c is attached.
I tested assigning different percentages, so far e.g. 50 really behave 
like before and 25 protects ~42M Buffers in my example which would match 
the intended behavior - see patch for more details.

Checkpatch and some basic function tests went fine.
While it may be not perfect yet, I think it is ready for feedback now.

> a,b,a+b would then need to be tested if they achieve a better behavior.
> 
> c on the other hand would be a fine tunable to let administrators 
> (knowing their workloads) or distributions (e.g. different values for 
> Desktop/Server defaults) adapt their installations.
> 
> In theory a,b and c should work fine together in case we need all of them.
> 
>> The big question is, what workload suffers from
>> having the inactive list at 50% of the page cache?
>>
>> So far the only big problem we have seen is on a
>> very unbalanced virtual machine, with 256MB RAM
>> and 4 fast disks.  The disks simply have more IO
>> in flight at once than what fits in the inactive
>> list.
> 
> Did I get you right that this means the write case - explaining why it 
> is building up buffers to the 50% max?
> 

Thinking about it I wondered for what these Buffers are protected.
If the intention to save these buffers is for reuse with similar loads I 
wonder why I "need" three iozones to build up the 85M in my case.

Buffers start at ~0, after iozone run 1 they are at ~35, then after #2 
~65 and after run #3 ~85.
Shouldn't that either allocate 85M for the first directly in case that 
much is needed for a single run - or if not the second and third run 
just "resuse" the 35M Buffers from the first run still held?

Note - "1 iozone run" means "iozone ... -i 0" which sequentially writes 
and then rewrites a 2Gb file on 16 disks in my current case.

looking forward especially to patch b as I'd really like to see a kernel 
able to win back these buffers if they are no more used for a longer 
period while still allowing to grow&protect them while needed.

-- 

GrA 1/4 sse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--------------010109070601080809080006
Content-Type: text/x-patch;
 name="active-inacte-ratio-tunable.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="active-inacte-ratio-tunable.diff"

Subject: [PATCH] mm: make working set portion that is protected tunable

From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

In discussion with Rik van Riel and Joannes Weiner we came up that there are
cases that want the current "save 50%" for the working set all the time and
others that would benefit from protectig only a smaller amount.

Eventually no "carved in stone" in kernel ratio will match all use cases,
therefore this patch makes the value tunable via a /proc/sys/vm/ interface
named active_inactive_ratio.

Example configurations might be:
- 50% - like the current kernel
- 0%  - like a kernel pre "56e49d21 vmscan: evict use-once pages first"
- x%  - any other percentage to allow customizing the system to its needs.

Due to our experiments the suggested default in this patch is 25%, but if
preferred I'm fine keeping 50% and letting admins/distros adapt as needed.

Signed-off-by: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
---

[diffstat]

[diff]
Index: linux-2.6/Documentation/sysctl/vm.txt
===================================================================
--- linux-2.6.orig/Documentation/sysctl/vm.txt	2010-04-21 06:32:23.000000000 +0200
+++ linux-2.6/Documentation/sysctl/vm.txt	2010-04-21 07:24:35.000000000 +0200
@@ -18,6 +18,7 @@
 
 Currently, these files are in /proc/sys/vm:
 
+- active_inactive_ratio
 - block_dump
 - dirty_background_bytes
 - dirty_background_ratio
@@ -57,6 +58,15 @@
 
 ==============================================================
 
+active_inactive_ratio
+
+The kernel tries to protect the active working set. Therefore a portion of the
+file pages is protected, meaning they are omitted when eviting pages until this
+ratio is reached.
+This tunable represents that ratio in percent and specifies the protected part
+
+==============================================================
+
 block_dump
 
 block_dump enables block I/O debugging when set to a nonzero value. More
Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c	2010-04-21 06:33:43.000000000 +0200
+++ linux-2.6/kernel/sysctl.c	2010-04-21 07:26:35.000000000 +0200
@@ -1271,6 +1271,15 @@
 		.extra2		= &one,
 	},
 #endif
+	{
+		.procname	= "active_inactive_ratio",
+		.data		= &sysctl_active_inactive_ratio,
+		.maxlen		= sizeof(sysctl_active_inactive_ratio),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one_hundred,
+	},
 
 /*
  * NOTE: do not add new entries to this table unless you have read
Index: linux-2.6/mm/memcontrol.c
===================================================================
--- linux-2.6.orig/mm/memcontrol.c	2010-04-21 06:31:29.000000000 +0200
+++ linux-2.6/mm/memcontrol.c	2010-04-21 09:00:22.000000000 +0200
@@ -893,12 +893,12 @@
 int mem_cgroup_inactive_file_is_low(struct mem_cgroup *memcg)
 {
 	unsigned long active;
-	unsigned long inactive;
+	unsigned long file;
 
-	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_FILE);
 	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_FILE);
+	file = active + mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_FILE);
 
-	return (active > inactive);
+	return (active > file * sysctl_active_inactive_ratio / 100);
 }
 
 unsigned long mem_cgroup_zone_nr_pages(struct mem_cgroup *memcg,
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2010-04-21 06:31:29.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2010-04-21 09:00:13.000000000 +0200
@@ -1459,14 +1459,23 @@
 	return low;
 }
 
+/*
+ * sysctl_active_inactive_ratio
+ *
+ * Defines the portion of file pages within the active working set is going to
+ * be protected. The value represents the percentage that will be protected.
+ */
+int sysctl_active_inactive_ratio __read_mostly = 25;
+
 static int inactive_file_is_low_global(struct zone *zone)
 {
-	unsigned long active, inactive;
+	unsigned long active, file;
 
 	active = zone_page_state(zone, NR_ACTIVE_FILE);
-	inactive = zone_page_state(zone, NR_INACTIVE_FILE);
+	file = active + zone_page_state(zone, NR_INACTIVE_FILE);
+
+	return (active > file * sysctl_active_inactive_ratio / 100);
 
-	return (active > inactive);
 }
 
 /**
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2010-04-21 09:02:37.000000000 +0200
+++ linux-2.6/include/linux/mm.h	2010-04-21 09:02:51.000000000 +0200
@@ -1467,5 +1467,7 @@
 
 extern void dump_page(struct page *page);
 
+extern int sysctl_active_inactive_ratio;
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */

--------------010109070601080809080006--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
