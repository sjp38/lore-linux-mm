Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D4B2B6B004F
	for <linux-mm@kvack.org>; Tue,  4 Aug 2009 22:29:38 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n752TaoN014180
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 5 Aug 2009 11:29:37 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9280E2AEA82
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 11:29:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7013D1EF082
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 11:29:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FB88E18014
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 11:29:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id CB89FE1800C
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 11:29:35 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] oom: move oom_adj to signal_struct
In-Reply-To: <20090805094534.35e64fbe.minchan.kim@barrios-desktop>
References: <20090804192514.6A40.A69D9226@jp.fujitsu.com> <20090805094534.35e64fbe.minchan.kim@barrios-desktop>
Message-Id: <20090805110107.5B97.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed,  5 Aug 2009 11:29:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi

> Hi, Kosaki. 
> 
> I am so late to invole this thread. 
> But let me have a question. 
> 
> What's advantage of placing oom_adj in singal rather than task ?
> I mean task->oom_adj and task->signal->oom_adj ?
> 
> I am sorry if you already discussed it at last threads. 

Not sorry. that's very good question.

I'm trying to explain the detailed intention of commit 2ff05b2b4eac
(move oom_adj to mm_struct).

In 2.6.30, OOM logic callflow is here.

__out_of_memory
	select_bad_process		for each task
		badness			calculate badness of one task
	oom_kill_process		search child
		oom_kill_task		kill target task and mm shared tasks with it

example, process-A have two thread, thread-A and thread-B and it 
have very fat memory.
And, each thread have following likes oom property.

	thread-A: oom_adj = OOM_DISABLE, oom_score = 0
	thread-B: oom_adj = 0,           oom_score = very-high

Then, select_bad_process() select thread-B, but oom_kill_task refuse
kill the task because thread-A have OOM_DISABLE.
__out_of_memory() call select_bad_process() again. but select_bad_process()
select the same task. It mean kernel fall in the livelock.

The fact is, select_bad_process() must select killable task. otherwise
OOM logic go into livelock.

Is this enough explanation? thanks.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
