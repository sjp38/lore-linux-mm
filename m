Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 206B2900155
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 19:38:55 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id p89NcpF2003665
	for <linux-mm@kvack.org>; Fri, 9 Sep 2011 16:38:51 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by hpaq7.eem.corp.google.com with ESMTP id p89Nck0N027491
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 9 Sep 2011 16:38:50 -0700
Received: by pzk37 with SMTP id 37so3781198pzk.29
        for <linux-mm@kvack.org>; Fri, 09 Sep 2011 16:38:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E699341.9010606@parallels.com>
References: <1315276556-10970-1-git-send-email-glommer@parallels.com>
 <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com>
 <4E664766.40200@parallels.com> <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com>
 <4E66A0A9.3060403@parallels.com> <CAHH2K0aq4s1_H-yY0kA3LhM00CCNNbJZyvyBoDD6rHC+qo_gNg@mail.gmail.com>
 <4E68484A.4000201@parallels.com> <CAHH2K0YcXMUfd1Zr=f5a4=X9cPPp8NZiuichFXaOo=kVp5rRJA@mail.gmail.com>
 <4E699341.9010606@parallels.com>
From: Greg Thelen <gthelen@google.com>
Date: Fri, 9 Sep 2011 16:38:26 -0700
Message-ID: <CAHH2K0YbmE_tt-LQSB=4L0oYc+CwNAjMQr0YViPn9=M-epST7A@mail.gmail.com>
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Suleiman Souhlal <suleiman@google.com>

On Thu, Sep 8, 2011 at 9:17 PM, Glauber Costa <glommer@parallels.com> wrote=
:
> On 09/08/2011 06:53 PM, Greg Thelen wrote:
>>
>> If a container must fit within 100M, then a single limit solution
>> would set the limit to 100M and never change it. =A0In a split limit
>> solution a
>> user daemon (e.g. uswapd) would need to monitor the usage and the amount
>> of
>> active memory vs inactive user memory and unreferenced kernel memory to
>> determine where to apply pressure.
>
> Or it can just define some parameters and let the kernel do the
> rest. Like for instance, a maximum proportion allowed, a maximum
> proportion desired, etc.

Agreed.

>> With some more knobs such a uswapd could
>> attempt to keep ahead of demand. =A0But eventually direct reclaim would
>> be needed to satisfy rapid growth spikes. =A0Example: If the 100M contai=
ner
>> starts with limits of 20M kmem and 80M user memory but later its kernel
>> memory needs grow to 70M. =A0With separate user and kernel memory
>> limits the kernel memory allocation could fail despite there being
>> reclaimable user pages available.
>
> No no, this is a ratio, not a *limit*. A limit is something you
> should not be allowed to go over. A good limit of kernel memory for
> a 100 Mb container could be something like... 100 mb. But there is
> more to that.
>
> Risking being a bit polemic here, I think that when we do
> containers, we have to view the kernel a little bit like a shared resourc=
e
> that is not accounted to anybody. It is easy to account things like tcp
> buffer, but who do you account page tables for shared pages to? Or pinned
> dentries for shared filesystems ?

This is a tough challenge.  If you don't account page tables, then
fork bombs can grab lots of kernel memory.  Containing such pigs is
good.  We are working on some patches that charge page tables to the
memcg they are allocated from.  This charge is checked against the
memcg's limit and thus the page table allocation may fail due if over
limit.

I suggest charging dentries to the cgroup that allocated the dentry.
If containers are used for isolation, then it seems that containers
should typically not share files.  That would break isolation.  Of
course there are shared files (/bin/bash, etc), but at least those are
read-only.

> Being the shared table under everybody, the kernel is more or less
> like buffers inside a physical hdd, or cache lines. You know it is
> there, you know it has a size, but provided you have some sane
> protections, you don't really care - because in most cases you can't
> - who is using it.

I agree that it makes sense to not bother charging fixed sized
resources (struct page, etc.) to containers; they are part of the
platform.  But the set of resources that a process can allocate are
ideally charged to a cgroup to limit container memory usage (i.e.
prevent DoS attacks, isolate performance).

>> The job should have a way to
>> transition to memory limits to 70M+ kernel and 30M- of user.
>
> Yes, and I don't see how what I propose prevents that.

I don't think your current proposal prevents that.  I was thinking
about the future of the proposed kmem cgroup.  I want to make sure the
kernel has a way to apply reclaim pressure bidirectionally between
cgroup kernel memory and cgroup user memory.

>> I suppose a GFP_WAIT slab kernel page allocation could wakeup user space
>> to
>> perform user-assisted direct reclaim. =A0User space would then lower the
>> user
>> limit thereby causing the kernel to direct reclaim user pages, then
>> the user daemon would raise the kernel limit allowing the slab allocatio=
n
>> to
>> succeed. =A0My hunch is that this would be prone to deadlocks (what prev=
ents
>> uswapd from needing more even more kmem?) =A0I'll defer to more
>> experienced minds to know if user assisted direct memory reclaim has
>> other pitfalls. =A0It scares me.
>
> Good that it scares you, it should. OTOH, userspace being
> able to set parameters to it, has nothing scary at all. A daemon in
> userspace can detect that you need more kernel space memory , and
> then - according to a policy you abide to - write to a file allowing
> it more, or maybe not - according to that same policy. It is very
> far away from "userspace driven reclaim".

Agreed.  I have no problem with user space policy being used to
updating kernel control files that alter reclaim.

>> If kmem expands to include reclaimable kernel memory (e.g. dentry) then =
I
>> presume the kernel would have no way to exchange unused user pages for
>> dentry
>> pages even if the user memory in the container is well below its limit.
>> =A0This is
>> motivation for the above user assisted direct reclaim.
>
> Dentry is not always reclaimable. If it is pinned, it is non
> reclaimable. Speaking of it, Would you take a look at
> https://lkml.org/lkml/2011/8/14/110 ?
>
> I am targetting dentry as well. But since it is hard to assign a
> dentry to a process all the time, going through a different path. I
> however, haven't entirely given up of doing it cgroups based, so any
> ideas are welcome =3D)

My hope is that dentry consumption can be effectively limited by
limiting the memory needed to allocate the dentries.  IOW: with a
memcg aware slab allocator which, when possible, charges the calling
process' cgroup.

> Well, I am giving this an extra thought... Having separate knobs
> adds flexibility, but - as usual - also complexity. For the goals I
> have in mind, "kernel memory" would work just as fine.
>
> If you look carefully at the other patches in the series besides
> this one, you'll see that it is just a matter of billing from kernel
> memory instead of tcp-memory, and then all the rest is the same.
>
> Do you think that a single kernel-memory knob would be better for
> your needs? I am willing to give it a try.

Regarding the tcp buffers we're discussing, how does an application
consume lots of buffer memory?  IOW, what would a malicious app do to
cause a grows of tcp buffer usage?  Or is this the kind of resource
that is difficult to directly exploit?

Also, how does the pressure get applied.  I see you have a
per-protocol, per-cgroup pressure pressure setting.  Once set, how
does this pressure cause memory to be freed?  It looks like the
pressure is set when allocating memory and later when packets are
freed the associated memory _might_ be freed if pressure was
previously detected.  Did I get this right?

For me the primary concern is that both user and kernel memory are
eventually charged to the same counter with an associated limit.
Per-container memory pressure is based on this composite limit.  So I
don't have a strong opinion as to how many kernel memory counters
there are so long as they also feed into container memory usage
counter.

>> I agree that kernel memory is somewhat different. =A0In some (I argue mo=
st)
>> situations containers want the ability to exchange job kmem and job umem=
.
>> Either split or combined accounting protects the system and isolates oth=
er
>> containers from kmem allocations of a bad job. =A0To me it seems natural=
 to
>> indicate that job X gets Y MB of memory. =A0I have more trouble dividing=
 the
>> Y MB of memory into dedicated slices for different types of memory.
>
> I understand. And I don't think anyone doing containers
> should be mandated to define a division. But a limit...

SGTM, so long as it is an optional kernel memory limit (see below).

>> I think
>> memcg aware slab accounting does a good job of limiting a job's
>> memory allocations.
>> Would such slab accounting meet your needs?
>
> Well, the slab alone, no. There are other objects - like tcp buffers
> - that aren't covered by the slab. Others are usually shared among
> many cgroups, and others don't really belong to anybody in
> particular.igh

Sorry, I am dumb wrt. networking.  I thought that these tcp buffers
were allocated using slab with __alloc_skb().  Are they done in
container process context or arbitrary context?

> How do you think then, about turning this into 2 files inside memcg:
>
> =A0- kernel_memory_hard_limit.
> =A0- kernel_memory_soft_limit.
>
> tcp memory would be the one defined in /proc, except if it is
> greater than any of the limits. Instead of testing for memory
> allocation against kmem.tcp_allocated_memory, we'd test it against
> memcg.kmem_pinned_memory.

memcg control files currently include:
  memory.limit_in_bytes
  memory.soft_limit_in_bytes
  memory.usage_in_bytes

If you want a kernel memory limit, then we can introduce two new memcg APIs=
:
  memory.kernel_limit_in_bytes
  memory.kernel_soft_limit_in_bytes
  memory.kernel_usage_in_bytes

Any memory charged to memory.kernel_limit_in_bytes would also be
charged to memory.limit_in_bytes.  IOW, memory.limit_in_bytes would
include both user pages (as it does today) and some kernel pages.

With these new files there are two cgroup memory limits: total and
kernel.  The total limit is a combination of user and some kinds of
kernel memory.

Kernel page reclaim would occur if memory.kernel_usage_in_bytes
exceeds memory.kernel_limit_in_bytes.  There would be no need to
reclaim user pages in this situation.  If kernel usage exceeds
kernel_soft_limit_in_bytes, then the protocol pressure flags would be
set.

Memcg-wide page reclaim would occur if memory.usage_in_bytes exceeds
memory.limit_in_bytes.  This reclaim would consider either container
kernel memory or user pages associated with the container.

This would be a behavioral memcg change which would need to be
carefully considered.  Today the limit_in_bytes is just a user byte
count that does not include kernel memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
