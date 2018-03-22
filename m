Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A3B56B0007
	for <linux-mm@kvack.org>; Thu, 22 Mar 2018 09:43:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j12so4580216pff.18
        for <linux-mm@kvack.org>; Thu, 22 Mar 2018 06:43:57 -0700 (PDT)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id m6si4436055pgp.831.2018.03.22.06.43.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Mar 2018 06:43:55 -0700 (PDT)
Subject: Re: [PATCH] mm: fix low-high watermark distance on small systems
References: <1521110079-26870-1-git-send-email-vinmenon@codeaurora.org>
 <20180315143415.GA473@rodete-desktop-imager.corp.google.com>
 <d6dc8e61-8d3e-d628-2651-50db62dd7fa1@codeaurora.org>
 <20180320101629.GA210031@rodete-desktop-imager.corp.google.com>
 <c1b84fef-0ad7-7380-9a6b-7cbc65abd68f@codeaurora.org>
 <20180320112905.GB210031@rodete-desktop-imager.corp.google.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <a33b81d4-8291-7970-9c20-831bba1c93ae@codeaurora.org>
Date: Thu, 22 Mar 2018 19:13:48 +0530
MIME-Version: 1.0
In-Reply-To: <20180320112905.GB210031@rodete-desktop-imager.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: hannes@cmpxchg.org, mgorman@techsingularity.net, linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, sfr@canb.auug.org.au, pasha.tatashin@oracle.com, penguin-kernel@I-love.SAKURA.ne.jp, peter.enderborg@sony.com

On 3/20/2018 4:59 PM, Minchan Kim wrote:
> On Tue, Mar 20, 2018 at 04:22:36PM +0530, Vinayak Menon wrote:
>>>> up few more times and doing shorter steals is better than kswapd stealing more in a single run. The latter
>>>> does not better direct reclaims and causes thrashing too.
>>> That's the tradeoff of kswapd aggressiveness to avoid high rate
>>> direct reclaim.
>> We can call it trade off only if increasing the aggressiveness of kswapd reduces the direct reclaims ?
>> But as shown by the data I had shared, the aggressiveness does not improve direct reclaims. It is just causing
>> unnecessary reclaim. i.e. a much lower low-high gap gives the same benefit on direct reclaims with far less
>> reclaim.
> Said again, it depends on workload. I can make simple test to break it easily.
>
>>

> I don't think repeated app launching on android doesn't reflect real user
> scenario. Anyone don't do that in real life except some guys want to show
> benchmark result in youtube.

Agree that user won't open apps continuously in sequence like the test does. But I believe it is very similar to what
a user would do with the device. i.e. open an app, do something, switch to another app..then come
back to previous app. The test tries to emulate the same.

> About mmtests, what kinds of tests did you perform? So what's the result?
> If you reduced thrashing, how much the test result is improved?
> Every tests are improved? Need not vmstat but result from the benchmark.
> Such wide testing would make more conviction.

I had performed the multibuild test of mmtests (3G RAM). Results below.

A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  wsf-defaultA A A A A A A A A  wsf-this-patch
multibuild time (secs)A A A A A A  7338A A A A A A A A A A A A A A A  A  A A  7186
workingset_refaultA A A A A A A A A A A  1228216A A A A A A A A A A A A A  974074A  (-20%)
workingset_activateA A A A A A A A A  292110A A A  A A A  A A A  A A A  181789A  (-37%)
pgpginA A A A A A A A A A A A A A A A A A A A A A  A A A A A A A A A A  11307694A A A A A A A A A A A  8678200 (-23%)
allocstallA A A  A A A  A A A  A A A  A A A  A A A A A A A A A A  98A A A  A A A  A A A  A A A  A A A A A A A A  103


>> and also the mmtests shows the problem, and fixed by the patch, can we try to pick it and see if someone complains ? I see that
>> there were other reports of this https://lkml.org/lkml/2017/11/24/167 . Do you suggest a tunable approach taken by the patch
>> in that link ? So that varying use cases can be accommodated. I wanted to avoid a new tunable if some heuristic like the patch does
>> just works.
> Actually, I don't want to touch it unless we have more nice feedback
> algorithm.
>
> Anyway, it's just my opinion. I did best effort to explain. I will
> defer to maintainer.
>
> Thanks.
