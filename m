Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id BC5B96B01AC
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 14:58:33 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@redhat.com>
Subject: Re: [PATCH] oom: Make coredump interruptible
In-Reply-To: Oleg Nesterov's message of  Wednesday, 2 June 2010 19:53:25 +0200 <20100602175325.GA16474@redhat.com>
References: <20100601093951.2430.A69D9226@jp.fujitsu.com>
	<20100601201843.GA20732@redhat.com>
	<20100602221805.F524.A69D9226@jp.fujitsu.com>
	<20100602154210.GA9622@redhat.com>
	<20100602172956.5A3E34A491@magilla.sf.frob.com>
	<20100602175325.GA16474@redhat.com>
Message-Id: <20100602185812.4B5894A549@magilla.sf.frob.com>
Date: Wed,  2 Jun 2010 11:58:12 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

> Because it is per-thread.

I see.

> when select_bad_process() finds the task P to kill it can participate
> in the core dump (sleep in exit_mm), but we should somehow inform the
> thread which actually dumps the core: P->mm->core_state->dumper.

Perhaps it should simply do that: if you would choose P to oom-kill, and
P->mm->core_state!=NULL, then choose P->mm->core_state->dumper instead.

> Well, we can use TIF_MEMDIE if we chose the right thread, I think.
> But perhaps mm->flags |= MMF_OOM is better, it can have other user.
> I dunno.

This is all the quick hack before get around to just making core dumping
fully-interruptible, no?  So we should go with whatever is the simplest
change now.

Perhaps this belongs in another thread as you suggested.  But I wonder what
we might get just from s/TASK_UNINTERRUPTIBLE/TASK_KILLABLE/ in exit_mm.


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
