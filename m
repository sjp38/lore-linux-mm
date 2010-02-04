Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 371C46B0047
	for <linux-mm@kvack.org>; Thu,  4 Feb 2010 16:34:47 -0500 (EST)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id o14LYg2A002810
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 13:34:43 -0800
Received: from pzk14 (pzk14.prod.google.com [10.243.19.142])
	by spaceape14.eur.corp.google.com with ESMTP id o14LXm8Y029320
	for <linux-mm@kvack.org>; Thu, 4 Feb 2010 13:34:41 -0800
Received: by pzk14 with SMTP id 14so363232pzk.3
        for <linux-mm@kvack.org>; Thu, 04 Feb 2010 13:34:40 -0800 (PST)
Date: Thu, 4 Feb 2010 13:34:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Improving OOM killer
In-Reply-To: <201002040858.33046.l.lunak@suse.cz>
Message-ID: <alpine.DEB.2.00.1002041255080.6071@chino.kir.corp.google.com>
References: <201002012302.37380.l.lunak@suse.cz> <201002032355.01260.l.lunak@suse.cz> <alpine.DEB.2.00.1002031600490.27918@chino.kir.corp.google.com> <201002040858.33046.l.lunak@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Lubos Lunak <l.lunak@suse.cz>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Feb 2010, Lubos Lunak wrote:

> > There're some things that still need to be worked out,
> 
>  Ok. Just please do not let the perfect stand in the way of the good for way 
> too long.
> 

The changes to the heuristic will be a part of a larger patchset that 
basically rewrites the oom killer since there have actually been many 
other suggestions and asides that have been mentioned during the course of 
the discussion: mempolicy targeted oom killing, killing a child only with 
the highest badness score first, always ensuring the killed task shares a 
set of allowed nodes with current, preempting the oom killer for GFP_DMA 
allocations, etc.  I'll write that patchset within the next couple of 
days, but we're still talking about 2.6.35 material at the earliest.  If 
you could test it with your particular usecase we can make sure to work 
any heuristic problems out in the early stages.

> > Do you have any comments about the forkbomb detector or its threshold that
> > I've put in my heuristic?  I think detecting these scenarios is still an
> > important issue that we need to address instead of simply removing it from
> > consideration entirely.
> 
>  I think before finding out the answer it should be first figured out what the 
> question is :). Besides the vague "forkbomb" description I still don't know 
> what realistic scenarios this is supposed to handle. IMO trying to cover 
> intentional abuse is a lost fight, so I think the purpose of this code should 
> be just to handle cases when there's a mistake leading to relatively fast 
> spawning of children of a specific parent that'll lead to OOM.

Yes, forkbombs are not always malicious, they can be the result of buggy 
code and there's no other kernel mechanism that will hold them off so that 
the machine is still usable.  If a task forks and execve's thousands of 
threads on your 2GB desktop machine either because its malicious, its a 
bug, or a the user made a mistake, that's going to be detrimental 
depending on the nature of what was executed especially to your 
interactivity :)  Keep in mind that the forking parent such as a job 
scheduler or terminal and all of its individual children may have very 
small rss and swap statistics, even though cumulatively its a problem.  
In that scenario, KDE is once again going to become the target on your 
machine when in reality we should target the forkbomb.

How we target the forkbomb could be another topic for discussion.  Recall 
that the oom killer does not necessarily always kill the task with the 
highest badness() score; it will always attempt to kill one of its 
children with a seperate mm first.  That doesn't help us as much as it 
could in the forkbomb scenario since the parent could likely continue to 
fork; the end result you'll see is difficulty in getting to a command line 
where you can find and kill the parent yourself.  Thus, we need to preempt 
the preference to kill the child first when we've detected a forkbomb task 
and it is selected for oom kill (detecting a forkbomb is only a 
penalization in the heuristic, it doesn't mean automatic killing, so 
another task consuming much more memory could be chosen instead).

> The shape of 
> the children subtree doesn't matter, it can be either a parent with many 
> direct children, or children being created recursively, I think any case is 
> possible here. A realistic example would be e.g. by mistake 
> typing 'make -j22' instead of 'make -j2' and overloading the machine by too 
> many g++ instances. That would be actually a non-trivial tree of children, 
> with recursive make and sh processes in it.
> 

We can't address recursive forkbombing in the oom killer with any 
efficiency, but luckily those cases aren't very common.

>  A good way to detect this would be checking in badness() if the process has 
> any children with relatively low CPU and real time values (let's say 
> something less than a minute). If yes, the badness score should also account 
> for all these children, recursively. I'm not sure about the exact formula, 
> just summing up the memory usage like it is done now does not fit your 0-1000 
> score idea, and it's also wrong because it doesn't take sharing of memory 
> into consideration (e.g. a KDE app with several kdelibs-based children could 
> achieve a massive score here because of extensive sharing, even though the 
> actual memory usage increase caused by them could be insignificant). I don't 
> know kernel internals, so I don't know how feasible it would be, but one 
> naive idea would be to simply count how big portion of the total memory all 
> these considered processes occupy.
> 

badness() can't be called recursively on children, so we need to look for 
the simple metrics like you mentioned: cpu time, for example.  I think we 
should also look at uid

>  This indeed would not handle the case when a tree of processes would slowly 
> leak, for example there being a bug in Apache and all the forked children of 
> the master process leaking memory equally, but none of the single children 
> leaking enough to score more than a single unrelated innocent process. Here I 
> question how realistic such scenario actually would be, and mainly the actual 
> possibility of detecting such case. I do not see how code could distinguish 
> this from the case of using Konsole or XTerm to launch a number of unrelated 
> KDE/X applications each of which would occupy a considerable amount of 
> memory. Here clearly killing the Konsole/XTerm and all the spawned 
> applications with it is incorrect, so with no obvious offender the OOM killer 
> would simply have to pick something.

The memory consumption of these children were not considered in my rough 
draft, it was simply a counter of how many first-generation children each 
task has.  When Konsole forks a very large number of tasks, is it 
unreasonable to bias it with a penalty of perhaps 10% of RAM?  Or should 
we take the lowest rss size of those children, multiply it by the number 
of children, and penalize it after it reaches a certain threshold (500? 
1000?) as the "cost of running the parent"?  This heavily biases parents 
that have forked a very large number of small threads that would be 
directly killed whereas the large, memory-hog children are killed 
themselves based on their own badness() heuristic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
