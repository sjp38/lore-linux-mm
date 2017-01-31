Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 34F806B0253
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 02:48:42 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id w107so311746682ota.6
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 23:48:42 -0800 (PST)
Received: from mail-oi0-x244.google.com (mail-oi0-x244.google.com. [2607:f8b0:4003:c06::244])
        by mx.google.com with ESMTPS id 43si6502617ote.157.2017.01.30.23.48.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 23:48:41 -0800 (PST)
Received: by mail-oi0-x244.google.com with SMTP id w144so27804439oiw.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 23:48:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170130235642.GB7942@bbox>
References: <1485504817-3124-1-git-send-email-vinmenon@codeaurora.org> <20170130235642.GB7942@bbox>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Tue, 31 Jan 2017 13:18:40 +0530
Message-ID: <CAOaiJ-mut9NO_+bj28DAz-yXbcUocvMjPVx=t=2umE+5Fp2kYQ@mail.gmail.com>
Subject: Re: [PATCH 1/2 v2] mm: vmscan: do not pass reclaimed slab to vmpressure
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, shashim@codeaurora.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On Tue, Jan 31, 2017 at 5:26 AM, Minchan Kim <minchan@kernel.org> wrote:
> On Fri, Jan 27, 2017 at 01:43:36PM +0530, Vinayak Menon wrote:
>> It is noticed that during a global reclaim the memory
>> reclaimed via shrinking the slabs can sometimes result
>> in reclaimed pages being greater than the scanned pages
>> in shrink_node. When this is passed to vmpressure, the
>> unsigned arithmetic results in the pressure value to be
>> huge, thus resulting in a critical event being sent to
>> root cgroup. While this can be fixed by underflow checks
>> in vmpressure, adding reclaimed slab without a corresponding
>> increment of nr_scanned results in incorrect vmpressure
>> reporting. So do not consider reclaimed slab pages in
>> vmpressure calculation.
>
> I belive we could enhance the description better.
>
> problem
>
> VM include nr_reclaimed of slab but not nr_scanned so pressure
> calculation can be underflow.
>
> solution
>
> do not consider reclaimed slab pages for vmpressure
>
> why
>
> Freeing a page by slab shrinking depends on each slab's object
> population so the cost model(i.e., scan:free) is not fair with
> LRU pages. Also, every shrinker doesn't account reclaimed pages.
> Lastly, this regression happens since 6b4f7799c6a5
>
Done. Sending an updated one.

>>
>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>> ---
>>  mm/vmscan.c | 10 +++++-----
>>  1 file changed, 5 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 947ab6f..37c4486 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2594,16 +2594,16 @@ static bool shrink_node(pg_data_t *pgdat, struct scan_control *sc)
>>                                   sc->nr_scanned - nr_scanned,
>>                                   node_lru_pages);
>>
>> -             if (reclaim_state) {
>> -                     sc->nr_reclaimed += reclaim_state->reclaimed_slab;
>> -                     reclaim_state->reclaimed_slab = 0;
>> -             }
>> -
>>               /* Record the subtree's reclaim efficiency */
>>               vmpressure(sc->gfp_mask, sc->target_mem_cgroup, true,
>>                          sc->nr_scanned - nr_scanned,
>>                          sc->nr_reclaimed - nr_reclaimed);
>>
>
> Please add comment about "vmpressure excludes reclaimed pages via slab
> because blah blah blah" so upcoming patches doesn't make mistake again.
>
> Thanks!
>
Done. Thanks Minchan.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
