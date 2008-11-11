Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAB7SnoW027271
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 11 Nov 2008 16:28:49 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F238E45DD7A
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 16:28:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C4E5745DD77
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 16:28:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C908E08002
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 16:28:48 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 33154E08005
	for <linux-mm@kvack.org>; Tue, 11 Nov 2008 16:28:48 +0900 (JST)
Date: Tue, 11 Nov 2008 16:28:12 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH]Per-cgroup OOM handler
Message-Id: <20081111162812.492218fc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <604427e00811102042x202906ecq2a10eb5e404e2ec9@mail.gmail.com>
References: <604427e00811031340k56634773g6e260d79e6cb51e7@mail.gmail.com>
	<604427e00811031419k2e990061kdb03f4b715b51fb9@mail.gmail.com>
	<20081106143438.5557b87c.kamezawa.hiroyu@jp.fujitsu.com>
	<604427e00811102042x202906ecq2a10eb5e404e2ec9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ying Han <yinghan@google.com>
Cc: linux-mm@kvack.org, Rohit Seth <rohitseth@google.com>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 10 Nov 2008 20:42:23 -0800
Ying Han <yinghan@google.com> wrote:

> Thank you for your comments.
> On Wed, Nov 5, 2008 at 9:34 PM, KAMEZAWA Hiroyuki <
> kamezawa.hiroyu@jp.fujitsu.com> wrote:
>     Here is how we do the one-tick-wait in cgroup_should_oom() in oom_kill.c
>     >-------if (!ret) {
>     >------->-------/* If we're not going to OOM, we should sleep for a
>     >------->------- * bit to give userspace a chance to respond before we
>     >------->------- * go back and try to reclaim again */
>     >------->-------schedule_timeout_uninterruptible(1);
>     >-------}
>    and it works well in-house so far as i mentioned earlier. what's
> important here is not "sleeping for one tick", the idea here is to
> reschedule the ooming thread so the oom handler can make action ( like
> adding memory node to the cpuset) and the subsequent page allocator in
> get_page_from_freelist() can use it.
> 
Can't we avoid this kind of magical one-tick wait ?

> 
> > (Before OOM, the system tend to wait in congestion_wait() or some.)
> 
>    I am not sure how the call to congestion_wait() relevant to the
> "one-tick-wait"? We are simply just trying to reschedule the ooming task,
> that the oom handler has waken up to have chance doing something.
> 
if lucky.


> >
> >
> > OOM-handler shoule be in another cpuset or mlocked in this case
> 
> The oom-handler is in the same cgroup as the ooming task. That is why it's
> called per-cgroup oom-handler. However, there's probably a livelock if the
> userspace oom handler is the one that triggers the oom and detach/reattaches
> without ever freeing or adding memory. For this case, either we can detect
> in the kernel by doing something like if(current == pid) or just leave the
> problem up to userspace( the oom handler shouldn't detach itself after
> getting the ooming notification, it is considered to be a user bug? ).
> 
Hmm, from discussion of mem_notify handler in Feb/March of this year,
oom-hanlder cannot works well if memory is near to OOM, in general.
Then, mlockall was recomemded to handler.
(and it must not do file access.)

I wonder creating small cpuset (and isolated node) for oom-handler may be
another help.


> >
> > I'm wondering
> >  - freeeze-all-threads-in-group-at-oom
> >  - free emergency memory to page allocator which was pooled at cgroup
> > creation
> >    rather than 1-tick wait
> >
> > BTW, it seems this patch allows task detach/attach always. it's safe(and
> > sane) ?
> 
>    yes, we allows task detach/attach. So far we don't see any race condition
> except the livelock
> i mentioned above. Any particular scenario can think of now? thanks
> 
I don't find it ;)
BTW, shouldn't we disable preempt(or irq) before taking spinlocks ?

> > +static int cgroup_should_oom(void)
> > +{
> > +     int ret = 1; /* OOM by default */
> > +     struct oom_cgroup *cs;
> > +
> > +     task_lock(current);
> > +     cs = oom_cgroup_from_task(current);
> > +

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
