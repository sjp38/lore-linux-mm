Date: Thu, 28 Jun 2007 01:05:36 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 4/4] oom: serialize for cpusets
In-Reply-To: <20070628003334.1ed6da96.pj@sgi.com>
Message-ID: <alpine.DEB.0.99.0706280039510.17762@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261949490.24949@chino.kir.corp.google.com>
 <alpine.DEB.0.99.0706261950140.24949@chino.kir.corp.google.com>
 <Pine.LNX.4.64.0706271452580.31852@schroedinger.engr.sgi.com>
 <20070627151334.9348be8e.pj@sgi.com> <alpine.DEB.0.99.0706272313410.12292@chino.kir.corp.google.com>
 <20070628003334.1ed6da96.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: clameter@sgi.com, andrea@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jun 2007, Paul Jackson wrote:

> > There's only three cases I'm aware of (and correct me if I'm wrong) where 
> > that can happen: the GFP_ATOMIC exception, tasks that have switched their 
> > cpuset attachment, or a change in p->mems_allowed and left pages behind in 
> > other nodes with memory_migrate set to 0.
> 
> Perhaps also shared memory - shared with another task in another cpuset
> that originally placed the page, then exited, leaving the current task
> as the only one holding it.
> 

That's possible, but then the user gets what he deserves because he's 
chosen to share memory across cpusets.  Without the expensive search 
through all system tasks and an examination of their associated mm's to 
determine whether it has allocated memory on an OOM'ing node, we can't fix 
that problem.  And, even then, this would only help if that task were the 
only user of such memory.  Otherwise we kill it unnecessarily.

>From Christoph Lameter:
> Filtering tasks is a very expensive operation on huge systems. We have had
> cases where it took an hour or so for the OOM to complete. OOM usually
> occurs under heavy processing loads which makes the taking of global locks
> quite expensive.
> 

The cost of this operation as I've enabled it in the OOM killer would be 
similiar to cating /dev/cpuset/my_cpuset/tasks, with the exception that it 
will take slightly longer if we have an elaborate hierarchy of 
non-mem_exclusive cpusets.  We need to hold a read_lock(&tasklist_lock) 
and callback_mutex for this, but I would argue that if it's perfectly 
legitimate for a system-wide (CONSTRAINT_NONE) OOM condition, then it 
should be legitimate for a cpuset-wide (CONSTRAINT_CPUSET) OOM.  All "huge 
systems" surely don't use cpusets currently and they must not be affected 
by this contention with current mainline behavior or we'd hear complaints.  
The OOM killer does not act egregiously.

Also from Christoph Lameter:
> The "kill-the-current-process" approach is most effective in hitting the
> process that is allocating the most. And as far as I can tell its easiest
> to understand for our customer.

Hmm, it probably goes without saying that I disagree with the first 
sentence or otherwise I wouldn't have written the patchset.  There is 
actually no guarantee at all that current is allocating the most, it could 
have just attempted to allocate at a very unfortunate time and ended up 
being the sacrificial lamb in the OOM killer.

A much better set of rules to determine what the best task to kill is 
through the select_bad_process() heuristics which take things such as 
OOM_DISABLE and total VM size into account when scoring tasks.  It's 
certainly the fairest way of determining which task to kill that will, 
hopefully, alleviate the OOM condition as soon as possible for that 
cpuset.  I would argue that going through select_bad_process() would not 
be as great of a performance hit as you might suspect compared with git 
HEAD's behavior of trying to kill current, which may be ineligible for 
several different reasons, making out_of_memory() a no-op, looping back to 
__alloc_pages(), rescheduling, and spinning until such time as an eligible 
task does hit out_of_memory() which would require an explicit memory 
allocation attempt from it to even occur.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
