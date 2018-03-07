Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7CABD6B0005
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 04:17:17 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id u2so764385pgn.19
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 01:17:17 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id w3-v6si12548948plb.441.2018.03.07.01.17.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 01:17:16 -0800 (PST)
Subject: Re: [RFC] kswapd aggressiveness with watermark_scale_factor
References: <7d57222b-42f5-06a2-2f91-75384e0c0bd9@codeaurora.org>
 <20180215124016.hn64v57istrfwz7p@techsingularity.net>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <0467b068-4627-e49f-77e8-c785a38a0d74@codeaurora.org>
Date: Wed, 7 Mar 2018 14:47:09 +0530
MIME-Version: 1.0
In-Reply-To: <20180215124016.hn64v57istrfwz7p@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, hannes@cmpxchg.org, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.com, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "vbabka@suse.cz" <vbabka@suse.cz>

On 2/15/2018 6:10 PM, Mel Gorman wrote:
> On Wed, Jan 24, 2018 at 09:25:37PM +0530, Vinayak Menon wrote:
>> Hi,
>>
>> It is observed that watermark_scale_factor when used to reduce thundering herds
>> in direct reclaim, reduces the direct reclaims, but results in unnecessary reclaim
>> due to kswapd running for long after being woken up. The tests are done with 4 GB
>> of RAM and the tests done are multibuild and another which opens a set of apps
>> sequentially on Android and repeating the sequence N times. The tests are done on
>> 4.9 kernel.
>>
>> The issue seems to be because of watermark_scale_factor creating larger gap between
>> low and high watermarks. The following results are with watermark_scale_factor of 120
>> and the other with watermark_scale_factor 120 with a reduced gap between low and
>> high watermarks. The patch used to reduce the gap is given below. The min-low gap is
>> untouched. It can be seen that with the reduced low-high gap, the direct reclaims are
>> almost same as base, but with 45% less pgpgin. Reduced low-high gap improves the
>> latency by around 11% in the sequential app test due to lesser IO and kswapd activity.
>>
>>                        wsf-120-default      wsf-120-reduced-low-high-gap
>> workingset_activate    15120206             8319182
>> pgpgin                 269795482            147928581
>> allocstall             1406                 1498
>> pgsteal_kswapd         68676960             38105142
>> slabs_scanned          94181738             49085755
>>
>> This is the diff of wsf-120-reduced-low-high-gap for comments. The patch considers
>> low-high gap as a fraction of min-low gap, and the fraction a function of managed pages,
>> increasing non-linearly. The multiplier 4 is was chosen as a reasonable value which does
>> not alter the low-high gap much from the base for large machines.
>>
> This needs a proper changelog, signed-offs and a comment on the reasoning
> behind the new min value for the gap between low and high and how it
> was derived.  It appears the equation was designed such at the gap, as
> a percentage of the zone size, would shrink according as the zone size
> increases but I'm not 100% certain that was the intent. That should be
> explained and why not just using "tmp >> 2" would have problems.
>
> It would also need review/testing by Johannes to ensure that there is no
> reintroduction of the problems that watermark_scale_factor was designed
> to solve.

Sorry for the delayed response. I will send a patch with the details. The equation was designed so that the
low-high gap is small for smaller RAM sizes and tends towards min-low gap as the RAM size increases. This
was done considering that it should not have a bad effect on for 140G configuration which Johannes had taken
taken as example when watermark_scale_factor was introduced, also assuming that the thrashing seen due to
low-high gap would be visible only on low RAM devices.

>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 3a11a50..749d1eb 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -6898,7 +6898,11 @@ static void __setup_per_zone_wmarks(void)
>>                                       watermark_scale_factor, 10000));
>>
>>                 zone->watermark[WMARK_LOW]  = min_wmark_pages(zone) + tmp;
>> -               zone->watermark[WMARK_HIGH] = min_wmark_pages(zone) + tmp * 2;
>> +
>> +               tmp = clamp_t(u64, mult_frac(tmp, int_sqrt(4 * zone->managed_pages),
>> +                               10000), min_wmark_pages(zone) >> 2 , tmp);
>> +
>> +               zone->watermark[WMARK_HIGH] = low_wmark_pages(zone) + tmp;
>>
>>                 spin_unlock_irqrestore(&zone->lock, flags);
>>         }
>>
>> With the patch,
>> With watermark_scale_factor as default 10, the low-high gap:
>> unchanged for 140G at 143M,
>> for 65G, reduces from 65M to 53M
>> for 4GB, reduces from 4M to 1M
>>
>> With watermark_scale_factor 120, the low-high gap:
>> unchanged for 140G
>> for 65G, reduces from 786M to 644M
>> for 4GB, reduces from 49M to 10M
>>
> This information should also be in the changelog.

Sure.

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
