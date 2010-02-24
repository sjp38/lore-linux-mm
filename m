Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D26A46B008C
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 19:12:09 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1O0C6rY020034
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Feb 2010 09:12:06 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2973845DE53
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 09:12:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D8F7B45DE4D
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 09:12:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B4CD71DB8043
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 09:12:05 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 568CC1DB803B
	for <linux-mm@kvack.org>; Wed, 24 Feb 2010 09:12:05 +0900 (JST)
Date: Wed, 24 Feb 2010 09:08:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: page fault oom improvement v2
Message-Id: <20100224090836.ba86a4a6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1002231443410.8693@chino.kir.corp.google.com>
References: <20100223120315.0da4d792.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223140218.0ab8ee29.nishimura@mxp.nes.nec.co.jp>
	<20100223152116.327a777e.nishimura@mxp.nes.nec.co.jp>
	<20100223152650.e8fc275d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100223155543.796138fc.nishimura@mxp.nes.nec.co.jp>
	<20100223160714.72520b48.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1002231443410.8693@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Feb 2010 14:49:12 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Tue, 23 Feb 2010, KAMEZAWA Hiroyuki wrote:
> 
> > Ouch, I missed to add memcontrol.h to quilt's reflesh set..
> > This is updated one. Anyway, I'd like to wait for the next mmotm.
> > We already have several changes. 
> > 
> 
> I think it would be better to just remove mem_cgroup_out_of_memory() and 
> make it go through out_of_memory() by specifying a non-NULL pointer to a 
> struct mem_cgroup.  We don't need the duplication in code that these two 
> functions have and then we can begin to have some consistency with how to 
> deal with panic_on_oom.
> 
> It would be much better to prefer killing current in pagefault oom 
> conditions, as the final patch in my oom killer rewrite does, if it is 
> killable.  If not, we scan the tasklist and find another suitable 
> candidate.  If current is bound to a memcg, we pass that to 
> select_bad_process() so that we only kill other tasks from the same 
> cgroup.
Adding new argument to out_of_memory ?

> 
> This allows us to hijack the TIF_MEMDIE bit to detect when there is a 
> parallel pagefault oom killing when the oom killer hasn't necessarily been 
> invoked to kill a system-wide task (it's simply killing current, by 
> default, and giving it access to memory reserves).  Then, we can change 
> out_of_memory(), which also now handles memcg oom conditions, to always 
> scan the tasklist first (including for mempolicy and cpuset constrained 
> ooms), check for any candidates that have TIF_MEMDIE, and return 
> ERR_PTR(-1UL) if so.  That catches the parallel pagefault oom conditions 
> from needlessly killing memcg tasks.  panic_on_oom would only panic after 
> the tasklist scan has completed and returned != ERR_PTR(-1UL), meaning 
> pagefault ooms are exempt from that sysctl.
> 
Sorry, I see your concern but I'd like not to do clean-up and bug-fix at
the same time.  

I think clean up after fix is easy in this case.


> Anyway, do you think it would be possible to rebase on mmotm with my oom 
> killer rewrite patches?  
> They're at 
> http://www.kernel.org/pub/linux/kernel/people/rientjes/oom-killer-rewrite
> 

I can wait until your patch are merged if necessary. But it seems there will
not be much confliction.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
