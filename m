Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 42ED96B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 02:30:44 -0400 (EDT)
Received: by pzk28 with SMTP id 28so3540175pzk.11
        for <linux-mm@kvack.org>; Tue, 04 Aug 2009 23:30:42 -0700 (PDT)
Date: Wed, 5 Aug 2009 15:29:56 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/4] oom: move oom_adj to signal_struct
Message-Id: <20090805152956.faf52a5a.minchan.kim@barrios-desktop>
In-Reply-To: <20090805150017.5BB9.A69D9226@jp.fujitsu.com>
References: <20090805114650.5BA1.A69D9226@jp.fujitsu.com>
	<20090805145516.b2129f81.minchan.kim@barrios-desktop>
	<20090805150017.5BB9.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed,  5 Aug 2009 15:04:48 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > On Wed,  5 Aug 2009 11:51:31 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > > On Wed,  5 Aug 2009 11:29:34 +0900 (JST)
> > > > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > > > 
> > > > > Hi
> > > > > 
> > > > > > Hi, Kosaki. 
> > > > > > 
> > > > > > I am so late to invole this thread. 
> > > > > > But let me have a question. 
> > > > > > 
> > > > > > What's advantage of placing oom_adj in singal rather than task ?
> > > > > > I mean task->oom_adj and task->signal->oom_adj ?
> > > > > > 
> > > > > > I am sorry if you already discussed it at last threads. 
> > > > > 
> > > > > Not sorry. that's very good question.
> > > > > 
> > > > > I'm trying to explain the detailed intention of commit 2ff05b2b4eac
> > > > > (move oom_adj to mm_struct).
> > > > > 
> > > > > In 2.6.30, OOM logic callflow is here.
> > > > > 
> > > > > __out_of_memory
> > > > > 	select_bad_process		for each task
> > > > > 		badness			calculate badness of one task
> > > > > 	oom_kill_process		search child
> > > > > 		oom_kill_task		kill target task and mm shared tasks with it
> > > > > 
> > > > > example, process-A have two thread, thread-A and thread-B and it 
> > > > > have very fat memory.
> > > > > And, each thread have following likes oom property.
> > > > > 
> > > > > 	thread-A: oom_adj = OOM_DISABLE, oom_score = 0
> > > > > 	thread-B: oom_adj = 0,           oom_score = very-high
> > > > > 
> > > > > Then, select_bad_process() select thread-B, but oom_kill_task refuse
> > > > > kill the task because thread-A have OOM_DISABLE.
> > > > > __out_of_memory() call select_bad_process() again. but select_bad_process()
> > > > > select the same task. It mean kernel fall in the livelock.
> > > > > 
> > > > > The fact is, select_bad_process() must select killable task. otherwise
> > > > > OOM logic go into livelock.
> > > > > 
> > > > > Is this enough explanation? thanks.
> > > > > 
> > 
> > The problem resulted from David patch.
> > It can solve live lock problem but make a new problem like vfork problem. 
> > I think both can be solved by different approach. 
> > 
> > It's just RFC. 
> > 
> > If some process is selected by OOM killer but it have a child of OOM immune,
> > We just decrease point of process. It can affect selection of bad process. 
> > After some trial, at last bad score is drastically low and another process is 
> > selected by OOM killer. So I think Live lock don't happen. 
> > 
> > New variable adding in task struct is rather high cost. 
> > But i think we can union it with oomkilladj 
> > since oomkilladj is used to present just -17 ~ 15. 
> > 
> > What do you think about this approach ?
> 
> I can ack this. but please re-initialize oom_scale_down at fork and
> exec time.
> currently oom_scale_down makes too big affect.


Thanks for carefult review. 
In fact, I didn't care of it 
since it just is RFC for making sure my idea. :)

> and, May I ask which you hate my approach? 
> 

Not at all. I never hate your approach. 
This problem resulted form David's original patch.
I thought if we will fix live lock with different approach, we can remove much pain.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
