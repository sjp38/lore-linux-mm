Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 13D3A6B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 02:21:22 -0400 (EDT)
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate6.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o3M6LADm031617
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 06:21:10 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3M6LAC31171472
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 07:21:10 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o3M6L9ct004855
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 07:21:09 +0100
Message-ID: <4BCFEAD0.4010708@linux.vnet.ibm.com>
Date: Thu, 22 Apr 2010 08:21:04 +0200
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone pressure
References: <20100322235053.GD9590@csn.ul.ie> <4BA940E7.2030308@redhat.com> <20100324145028.GD2024@csn.ul.ie> <4BCC4B0C.8000602@linux.vnet.ibm.com> <20100419214412.GB5336@cmpxchg.org> <4BCD55DA.2020000@linux.vnet.ibm.com> <20100420153202.GC5336@cmpxchg.org> <4BCDE2F0.3010009@redhat.com> <4BCE7DD1.70900@linux.vnet.ibm.com> <4BCEAAC6.7070602@linux.vnet.ibm.com> <4BCEFB4C.1070206@redhat.com>
In-Reply-To: <4BCEFB4C.1070206@redhat.com>
Content-Type: multipart/mixed;
 boundary="------------090802010902090800010405"
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com, Corrado Zoccolo <czoccolo@gmail.com>, Ehrhardt Christian <ehrhardt@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------090802010902090800010405
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Trying to answer and consolidate all open parts of this thread down below.

Rik van Riel wrote:
> On 04/21/2010 03:35 AM, Christian Ehrhardt wrote:
>>
>>
>> Christian Ehrhardt wrote:
>>>
>>>
>>> Rik van Riel wrote:
>>>> On 04/20/2010 11:32 AM, Johannes Weiner wrote:
>>>>
>>>>> The idea is that it pans out on its own. If the workload changes, new
>>>>> pages get activated and when that set grows too large, we start
>>>>> shrinking
>>>>> it again.
>>>>>
>>>>> Of course, right now this unscanned set is way too large and we can 
>>>>> end
>>>>> up wasting up to 50% of usable page cache on false active pages.
>>>>
>>>> Thing is, changing workloads often change back.
>>>>
>>>> Specifically, think of a desktop system that is doing
>>>> work for the user during the day and gets backed up
>>>> at night.
>>>>
>>>> You do not want the backup to kick the working set
>>>> out of memory, because when the user returns in the
>>>> morning the desktop should come back quickly after
>>>> the screensaver is unlocked.
>>>
>>> IMHO it is fine to prevent that nightly backup job from not being
>>> finished when the user arrives at morning because we didn't give him
>>> some more cache - and e.g. a 30 sec transition from/to both optimized
>>> states is fine.
>>> But eventually I guess the point is that both behaviors are reasonable
>>> to achieve - depending on the users needs.
>>>
>>> What we could do is combine all our thoughts we had so far:
>>> a) Rik could create an experimental patch that excludes the in flight
>>> pages
>>> b) Johannes could create one for his suggestion to "always scan active
>>> file pages but only deactivate them when the ratio is off and
>>> otherwise strip buffers of clean pages"
> 
> I think you are confusing "buffer heads" with "buffers".
> 
> You can strip buffer heads off pages, but that is not
> your problem.
> 
> "buffers" in /proc/meminfo stands for cached metadata,
> eg. the filesystem journal, inodes, directories, etc...
> Caching such metadata is legitimate, because it reduces
> the number of disk seeks down the line.

Yeah I mixed that as well, thanks for clarification (Johannes wrote a 
similar response effectively kicking b) from the list of things we could 
do).

Regarding your question from thread reply#3
 > How on earth would a backup job benefit from cache?
 >
 > It only accesses each bit of data once, so caching the
 > to-be-backed-up data is a waste of memory.

If it is a low memory system with a lot of disks (like in my case) 
giving it more cache allows e.g. larger readaheads or less cache 
trashing - but it might be ok, as it might be rare case to hit all those 
constraints at once.
But as we discussed before on virtual servers it can happen from time to 
time due to balooning and much more disk attachments etc.



So definitely not the majority of cases around, but some corner cases 
here and there that would benefit at least from making the preserved 
ratio configurable if we don't find a good way to let it take the memory 
back without hurting the intended preservation functionality.

For that reason - how about the patch I posted yesterday (to consolidate 
this spread out thread I attach it here again)



And finally I still would like to understand why writing the same files 
three times increase the active file pages each time instead of reusing 
those already brought into memory by the first run.
To collect that last open thread as well I'll cite my own question here:

 > Thinking about it I wondered for what these Buffers are protected.
 > If the intention to save these buffers is for reuse with similar 
loads > I wonder why I "need" three iozones to build up the 85M in my case.

 > Buffers start at ~0, after iozone run 1 they are at ~35, then after 
#2 > ~65 and after run #3 ~85.
 > Shouldn't that either allocate 85M for the first directly in case 
that > much is needed for a single run - or if not the second and third 
run > > just "resuse" the 35M Buffers from the first run still held?

 > Note - "1 iozone run" means "iozone ... -i 0" which sequentially
 > writes and then rewrites a 2Gb file on 16 disks in my current case.

Trying to answering this question my self using your buffer details 
above doesn't completely fit without further clarification, as the same 
files should have the same dir, inode, ... (all ext2 in my case, so no 
journal data as well).


-- 

GrA 1/4 sse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--------------090802010902090800010405
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

--------------090802010902090800010405--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
