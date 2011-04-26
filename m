Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 23072900001
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 03:50:54 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id E89093EE0C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:50:48 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C8B1D45DE58
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:50:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B28E045DE54
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:50:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 91687EF8008
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:50:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AD4EE08003
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 16:50:48 +0900 (JST)
Date: Tue, 26 Apr 2011 16:43:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/7] memcg background reclaim , yet another one.
Message-Id: <20110426164341.fb6c80a4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <BANLkTi=aoRhgu3SOKZ8OLRqTew67ciquFg@mail.gmail.com>
References: <20110425182529.c7c37bb4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110425191437.d881ee68.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTikYeV8JpMHd1Lvh7kRXXpLyQEOw4w@mail.gmail.com>
	<20110426103859.05eb7a35.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTi=aoRhgu3SOKZ8OLRqTew67ciquFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

On Tue, 26 Apr 2011 00:19:46 -0700
Ying Han <yinghan@google.com> wrote:

> On Mon, Apr 25, 2011 at 6:38 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Mon, 25 Apr 2011 15:21:21 -0700
> > Ying Han <yinghan@google.com> wrote:

> >> Thank you for putting time on implementing the patch. I think it is
> >> definitely a good idea to have the two alternatives on the table since
> >> people has asked the questions. Before going down to the track, i have
> >> thought about the two approaches and also discussed with Greg and Hugh
> >> (cc-ed), A i would like to clarify some of the pros and cons on both
> >> approaches. A In general, I think the workqueue is not the right answer
> >> for this purpose.
> >>
> >> The thread-pool model
> >> Pros:
> >> 1. there is no isolation between memcg background reclaim, since the
> >> memcg threads are shared. That isolation including all the resources
> >> that the per-memcg background reclaim will need to access, like cpu
> >> time. One thing we are missing for the shared worker model is the
> >> individual cpu scheduling ability. We need the ability to isolate and
> >> count the resource assumption per memcg, and including how much
> >> cputime and where to run the per-memcg kswapd thread.
> >>
> >
> > IIUC, new threads for workqueue will be created if necessary in automatic.
> >
> I read your patches today, but i might missed some details while I was
> reading it. I will read them through tomorrow.
> 

Thank you.

> The question I was wondering here is
> 1. how to do cpu cgroup limit per-memcg including the kswapd time.

I'd like to add some limitation based on elapsed time. For example,
only allow to run 10ms within 1sec. It's a background job should be
limited. Or, simply adds static delay per memcg at queue_delayed_work().
Then, the user can limit scan/sec. But what I wonder now is what is the
good interface....msec/sec ? scan/sec, free/sec ? etc...


> 2. how to do numa awareness cpu scheduling if i want to do cpumask on
> the memcg-kswapd close to the numa node where all the pages of the
> memcg allocated.
> 
> I guess the second one should have been covered. If not, it shouldn't
> be a big effort to fix that. And any suggestions on the first one.
> 

Interesting. If we use WQ_CPU_INTENSIVE + queue_work_on() instead
of WQ_UNBOUND, we can control which cpu to do jobs.

"The default cpu" to run wmark-reclaim can by calculated by
css_id(&mem->css) % num_online_cpus() or some round robin at
memcg creation. Anyway, we'll need to use WQ_CPU_INTENSIVE.
It may give us good result than WQ_UNBOUND...

Adding an interface for limiting cpu is...hmm. per memcg ? or
as the generic memcg param ? It will a memcg parameter not
a threads's.


> >
> >> 4. the kswapd threads are created and destroyed dynamically. are we
> >> talking about allocating 8k of stack for kswapd when we are under
> >> memory pressure? In the other case, all the memory are preallocated.
> >>
> >
> > I think workqueue is there for avoiding 'making kthread dynamically'.
> > We can save much codes.
> 
> So right now, the workqueue is configured as unbounded. which means
> the worse case we might create
> the same number of workers as the number of memcgs. ( if each memcg
> takes long time to do the reclaim). So this might not be a problem,
> but I would like to confirm.
> 
>From documenation, max_active unbound workqueue (default) is
==
Currently, for a bound wq, the maximum limit for @max_active is 512
and the default value used when 0 is specified is 256.  For an unbound
wq, the limit is higher of 512 and 4 * num_possible_cpus().  These
values are chosen sufficiently high such that they are not the
limiting factor while providing protection in runaway cases.
==
512 ?  If wmark-reclaim burns cpu (and get rechedule), new kthread will
be created.


> >
> >> 5. the workqueue is scary and might introduce issues sooner or later.
> >> Also, why we think the background reclaim fits into the workqueue
> >> model, and be more specific, how that share the same logic of other
> >> parts of the system using workqueue.
> >>
> >
> > Ok, with using workqueue.
> >
> > A 1. The number of threads can be changed dynamically with regard to system
> > A  A  workload without adding any codes. workqueue is for this kind of
> > A  A  background jobs. gcwq has a hooks to scheduler and it works well.
> > A  A  With per-memcg thread model, we'll never be able to do such.
> >
> > A 2. We can avoid having unncessary threads.
> > A  A  If it sleeps most of time, why we need to keep it ? No, it's unnecessary.
> > A  A  It should be on-demand. freezer() etc need to stop all threads and
> > A  A  thousands of sleeping threads will be harmful.
> > A  A  You can see how 'ps -elf' gets slow when the number of threads increases.
> 
> In general, i am not strongly against the workqueue but trying to
> understand the procs and cons between the two approaches. The first
> one is definitely simpler and more straight-forward, and I was
> suggesting to start with something simple and improve it later if we
> see problems. But I will read your path through tomorrow and also
> willing to see comments from others.
> 
> Thank you for the efforts!
> 

you, too. 

Anyway, get_scan_count() seems to be a big problem and I'll cut out it
as independent patch.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
