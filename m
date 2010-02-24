Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9EBC76B0093
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 20:52:12 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1O1qA4d029669
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Feb 2010 10:52:10 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E352E2E6A2E
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 10:52:09 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E07EE45DE50
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 10:52:08 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DA5FC1DB804B
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 10:52:07 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 939491DB8046
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 10:52:07 +0900 (JST)
Date: Wed, 24 Feb 2010 10:48:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: page fault oom improvement v2
Message-Id: <20100224104839.6547ab78.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002231738070.3435@chino.kir.corp.google.com>
References: <20100223120315.0da4d792.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223140218.0ab8ee29.nishimura@mxp.nes.nec.co.jp>
	<20100223152116.327a777e.nishimura@mxp.nes.nec.co.jp>
	<20100223152650.e8fc275d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223155543.796138fc.nishimura@mxp.nes.nec.co.jp>
	<20100223160714.72520b48.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002231443410.8693@chino.kir.corp.google.com>
	<20100224090836.ba86a4a6.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002231738070.3435@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010 17:42:33 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> > > 
> > > This allows us to hijack the TIF_MEMDIE bit to detect when there is a 
> > > parallel pagefault oom killing when the oom killer hasn't necessarily been 
> > > invoked to kill a system-wide task (it's simply killing current, by 
> > > default, and giving it access to memory reserves).  Then, we can change 
> > > out_of_memory(), which also now handles memcg oom conditions, to always 
> > > scan the tasklist first (including for mempolicy and cpuset constrained 
> > > ooms), check for any candidates that have TIF_MEMDIE, and return 
> > > ERR_PTR(-1UL) if so.  That catches the parallel pagefault oom conditions 
> > > from needlessly killing memcg tasks.  panic_on_oom would only panic after 
> > > the tasklist scan has completed and returned != ERR_PTR(-1UL), meaning 
> > > pagefault ooms are exempt from that sysctl.
> > > 
> > Sorry, I see your concern but I'd like not to do clean-up and bug-fix at
> > the same time.  
> > 
> > I think clean up after fix is easy in this case.
> > 
> 
> If you develop on top of my oom killer rewrite, pagefault ooms already 
> attempt to kill current first and then defer back to killing another task 
> if current is unkillable.  

After my fix, page_fault_out_of_memory is never called. (because memcg doesn't
return needless failure.)

Then, that's not point in this thread.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
