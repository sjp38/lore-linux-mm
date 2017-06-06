Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id BBC5583293
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 09:10:15 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id m76so32968018vkh.9
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 06:10:15 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [45.249.212.187])
        by mx.google.com with ESMTPS id b16si14911038vke.177.2017.06.06.06.10.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 06:10:14 -0700 (PDT)
Message-ID: <5936A787.4050002@huawei.com>
Date: Tue, 6 Jun 2017 21:00:55 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmscan: do not pass reclaimed slab to vmpressure
References: <1485344318-6418-1-git-send-email-vinmenon@codeaurora.org> <20170125232713.GB20811@bbox> <CAOaiJ-mk=SmNR4oK+udhJNxHzmobf28wSu+nf449c=1cHMBDAg@mail.gmail.com> <20170126141836.GA3584@bbox> <CAOaiJ-m=X=8GpLCW-7wVkBmT=Gq9V9ocXtcXbmNNALffLepWeg@mail.gmail.com> <20170130234028.GA7942@bbox>
In-Reply-To: <20170130234028.GA7942@bbox>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: vinayak menon <vinayakm.list@gmail.com>, Vinayak Menon <vinmenon@codeaurora.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, Rik van Riel <riel@redhat.com>, vdavydov.dev@gmail.com, anton.vorontsov@linaro.org, Shiraz Hashim <shiraz.hashim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On 2017/1/31 7:40, Minchan Kim wrote:
> Hi Vinayak,
> Sorry for late response. It was Lunar New Year holidays.
>
> On Fri, Jan 27, 2017 at 01:43:23PM +0530, vinayak menon wrote:
>>> Thanks for the explain. However, such case can happen with THP page
>>> as well as slab. In case of THP page, nr_scanned is 1 but nr_reclaimed
>>> could be 512 so I think vmpressure should have a logic to prevent undeflow
>>> regardless of slab shrinking.
>>>
>> I see. Going to send a vmpressure fix. But, wouldn't the THP case
>> result in incorrect
>> vmpressure reporting even if we fix the vmpressure underflow problem ?
> If a THP page is reclaimed, it reports lower pressure due to bigger
> reclaim ratio(ie, reclaimed/scanned) compared to normal pages but
> it's not a problem, is it? Because VM reclaimed more memory than
> expected so memory pressure isn't severe now.
  Hi, Minchan

  THP lru page is reclaimed, reclaim ratio bigger make sense. but I read the code, I found
  THP is split to normal pages and loop again.  reclaimed pages should not be bigger
   than nr_scan.  because of each loop will increase nr_scan counter.
 
   It is likely  I miss something.  you can point out the point please.
 
  Thanks
  zhongjiang
>>>>>> unsigned arithmetic results in the pressure value to be
>>>>>> huge, thus resulting in a critical event being sent to
>>>>>> root cgroup. Fix this by not passing the reclaimed slab
>>>>>> count to vmpressure, with the assumption that vmpressure
>>>>>> should show the actual pressure on LRU which is now
>>>>>> diluted by adding reclaimed slab without a corresponding
>>>>>> scanned value.
>>>>> I can't guess justfication of your assumption from the description.
>>>>> Why do we consider only LRU pages for vmpressure? Could you elaborate
>>>>> a bit?
>>>>>
>>>> When we encountered the false events from vmpressure, thought the problem
>>>> could be that slab scanned is not included in sc->nr_scanned, like it is done
>>>> for reclaimed. But later thought vmpressure works only on the scanned and
>>>> reclaimed from LRU. I can explain what I understand, let me know if this is
>>>> incorrect.
>>>> vmpressure is an index which tells the pressure on LRU, and thus an
>>>> indicator of thrashing. In shrink_node when we come out of the inner do-while
>>>> loop after shrinking the lruvec, the scanned and reclaimed corresponds to the
>>>> pressure felt on the LRUs which in turn indicates the pressure on VM. The
>>>> moment we add the slab reclaimed pages to the reclaimed, we dilute the
>>>> actual pressure felt on LRUs. When slab scanned/reclaimed is not included
>>>> in the vmpressure, the values will indicate the actual pressure and if there
>>>> were a lot of slab reclaimed pages it will result in lesser pressure
>>>> on LRUs in the next run which will again be indicated by vmpressure. i.e. the
>>> I think there is no intention to exclude slab by design of vmpressure.
>>> Beause slab is memory consumption so freeing of slab pages really helps
>>> the memory pressure. Also, there might be slab-intensive workload rather
>>> than LRU. It would be great if vmpressure works well with that case.
>>> But the problem with involving slab for vmpressure is it's not fair with
>>> LRU pages. LRU pages are 1:1 cost model for scan:free but slab shriking
>>> depends the each slab's object population. It means it's impossible to
>>> get stable cost model with current slab shrinkg model, unfortunately.
>>> So I don't obejct this patch although I want to see slab shrink model's
>>> change which is heavy-handed work.
>>>
>> Looking at the code, the slab reclaimed pages started getting passed to
>> vmpressure after the commit ("mm: vmscan: invoke slab shrinkers from
>> shrink_zone()").
>> But as you said, this may be helpful for slab intensive workloads. But in its
>> current form I think it results in incorrect vmpressure reporting because of not
>> accounting the slab scanned pages. Resending the patch with a modified
>> commit msg
>> since the underflow issue is fixed separately. Thanks Minchan.
> Make sense.
>
> Thanks, Vinayak!
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
