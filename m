Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 101516B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 21:19:41 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA42JduG019852
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 4 Nov 2009 11:19:39 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F196145DE52
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 11:19:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D39C145DE4F
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 11:19:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 17B4BE08001
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 11:19:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A4B511DB803A
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 11:19:37 +0900 (JST)
Date: Wed, 4 Nov 2009 11:17:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Memory overcommit
Message-Id: <20091104111703.b46ae72b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0911031752180.1187@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org>
	<4AE792B8.5020806@gmail.com>
	<alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com>
	<20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com>
	<20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910272311001.15462@chino.kir.corp.google.com>
	<20091028152015.3d383cd6.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910290136000.11476@chino.kir.corp.google.com>
	<4AE97861.1070902@gmail.com>
	<alpine.DEB.2.00.0910291248480.2276@chino.kir.corp.google.com>
	<20091030084836.5428e085.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0910300200170.18076@chino.kir.corp.google.com>
	<20091030183638.1125c987.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911031240470.29695@chino.kir.corp.google.com>
	<20091104095021.5532e913.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.0911031752180.1187@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Nov 2009 17:58:04 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Wed, 4 Nov 2009, KAMEZAWA Hiroyuki wrote:
> 
> > > That's a different point.  Today, we can influence the badness score of 
> > > any user thread to prioritize oom killing from userspace and that can be 
> > > done regardless of whether there's a memory leaker, a fork bomber, etc.  
> > > The priority based oom killing is important to production scenarios and 
> > > cannot be replaced by a heuristic that works everytime if it cannot be 
> > > influenced by userspace.
> > > 
> > I don't removed oom_adj...
> > 
> 
> Right, but we must ensure that we have the same ability to influence a 
> priority based oom killing scheme from userspace as we currently do with a 
> relatively static total_vm.  total_vm may not be the optimal baseline, but 
> it does allow users to tune oom_adj specifically to identify tasks that 
> are using more memory than expected and to be static enough to not depend 
> on rss, for example, that is really hard to predict at the time of oom.
> 
> That's actually my main goal in this discussion: to avoid losing any 
> ability of userspace to influence to priority of tasks being oom killed 
> (if you haven't noticed :).
> 
> > > Tweaking on the heuristic will probably make it more convoluted and 
> > > overall worse, I agree.  But it's a more stable baseline than rss from 
> > > which we can set oom killing priorities from userspace.
> > 
> > - "rss < total_vm_size" always.
> 
> But rss is much more dynamic than total_vm, that's my point.
> 
My point and your point are differnt.

  1. All my concern is "baseline for heuristics"
  2. All your concern is "baseline for knob, as oom_adj"

ok ? For selecting victim by the kernel, dynamic value is much more useful.
Current behavior of "Random kill" and "Kill multiple processes" are too bad.
Considering oom-killer is for what, I think "1" is more important.

But I know what you want, so, I offers new knob which is not affected by RSS
as I wrote in previous mail.

Off-topic:
As memcg is growing better, using OOM-Killer for resource control should be
ended, I think. Maybe Fake-NUMA+cpuset is working well for google system, 
but plz consider to use memcg. 



> > - oom_adj culculation is quite strong.
> > - total_vm of processes which maps hugetlb is very big ....but killing them
> >   is no help for usual oom.
> > 
> > I recommend you to add "stable baseline" knob for user space, as I wrote.
> > My patch 6 adds stable baseline bonus as 50% of vm size if run_time is enough
> > large.
> > 
> 
> There's no clear relationship between VM size and runtime.  The forkbomb 
> heuristic itself could easily return a badness of ULONG_MAX if one is 
> detected using runtime and number of children, as I earlier proposed, but 
> that doesn't seem helpful to factor into the scoring. 
> 

Old processes are important, younger are not. But as I wrote, I'll drop
most of patch "6". So, plz forget about this part.

I'm interested in fork-bomb killer rather than crazy badness calculation, now.

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
