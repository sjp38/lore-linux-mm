Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A64DA6B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 19:52:57 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA40qtJx014789
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 4 Nov 2009 09:52:55 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3412145DE52
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:52:55 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DE8AC45DE54
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:52:54 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B15221DB803E
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:52:54 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5544DE08001
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 09:52:53 +0900 (JST)
Date: Wed, 4 Nov 2009 09:50:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Memory overcommit
Message-Id: <20091104095021.5532e913.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.0911031240470.29695@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org>
	<4AE78B8F.9050201@gmail.com>
	<alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Nov 2009 12:49:52 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> On Fri, 30 Oct 2009, KAMEZAWA Hiroyuki wrote:
> 
> > > >    - The kernel can't know the program is bad or not. just guess it.
> > > 
> > > Totally irrelevant, given your fourth point about /proc/pid/oom_adj.  We 
> > > can tell the kernel what we'd like the oom killer behavior should be if 
> > > the situation arises.
> > > 
> > 
> > My point is that the server cannot distinguish memory leak from intentional
> > memory usage. No other than that.
> > 
> 
> That's a different point.  Today, we can influence the badness score of 
> any user thread to prioritize oom killing from userspace and that can be 
> done regardless of whether there's a memory leaker, a fork bomber, etc.  
> The priority based oom killing is important to production scenarios and 
> cannot be replaced by a heuristic that works everytime if it cannot be 
> influenced by userspace.
> 
I don't removed oom_adj...

> A spike in memory consumption when a process is initially forked would be 
> defined as a memory leaker in your quiet_time model.
> 
I'll rewrite or drop quiet_time.

> > In this summer, at lunch with a daily linux user, I was said
> > "you, enterprise guys, don't consider desktop or laptop problem at all."
> > yes, I use only servers. My customer uses server, too. My first priority
> > is always on server users.
> > But, for this time, I wrote reply to Vedran and try to fix desktop problem.
> > Even if current logic works well for servers, "KDE/GNOME is killed" problem
> > seems to be serious. And this may be a problem for EMBEDED people, I guess.
> > 
> 
> You argued before that the problem wasn't specific to X (after I said you 
> could protect it very trivially with /proc/pid/oom_adj set to 
> OOM_DISABLE), but that's now your reasoning for rewriting the oom killer 
> heuristics?
> 
One of reasons. My cusotomers always suffers from "OOM-RANDOM-KILLER".
Why I mentioned about "lunch" is for saying that "I'm not working _only_
for servers."
ok ?


> > I can say the same thing to total_vm size. total_vm size doesn't include any
> > good information for oom situation. And tweaking based on that not-useful
> > parameter will make things worse.
> > 
> 
> Tweaking on the heuristic will probably make it more convoluted and 
> overall worse, I agree.  But it's a more stable baseline than rss from 
> which we can set oom killing priorities from userspace.

- "rss < total_vm_size" always.
- oom_adj culculation is quite strong.
- total_vm of processes which maps hugetlb is very big ....but killing them
  is no help for usual oom.

I recommend you to add "stable baseline" knob for user space, as I wrote.
My patch 6 adds stable baseline bonus as 50% of vm size if run_time is enough
large.

If users can estimate how their process uses memory, it will be good thing.
I'll add some other than oom_adj (I don't say I'll drop oom_adj).

Thanks,
-Kame






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
