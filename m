Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BA4976B004D
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 05:01:59 -0400 (EDT)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id n9T91rc3028159
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 02:01:54 -0700
Received: from pxi13 (pxi13.prod.google.com [10.243.27.13])
	by spaceape23.eur.corp.google.com with ESMTP id n9T91cJ6005569
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 02:01:50 -0700
Received: by pxi13 with SMTP id 13so1117892pxi.28
        for <linux-mm@kvack.org>; Thu, 29 Oct 2009 02:01:50 -0700 (PDT)
Date: Thu, 29 Oct 2009 02:01:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
In-Reply-To: <20091029174632.8110976c.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0910290156560.16347@chino.kir.corp.google.com>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com> <abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com> <20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com> <20091029174632.8110976c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, vedran.furac@gmail.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Oct 2009, KAMEZAWA Hiroyuki wrote:

> > This appears to actually prefer X more than total_vm in Vedran's test 
> > case.  He cited http://pastebin.com/f3f9674a0 in 
> > http://marc.info/?l=linux-kernel&m=125678557002888.
> > 
> > There are 12 ooms in this log, which has /proc/sys/vm/oom_dump_tasks 
> > enabled.  It shows the difference between the top total_vm candidates vs. 
> > the top rss candidates.
> > 
> > total_vm
> > 708945 test
> > 195695 krunner
> > 168881 plasma-desktop
> > 130567 ktorrent
> > 127081 knotify4
> > 125881 icedove-bin
> > 123036 akregator
> > 118641 kded4
> > 
> > rss
> > 707878 test
> > 42201 Xorg
> > 13300 icedove-bin
> > 10209 ktorrent
> > 9277 akregator
> > 8878 plasma-desktop
> > 7546 krunner
> > 4532 mysqld
> > 
> > This patch would pick the memory hogging task, "test", first everytime 
> > just like the current implementation does.  It would then prefer Xorg, 
> > icedove-bin, and ktorrent next as a starting point.
> > 
> > Admittedly, there are other heuristics that the oom killer uses to create 
> > a badness score.  But since this patch is only changing the baseline from 
> > mm->total_vm to get_mm_rss(mm), its behavior in this test case do not 
> > match the patch description.
> > 
> yes, then I wrote "as start point". There are many environments.

And this environment has a particularly bad result.

> But I'm not sure why ntpd can be the first candidate...
> The scores you shown doesn't include children's score, right ?
> 

Right, it's just the get_mm_rss(mm) for each thread shown in the oom dump, 
the same value you've used as the new baseline.  The actual badness scores 
could easily be calculated by cat'ing /proc/*/oom_score prior to oom, but 
this data was meant to illustrate the preference given the rss compared to 
total_vm in a heuristic sense.

> I believe I'll have to remove "adding child's score to parents".
> I'm now considering how to implement fork-bomb detector for removing it.
> 

Agreed, I'm looking forward to your proposal.

> ya, I'm now considering to drop file_rss from calculation.
> 
> some reasons.
> 
>   - file caches remaining in memory at OOM tend to have some trouble to remove it.
>   - file caches tend to be shared.
>   - if file caches are from shmem, we never be able to drop them if no swap/swapfull.
> 
> Maybe we'll have better result.
> 

That sounds more appropriate.

I'm surprised you still don't see a value in using the peak VM and RSS 
sizes, though, as part of your formula as it would indicate the proportion 
of memory resident in RAM at the time of oom.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
