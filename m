Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 28EE1900155
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 01:03:37 -0400 (EDT)
Received: by yic24 with SMTP id 24so2994224yic.14
        for <linux-mm@kvack.org>; Sun, 11 Sep 2011 22:03:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E699341.9010606@parallels.com>
References: <1315276556-10970-1-git-send-email-glommer@parallels.com>
 <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com>
 <4E664766.40200@parallels.com> <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com>
 <4E66A0A9.3060403@parallels.com> <CAHH2K0aq4s1_H-yY0kA3LhM00CCNNbJZyvyBoDD6rHC+qo_gNg@mail.gmail.com>
 <4E68484A.4000201@parallels.com> <CAHH2K0YcXMUfd1Zr=f5a4=X9cPPp8NZiuichFXaOo=kVp5rRJA@mail.gmail.com>
 <4E699341.9010606@parallels.com>
From: Paul Menage <paul@paulmenage.org>
Date: Sun, 11 Sep 2011 22:03:14 -0700
Message-ID: <CALdu-PCrYPZx38o44ZyFrbQ6H39-vNPKey_Tpm4HRUNHNFMpyA@mail.gmail.com>
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Suleiman Souhlal <suleiman@google.com>

On Thu, Sep 8, 2011 at 9:17 PM, Glauber Costa <glommer@parallels.com> wrote=
:
> On 09/08/2011 06:53 PM, Greg Thelen wrote:
>>
>> On Wed, Sep 7, 2011 at 9:44 PM, Glauber Costa<glommer@parallels.com>
>> =A0wrote:
>>
>> Thanks for your ideas and patience.
>
> Likewise. It is turning out to be a very fruitful
> discussion.
>

This also got a fair bit of attention at LPC on Thursday - shame you
couldn't make it, but I hope you had no problems getting your visa!

I definitely think that there was no consensus reached on unified
versus split charging - but I think that we can work around that and
keep everyone happy, see below.

>
> Risking being a bit polemic here, I think that when we do
> containers, we have to view the kernel a little bit like a shared resourc=
e
> that is not accounted to anybody. It is easy to account things like tcp
> buffer, but who do you account page tables for shared pages to? Or pinned
> dentries for shared filesystems ?

I'd say that if filesystems (or page tables) are shared between
containers / cgroups, then it's fair to do first-touch accounting. But
if a filesystem is shared between multiple processes in just one
container / cgroup then it should definitely be charged to that cgroup
(which you get automatically with first-touch accounting).

It might be reasonable to also allow the sysadmin to request a more
expensive form of accounting (probably either charge-all or
equal-share), if the code to support that didn't interfere with the
performance of the normal first-touch charging mechanism, or
complicate the code too much.

On the subject of filesystems specifically, see Greg Thelen's proposal
for using bind mounts to account on a bind mount to a given cgroup -
that could apply to dentries, page tables and other kernel memory as
well as page cache.

> Good that it scares you, it should. OTOH, userspace being
> able to set parameters to it, has nothing scary at all. A daemon in
> userspace can detect that you need more kernel space memory , and
> then - according to a policy you abide to - write to a file allowing
> it more, or maybe not - according to that same policy. It is very
> far away from "userspace driven reclaim".

It can do that, but it's a bit messy when all userspace really wants
to do is say "limit the total to X GB".


> No, I don't necessarily feel that need. I just thought it was
> cleaner to have entities with different purposes in different
> cgroups. If moving it to the memory controller would help you in any
> way, I can just do it. 80 % of this work is independent of where a
> cgroup file lives.

My feeling is also that it's more appropriate for this to live in
memcg. While the ability to mount subsystems separately gives nice
flexibility, in the case of userspace versus kernel memory, I'm having
trouble envisaging a realistic situation where you'd want them mounted
on different hierarchies.

> =A0- kernel_memory_hard_limit.
> =A0- kernel_memory_soft_limit.
>
> tcp memory would be the one defined in /proc, except if it is
> greater than any of the limits. Instead of testing for memory
> allocation against kmem.tcp_allocated_memory, we'd test it against
> memcg.kmem_pinned_memory.
>

This is definitely an improvement, but I'd say it's not enough. I
think we should consider something like:

- a root cgroup file (memory.unified?) that controls whether memory
limits are unified or split.
- this file can only be modified when there are no memory cgroups
created (other than the root, which we shouldn't be charging, I think)
- the 'active' control determines whether (all) child cgroups will
have  memory.{limit,usage}_in_bytes files, or
memory.{kernel,user}_{limit,usage}_in_bytes files
- kernel memory will be charged either against 'kernel' or 'total'
depending on the value of unified
- userspace memory will be charged either against 'user' or 'total'

That way the kernel doesn't force a unified or split decision on
anyone, with I think zero performance hit and not much extra code.

You could even take this a step further. The following is probably
straying into the realm of overly-flexible, but I'll throw it into the
discussion anyway:

- define counters for various types of memory (e.g. total, user,
kernel, network, tcp, pagetables, dentries, etc)

- document what kind of memory is potentially charged against each
counter. (e.g. TCP buffers would be potentially charged against 'tcp',
'network', 'kernel' and 'total')

- have a memory.counters root cgroup file that allows the user to
specify which of the available counters are active. (only writeable
when no child cgroups, to avoid inconsistencies caused by changes
while memory is charged)

- default memory.counters to 'total'

- when memory.counters is updated, the memcg code builds the set of
targets for each chargeable entity. (e.g. if you enabled 'network' and
'total', then we'd update the charge_tcp array to contain something
like { &network_counter, &total_counter, NULL })

- charging for an object (TCP allocation, pagecache page, pagetable,
dentry, etc) just involves (trying to) charge all the counters set up
in that object's array. Since these arrays will be immutable once
child cgroups are being charged, they should be fairly well predicted.

This would give complete flexibility to userspace on the policy for
charging and reporting without incurring performance overhead for
systems that didn't care about some particular counter. (And without
complicating the code too much, I think).

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
