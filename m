Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 020556B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 15:50:04 -0500 (EST)
Received: from spaceape24.eur.corp.google.com (spaceape24.eur.corp.google.com [172.28.16.76])
	by smtp-out.google.com with ESMTP id nA3Ko0Fv002052
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 12:50:00 -0800
Received: from pxi31 (pxi31.prod.google.com [10.243.27.31])
	by spaceape24.eur.corp.google.com with ESMTP id nA3KnJ59018784
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 12:49:57 -0800
Received: by pxi31 with SMTP id 31so314620pxi.9
        for <linux-mm@kvack.org>; Tue, 03 Nov 2009 12:49:56 -0800 (PST)
Date: Tue, 3 Nov 2009 12:49:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory overcommit
In-Reply-To: <20091030183638.1125c987.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911031240470.29695@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com> <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com>
 <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com> <20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0910272311001.15462@chino.kir.corp.google.com> <20091028152015.3d383cd6.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910290136000.11476@chino.kir.corp.google.com> <4AE97861.1070902@gmail.com> <alpine.DEB.2.00.0910291248480.2276@chino.kir.corp.google.com>
 <20091030084836.5428e085.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910300200170.18076@chino.kir.corp.google.com> <20091030183638.1125c987.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 30 Oct 2009, KAMEZAWA Hiroyuki wrote:

> > >    - The kernel can't know the program is bad or not. just guess it.
> > 
> > Totally irrelevant, given your fourth point about /proc/pid/oom_adj.  We 
> > can tell the kernel what we'd like the oom killer behavior should be if 
> > the situation arises.
> > 
> 
> My point is that the server cannot distinguish memory leak from intentional
> memory usage. No other than that.
> 

That's a different point.  Today, we can influence the badness score of 
any user thread to prioritize oom killing from userspace and that can be 
done regardless of whether there's a memory leaker, a fork bomber, etc.  
The priority based oom killing is important to production scenarios and 
cannot be replaced by a heuristic that works everytime if it cannot be 
influenced by userspace.

A spike in memory consumption when a process is initially forked would be 
defined as a memory leaker in your quiet_time model.

> In this summer, at lunch with a daily linux user, I was said
> "you, enterprise guys, don't consider desktop or laptop problem at all."
> yes, I use only servers. My customer uses server, too. My first priority
> is always on server users.
> But, for this time, I wrote reply to Vedran and try to fix desktop problem.
> Even if current logic works well for servers, "KDE/GNOME is killed" problem
> seems to be serious. And this may be a problem for EMBEDED people, I guess.
> 

You argued before that the problem wasn't specific to X (after I said you 
could protect it very trivially with /proc/pid/oom_adj set to 
OOM_DISABLE), but that's now your reasoning for rewriting the oom killer 
heuristics?

> I can say the same thing to total_vm size. total_vm size doesn't include any
> good information for oom situation. And tweaking based on that not-useful
> parameter will make things worse.
> 

Tweaking on the heuristic will probably make it more convoluted and 
overall worse, I agree.  But it's a more stable baseline than rss from 
which we can set oom killing priorities from userspace.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
