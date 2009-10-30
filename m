Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CAB6E6B004D
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 05:10:51 -0400 (EDT)
Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id n9U9AjcV008577
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 09:10:45 GMT
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by spaceape12.eur.corp.google.com with ESMTP id n9U9Ag6Z020135
	for <linux-mm@kvack.org>; Fri, 30 Oct 2009 02:10:43 -0700
Received: by pzk37 with SMTP id 37so1810456pzk.10
        for <linux-mm@kvack.org>; Fri, 30 Oct 2009 02:10:42 -0700 (PDT)
Date: Fri, 30 Oct 2009 02:10:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Memory overcommit
In-Reply-To: <20091030084836.5428e085.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0910300200170.18076@chino.kir.corp.google.com>
References: <hav57c$rso$1@ger.gmane.org> <4AE5CB4E.4090504@gmail.com> <20091027122213.f3d582b2.kamezawa.hiroyu@jp.fujitsu.com> <Pine.LNX.4.64.0910271843510.11372@sister.anvils> <alpine.DEB.2.00.0910271351140.9183@chino.kir.corp.google.com> <4AE78B8F.9050201@gmail.com>
 <alpine.DEB.2.00.0910271723180.17615@chino.kir.corp.google.com> <4AE792B8.5020806@gmail.com> <alpine.DEB.2.00.0910272047430.8988@chino.kir.corp.google.com> <20091028135519.805c4789.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272205200.7507@chino.kir.corp.google.com>
 <20091028150536.674abe68.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910272311001.15462@chino.kir.corp.google.com> <20091028152015.3d383cd6.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0910290136000.11476@chino.kir.corp.google.com>
 <4AE97861.1070902@gmail.com> <alpine.DEB.2.00.0910291248480.2276@chino.kir.corp.google.com> <20091030084836.5428e085.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: vedran.furac@gmail.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, minchan.kim@gmail.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 30 Oct 2009, KAMEZAWA Hiroyuki wrote:

> As I wrote repeatedly,
> 
>    - OOM-Killer itselfs is bad thing, bad situation.

Not necessarily, the memory controller and cpusets uses it quite often to 
enforce it's policy and is standard runtime behavior.  We'd like to 
imagine that our cpuset will never be too small to run all the attached 
jobs, but that happens and we can easily recover from it by killing a 
task.

>    - The kernel can't know the program is bad or not. just guess it.

Totally irrelevant, given your fourth point about /proc/pid/oom_adj.  We 
can tell the kernel what we'd like the oom killer behavior should be if 
the situation arises.

>    - Then, there is no "correct" OOM-Killer other than fork-bomb killer.

Well of course there is, you're seeing this is a WAY too simplistic 
manner.  If we are oom, we want to be able to influence how the oom killer 
behaves and respond to that situation.  You are proposing that we change 
the baseline for how the oom killer selects tasks which we use CONSTANTLY 
as part of our normal production environment.  I'd appreciate it if you'd 
take it a little more seriously.

>    - User has a knob as oom_adj. This is very strong.
> 

Agreed.

> Then, there is only "reasonable" or "easy-to-understand" OOM-Kill.
> "Current biggest memory eater is killed" sounds reasonable, easy to
> understand. And if total_vm works well, overcommit_guess should catch it.
> Please improve overcommit_guess if you want to stay on total_vm.
> 

I don't necessarily want to stay on total_vm, but I also don't want to 
move to rss as a baseline, as you would probably agree.

We disagree about a very fundamental principle: you are coming from a 
perspective of always wanting to kill the biggest resident memory eater 
even for a single order-0 allocation that fails and I'm coming from a 
perspective of wanting to ensure that our machines know how the oom killer 
will react when it is used.  Moving to rss reduces the ability of the user 
to specify an expected oom priority other than polarizing it by either 
disabling it completely with an oom_adj value of -17 or choosing the 
definite next victim with +15.  That's my objection to it: the user cannot 
possibly be expected to predict what proportion of each application's 
memory will be resident at the time of oom.

I understand you want to totally rewrite the oom killer for whatever 
reason, but I think you need to spend a lot more time understanding the 
needs that the Linux community has for its behavior instead of insisting 
on your point of view.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
