Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CFA06B000C
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 07:04:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j8so4942211pfh.13
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 04:04:03 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id f9-v6si6051066pln.542.2018.03.16.04.04.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 04:04:01 -0700 (PDT)
Subject: Re: [PATCH] mm: fix low-high watermark distance on small systems
References: <1521110079-26870-1-git-send-email-vinmenon@codeaurora.org>
 <20180315143415.GA473@rodete-desktop-imager.corp.google.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <d6dc8e61-8d3e-d628-2651-50db62dd7fa1@codeaurora.org>
Date: Fri, 16 Mar 2018 16:33:54 +0530
MIME-Version: 1.0
In-Reply-To: <20180315143415.GA473@rodete-desktop-imager.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: hannes@cmpxchg.org, mgorman@techsingularity.net, linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, sfr@canb.auug.org.au, pasha.tatashin@oracle.com, penguin-kernel@I-love.SAKURA.ne.jp


On 3/15/2018 8:04 PM, Minchan Kim wrote:
> Hi Vinayak,

Thanks for your comments Minchan.
>
> On Thu, Mar 15, 2018 at 04:04:39PM +0530, Vinayak Menon wrote:
>> It is observed that watermark_scale_factor when used to reduce
>> thundering herds in direct reclaim, reduces the direct reclaims,
>> but results in unnecessary reclaim due to kswapd running for long
>> after being woken up. The tests are done with 4 GB of RAM and the
>> tests done are multibuild and another which opens a set of apps
>> sequentially on Android and repeating the sequence N times. The
>> tests are done on 4.9 kernel.
>>
>> The issue is caused by watermark_scale_factor creating larger than
>> required gap between low and high watermarks. The following results
>> are with watermark_scale_factor of 120.
>>
>>                        wsf-120-default  wsf-120-reduced-low-high-gap
>> workingset_activate    15120206         8319182
>> pgpgin                 269795482        147928581
>> allocstall             1406             1498
>> pgsteal_kswapd         68676960         38105142
>> slabs_scanned          94181738         49085755
> "required gap" you mentiond is very dependent for your workload.
> You had an experiment with wsf-120. It means user wanted to be more
> aggressive for kswapd while your load is not enough to make meomry
> consumption spike. Couldn't you decrease wfs?

I did try reducing the wsf for both multibuild and Android workloads. But that results in kswapd
waking up late and thus latency issues due to higher direct reclaims. As I understand the problem, the
wsf in its current form helps in tuning the kswapd wakeups (and note that I have not touched the
wsf logic to calculate min-low gap), but the issue arises due to the depth to which kswapd scans the LRUs in a
single run, causing thrashing, due to the higher low-high gap. From experiments, it looks like kswapd waking
up few more times and doing shorter steals is better than kswapd stealing more in a single run. The latter
does not better direct reclaims and causes thrashing too.

>
> Don't get me wrong. I don't want you test all of wfs with varios
> workload to prove your logic is better. What I want to say here is
> it's heuristic so it couldn't be perfect for every workload so
> if you change to non-linear, you could be better but others might be not.

Yes I understand your point. But since mmtests and Android tests showed similar results, I thought the
heuristic may just work across workloads. I assume from Johannes's tests on 140GB machine (from the
commit msg of the patch which introduced wsf) that the current low-high gap works well without thrashing
on bigger machines. This made me assume that the behavior is non-linear. So the non-linear behavior will
not make any difference to higher RAM machines as the low-high remains almost same as shown in the table
below. But I understand your point, for a different workload on smaller machines, I am not sure the benefit I
see would be observed, though that's the same problem with current wsf too.

>
> In such context, current linear linear scale factor is simple enough
> to understand. IMO, if we really want to enhance watermark, the low/high
> wmark shold be adaptable according to memory spike. One of rough idea is
> to change low/high wmark based on kswapd_[high|low]_wmark_hit_quickly.

That seems like a nice idea to me.A  But considering the current case with and without this patch,
the kswapd_low_wmark_hit quickly is actually less without the patch. But that comes at the cost of thrashing.
Which then would mean we need to detect thrashing to adjust the watermark. We may get the thrashing data
from workingset refaults, but I am not sure if we can take it as an input to adjust watermark since thrashing can
be due to other reasons too. Maybe there are ways to make this adaptive, like using Johannes's memdelay feature
to detect more time spent in direct reclaims and then raise the low watermark, and then use time spent in refault
and stabilized direct reclaim time to bring down or stop raising the low watermark.
But do we need that adaptive logic now if this (or other similar) patch just works across workloads for small machines ?
What is your suggestion ?

>> Even though kswapd does 80% more steal in the default case, it doesn't
>> make any significant improvement to the direct reclaims. The excessive
>> reclaims cause more pgpgin and increases app launch latencies.
>>
>> The min-low gap is untouched by the patch. The low-high gap is made
>> a percentage of min-low gap. The fraction was derived considering
>> these,
>>
>> 1) The existing watermark_scale_factor logic was designed to fix
>> issues on high RAM machines and I assume that the current low-high
>> gap works well on those.
>> 2) The gap should be reduced on low RAM targets where thrashing is
>> observed.
>>
>> The multiplier 4 was chosen empirically which was seen to fix the
>> thrashing on <8GB devices.
>>
>> With watermark_scale_factor as default 10, the low-high gap for different
>> memory sizes.
>>            default-low_high_gap-pages  this-patch-low_high_gap-pages
>> 16M        4                           4
>> 512M       131                         131
>> 1024M      262                         256
>> 2048M      524                         362
>> 4096M      1048                        512
>> 8192M      2097                        724
>> 16384M     4194                        1717
>> 32768M     8388                        4858
>> 65536M     16777                       13743
>> 102400M    26214                       26214
>> 143360M    36700                       36700
>>
>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>> ---
>>  mm/page_alloc.c | 15 ++++++++++++++-
>>  1 file changed, 14 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index c0f0b1b..ac75985 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -7223,7 +7223,20 @@ static void __setup_per_zone_wmarks(void)
>>  				      watermark_scale_factor, 10000));
>>  
>>  		zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
>> -		zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
>> +
>> +		/*
>> +		 * Set the kswapd low-high distance as a percentage of
>> +		 * min-low distance in such a way that the distance
>> +		 * increases non-linearly with available memory. This
>> +		 * ensures enough free memory without causing thrashing
>> +		 * on small machines due to excessive reclaim by kswapd.
>> +		 * Ensure a minimum distance on very small machines.
>> +		 */
>> +		tmp = clamp_t(u64, mult_frac(tmp,
>> +				int_sqrt(4 * zone->managed_pages), 10000),
>> +					min_wmark_pages(zone) >> 2, tmp);
>> +
>> +		zone->watermark[WMARK_HIGH] = low_wmark_pages(zone) + tmp;
>>  
>>  		spin_unlock_irqrestore(&zone->lock, flags);
>>  	}
>> -- 
>> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
>> member of the Code Aurora Forum, hosted by The Linux Foundation
>>
