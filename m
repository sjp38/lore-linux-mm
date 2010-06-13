Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5D0C76B01B5
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 07:24:57 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5DBOrkJ021727
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 13 Jun 2010 20:24:53 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1342B45DE50
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EA3CE45DE4D
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CE4E71DB8045
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 844DF1DB8042
	for <linux-mm@kvack.org>; Sun, 13 Jun 2010 20:24:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] oom: Make coredump interruptible
In-Reply-To: <20100609195309.GA6899@redhat.com>
References: <20100604112721.GA12582@redhat.com> <20100609195309.GA6899@redhat.com>
Message-Id: <20100613175547.616F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Date: Sun, 13 Jun 2010 20:24:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Roland McGrath <roland@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Sorry for the delay.

> On 06/04, Oleg Nesterov wrote:
> >
> > On 06/04, KOSAKI Motohiro wrote:
> > >
> > > In multi threaded OOM case, we have two problematic routine, coredump
> > > and vmscan. Roland's idea can only solve the former.
> > >
> > > But I also interest vmscan quickly exit if OOM received.
> >
> > Yes, agreed. See another email from me, MMF_ flags looks "obviously
> > useful" to me.
> 
> Well. But somehow we forgot about the !coredumping case... Suppose
> that select_bad_process() chooses the process P to kill and we have
> other processes (not sub-threads) which share the same ->mm.

Ah, yes. I think you are correct.


> In that case I am not sure we should blindly set MMF_OOMKILL. Suppose
> that we kill P and after that the "out-of-memory" condition goes away.
> But its ->mm still has MMF_OOMKILL set, and it is used. Who/when will
> clear this flag?
> 
> Perhaps something like below makes sense for now.

Probably, this works. at least I don't find any problems.
But umm... Do you mean we can't implement per-process oom flags?

example,
	1) back to implement signal->oom_victim
	   because We are using SIGKILL for OOM and struct signal
	   naturally represent signal target.
	2) mm->nr_oom_killed_task
	   just avoid simple flag. instead counting number of tasks of
	   oom-killed.

I think both avoid your explained problem. Am I missing something?

But, again, I have no objection to your patch. because I really hope to
fix coredump vs oom issue.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
