Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id D498C6B0038
	for <linux-mm@kvack.org>; Sun, 25 Oct 2015 18:47:19 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so168064206pad.1
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 15:47:19 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id t9si48403951pbs.73.2015.10.25.15.47.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Oct 2015 15:47:18 -0700 (PDT)
Received: by pasz6 with SMTP id z6so167843050pas.2
        for <linux-mm@kvack.org>; Sun, 25 Oct 2015 15:47:18 -0700 (PDT)
Date: Mon, 26 Oct 2015 07:47:09 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151025224709.GA8223@mtj.duckdns.org>
References: <20151023083316.GB2410@dhcp22.suse.cz>
 <20151023103630.GA4170@mtj.duckdns.org>
 <20151023111145.GH2410@dhcp22.suse.cz>
 <201510232125.DAG82381.LMJtOQFOHVOSFF@I-love.SAKURA.ne.jp>
 <20151023182343.GB14610@mtj.duckdns.org>
 <201510251952.CEF04109.OSOtLFHFVFJMQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201510251952.CEF04109.OSOtLFHFVFJMQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Hello,

On Sun, Oct 25, 2015 at 07:52:59PM +0900, Tetsuo Handa wrote:
...
> This means that any kernel code which invokes a __GFP_WAIT allocation
> might fail to do (4) when invoked via workqueue, regardless of flags
> passed to alloc_workqueue()?

Sounds that way and yeah (3) should technically be okay and that's why
HIGHPRI was implemented the way it was at the beginning; however, in
practice, this is the first time it's noticeable in all the years.  I
think it comes down to the fact that there just aren't many places
which need such looping behavior and even in those places it's often
very undesirable to busy-loop while not making forward-progress (and
if forward-progress is being made, it won't be indefinite).

> I think that inserting a short sleep into page allocator is better
> because the vmstat_update fix will not require workqueue tweaks if
> we sleep inside page allocator. Also, from the point of view of
> protecting page allocator from going unresponsive when hundreds of tasks
> started busy-waiting at __alloc_pages_slowpath() because we can observe
> that XXX value in the "MemAlloc-Info: XXX stalling task," line grows
> when we are unable to make forward progress.

This looks good to me too; however, it still needs a dedicated
workqueue with WQ_MEM_RECLAIM set.  That deadlock probably is very
unlikely as the side effect of vmstat failing to execute due to worker
exhaustion is more memory reclaim but it still is theoretically
possible and it could just be that it happens at low enough frequency
that it hasn't been reported yet.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
