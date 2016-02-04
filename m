Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7BDEB4403D8
	for <linux-mm@kvack.org>; Thu,  4 Feb 2016 07:57:03 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id g62so3143879wme.0
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 04:57:03 -0800 (PST)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id ef6si17459861wjd.208.2016.02.04.04.57.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Feb 2016 04:57:02 -0800 (PST)
Received: by mail-wm0-f67.google.com with SMTP id g62so327533wme.2
        for <linux-mm@kvack.org>; Thu, 04 Feb 2016 04:57:01 -0800 (PST)
Date: Thu, 4 Feb 2016 13:57:00 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160204125700.GA14425@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.DEB.2.10.1602031457120.10331@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1602031457120.10331@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 03-02-16 14:58:06, David Rientjes wrote:
> On Wed, 3 Feb 2016, Michal Hocko wrote:
> 
> > Hi,
> > this thread went mostly quite. Are all the main concerns clarified?
> > Are there any new concerns? Are there any objections to targeting
> > this for the next merge window?
> 
> Did we ever figure out what was causing the oom killer to be called much 
> earlier in Tetsuo's http://marc.info/?l=linux-kernel&m=145096089726481 and

>From the OOM report:
[ 3902.430630] kthreadd invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[ 3902.507561] Node 0 DMA32: 3788*4kB (UME) 184*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 16624kB
[ 5262.901161] smbd invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[ 5262.983496] Node 0 DMA32: 1987*4kB (UME) 14*8kB (ME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 8060kB
[ 5269.764580] kthreadd invoked oom-killer: order=2, oom_score_adj=0, gfp_mask=0x27000c0(GFP_KERNEL|GFP_NOTRACK|0x100000)
[ 5269.858330] Node 0 DMA32: 10648*4kB (UME) 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 42592kB

> http://marc.info/?l=linux-kernel&m=145130454913757 ?

[  277.884512] Node 0 DMA32: 3438*4kB (UME) 791*8kB (UME) 3*16kB (UM) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 20128kB
[  291.349097] Node 0 DMA32: 4221*4kB (UME) 1971*8kB (UME) 436*16kB (UME) 141*32kB (UME) 8*64kB (UM) 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 44652kB
[  302.916334] Node 0 DMA32: 4304*4kB (UM) 1181*8kB (UME) 59*16kB (UME) 7*32kB (ME) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 27832kB
[  311.034251] Node 0 DMA32: 6*4kB (U) 2401*8kB (ME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 19232kB
[  314.314336] Node 0 DMA32: 1180*4kB (UM) 1449*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 16312kB
[  322.796256] Node 0 DMA32: 86*4kB (UME) 2474*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 20136kB
[  330.826190] Node 0 DMA32: 1637*4kB (UM) 1354*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 17380kB
[  332.846805] Node 0 DMA32: 4108*4kB (UME) 897*8kB (ME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 23608kB
[  341.073722] Node 0 DMA32: 3309*4kB (UM) 1124*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 22228kB
[  360.093794] Node 0 DMA32: 2719*4kB (UM) 97*8kB (UM) 14*16kB (UM) 37*32kB (UME) 27*64kB (UME) 3*128kB (UM) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15172kB
[  368.871173] Node 0 DMA32: 5042*4kB (UM) 248*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 22152kB
[  379.279344] Node 0 DMA32: 2994*4kB (ME) 503*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 16000kB
[  387.385740] Node 0 DMA32: 3638*4kB (UM) 115*8kB (UM) 1*16kB (U) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15488kB
[  391.228084] Node 0 DMA32: 3374*4kB (UME) 221*8kB (M) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15264kB
[  395.683137] Node 0 DMA32: 3794*4kB (ME) 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15176kB
[  399.890082] Node 0 DMA32: 4155*4kB (UME) 200*8kB (ME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 18220kB
[  408.465169] Node 0 DMA32: 2804*4kB (ME) 203*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 12840kB
[  416.447247] Node 0 DMA32: 5158*4kB (UME) 68*8kB (M) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 21176kB
[  418.799643] Node 0 DMA32: 3093*4kB (UME) 1043*8kB (UME) 2*16kB (M) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 20748kB
[  428.109005] Node 0 DMA32: 2943*4kB (UME) 458*8kB (UME) 20*16kB (UME) 11*32kB (UME) 11*64kB (ME) 4*128kB (UME) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 17324kB
[  439.032446] Node 0 DMA32: 2761*4kB (UM) 28*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 11268kB
[  441.731018] Node 0 DMA32: 3130*4kB (UM) 338*8kB (UM) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 15224kB
[  442.070867] Node 0 DMA32: 590*4kB (ME) 827*8kB (ME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 8976kB
[  442.245208] Node 0 DMA32: 1902*4kB (UME) 410*8kB (UME) 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 10888kB

There are cases where order-2 has some pages but I have commented on
that here [1]

> I'd like to take a look at the patch(es) that fixed it.

I am not sure we can fix these pathological loads where we hit the
higher order depletion and there is a chance that one of the thousands
tasks terminates in an unpredictable way which happens to race with the
OOM killer. As I've pointed out in [1] once the watermark check for the
higher order allocation fails for the given order then we cannot rely
on the reclaimable pages ever construct the required order. The current
zone_reclaimable approach just happens to work for this particular load
because the NR_PAGES_SCANNED gets reseted too often with a side effect
of an undeterministic behavior.

[1] http://lkml.kernel.org/r/20160120131355.GE14187@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
