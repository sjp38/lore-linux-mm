Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1EF276B0173
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 00:17:58 -0400 (EDT)
Message-ID: <4E699341.9010606@parallels.com>
Date: Fri, 9 Sep 2011 01:17:05 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
References: <1315276556-10970-1-git-send-email-glommer@parallels.com> <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com> <4E664766.40200@parallels.com> <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com> <4E66A0A9.3060403@parallels.com> <CAHH2K0aq4s1_H-yY0kA3LhM00CCNNbJZyvyBoDD6rHC+qo_gNg@mail.gmail.com> <4E68484A.4000201@parallels.com> <CAHH2K0YcXMUfd1Zr=f5a4=X9cPPp8NZiuichFXaOo=kVp5rRJA@mail.gmail.com>
In-Reply-To: <CAHH2K0YcXMUfd1Zr=f5a4=X9cPPp8NZiuichFXaOo=kVp5rRJA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Suleiman Souhlal <suleiman@google.com>

On 09/08/2011 06:53 PM, Greg Thelen wrote:
> On Wed, Sep 7, 2011 at 9:44 PM, Glauber Costa<glommer@parallels.com>  wrote:
>
> Thanks for your ideas and patience.

Likewise. It is turning out to be a very fruitful
discussion.

>> Well, it is a way to see this. The other way to see this, is that you're
>> proposing to move to the kernel, something that really belongs in userspace.
>> That's because:
>>
>> With the information you provided me, I have no reason to believe that the
>> kernel has more condition to do this work. Do the kernel have access to any
>> information that userspace do not, and can't be exported? If not, userspace
>> is traditionally where this sort of stuff has been done.
>
> I think direct reclaim is a pain if user space is required to participate in
> memory balancing decisions.
It depends on the decision.

> One thing a single memory limit solution has is the
> ability to reclaim user memory to satisfy growing kernel memory needs (and vise
> versa).

this works for a strict definition of the word "needs". If I *need*
more kernel memory, I'd be happy to have more. But if I just want to
screw other containers, they will be happy if I don't get what I
"need" - it can be unreclaimable. Since those are limits, they are
expected to be, in any real setups, greater than any use people
should be doing, and yet, prevent bad usage scenarios.

> If a container must fit within 100M, then a single limit solution
> would set the limit to 100M and never change it.  In a split limit solution a
> user daemon (e.g. uswapd) would need to monitor the usage and the amount of
> active memory vs inactive user memory and unreferenced kernel memory to
> determine where to apply pressure.

Or it can just define some parameters and let the kernel do the
rest. Like for instance, a maximum proportion allowed, a maximum
proportion desired, etc.

> With some more knobs such a uswapd could
> attempt to keep ahead of demand.  But eventually direct reclaim would
> be needed to satisfy rapid growth spikes.  Example: If the 100M container
> starts with limits of 20M kmem and 80M user memory but later its kernel
> memory needs grow to 70M.  With separate user and kernel memory
> limits the kernel memory allocation could fail despite there being
> reclaimable user pages available.

No no, this is a ratio, not a *limit*. A limit is something you
should not be allowed to go over. A good limit of kernel memory for
a 100 Mb container could be something like... 100 mb. But there is
more to that.

Risking being a bit polemic here, I think that when we do
containers, we have to view the kernel a little bit like a shared 
resource that is not accounted to anybody. It is easy to account things 
like tcp buffer, but who do you account page tables for shared pages to? 
Or pinned dentries for shared filesystems ?

Being the shared table under everybody, the kernel is more or less
like buffers inside a physical hdd, or cache lines. You know it is
there, you know it has a size, but provided you have some sane
protections, you don't really care - because in most cases you can't
- who is using it.

> The job should have a way to
> transition to memory limits to 70M+ kernel and 30M- of user.

Yes, and I don't see how what I propose prevents that.

> I suppose a GFP_WAIT slab kernel page allocation could wakeup user space to
> perform user-assisted direct reclaim.  User space would then lower the user
> limit thereby causing the kernel to direct reclaim user pages, then
> the user daemon would raise the kernel limit allowing the slab allocation to
> succeed.  My hunch is that this would be prone to deadlocks (what prevents
> uswapd from needing more even more kmem?)  I'll defer to more
> experienced minds to know if user assisted direct memory reclaim has
> other pitfalls.  It scares me.

Good that it scares you, it should. OTOH, userspace being
able to set parameters to it, has nothing scary at all. A daemon in
userspace can detect that you need more kernel space memory , and
then - according to a policy you abide to - write to a file allowing
it more, or maybe not - according to that same policy. It is very
far away from "userspace driven reclaim".

> Fundamentally I have no problem putting an upper bound on a cgroup's resource
> usage.  This serves to contain the damage a job can do to the system and other
> jobs.  My concern is about limiting the kernel's ability to trade one type of
> memory for another by using different cgroups for different types of memory.
Yes, but limits have nothing to do with it.

>
> If kmem expands to include reclaimable kernel memory (e.g. dentry) then I
> presume the kernel would have no way to exchange unused user pages for dentry
> pages even if the user memory in the container is well below its limit.  This is
> motivation for the above user assisted direct reclaim.

Dentry is not always reclaimable. If it is pinned, it is non
reclaimable. Speaking of it, Would you take a look at
https://lkml.org/lkml/2011/8/14/110 ?

I am targetting dentry as well. But since it is hard to assign a
dentry to a process all the time, going through a different path. I
however, haven't entirely given up of doing it cgroups based, so any
ideas are welcome =)

> Do you feel the need to segregate user and kernel memory into different cgroups
> with independent limits?  Or is this this just a way to create a new clean
> cgroup with a simple purpose?

No, I don't necessarily feel that need. I just thought it was
cleaner to have entities with different purposes in different
cgroups. If moving it to the memory controller would help you in any
way, I can just do it. 80 % of this work is independent of where a
cgroup file lives.

> In some resource sharing shops customers purchase a certain amount of memory,
> cpu, network, etc.  Such customers don't define how the memory is used and the
> user/kernel mixture may change over time.  Can a user space reclaim daemon stay
> ahead of the workloads needs?

If you think solely about limits, you don't need to. The most
sane policy is actually "I don't care what is the kernel/user ratio,
as long as the kernel never grows over X Mb".

>> Using userspace CPU is no different from using kernel cpu in this particular
>> case. It is all overhead, regardless where it comes from. Moreover, you end
>> up setting up a policy, instead of a mechanism. What should be this
>> proportion?  Do we reclaim everything with the same frequency? Should we be
>> more tolerant with a specific container?
>
> I assume that this implies that a generic kmem cgroup usage is inferior to
> separate limits for each kernel memory type to allow user space the flexibility
> to choose between kernel types (udp vs tcp vs ext4 vs page_tables vs ...)?  Do
> you foresee a way to provide a limit on the total amount of kmem usage by all
> such types?  If a container wants to dedicate 4M for all network protocol
> buffers (tcp, udp, etc.) would that require a user space daemon to balance
> memory limits b/w the protocols?

Well, I am giving this an extra thought... Having separate knobs
adds flexibility, but - as usual - also complexity. For the goals I
have in mind, "kernel memory" would work just as fine.

If you look carefully at the other patches in the series besides
this one, you'll see that it is just a matter of billing from kernel
memory instead of tcp-memory, and then all the rest is the same.

Do you think that a single kernel-memory knob would be better for
your needs? I am willing to give it a try.
>> Also, If you want to allow any flexibility in this scheme, like: "Should
>> this network container be able to stress the network more, pinning more
>> memory, but not other subsystems?", you end up having to touch all
>> individual files anyway - probably with a userspace daemon.
>>
>> Also, as you noticed yourself, kernel memory is fundamentally different from
>> userspace memory. You can't just set reclaim limits, since you have no
>> guarantees it will work. User memory is not a scarce resource.
>> Kernel memory is.
>
> I agree that kernel memory is somewhat different.  In some (I argue most)
> situations containers want the ability to exchange job kmem and job umem.
> Either split or combined accounting protects the system and isolates other
> containers from kmem allocations of a bad job.  To me it seems natural to
> indicate that job X gets Y MB of memory.  I have more trouble dividing the
> Y MB of memory into dedicated slices for different types of memory.

I understand. And I don't think anyone doing containers
should be mandated to define a division. But a limit...
>>> While there are people (like me) who want a combined memory usage
>>> limit there are also people (like you) who want separate user and
>>> kernel limiting.
>>
>> Combined excludes separate. Separate does not exclude combined.
>
> I agree.  I have no problem with separate accounting and separate
> user-accessible pressure knobs to allow for complex policies.  My concern is
> about limiting the kernel's ability to reclaim one type of memory to
> fulfill the needs of another memory type (e.g. I think reclaiming clean file
> pages should be possible to make room for user slab needs).

I agree with your concern. It is definitely something we should not
do.

> I think
> memcg aware slab accounting does a good job of limiting a job's
> memory allocations.
> Would such slab accounting meet your needs?

Well, the slab alone, no. There are other objects - like tcp buffers
- that aren't covered by the slab. Others are usually shared among
many cgroups, and others don't really belong to anybody in
particular.igh

How do you think then, about turning this into 2 files inside memcg:

  - kernel_memory_hard_limit.
  - kernel_memory_soft_limit.

tcp memory would be the one defined in /proc, except if it is
greater than any of the limits. Instead of testing for memory
allocation against kmem.tcp_allocated_memory, we'd test it against
memcg.kmem_pinned_memory.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
