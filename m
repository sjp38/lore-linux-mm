Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id DFA976B004A
	for <linux-mm@kvack.org>; Wed, 22 Feb 2012 15:32:04 -0500 (EST)
Received: by qadz32 with SMTP id z32so6721202qad.14
        for <linux-mm@kvack.org>; Wed, 22 Feb 2012 12:32:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F44F4A2.7010902@parallels.com>
References: <1329824079-14449-1-git-send-email-glommer@parallels.com>
	<CABCjUKCwLTOFOYR7E6v_z5=tUCUKch7TTMpAOrhQ_JKT1sqTqA@mail.gmail.com>
	<4F44F4A2.7010902@parallels.com>
Date: Wed, 22 Feb 2012 12:32:03 -0800
Message-ID: <CABCjUKBf1T=ccwz9xNY84y5Kizyx0sD+8Vh0ro-jtrdMgD-SNw@mail.gmail.com>
Subject: Re: [PATCH 0/7] memcg kernel memory tracking
From: Suleiman Souhlal <suleiman@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org

On Wed, Feb 22, 2012 at 5:58 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
>>> As previously proposed, one has the option of keeping kernel memory
>>> accounted separatedly, or together with the normal userspace memory.
>>> However, this time I made the option to, in this later case, bill
>>> the memory directly to memcg->res. It has the disadvantage that it
>>> becomes
>>> complicated to know which memory came from user or kernel, but OTOH,
>>> it does not create any overhead of drawing from multiple res_counters
>>> at read time. (and if you want them to be joined, you probably don't
>>> care)
>>
>>
>> It would be nice to still keep a kernel memory counter (that gets
>> updated at the same time as memcg->res) even when the limits are not
>> independent, because sometimes it's important to know how much kernel
>> memory is being used by a cgroup.
>
>
> Can you clarify in this "sometimes" ? The way I see it, we either always =
use
> two counters - as did in my original proposal - or use a single counter f=
or
> this case. Keeping a separated counter and still billing to the user memo=
ry
> is the worst of both worlds to me, since you get the performance hit of
> updating two resource counters.

By "sometimes", I mean pretty much any time we have to debug why a
cgroup is out of memory.
If there is no counter for how much kernel memory is used, it's pretty
much impossible to determine why the cgroup is full.

As for the performance, I do not think it is bad, as the accounting is
done in the slow path of slab allocation, when we allocate/free pages.

>
>
>>> Kernel memory is never tracked for the root memory cgroup. This means
>>> that a system where no memory cgroups exists other than the root, the
>>> time cost of this implementation is a couple of branches in the slub
>>> code - none of them in fast paths. At the moment, this works only
>>> with the slub.
>>>
>>> At cgroup destruction, memory is billed to the parent. With no hierarch=
y,
>>> this would mean the root memcg. But since we are not billing to that,
>>> it simply ceases to be tracked.
>>>
>>> The caches that we want to be tracked need to explicit register into
>>> the infrastructure.
>>
>>
>> Why not track every cache unless otherwise specified? If you don't,
>> you might end up polluting code all around the kernel to create
>> per-cgroup caches.
>> =A0From what I've seen, there are a fair amount of different caches that
>> can end up using a significant amount of memory, and having to go
>> around and explicitly mark each one doesn't seem like the right thing
>> to do.
>>
> The registration code is quite simple, so I don't agree this is polluting
> code all around the kernel. It is just a couple of lines.
>
> Of course, in an opt-out system, this count would be zero. So is it bette=
r?
>
> Let's divide the caches in two groups: Ones that use shrinkers, and simpl=
e
> ones that won't do. I am assuming most of the ones we need to track use
> shrinkers somehow.
>
> So if they do use a shrinker, it is very unlikely that the normal shrinke=
rs
> will work without being memcg-aware. We then end up in a scenario in whic=
h
> we track memory, we create a bunch of new caches, but we can't really for=
ce
> reclaim on that cache. We then depend on luck to have the objects reclaim=
ed
> from the root shrinker. Note that this is a problem that did not exist
> before: a dcache shrinker would shrink dcache objects and that's it, but =
we
> didn't have more than one cache with those objects.
>
> So in this context, registering a cache explicitly is better IMHO, becaus=
e
> what you are doing is telling: "I examined this cache, and I believe it w=
ill
> work okay with the memcg. It either does not need changes to the shrinker=
,
> or I made them already"
>
> Also, everytime we create a new cache, we're wasting some memory, as we
> duplicate state. That is fine, since we're doing this to prevent the usag=
e
> to explode.
>
> But I am not sure it pays of in a lot of caches, even if they use a lot o=
f
> pages: Like, quickly scanning slabinfo:
>
> task_struct =A0 =A0 =A0 =A0 =A0512 =A0 =A0570 =A0 5920 =A0 =A05 =A0 =A08 =
: tunables =A0 =A00 =A0 =A00 =A00 :
> slabdata =A0 =A0114 =A0 =A0114 =A0 =A0 =A00
>
> Can only grow if # of processes grow. Likely to hit a limit on that first=
.
>
> Acpi-Namespace =A0 =A0 =A04348 =A0 5304 =A0 =A0 40 =A0102 =A0 =A01 : tuna=
bles =A0 =A00 =A0 =A00 =A00 :
> slabdata =A0 =A0 52 =A0 =A0 52 =A0 =A0 =A00
>
> I doubt we can take down a sane system by using this cache...
>
> and so on and so forth.
>
> What do you think?

Well, we've seen several slabs that don't have shrinkers use
significant amounts of memory. For example, size-64, size-32,
vm_area_struct, buffer_head, radix_tree_node, TCP, filp..

For example, consider this perl program (with high enough file
descriptor limits):
use POSIX; use Socket; my $i; for ($i =3D 0; $i < 100000; $i++) {
socket($i, PF_INET, SOCK_STREAM, 0) || die "socket: $!"; }

One can make other simple programs like this that use significant
amounts of slab memory.

Having to look at a running kernel, having to find out which caches
are significant, and then going back and marking them for accounting,
really doesn't seem the right approach to me.

-- Suleiman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
