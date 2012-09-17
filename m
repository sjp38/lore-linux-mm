Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 0AF626B005A
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 15:41:07 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <9e3b0e01-836d-49d3-8aed-9ed9df6c1cfa@default>
Date: Mon, 17 Sep 2012 12:40:58 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: steering allocations to particular parts of memory
References: <20120907182715.GB4018@labbmf01-linux.qualcomm.com>
 <20120911093407.GH11266@suse.de>
 <20120912212829.GC4018@labbmf01-linux.qualcomm.com>
 <20120913083443.GS11266@suse.de>
In-Reply-To: <20120913083443.GS11266@suse.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Larry Bassel <lbassel@codeaurora.org>
Cc: linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>

Hi Larry --

Sorry I missed seeing you and missed this discussion at Linuxcon!

> based on transcendent memory (which I am somewhat familiar
> with, having built something based upon it which can be used either
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> as contiguous memory or as clean cache) might work, but

That reminds me... I never saw this code posted on linux-mm
or lkml or anywhere else.  Since this is another interesting
use of tmem/cleancache/frontswap, it might be good to get
your work into the kernel or at least into some other public
tree.  Is your code post-able? (re original thread:
http://www.spinics.net/lists/linux-mm/msg24785.html )

> At the memory mini-summit last week, it was mentioned
> that the Super-H architecture was using NUMA for this
> purpose, which was considered to be an very bad thing
> to do -- we have ported NUMA to ARM here (as an experiment)
> and agree that NUMA doesn't work well for solving this problem.

If there are any notes/slides/threads with more detail
on this discussion (why NUMA doesn't work well), I'd be
interested in a pointer...

> I am looking for a way to steer allocations (these may be
> by either userspace or the kernel) to or away from particular
> ranges of memory. The reason for this is that some parts of
> memory are different from others (i.e. some memory may be
> faster/slower). For instance there may be 500M of "fast"
> memory and 1500M of "slower" memory on a 2G platform.

In the kernel's current uses of tmem (frontswap and cleancache),
there's no way to proactively steer the allocation.  The
kernel effectively subdivides pages into two priority
classes and lower priority pages end up in cleancache
rather than being reclaimed, and frontswap rather than
on a swap disk.

A brand new in-kernel interface to tmem code to explicitly
allocate "slow memory" is certainly possible, though I
haven't given it much thought.   Depending on how "slow"
is slow, it may make sense for the memory to only be used
for tmem pages rather than for user/kernel-directly-accessible
RAM.

> This pushes responsibility for placement policy out to the edge. While it
> will work to some extent, it'll depend heavily on the applications gettin=
g
> the placement policy right right. If a mistake is made then potentially
> every one of these applications and drivers will need to be fixed althoug=
h
> I would expect that you'd create a new allocator API and hopefully only
> have to fix it there if the policies were suitably fine-grained. To me
> this type of solution is less than ideal as the drivers and applications
> may not really know if the memory is "hot" or not.

I'd have to agree with Mel on this.  There are certainly a number
of enterprise apps that subvert kernel policies and entirely
manage their own memory.  I'm not sure there would be much value
to kernel participation (or using tmem) if this is what you ultimately
need to do.

> I do not think it's a simplified version of memory policies but it is
> certainly similar to memory policies.
>=20
> > Admittedly, most drivers and user processes will not explicitly ask
> > for a certain type of memory.
>=20
> This is what I expect. It means that your solution might work for Super-H
> but it will not work for any of the other use cases where applications
> will be expected to work without modification. I guess it would be fine
> if one was building an applicance where they knew exactly what was going
> to be running and how it behaved but it's not exactly a general solution.
>=20
> > We also would like to be able to create lowmem or highmem
> > from any type of memory.
>=20
> You may be able to hack something into the architecture layer that abuses
> the memory model and remaps some pages into lowmem.
>=20
> > The above makes me wonder if something that keeps nodes and zones
> > and some sort of simple memory policy and throws out the rest of NUMA s=
uch
> > as bindings of memory to CPUs, cpusets, etc. might be useful
> > (though after the memory mini-summit I have doubts about this as well)
> > as node-aware allocators already exist.
>=20
> You can just ignore the cpuset, CPU bindings and all the rest of it
> already. It is already possible to use memory policies to only allocate
> from a specific node (although it is not currently possible to restrict
> allocations to a zone from user space at least).
>=20
> I just fear that solutions that push responsibility out to drivers and
> applications will end up being very hacky, rarely used, and be unsuitable
> for the other use cases where application modification is not an option.

I agree with Mel on all of these comments.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
