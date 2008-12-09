Subject: Re: [PATCH] - support inheritance of mlocks across fork/exec V2
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <1228851652.6379.58.camel@lts-notebook>
References: <1227561707.6937.61.camel@lts-notebook>
	 <20081125152651.b4c3c18f.akpm@linux-foundation.org>
	 <1228331069.6693.73.camel@lts-notebook>
	 <20081206220729.042a926e.akpm@linux-foundation.org>
	 <1228770337.31442.44.camel@lts-notebook>  <1228771985.3726.32.camel@calx>
	 <1228851652.6379.58.camel@lts-notebook>
Content-Type: text/plain
Date: Tue, 09 Dec 2008 14:41:36 -0600
Message-Id: <1228855296.3726.113.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, riel@redhat.com, hugh@veritas.com, kosaki.motohiro@jp.fujitsu.com, linux-api@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-12-09 at 14:40 -0500, Lee Schermerhorn wrote:
> On Mon, 2008-12-08 at 15:33 -0600, Matt Mackall wrote:
> > On Mon, 2008-12-08 at 16:05 -0500, Lee Schermerhorn wrote:
> > > > > In support of a "lock prefix command"--e.g., mlock <cmd>
> > > <args> ...
> > > > > Analogous to taskset(1) for cpu affinity or numactl(8) for numa memory
> > > > > policy.
> > > > > 
> > > > > Together with patches to keep mlocked pages off the LRU, this will
> > > > > allow users/admins to lock down applications without modifying them,
> > > > > if their RLIMIT_MEMLOCK is sufficiently large, keeping their pages
> > > > > off the LRU and out of consideration for reclaim.
> > > > > 
> > > > > Potentially useful, as well, in real-time environments to force
> > > > > prefaulting and residency for applications that don't mlock themselves.
> > 
> > This is a bit scary to me. Privilege and mode inheritance across
> > processes is the root of many nasty surprises, security and otherwise.
> 
> Hi, Matt:
> 
> Could you explain more about this issue?  I believe that the patch
> doesn't provide any privileges or capabilities that a process doesn't
> already have.  It just allows one to cause a process and, optionally,
> its descendants, to behave as if one had modified the sources to invoke
> mlockall() directly.  It is still subject to each individual task's
> resource limits.  At least, that was my intent.  

Again, it's about inheriting *something* across processes. This
historically creates surprises. When the thing being inherited is a
privilege, the surprises are security holes. I can't tell you what the
surprises are, only that I expect there to be some.

mlockall is not a privilege in itself, but it is a non-standard mode of
operation that most processes are not designed for or expecting, and it
does relate to the handling of a finite resource with system stability
implications. If the thing that turns on this mode is buried inside some
poorly written app that decides it needs to mlockall somewhere, the
'surprise' can occur far away - in the child of a child of a thread an
hour later. And the surprise can be fatal - all memory eaten up, because
our process just happened to run without an rlimit.

I've seen this with RT. An app temporarily elevates itself to RT, and
unrelatedly forks another process. The second short-lived process kicks
off a daemon that sometime later consumes all CPU in a busy loop (in
this case waiting on I/O that never happens because everything else is
shut out).

Doing it as a container parameter means that you explicitly recognize
that 'everything in the container' gets this mode. And you've probably
also given a thought to 'how big is this container' and the like as
well.

> As far as "what I'm trying to do":  I see this as exactly like using
> taskset to set the cpu affinity of a task, or numactl to set the task
> mempolicy without modifying the source.

Oh sure, I completely get that and I think it's a useful notion. And I
think the above analogous interfaces have more or less the same issues,
except that mlockall is a much older and more widely used API.
Containers are a better match here too, but the above predate
containers.

>   If one had access to the
> program source and wouldn't, e.g., void a support contract by modifying
> it, one could just insert the calls into the source itself.

Huh? We would of course set up a container 'from the outside'. By
comparison, your mlockall() call traditionally operates from 'from the
inside', and you're proposing to add a flag and a helper program that
makes it work 'from the outside' too. Which is a bit hackish.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
