Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B12666B00F7
	for <linux-mm@kvack.org>; Wed, 22 Apr 2009 15:22:33 -0400 (EDT)
Subject: Re: [Patch] mm tracepoints update - use case.
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <1240402037.4682.3.camel@dhcp47-138.lab.bos.redhat.com>
References: <1240353915.11613.39.camel@dhcp-100-19-198.bos.redhat.com>
	 <20090422095916.627A.A69D9226@jp.fujitsu.com>
	 <20090422095727.GG18226@elte.hu>
	 <1240402037.4682.3.camel@dhcp47-138.lab.bos.redhat.com>
Content-Type: multipart/mixed; boundary="=-MVabRF+eP4gEAZxPAegl"
Date: Wed, 22 Apr 2009 15:22:31 -0400
Message-Id: <1240428151.11613.46.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, =?ISO-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, eduard.munteanu@linux360.ro, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, rostedt@goodmis.org
List-ID: <linux-mm.kvack.org>


--=-MVabRF+eP4gEAZxPAegl
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2009-04-22 at 08:07 -0400, Larry Woodman wrote:
> On Wed, 2009-04-22 at 11:57 +0200, Ingo Molnar wrote:
> > * KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > > In past thread, Andrew pointed out bare page tracer isn't useful. 
> > 
> > (do you have a link to that mail?)
> > 
> > > Can you make good consumer?
> 
> I will work up some good examples of what these are useful for.  I use
> the mm tracepoint data in the debugfs trace buffer to locate customer
> performance problems associated with memory allocation, deallocation,
> paging and swapping frequently, especially on large systems.
> 
> Larry

Attached is an example of what the mm tracepoints can be used for:



--=-MVabRF+eP4gEAZxPAegl
Content-Disposition: attachment; filename=usecase
Content-Type: text/plain; name=usecase; charset=utf-8
Content-Transfer-Encoding: 7bit


At Red Hat I use these mm tracepoints in an older kernel version(2.6.18).
The following steps illustrate how the mm tracepoints were used to debug 
and ultimately fix a problem. 

1.) We had customer complaints about large NUMA systems burning up 100% of
a CPU in system mode when running memory applications that require at least
half but not all of the of the memory.

---------- top output -------------------------------------------------------
Tasks: 212 total,   2 running, 210 sleeping,   0 stopped,   0 zombie
Cpu0  :  0.0%us,  0.3%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu1  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu2  :  0.0%us,  0.3%sy,  0.0%ni, 99.7%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu3  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu4  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu5  :  0.0%us,100.0%sy,  0.0%ni,  0.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu6  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Cpu7  :  0.0%us,  0.0%sy,  0.0%ni,100.0%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:  16334996k total,  8979320k used,  7355676k free,     3280k buffers
Swap:  2031608k total,   129572k used,  1902036k free,   353220k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
10723 root      20   0 16.0g 8.0g  376 R  100 51.4   0:17.78 mem
10724 root      20   0 12880 1224  872 R    1  0.0   0:00.06 top
 7822 root      20   0 10868  348  272 S    0  0.0   0:06.00 irqbalance
-----------------------------------------------------------------------------

2.) Using the mm tracepoints I could immediately see that __zone_reclaim() is 
being called directly out of the memory allocator indicating that 
zone_reclaim_mode is non-zero(1).  In addition I could see that the priority
was decremented to zero and that 12342 pages had been reclaimed rather than
just enough to satisfy the page allocation request.

-----------------------------------------------------------------------------
# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
<mem>-10723 [005]  6976.285610: mm_directreclaim_reclaimzone: reclaimed=12342, priority=0
-----------------------------------------------------------------------------

3.) zone_reclaim_mode is set to 1 in build_zonelists() on NUMA systems with 
sufficient distance between the nodes:

                /*
                 * If another node is sufficiently far away then it is better
                 * to reclaim pages in a zone before going off node.
                 */
                if (distance > RECLAIM_DISTANCE)
                        zone_reclaim_mode = 1;


4.) To verify zone_reclaim_mode was involved I disabled it by:
"echo 0 > /proc/sys/vm/zone_reclaim_mode" and sure enough the problem went
away.

5.) Next, after a reboot using the mm tracepoints I could see several calls 
were made to shrink_zone() and it had reclaimed many more pages than it 
should have:

-----------------------------------------------------------------------------
# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
           <mem>-10723 [005]   282.776271: mm_pagereclaim_shrinkzone: reclaimed=12342
           <mem>-10723 [005]   282.781209: mm_pagereclaim_shrinkzone: reclaimed=3540
           <mem>-10723 [005]   282.801194: mm_pagereclaim_shrinkzone: reclaimed=7528
-----------------------------------------------------------------------------

6.) In between the shrink_zone() runs, shrink_active_list() and 
shrink_inactive_list() had run several times, each time fulfilling the memory
request from the pagecache.

-----------------------------------------------------------------------------
# tracer: nop
#
#           TASK-PID    CPU#    TIMESTAMP  FUNCTION
#              | |       |          |         |
           <mem>-10723 [005]   282.755691: mm_pagereclaim_shrinkinactive: scanned=32, pagecache, priority=4
           <mem>-10723 [005]   282.755766: mm_pagereclaim_shrinkinactive: scanned=32, pagecache, priority=4
           <mem>-10723 [005]   282.755795: mm_pagereclaim_shrinkinactive: scanned=32, pagecache, priority=4
 ...
           <mem>-10723 [005]   282.755845: mm_pagereclaim_shrinkactive: scanned=32, pagecache, priority=4
           <mem>-10723 [005]   282.755882: mm_pagereclaim_shrinkactive: scanned=32, pagecache, priority=4
           <mem>-10723 [005]   282.755938: mm_pagereclaim_shrinkactive: scanned=32, pagecache, priority=4
-----------------------------------------------------------------------------

7.) This indicates that the direct memory reclaim code path called directly 
from the memory allocator when zone_reclaim_mode is non-zero could reclaim 
far more than SWAP_CLUSTER_MAX pages and consume significant CPU time doing 
it:

-----------------------------------------------------------------------------
get_page_from_freelist(..)

                if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
                        unsigned long mark;
                        if (alloc_flags & ALLOC_WMARK_MIN)
                                mark = (*z)->pages_min;
                        else if (alloc_flags & ALLOC_WMARK_LOW)
                                mark = (*z)->pages_low;
                        else
                                mark = (*z)->pages_high;
                        if (!zone_watermark_ok(*z, order, mark,
                                    classzone_idx, alloc_flags))
                                if (!zone_reclaim_mode ||
                                    !zone_reclaim(*z, gfp_mask, order))
                                        continue;
                }

-----------------------------------------------------------------------------

8.) On further investigation I found that the 2.6.18 shrink_zone() was missing
an upstream patch that bails out as soon as SWAP_CLUSTER_MAX pages have been 
reclaimed.

-----------------------------------------------------------------------------
shrink_zone(...)

+               /*
+                * On large memory systems, scan >> priority can become
+                * really large. This is fine for the starting priority;
+                * we want to put equal scanning pressure on each zone.
+                * However, if the VM has a harder time of freeing pages,
+                * with multiple processes reclaiming pages, the total
+                * freeing target can get unreasonably large.
+                */
+               if (nr_reclaimed > swap_cluster_max &&
+                       priority < DEF_PRIORITY && !current_is_kswapd())
+                       break; 
-----------------------------------------------------------------------------

9.) Including this patch in shrink_zone() fixed the problem by terminating
one enough memory is reclaimed to satisfy the __alloc_pages() request on the
local node.


This example is realitively simple and does not illustrate the use of
every one of the proposed mm tracepoints,   It show how they can be used to
quickly drill down into performance and other problems without several
itterations of rebuilding the kernel adding debug code.  


--=-MVabRF+eP4gEAZxPAegl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
