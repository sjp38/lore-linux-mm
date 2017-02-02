Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7539D6B0033
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 06:25:51 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id x84so11017583oix.7
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 03:25:51 -0800 (PST)
Received: from mail-ot0-x242.google.com (mail-ot0-x242.google.com. [2607:f8b0:4003:c0f::242])
        by mx.google.com with ESMTPS id q8si9334761otc.305.2017.02.02.03.25.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 03:25:50 -0800 (PST)
Received: by mail-ot0-x242.google.com with SMTP id 36so1427365otx.3
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 03:25:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170202104808.GG22806@dhcp22.suse.cz>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
 <1485853328-7672-1-git-send-email-vinmenon@codeaurora.org>
 <20170202104422.GF22806@dhcp22.suse.cz> <20170202104808.GG22806@dhcp22.suse.cz>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Thu, 2 Feb 2017 16:55:49 +0530
Message-ID: <CAOaiJ-nyZtgrCHjkGJeG3nhGFes5Y7go3zZwa3SxGrZV=LV0ag@mail.gmail.com>
Subject: Re: [PATCH 1/2 v3] mm: vmscan: do not pass reclaimed slab to vmpressure
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Thu, Feb 2, 2017 at 4:18 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 02-02-17 11:44:22, Michal Hocko wrote:
>> On Tue 31-01-17 14:32:08, Vinayak Menon wrote:
>> > During global reclaim, the nr_reclaimed passed to vmpressure
>> > includes the pages reclaimed from slab. But the corresponding
>> > scanned slab pages is not passed. This can cause total reclaimed
>> > pages to be greater than scanned, causing an unsigned underflow
>> > in vmpressure resulting in a critical event being sent to root
>> > cgroup. So do not consider reclaimed slab pages for vmpressure
>> > calculation. The reclaimed pages from slab can be excluded because
>> > the freeing of a page by slab shrinking depends on each slab's
>> > object population, making the cost model (i.e. scan:free) different
>> > from that of LRU.
>>
>> This might be true but what happens if the slab reclaim contributes
>> significantly to the overal reclaim? This would be quite rare but not
>> impossible.
>>
>> I am wondering why we cannot simply make cap nr_reclaimed to nr_scanned
>> and be done with this all? Sure it will be imprecise but the same will
>> be true with this approach.
Thinking of a case where 100 LRU pages were scanned and only 10 were reclaimed.
Now, say slab reclaimed 100 pages and we have no idea how many were scanned.
The actual vmpressure of 90 will now be 0 because of the addition on 100 slab
pages. So underflow was not the only issue, but incorrect vmpressure.
Even though the slab reclaimed is not accounted in vmpressure, the
slab reclaimed
pages will have a feedback effect on the LRU pressure right ? i.e. the
next LRU scan
will either be less or delayed if enough slab pages are reclaimed, in
turn lowering the
vmpressure or delaying it ? If that is so, the current approach of
neglecting slab reclaimed
will provide more accurate vmpressure than capping nr_reclaimed to nr_scanned ?
Our internal tests on Android actually shows the problem. When
vmpressure with slab
reclaimed added is used to kill tasks, it does not kick in at the right time.

>
> In other words something as "beautiful" as the following:
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 149fdf6c5c56..abea42817dd0 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -236,6 +236,15 @@ void vmpressure(gfp_t gfp, struct mem_cgroup *memcg, bool tree,
>                 return;
>
>         /*
> +        * Due to accounting issues - e.g. THP contributing 1 to scanned but
> +        * potentially much more to reclaimed or SLAB pages not contributing
> +        * to scanned at all - we have to skew reclaimed to prevent from
> +        * wrong pressure levels due to overflows.
> +        */
> +       if (reclaimed > scanned)
> +               reclaimed = scanned;
> +
> +       /*

This underflow problem is fixed by a separate patch
https://lkml.org/lkml/2017/1/27/48
That patch performs this check only once at the end of a window period.
Is that ok ?

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
