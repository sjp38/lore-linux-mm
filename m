Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EE3DB6B01AC
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 11:55:28 -0400 (EDT)
Date: Sun, 13 Jun 2010 17:53:54 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] oom: Make coredump interruptible
Message-ID: <20100613155354.GA8428@redhat.com>
References: <20100604112721.GA12582@redhat.com> <20100609195309.GA6899@redhat.com> <20100613175547.616F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100613175547.616F.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Roland McGrath <roland@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On 06/13, KOSAKI Motohiro wrote:
>
> > On 06/04, Oleg Nesterov wrote:
> > >
> > Perhaps something like below makes sense for now.
>
> Probably, this works. at least I don't find any problems.
> But umm... Do you mean we can't implement per-process oom flags?

Sorry, can't understand what you mean.

> example,
> 	1) back to implement signal->oom_victim
> 	   because We are using SIGKILL for OOM and struct signal
> 	   naturally represent signal target.

Yes, but if this process participates in the coredump, we should find
the right thread, or mark mm or mm->core_state.

In fact, I was never sure that oom-kill should kill the single process.
Perhaps it should kill all tasks using the same ->mm instead. But this
is another story.

> 	2) mm->nr_oom_killed_task
> 	   just avoid simple flag. instead counting number of tasks of
> 	   oom-killed.

again, can't understand.

> I think both avoid your explained problem. Am I missing something?

I guess that I am missing something ;) Please clarify?

> But, again, I have no objection to your patch. because I really hope to
> fix coredump vs oom issue.

Yes, I think this is important. And if we keep the PF_EXITING check in
select_bad_process(), it should be fixed so that at least the coredump
can't fool it. And the "p != current" is obviously not right too.

I'll try to do something next week, the patches should be simple.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
