Content-Type: text/plain; charset=US-ASCII
From: Daniel Phillips <phillips@bonn-fries.net>
Subject: Re: Load control  (was: Re: 2.4.9-ac16 good perfomer?)
Date: Mon, 1 Oct 2001 17:51:47 +0200
References: <200110011449.JAA80750@tomcat.admin.navo.hpc.mil>
In-Reply-To: <200110011449.JAA80750@tomcat.admin.navo.hpc.mil>
MIME-Version: 1.0
Content-Transfer-Encoding: 7BIT
Message-Id: <20011001155149Z16373-2757+2648@humbolt.nl.linux.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jesse Pollard <pollard@tomcat.admin.navo.hpc.mil>, riel@conectiva.com.br
Cc: Mike Fedyk <mfedyk@matchmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On October 1, 2001 04:49 pm, Jesse Pollard wrote:
> 5. If swap full, do not start new processes (ENOMEM)

I was going to pounce on this one, but then I read the rest of your post...

> I also vaguely remember something about processes spawning new processes -
> if memory wasn't immediately available (working set minimum for the new
> process) then the process attempting the spawn is put to sleep (or swapped,
> or both - this may have only occured if there was room in swap for the
> process, if not - ENOMEM on the fork, in case that causes the parent to
> exit and free more memory).

Yes, here it should degrade gracefully as well.  Child-spawning tasks should
should be made to wait an increasingly long time as pressure increases before
they start seeing a lot of ENOMEM's.  Also, such penalties must be carefully
targetted so as not to prevent, for example, a new root login for
administrative purposes.  Under tight memory conditions we would want to
target any task that spawns children rapidly, which would constitute a sane
form of fork bomb control: its ok to spawn many tasks rapidly a long as
memory is lightly loaded.

Another weapon we can add to our arsenal is the possibility of suspending
tasks to non-swap storage, which would effectively add a second level of swap
space as large as all the free space on your disk.  Equivalently but perhaps
more usefully, we could allow swap files to grow dynamically.

Implementing such complex policy seems a distant goal considering that we are
still far from even being able to make an accurate OOM determination.
However, I have a suggestion.  Such policy is exactly that, policy, and as
such should be implemented outside the kernel.  We just need to expose the
relevant statistics and vm/scheduler control hooks, taking care that the task
responsible for scheduling policy never becomes its own victim.  This is a
much smaller and more clearly defined task than actually implementing the
task control policy.

> The trimming action did not immediately cause a pageout - all that was
> needed was to reduce the working set size. The process that needed memory
> would then cause the system to scan memory for pages that could be freed.
> The first process examined (may have been the process asking for memory)
> would have the excess pages paged out. (I believe they were chosen by a
> LRU mechanism)
>
> There was also a scheduling fairness rule about swapped processes geting
> a schedule increment of 1, in memory processes got incremented 4, IO wait
> processes got +6. When they were selected for run: if previous state was IO,
> then decrement by 2, if state run, decrement by 2. If a swapped process
> schedule value > in memory process, swap the memory resident process out,
> swapin  the swaped process. (Oviously this isn't quite right :-)

Wouldn't you love to be able to tweak this policy from user space, in a
language of your choice, on a running system? ;-)

--
Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
