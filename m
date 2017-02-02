Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB2026B0260
	for <linux-mm@kvack.org>; Thu,  2 Feb 2017 10:30:11 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id f9so17000060otd.4
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 07:30:11 -0800 (PST)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id c53si9599770otd.261.2017.02.02.07.30.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Feb 2017 07:30:11 -0800 (PST)
Received: by mail-oi0-x244.google.com with SMTP id x84so1429154oix.2
        for <linux-mm@kvack.org>; Thu, 02 Feb 2017 07:30:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170202115222.GH22806@dhcp22.suse.cz>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org>
 <1485853328-7672-1-git-send-email-vinmenon@codeaurora.org>
 <20170202104422.GF22806@dhcp22.suse.cz> <20170202104808.GG22806@dhcp22.suse.cz>
 <CAOaiJ-nyZtgrCHjkGJeG3nhGFes5Y7go3zZwa3SxGrZV=LV0ag@mail.gmail.com> <20170202115222.GH22806@dhcp22.suse.cz>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Thu, 2 Feb 2017 21:00:10 +0530
Message-ID: <CAOaiJ-=pCUzaVbte-+QiQoN_XtB0KFbcB40yjU9r7OV8VOkmFg@mail.gmail.com>
Subject: Re: [PATCH 1/2 v3] mm: vmscan: do not pass reclaimed slab to vmpressure
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Minchan Kim <minchan@kernel.org>, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Thu, Feb 2, 2017 at 5:22 PM, Michal Hocko <mhocko@kernel.org> wrote:
> On Thu 02-02-17 16:55:49, vinayak menon wrote:
>> On Thu, Feb 2, 2017 at 4:18 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Thu 02-02-17 11:44:22, Michal Hocko wrote:
>> >> On Tue 31-01-17 14:32:08, Vinayak Menon wrote:
>> >> > During global reclaim, the nr_reclaimed passed to vmpressure
>> >> > includes the pages reclaimed from slab. But the corresponding
>> >> > scanned slab pages is not passed. This can cause total reclaimed
>> >> > pages to be greater than scanned, causing an unsigned underflow
>> >> > in vmpressure resulting in a critical event being sent to root
>> >> > cgroup. So do not consider reclaimed slab pages for vmpressure
>> >> > calculation. The reclaimed pages from slab can be excluded because
>> >> > the freeing of a page by slab shrinking depends on each slab's
>> >> > object population, making the cost model (i.e. scan:free) different
>> >> > from that of LRU.
>> >>
>> >> This might be true but what happens if the slab reclaim contributes
>> >> significantly to the overal reclaim? This would be quite rare but not
>> >> impossible.
>> >>
>> >> I am wondering why we cannot simply make cap nr_reclaimed to nr_scanned
>> >> and be done with this all? Sure it will be imprecise but the same will
>> >> be true with this approach.
>>
>> Thinking of a case where 100 LRU pages were scanned and only 10 were
>> reclaimed.  Now, say slab reclaimed 100 pages and we have no idea
>> how many were scanned.  The actual vmpressure of 90 will now be 0
>> because of the addition on 100 slab pages. So underflow was not the
>> only issue, but incorrect vmpressure.
>
> Is this actually a problem. The end result - enough pages being
> reclaimed should matter, no?
>
But vmpressure is incorrect now, no ? Because the scanned slab pages is
not included in nr_scanned (the cost). The 100 scanned and 10 reclaimed from LRU
were a reasonable estimate as you said, and to that we are adding a
reclaimed value alone without
scanned and thus making it incorrect ? Because the cost of slab reclaim is not
accounted. But I agree that the vmpressure value would have been more correct
if it could include both scanned and reclaimed from slab. And may be
more correct
if we can include the scanned and reclaimed from all shrinkers which I
think is not
the case right now (lowmemorykiller, zsmalloc etc). But as Minchan was pointing
out, since the cost model for slab is different, would it be fine to
just add reclaimed
from slab to vmpressure ?

>> Even though the slab reclaimed is not accounted in vmpressure, the
>> slab reclaimed pages will have a feedback effect on the LRU pressure
>> right ? i.e. the next LRU scan will either be less or delayed if
>> enough slab pages are reclaimed, in turn lowering the vmpressure or
>> delaying it ?
>
> Not sure what you mean but we can break out from the direct reclaim
> because we have fulfilled the reclaim target and that is why I think
> that it shouldn't be really harmful to consider them in the pressure
> calculation. After all we are making reclaim progress and that should
> be considered. reclaimed/scanned is a reasonable estimation but it has
> many issues because it doesn't really tell how hard it was to get that
> number of pages reclaimed. We might have to wait for writeback which is
> something completely different from a clean page cache. There are
> certainly different possible metrics.
>
I see.

>> If that is so, the
>> current approach of neglecting slab reclaimed will provide more
>> accurate vmpressure than capping nr_reclaimed to nr_scanned ?
>
> The problem I can see is that you can get serious vmpressure events
> while the reclaim manages to provide pages we are asking for and later
> decisions might be completely inappropriate.
>
>> Our
>> internal tests on Android actually shows the problem. When vmpressure
>> with slab reclaimed added is used to kill tasks, it does not kick in
>> at the right time.
>
> With the skewed reclaimed? How that happens? Could you elaborate more?
Yes. Because of the skewed reclaim. The observation is that the vmpressure
critical events are received late. Because of adding slab reclaimed without
corresponding scanned, the vmpressure values are diluted resulting in lesser
number of critical events at the beginning, resulting in tasks not
being chosen to
be killed. This increases the memory pressure and finally result in
late critical events,
but by that time the task launch latencies are impacted.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
