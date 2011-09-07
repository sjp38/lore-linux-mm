Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 14CF76B016C
	for <linux-mm@kvack.org>; Wed,  7 Sep 2011 17:36:00 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p87LZhV7023221
	for <linux-mm@kvack.org>; Wed, 7 Sep 2011 14:35:43 -0700
Received: from gwm11 (gwm11.prod.google.com [10.200.13.11])
	by hpaq13.eem.corp.google.com with ESMTP id p87LXTLZ018340
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 7 Sep 2011 14:35:42 -0700
Received: by gwm11 with SMTP id 11so122369gwm.30
        for <linux-mm@kvack.org>; Wed, 07 Sep 2011 14:35:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4E66A0A9.3060403@parallels.com>
References: <1315276556-10970-1-git-send-email-glommer@parallels.com>
 <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com>
 <4E664766.40200@parallels.com> <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com>
 <4E66A0A9.3060403@parallels.com>
From: Greg Thelen <gthelen@google.com>
Date: Wed, 7 Sep 2011 14:35:17 -0700
Message-ID: <CAHH2K0aq4s1_H-yY0kA3LhM00CCNNbJZyvyBoDD6rHC+qo_gNg@mail.gmail.com>
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Suleiman Souhlal <suleiman@google.com>

On Tue, Sep 6, 2011 at 3:37 PM, Glauber Costa <glommer@parallels.com> wrote=
:
> I think memcg's usage is really all you need here. In the end of the day,=
 it
> tells you how many pages your container has available. The whole
> point of kmem cgroup is not any kind of reservation or accounting.

The memcg does not reserve memory.  It provides upper bound limits on
memory usage.  A careful admin can configure soft_limit_in_bytes as an
approximation of a memory reservation.  But the soft limit is really
more like a reclaim target when there is global memory pressure.

> Once a container (or cgroup) reaches a number of objects *pinned* in memo=
ry
> (therefore, non-reclaimable), you won't be able to grab anything from it.
>
>> So
>> far my use cases involve a single memory limit which includes both
>> kernel and user memory. =A0So I would need a user space agent to poll
>> {memcg,kmem}.usage_in_bytes to apply pressure to memcg if kmem grows
>> and visa versa.
>
> Maybe not.
> If userspace memory works for you today (supposing it does), why change?

Good question.  Current upstream memcg user space memory limit does
not work for me today.  I should have made that more obvious (sorry).
See below for details.

> Right now you assign X bytes of user memory to a container, and the kerne=
l
> memory is shared among all of them. If this works for you, kmem_cgroup wo=
n't
> change that. It just will impose limits over which
> your kernel objects can't grow.
>
> So you don't *need* a userspace agent doing this calculation, because
> fundamentally, nothing changed: I am not unbilling memory in memcg to bil=
l
> it back in kmem_cg. Of course, once it is in, you will be able to do it i=
n
> such a fine grained fashion if you decide to do so.
>
>> Do you foresee instantiation of multiple kmem cgroups, so that a
>> process could be added into kmem/K1 or kmem/K2? =A0If so do you plan on
>> supporting migration between cgroups and/or migration of kmem charge
>> between K1 to K2?
>
> Yes, each container should have its own cgroup, so at least in the use
> cases I am concerned, we will have a lot of them. But the usual lifecycle=
,
> is create, execute and die. Mobility between them
> is not something I am overly concerned right now.
>
>
>>>> Do you foresee the kmem cgroup growing to include reclaimable slab,
>>>> where freeing one type of memory allows for reclaim of the other?
>>>
>>> Yes, absolutely.

Now I see that you're using kmem to limit the amount of unreclaimable
kernel memory.

We have a work-in-progress patch series that adds kernel memory accounting =
to
memcg.  These patches allow an admin to specify a single memory limit
for a cgroup which encompasses both user memory (as upstream memcg
does) and also includes many kernel memory allocations (especially
slab, page-tables).  When kernel memory grows it puts pressure on user
memory; when user memory grows it puts pressure on reclaimable kernel
memory using registered shrinkers.  We are in the process of cleaning
up these memcg slab accounting patches.

In my uses cases there is a single memory limit that applies to both
kernel and user memory.  If a separate kmem cgroup is introduced to
manage kernel memory outside of memcg with a distinct limit, then I
would need a user space daemon which balances memory between the kmem
and memcg subsystems.  As kmem grows, this daemon would apply pressure
to memcg, and as memcg grows pressure would be applied to kmem.  As
you stated kernel memory is not necessarily reclaimable.  So such
reclaim may fail.  My resistance to this approach is that with a
single memory cgroup admins can do a better job packing a machine.  If
balancing daemons are employed then more memory would need to be
reserved and more user space cpu time would be needed to apply VM
pressure between the types of memory.

While there are people (like me) who want a combined memory usage
limit there are also people (like you) who want separate user and
kernel limiting.  I have toyed with the idea of having a per cgroup
flag that determines if kernel and user memory should be combined
charged against a single limit or if they should have separate limits.
 I have also wondered if there was a way to wire the usage of two
subsystems together, then it would also meet meet my needs.  But I am
not sure how to do that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
