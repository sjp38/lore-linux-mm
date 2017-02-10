Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D5A996B0388
	for <linux-mm@kvack.org>; Fri, 10 Feb 2017 03:45:21 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id j82so30344149oih.6
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 00:45:21 -0800 (PST)
Received: from mail-ot0-x241.google.com (mail-ot0-x241.google.com. [2607:f8b0:4003:c0f::241])
        by mx.google.com with ESMTPS id t80si464857oih.118.2017.02.10.00.45.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Feb 2017 00:45:21 -0800 (PST)
Received: by mail-ot0-x241.google.com with SMTP id 65so3186618otq.2
        for <linux-mm@kvack.org>; Fri, 10 Feb 2017 00:45:21 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170209122007.GG10257@dhcp22.suse.cz>
References: <1486641577-11685-1-git-send-email-vinmenon@codeaurora.org>
 <1486641577-11685-2-git-send-email-vinmenon@codeaurora.org> <20170209122007.GG10257@dhcp22.suse.cz>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Fri, 10 Feb 2017 14:15:20 +0530
Message-ID: <CAOaiJ-nJWeMWeY1S5rBmC3M1EiT+HbiLcPwEMZsDMHemhGO0jA@mail.gmail.com>
Subject: Re: [PATCH 2/2 v5] mm: vmscan: do not pass reclaimed slab to vmpressure
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Thu, Feb 9, 2017 at 5:50 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 09-02-17 17:29:37, Vinayak Menon wrote:
>> During global reclaim, the nr_reclaimed passed to vmpressure includes the
>> pages reclaimed from slab.  But the corresponding scanned slab pages is
>> not passed. There is an impact to the vmpressure values because of this.
>> While moving from kernel version 3.18 to 4.4, a difference is seen
>> in the vmpressure values for the same workload resulting in a different
>> behaviour of the vmpressure consumer. One such case is of a vmpressure
>> based lowmemorykiller. It is observed that the vmpressure events are
>> received late and less in number resulting in tasks not being killed at
>> the right time. The following numbers show the impact on reclaim activity
>> due to the change in behaviour of lowmemorykiller on a 4GB device. The test
>> launches a number of apps in sequence and repeats it multiple times.
>
> this is really vague description of your workload and doesn't really
> explain why getting critical events later is a bad thing.
Ok. I will add that.

>
>>
>>                       v4.4           v3.18
>> pgpgin                163016456      145617236
>> pgpgout               4366220        4188004
>> workingset_refault    29857868       26781854
>> workingset_activate   6293946        5634625
>> pswpin                1327601        1133912
>> pswpout               3593842        3229602
>> pgalloc_dma           99520618       94402970
>> pgalloc_normal        104046854      98124798
>> pgfree                203772640      192600737
>> pgmajfault            2126962        1851836
>> pgsteal_kswapd_dma    19732899       18039462
>> pgsteal_kswapd_normal 19945336       17977706
>> pgsteal_direct_dma    206757         131376
>> pgsteal_direct_normal 236783         138247
>> pageoutrun            116622         108370
>> allocstall            7220           4684
>> compact_stall         931            856
>
> this is missing any vmpressure events data and so it is not very useful
> on its own
Done.

>
>> This is a regression introduced by commit 6b4f7799c6a5 ("mm: vmscan:
>> invoke slab shrinkers from shrink_zone()").
>>
>> So do not consider reclaimed slab pages for vmpressure calculation. The
>> reclaimed pages from slab can be excluded because the freeing of a page
>> by slab shrinking depends on each slab's object population, making the
>> cost model (i.e. scan:free) different from that of LRU.  Also, not every
>> shrinker accounts the pages it reclaims. But ideally the pages reclaimed
>> from slab should be passed to vmpressure, otherwise higher vmpressure
>> levels can be triggered even when there is a reclaim progress. But
>> accounting only the reclaimed slab pages without the scanned, and adding
>> something which does not fit into the cost model just adds noise to the
>> vmpressure values.
>>
>> Fixes: 6b4f7799c6a5 ("mm: vmscan: invoke slab shrinkers from shrink_zone()")
>> Acked-by: Minchan Kim <minchan@kernel.org>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Mel Gorman <mgorman@techsingularity.net>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
>> Cc: Anton Vorontsov <anton.vorontsov@linaro.org>
>> Cc: Shiraz Hashim <shashim@codeaurora.org>
>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>
> I have already said I will _not_ NAK the patch but we need a much better
> description and justification why the older behavior was better to
> consider this a regression before this can be merged. It is hard to
> expect that the underlying implementation of the vmpressure will stay
> carved in stone and there might be changes in this area in the future. I
> want to hear why we believe that the tested workload is sufficiently
> universal and we won't see another report in few months because somebody
> else will see higher vmpressure levels even though we make reclaim
> progress. I have asked those questions already but it seems those were
> ignored.

The tested workload is not universal. The lowmemorykiller example was used just
to mention the effect of vmpressure change on one of the workloads. I
can drop the
reclaim stats and just keep the stats of change observed in vmpressure
critical events.
I am not sure whether we would see another issue reported with this
patch. We may because
someone would have written a code that works with this new vmpressure
values. I am not
sure whether that matters because the core issue is whether the kernel
is reporting the
right values.  This could be termed as a regression because,

1) Accounting only reclaimed pages to a model which works on scanned
and reclaimed
seems like a wrong thing. It is just adding noise to it. There could
be issues with vmpressure
implementation, but it at least gives an estimate on what the pressure
on LRU is. There are
many other shrinkers like zsmalloc which does not report reclaimed
pages, and when add those
also in a similar fashion without considering the cost part,
vmpressure values would always
remain low. So util we have a way to give correct information to
vmpressure about non-LRU
reclaimers, I feel its better to keep it in its original form.

2) As Minchan mentioned, the cost model is different and thus adding
slab reclaimed would
not be the right thing to do at this point.

But if you feel we don't have to fix this now and that it is better to
fix the core problems with
vmpressure first, that's ok. Anyway I will sent a patch with a new
changelog with vmpressure
event details. Thanks Michal for your comments.

Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
