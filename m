Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 83DBA6B0003
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 06:16:38 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id z23so1126040iob.23
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 03:16:38 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h82-v6sor681551itb.145.2018.03.20.03.16.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 20 Mar 2018 03:16:37 -0700 (PDT)
Date: Tue, 20 Mar 2018 19:16:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: fix low-high watermark distance on small systems
Message-ID: <20180320101629.GA210031@rodete-desktop-imager.corp.google.com>
References: <1521110079-26870-1-git-send-email-vinmenon@codeaurora.org>
 <20180315143415.GA473@rodete-desktop-imager.corp.google.com>
 <d6dc8e61-8d3e-d628-2651-50db62dd7fa1@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <d6dc8e61-8d3e-d628-2651-50db62dd7fa1@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vinayak Menon <vinmenon@codeaurora.org>
Cc: hannes@cmpxchg.org, mgorman@techsingularity.net, linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, sfr@canb.auug.org.au, pasha.tatashin@oracle.com, penguin-kernel@I-love.SAKURA.ne.jp

On Fri, Mar 16, 2018 at 04:33:54PM +0530, Vinayak Menon wrote:
> 
> On 3/15/2018 8:04 PM, Minchan Kim wrote:
> > Hi Vinayak,
> 
> Thanks for your comments Minchan.
> >
> > On Thu, Mar 15, 2018 at 04:04:39PM +0530, Vinayak Menon wrote:
> >> It is observed that watermark_scale_factor when used to reduce
> >> thundering herds in direct reclaim, reduces the direct reclaims,
> >> but results in unnecessary reclaim due to kswapd running for long
> >> after being woken up. The tests are done with 4 GB of RAM and the
> >> tests done are multibuild and another which opens a set of apps
> >> sequentially on Android and repeating the sequence N times. The
> >> tests are done on 4.9 kernel.
> >>
> >> The issue is caused by watermark_scale_factor creating larger than
> >> required gap between low and high watermarks. The following results
> >> are with watermark_scale_factor of 120.
> >>
> >>                        wsf-120-default  wsf-120-reduced-low-high-gap
> >> workingset_activate    15120206         8319182
> >> pgpgin                 269795482        147928581
> >> allocstall             1406             1498
> >> pgsteal_kswapd         68676960         38105142
> >> slabs_scanned          94181738         49085755
> > "required gap" you mentiond is very dependent for your workload.
> > You had an experiment with wsf-120. It means user wanted to be more
> > aggressive for kswapd while your load is not enough to make meomry
> > consumption spike. Couldn't you decrease wfs?
> 
> I did try reducing the wsf for both multibuild and Android workloads. But that results in kswapd
> waking up late and thus latency issues due to higher direct reclaims. As I understand the problem, the
> wsf in its current form helps in tuning the kswapd wakeups (and note that I have not touched the
> wsf logic to calculate min-low gap), but the issue arises due to the depth to which kswapd scans the LRUs in a
> single run, causing thrashing, due to the higher low-high gap. From experiments, it looks like kswapd waking

wsf conducts kswapd sleep time as well as wakeup time.

"This factor controls the aggressiveness of kswapd. It defines the
amount of memory left in a node/system before kswapd is woken up and
how much memory needs to be free before kswapd goes back to sleep."

> up few more times and doing shorter steals is better than kswapd stealing more in a single run. The latter
> does not better direct reclaims and causes thrashing too.


That's the tradeoff of kswapd aggressiveness to avoid high rate
direct reclaim.

> 
> >
> > Don't get me wrong. I don't want you test all of wfs with varios
> > workload to prove your logic is better. What I want to say here is
> > it's heuristic so it couldn't be perfect for every workload so
> > if you change to non-linear, you could be better but others might be not.
> 
> Yes I understand your point. But since mmtests and Android tests showed similar results, I thought the
> heuristic may just work across workloads. I assume from Johannes's tests on 140GB machine (from the
> commit msg of the patch which introduced wsf) that the current low-high gap works well without thrashing
> on bigger machines. This made me assume that the behavior is non-linear. So the non-linear behavior will
> not make any difference to higher RAM machines as the low-high remains almost same as shown in the table
> below. But I understand your point, for a different workload on smaller machines, I am not sure the benefit I
> see would be observed, though that's the same problem with current wsf too.

True. That's why I don't want to make it complicate. Later, if someone complains
"linear is better for his several testing", are you happy to rollback to it? 

You might argue it's same problem now but at least as-is code is simple to
understand. 

> 
> >
> > In such context, current linear linear scale factor is simple enough
> > to understand. IMO, if we really want to enhance watermark, the low/high
> > wmark shold be adaptable according to memory spike. One of rough idea is
> > to change low/high wmark based on kswapd_[high|low]_wmark_hit_quickly.
> 
> That seems like a nice idea to me.  But considering the current case with and without this patch,
> the kswapd_low_wmark_hit quickly is actually less without the patch. But that comes at the cost of thrashing.
> Which then would mean we need to detect thrashing to adjust the watermark. We may get the thrashing data
> from workingset refaults, but I am not sure if we can take it as an input to adjust watermark since thrashing can
> be due to other reasons too. Maybe there are ways to make this adaptive, like using Johannes's memdelay feature
> to detect more time spent in direct reclaims and then raise the low watermark, and then use time spent in refault
> and stabilized direct reclaim time to bring down or stop raising the low watermark.
> But do we need that adaptive logic now if this (or other similar) patch just works across workloads for small machines ?
> What is your suggestion ?

Sorry for being grumpy.

Let's leave it as-is. Such a simple heuristic could be never optimal
for everyone. If we really need to fix it, I want to see better logic
to convince others.
