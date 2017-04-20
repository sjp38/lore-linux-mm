Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E13052806EA
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 09:25:40 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k14so5621668wrc.16
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 06:25:40 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id g55si9051279wra.249.2017.04.20.06.25.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Apr 2017 06:25:39 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id u65so3108421wmu.3
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 06:25:39 -0700 (PDT)
Date: Thu, 20 Apr 2017 15:25:37 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: Heads-up: two regressions in v4.11-rc series
Message-ID: <20170420132536.GB25160@lerouge>
References: <20170420110042.73d01e0f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170420110042.73d01e0f@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Tariq Toukan <tariqt@mellanox.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, peterz@infradead.org

On Thu, Apr 20, 2017 at 11:00:42AM +0200, Jesper Dangaard Brouer wrote:
> Hi Linus,
> 
> Just wanted to give a heads-up on two regressions in 4.11-rc series.
> 
> (1) page allocator optimization revert
> 
> Mel Gorman and I have been playing with optimizing the page allocator,
> but Tariq spotted that we caused a regression for (NIC) drivers that
> refill DMA RX rings in softirq context.
> 
> The end result was a revert, and this is waiting in AKPMs quilt queue:
>  http://ozlabs.org/~akpm/mmots/broken-out/revert-mm-page_alloc-only-use-per-cpu-allocator-for-irq-safe-requests.patch
> 
> 
> (2) Busy softirq can cause userspace not to be scheduled
> 
> I bisected the problem to a499a5a14dbd ("sched/cputime: Increment
> kcpustat directly on irqtime account"). See email thread with
>  Subject: Bisected softirq accounting issue in v4.11-rc1~170^2~28
>  http://lkml.kernel.org/r/20170328101403.34a82fbf@redhat.com
> 
> I don't know the scheduler code well enough to fix this, and will have
> to rely others to figure out this scheduler regression.
> 
> To make it clear: I'm only seeing this scheduler regression when a
> remote host is sending many many network packets, towards the kernel
> which keeps NAPI/softirq busy all the time.  A possible hint: tool
> "top" only shows this in "si" column, while on v4.10 "top" also blames
> "ksoftirqd/N", plus "ps" reported cputime (0:00) seems wrong for ksoftirqd.

(I'm currently working on reproducing that one.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
