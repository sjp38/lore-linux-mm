Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id E14278D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 00:59:02 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D8CA33EE0CB
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:58:59 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C010E45DE51
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:58:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C6DD45DE4D
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:58:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 90F7A1DB803E
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:58:59 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B6861DB802F
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 14:58:59 +0900 (JST)
Date: Wed, 9 Mar 2011 14:52:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in
 all_unreclaimable()
Message-Id: <20110309145239.ba31b415.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4D767D43.5020802@gmail.com>
References: <20110307135831.9e0d7eaa.akpm@linux-foundation.org>
	<20110308094438.1ba05ed2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110308120615.7EB9.A69D9226@jp.fujitsu.com>
	<4D767D43.5020802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: avagin@gmail.com
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 08 Mar 2011 22:02:27 +0300
"avagin@gmail.com" <avagin@gmail.com> wrote:

> On 03/08/2011 06:06 AM, KOSAKI Motohiro wrote:
> >>>> Hmm.. Although it solves the problem, I think it's not a good idea that
> >>>> depends on false alram and give up the retry.
> >>>
> >>> Any alternative proposals?  We should get the livelock fixed if possible..
> >>
> >> I agree with Minchan and can't think this is a real fix....
> >> Andrey, I'm now trying your fix and it seems your fix for oom-killer,
> >> 'skip-zombie-process' works enough good for my environ.
> >>
> >> What is your enviroment ? number of cpus ? architecture ? size of memory ?
> >
> > me too. 'skip-zombie-process V1' work fine. and I didn't seen this patch
> > improve oom situation.
> >
> > And, The test program is purely fork bomb. Our oom-killer is not silver
> > bullet for fork bomb from very long time ago. That said, oom-killer send
> > SIGKILL and start to kill the victim process. But, it doesn't prevent
> > to be created new memory hogging tasks. Therefore we have no gurantee
> > to win process exiting and creating race.
> 
> I think a live-lock is a bug, even if it's provoked by fork bomds.
> 

I tried to write fork-bomb-detector in oom-kill layer but I think
it should be co-operative with do_fork(), now.
IOW, some fork() should return -ENOMEM under OOM condition.

I'd like to try some but if you have some idea, please do.


> And now I want say some words about zone->all_unreclaimable. I think 
> this flag is "conservative". It is set when situation is bad and it's 
> unset when situation get better. If we have a small number of 
> reclaimable  pages, the situation is still bad. What do you mean, when 
> say that kernel is alive? If we have one reclaimable page, is the kernel 
> alive? Yes, it can work, it will generate many page faults and do 
> something, but anyone say that it is more dead than alive.
> 
> Try to look at it from my point of view. The patch will be correct and 
> the kernel will be more alive.
> 
> Excuse me, If I'm mistaken...
> 

Mayne something more casual interface than oom-kill should be provided.
I wonder I can add memory-reclaim-priority to memory cgroup and
allow control of page fault latency for applicaton...
Maybe "soft_limit" for memcg, it's implemented now, works to some extent.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
