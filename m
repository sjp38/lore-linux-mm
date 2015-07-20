Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 956A19003C7
	for <linux-mm@kvack.org>; Mon, 20 Jul 2015 12:13:15 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so32937105pdb.0
        for <linux-mm@kvack.org>; Mon, 20 Jul 2015 09:13:15 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id by3si36838399pdb.201.2015.07.20.09.13.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 20 Jul 2015 09:13:13 -0700 (PDT)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NRS0267FNPZKG90@mailout2.samsung.com> for linux-mm@kvack.org;
 Tue, 21 Jul 2015 01:13:11 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1437114578-2502-1-git-send-email-pintu.k@samsung.com>
 <1437366544-32673-1-git-send-email-pintu.k@samsung.com>
 <20150720082810.GG2561@suse.de>
In-reply-to: <20150720082810.GG2561@suse.de>
Subject: RE: [PATCH v3 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory
 feature
Date: Mon, 20 Jul 2015 21:43:02 +0530
Message-id: <02c601d0c306$f86d30f0$e94792d0$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@suse.de>
Cc: akpm@linux-foundation.org, corbet@lwn.net, vbabka@suse.cz, gorcunov@openvz.org, mhocko@suse.cz, emunson@akamai.com, kirill.shutemov@linux.intel.com, standby24x7@gmail.com, hannes@cmpxchg.org, vdavydov@parallels.com, hughd@google.com, minchan@kernel.org, tj@kernel.org, rientjes@google.com, xypron.glpk@gmx.de, dzickus@redhat.com, prarit@redhat.com, ebiederm@xmission.com, rostedt@goodmis.org, uobergfe@redhat.com, paulmck@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, ddstreet@ieee.org, sasha.levin@oracle.com, koct9i@gmail.com, cj@linux.com, opensource.ganesh@gmail.com, vinmenon@codeaurora.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, qiuxishi@huawei.com, Valdis.Kletnieks@vt.edu, cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com, pintu.ping@gmail.com, pintu.k@outlook.com

Hi,

Thank you all for reviewing the patch and providing your valuable comments and
suggestions.
During the ELC conference many people suggested to release the patch to
mainline, so this patch, to get others opinion.

If you have any more suggestions to experiment and verify please let me know.

The suggestion was only to open up the shrink_all_memory API for some use cases.

I am not saying that it needs to be called continuously. It can be used only on
certain condition and only when deemed necessary.
The same technique is already used in hibernation to reduce the RAM snapshot
image size.
But in embedded world, hibernation is not used, so this feature cannot be
utilized.

Thanks once again for the review and feedback.


> -----Original Message-----
> From: Mel Gorman [mailto:mgorman@suse.de]
> Sent: Monday, July 20, 2015 1:58 PM
> To: Pintu Kumar
> Cc: akpm@linux-foundation.org; corbet@lwn.net; vbabka@suse.cz;
> gorcunov@openvz.org; mhocko@suse.cz; emunson@akamai.com;
> kirill.shutemov@linux.intel.com; standby24x7@gmail.com;
> hannes@cmpxchg.org; vdavydov@parallels.com; hughd@google.com;
> minchan@kernel.org; tj@kernel.org; rientjes@google.com;
> xypron.glpk@gmx.de; dzickus@redhat.com; prarit@redhat.com;
> ebiederm@xmission.com; rostedt@goodmis.org; uobergfe@redhat.com;
> paulmck@linux.vnet.ibm.com; iamjoonsoo.kim@lge.com; ddstreet@ieee.org;
> sasha.levin@oracle.com; koct9i@gmail.com; cj@linux.com;
> opensource.ganesh@gmail.com; vinmenon@codeaurora.org; linux-
> doc@vger.kernel.org; linux-kernel@vger.kernel.org; linux-mm@kvack.org; linux-
> pm@vger.kernel.org; qiuxishi@huawei.com; Valdis.Kletnieks@vt.edu;
> cpgs@samsung.com; pintu_agarwal@yahoo.com; vishnu.ps@samsung.com;
> rohit.kr@samsung.com; iqbal.ams@samsung.com; pintu.ping@gmail.com;
> pintu.k@outlook.com
> Subject: Re: [PATCH v3 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory
> feature
> 
> On Mon, Jul 20, 2015 at 09:59:04AM +0530, Pintu Kumar wrote:
> > This patch provides 2 things:
> > 1. Add new control called shrink_memory in /proc/sys/vm/.
> > This control can be used to aggressively reclaim memory system-wide in
> > one shot from the user space. A value of 1 will instruct the kernel to
> > reclaim as much as totalram_pages in the system.
> > Example: echo 1 > /proc/sys/vm/shrink_memory
> >
> > If any other value than 1 is written to shrink_memory an error EINVAL
> > occurs.
> >
> > 2. Enable shrink_all_memory API in kernel with new
> CONFIG_SHRINK_MEMORY.
> > Currently, shrink_all_memory function is used only during hibernation.
> > With the new config we can make use of this API for non-hibernation
> > case also without disturbing the hibernation case.
> >
> > The detailed paper was presented in Embedded Linux Conference,
> > Mar-2015 http://events.linuxfoundation.org/sites/events/files/slides/
> > %5BELC-2015%5D-System-wide-Memory-Defragmenter.pdf
> >
> 
> Johannes has already reviewed this series and explained why it's a bad idea.
This
> is just a note to say that I agree the points he made and also think that
adding an
> additional knob to reclaim data from user space is a bad idea. Even
drop_caches
> is only intended as a debugging tool to illustrate cases where normal reclaim
is
> broken. Similarly compact_node exists as a debugging tool to check if direct
> compaction is not behaving as expected.
> 
> If this is invoked when high-order allocations start failing and memory is
> fragmented with unreclaimable memory then it'll potentially keep thrashing
> depending on the userspace monitor implementation.  If the latency of a high
> order allocation is important then reclaim/compaction should be examined and
> improved. If the reliability of high-order allocations are important then you
either
> need to reserve the memory in advance. If that is undesirable due to a
> constrained memory environment then one approach is to modify how pages are
> grouped by mobility as described in the leader of the series "Remove zonelist
> cache and high-order watermark checking".
> There are two suggestions there for out-of-tree patches that would make high-
> order allocations more reliable that are not suitable for mainline.
> 
> Yes, I read your presentation but lets go through the use cases you list
again;
> 
> > Various other use cases where this can be used:
> > ----------------------------------------------------------------------
> > ------
> > 1) Just after system boot-up is finished, using the sysctl configuration
from
> >    bootup script.
> 
> Almost no benefit. Any page cache that is active and now cold would be
trivially
> reclaimed later.
> 
> > 2) During system suspend state, after suspend_freeze_processes()
> >    [kernel/power/suspend.c]
> >    Based on certain condition about fragmentation or free memory state.
> 
> No gain.
> 
> > 3) From Android ION system heap driver, when order-4 allocation starts
failing.
> >    By calling shrink_all_memory, in a separate worker thread, based on
certain
> >    condition.
> 
> If order-4 allocations fail when shrink_all_memory works and the order-4
> allocation is required to work then the aggressiveness of reclaim/compaction
> needs to be fixed to reclaim all system memory if necessary. Right now it can
bail
> because generally it is expected that no subsystem depends on high order
> allocations succeeding for functional correctness.
> 
> > 4) It can be combined with compact_memory to achieve better results on
> memory
> >    fragmentation.
> 
> Only by reclaiming the world. In 3.0 the system behaved like this. High order
> stress tests could take hours to complete as the system was continually
thrashed.
> Today the same test would complete in about 15 minutes albeit with lower
> allocation success rates. We ran into multiple issues where high order
allocation
> requests caused the system to thrash and triggering such thrashing from
> userspace is not an improvement.
> 
> > 5) It can be helpful in debugging and tuning various vm parameters.
> 
> No more than drop_caches is.
> 
> > 6) It can be helpful to identify how much of maximum memory could be
> >    reclaimable at any point of time.
> 
> Only by reclaiming the world. A less destructive means is using MemAvailable
> from /proc/meminfo
> 
> >    And how much higher-order pages could be formed with this amount of
> >    reclaimable memory.
> 
> Only by reclaiming the world
> 
> >    Thus it can be helpful in accordingly tuning the reserved memory needs
> >    of a system.
> 
> By which time it's too late as a reboot will be necessary to set the reserve.
> 
> > 7) It can be helpful in properly tuning the SWAP size in the system.
> 
> Only for a single point in time as it's workload dependant. The same data can
be
> inferred from smaps.
> 
> >    In shrink_all_memory, we enable may_swap = 1, that means all unused pages
> >    will be swapped out.
> >    Thus, running shrink_memory on a heavy loaded system, we can check how
> much
> >    swap is getting full.
> >    That can be the maximum swap size with a 10% delta.
> >    Also if ZRAM is used, it helps us in compressing and storing the pages
for
> >    later use.
> > 8) It can be helpful to allow more new applications to be launched, without
> >    killing the older once.
> 
> Reclaim would achieve the same effect over time.
> 
> >    And moving the least recently used pages to the SWAP area.
> >    Thus user data can be retained.
> > 9) Can be part of a system utility to quickly defragment entire system
> >    memory.
> 
> Any memory that is not on the LRU or indirectly pinned by pages on the LRU are
> unaffected.
> 
> If high-order allocation latency or reliability is important then you really
need a
> different solution because unless this thing runs continually to keep memory
> unused then it'll eventually fail hard and the system will perform poorly in
the
> meantime.
> 
> --
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
