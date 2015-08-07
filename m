Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0DB066B0038
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 08:48:45 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so52317237pac.3
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 05:48:44 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id c3si17386190pdj.114.2015.08.07.05.48.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 07 Aug 2015 05:48:44 -0700 (PDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NSP01X4EQ95WX20@mailout3.samsung.com> for linux-mm@kvack.org;
 Fri, 07 Aug 2015 21:48:41 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1438931334-25894-1-git-send-email-pintu.k@samsung.com>
 <20150807074422.GE26566@dhcp22.suse.cz>
In-reply-to: <20150807074422.GE26566@dhcp22.suse.cz>
Subject: RE: [PATCH 1/1] mm: vmstat: introducing vm counter for slowpath
Date: Fri, 07 Aug 2015 18:16:47 +0530
Message-id: <0f2101d0d10f$594e4240$0beac6c0$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.k@outlook.com, vishnu.ps@samsung.com, rohit.kr@samsung.com

Hi,

> -----Original Message-----
> From: Michal Hocko [mailto:mhocko@kernel.org]
> Sent: Friday, August 07, 2015 1:14 PM
> To: Pintu Kumar
> Cc: akpm@linux-foundation.org; linux-kernel@vger.kernel.org; linux-
> mm@kvack.org; minchan@kernel.org; dave@stgolabs.net; koct9i@gmail.com;
> mgorman@suse.de; vbabka@suse.cz; js1304@gmail.com;
> hannes@cmpxchg.org; alexander.h.duyck@redhat.com;
> sasha.levin@oracle.com; cl@linux.com; fengguang.wu@intel.com;
> cpgs@samsung.com; pintu_agarwal@yahoo.com; pintu.k@outlook.com;
> vishnu.ps@samsung.com; rohit.kr@samsung.com
> Subject: Re: [PATCH 1/1] mm: vmstat: introducing vm counter for slowpath
> 
> On Fri 07-08-15 12:38:54, Pintu Kumar wrote:
> > This patch add new counter slowpath_entered in /proc/vmstat to track
> > how many times the system entered into slowpath after first allocation
> > attempt is failed.
> 
> This is too lowlevel to be exported in the regular user visible interface IMO.
> 
I think its ok because I think this interface is for lowlevel debugging itself.

> > This is useful to know the rate of allocation success within the
> > slowpath.
> 
> What would be that information good for? Is a regular administrator expected
to
> consume this value or this is aimed more to kernel developers? If the later
then I
> think a trace point sounds like a better interface.
> 
This information is good for kernel developers.
I found this information useful while debugging low memory situation and
sluggishness behavior.
I wanted to know how many times the first allocation is failing and how many
times system entering slowpath.
As I said, the existing counter does not give this information clearly. 
The pageoutrun, allocstall is too confusing.
Also, if kswapd and compaction is disabled, we have no other counter for
slowpath (except allocstall).
Another problem is that allocstall can also be incremented from hibernation
during shrink_all_memory calling.
Which may create more confusion.
Thus I found this interface useful to understand low memory behavior.
If device sluggishness is happening because of too many slowpath or due to some
other problem.
Then we can decide what will be the best memory configuration for my device to
reduce the slowpath.

Regarding trace points, I am not sure if we can attach counter to it.
Also trace may have more over-head and requires additional configs to be enabled
to debug.
Mostly these configs will not be enabled by default (at least in embedded, low
memory device).
I found the vmstat interface more easy and useful.

Comments and suggestions are welcome.

> > This patch is tested on ARM with 512MB RAM.
> > A sample output is shown below after successful boot-up:
> > shell> cat /proc/vmstat
> > nr_free_pages 4712
> > pgalloc_normal 1319432
> > pgalloc_movable 0
> > pageoutrun 379
> > allocstall 0
> > slowpath_entered 585
> > compact_stall 0
> > compact_fail 0
> > compact_success 0
> >
> > >From the above output we can see that the system entered
> > slowpath 585 times.
> > But the existing counter kswapd(pageoutrun),
> > direct_reclaim(allocstall),
> > direct_compact(compact_stall) does not tell this value.
> > >From the above value, it clearly indicates that the system have
> > entered slowpath 585 times. Out of which 379 times allocation passed
> > through kswapd, without performing direct reclaim/compaction.
> > That means the remaining 206 times the allocation would have succeeded
> > using the alloc_pages_high_priority.
> >
> > Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
