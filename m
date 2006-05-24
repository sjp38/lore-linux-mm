Message-Id: <7.0.0.16.2.20060524073251.0237c250@llnl.gov>
Date: Wed, 24 May 2006 08:05:39 -0700
From: Dave Peterson <dsp@llnl.gov>
Subject: Re: [PATCH (try #3)] mm: avoid unnecessary OOM kills
In-Reply-To: <44739E2D.60406@yahoo.com.au>
References: <200605230032.k4N0WCIU023760@calaveras.llnl.gov>
 <4472A006.2090006@yahoo.com.au>
 <7.0.0.16.2.20060523094646.02429fd8@llnl.gov>
 <44739E2D.60406@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, pj@sgi.com, ak@suse.de, linux-mm@kvack.org, garlick@llnl.gov, mgrondona@llnl.gov
List-ID: <linux-mm.kvack.org>

At 04:43 PM 5/23/2006, Nick Piggin wrote:
>>That would be another way to do things.  It's a tradeoff between either
>>    option A: Each task that enters the OOM code path must loop over all
>>              tasks to determine whether an OOM kill is in progress.
>>    or...
>>    option B: We must declare an oom_kill_in_progress variable and add
>>              the following snippet of code to mmput():
>>                put_swap_token(mm);
>>+               if (unlikely(test_bit(MM_FLAG_OOM_NOTIFY, &mm->flags)))
>>+                       oom_kill_finish();  /* terminate pending OOM kill */
>>                mmdrop(mm);
>>I think either option is reasonable (although I have a slight preference
>>for B since it eliminates substantial looping through the tasklist).
>
>Don't you have to loop through the tasklist anyway? To find a task
>to kill?
>
>Either way, at the point of OOM, usually they should have gone through
>the LRU lists several times, so a little bit more CPU time shouldn't
>hurt.

ok, I'll change the patch to use option A.

>>>Is all this really required? Shouldn't you just have in place the
>>>mechanism to prevent concurrent OOM killings in the OOM code, and
>>>so the page allocator doesn't have to bother with it at all (ie.
>>>it can just call into the OOM killer, which may or may not actually
>>>kill anything).
>>
>>I agree it's desirable to keep the OOM killing logic as encapsulated
>>as possible.  However unless you are holding the oom kill semaphore
>>when you make your final attempt to allocate memory it's a bit racy.
>>Holding the OOM kill semaphore guarantees that our final allocation
>>failure before invoking the OOM killer occurred _after_ any previous
>>OOM kill victim freed its memory.  Thus we know we are not shooting
>>another process prematurely (i.e. before the memory-freeing effects
>>of our previous OOM kill have been felt).
>
>But there is so much fudge in it that I don't think it matters:
>pages could be freed from other sources, some reclaim might happen,
>the point at which OOM is declared is pretty arbitrary anyway, etc.

There's definitely some fudge in it.  However the main scenario I'm
concerned with is where one big process is hogging most of the memory
(as opposed to a case where the collective memory-hogging effect of
lots of little processes triggers the OOM killer).  In the first case
we want to shoot the one big process and leave the little processes
undisturbed.

If the final allocation failure before invoking the OOM killer
occurs when we don't yet hold the OOM kill semaphore then I'd
be concerned about processes queueing up on the OOM kill semaphore
after they fail their memory allocations.  If only one of these
ends up getting awakened _after_ the death of the big memory hog,
then that process will enter the OOM killer and shoot a little
process unnecessarily.

Alternately (perhaps less likely), if your kernel is preemptible,
after the memory hog has been shot but not yet expired a process
may get preempted between its final allocation failure and its
choosing an OOM kill victim (with the memory hog expiring before
the preempted process gets rescheduled).  Then the preempted
process shoots a little process when rescheduled.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
