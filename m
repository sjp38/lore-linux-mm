Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CD3F36B01EE
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 10:01:26 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.1/8.13.1) with ESMTP id o3RE17j7012721
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 14:01:07 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3RE11O01593528
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 16:01:07 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o3RE10AE003700
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 16:01:01 +0200
Message-ID: <4BD6EE18.4090909@linux.vnet.ibm.com>
Date: Tue, 27 Apr 2010 16:00:56 +0200
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: Subject: [PATCH][RFC] mm: make working set portion that is protected
 tunable v2
References: <20100322235053.GD9590@csn.ul.ie> <20100419214412.GB5336@cmpxchg.org>	 <4BCD55DA.2020000@linux.vnet.ibm.com> <20100420153202.GC5336@cmpxchg.org> <4BCDE2F0.3010009@redhat.com> <4BCE7DD1.70900@linux.vnet.ibm.com>	 <4BCEAAC6.7070602@linux.vnet.ibm.com> <4BCEFB4C.1070206@redhat.com>	 <4BCFEAD0.4010708@linux.vnet.ibm.com> <4BD57213.7060207@linux.vnet.ibm.com> <p2y2f11576a1004260459jcaf79962p50e4d29f990019ee@mail.gmail.com> <4BD58A6C.6040104@linux.vnet.ibm.com> <4BD5A121.8060206@redhat.com>
In-Reply-To: <4BD5A121.8060206@redhat.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, gregkh@novell.com, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, Corrado Zoccolo <czoccolo@gmail.com>
List-ID: <linux-mm.kvack.org>



Rik van Riel wrote:
> On 04/26/2010 08:43 AM, Christian Ehrhardt wrote:
> 
>>>> This patch creates a knob to help users that have workloads suffering
>>>> from the
>>>> fix 1:1 active inactive ratio brought into the kernel by "56e49d21
>>>> vmscan:
>>>> evict use-once pages first".
>>>> It also provides the tuning mechanisms for other users that want an
>>>> even bigger
>>>> working set to be protected.
>>>
>>> We certainly need no knob. because typical desktop users use various
>>> application,
>>> various workload. then, the knob doesn't help them.
>>
>> Briefly - We had discussed non desktop scenarios where like a day load
>> that builds up the working set to 50% and a nightly backup job which
>> then is unable to use that protected 50% when sequentially reading a lot
>> of disks and due to that doesn't finish before morning.
> 
> This is a red herring.  A backup touches all of the
> data once, so it does not need a lot of page cache
> and will not "not finish before morning" due to the
> working set being protected.
>
> You're going to have to come up with a more realistic
> scenario than that.

I completely agree that a backup case is read once and therefore doesn't
benefit from caching itself, but you know my scenario from the thread
where this patch emerged from.
="Parallel iozone sequential read - resembling the classic backup case
(read once + sequential)."

While caching isn't helping the classic way, by having data in cache
ready on the next access it is still used transparently as the system
is reading ahead into page cache to assist the sequentially reading
process.
Yes it doesn't happen with direct IO and some, but unfortunately not
all backup tools use DIO. Additionally not all backup jobs have a whole
night, and this can really be a decision maker if you can quickly pump
out your 100 TB main database in 10 or 20 minutes.

So here comes the problem, due to the 50% preserved I assume it comes
into trouble allocating that page cache memory in time. So much that it
even slows down the load - meaning long enough to let the application
completely consume the data already read and then still letting it wait.
More about that below.

Now IMHO this feels comparable to a classic backup job, and by loosing
60% Throughput (more than a Gb/s) is seems neither red nor smells like
fish to me.

>> I personally just don't feel too good knowing that 50% of my memory
>> might hang around unused for many hours while they could be of some use.
>> I absolutely agree with the old intention and see how the patch helped
>> with the latency issue Elladan brought up in the past - but it just
>> looks way too aggressive to protect it "forever" for some server use 
>> cases.
> 
> So far we have seen exactly one workload where it helps
> to reduce the size of the active file list, and that is
> not due to any need for caching more inactive pages.
>
> On the contrary, it is because ALL OF THE INACTIVE PAGES
> are in flight to disk, all under IO at the same time.

Ok this time I think I got your point much better - sorry for 
being confused.
Discard my patch, but I'd really like to clarify and verify your 
assumption in conjunction with my findings and would be happy
if you can help me with that.

As mentioned the case that suffers from the 50% memory protected is
iozone read - so it would be "in flight FROM disk", but I guess that
it is not important if it is from or to right ?

Effectively I have two read cases, one with caches dropped which then 
has almost full memory for page cache in the read case. And the other 
one with a few writes before filling up the protected 50% leading to a 
read case with only half of the memory for page cache.
Now if I really got you right this time the issue is caused by the
fact that the parallel read ahead on all 16 disks creates so much I/O
in flight that the 128M (=50% that are left) are not enough.
>From the past we know that the time lost for the -60% Throughput was 
spent in a loop around direct_reclaim&congestion_wait trying to get the
memory for the page cache reads - would you consider it possible that
we now run into a scenario splitting the memory like this?:
- 50% active file protected
- a lot of the other half related to I/O that is currently
  in flight from the disk -> not free-able too?
- almost nothing to free when allocating for the next read to page 
  cache (can only take pages above low watermark) -> waiting

I updated my old counter patch, that I used to verify the old issue were
we spent so much time in a full timeout of congestion wait. Thanks to
Mel this was fixed (I have his watermark wait patch applied), but I
assume having 50% protected I just run into the shortened wait more
often or wait longer for watermarks to still be an issue (due to 50%
not free-able).
See the patch inlined at the end of the mail for details what/how
it is exactly counted.

As before the scenario is iozone on 16 disks in parallel with 1 iozone
child per disk.
I ran:
- write, write, write, read -> bad case
- drop cache, read -> good case
Read throughput still drops by ~60% comparing good to bad case.
Here are the numbers I got for those two cases by my counters and
meminfo:

Value                           Initial state          Write 1            Write 2             Write 3     Read after writes (bad)      Read after DC (good)	
watermark_wait_duration (ns)                0    9,902,333,643     12,288,444,574      24,197,098,221             317,175,021,553            35,002,926,894
watermark_wait                              0            24102              26708               35285                       29720                     15515
pages_direct_reclaim                        0            59195              65010               86777                       90883                     66672
failed_pages_direct_reclaim                 0            24144              26768               35343                       29733                     15525
failed_pages_direct_reclaim_but_progress    0            24144              26768               35343                       29733                     15525

MemTotal:                              248912           248912             248912              248912                      248912                    248912
MemFree:                               185732             4868               5028                3780                        3064                      7136
Buffers:                                  536            33588              65660               84296                       81868                     32072
Cached:                                  9480           145252             111672               93736                       98424                    149724
Active:                                 11052            43920              76032               89084                       87780                     38024
Inactive:                                6860           142628             108980               96528                      100280                    151572
Active(anon):                            5092             4452               4428                4364                        4516                      4492
Inactive(anon):                          6480             6608               6604                6604                        6604                      6604
Active(file):                            5960            39468              71604               84720                       83264                     33532
Inactive(file):                           380           136020             102376               89924                       93676                    144968
Unevictable:                             3952             3952               3952                3952                        3952                      3952
							
Real Time passed in seconds                              48.83             49.38                50.35                       40.62                      22.61	
AVG wait time waitduration/#                           410,851           460,104              685,762                  10,672,107                  2,256,070	=> x5 longer waits in avg
                                                                                                                                                      -52.20%	bad case runs about twice as often into waits

These numbers seem to point toward my assumption, that the 50% preserved
cause the system to be unable to find memory fast enough.
Happening twice as often to run into the wait after a direct_reclaim
that made progress, but not finding a free page.
And then in average waiting about 5 times longer to get things freed up
enough reaching the watermark and get woken up.


####

Eventually I'd also really like to completely understand why the active
file pages grow when I execute the same iozone write load three times.
They effectively write the same files in the same directories without 
being a journaling file system (The effect can be seen in the table
above as well).

If one of these write runs would use more than ~30M active file pages
they would be allocated and afterwards protected, but they aren't.
Then after the second run I see ~60M active file pages.
As mentioned before I would assume that it either just reuses what is
in memory from the first run, or if it really uses new stuff then the
time has come to throw the old away.

Therefore I would assume that it should never get much more after the
first run as long as they are essentially doing the same.
Does someone already know or has a good assumption what might be
growing in these buffers?
Is there a good interface to check what is buffered and protected atm?

> Caching has absolutely nothing to do with the regression
> you ran into.

As mentioned above not by means of "having it in the cache for another
fast access" yes.
But maybe by "not getting memory for reads into page cache fast enough".

-- 

GrA 1/4 sse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance


#### patch for the counters shown in table above ######
Subject: [PATCH][DEBUGONLY] mm: track allocation waits

From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

This patch adds some debug counters to track how often a system runs into
waits after direct reclaim (happens in case of did_some_progress & !page)
and how much time it spends there waiting.

#for debugging only#

Signed-off-by: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
---

[diffstat]
 include/linux/sysctl.h |    1
 kernel/sysctl.c        |   57 +++++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c        |   17 ++++++++++++++
 3 files changed, 75 insertions(+)

[diff]
diff -Naur linux-2.6.32.11-0.3.99.6.626e022.orig/include/linux/sysctl.h linux-2.6.32.11-0.3.99.6.626e022/include/linux/sysctl.h
--- linux-2.6.32.11-0.3.99.6.626e022.orig/include/linux/sysctl.h	2010-04-27 12:01:54.000000000 +0200
+++ linux-2.6.32.11-0.3.99.6.626e022/include/linux/sysctl.h	2010-04-27 12:03:56.000000000 +0200
@@ -68,6 +68,7 @@
 	CTL_BUS=8,		/* Busses */
 	CTL_ABI=9,		/* Binary emulation */
 	CTL_CPU=10,		/* CPU stuff (speed scaling, etc) */
+	CTL_PERF=11,		/* Performance counters and timer sums for debugging */
 	CTL_XEN=123,		/* Xen info and control */
 	CTL_ARLAN=254,		/* arlan wireless driver */
 	CTL_S390DBF=5677,	/* s390 debug */
diff -Naur linux-2.6.32.11-0.3.99.6.626e022.orig/kernel/sysctl.c linux-2.6.32.11-0.3.99.6.626e022/kernel/sysctl.c
--- linux-2.6.32.11-0.3.99.6.626e022.orig/kernel/sysctl.c	2010-04-27 14:26:04.000000000 +0200
+++ linux-2.6.32.11-0.3.99.6.626e022/kernel/sysctl.c	2010-04-27 15:44:54.000000000 +0200
@@ -183,6 +183,7 @@
 	.default_set.list = LIST_HEAD_INIT(root_table_header.ctl_entry),
 };
 
+static struct ctl_table perf_table[];
 static struct ctl_table kern_table[];
 static struct ctl_table vm_table[];
 static struct ctl_table fs_table[];
@@ -236,6 +237,13 @@
 		.mode		= 0555,
 		.child		= dev_table,
 	},
+	{
+		.ctl_name	= CTL_PERF,
+		.procname	= "perf",
+		.mode		= 0555,
+		.child		= perf_table,
+	},
+
 /*
  * NOTE: do not add new entries to this table unless you have read
  * Documentation/sysctl/ctl_unnumbered.txt
@@ -254,6 +262,55 @@
 static int max_sched_shares_ratelimit = NSEC_PER_SEC; /* 1 second */
 #endif
 
+extern unsigned long perf_count_watermark_wait;
+extern unsigned long perf_count_pages_direct_reclaim;
+extern unsigned long perf_count_failed_pages_direct_reclaim;
+extern unsigned long perf_count_failed_pages_direct_reclaim_but_progress;
+extern unsigned long perf_count_watermark_wait_duration;
+static struct ctl_table perf_table[] = {
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname       = "perf_count_watermark_wait_duration",
+		.data           = &perf_count_watermark_wait_duration,
+		.mode           = 0666,
+		.maxlen		= sizeof(unsigned long),
+		.proc_handler   = &proc_doulongvec_minmax,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname       = "perf_count_watermark_wait",
+		.data           = &perf_count_watermark_wait,
+		.mode           = 0666,
+		.maxlen		= sizeof(unsigned long),
+		.proc_handler   = &proc_doulongvec_minmax,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname       = "perf_count_pages_direct_reclaim",
+		.data           = &perf_count_pages_direct_reclaim,
+		.maxlen		= sizeof(unsigned long),
+		.mode           = 0666,
+		.proc_handler   = &proc_doulongvec_minmax,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname       = "perf_count_failed_pages_direct_reclaim",
+		.data           = &perf_count_failed_pages_direct_reclaim,
+		.maxlen		= sizeof(unsigned long),
+		.mode           = 0666,
+		.proc_handler   = &proc_doulongvec_minmax,
+	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname       = "perf_count_failed_pages_direct_reclaim_but_progress",
+		.data           = &perf_count_failed_pages_direct_reclaim_but_progress,
+		.maxlen		= sizeof(unsigned long),
+		.mode           = 0666,
+		.proc_handler   = &proc_doulongvec_minmax,
+	},
+	{ .ctl_name = 0 }
+};
+
 static struct ctl_table kern_table[] = {
 	{
 		.ctl_name	= CTL_UNNUMBERED,
diff -Naur linux-2.6.32.11-0.3.99.6.626e022.orig/mm/page_alloc.c linux-2.6.32.11-0.3.99.6.626e022/mm/page_alloc.c
--- linux-2.6.32.11-0.3.99.6.626e022.orig/mm/page_alloc.c	2010-04-27 12:01:55.000000000 +0200
+++ linux-2.6.32.11-0.3.99.6.626e022/mm/page_alloc.c	2010-04-27 14:06:40.000000000 +0200
@@ -191,6 +191,7 @@
 		wake_up_interruptible(&watermark_wq);
 }
 
+unsigned long perf_count_watermark_wait = 0;
 /**
  * watermark_wait - Wait for watermark to go above low
  * @timeout: Wait until watermark is reached or this timeout is reached
@@ -202,6 +203,7 @@
 	long ret;
 	DEFINE_WAIT(wait);
 
+	perf_count_watermark_wait++;
 	prepare_to_wait(&watermark_wq, &wait, TASK_INTERRUPTIBLE);
 
 	/*
@@ -1725,6 +1727,10 @@
 	return page;
 }
 
+unsigned long perf_count_pages_direct_reclaim = 0;
+unsigned long perf_count_failed_pages_direct_reclaim = 0;
+unsigned long perf_count_failed_pages_direct_reclaim_but_progress = 0;
+
 /* The really slow allocator path where we enter direct reclaim */
 static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
@@ -1761,6 +1767,13 @@
 					zonelist, high_zoneidx,
 					alloc_flags, preferred_zone,
 					migratetype);
+
+	perf_count_pages_direct_reclaim++;
+	if (!page)
+		perf_count_failed_pages_direct_reclaim++;
+	if (!page && *did_some_progress)
+		perf_count_failed_pages_direct_reclaim_but_progress++;
+
 	return page;
 }
 
@@ -1841,6 +1854,7 @@
 	return alloc_flags;
 }
 
+unsigned long perf_count_watermark_wait_duration = 0;
 static inline struct page *
 __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
@@ -1961,8 +1975,11 @@
 	/* Check if we should retry the allocation */
 	pages_reclaimed += did_some_progress;
 	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
+		unsigned long t1;
 		/* Too much pressure, back off a bit at let reclaimers do work */
+		t1 = get_clock();
 		watermark_wait(HZ/50);
+		perf_count_watermark_wait_duration += ((get_clock() - t1) * 125) >> 9;
 		goto rebalance;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
