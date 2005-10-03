Date: Sun, 2 Oct 2005 20:21:57 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 00/07][RFC] i386: NUMA emulation
Message-Id: <20051002202157.7b54253d.pj@sgi.com>
In-Reply-To: <1128093825.6145.26.camel@localhost>
References: <20050930073232.10631.63786.sendpatchset@cherry.local>
	<1128093825.6145.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: magnus@valinux.co.jp, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Dave wrote:
> Also, I worry that simply #ifdef'ing things out like CPUsets' update
> means that CPUsets lacks some kind of abstraction that it should have
> been using in the first place. 

In the abstract, cpusets should just assume that the system has one or
more CPUs, and one or more Memory Nodes.  Ideally, it should not
require either SMP nor NUMA.  Indeed, if you (Magnus) can get it
to compile with just one or the other of those two:

     config CPUSETS
	    bool "Cpuset support"
    -       depends on SMP
    +       depends on SMP || NUMA

then I would hope that it would compile with neither.  The cpuset
hierarchy on such a system would be rather boring, with all cpusets
having the same one CPU and one Memory Node, but it should work ... in
theory of course.

In practice of course, there may be details on the edges that depend on
the current SMP/NUMA limitations, such as:

Magnus wrote:
> Regarding the #ifdef, it
> was added because partition_sched_domain() is only implemented for
> SMP. That symbol has no prototype or implementation when CONFIG_SMP is
> not set. Maybe it is better to add an empty inline function in
> linux/sched.h for !SMP?

An empty inline partition_sched_domain() would be better than ifdef's
in cpuset.c, yes.  Or at least, that's usually the case.  Probably here
too.

In theory at least, I applaud Magnus's work here.  The assymetry of the
SMP/NUMA define structure has always annoyed me slightly, and only been
explainable in my view as a consequence of the historical order of
development.  I had a PC with a second memory board in an ISA slot,
which would qualify as a one CPU, two Memory Node system.

Or what byte us in the future (that PC was a long time ago), the kinks
in the current setup might be a hitch in our side as we extend to
increasingly interesting architectures.

Aside - for those reading this thread on lkml, it originated
on linux-mm.  It looks like Dave added lkml to the cc list.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
