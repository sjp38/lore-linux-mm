Subject: Re: [PATCH] - support inheritance of mlocks across fork/exec V2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <1228771985.3726.32.camel@calx>
References: <1227561707.6937.61.camel@lts-notebook>
	 <20081125152651.b4c3c18f.akpm@linux-foundation.org>
	 <1228331069.6693.73.camel@lts-notebook>
	 <20081206220729.042a926e.akpm@linux-foundation.org>
	 <1228770337.31442.44.camel@lts-notebook>  <1228771985.3726.32.camel@calx>
Content-Type: text/plain
Date: Tue, 09 Dec 2008 14:40:51 -0500
Message-Id: <1228851652.6379.58.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, riel@redhat.com, hugh@veritas.com, kosaki.motohiro@jp.fujitsu.com, linux-api@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2008-12-08 at 15:33 -0600, Matt Mackall wrote:
> On Mon, 2008-12-08 at 16:05 -0500, Lee Schermerhorn wrote:
> > > > In support of a "lock prefix command"--e.g., mlock <cmd>
> > <args> ...
> > > > Analogous to taskset(1) for cpu affinity or numactl(8) for numa memory
> > > > policy.
> > > > 
> > > > Together with patches to keep mlocked pages off the LRU, this will
> > > > allow users/admins to lock down applications without modifying them,
> > > > if their RLIMIT_MEMLOCK is sufficiently large, keeping their pages
> > > > off the LRU and out of consideration for reclaim.
> > > > 
> > > > Potentially useful, as well, in real-time environments to force
> > > > prefaulting and residency for applications that don't mlock themselves.
> 
> This is a bit scary to me. Privilege and mode inheritance across
> processes is the root of many nasty surprises, security and otherwise.

Hi, Matt:

Could you explain more about this issue?  I believe that the patch
doesn't provide any privileges or capabilities that a process doesn't
already have.  It just allows one to cause a process and, optionally,
its descendants, to behave as if one had modified the sources to invoke
mlockall() directly.  It is still subject to each individual task's
resource limits.  At least, that was my intent.  

> 
> Here's a crazy alternative: add a flag to containers instead? I think
> this is a better match to what you're trying to do and will keep people
> from being surprised when an mlockall call in one thread causes a
> fork/exec in another thread to crash their box, but only sometimes.

Not so crazy.  It isn't really a better match, IMO [more below], but I
can see providing a flag to enable/disable this ability in the
container.  Initially, the default could be disabled.  If/when it's been
around long enough that people are comfortable with it, perhaps the
default could be flipped to enabled.

As far as "what I'm trying to do":  I see this as exactly like using
taskset to set the cpu affinity of a task, or numactl to set the task
mempolicy without modifying the source.  If one had access to the
program source and wouldn't, e.g., void a support contract by modifying
it, one could just insert the calls into the source itself.  These would
still be subject to, but "finer grain" than, external administrative
controls, such as cpuset allowed mems and cpus.

But, sometimes, it's very convenient to use the prefix commands to
effect the same behavior.  I could certainly use it in the Oracle,
SAP, ... benchmarking that I occasionally help out with.  Actually, as I
have the patches, I can create custom kernels for the purpose of
demonstrating the effects.  However, I think it would be useful for
customers someday to have this feature in distro kernels.

I don't understand your comment about threads and crashing the box. If
an inherited mlockall() can crash Linux, then inserting the call into
the source could also crash it.  I think that's a bug we'd need to fix
in any case.  Indeed, using this facility during testing of the
unevictable lru/mlocked pages work DID uncover bugs that I might not
have seen otherwise.   If you meant "cause OOMs", I agree that this
could happen, as well but, again, I think this would be the same
behavior as if the calls were inserted into the source.

Regarding one thread being surprised by what another thread did:  if you
mean threads within the same executable, I'd expect them to part of the
same program.  One hopes that someone knows the big picture--what all
the threads are doing--obviating any such surprises.  But, I recall that
you work/ed in the embedded space, and perhaps threads mean something
different to you.

Anyway...

This is a pretty small patch that I can maintain out of tree for my own
use in testing if people don't think its usefulness outweighs any
concerns it raises.  Customers won't be able to use it, but thems the
breaks.

Regards,
Lee
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
