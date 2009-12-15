Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6AB216B0062
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 00:19:54 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF5JpnY000905
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 15 Dec 2009 14:19:52 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CAA645DE58
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:19:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C99045DE52
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:19:51 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 22466E1800A
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:19:51 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A4AB11DB8043
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 14:19:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask v4.2
In-Reply-To: <alpine.DEB.2.00.0912142046070.436@chino.kir.corp.google.com>
References: <20091215133546.6872fc4f.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0912142046070.436@chino.kir.corp.google.com>
Message-Id: <20091215135902.CDD6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 15 Dec 2009 14:19:49 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 15 Dec 2009, KAMEZAWA Hiroyuki wrote:
> 
> > > I would agree only if the oom killer used total_vm as a the default, it is 
> > > long-standing and allows for the aforementioned capability that you lose 
> > > with rss.  I have no problem with the added sysctl to use rss as the 
> > > baseline when enabled.
> > > 
> > I'll prepare a patch for adds
> > 
> >   sysctl_oom_kill_based_on_rss (default=0)
> > 
> > ok ?
> > 
> 
> I have no strong feelings either for or against that, I guess users who 
> want to always kill the biggest memory hogger even when single page 
> __GFP_WAIT allocations fail could use it.  I'm not sure it would get much 
> use, though.
> 
> I think we should methodically work out an oom killer badness rewrite that 
> won't compound the problem by adding more and more userspace knobs.  In 
> other words, we should slow down, construct a list of goals that we want 
> to achieve, and then see what type of solution we can create.
> 
> A few requirements that I have:

Um, good analysis! really.

>
>  - we must be able to define when a task is a memory hogger; this is
>    currently done by /proc/pid/oom_adj relying on the overall total_vm
>    size of the task as a baseline.  Most users should have a good sense
>    of when their task is using more memory than expected and killing a
>    memory leaker should always be the optimal oom killer result.  A better 
>    set of units other than a shift on total_vm would be helpful, though.

nit: What's mean "Most users"? desktop user(one of most majority users)
don't have any expection of memory usage.

but, if admin have memory expection, they should be able to tune
optimal oom result.

I think you pointed right thing.


>  - we must prefer tasks that run on a cpuset or mempolicy's nodes if the 
>    oom condition is constrained by that cpuset or mempolicy and its not a
>    system-wide issue.

agreed. (who disagree it?)


>  - we must be able to polarize the badness heuristic to always select a
>    particular task is if its very low priority or disable oom killing for
>    a task if its must-run.

Probably I haven't catch your point. What's mean "polarize"? Can you
please describe more?


> The proposal may be to remove /proc/pid/oom_adj completely since I know 
> both you and KOSAKI-san dislike it, but we'd need an alternative which 
> keeps the above functionality intact.

Yes, To provide alternative way is must.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
