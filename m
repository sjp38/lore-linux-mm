Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BEF146B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 07:31:18 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id kq3so32597673wjc.1
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 04:31:18 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g29si8971389wra.178.2017.02.08.04.31.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 04:31:17 -0800 (PST)
Date: Wed, 8 Feb 2017 12:31:13 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH] mm: move pcp and lru-pcp drainging into vmstat_wq
Message-ID: <20170208123113.nq5unzmzpb23zoz5@suse.de>
References: <20170207210908.530-1-mhocko@kernel.org>
 <20170208105334.zbjuaaqwmp5rgpui@suse.de>
 <20170208120354.GI5686@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170208120354.GI5686@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Feb 08, 2017 at 01:03:55PM +0100, Michal Hocko wrote:
> > I don't object to it being actually moved. I have a slight concern that
> > it could somehow starve a vmstat update while frequent drains happen
> > during reclaim though which potentially compounds the problem. It could
> > be offset by a variety of other factors but if it ever is an issue,
> > it'll show up and the paths that really matter check the vmstats
> > directly instead of waiting for an update.
> 
> vmstat updates can tolared delays, that's we we are using deferable
> scheduling in the first place so I am not really worried about that. Any
> user which needs a better precision should use *_snapshot API.
> 

Agreed, we already had cases where deferred vmstat updates had problems
and were resolved by using _snapshot. It's a slight concern only and I'd
be surprised if the _snapshot usage didn't cover it.

> > The altering of the return value in setup_vmstat was mildly surprising as
> > it increases the severity of registering the vmstat callback for memory
> > hotplug so maybe split that out and appears unrelated.
> 
> not sure I understand. What do you mean?
> 

This hunk

@@ -1763,9 +1762,11 @@ static int vmstat_cpu_dead(unsigned int cpu)

 static int __init setup_vmstat(void)
 {
-#ifdef CONFIG_SMP
-       int ret;
+       int ret = 0;
+
+       vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);

+#ifdef CONFIG_SMP
        ret = cpuhp_setup_state_nocalls(CPUHP_MM_VMSTAT_DEAD, "mm/vmstat:dead",
                                        NULL, vmstat_cpu_dead);
        if (ret < 0)
@@ -1789,7 +1790,7 @@ static int __init setup_vmstat(void)
        proc_create("vmstat", S_IRUGO, NULL, &proc_vmstat_file_operations);
        proc_create("zoneinfo", S_IRUGO, NULL, &proc_zoneinfo_file_operations);
 #endif
-       return 0;
+       return ret;


A failed register of vmstat_cpu_dead is returning the failure code in an
init function now. Chances are it'll never hit but it didn't seem related
to the patches general intent.

> > It also feels like vmstat is now a misleading name for something that
> > handles vmstat, lru drains and per-cpu drains but that's cosmetic.
> 
> yeah a better name sounds like a good thing. mm_nonblock_wq?
> 

it's not always non-blocking. Maybe mm_percpu_wq to describev a workqueue
that handles a variety of MM-related per-cpu updates?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
