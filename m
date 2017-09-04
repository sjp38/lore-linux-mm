Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9583E6B0497
	for <linux-mm@kvack.org>; Mon,  4 Sep 2017 04:30:57 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a126so6425591lfa.5
        for <linux-mm@kvack.org>; Mon, 04 Sep 2017 01:30:57 -0700 (PDT)
Received: from forwardcorp1g.cmail.yandex.net (forwardcorp1g.cmail.yandex.net. [87.250.241.190])
        by mx.google.com with ESMTPS id t16si2637846ljd.381.2017.09.04.01.30.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Sep 2017 01:30:56 -0700 (PDT)
Subject: Re: [PATCH] mm/vmstats: add counters for the page frag cache
References: <1504222631-2635-1-git-send-email-kyeongdon.kim@lge.com>
 <50592560-af4d-302c-c0bc-1e854e35139d@yandex-team.ru>
 <19156a13-6153-f570-317b-7b80505347e7@lge.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <d6120888-344a-4449-4ca6-ac98508bb3cf@yandex-team.ru>
Date: Mon, 4 Sep 2017 11:30:55 +0300
MIME-Version: 1.0
In-Reply-To: <19156a13-6153-f570-317b-7b80505347e7@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyeongdon Kim <kyeongdon.kim@lge.com>, akpm@linux-foundation.org, sfr@canb.auug.org.au
Cc: ying.huang@intel.com, vbabka@suse.cz, hannes@cmpxchg.org, xieyisheng1@huawei.com, luto@kernel.org, shli@fb.com, mhocko@suse.com, mgorman@techsingularity.net, hillf.zj@alibaba-inc.com, kemi.wang@intel.com, rientjes@google.com, bigeasy@linutronix.de, iamjoonsoo.kim@lge.com, bongkyu.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev <netdev@vger.kernel.org>

On 04.09.2017 04:35, Kyeongdon Kim wrote:
> Thanks for your reply,
> But I couldn't find "NR_FRAGMENT_PAGES" in linux-next.git .. is that vmstat counter? or others?
> 

I mean rather than adding bunch vmstat counters for operations it might be
worth to add page counter which will show current amount of these pages.
But this seems too low-level for tracking, common counters for all network
buffers would be more useful but much harder to implement.

As I can see page owner is able to save stacktrace where allocation happened,
this makes debugging mostly trivial without any counters. If it adds too much
overhead - just track random 1% of pages, should be enough for finding leak.

> As you know, page_frag_alloc() directly calls __alloc_pages_nodemask() function,
> so that makes too difficult to see memory usage in real time even though we have "/meminfo or /slabinfo.." information.
> If there was a way already to figure out the memory leakage from page_frag_cache in mainline, I agree your opinion
> but I think we don't have it now.
> 
> If those counters too much in my patch,
> I can say two values (pgfrag_alloc and pgfrag_free) are enough to guess what will happen
> and would remove pgfrag_alloc_calls and pgfrag_free_calls.
> 
> Thanks,
> Kyeongdon Kim
> 
> On 2017-09-01 i??i?? 6:12, Konstantin Khlebnikov wrote:
>> IMHO that's too much counters.
>> Per-node NR_FRAGMENT_PAGES should be enough for guessing what's going on.
>> Perf probes provides enough features for furhter debugging.
>>
>> On 01.09.2017 02:37, Kyeongdon Kim wrote:
>> > There was a memory leak problem when we did stressful test
>> > on Android device.
>> > The root cause of this was from page_frag_cache alloc
>> > and it was very hard to find out.
>> >
>> > We add to count the page frag allocation and free with function call.
>> > The gap between pgfrag_alloc and pgfrag_free is good to to calculate
>> > for the amount of page.
>> > The gap between pgfrag_alloc_calls and pgfrag_free_calls is for
>> > sub-indicator.
>> > They can see trends of memory usage during the test.
>> > Without it, it's difficult to check page frag usage so I believe we
>> > should add it.
>> >
>> > Signed-off-by: Kyeongdon Kim <kyeongdon.kim@lge.com>
>> > ---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
