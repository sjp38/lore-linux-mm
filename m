Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6D76B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 20:58:13 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id nA41wApc019823
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 17:58:10 -0800
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by spaceape14.eur.corp.google.com with ESMTP id nA41w66L000334
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 17:58:07 -0800
Received: by pzk33 with SMTP id 33so4673257pzk.2
        for <linux-mm@kvack.org>; Tue, 03 Nov 2009 17:58:06 -0800 (PST)
Date: Tue, 3 Nov 2009 17:58:04 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory overcommit
In-Reply-To: <20091104095021.5532e913.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0911031752180.1187@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org> <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com> <20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272311001.15462@chino.kir.corp.google.com> <20091028152015.3d383cd6.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.0910290136000.11476@chino.kir.corp.google.com> <4AE97861.1070902@gmail.com> <alpine.DEB.2.00.0910291248480.2276@chino.kir.corp.google.com> <20091030084836.5428e085.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910300200170.18076@chino.kir.corp.google.com>
 <20091030183638.1125c987.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911031240470.29695@chino.kir.corp.google.com> <20091104095021.5532e913.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 4 Nov 2009, KAMEZAWA Hiroyuki wrote:

> > That's a different point.  Today, we can influence the badness score of 
> > any user thread to prioritize oom killing from userspace and that can be 
> > done regardless of whether there's a memory leaker, a fork bomber, etc.  
> > The priority based oom killing is important to production scenarios and 
> > cannot be replaced by a heuristic that works everytime if it cannot be 
> > influenced by userspace.
> > 
> I don't removed oom_adj...
> 

Right, but we must ensure that we have the same ability to influence a 
priority based oom killing scheme from userspace as we currently do with a 
relatively static total_vm.  total_vm may not be the optimal baseline, but 
it does allow users to tune oom_adj specifically to identify tasks that 
are using more memory than expected and to be static enough to not depend 
on rss, for example, that is really hard to predict at the time of oom.

That's actually my main goal in this discussion: to avoid losing any 
ability of userspace to influence to priority of tasks being oom killed 
(if you haven't noticed :).

> > Tweaking on the heuristic will probably make it more convoluted and 
> > overall worse, I agree.  But it's a more stable baseline than rss from 
> > which we can set oom killing priorities from userspace.
> 
> - "rss < total_vm_size" always.

But rss is much more dynamic than total_vm, that's my point.

> - oom_adj culculation is quite strong.
> - total_vm of processes which maps hugetlb is very big ....but killing them
>   is no help for usual oom.
> 
> I recommend you to add "stable baseline" knob for user space, as I wrote.
> My patch 6 adds stable baseline bonus as 50% of vm size if run_time is enough
> large.
> 

There's no clear relationship between VM size and runtime.  The forkbomb 
heuristic itself could easily return a badness of ULONG_MAX if one is 
detected using runtime and number of children, as I earlier proposed, but 
that doesn't seem helpful to factor into the scoring. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
