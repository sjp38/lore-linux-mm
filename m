Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id CF2A5900138
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 17:58:16 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p88Lrjv7001914
	for <linux-mm@kvack.org>; Thu, 8 Sep 2011 14:53:45 -0700
Received: from qwm42 (qwm42.prod.google.com [10.241.196.42])
	by wpaz37.hot.corp.google.com with ESMTP id p88Lrg1f009634
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 8 Sep 2011 14:53:44 -0700
Received: by qwm42 with SMTP id 42so1529784qwm.16
        for <linux-mm@kvack.org>; Thu, 08 Sep 2011 14:53:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E68484A.4000201@parallels.com>
References: <1315276556-10970-1-git-send-email-glommer@parallels.com>
 <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com>
 <4E664766.40200@parallels.com> <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com>
 <4E66A0A9.3060403@parallels.com> <CAHH2K0aq4s1_H-yY0kA3LhM00CCNNbJZyvyBoDD6rHC+qo_gNg@mail.gmail.com>
 <4E68484A.4000201@parallels.com>
From: Greg Thelen <gthelen@google.com>
Date: Thu, 8 Sep 2011 14:53:22 -0700
Message-ID: <CAHH2K0YcXMUfd1Zr=f5a4=X9cPPp8NZiuichFXaOo=kVp5rRJA@mail.gmail.com>
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Suleiman Souhlal <suleiman@google.com>

On Wed, Sep 7, 2011 at 9:44 PM, Glauber Costa <glommer@parallels.com> wrote=
:

Thanks for your ideas and patience.

> Well, it is a way to see this. The other way to see this, is that you're
> proposing to move to the kernel, something that really belongs in userspa=
ce.
> That's because:
>
> With the information you provided me, I have no reason to believe that th=
e
> kernel has more condition to do this work. Do the kernel have access to a=
ny
> information that userspace do not, and can't be exported? If not, userspa=
ce
> is traditionally where this sort of stuff has been done.

I think direct reclaim is a pain if user space is required to participate i=
n
memory balancing decisions.  One thing a single memory limit solution has i=
s the
ability to reclaim user memory to satisfy growing kernel memory needs (and =
vise
versa).  If a container must fit within 100M, then a single limit solution
would set the limit to 100M and never change it.  In a split limit solution=
 a
user daemon (e.g. uswapd) would need to monitor the usage and the amount of
active memory vs inactive user memory and unreferenced kernel memory to
determine where to apply pressure.  With some more knobs such a uswapd coul=
d
attempt to keep ahead of demand.  But eventually direct reclaim would
be needed to satisfy rapid growth spikes.  Example: If the 100M container
starts with limits of 20M kmem and 80M user memory but later its kernel
memory needs grow to 70M.  With separate user and kernel memory
limits the kernel memory allocation could fail despite there being
reclaimable user pages available.  The job should have a way to
transition to memory limits to 70M+ kernel and 30M- of user.

I suppose a GFP_WAIT slab kernel page allocation could wakeup user space to
perform user-assisted direct reclaim.  User space would then lower the user
limit thereby causing the kernel to direct reclaim user pages, then
the user daemon would raise the kernel limit allowing the slab allocation t=
o
succeed.  My hunch is that this would be prone to deadlocks (what prevents
uswapd from needing more even more kmem?)  I'll defer to more
experienced minds to know if user assisted direct memory reclaim has
other pitfalls.  It scares me.

Fundamentally I have no problem putting an upper bound on a cgroup's resour=
ce
usage.  This serves to contain the damage a job can do to the system and ot=
her
jobs.  My concern is about limiting the kernel's ability to trade one type =
of
memory for another by using different cgroups for different types of memory=
.

If kmem expands to include reclaimable kernel memory (e.g. dentry) then I
presume the kernel would have no way to exchange unused user pages for dent=
ry
pages even if the user memory in the container is well below its limit.  Th=
is is
motivation for the above user assisted direct reclaim.

Do you feel the need to segregate user and kernel memory into different cgr=
oups
with independent limits?  Or is this this just a way to create a new clean
cgroup with a simple purpose?

In some resource sharing shops customers purchase a certain amount of memor=
y,
cpu, network, etc.  Such customers don't define how the memory is used and =
the
user/kernel mixture may change over time.  Can a user space reclaim daemon =
stay
ahead of the workloads needs?

> Using userspace CPU is no different from using kernel cpu in this particu=
lar
> case. It is all overhead, regardless where it comes from. Moreover, you e=
nd
> up setting up a policy, instead of a mechanism. What should be this
> proportion? =A0Do we reclaim everything with the same frequency? Should w=
e be
> more tolerant with a specific container?

I assume that this implies that a generic kmem cgroup usage is inferior to
separate limits for each kernel memory type to allow user space the flexibi=
lity
to choose between kernel types (udp vs tcp vs ext4 vs page_tables vs ...)? =
 Do
you foresee a way to provide a limit on the total amount of kmem usage by a=
ll
such types?  If a container wants to dedicate 4M for all network protocol
buffers (tcp, udp, etc.) would that require a user space daemon to balance
memory limits b/w the protocols?

> Also, If you want to allow any flexibility in this scheme, like: "Should
> this network container be able to stress the network more, pinning more
> memory, but not other subsystems?", you end up having to touch all
> individual files anyway - probably with a userspace daemon.
>
> Also, as you noticed yourself, kernel memory is fundamentally different f=
rom
> userspace memory. You can't just set reclaim limits, since you have no
> guarantees it will work. User memory is not a scarce resource.
> Kernel memory is.

I agree that kernel memory is somewhat different.  In some (I argue most)
situations containers want the ability to exchange job kmem and job umem.
Either split or combined accounting protects the system and isolates other
containers from kmem allocations of a bad job.  To me it seems natural to
indicate that job X gets Y MB of memory.  I have more trouble dividing the
Y MB of memory into dedicated slices for different types of memory.

>> While there are people (like me) who want a combined memory usage
>> limit there are also people (like you) who want separate user and
>> kernel limiting.
>
> Combined excludes separate. Separate does not exclude combined.

I agree.  I have no problem with separate accounting and separate
user-accessible pressure knobs to allow for complex policies.  My concern i=
s
about limiting the kernel's ability to reclaim one type of memory to
fulfill the needs of another memory type (e.g. I think reclaiming clean fil=
e
pages should be possible to make room for user slab needs).  I think
memcg aware slab accounting does a good job of limiting a job's
memory allocations.
Would such slab accounting meet your needs?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
