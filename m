Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B98E86B005C
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 02:05:19 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7565Igw017232
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 5 Aug 2009 15:05:19 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F00645DE54
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 15:05:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F8BB45DE4E
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 15:05:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 506E01DB8044
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 15:05:18 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EAD761DB803F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 15:05:17 +0900 (JST)
Date: Wed, 5 Aug 2009 15:03:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] oom: move oom_adj to signal_struct
Message-Id: <20090805150323.2624a68f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090805145516.b2129f81.minchan.kim@barrios-desktop>
References: <20090805110107.5B97.A69D9226@jp.fujitsu.com>
	<20090805114004.459a7deb.minchan.kim@barrios-desktop>
	<20090805114650.5BA1.A69D9226@jp.fujitsu.com>
	<20090805145516.b2129f81.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 5 Aug 2009 14:55:16 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed,  5 Aug 2009 11:51:31 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > > On Wed,  5 Aug 2009 11:29:34 +0900 (JST)
> > > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > 
> > > > Hi
> > > > 
> > > > > Hi, Kosaki. 
> > > > > 
> > > > > I am so late to invole this thread. 
> > > > > But let me have a question. 
> > > > > 
> > > > > What's advantage of placing oom_adj in singal rather than task ?
> > > > > I mean task->oom_adj and task->signal->oom_adj ?
> > > > > 
> > > > > I am sorry if you already discussed it at last threads. 
> > > > 
> > > > Not sorry. that's very good question.
> > > > 
> > > > I'm trying to explain the detailed intention of commit 2ff05b2b4eac
> > > > (move oom_adj to mm_struct).
> > > > 
> > > > In 2.6.30, OOM logic callflow is here.
> > > > 
> > > > __out_of_memory
> > > > 	select_bad_process		for each task
> > > > 		badness			calculate badness of one task
> > > > 	oom_kill_process		search child
> > > > 		oom_kill_task		kill target task and mm shared tasks with it
> > > > 
> > > > example, process-A have two thread, thread-A and thread-B and it 
> > > > have very fat memory.
> > > > And, each thread have following likes oom property.
> > > > 
> > > > 	thread-A: oom_adj = OOM_DISABLE, oom_score = 0
> > > > 	thread-B: oom_adj = 0,           oom_score = very-high
> > > > 
> > > > Then, select_bad_process() select thread-B, but oom_kill_task refuse
> > > > kill the task because thread-A have OOM_DISABLE.
> > > > __out_of_memory() call select_bad_process() again. but select_bad_process()
> > > > select the same task. It mean kernel fall in the livelock.
> > > > 
> > > > The fact is, select_bad_process() must select killable task. otherwise
> > > > OOM logic go into livelock.
> > > > 
> > > > Is this enough explanation? thanks.
> > > > 
> 
> The problem resulted from David patch.
> It can solve live lock problem but make a new problem like vfork problem. 
> I think both can be solved by different approach. 
> 
> It's just RFC. 
> 
> If some process is selected by OOM killer but it have a child of OOM immune,
> We just decrease point of process. It can affect selection of bad process. 
> After some trial, at last bad score is drastically low and another process is 
> selected by OOM killer. So I think Live lock don't happen. 
> 
> New variable adding in task struct is rather high cost. 
> But i think we can union it with oomkilladj 
> since oomkilladj is used to present just -17 ~ 15. 
> 
> What do you think about this approach ?
> 
keeping this in "task" struct is troublesome.
It may not livelock but near-to-livelock state, in bad case.

After applying Kosaki's , oom_kill will use
"for_each_process()" instead of "do_each_thread", I think it's a way to go.

But, yes, your "scale_down" idea itself is interesitng.
Then, hmm, merging two of yours ?

Thanks,
-Kame



> ----
> 
> This is based on 2.6.30 which is kernel before applying David Patch. 
> 
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index b4c38bc..6e195f7 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1150,6 +1150,11 @@ struct task_struct {
>          */
>         unsigned char fpu_counter;
>         s8 oomkilladj; /* OOM kill score adjustment (bit shift). */
> +       /*
> +        * If OOM kill happens at one process repeately, 
> +        * oom_sacle_down will be increased to prevent OOM live lock 
> +        */
> +       unsigned int oom_scale_down;
>  #ifdef CONFIG_BLK_DEV_IO_TRACE
>         unsigned int btrace_seq;
>  #endif
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index a7b2460..3592786 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -159,6 +159,11 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
>                         points >>= -(p->oomkilladj);
>         }
>  
> +       /*
> +        * adjust the score by number of OOM kill retrial
> +        */
> +       points >>= p->oom_scale_down;
> +
>  #ifdef DEBUG
>         printk(KERN_DEBUG "OOMkill: task %d (%s) got %lu points\n",
>         p->pid, p->comm, points);
> @@ -367,8 +372,10 @@ static int oom_kill_task(struct task_struct *p)
>          * Don't kill the process if any threads are set to OOM_DISABLE
>          */
>         do_each_thread(g, q) {
> -               if (q->mm == mm && q->oomkilladj == OOM_DISABLE)
> +               if (q->mm == mm && q->oomkilladj == OOM_DISABLE) {
> +                       p->oom_scale_down++;
>                         return 1;
> +               }
>         } while_each_thread(g, q);
>  
>         __oom_kill_task(p, 1);
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
