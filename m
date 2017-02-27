Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 48A286B0388
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 12:29:46 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u63so40491288wmu.0
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 09:29:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s26si14265857wma.12.2017.02.27.09.29.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 09:29:45 -0800 (PST)
Date: Mon, 27 Feb 2017 18:29:42 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm/vmscan: fix high cpu usage of kswapd if there are
 no reclaimable pages
Message-ID: <20170227172942.GQ26504@dhcp22.suse.cz>
References: <1487918992-7515-1-git-send-email-hejianet@gmail.com>
 <20170224084949.GA19161@dhcp22.suse.cz>
 <20170224165105.GB20092@cmpxchg.org>
 <20170227085024.GD14029@dhcp22.suse.cz>
 <20170227170634.GA20423@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170227170634.GA20423@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jia He <hejianet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Mon 27-02-17 12:06:34, Johannes Weiner wrote:
> On Mon, Feb 27, 2017 at 09:50:24AM +0100, Michal Hocko wrote:
> > On Fri 24-02-17 11:51:05, Johannes Weiner wrote:
> > [...]
> > > >From 29fefdca148e28830e0934d4e6cceb95ed2ee36e Mon Sep 17 00:00:00 2001
> > > From: Johannes Weiner <hannes@cmpxchg.org>
> > > Date: Fri, 24 Feb 2017 10:56:32 -0500
> > > Subject: [PATCH] mm: vmscan: disable kswapd on unreclaimable nodes
> > > 
> > > Jia He reports a problem with kswapd spinning at 100% CPU when
> > > requesting more hugepages than memory available in the system:
> > > 
> > > $ echo 4000 >/proc/sys/vm/nr_hugepages
> > > 
> > > top - 13:42:59 up  3:37,  1 user,  load average: 1.09, 1.03, 1.01
> > > Tasks:   1 total,   1 running,   0 sleeping,   0 stopped,   0 zombie
> > > %Cpu(s):  0.0 us, 12.5 sy,  0.0 ni, 85.5 id,  2.0 wa,  0.0 hi,  0.0 si,  0.0 st
> > > KiB Mem:  31371520 total, 30915136 used,   456384 free,      320 buffers
> > > KiB Swap:  6284224 total,   115712 used,  6168512 free.    48192 cached Mem
> > > 
> > >   PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
> > >    76 root      20   0       0      0      0 R 100.0 0.000 217:17.29 kswapd3
> > > 
> > > At that time, there are no reclaimable pages left in the node, but as
> > > kswapd fails to restore the high watermarks it refuses to go to sleep.
> > > 
> > > Kswapd needs to back away from nodes that fail to balance. Up until
> > > 1d82de618ddd ("mm, vmscan: make kswapd reclaim in terms of nodes")
> > > kswapd had such a mechanism. It considered zones whose theoretically
> > > reclaimable pages it had reclaimed six times over as unreclaimable and
> > > backed away from them. This guard was erroneously removed as the patch
> > > changed the definition of a balanced node.
> > > 
> > > However, simply restoring this code wouldn't help in the case reported
> > > here: there *are* no reclaimable pages that could be scanned until the
> > > threshold is met. Kswapd would stay awake anyway.
> > > 
> > > Introduce a new and much simpler way of backing off. If kswapd runs
> > > through MAX_RECLAIM_RETRIES (16) cycles without reclaiming a single
> > > page, make it back off from the node. This is the same number of shots
> > > direct reclaim takes before declaring OOM. Kswapd will go to sleep on
> > > that node until a direct reclaimer manages to reclaim some pages, thus
> > > proving the node reclaimable again.
> > 
> > Yes this looks, nice&simple. I would just be worried about [1] a bit.
> > Maybe that is worth a separate patch though.
> > 
> > [1] http://lkml.kernel.org/r/20170223111609.hlncnvokhq3quxwz@dhcp22.suse.cz
> 
> I think I'd prefer the simplicity of keeping this contained inside
> vmscan.c, as an interaction between direct reclaimers and kswapd, as
> well as leaving the wakeup tied to actually seeing reclaimable pages
> rather than merely producing free pages (e.g. should we also add a
> kick to a large munmap() for example?).

OK, that is a good point as well. I was about to argue that a mlock
runaway process killed by the OOM killer should restart kswapd otherwise
the following operation would be quite surprising. But you are right
that there are other sources of large amout of free pages. So you are
right, let's keep it simple for now and do something based on freed
pages.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
