Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4CE67681034
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 08:17:03 -0500 (EST)
Received: by mail-lf0-f70.google.com with SMTP id x1so19855999lff.6
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 05:17:03 -0800 (PST)
Received: from mail-lf0-x22e.google.com (mail-lf0-x22e.google.com. [2a00:1450:4010:c07::22e])
        by mx.google.com with ESMTPS id m8si2278651lfj.364.2017.02.17.05.17.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 05:17:01 -0800 (PST)
Received: by mail-lf0-x22e.google.com with SMTP id o140so8313414lff.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 05:17:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <b11e01d9-7f67-5c91-c7da-e5a95996c0ec@codeaurora.org>
References: <b7ee0ad3-a580-b38a-1e90-035c77b181ea@codeaurora.org> <b11e01d9-7f67-5c91-c7da-e5a95996c0ec@codeaurora.org>
From: Bob Liu <lliubbo@gmail.com>
Date: Fri, 17 Feb 2017 21:17:00 +0800
Message-ID: <CAA_GA1eMYOPwm8iqn6QLVRvn7vFi3Ae6CbpkLU7iO=J+jE=Yiw@mail.gmail.com>
Subject: Re: Query on per app memory cgroup
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Minchan Kim <minchan@kernel.org>, Linux-MM <linux-mm@kvack.org>, shashim@codeaurora.org

On Thu, Feb 9, 2017 at 7:16 PM, Vinayak Menon <vinmenon@codeaurora.org> wrote:
> Hi,
>
> We were trying to implement the per app memory cgroup that Johannes
> suggested (https://lkml.org/lkml/2014/12/19/358) and later discussed during
> Minchan's proposal of per process reclaim
> (https://lkml.org/lkml/2016/6/13/570). The test was done on Android target
> with 2GB of RAM and cgroupv1. The first test done was to just create per
> app cgroups without modifying any cgroup controls. 2 kinds of tests were
> done which gives similar kind of observation. One was to just open
> applications in sequence and repeat this N times (20 apps, so around 20
> memcgs max at a time). Another test was to create around 20 cgroups and
> perform a make (not kernel, another less heavy source) in each of them.
>
> It is observed that because of the creation of memcgs per app, the per
> memcg LRU size is so low and results in kswapd priority drop. This results

How did you confirm that? Traced the get_scan_count() function?
You may hack this function for more verification.

-
Regards,
Bob

> in sudden increase in scan at lower priorities. Because of this, kswapd
> consumes around 3 times more time (and thus less pageoutrun), and due to
> the lag in reclaiming memory direct reclaims are more and consumes around
> 2.5 times more time.
>
> Another observation is that the reclaim->generation check in
> mem_cgroup_iter results in kswapd breaking the memcg lru reclaim loop in
> shrink_zone (this is 4.4 kernel) often. This also contributes to the
> priority drop. A test was done to skip the reclaim generation check in
> mem_cgroup_iter and allow concurrent reclaimers to run at same priority.
> This improved the results reducing the kswapd priority drops (and thus time
> spent in kswapd, allocstalls etc). But this problem could be a side effect
> of kswapd running for long and reclaiming slow resulting in many parallel
> direct reclaims.
>
> Some of the stats are shown below
>                             base        per-app-memcg
>
> pgalloc_dma                 4982349     5043134
>
> pgfree                      5249224     5303701
>
> pgactivate                  83480       117088
>
> pgdeactivate                152407      1021799
>
> pgmajfault                  421         31698
>
> pgrefill_dma                156884      1027744
>
> pgsteal_kswapd_dma          128449      97364
>
> pgsteal_direct_dma          101012      229924
>
> pgscan_kswapd_dma           132716      109750
>
> pgscan_direct_dma           104141      265515
>
> slabs_scanned               58782       116886
>
> pageoutrun                  57          16
>
> allocstall                  1283        3540
>
>
> After this, offloading some of the job to soft reclaim was tried with the
> assumption that it will result in lesser priority drops. The problem is in
> determining the right value to be set for soft reclaim. For e.g. one of the
> main motives behind using memcg in Android is to set different swappiness
> to tasks depending on their importance (foreground, background etc.). In
> such a case we actually do not want to set any soft limits. And in the
> second case when we want to use soft reclaim to offload some work from
> kswapd_shrink_zone on to mem_cgroup_soft_limit_reclaim, it becomes tricky
> to set the soft limit values. I was trying out with different percentage of
> task RSS for setting soft limit, but this actually results in excessive
> scanning by mem_cgroup_soft_limit_reclaim, which as I understand  is
> because of always using scan priority of 0. This in turn increases the time
> spent in kswapd. It reduces the kswapd priority drop though.
>
> Is there a way to mitigate this problem of small lru sizes, priority drop
> and kswapd cpu consumption.
>
> Thanks,
> Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
