Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6E8BE6B007B
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 03:31:44 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1F8Vf8n032153
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 15 Feb 2010 17:31:41 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8929245DE55
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:31:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 51A3F45DE51
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:31:40 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 363041DB8042
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:31:40 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CB9BF1DB8043
	for <linux-mm@kvack.org>; Mon, 15 Feb 2010 17:31:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch 7/7 -mm] oom: remove unnecessary code and cleanup
In-Reply-To: <alpine.DEB.2.00.1002111619370.13384@chino.kir.corp.google.com>
References: <20100212091237.adb94384.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1002111619370.13384@chino.kir.corp.google.com>
Message-Id: <20100215173046.72A4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 15 Feb 2010 17:31:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Fri, 12 Feb 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > Remove the redundancy in __oom_kill_task() since:
> > > 
> > >  - init can never be passed to this function: it will never be PF_EXITING
> > >    or selectable from select_bad_process(), and
> > > 
> > >  - it will never be passed a task from oom_kill_task() without an ->mm
> > >    and we're unconcerned about detachment from exiting tasks, there's no
> > >    reason to protect them against SIGKILL or access to memory reserves.
> > > 
> > > Also moves the kernel log message to a higher level since the verbosity
> > > is not always emitted here; we need not print an error message if an
> > > exiting task is given a longer timeslice.
> > > 
> > > Signed-off-by: David Rientjes <rientjes@google.com>
> > 
> > If you say "never", it's better to add BUG_ON() rather than 
> > if (!p->mm)...
> > 
> 
> As the description says, oom_kill_task() never passes __oom_kill_task() a 
> task, p, where !p->mm, but it doesn't imply that p cannot detach its ->mm 
> before __oom_kill_task() gets a chance to run.  The point is that we don't 
> really care about giving it access to memory reserves anymore since it's 
> exiting and won't be allocating anything.  Warning about that scenario is 
> unnecessary and would simply spam the kernel log, a recall to the oom 
> killer would no longer select this task in case the oom condition persists 
> anyway.

I agree this description is correct and this code is unnecessary.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


> 
> > But yes, this patch seesm to remove unnecessary codes.
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> 
> Thanks!
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
