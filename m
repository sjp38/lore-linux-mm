Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 638F96B0003
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 06:52:54 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 62-v6so888907ply.4
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 03:52:54 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id t2-v6si1265013plo.130.2018.03.20.03.52.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 03:52:52 -0700 (PDT)
Subject: Re: [PATCH] mm: fix low-high watermark distance on small systems
References: <1521110079-26870-1-git-send-email-vinmenon@codeaurora.org>
 <20180315143415.GA473@rodete-desktop-imager.corp.google.com>
 <d6dc8e61-8d3e-d628-2651-50db62dd7fa1@codeaurora.org>
 <20180320101629.GA210031@rodete-desktop-imager.corp.google.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <c1b84fef-0ad7-7380-9a6b-7cbc65abd68f@codeaurora.org>
Date: Tue, 20 Mar 2018 16:22:36 +0530
MIME-Version: 1.0
In-Reply-To: <20180320101629.GA210031@rodete-desktop-imager.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: hannes@cmpxchg.org, mgorman@techsingularity.net, linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, sfr@canb.auug.org.au, pasha.tatashin@oracle.com, penguin-kernel@I-love.SAKURA.ne.jp, peter.enderborg@sony.com


On 3/20/2018 3:46 PM, Minchan Kim wrote:
> On Fri, Mar 16, 2018 at 04:33:54PM +0530, Vinayak Menon wrote:
>> On 3/15/2018 8:04 PM, Minchan Kim wrote:
>>> Hi Vinayak,
>> Thanks for your comments Minchan.
>>> On Thu, Mar 15, 2018 at 04:04:39PM +0530, Vinayak Menon wrote:
>>>> It is observed that watermark_scale_factor when used to reduce
>>>> thundering herds in direct reclaim, reduces the direct reclaims,
>>>> but results in unnecessary reclaim due to kswapd running for long
>>>> after being woken up. The tests are done with 4 GB of RAM and the
>>>> tests done are multibuild and another which opens a set of apps
>>>> sequentially on Android and repeating the sequence N times. The
>>>> tests are done on 4.9 kernel.
>>>>
>>>> The issue is caused by watermark_scale_factor creating larger than
>>>> required gap between low and high watermarks. The following results
>>>> are with watermark_scale_factor of 120.
>>>>
>>>>                        wsf-120-default  wsf-120-reduced-low-high-gap
>>>> workingset_activate    15120206         8319182
>>>> pgpgin                 269795482        147928581
>>>> allocstall             1406             1498
>>>> pgsteal_kswapd         68676960         38105142
>>>> slabs_scanned          94181738         49085755
>>> "required gap" you mentiond is very dependent for your workload.
>>> You had an experiment with wsf-120. It means user wanted to be more
>>> aggressive for kswapd while your load is not enough to make meomry
>>> consumption spike. Couldn't you decrease wfs?
>> I did try reducing the wsf for both multibuild and Android workloads. But that results in kswapd
>> waking up late and thus latency issues due to higher direct reclaims. As I understand the problem, the
>> wsf in its current form helps in tuning the kswapd wakeups (and note that I have not touched the
>> wsf logic to calculate min-low gap), but the issue arises due to the depth to which kswapd scans the LRUs in a
>> single run, causing thrashing, due to the higher low-high gap. From experiments, it looks like kswapd waking
> wsf conducts kswapd sleep time as well as wakeup time.
>
> "This factor controls the aggressiveness of kswapd. It defines the
> amount of memory left in a node/system before kswapd is woken up and
> how much memory needs to be free before kswapd goes back to sleep."

Yes I understand that. What I meant was the current wsf helps in tuning the wake up time properly, but causes the
kswapd to sleep late and thus causing thrashing.

>
>> up few more times and doing shorter steals is better than kswapd stealing more in a single run. The latter
>> does not better direct reclaims and causes thrashing too.
>
> That's the tradeoff of kswapd aggressiveness to avoid high rate
> direct reclaim.

We can call it trade off only if increasing the aggressiveness of kswapd reduces the direct reclaims ?
But as shown by the data I had shared, the aggressiveness does not improve direct reclaims. It is just causing
unnecessary reclaim. i.e. a much lower low-high gap gives the same benefit on direct reclaims with far less
reclaim.

>>> Don't get me wrong. I don't want you test all of wfs with varios
>>> workload to prove your logic is better. What I want to say here is
>>> it's heuristic so it couldn't be perfect for every workload so
>>> if you change to non-linear, you could be better but others might be not.
>> Yes I understand your point. But since mmtests and Android tests showed similar results, I thought the
>> heuristic may just work across workloads. I assume from Johannes's tests on 140GB machine (from the
>> commit msg of the patch which introduced wsf) that the current low-high gap works well without thrashing
>> on bigger machines. This made me assume that the behavior is non-linear. So the non-linear behavior will
>> not make any difference to higher RAM machines as the low-high remains almost same as shown in the table
>> below. But I understand your point, for a different workload on smaller machines, I am not sure the benefit I
>> see would be observed, though that's the same problem with current wsf too.
> True. That's why I don't want to make it complicate. Later, if someone complains
> "linear is better for his several testing", are you happy to rollback to it? 
>
> You might argue it's same problem now but at least as-is code is simple to
> understand. 

Yes I agree that there can be workloads on low RAM that may see a side effect.A  But since popular use case like those on Android
and also the mmtests shows the problem, and fixed by the patch, can we try to pick it and see if someone complains ? I see that
there were other reports of this https://lkml.org/lkml/2017/11/24/167 . Do you suggest a tunable approach taken by the patch
in that link ? So that varying use cases can be accommodated. I wanted to avoid a new tunable if some heuristic like the patch does
just works.

Thanks,
Vinayak
