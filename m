Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9E2968D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 06:42:33 -0400 (EDT)
Date: Tue, 15 Mar 2011 12:42:26 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC][PATCH] fork bomb killer
Message-ID: <20110315104226.GB10165@shutemov.name>
References: <20110315185242.9533e65b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110315185242.9533e65b.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, rientjes@google.com, Oleg Nesterov <oleg@redhat.com>, Andrey Vagin <avagin@openvz.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Tue, Mar 15, 2011 at 06:52:42PM +0900, KAMEZAWA Hiroyuki wrote:
> While testing Andrey's case, I confirmed I need to reboot the system by
> power off when I ran a fork-bomb. The speed of fork() is much faster
> than some smart killing as pkill(1) and oom-killer cannot reach the speed.
> 
> I wonder it's better to have a fork-bomb killer even if it's a just heuristic
> method. This is a one. This one works fine with Andrey's case and I don't need
> to reboot more. And I confirmed this can kill a case like
> 
> 	while True:
> 		os.fork()
> 
> BTW, does usual man see fork-bomb in a production system ?
> I saw only once which was caused be a shell script.
> 
> ==
> A fork bomb killer.
> 
> When fork-bomb runs, the system exhausts memory and we need to
> reboot the system, in usual. The oom-killer or admin's killall
> is slower than fork-bomb if system memory is exhausted.
> 
> So, fork-bomb-killer is appreciated even if it's a just heuristic.
> 
> This patch implements a heuristic for fork-bomb. The logic finds
> a fork bomb which
>  - has spawned 10+ tasks recently (10 min).
>  - aggregate score of bomb is larger than the baddest task's badness.
> 
> When fork-bomb found,
>  - new fork in the session under where fork bomb is will return -ENOMEM
>    for the next 30secs.

-EAGAIN is more appropiate, I think. At least -EAGAIN returns if
RLIMIT_NPROC resource limit was encountered.

Will the fork-bomb-killer work, if a fork-bomb calls setsid() before
fork()?

>  - all tasks of fork-bomb will be killed.
> 
> Note:
>  - I wonder I shoud add a sysctl knob for this.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
