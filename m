Date: Tue, 3 May 2005 01:08:46 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH/RFC 0/4] VM: Manual and Automatic page cache reclaim
Message-Id: <20050503010846.508bbe62.akpm@osdl.org>
In-Reply-To: <4277259C.6000207@engr.sgi.com>
References: <20050427150848.GR8018@localhost>
	<20050427233335.492d0b6f.akpm@osdl.org>
	<4277259C.6000207@engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: mort@sgi.com, linux-mm@kvack.org, raybry@sgi.com, ak@suse.de
List-ID: <linux-mm.kvack.org>

Ray Bryant <raybry@engr.sgi.com> wrote:
>
> ...
> One of the common responses to changes in the VM system for optimizations
> of this type is that we instead should devote our efforts to improving
> the VM system algorithms and that we are taking an "easy way out" by
> putting a hack into the VM system.

There's that plus the question which forever lurks around funky SGI patches:

	How many machines in the world want this feature?

Because if the answer is "twelve" then gee it becomes hard to justify
merging things into the mainline kernel.  Particularly when they add
complexity to page reclaim.

>  Fundamentally, the VM system cannot
> predict the future behavior of the application in order to correctly
> make this tradeoff.

Yup.  But we could add a knob to each zone which says, during page
allocation "be more reluctant to advance onto the next node - do some
direct reclaim instead"

And the good thing about that is that it is an easier merge because it's a
simpler patch and because it's useful to more machines.  People can tune it
and get better (or worse) performance from existing apps on NUMA.

Yes, if it's a "simple" patch then it _might_ do a bit of swapout or
something.  But the VM does prefer to reclaim clean pagecache first (as
well as slab, which is a bonus for this approach).

Worth trying, at least?

> 
> Why isn't POSIX_FADV_DONTNEED good enough here?
> ----------------------------------------------

I was going to ask that.

> We've tried that too.  If the application is sufficiently aware of what
> files it has opened, it could schedule those page cache pages to be
> released.  Unfortunately, this doesn't handle the case of the last
> application that ran and wrote out a bunch of data before it terminated,
> nor does it deal very well with shell scripts that stage data onto and
> off of the compute node as part the job's workflow.

Ah.  But to do this we need to be able to answer the question "what files
are in pagecache, and how much pagecache do they have".  (And "on what
nodes", but let's ignore that coz it's hard ;)) And something like this
would be an easier merge because it's useful to more than twelve machines.

It could be done in userspace, really.  Hack into glibc's open() and
creat() to log file opening activity, something silly like that.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
