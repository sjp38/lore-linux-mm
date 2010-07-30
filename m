Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9004D6B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 16:15:34 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id o6UKFU1N007806
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 13:15:30 -0700
Received: from pxi13 (pxi13.prod.google.com [10.243.27.13])
	by kpbe19.cbf.corp.google.com with ESMTP id o6UKFSiJ031146
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 13:15:29 -0700
Received: by pxi13 with SMTP id 13so707359pxi.8
        for <linux-mm@kvack.org>; Fri, 30 Jul 2010 13:15:28 -0700 (PDT)
Date: Fri, 30 Jul 2010 13:14:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 1/2] oom: badness heuristic rewrite
In-Reply-To: <20100730195338.4AF6.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1007301254270.7008@chino.kir.corp.google.com>
References: <20100730091125.4AC3.A69D9226@jp.fujitsu.com> <20100729183809.ca4ed8be.akpm@linux-foundation.org> <20100730195338.4AF6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 30 Jul 2010, KOSAKI Motohiro wrote:

> Major homework are
> 
> - make patch series instead unreviewable all in one patch.

Hi, KOSAKI.

We've talked about this point many times.  This particular patch simply 
cannot be split up into multiple patches without dropping existing 
behavior without forward-looking statements that they're going to be 
readded later.  For example, I cannot remove the heuristic that lowers the 
score for CAP_SYS_ADMIN tasks from the current implementation and then say 
"it will be readded in a later patch."  That makes it much more difficult 
to review since it takes a lot more effort to ensure nothing was dropped 
that we still need.  As a consequence, oom_badness() needs to be rewritten 
in its entirety (although the majority of changes are deleting lines from 
the current implementation :) and there are consequences in other areas of 
code like changing function signatures and passing the necessary 
information that the heuristic now uses: the total amount of memory that 
the application is bound to, depending on the context in which the oom 
killer was called.

I've said all of that many times so perhaps it was a misunderstanding 
before and now it's more clear after this iteration.  I don't know.  But 
I'd prefer that if the maintainer, Andrew, disagrees with the methodology 
used to generate this patche (and has said he accepts total rewrites in 
the past, even in the discussion regarding this one), that he disagree 
with the paragraph above.  Otherwise we end up talking in circles.

I've made great efforts to make this rewrite happen because it 
significantly improves the oom killer's behavior on the desktop as well as 
enables us to have a much more powerful tunable for server systems to 
prioritize oom killing.  For example, I dropped the forkbomb detector in 
this iteration since it was pretty controversial.  I'd appreciate it if 
you could take the time to review the patch.

> - kill oom_score_adj

I don't quite understand where this is coming from since there's no 
reasoning given, but oom_score_adj is vital to the ability of userspace to 
tune the new heuristic's baseline.  It is the first time we've ever had 
the ability to tune the oom killing priority of a task based on an actual 
unit.  oom_adj does not work with the new heuristic, which ranks tasks by 
a proportion of resident memory to allowed memory.  That ranking is 
necessary because oom killing priority only makes sense when considered 
relative to other candidate tasks: we want to kill the memory hogging task 
and we don't want to reset oom_adj anytime that task is attached to a 
memcg, a cpuset, or a mempolicy.  It's unreasonable to expect userspace to 
tune oom_adj whenever its attachment to a memcg, a cpuset, or a mempolicy 
changes, and whenever their traits changes: the memcg limit changes, the 
set of allowed cpuset mems changes, or the set of allowed mempolicy nodes 
changes.

> - write test way and test result
> 

I've stated multiple times, and the example is mentioned in the changelog, 
that this change prefers to kill memory hogging tasks over X on a desktop 
system as the result of these changes.  The remainder of the change is 
enabling a more powerful interface for server systems that we need to 
introduce with the new heuristic since oom_adj is obsoleted in that case.  
Perhaps we both don't face the same challenges when it comes to tuning the 
oom killer, so you don't fully understand the problem that I'm addressing 
here.  I've stated the importance of oom_score_adj above, I hope you would 
understand that other people use the oom killer for different reasons 
other than your own and we need this interface.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
