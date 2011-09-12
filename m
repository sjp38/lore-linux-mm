Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 8D64C900137
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 12:31:29 -0400 (EDT)
Message-ID: <4E6E33B1.6060806@parallels.com>
Date: Mon, 12 Sep 2011 13:30:41 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
References: <1315276556-10970-1-git-send-email-glommer@parallels.com> <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com> <4E664766.40200@parallels.com> <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com> <4E66A0A9.3060403@parallels.com> <CAHH2K0aq4s1_H-yY0kA3LhM00CCNNbJZyvyBoDD6rHC+qo_gNg@mail.gmail.com> <4E68484A.4000201@parallels.com> <CAHH2K0YcXMUfd1Zr=f5a4=X9cPPp8NZiuichFXaOo=kVp5rRJA@mail.gmail.com> <4E699341.9010606@parallels.com> <CAHH2K0YbmE_tt-LQSB=4L0oYc+CwNAjMQr0YViPn9=M-epST7A@mail.gmail.com>
In-Reply-To: <CAHH2K0YbmE_tt-LQSB=4L0oYc+CwNAjMQr0YViPn9=M-epST7A@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Suleiman Souhlal <suleiman@google.com>


>>> With some more knobs such a uswapd could
>>> attempt to keep ahead of demand.  But eventually direct reclaim would
>>> be needed to satisfy rapid growth spikes.  Example: If the 100M container
>>> starts with limits of 20M kmem and 80M user memory but later its kernel
>>> memory needs grow to 70M.  With separate user and kernel memory
>>> limits the kernel memory allocation could fail despite there being
>>> reclaimable user pages available.
>>
>> No no, this is a ratio, not a *limit*. A limit is something you
>> should not be allowed to go over. A good limit of kernel memory for
>> a 100 Mb container could be something like... 100 mb. But there is
>> more to that.
>>
>> Risking being a bit polemic here, I think that when we do
>> containers, we have to view the kernel a little bit like a shared resource
>> that is not accounted to anybody. It is easy to account things like tcp
>> buffer, but who do you account page tables for shared pages to? Or pinned
>> dentries for shared filesystems ?
>
> This is a tough challenge.  If you don't account page tables, then
> fork bombs can grab lots of kernel memory.  Containing such pigs is
> good.  We are working on some patches that charge page tables to the
> memcg they are allocated from.  This charge is checked against the
> memcg's limit and thus the page table allocation may fail due if over
> limit.
>
> I suggest charging dentries to the cgroup that allocated the dentry.
> If containers are used for isolation, then it seems that containers
> should typically not share files.  That would break isolation.  Of
> course there are shared files (/bin/bash, etc), but at least those are
> read-only.

You mean first allocated ? I actually considered that a while ago.
Specially with page tables, to whom do you account shared ptes ?
If we're doing first allocated, one way to fork bomb then, although 
clearly harder, is to have a cgroup mapping ptes that were already 
mapped before by other cgroups. A part of them is trivial to guess,
some others can be guessed more cleverly by the type of workload
you expect other containers in the box to be running.

This way you map a lot, and nothing is charged to you.
With dentries, first allocated might be possible if you assume files
are not shared, indeed... there are some shared use cases for exported 
directories... humm, but  maybe there are ways to contain those cases
as well.

>
>> Being the shared table under everybody, the kernel is more or less
>> like buffers inside a physical hdd, or cache lines. You know it is
>> there, you know it has a size, but provided you have some sane
>> protections, you don't really care - because in most cases you can't
>> - who is using it.
>
> I agree that it makes sense to not bother charging fixed sized
> resources (struct page, etc.) to containers; they are part of the
> platform.  But the set of resources that a process can allocate are
> ideally charged to a cgroup to limit container memory usage (i.e.
> prevent DoS attacks, isolate performance).
>
Agreed.

>>> The job should have a way to
>>> transition to memory limits to 70M+ kernel and 30M- of user.
>>
>> Yes, and I don't see how what I propose prevents that.
>
> I don't think your current proposal prevents that.  I was thinking
> about the future of the proposed kmem cgroup.  I want to make sure the
> kernel has a way to apply reclaim pressure bidirectionally between
> cgroup kernel memory and cgroup user memory.

I see.

>>> If kmem expands to include reclaimable kernel memory (e.g. dentry) then I
>>> presume the kernel would have no way to exchange unused user pages for
>>> dentry
>>> pages even if the user memory in the container is well below its limit.
>>>   This is
>>> motivation for the above user assisted direct reclaim.
>>
>> Dentry is not always reclaimable. If it is pinned, it is non
>> reclaimable. Speaking of it, Would you take a look at
>> https://lkml.org/lkml/2011/8/14/110 ?
>>
>> I am targetting dentry as well. But since it is hard to assign a
>> dentry to a process all the time, going through a different path. I
>> however, haven't entirely given up of doing it cgroups based, so any
>> ideas are welcome =)
>
> My hope is that dentry consumption can be effectively limited by
> limiting the memory needed to allocate the dentries.  IOW: with a
> memcg aware slab allocator which, when possible, charges the calling
> process' cgroup.

If you have patches for that, even early patches, I'd like to take a 
look at them.

>> Well, I am giving this an extra thought... Having separate knobs
>> adds flexibility, but - as usual - also complexity. For the goals I
>> have in mind, "kernel memory" would work just as fine.
>>
>> If you look carefully at the other patches in the series besides
>> this one, you'll see that it is just a matter of billing from kernel
>> memory instead of tcp-memory, and then all the rest is the same.
>>
>> Do you think that a single kernel-memory knob would be better for
>> your needs? I am willing to give it a try.
>
> Regarding the tcp buffers we're discussing, how does an application
> consume lots of buffer memory?  IOW, what would a malicious app do to
> cause a grows of tcp buffer usage?  Or is this the kind of resource
> that is difficult to directly exploit?
>
> Also, how does the pressure get applied.  I see you have a
> per-protocol, per-cgroup pressure pressure setting.  Once set, how
> does this pressure cause memory to be freed?  It looks like the
> pressure is set when allocating memory and later when packets are
> freed the associated memory _might_ be freed if pressure was
> previously detected.  Did I get this right?

See below:

> For me the primary concern is that both user and kernel memory are
> eventually charged to the same counter with an associated limit.
> Per-container memory pressure is based on this composite limit.  So I
> don't have a strong opinion as to how many kernel memory counters
> there are so long as they also feed into container memory usage
> counter.

Okay.

>
>>> I think
>>> memcg aware slab accounting does a good job of limiting a job's
>>> memory allocations.
>>> Would such slab accounting meet your needs?
>>
>> Well, the slab alone, no. There are other objects - like tcp buffers
>> - that aren't covered by the slab. Others are usually shared among
>> many cgroups, and others don't really belong to anybody in
>> particular.igh
>
> Sorry, I am dumb wrt. networking.  I thought that these tcp buffers
> were allocated using slab with __alloc_skb().  Are they done in
> container process context or arbitrary context?

You are right. They come from the slab with alloc_skb. But consider the 
following code, from tcp.c:

         skb = alloc_skb_fclone(size + sk->sk_prot->max_header, gfp);
         if (skb) {
                 if (sk_wmem_schedule(sk, skb->truesize)) {
                         /*
                          * Make sure that we have exactly size bytes
                          * available to the caller, no more, no less.
                          */
                         skb_reserve(skb, skb_tailroom(skb) - size);
                         return skb;
                 }
                 __kfree_skb(skb);
         } else {
		...
	}

Limiting the slab may be enough to prevent kernel memory abuse (sorry, I 
should have made this clear from the start). However, if the allocation 
succeed, a container can then kfree it, because someone else
is starving the network.

Of course, my patchset also limits kernel memory usage. But I agree that 
if we do slab accounting, only the network specific part remains.

>> How do you think then, about turning this into 2 files inside memcg:
>>
>>   - kernel_memory_hard_limit.
>>   - kernel_memory_soft_limit.
>>
>> tcp memory would be the one defined in /proc, except if it is
>> greater than any of the limits. Instead of testing for memory
>> allocation against kmem.tcp_allocated_memory, we'd test it against
>> memcg.kmem_pinned_memory.
>
> memcg control files currently include:
>    memory.limit_in_bytes
>    memory.soft_limit_in_bytes
>    memory.usage_in_bytes
>
> If you want a kernel memory limit, then we can introduce two new memcg APIs:
>    memory.kernel_limit_in_bytes
>    memory.kernel_soft_limit_in_bytes
>    memory.kernel_usage_in_bytes
>
> Any memory charged to memory.kernel_limit_in_bytes would also be
> charged to memory.limit_in_bytes.  IOW, memory.limit_in_bytes would
> include both user pages (as it does today) and some kernel pages.
>
> With these new files there are two cgroup memory limits: total and
> kernel.  The total limit is a combination of user and some kinds of
> kernel memory.

Nice.

> Kernel page reclaim would occur if memory.kernel_usage_in_bytes
> exceeds memory.kernel_limit_in_bytes.  There would be no need to
> reclaim user pages in this situation.  If kernel usage exceeds
> kernel_soft_limit_in_bytes, then the protocol pressure flags would be
> set.

SGTM. ATLAIJI as well.

> Memcg-wide page reclaim would occur if memory.usage_in_bytes exceeds
> memory.limit_in_bytes.  This reclaim would consider either container
> kernel memory or user pages associated with the container.
>
> This would be a behavioral memcg change which would need to be
> carefully considered.  Today the limit_in_bytes is just a user byte
> count that does not include kernel memory.

This makes me wonder that maybe I should just add a tcp-specific file to 
memcg (so all memory-related information goes in the same place), but
not account this memory as kernel memory. When you have slab-aware 
memcg, let it handle the accounting.

Alternatively, I could start doing basic accounting to pave the way, and 
later on this accounting is removing in favor or the slab-based
one.

What do you think ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
