Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2923C8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 19:57:14 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 10E503EE0C0
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 08:57:08 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D14F145DE92
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 08:57:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B269545DE95
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 08:57:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A39ADE08006
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 08:57:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 652A8E08005
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 08:57:07 +0900 (JST)
Date: Tue, 29 Mar 2011 08:50:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] forkbomb killer
Message-Id: <20110329085033.6e20868e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110328162137.GA2904@barrios-desktop>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110324105222.GA2625@barrios-desktop>
	<20110325090411.56c5e5b2.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=f3gu7-8uNiT4qz6s=BOhto5s=7g@mail.gmail.com>
	<20110325115453.82a9736d.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim3fFe3VzvaWRwzaCT6aRd-yeyfiQ@mail.gmail.com>
	<20110326023452.GA8140@google.com>
	<AANLkTi=ng9vwoMJ=tseWwTsXMf9XZkMKUexcpEmQ45M_@mail.gmail.com>
	<20110328162137.GA2904@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>

On Tue, 29 Mar 2011 01:21:37 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Sat, Mar 26, 2011 at 05:48:45PM +0900, Hiroyuki Kamezawa wrote:
> > 2011/3/26 Michel Lespinasse <walken@google.com>:
> > > On Fri, Mar 25, 2011 at 01:05:50PM +0900, Minchan Kim wrote:
> > >> Okay. Each approach has a pros and cons and at least, now anyone
> > >> doesn't provide any method and comments but I agree it is needed(ex,
> > >> careless and lazy admin could need it strongly). Let us wait a little
> > >> bit more. Maybe google guys or redhat/suse guys would have a opinion.
> > >
> > > I haven't heard of fork bombs being an issue for us (and it's not been
> > > for me on my desktop, either).
> > >
> > > Also, I want to point out that there is a classical userspace solution
> > > for this, as implemented by killall5 for example. One can do
> > > kill(-1, SIGSTOP) to stop all processes that they can send
> > > signals to (except for init and itself). Target processes
> > > can never catch or ignore the SIGSTOP. This stops the fork bomb
> > > from causing further damage. Then, one can look at the process
> > > tree and do whatever is appropriate - including killing by uid,
> > > by cgroup or whatever policies one wants to implement in userspace.
> > > Finally, the remaining processes can be restarted using SIGCONT.
> > >
> > 
> > Can that solution work even under OOM situation without new login/commands ?
> > Please show us your solution, how to avoid Andrey's Bomb  with your way.
> > Then, we can add Documentation, at least. Or you can show us your tool.
> > 
> > Maybe it is....
> > - running as a daemon. (because it has to lock its work memory before OOM.)
> > - mlockall its own memory to work under OOM.
> > - It can show process tree of users/admin or do all in automatic way
> > with user's policy.
> > - tell us which process is guilty.
> > - wakes up automatically when OOM happens.....IOW, OOM should have some notifier
> >   to userland.
> > - never allocate any memory at running. (maybe it can't use libc.)
> > - never be blocked by any locks, for example, some other task's mmap_sem.
> >   One of typical mistakes of admins at OOM is typing 'ps' to see what
> > happens.....
> > - Can be used even with GUI system, which can't show console.
> 
> Hi Kame,
> 
> I am worried about run-time cost. 
> Should we care of mistake of users for robustness of OS?
> Mostly right but we can't handle all mistakes of user so we need admin.
> For exampe, what happens if admin execute "rm -rf /"?
> For avoiding it, we get a solution "backup" about critical data.
> 

Then, my patch is configurable and has control knobs....never invasive for
people who don't want it. And simple and very low cost. It will have
no visible performance/resource usage impact for usual guys.



> In the same manner, if the system is very critical of forkbomb, 
> admin should consider it using memcg, virtualization, ulimit and so on.
> If he don't want it, he should become a hard worker who have to 
> cross over other building to reboot it. Although he is a diligent man, 
> Reboot isn't good. So I suggest following patch which is just RFC. 
> For making formal patch, I have to add more comment and modify sysrq.txt.
> 

For me, sysrq is of-no-use as I explained.

> From 51bec44086a6b6c0e56ea978a2eb47e995236b47 Mon Sep 17 00:00:00 2001
> From: Minchan Kim <minchan.kim@gmail.com>
> Date: Tue, 29 Mar 2011 00:52:20 +0900
> Subject: [PATCH] [RFC] Prevent livelock by forkbomb
> 
> Recently, We discussed how to prevent forkbomb.
> The thing is a trade-off between cost VS effect.
> 
> Forkbomb is a _race_ case which happes by someone's mistake
> so if we have to pay cost in fast path(ex, fork, exec, exit),
> It's a not good.
> 
> Now, sysrq + I kills all processes. When I tested it, I still
> need rebooting to work my system really well(ex, x start)
> although console works. I don't know why we need such sysrq(kill
> all processes and then what we can do?)
> 
> So I decide to change sysrq + I to meet our goal which prevent
> forkbomb. The rationale is following as.
> 
> Forkbomb means somethings makes repeately tasks in a short time so
> system don't have a free page then it become almost livelock state.
> This patch uses the characteristc of forkbomb.
> 
> When you push sysrq + I, it kills recent created tasks.
> (In this version, 1 minutes). Maybe all processes included
> forkbomb tasks are killed. If you can't get normal state of system
> after you push sysrq + I, you can try one more. It can kill futher
> recent tasks(ex, 2 minutes).
> 
> You can continue to do it until your system becomes normal state.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  drivers/tty/sysrq.c   |   45 ++++++++++++++++++++++++++++++++++++++++++---
>  include/linux/sched.h |    6 ++++++
>  2 files changed, 48 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/tty/sysrq.c b/drivers/tty/sysrq.c
> index 81f1395..6fb7e18 100644
> --- a/drivers/tty/sysrq.c
> +++ b/drivers/tty/sysrq.c
> @@ -329,6 +329,45 @@ static void send_sig_all(int sig)
>  	}
>  }
>  
> +static void send_sig_recent(int sig)
> +{
> +	struct task_struct *p;
> +	unsigned long task_jiffies, last_jiffies = 0;
> +	bool kill = false;
> +
> +retry:

you need tasklist lock for scanning reverse.

> +	for_each_process_reverse(p) {
> +		if (p->mm && !is_global_init(p) && !fatal_signal_pending(p)) {
> +			/* recent created task */
> +			last_jiffies = timeval_to_jiffies(p->real_start_time);
> +			force_sig(sig, p);
> +			break;

why break ? you need to kill all youngers. And what is the relationship with below ?


> +		}
> +	}
> +
> +	for_each_process_reverse(p) {
> +		if (p->mm && !is_global_init(p)) {
> +			task_jiffies = timeval_to_jiffies(p->real_start_time);
> +			/*
> +			 * Kill all processes which are created recenlty
> +			 * (ex, 1 minutes)
> +			 */
> +			if (task_jiffies > (last_jiffies - 60 * HZ)) {
> +				force_sig(sig, p);
> +				kill = true;
> +			}
> +			else
> +				break;
> +		}
> +	}
> +
> +	/*
> +	 * If we can't kill anything, restart with next group.
> +	 */
> +	if (!kill)
> +		goto retry;
> +}

This is not useful under OOM situation, we cannot use 'jiffies' to find younger tasks
because "memory reclaim-> livelock" can take some amount of minutes very easily.
So, I used other metrics. I think you do the same mistake I made before,
this doesn't work.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
