Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6843E6B0083
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 16:40:12 -0500 (EST)
Received: from spaceape7.eur.corp.google.com (spaceape7.eur.corp.google.com [172.28.16.141])
	by smtp-out.google.com with ESMTP id nAPLe6To010262
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 21:40:07 GMT
Received: from pzk10 (pzk10.prod.google.com [10.243.19.138])
	by spaceape7.eur.corp.google.com with ESMTP id nAPLe2p1003312
	for <linux-mm@kvack.org>; Wed, 25 Nov 2009 13:40:03 -0800
Received: by pzk10 with SMTP id 10so89979pzk.19
        for <linux-mm@kvack.org>; Wed, 25 Nov 2009 13:40:02 -0800 (PST)
Date: Wed, 25 Nov 2009 13:39:59 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
In-Reply-To: <20091125124433.GB27615@random.random>
Message-ID: <alpine.DEB.2.00.0911251334020.8191@chino.kir.corp.google.com>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com> <abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com> <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com> <20091125124433.GB27615@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, vedran.furac@gmail.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Nov 2009, Andrea Arcangeli wrote:

> You're focusing on the noise and not looking at the only thing that
> matters.
> 
> The noise level with rss went down to 50000, it doesn't matter the
> order of what's below 50000. Only thing it matters is the _delta_
> between "noise-level innocent apps" and "exploit".
> 
> The delta is clearly increase from 708945-max(noise) to
> 707878-max(noise) which translates to a increase of precision from
> 513250 to 665677, which shows how much more rss is making the
> detection more accurate (i.e. the distance between exploit and first
> innocent app). The lower level the noise level starts, the less likely
> the innocent apps are killed.
> 

That's not surprising since the amount of physical RAM is the constraining 
factor.

> There's simply no way to get to perfection, some innocent apps will
> always have high total_vm or rss levels, but this at least removes
> lots of innocent apps from the equation. The fact X isn't less
> innocent than before is because its rss is quite big, and this is not
> an error, luckily much smaller than the hog itself. Surely there are
> ways to force X to load huge bitmaps into its address space too
> (regardless of total_vm or rss) but again no perfection, just better
> with rss even in this testcase.
> 

We use the oom killer as a mechanism to enforce memory containment policy, 
we are much more interested in the oom killing priority than the oom 
killer's own heuristics to determine the ideal task to kill.  Those 
heuristics can't possibly represent the priorities for all possible 
workloads, so we require input from the user via /proc/pid/oom_adj to 
adjust that heuristic.  That has traditionally always used total_vm as a 
baseline which is a much more static value and can be quantified within a 
reasonable range by experimental data when it would not be defined as 
rogue.  By changing the baseline to rss, we lose much of that control 
since its more dynamic and dependent on the current state of the machine 
at the time of the oom which can be predicted with less accuracy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
