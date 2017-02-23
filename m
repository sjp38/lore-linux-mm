Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 855D56B0038
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 04:02:00 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id t184so40378430pgt.1
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 01:02:00 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id l28si3777966pgc.81.2017.02.23.01.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 01:01:59 -0800 (PST)
Subject: Re: + mm-vmscan-do-not-pass-reclaimed-slab-to-vmpressure.patch added
 to -mm tree
References: <58a38a94.nb3wSoo24sv+3Kju%akpm@linux-foundation.org>
 <20170222104303.GH5753@dhcp22.suse.cz>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <4378f15c-91fa-2ad1-4c32-2fce11262ef3@codeaurora.org>
Date: Thu, 23 Feb 2017 14:31:51 +0530
MIME-Version: 1.0
In-Reply-To: <20170222104303.GH5753@dhcp22.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org
Cc: anton.vorontsov@linaro.org, hannes@cmpxchg.org, mgorman@techsingularity.net, minchan@kernel.org, riel@redhat.com, shashim@codeaurora.org, vbabka@suse.cz, vdavydov.dev@gmail.com, mm-commits@vger.kernel.org, linux-mm@kvack.org


On 2/22/2017 4:13 PM, Michal Hocko wrote:
> On Tue 14-02-17 14:54:12, akpm@linux-foundation.org wrote:
>> From: Vinayak Menon <vinmenon@codeaurora.org>
>> Subject: mm: vmscan: do not pass reclaimed slab to vmpressure
>>
>> During global reclaim, the nr_reclaimed passed to vmpressure includes the
>> pages reclaimed from slab.  But the corresponding scanned slab pages is
>> not passed.  There is an impact to the vmpressure values because of this. 
>> While moving from kernel version 3.18 to 4.4, a difference is seen in the
>> vmpressure values for the same workload resulting in a different behaviour
>> of the vmpressure consumer.  One such case is of a vmpressure based
>> lowmemorykiller.  It is observed that the vmpressure events are received
>> late and less in number resulting in tasks not being killed at the right
>> time.  The following numbers show the impact on reclaim activity due to
>> the change in behaviour of lowmemorykiller on a 4GB device.  The test
>> launches a number of apps in sequence and repeats it multiple times.
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
>>
>> This is a regression introduced by commit 6b4f7799c6a5 ("mm: vmscan:
>> invoke slab shrinkers from shrink_zone()").
>>
>> So do not consider reclaimed slab pages for vmpressure calculation.  The
>> reclaimed pages from slab can be excluded because the freeing of a page by
>> slab shrinking depends on each slab's object population, making the cost
>> model (i.e.  scan:free) different from that of LRU.  Also, not every
>> shrinker accounts the pages it reclaims.  But ideally the pages reclaimed
>> from slab should be passed to vmpressure, otherwise higher vmpressure
>> levels can be triggered even when there is a reclaim progress.  But
>> accounting only the reclaimed slab pages without the scanned, and adding
>> something which does not fit into the cost model just adds noise to the
>> vmpressure values.
> I believe there are still some of my questions which are not answered by
> the changelog update. Namely
> - vmstat numbers without mentioning vmpressure events for those 2
>   kernels have basically no meaning.
Sending a new version. The vmpressure events difference is added.
> - the changelog doesn't mention that the test case basically benefits
>   from as many lmk interventions as possible. Does this represent a real
>   life workload? If not is there any real life workload which would
>   benefit from the new behavior.
The use case does not actually benefit from as many lmk interventions as possible. Because it has to also take care
of maximizing the number of applications sustained. IMHO Android using a vmpressure based user space lowmemorykiller
is a real life workload. But the lowmemorykiller killer example was just to show the difference in vmpressure events between
2 kernel versions. Any workload which uses vmpressure would be something similar ? It would take an action by killing tasks,
or releasing some buffers etc as I understand. The patch was actually meant to fix the addition of noise to vmpressure by
adding reclaimed without accounting the cost and the lmk example was just to indicate the difference in vmpressure events.
> - I would be also very careful calling this a regression without having
>   any real workload as an example
Okay. I have removed that from changelog.
> - Arguments about the cost model is are true but the resulting code is
>   not a 100% win either and the changelog should be explicit about the
>   consequences - aka more critical events can fire early while there is
>   still slab making a reclaim progress.
>  
This line was added to changelog indicating the consequence.
"Ideally the pages reclaimed from slab should be passed to vmpressure, otherwise higher vmpressure levels can
 be triggered even when there is a reclaim progress."

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
