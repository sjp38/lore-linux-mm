Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8F42D6B0078
	for <linux-mm@kvack.org>; Wed, 10 Feb 2010 23:01:26 -0500 (EST)
From: Lubos Lunak <l.lunak@suse.cz>
Subject: Re: Improving OOM killer
Date: Wed, 10 Feb 2010 21:54:39 +0100
References: <201002012302.37380.l.lunak@suse.cz> <201002040858.33046.l.lunak@suse.cz> <alpine.DEB.2.00.1002041255080.6071@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002041255080.6071@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <201002102154.39771.l.lunak@suse.cz>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Thursday 04 of February 2010, David Rientjes wrote:
> On Thu, 4 Feb 2010, Lubos Lunak wrote:
> >  I think before finding out the answer it should be first figured out
> > what the question is :). Besides the vague "forkbomb" description I still
> > don't know what realistic scenarios this is supposed to handle. IMO
> > trying to cover intentional abuse is a lost fight, so I think the purpose
> > of this code should be just to handle cases when there's a mistake
> > leading to relatively fast spawning of children of a specific parent
> > that'll lead to OOM.
>
> Yes, forkbombs are not always malicious, they can be the result of buggy
> code and there's no other kernel mechanism that will hold them off so that
> the machine is still usable.  If a task forks and execve's thousands of
> threads on your 2GB desktop machine either because its malicious, its a
> bug, or a the user made a mistake, that's going to be detrimental
> depending on the nature of what was executed especially to your
> interactivity :)  Keep in mind that the forking parent such as a job
> scheduler or terminal and all of its individual children may have very
> small rss and swap statistics, even though cumulatively its a problem.

 Which is why I suggested summing up the memory of the parent and its 
children.

> > The shape of
> > the children subtree doesn't matter, it can be either a parent with many
> > direct children, or children being created recursively, I think any case
> > is possible here. A realistic example would be e.g. by mistake
> > typing 'make -j22' instead of 'make -j2' and overloading the machine by
> > too many g++ instances. That would be actually a non-trivial tree of
> > children, with recursive make and sh processes in it.
>
> We can't address recursive forkbombing in the oom killer with any
> efficiency, but luckily those cases aren't very common.

 Right, I've never run a recursive make that brought my machine to its knees. 
Oh, wait.

 And why exactly is iterating over 1st level children efficient enough and 
doing that recursively is not? I don't find it significantly more expensive 
and badness() is hardly a bottleneck anyway.

> >  A good way to detect this would be checking in badness() if the process
> > has any children with relatively low CPU and real time values (let's say
> > something less than a minute). If yes, the badness score should also
> > account for all these children, recursively. I'm not sure about the exact
> > formula, just summing up the memory usage like it is done now does not
> > fit your 0-1000 score idea, and it's also wrong because it doesn't take
> > sharing of memory into consideration (e.g. a KDE app with several
> > kdelibs-based children could achieve a massive score here because of
> > extensive sharing, even though the actual memory usage increase caused by
> > them could be insignificant). I don't know kernel internals, so I don't
> > know how feasible it would be, but one naive idea would be to simply
> > count how big portion of the total memory all these considered processes
> > occupy.
>
> badness() can't be called recursively on children,
> the simple metrics like you mentioned: cpu time, for example.

 I didn't mean calling badness() recursively, just computing total memory 
usage of the parent and all the children together (and trying not to count 
shared parts more than once). If doing that accurately is too expensive, 
summing rss+swap for the parent and using only unshared memory for the 
children seems reasonably close to it and pretty cheap (surely if the code 
can find out rss+swap for each child it can equally easily find out how much 
of it is unshared?). With the assumption that the shared memory will be 
hopefully reasonably accounted in the parent's memory usage and thus only 
unshared portions for children are needed, this appears to be much more 
precise than trying to sum up rss for all like your proposal does.

> >  This indeed would not handle the case when a tree of processes would
> > slowly leak, for example there being a bug in Apache and all the forked
> > children of the master process leaking memory equally, but none of the
> > single children leaking enough to score more than a single unrelated
> > innocent process. Here I question how realistic such scenario actually
> > would be, and mainly the actual possibility of detecting such case. I do
> > not see how code could distinguish this from the case of using Konsole or
> > XTerm to launch a number of unrelated KDE/X applications each of which
> > would occupy a considerable amount of memory. Here clearly killing the
> > Konsole/XTerm and all the spawned applications with it is incorrect, so
> > with no obvious offender the OOM killer would simply have to pick
> > something.
>
> The memory consumption of these children were not considered in my rough
> draft, it was simply a counter of how many first-generation children each
> task has.

 Why exactly do you think only 1st generation children matter? Look again at 
the process tree posted by me and you'll see it solves nothing there. I still 
fail to see why counting also all other generations should be considered 
anything more than a negligible penalty for something that's not a bottleneck 
at all.

> When Konsole forks a very large number of tasks, is it 
> unreasonable to bias it with a penalty of perhaps 10% of RAM?

 It appears unresonable to penalize it with a random magic number.

> Or should 
> we take the lowest rss size of those children, multiply it by the number
> of children, and penalize it after it reaches a certain threshold (500?
> 1000?) as the "cost of running the parent"?

 And another magic number. And again it doesn't solve my initial problem, 
where the number of processes taking part in the OOM situation is counted 
only in tens.

 Simply computing the cost of the whole children subtree (or a reasonable 
approximation) avoids the need for any magic numbers and gives a much better 
representation of how costly the subtree is, since, well, it is the cost 
itself.

> This heavily biases parents 
> that have forked a very large number of small threads that would be
> directly killed whereas the large, memory-hog children are killed
> themselves based on their own badness() heuristic.

-- 
 Lubos Lunak
 openSUSE Boosters team, KDE developer
 l.lunak@suse.cz , l.lunak@kde.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
