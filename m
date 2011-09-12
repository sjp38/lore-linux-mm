Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1E76D900137
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 13:04:00 -0400 (EDT)
Message-ID: <4E6E39DD.2040102@parallels.com>
Date: Mon, 12 Sep 2011 13:57:01 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
References: <1315276556-10970-1-git-send-email-glommer@parallels.com> <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com> <4E664766.40200@parallels.com> <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com> <4E66A0A9.3060403@parallels.com> <CAHH2K0aq4s1_H-yY0kA3LhM00CCNNbJZyvyBoDD6rHC+qo_gNg@mail.gmail.com> <4E68484A.4000201@parallels.com> <CAHH2K0YcXMUfd1Zr=f5a4=X9cPPp8NZiuichFXaOo=kVp5rRJA@mail.gmail.com> <4E699341.9010606@parallels.com> <CALdu-PCrYPZx38o44ZyFrbQ6H39-vNPKey_Tpm4HRUNHNFMpyA@mail.gmail.com>
In-Reply-To: <CALdu-PCrYPZx38o44ZyFrbQ6H39-vNPKey_Tpm4HRUNHNFMpyA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menage <paul@paulmenage.org>
Cc: Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Suleiman Souhlal <suleiman@google.com>, Lennart Poettering <lennart@poettering.net>

On 09/12/2011 02:03 AM, Paul Menage wrote:
> On Thu, Sep 8, 2011 at 9:17 PM, Glauber Costa<glommer@parallels.com>  wrote:
>> On 09/08/2011 06:53 PM, Greg Thelen wrote:
>>>
>>> On Wed, Sep 7, 2011 at 9:44 PM, Glauber Costa<glommer@parallels.com>
>>>   wrote:
>>>
>>> Thanks for your ideas and patience.
>>
>> Likewise. It is turning out to be a very fruitful
>> discussion.
>>
>
> This also got a fair bit of attention at LPC on Thursday - shame you
> couldn't make it, but I hope you had no problems getting your visa!

Apart from the trip to the nearest consulate and 4 hours in a line, no 
problems =) I can now legally enter the United States - so wait for me 
next time!

>
> I definitely think that there was no consensus reached on unified
> versus split charging - but I think that we can work around that and
> keep everyone happy, see below.

I think at this point there is at least consensus that this could very 
well live in memcg, right ?
>
>>
>> Risking being a bit polemic here, I think that when we do
>> containers, we have to view the kernel a little bit like a shared resource
>> that is not accounted to anybody. It is easy to account things like tcp
>> buffer, but who do you account page tables for shared pages to? Or pinned
>> dentries for shared filesystems ?
>
> I'd say that if filesystems (or page tables) are shared between
> containers / cgroups, then it's fair to do first-touch accounting. But
> if a filesystem is shared between multiple processes in just one
> container / cgroup then it should definitely be charged to that cgroup
> (which you get automatically with first-touch accounting).
>
> It might be reasonable to also allow the sysadmin to request a more
> expensive form of accounting (probably either charge-all or
> equal-share), if the code to support that didn't interfere with the
> performance of the normal first-touch charging mechanism, or
> complicate the code too much.

I personally think equal share is a nightmare. But charge-all for shared 
resources is quite acceptable even as a default if people are not 
heavily concerned about precise accounting, in the sense that all 
containers should sum up to one (well, I am not)

> On the subject of filesystems specifically, see Greg Thelen's proposal
> for using bind mounts to account on a bind mount to a given cgroup -
> that could apply to dentries, page tables and other kernel memory as
> well as page cache.

Care to point me to it ?

>> Good that it scares you, it should. OTOH, userspace being
>> able to set parameters to it, has nothing scary at all. A daemon in
>> userspace can detect that you need more kernel space memory , and
>> then - according to a policy you abide to - write to a file allowing
>> it more, or maybe not - according to that same policy. It is very
>> far away from "userspace driven reclaim".
>
> It can do that, but it's a bit messy when all userspace really wants
> to do is say "limit the total to X GB".
>
>
>> No, I don't necessarily feel that need. I just thought it was
>> cleaner to have entities with different purposes in different
>> cgroups. If moving it to the memory controller would help you in any
>> way, I can just do it. 80 % of this work is independent of where a
>> cgroup file lives.
>
> My feeling is also that it's more appropriate for this to live in
> memcg. While the ability to mount subsystems separately gives nice
> flexibility, in the case of userspace versus kernel memory, I'm having
> trouble envisaging a realistic situation where you'd want them mounted
> on different hierarchies.

Right.
>>   - kernel_memory_hard_limit.
>>   - kernel_memory_soft_limit.
>>
>> tcp memory would be the one defined in /proc, except if it is
>> greater than any of the limits. Instead of testing for memory
>> allocation against kmem.tcp_allocated_memory, we'd test it against
>> memcg.kmem_pinned_memory.
>>
>
> This is definitely an improvement, but I'd say it's not enough. I
> think we should consider something like:
One step at a time =)

>
> - a root cgroup file (memory.unified?) that controls whether memory
> limits are unified or split.
> - this file can only be modified when there are no memory cgroups
> created (other than the root, which we shouldn't be charging, I think)

Okay.

> - the 'active' control determines whether (all) child cgroups will
> have  memory.{limit,usage}_in_bytes files, or
> memory.{kernel,user}_{limit,usage}_in_bytes files
> - kernel memory will be charged either against 'kernel' or 'total'
> depending on the value of unified

You mean for display/pressure purposes, right? Internally, I think once 
we have kernel memory, we always charge it to kernel memory, regardless 
of anything else. The value in unified field will only take place when 
we need to grab this value.

I don't personally see a reason for not having all files present at all 
times.

> - userspace memory will be charged either against 'user' or 'total'
>
> That way the kernel doesn't force a unified or split decision on
> anyone, with I think zero performance hit and not much extra code.

Yes, I think not forcing it is not only an interesting way of settling 
this, but also an interesting feature.

> You could even take this a step further. The following is probably
> straying into the realm of overly-flexible, but I'll throw it into the
> discussion anyway:
>
> - define counters for various types of memory (e.g. total, user,
> kernel, network, tcp, pagetables, dentries, etc)

Hummm, I like it, but I also fear that in the future we'll hit some 
resource whose origin is hard to track... /me trying to think of such
potential monster...

It is overly flexible if we're exposing these counters and expecting the 
user to do anything with them. It is perfectly fine if a single file, 
when read, displays this information as statistics.


> - document what kind of memory is potentially charged against each
> counter. (e.g. TCP buffers would be potentially charged against 'tcp',
> 'network', 'kernel' and 'total')

That, I think, is overly flexible. I think what I said above makes sense 
for very well defined entities such the slab. If we have something that 
can be accounted to more to one general (kernel/user) and one specific 
(slab) entity, we're getting too complex.

> - have a memory.counters root cgroup file that allows the user to
> specify which of the available counters are active. (only writeable
> when no child cgroups, to avoid inconsistencies caused by changes
> while memory is charged)
>
> - default memory.counters to 'total'
>
> - when memory.counters is updated, the memcg code builds the set of
> targets for each chargeable entity. (e.g. if you enabled 'network' and
> 'total', then we'd update the charge_tcp array to contain something
> like {&network_counter,&total_counter, NULL })
>
> - charging for an object (TCP allocation, pagecache page, pagetable,
> dentry, etc) just involves (trying to) charge all the counters set up
> in that object's array. Since these arrays will be immutable once
> child cgroups are being charged, they should be fairly well predicted.
>
> This would give complete flexibility to userspace on the policy for
> charging and reporting without incurring performance overhead for
> systems that didn't care about some particular counter. (And without
> complicating the code too much, I think).

While I do think it is overly complicated, I think that a sound use case 
for this would bring it to the "complicated" realm only. It sounds like 
a nice feature if there are users for it.

Not only for containers - that tend to be generic in most cases - but 
maybe people enclosing services in isolated cgroups can come up with 
profiles that will, for instance, disallow or allow very little disk 
activity on a network-profiled cgroup and vice versa.

I am adding Lennart to this discussion, since if there is anyone crazy 
enough to come up with an interesting use case for something strange, 
it'll be systemd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
