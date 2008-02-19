Date: Tue, 19 Feb 2008 14:18:20 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH 0/8][for -mm] mem_notify v6
Message-Id: <20080219141820.f7132b62.pj@sgi.com>
In-Reply-To: <20080219140222.4cee07ab@cuia.boston.redhat.com>
References: <2f11576a0802090719i3c08a41aj38504e854edbfeac@mail.gmail.com>
	<20080217084906.e1990b11.pj@sgi.com>
	<20080219145108.7E96.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080219090008.bb6cbe2f.pj@sgi.com>
	<20080219140222.4cee07ab@cuia.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, marcelo@kvack.org, daniel.spang@gmail.com, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk, linux-fsdevel@vger.kernel.org, pavel@ucw.cz, a1426z@gawab.com, jonathan@jonmasters.org, zlynx@acm.org
List-ID: <linux-mm.kvack.org>

Rik wrote:
> Basically in all situations, the kernel needs to warn at the same point
> in time: when the system is about to run out of RAM for anonymous pages.
>
> ...
> 
> In the HPC case, it leads to swapping (and a management program can kill or
> restart something else).

Thanks for stopping by ...

Perhaps with the cgroup based memory controller in progress, or with
other work I'm overlooking, this is or will no longer be a problem,
but on 2.6.16 kernels (the latest ones I have in major production HPC
use) this is not sufficient.

As of at least that point, we don't (didn't ?) have sufficiently
accurate numbers of when we were "about to run out".  We can only
detect when "we just did run out", as evidenced by entering the direct
reclaim code, or as by slightly later events such as starting to push
Anon pages to the swap device from direct reclaim.

Actually, even the point that we enter direct reclaim, near the bottom
of __alloc_pages(), isn't adequate either, as we could be there because
some thread in that cpuset is trying to write out a results file that
is larger than that cpusets memory.   In that case, we really don't want
to kill the job ... it just needs to be (and routinely is) throttled
back to disk speeds as it completes the write out of dirty file system
pages.

So the first clear spot that we -know- serious swapping is commencing
is where the direct reclaim code calls a writepage op with an Anon
page. At that point, having a management program intervene is entirely
too late.  Even having the task at that instant, inline, tag itself
with a SIGKILL, as it queues that first Anon page to a swap device, is
too late.  The direct reclaim code can loop, pushing hundreds or
thousand of pages, on big memory systems, to the swapper, in the
current reclaim loop, before it pops the stack far enough back to even
notice that it has a SIGKILL pending on it.  The suppression of pushing
pages to the swapper has to happen right there, inline in some
mm/vmscan.c code, as part of the direct reclaim loops.

(Hopefully I said something stupid in that last paragraph, and you will
be able to correct it ... it sure would be useful ;).

A year or two ago, I added the 'memory_pressure' per-cpuset meter to
Linux, in an effort to realize just what you suggest, Rik.  My colleagues
at SGI (mostly) and myself (a little) have proven to ourselves that this
doesn't work, for our HPC needs, for two reasons:

 1) once swapping begins, issuing a SIGKILL, no matter how instantly,
    is too late, as explained above, and

 2) that memory_pressure combines and confuses memory pressure due to
    dirty file system buffers filling memory, with memory pressure due
    to anonymous swappable pages filling memory, also as explained above.

I do have a patch in my playarea that adds two more of the
memory_pressure meters, one for swapouts, and one for flushing dirty
file system buffers, both hooking into the spot in the vmscan reclaim
code where the writepage op is called.  This patch ~might~ address the
desktop need here.  It nicely generates two clean, sharp indicators
that we're getting throttled by direct reclaim of dirty file buffers,
and that we're starting to reclaim anon pages to the swappers.  Of course
for embedded use, I'd have to adapt it to a non-cpuset based mechanism
(not difficult), as embedded definitely doesn't do cpusets.

> Don't forget the "hooks for desktop" :)

I'll agree (perhaps out of ignorance) that the desktop (and normal sized
server) cases are like the embedded case ... in that they need to
distribute some event to user space tasks that want to know that memory
is short, so that that user space code can do what it will (reclaim
some user space memory or restart or kill or throttle something?)

However, I'm still stuck carrying a patch out of the community kernel,
to get my HPC customers the "instant kill on direct reclaim swap" they
need, as this still seems to be the special case.  Which is rather
unfortunate, from the business perspective of my good employer, as it
the -only- out of mainline patch, so far as I know, that we have been
having to carry, continuously, for several years now.  But for that
single long standing issue (and now and then various more short term
issues), a vanilla distribution kernel, using the vanilla distribution
config and build, runs production on our one or two thousand CPU,
several terabyte big honkin NUMA boxes.

Part of my motivation for engaging Kosaki-san in this discussion was
to reinvigorate this discussion, as it's getting to be time I took
another shot at getting something in the community kernel that addresses
this.  The more overlap the HPC fix here is with the other 99.978% of
the worlds Linux systems that are desktop, laptop, (ordinary sized)
server or embedded, the better my chances (he said hopefully.)

(Now if I could just get us to consider systems in proportion to
how much power & cooling they need, rather than in proportion to
unit sales ... ;)

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
