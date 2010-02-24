Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4215F6B007B
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 21:28:47 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1O2SiIe012408
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Feb 2010 11:28:44 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 535B345DE6F
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 11:28:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E524845DE4D
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 11:28:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CA3AE18001
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 11:28:43 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EFE9A1DB8037
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 11:28:41 +0900 (JST)
Date: Wed, 24 Feb 2010 11:25:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: page fault oom improvement v2
Message-Id: <20100224112513.3d3e385b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002231818540.9613@chino.kir.corp.google.com>
References: <20100223120315.0da4d792.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223140218.0ab8ee29.nishimura@mxp.nes.nec.co.jp>
	<20100223152116.327a777e.nishimura@mxp.nes.nec.co.jp>
	<20100223152650.e8fc275d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223155543.796138fc.nishimura@mxp.nes.nec.co.jp>
	<20100223160714.72520b48.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002231443410.8693@chino.kir.corp.google.com>
	<20100224090836.ba86a4a6.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002231738070.3435@chino.kir.corp.google.com>
	<20100224104839.6547ab78.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002231818540.9613@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010 18:26:17 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 24 Feb 2010, KAMEZAWA Hiroyuki wrote:
> 
> > > > > This allows us to hijack the TIF_MEMDIE bit to detect when there is a 
> > > > > parallel pagefault oom killing when the oom killer hasn't necessarily been 
> > > > > invoked to kill a system-wide task (it's simply killing current, by 
> > > > > default, and giving it access to memory reserves).  Then, we can change 
> > > > > out_of_memory(), which also now handles memcg oom conditions, to always 
> > > > > scan the tasklist first (including for mempolicy and cpuset constrained 
> > > > > ooms), check for any candidates that have TIF_MEMDIE, and return 
> > > > > ERR_PTR(-1UL) if so.  That catches the parallel pagefault oom conditions 
> > > > > from needlessly killing memcg tasks.  panic_on_oom would only panic after 
> > > > > the tasklist scan has completed and returned != ERR_PTR(-1UL), meaning 
> > > > > pagefault ooms are exempt from that sysctl.
> > > > > 
> > > > Sorry, I see your concern but I'd like not to do clean-up and bug-fix at
> > > > the same time.  
> > > > 
> > > > I think clean up after fix is easy in this case.
> > > > 
> > > 
> > > If you develop on top of my oom killer rewrite, pagefault ooms already 
> > > attempt to kill current first and then defer back to killing another task 
> > > if current is unkillable.  
> > 
> > After my fix, page_fault_out_of_memory is never called. (because memcg doesn't
> > return needless failure.)
> > 
> 
> Of course it's called, it's called from the pagefault handler whenever we 
> return VM_FAULT_OOM.  Whenever that happens, we'd needlessly panic the 
> machine for panic_on_oom if we didn't do the tasklist scan and check for 
> eligible tasks with TIF_MEMDIE set because it prefers to kill current 
> first in pagefault conditions without consideration given to the sysctl.  
> pagefault_out_of_memory() has changed radically with my rewrite, so I'd 
> encourage you to develop on top of that where I've completely removed 
> mem_cgroup_oom_called() and memcg->last_oom_jiffies already because 
> they're nonsense.
> 
> My patches are available from 
> http://www.kernel.org/pub/linux/kernel/people/rientjes/oom-killer-rewrite
> 

I do by myself.

Bye.
-Kame

> Thanks.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
