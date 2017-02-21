Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3A86B0389
	for <linux-mm@kvack.org>; Tue, 21 Feb 2017 01:01:33 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id x75so48497210vke.5
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 22:01:33 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id n188si20827416pga.361.2017.02.20.22.01.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Feb 2017 22:01:31 -0800 (PST)
Subject: Re: Query on per app memory cgroup
References: <b7ee0ad3-a580-b38a-1e90-035c77b181ea@codeaurora.org>
 <b11e01d9-7f67-5c91-c7da-e5a95996c0ec@codeaurora.org>
 <CAKTCnzn7Ry0WLEiF4TWKSO02gy_U=iaCsO=nw7p4Jfz7T71R2Q@mail.gmail.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <1301f831-31bd-41ad-a738-8afd8639fd61@codeaurora.org>
Date: Tue, 21 Feb 2017 11:31:25 +0530
MIME-Version: 1.0
In-Reply-To: <CAKTCnzn7Ry0WLEiF4TWKSO02gy_U=iaCsO=nw7p4Jfz7T71R2Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, linux-mm <linux-mm@kvack.org>, shashim@codeaurora.org


On 2/21/2017 10:01 AM, Balbir Singh wrote:
> On Thu, Feb 9, 2017 at 4:46 PM, Vinayak Menon <vinmenon@codeaurora.org> wrote:
>> Hi,
>>
>> We were trying to implement the per app memory cgroup that Johannes
>> suggested (https://lkml.org/lkml/2014/12/19/358) and later discussed during
>> Minchan's proposal of per process reclaim
> Per app memory cgroups are interesting, but also quite aggressive. Could
> you please describe what tasks/workload you have?
Three types of tests were done. One on Android, only putting activity tasks (apps that the user opens like games etc)
in their own memcg. These are usually anon intensive apps. The second test was to move any android created processes
to its own memcg. The second test results are worse than the first because of the presence of more memcgs with smaller
LRUs. In the first case there are around 15 memcgs, and in the second case around 70.
These 2 tests include opening the apps one by one for around 10 iterations.
The third test was done in non-Android environment creating N number of memcgs. Within each memcg multiple .c files are
created runtime and then they are compiled and executed. This test creates almost and equal amount of anon and file pages
within each memcg. All these tests shows the same behavior with the  problem worsening with the increase in number of
memcgs and a corresponding drop in LRU sizes.
>> (https://lkml.org/lkml/2016/6/13/570). The test was done on Android target
>> with 2GB of RAM and cgroupv1. The first test done was to just create per
>> app cgroups without modifying any cgroup controls. 2 kinds of tests were
>> done which gives similar kind of observation. One was to just open
>> applications in sequence and repeat this N times (20 apps, so around 20
>> memcgs max at a time). Another test was to create around 20 cgroups and
>> perform a make (not kernel, another less heavy source) in each of them.
>>
>> It is observed that because of the creation of memcgs per app, the per
>> memcg LRU size is so low and results in kswapd priority drop. This results
>> in sudden increase in scan at lower priorities. Because of this, kswapd
>> consumes around 3 times more time (and thus less pageoutrun), and due to
>> the lag in reclaiming memory direct reclaims are more and consumes around
>> 2.5 times more time.
>>
> That does not sound good! Have you been able to test this with older
> kernels to see if this is a regression?
I have tried it on 3.18 and 4.4 kernels and both shows the problem. Let me see if I can try this on an older
kernel.
One query. When the LRUs are very small and there are multiple of them (and more importantly in the case of per app
memcg most of the memory consumed by the system is divided among these memcgs and root memcg is tiny),
we would always end up with this problem ? I assume this is the reason why a force scan is done in the case of
targeted reclaim as this comment in get_scan_count indicates

        /*
         * If the zone or memcg is small, nr[l] can be 0.  This
         * results in no scanning on this priority and a potential
         * priority drop.  Global direct reclaim can go to the next
         * zone and tends to have no problems. Global kswapd is for
         * zone balancing and it needs to scan a minimum amount. When
         * reclaiming for a memcg, a priority drop can cause high
         * latencies, so it's better to scan a minimum amount there as
         * well.
         */
As I understand, with per app memcg we get into the above mentioned problem with global reclaim too, but a force scan
during global_reclam would result in excessive scanning since it scans all memcgs. No ?
>> Another observation is that the reclaim->generation check in
>> mem_cgroup_iter results in kswapd breaking the memcg lru reclaim loop in
>> shrink_zone (this is 4.4 kernel) often. This also contributes to the
>> priority drop. A test was done to skip the reclaim generation check in
>> mem_cgroup_iter and allow concurrent reclaimers to run at same priority.
>> This improved the results reducing the kswapd priority drops (and thus time
>> spent in kswapd, allocstalls etc). But this problem could be a side effect
>> of kswapd running for long and reclaiming slow resulting in many parallel
>> direct reclaims.
>>
>> Some of the stats are shown below
>>                             base        per-app-memcg
>>
>> pgalloc_dma                 4982349     5043134
>>
>> pgfree                      5249224     5303701
>>
>> pgactivate                  83480       117088
>>
>> pgdeactivate                152407      1021799
>>
>> pgmajfault                  421         31698
>>
>> pgrefill_dma                156884      1027744
>>
>> pgsteal_kswapd_dma          128449      97364
>>
>> pgsteal_direct_dma          101012      229924
>>
>> pgscan_kswapd_dma           132716      109750
>>
>> pgscan_direct_dma           104141      265515
>>
>> slabs_scanned               58782       116886
>>
>> pageoutrun                  57          16
>>
>> allocstall                  1283        3540
>>
>>
>> After this, offloading some of the job to soft reclaim was tried with the
>> assumption that it will result in lesser priority drops. The problem is in
>> determining the right value to be set for soft reclaim. For e.g. one of the
>> main motives behind using memcg in Android is to set different swappiness
>> to tasks depending on their importance (foreground, background etc.). In
>> such a case we actually do not want to set any soft limits. And in the
>> second case when we want to use soft reclaim to offload some work from
>> kswapd_shrink_zone on to mem_cgroup_soft_limit_reclaim, it becomes tricky
>> to set the soft limit values. I was trying out with different percentage of
>> task RSS for setting soft limit, but this actually results in excessive
>> scanning by mem_cgroup_soft_limit_reclaim, which as I understand  is
>> because of always using scan priority of 0. This in turn increases the time
>> spent in kswapd. It reduces the kswapd priority drop though.
>>
> Soft limit setting can be tricky, but my advise is to set it based on how much
> you see a particular cgroup using when the system is under memory pressure.
>
>> Is there a way to mitigate this problem of small lru sizes, priority drop
>> and kswapd cpu consumption.
>>
> I've not investigated or heard of this problem before, so I am not
> sure if I have
> a solution for you.
Thanks for your comments Balbir.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
