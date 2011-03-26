Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 20CD68D0040
	for <linux-mm@kvack.org>; Sat, 26 Mar 2011 04:48:50 -0400 (EDT)
Received: by iyf13 with SMTP id 13so2633875iyf.14
        for <linux-mm@kvack.org>; Sat, 26 Mar 2011 01:48:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110326023452.GA8140@google.com>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110324105222.GA2625@barrios-desktop>
	<20110325090411.56c5e5b2.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=f3gu7-8uNiT4qz6s=BOhto5s=7g@mail.gmail.com>
	<20110325115453.82a9736d.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim3fFe3VzvaWRwzaCT6aRd-yeyfiQ@mail.gmail.com>
	<20110326023452.GA8140@google.com>
Date: Sat, 26 Mar 2011 17:48:45 +0900
Message-ID: <AANLkTi=ng9vwoMJ=tseWwTsXMf9XZkMKUexcpEmQ45M_@mail.gmail.com>
Subject: Re: [PATCH 0/4] forkbomb killer
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

2011/3/26 Michel Lespinasse <walken@google.com>:
> On Fri, Mar 25, 2011 at 01:05:50PM +0900, Minchan Kim wrote:
>> Okay. Each approach has a pros and cons and at least, now anyone
>> doesn't provide any method and comments but I agree it is needed(ex,
>> careless and lazy admin could need it strongly). Let us wait a little
>> bit more. Maybe google guys or redhat/suse guys would have a opinion.
>
> I haven't heard of fork bombs being an issue for us (and it's not been
> for me on my desktop, either).
>
> Also, I want to point out that there is a classical userspace solution
> for this, as implemented by killall5 for example. One can do
> kill(-1, SIGSTOP) to stop all processes that they can send
> signals to (except for init and itself). Target processes
> can never catch or ignore the SIGSTOP. This stops the fork bomb
> from causing further damage. Then, one can look at the process
> tree and do whatever is appropriate - including killing by uid,
> by cgroup or whatever policies one wants to implement in userspace.
> Finally, the remaining processes can be restarted using SIGCONT.
>

Can that solution work even under OOM situation without new login/commands ?
Please show us your solution, how to avoid Andrey's Bomb  with your way.
Then, we can add Documentation, at least. Or you can show us your tool.

Maybe it is....
- running as a daemon. (because it has to lock its work memory before OOM.)
- mlockall its own memory to work under OOM.
- It can show process tree of users/admin or do all in automatic way
with user's policy.
- tell us which process is guilty.
- wakes up automatically when OOM happens.....IOW, OOM should have some notifier
  to userland.
- never allocate any memory at running. (maybe it can't use libc.)
- never be blocked by any locks, for example, some other task's mmap_sem.
  One of typical mistakes of admins at OOM is typing 'ps' to see what
happens.....
- Can be used even with GUI system, which can't show console.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
