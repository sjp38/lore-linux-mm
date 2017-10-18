Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC7706B025F
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 02:30:57 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v91so1939105wrc.11
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 23:30:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g84si7743952wmf.275.2017.10.17.23.30.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 23:30:56 -0700 (PDT)
Subject: Re: [PATCH v5] mm, sysctl: make NUMA stats configurable
References: <1508290927-8518-1-git-send-email-kemi.wang@intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <082e44ef-c5f2-ae99-8672-37a678c61edd@suse.cz>
Date: Wed, 18 Oct 2017 08:30:53 +0200
MIME-Version: 1.0
In-Reply-To: <1508290927-8518-1-git-send-email-kemi.wang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kemi Wang <kemi.wang@intel.com>, "Luis R . Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, Christopher Lameter <cl@linux.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dave <dave.hansen@linux.intel.com>, Tim Chen <tim.c.chen@intel.com>, Andi Kleen <andi.kleen@intel.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Ying Huang <ying.huang@intel.com>, Aaron Lu <aaron.lu@intel.com>, Proc sysctl <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On 10/18/2017 03:42 AM, Kemi Wang wrote:
> This is the second step which introduces a tunable interface that allow
> numa stats configurable for optimizing zone_statistics(), as suggested by
> Dave Hansen and Ying Huang.
> 
> =========================================================================
> When page allocation performance becomes a bottleneck and you can tolerate
> some possible tool breakage and decreased numa counter precision, you can
> do:
> 	echo 0 > /proc/sys/vm/numa_stat
> In this case, numa counter update is ignored. We can see about
> *4.8%*(185->176) drop of cpu cycles per single page allocation and reclaim
> on Jesper's page_bench01 (single thread) and *8.1%*(343->315) drop of cpu
> cycles per single page allocation and reclaim on Jesper's page_bench03 (88
> threads) running on a 2-Socket Broadwell-based server (88 threads, 126G
> memory).
> 
> Benchmark link provided by Jesper D Brouer(increase loop times to
> 10000000):
> https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/mm/
> bench
> 
> =========================================================================
> When page allocation performance is not a bottleneck and you want all
> tooling to work, you can do:
> 	echo 1 > /proc/sys/vm/numa_stat
> This is system default setting.
> 
> Many thanks to Michal Hocko, Dave Hansen, Ying Huang and Vlastimil Babka
> for comments to help improve the original patch.
> 
> ChangeLog:
>   V4->V5
>   a) Scope vm_numa_stat_lock into the sysctl handler function, as suggested
>   by Michal Hocko;
>   b) Only allow 0/1 value when setting a value to numa_stat at userspace,
>   that would keep the possibility for add auto mode in future (e.g. 2 for
>   auto mode), as suggested by Michal Hocko.
> 
>   V3->V4
>   a) Get rid of auto mode of numa stats, and may add it back if necessary,
>   as alignment before;
>   b) Skip NUMA_INTERLEAVE_HIT counter update when numa stats is disabled,
>   as reported by Andrey Ryabinin. See commit "de55c8b2519" for details
>   c) Remove extern declaration for those clear_numa_ function, and make
>   them static in vmstat.c, as suggested by Vlastimil Babka.
> 
>   V2->V3:
>   a) Propose a better way to use jump label to eliminate the overhead of
>   branch selection in zone_statistics(), as inspired by Ying Huang;
>   b) Add a paragraph in commit log to describe the way for branch target
>   selection;
>   c) Use a more descriptive name numa_stats_mode instead of vmstat_mode,
>   and change the description accordingly, as suggested by Michal Hocko;
>   d) Make this functionality NUMA-specific via ifdef
> 
>   V1->V2:
>   a) Merge to one patch;
>   b) Use jump label to eliminate the overhead of branch selection;
>   c) Add a single-time log message at boot time to help tell users what
>   happened.
> 
> Reported-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Suggested-by: Dave Hansen <dave.hansen@intel.com>
> Suggested-by: Ying Huang <ying.huang@intel.com>
> Signed-off-by: Kemi Wang <kemi.wang@intel.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
