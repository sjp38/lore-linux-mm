Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 09DD99003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 09:06:25 -0400 (EDT)
Received: by oige126 with SMTP id e126so143095745oig.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 06:06:24 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id el7si3727738pdb.190.2015.07.22.06.06.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 06:06:24 -0700 (PDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NRW00UZ74ELXA40@mailout1.samsung.com> for linux-mm@kvack.org;
 Wed, 22 Jul 2015 22:06:21 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1437114578-2502-1-git-send-email-pintu.k@samsung.com>
 <1437366544-32673-1-git-send-email-pintu.k@samsung.com>
 <20150720082810.GG2561@suse.de> <02c601d0c306$f86d30f0$e94792d0$@samsung.com>
 <20150720175538.GJ2561@suse.de>
In-reply-to: <20150720175538.GJ2561@suse.de>
Subject: RE: [PATCH v3 1/1] kernel/sysctl.c: Add /proc/sys/vm/shrink_memory
 feature
Date: Wed, 22 Jul 2015 18:33:26 +0530
Message-id: <05af01d0c47f$3337ccd0$99a76670$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mel Gorman' <mgorman@suse.de>
Cc: akpm@linux-foundation.org, corbet@lwn.net, vbabka@suse.cz, gorcunov@openvz.org, mhocko@suse.cz, emunson@akamai.com, kirill.shutemov@linux.intel.com, standby24x7@gmail.com, hannes@cmpxchg.org, vdavydov@parallels.com, hughd@google.com, minchan@kernel.org, tj@kernel.org, rientjes@google.com, xypron.glpk@gmx.de, dzickus@redhat.com, prarit@redhat.com, ebiederm@xmission.com, rostedt@goodmis.org, uobergfe@redhat.com, paulmck@linux.vnet.ibm.com, iamjoonsoo.kim@lge.com, ddstreet@ieee.org, sasha.levin@oracle.com, koct9i@gmail.com, cj@linux.com, opensource.ganesh@gmail.com, vinmenon@codeaurora.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pm@vger.kernel.org, qiuxishi@huawei.com, Valdis.Kletnieks@vt.edu, cpgs@samsung.com, pintu_agarwal@yahoo.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, iqbal.ams@samsung.com, pintu.ping@gmail.com, pintu.k@outlook.com

Dear Mel, thank you very much for your comments and suggestions.
I will drop this one and look on further improving direct_reclaim and
compaction.
Just few more comments below before I close.

Also, during this patch, I feel that the hibernation_mode part in
shrink_all_memory can be corrected.
So, can I separately submit the below patch?
That is instead of hard-coding the hibernation_mode, we can get hibernation
status using:
system_entering_hibernation()

Please let me know your suggestion about this changes.

-#ifdef CONFIG_HIBERNATION
+#if defined CONFIG_HIBERNATION || CONFIG_SHRINK_MEMORY
 /*
  * Try to free `nr_to_reclaim' of memory, system-wide, and return the number of
  * freed pages.
@@ -3576,12 +3580,16 @@ unsigned long shrink_all_memory(unsigned long
nr_to_reclaim)
                .may_writepage = 1,
                .may_unmap = 1,
                .may_swap = 1,
-               .hibernation_mode = 1,
        };
        struct zonelist *zonelist = node_zonelist(numa_node_id(), sc.gfp_mask);
        struct task_struct *p = current;
        unsigned long nr_reclaimed;

+       if (system_entering_hibernation())
+               sc.hibernation_mode = 1;
+       else
+               sc.hibernation_mode = 0;
+
        p->flags |= PF_MEMALLOC;
        lockdep_set_current_reclaim_state(sc.gfp_mask);
        reclaim_state.reclaimed_slab = 0;
@@ -3597,6 +3605,28 @@ unsigned long shrink_all_memory(unsigned long
nr_to_reclaim)
 }
 #endif /* CONFIG_HIBERNATION */


> -----Original Message-----
> From: Mel Gorman [mailto:mgorman@suse.de]
> Sent: Monday, July 20, 2015 11:26 PM
> To: PINTU KUMAR
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
> On Mon, Jul 20, 2015 at 09:43:02PM +0530, PINTU KUMAR wrote:
> > Hi,
> >
> > Thank you all for reviewing the patch and providing your valuable
> > comments and suggestions.
> > During the ELC conference many people suggested to release the patch
> > to mainline, so this patch, to get others opinion.
> >
> 
> Unfortunately, in my opinion it runs the risk of creating a different set of
> problems. Either it needs to be run frequently to keep memory free which
incurs
> one set of penalties or it is used too late when there are
> unmovable/unreclaimable pages preventing allocations succeeding in which case
> you are back at the original problem. 

Yes, I completely agree with you that it needs to be invoked at the right time.
Running it too late is of no benefit.

> I see what you did and why it would work in  some cases 
> but I think the main reason it works is because it's run frequently
> enough so memory is never used. 

Yes, we ran frequently, but not so frequently and only when required.
Actually, it gives us best result when calling shrink_memory plus compaction
together,
once after boot, and once during order-4 failure from kernel, or during suspend
state.
It reduced the slowpath count drastically (during 30 application launch test).
VMSTAT		WITHOUT	WITH
slowpath_entered	16659		1859
allocstall		298		149
pageoutrun		2699		1108
compact_stall		244		37
nr_free_cma		2560		2505

Anyways, I agree that if reclaimable pages or SWAP free is not enough, it does
not 
yield good results.

> Grouping pages by mobility actually took
> advantage of a similar property when it increased min_free_kbytes but that was
> much more limited than adding a giant hammer for userspace to reclaim the
> world.
> 
> > If you have any more suggestions to experiment and verify please let me
know.
> >
> 
> I believe I already did. If it's high-order reliability that is important then
you need
> to either reserve the memory or look at protecting the pages using grouping
> pages by mobility. I pointed out what series to look at and the leader
explains
> how it could be adjusted further for the embedded case if necessary.

Thanks. I would definitely look into grouping pages by mobility and those
series.

> 
> If it's latency you are interested in then reclaim/compaction needs to be
modified
> to be more aggressive when it is somehow detected that the high-order
> allocation must succeed for functional correctness. In that case the
relational
> starting point would be to look at should_continue_reclaim and how it relates
to
> compaction.
> 
Thanks. Definitely I will do a deep dive into should_continue_reclaim.

> > The suggestion was only to open up the shrink_all_memory API for some use
> cases.
> >
> > I am not saying that it needs to be called continuously. It can be
> > used only on certain condition and only when deemed necessary.
> > The same technique is already used in hibernation to reduce the RAM
> > snapshot image size.
> 
> Reducing memory usage is not the same as guaranteeing that high-order pages
> are available for allocation.
> 
> --
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
