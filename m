Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3115F6B0003
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 07:29:14 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id a79-v6so1347741itc.3
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 04:29:14 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b186-v6sor632505ith.105.2018.03.20.04.29.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 04:29:12 -0700 (PDT)
Date: Tue, 20 Mar 2018 20:29:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: fix low-high watermark distance on small systems
Message-ID: <20180320112905.GB210031@rodete-desktop-imager.corp.google.com>
References: <1521110079-26870-1-git-send-email-vinmenon@codeaurora.org>
 <20180315143415.GA473@rodete-desktop-imager.corp.google.com>
 <d6dc8e61-8d3e-d628-2651-50db62dd7fa1@codeaurora.org>
 <20180320101629.GA210031@rodete-desktop-imager.corp.google.com>
 <c1b84fef-0ad7-7380-9a6b-7cbc65abd68f@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c1b84fef-0ad7-7380-9a6b-7cbc65abd68f@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: hannes@cmpxchg.org, mgorman@techsingularity.net, linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, sfr@canb.auug.org.au, pasha.tatashin@oracle.com, penguin-kernel@I-love.SAKURA.ne.jp, peter.enderborg@sony.com

On Tue, Mar 20, 2018 at 04:22:36PM +0530, Vinayak Menon wrote:
> >
> >> up few more times and doing shorter steals is better than kswapd stealing more in a single run. The latter
> >> does not better direct reclaims and causes thrashing too.
> >
> > That's the tradeoff of kswapd aggressiveness to avoid high rate
> > direct reclaim.
> 
> We can call it trade off only if increasing the aggressiveness of kswapd reduces the direct reclaims ?
> But as shown by the data I had shared, the aggressiveness does not improve direct reclaims. It is just causing
> unnecessary reclaim. i.e. a much lower low-high gap gives the same benefit on direct reclaims with far less
> reclaim.

Said again, it depends on workload. I can make simple test to break it easily.

> 
> >>> Don't get me wrong. I don't want you test all of wfs with varios
> >>> workload to prove your logic is better. What I want to say here is
> >>> it's heuristic so it couldn't be perfect for every workload so
> >>> if you change to non-linear, you could be better but others might be not.
> >> Yes I understand your point. But since mmtests and Android tests showed similar results, I thought the
> >> heuristic may just work across workloads. I assume from Johannes's tests on 140GB machine (from the
> >> commit msg of the patch which introduced wsf) that the current low-high gap works well without thrashing
> >> on bigger machines. This made me assume that the behavior is non-linear. So the non-linear behavior will
> >> not make any difference to higher RAM machines as the low-high remains almost same as shown in the table
> >> below. But I understand your point, for a different workload on smaller machines, I am not sure the benefit I
> >> see would be observed, though that's the same problem with current wsf too.
> > True. That's why I don't want to make it complicate. Later, if someone complains
> > "linear is better for his several testing", are you happy to rollback to it? 
> >
> > You might argue it's same problem now but at least as-is code is simple to
> > understand. 
> 
> Yes I agree that there can be workloads on low RAM that may see a side effect.  But since popular use case like those on Android

My concern is not side effect but putting more heuristic without proving
it's generally better.

I don't think repeated app launching on android doesn't reflect real user
scenario. Anyone don't do that in real life except some guys want to show
benchmark result in youtube.
About mmtests, what kinds of tests did you perform? So what's the result?
If you reduced thrashing, how much the test result is improved?
Every tests are improved? Need not vmstat but result from the benchmark.
Such wide testing would make more conviction.

> and also the mmtests shows the problem, and fixed by the patch, can we try to pick it and see if someone complains ? I see that
> there were other reports of this https://lkml.org/lkml/2017/11/24/167 . Do you suggest a tunable approach taken by the patch
> in that link ? So that varying use cases can be accommodated. I wanted to avoid a new tunable if some heuristic like the patch does
> just works.

Actually, I don't want to touch it unless we have more nice feedback
algorithm.

Anyway, it's just my opinion. I did best effort to explain. I will
defer to maintainer.

Thanks.
