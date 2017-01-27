Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 59A6C6B0033
	for <linux-mm@kvack.org>; Fri, 27 Jan 2017 03:13:25 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id s36so207187317otd.3
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 00:13:25 -0800 (PST)
Received: from mail-ot0-x241.google.com (mail-ot0-x241.google.com. [2607:f8b0:4003:c0f::241])
        by mx.google.com with ESMTPS id y93si1718185otb.169.2017.01.27.00.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jan 2017 00:13:24 -0800 (PST)
Received: by mail-ot0-x241.google.com with SMTP id 65so30183745otq.2
        for <linux-mm@kvack.org>; Fri, 27 Jan 2017 00:13:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170126141836.GA3584@bbox>
References: <1485344318-6418-1-git-send-email-vinmenon@codeaurora.org>
 <20170125232713.GB20811@bbox> <CAOaiJ-mk=SmNR4oK+udhJNxHzmobf28wSu+nf449c=1cHMBDAg@mail.gmail.com>
 <20170126141836.GA3584@bbox>
From: vinayak menon <vinayakm.list@gmail.com>
Date: Fri, 27 Jan 2017 13:43:23 +0530
Message-ID: <CAOaiJ-m=X=8GpLCW-7wVkBmT=Gq9V9ocXtcXbmNNALffLepWeg@mail.gmail.com>
Subject: Re: [PATCH] mm: vmscan: do not pass reclaimed slab to vmpressure
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Shiraz Hashim <shiraz.hashim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

>
> Thanks for the explain. However, such case can happen with THP page
> as well as slab. In case of THP page, nr_scanned is 1 but nr_reclaimed
> could be 512 so I think vmpressure should have a logic to prevent undeflow
> regardless of slab shrinking.
>
I see. Going to send a vmpressure fix. But, wouldn't the THP case
result in incorrect
vmpressure reporting even if we fix the vmpressure underflow problem ?

>>
>> >
>> >> unsigned arithmetic results in the pressure value to be
>> >> huge, thus resulting in a critical event being sent to
>> >> root cgroup. Fix this by not passing the reclaimed slab
>> >> count to vmpressure, with the assumption that vmpressure
>> >> should show the actual pressure on LRU which is now
>> >> diluted by adding reclaimed slab without a corresponding
>> >> scanned value.
>> >
>> > I can't guess justfication of your assumption from the description.
>> > Why do we consider only LRU pages for vmpressure? Could you elaborate
>> > a bit?
>> >
>> When we encountered the false events from vmpressure, thought the problem
>> could be that slab scanned is not included in sc->nr_scanned, like it is done
>> for reclaimed. But later thought vmpressure works only on the scanned and
>> reclaimed from LRU. I can explain what I understand, let me know if this is
>> incorrect.
>> vmpressure is an index which tells the pressure on LRU, and thus an
>> indicator of thrashing. In shrink_node when we come out of the inner do-while
>> loop after shrinking the lruvec, the scanned and reclaimed corresponds to the
>> pressure felt on the LRUs which in turn indicates the pressure on VM. The
>> moment we add the slab reclaimed pages to the reclaimed, we dilute the
>> actual pressure felt on LRUs. When slab scanned/reclaimed is not included
>> in the vmpressure, the values will indicate the actual pressure and if there
>> were a lot of slab reclaimed pages it will result in lesser pressure
>> on LRUs in the next run which will again be indicated by vmpressure. i.e. the
>
> I think there is no intention to exclude slab by design of vmpressure.
> Beause slab is memory consumption so freeing of slab pages really helps
> the memory pressure. Also, there might be slab-intensive workload rather
> than LRU. It would be great if vmpressure works well with that case.
> But the problem with involving slab for vmpressure is it's not fair with
> LRU pages. LRU pages are 1:1 cost model for scan:free but slab shriking
> depends the each slab's object population. It means it's impossible to
> get stable cost model with current slab shrinkg model, unfortunately.
> So I don't obejct this patch although I want to see slab shrink model's
> change which is heavy-handed work.
>
Looking at the code, the slab reclaimed pages started getting passed to
vmpressure after the commit ("mm: vmscan: invoke slab shrinkers from
shrink_zone()").
But as you said, this may be helpful for slab intensive workloads. But in its
current form I think it results in incorrect vmpressure reporting because of not
accounting the slab scanned pages. Resending the patch with a modified
commit msg
since the underflow issue is fixed separately. Thanks Minchan.

Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
