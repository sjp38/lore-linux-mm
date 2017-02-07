Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6D8556B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 06:09:17 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id s36so107836581otd.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 03:09:17 -0800 (PST)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id v17si1529193oia.264.2017.02.07.03.09.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 03:09:16 -0800 (PST)
Received: by mail-oi0-x242.google.com with SMTP id j15so8554891oih.0
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 03:09:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170207081002.GB5065@dhcp22.suse.cz>
References: <1486383850-30444-1-git-send-email-vinmenon@codeaurora.org>
 <20170206125240.GB10298@dhcp22.suse.cz> <CAOaiJ-=ovwZ53nqNLRtP=sCY=+4s1-1r_soBXvam42bxDeUdAQ@mail.gmail.com>
 <20170207081002.GB5065@dhcp22.suse.cz>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Tue, 7 Feb 2017 16:39:15 +0530
Message-ID: <CAOaiJ-ndDnkm2qL0M9gqhnR8szzDxiRG2_KkaYAM+9hAkq_m5A@mail.gmail.com>
Subject: Re: [PATCH 1/2 v4] mm: vmscan: do not pass reclaimed slab to vmpressure
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue, Feb 7, 2017 at 1:40 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Mon 06-02-17 20:40:10, vinayak menon wrote:
>> On Mon, Feb 6, 2017 at 6:22 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Mon 06-02-17 17:54:09, Vinayak Menon wrote:
>> >> During global reclaim, the nr_reclaimed passed to vmpressure includes the
>> >> pages reclaimed from slab.  But the corresponding scanned slab pages is
>> >> not passed.  This can cause total reclaimed pages to be greater than
>> >> scanned, causing an unsigned underflow in vmpressure resulting in a
>> >> critical event being sent to root cgroup.
>> >
>> > If you switched the ordering then this wouldn't be a problem, right?
>>
>> You mean calling vmpressure first and then shrink_slab ?
>
> No, I meant the scanned vs. reclaim normalization patch first and than do
> whatever slab related thing later on. This would have an advantage that
> we can rule the underflow issue out and only focus on why the slab
> numbers actually matter.
>
Yes, makes sense. Will reorder the patches and remove the underflow comments
from this changelog.

>> That also can be done. Would completing shrink_slab before vmpressure
>> be of any use to a userspace task that takes into account both
>> vmpressure and reclaimable slab size ?
>
> Is this the case in your lowmemmory killer implementation? If yes how
> does it actually work?
>
No. When you mentioned reordering I thought you meant reordering the
shrink_slab and
vmpressure calls. So was just thinking whether that would make a
visible side effect
for those clients considering both vmpressure and reclaimable slab size.

> [...]
>> > It would be also more than useful to say how much the slab reclaim
>> > really contributed.
>>
>> The 70% less events is caused by slab reclaim being added to
>> vmpressure, which is confirmed by running the test with and without
>> the fix.  But it is hard to say the effect on reclaim stats is caused
>> by this problem because, the lowmemorykiller can be written with
>> different heuristics to make the reclaim look better.
>
> Exactly! And this is why I am not still happy with the current
> justification of this patch. It seems to be tuning for a particular
> consumer of vmpressure events. Others might depend on a less pessimistic
> events because we are making some progress afterall. Being more
> pessimistic can lead to premature oom or other performance related
> decisions and that is why I am not happy about that.
>
> Btw. could you be more specific about your particular test? What is
> desired/acceptable result?
The test opens multiple applications on android in a sequence and then
repeats this
for N times. Time taken to launch the application is measured. With and without
the patch the deviation is seen in the launch latencies. The launch
latency diff is
caused by the lesser number of kills (because of vmpressure difference).

>
>> The issue we see
>> in the above reclaim stats is entirely because of task kills being
>> delayed. That is the reason why I did not include the vmstat stats in
>> the changelog in the earlier versions.
>>
>> >
>> >> This is a regression introduced by commit 6b4f7799c6a5 ("mm: vmscan:
>> >> invoke slab shrinkers from shrink_zone()").
>> >
>> > I am not really sure this is a regression, though. Maybe your heuristic
>> > which consumes events is just too fragile?
>> >
>> Yes it could be. A different kind of lowmemorykiller may not show up
>> this issue at all. In my opinion the regression here is the difference
>> in vmpressure values and thus the vmpressure events because of passing
>> slab reclaimed pages to vmpressure without considering the scanned
>> pages and cost model.
>> So would it be better to drop the vmstat data from changelog ?
>
> No! The main question is whether being more pessimistic and report
> higher reclaim levels really does make sense even when there is a slab
> reclaim progress. This hasn't been explained and I _really_ do not like
> a patch which optimizes for a particular consumer of events.
>
> I understand that the change of the behavior is unexpeted and that
> might be reason to revert to the original one. But if this is the only
> reasonable way to go I would, at least, like to understand what is going
> on here. Why cannot your lowmemorykiller cope with the workload? Why
> starting to kill sooner (at the time when the slab still reclaims enough
> pages to report lower critical events) helps to pass your test. Maybe it
> is the implementation of the lmk which needs to be changed because it
> has some false expectations? Or the memory reclaim just behaves in an
> unpredictable manner?
> --
Say if 4.4 had actually implemented page based shrinking model for slab and
included the correct scanned and reclaimed to vmpressure considering the cost
model, then it is all fine and behavior difference if any shown by a
vmpressure client
need to be fixed. But as I understand, the case here is different.
vmpressure was implemented to work with scanned and reclaimed pages
from LRU and it works
well for at least some use cases. As you had pointed out earlier there could be
problems with the way vmpressure works since it is not considering
many other costs. But
it shows an estimate of the pressure on LRUs. I think adding just the
slab reclaimed to nr_reclaimed
without considering the cost is arbitrary and it disturbs the LRU
pressure which vmpressure
reports properly. So shouldn't we account slab reclaimed in vmpressure
only when we have a proper
way to do it ? By adding slab reclaimed pages, we are saying
vmpressure that X pages were
reclaimed with 0 effort. With this patch the vmpressure will show an
estimate of pressure on LRU and
restores the original behavior of vmpressure. If we add in future the
slab cost, vmpressure can become
more accurate. But just adding slab reclaimed is arbitrary right ?
Consider a case where we start to
account reclaimed pages from other shrinkers which are not reporting
their reclaimed values right now.
Like zsmalloc, android lowmemorykiller etc. Then nr_reclaimed sent to
vmpressure will just be bloated
and will make vmpressure useless right ? And most of the time
vmpressure will receive
reclaimed greater than scanned and won't be reporting any critical
events. The problem we are
encountering now with slab reclaimed is a subset of the case above right ?

Starting to kill at the right time helps in recovering memory at a
faster rate than waiting for the
reclaim to complete. Yes, we may be able to modify lowmemorykiller to
cope with this
problem. But the actual problem this patch tried to fix was the
vmpressure event regression.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
