Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 368A96B0078
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 05:19:24 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9T9JLEg009896
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 29 Oct 2009 18:19:21 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7226645DE51
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 18:19:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 386C445DE4F
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 18:19:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1FBAD1DB8041
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 18:19:21 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B75481DB803E
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 18:19:20 +0900 (JST)
Date: Thu, 29 Oct 2009 18:16:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] oom_kill: use rss value instead of vm size for badness
Message-Id: <20091029181650.979bf95c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0910290156560.16347@chino.kir.corp.google.com>
References: <20091028175846.49a1d29c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910280206430.7122@chino.kir.corp.google.com>
	<abbed627532b26d8d96990e2f95c02fc.squirrel@webmail-b.css.fujitsu.com>
	<20091029100042.973328d3.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910290125390.11476@chino.kir.corp.google.com>
	<20091029174632.8110976c.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910290156560.16347@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>, vedran.furac@gmail.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Oct 2009 02:01:49 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:
> > yes, then I wrote "as start point". There are many environments.
> 
> And this environment has a particularly bad result.
> yes, then I wrote "as start point". There are many environments.

In my understanding, 2nd, 3rd candidates are not important. If both of
total_vm and RSS catches the same process as 1st candidate, it's ok.
(i.e. If killed, oom situation will go away.)


> > ya, I'm now considering to drop file_rss from calculation.
> > 
> > some reasons.
> > 
> >   - file caches remaining in memory at OOM tend to have some trouble to remove it.
> >   - file caches tend to be shared.
> >   - if file caches are from shmem, we never be able to drop them if no swap/swapfull.
> > 
> > Maybe we'll have better result.
> > 
> 
> That sounds more appropriate.
> 
> I'm surprised you still don't see a value in using the peak VM and RSS 
> sizes, though, as part of your formula as it would indicate the proportion 
> of memory resident in RAM at the time of oom.
> 
I'll use swap_usage instead of peak VM size as bonus.

  anon_rss + swap_usage/2 ? or some.

My first purpose is not to kill not-guilty process at random.
If memory eater is killed, it's reasnoable.

In my consideration

  - "Killing a process because of OOM" is something bad, but not avoidable.

  - We don't need to do compliated/too-wise calculation for killing a process.
    "The worst one is memory-eater!" is easy to understand to users and admins.

  - We have oom_adj, now. User can customize it if he run _important_ memory eater.

  - But fork-bomb doesn't seem memory eater if we see each process.
    We need some cares.

  Then,
  - I'd like to drop file_rss.
  - I'd like to take swap_usage into acccount.
  - I'd like to remove cpu_time bonus. runtime bonus is much more important.
  - I'd like to remove penalty from children. To do that, fork-bomb detector
    is necessary.
  - nice bonus is bad. (We have oom_adj instead of this.) It should be
    if (task_nice(p) < 0)
	points /= 2;
    But we have "root user" bonus already. We can remove this line.

After above, much more simple selection, easy-to-understand,  will be done.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
