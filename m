Date: Thu, 28 Jun 2007 00:33:34 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [patch 4/4] oom: serialize for cpusets
Message-Id: <20070628003334.1ed6da96.pj@sgi.com>
In-Reply-To: <alpine.DEB.0.99.0706272313410.12292@chino.kir.corp.google.com>
References: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
	<alpine.DEB.0.99.0706261949140.24949@chino.kir.corp.google.com>
	<alpine.DEB.0.99.0706261949490.24949@chino.kir.corp.google.com>
	<alpine.DEB.0.99.0706261950140.24949@chino.kir.corp.google.com>
	<Pine.LNX.4.64.0706271452580.31852@schroedinger.engr.sgi.com>
	<20070627151334.9348be8e.pj@sgi.com>
	<alpine.DEB.0.99.0706272313410.12292@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: clameter@sgi.com, andrea@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > I did have this vague recollection that I had seen something
> > like this before, and it got shot down, because even tasks
> > in entirely nonoverlapping cpusets might be holding memory
> > resources on the nodes where we're running out of memory.
> > 
> 
> There's only three cases I'm aware of (and correct me if I'm wrong) where 
> that can happen: the GFP_ATOMIC exception, tasks that have switched their 
> cpuset attachment, or a change in p->mems_allowed and left pages behind in 
> other nodes with memory_migrate set to 0.

Perhaps also shared memory - shared with another task in another cpuset
that originally placed the page, then exited, leaving the current task
as the only one holding it.

Yes - that too would not be a common occurrence.

Christoph Lameter had a reply to Andrea Arcangeli on linux-mm (11 Jun 2007)
in a similar discussion, that might be relevant here:

=============================== begin snip ===============================
On Sat, 9 Jun 2007, Andrea Arcangeli wrote:

> On a side note about the current way you select the task to kill if a
> constrained alloc failure triggers, I think it would have been better
> if you simply extended the oom-selector by filtering tasks in function
> of the current->mems_allowed. Now I agree the current badness is quite

Filtering tasks is a very expensive operation on huge systems. We have had
cases where it took an hour or so for the OOM to complete. OOM usually
occurs under heavy processing loads which makes the taking of global locks
quite expensive.

> bad, now with rss instead of the virtual space, it works a bit better
> at least, but the whole point is that if you integrate the cpuset task
> filtering in the oom-selector algorithm, then once we fix the badness
> algorithm to actually do something more meaningful than to check
> static values, you'll get the better algorithm working for your
> local-oom killing too. This if you really care about the huge-numa
> niche to get node-partitioning working really like if this was a
> virtualized environment. If you just have kill something to release
> memory, killing the current task is always the safest choice
> obviously, so as your customers are ok with it I'm certainly fine with
> the current approach too.

The "kill-the-current-process" approach is most effective in hitting the
process that is allocating the most. And as far as I can tell its easiest
to understand for our customer.
================================ end snip ================================

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
