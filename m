Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id F39BE6B004F
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 22:40:47 -0400 (EDT)
Received: by pzk3 with SMTP id 3so3061712pzk.22
        for <linux-mm@kvack.org>; Tue, 04 Aug 2009 19:40:49 -0700 (PDT)
Date: Wed, 5 Aug 2009 11:40:04 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 1/4] oom: move oom_adj to signal_struct
Message-Id: <20090805114004.459a7deb.minchan.kim@barrios-desktop>
In-Reply-To: <20090805110107.5B97.A69D9226@jp.fujitsu.com>
References: <20090804192514.6A40.A69D9226@jp.fujitsu.com>
	<20090805094534.35e64fbe.minchan.kim@barrios-desktop>
	<20090805110107.5B97.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed,  5 Aug 2009 11:29:34 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Hi
> 
> > Hi, Kosaki. 
> > 
> > I am so late to invole this thread. 
> > But let me have a question. 
> > 
> > What's advantage of placing oom_adj in singal rather than task ?
> > I mean task->oom_adj and task->signal->oom_adj ?
> > 
> > I am sorry if you already discussed it at last threads. 
> 
> Not sorry. that's very good question.
> 
> I'm trying to explain the detailed intention of commit 2ff05b2b4eac
> (move oom_adj to mm_struct).
> 
> In 2.6.30, OOM logic callflow is here.
> 
> __out_of_memory
> 	select_bad_process		for each task
> 		badness			calculate badness of one task
> 	oom_kill_process		search child
> 		oom_kill_task		kill target task and mm shared tasks with it
> 
> example, process-A have two thread, thread-A and thread-B and it 
> have very fat memory.
> And, each thread have following likes oom property.
> 
> 	thread-A: oom_adj = OOM_DISABLE, oom_score = 0
> 	thread-B: oom_adj = 0,           oom_score = very-high
> 
> Then, select_bad_process() select thread-B, but oom_kill_task refuse
> kill the task because thread-A have OOM_DISABLE.
> __out_of_memory() call select_bad_process() again. but select_bad_process()
> select the same task. It mean kernel fall in the livelock.
> 
> The fact is, select_bad_process() must select killable task. otherwise
> OOM logic go into livelock.
> 
> Is this enough explanation? thanks.
> 

Thanks for good explanation. :)

It resulted from patch of David which moved task_struct->oom_ajd 
to mm_struct. I understood it. 

It meant oom_adj was not per-process.

AFAIU, you want to make oom_adj per-process, again. 
And you selected the place with task->singal as per-process.

What I have a question is that why do you select task_struct->signal 
rather than task_struct like old?

What's benefit of using task_struct->signal ?


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
