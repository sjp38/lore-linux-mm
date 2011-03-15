Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 281C48D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 20:01:48 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2829D3EE0BC
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:01:45 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 119B245DE53
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:01:45 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EF9D945DE56
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:01:44 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id E3435E38005
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:01:44 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B15AFE08001
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 09:01:44 +0900 (JST)
Date: Wed, 16 Mar 2011 08:55:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] fork bomb killer
Message-Id: <20110316085518.13351576.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110315104226.GB10165@shutemov.name>
References: <20110315185242.9533e65b.kamezawa.hiroyu@jp.fujitsu.com>
	<20110315104226.GB10165@shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, rientjes@google.com, Oleg Nesterov <oleg@redhat.com>, Andrey Vagin <avagin@openvz.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Tue, 15 Mar 2011 12:42:26 +0200
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Tue, Mar 15, 2011 at 06:52:42PM +0900, KAMEZAWA Hiroyuki wrote:
> > While testing Andrey's case, I confirmed I need to reboot the system by
> > power off when I ran a fork-bomb. The speed of fork() is much faster
> > than some smart killing as pkill(1) and oom-killer cannot reach the speed.
> > 
> > I wonder it's better to have a fork-bomb killer even if it's a just heuristic
> > method. This is a one. This one works fine with Andrey's case and I don't need
> > to reboot more. And I confirmed this can kill a case like
> > 
> > 	while True:
> > 		os.fork()
> > 
> > BTW, does usual man see fork-bomb in a production system ?
> > I saw only once which was caused be a shell script.
> > 
> > ==
> > A fork bomb killer.
> > 
> > When fork-bomb runs, the system exhausts memory and we need to
> > reboot the system, in usual. The oom-killer or admin's killall
> > is slower than fork-bomb if system memory is exhausted.
> > 
> > So, fork-bomb-killer is appreciated even if it's a just heuristic.
> > 
> > This patch implements a heuristic for fork-bomb. The logic finds
> > a fork bomb which
> >  - has spawned 10+ tasks recently (10 min).
> >  - aggregate score of bomb is larger than the baddest task's badness.
> > 
> > When fork-bomb found,
> >  - new fork in the session under where fork bomb is will return -ENOMEM
> >    for the next 30secs.
> 
> -EAGAIN is more appropiate, I think. At least -EAGAIN returns if
> RLIMIT_NPROC resource limit was encountered.
> 
> Will the fork-bomb-killer work, if a fork-bomb calls setsid() before
> fork()?
> 

This function just kills "young" children and cannot guarantee the core
of fork-bomb will be killed. By limiting fork() in the fork-bomb session
by -ENOMEM,  I hope careless fork-bomb will die. Then, I selected -ENOMEM
rather than -EAGAIN. By -ENOMEM, session leader (and user) can see there
was memory shortage.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
