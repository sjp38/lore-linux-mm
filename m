Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 1BF9C6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 13:18:24 -0500 (EST)
Received: by qcsd16 with SMTP id d16so34783qcs.14
        for <linux-mm@kvack.org>; Thu, 23 Feb 2012 10:18:23 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1329824079-14449-1-git-send-email-glommer@parallels.com>
References: <1329824079-14449-1-git-send-email-glommer@parallels.com>
Date: Thu, 23 Feb 2012 10:18:22 -0800
Message-ID: <CALWz4izD0Ykx8YJWVoECk7jdBLTxSm1vXOjKfkAgUaUVv2FkJw@mail.gmail.com>
Subject: Re: [PATCH 0/7] memcg kernel memory tracking
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, devel@openvz.org, linux-mm@kvack.org

On Tue, Feb 21, 2012 at 3:34 AM, Glauber Costa <glommer@parallels.com> wrot=
e:
> This is a first structured approach to tracking general kernel
> memory within the memory controller. Please tell me what you think.
>
> As previously proposed, one has the option of keeping kernel memory
> accounted separatedly, or together with the normal userspace memory.
> However, this time I made the option to, in this later case, bill
> the memory directly to memcg->res. It has the disadvantage that it become=
s
> complicated to know which memory came from user or kernel, but OTOH,
> it does not create any overhead of drawing from multiple res_counters
> at read time. (and if you want them to be joined, you probably don't care=
)

Keeping one counter for user and kernel pages makes it easier for
admins to configure the system. About reporting, we should still
report the user and kernel memory separately. It will be extremely
useful when diagnosing the system like heavily memory pressure or OOM.

> Kernel memory is never tracked for the root memory cgroup. This means
> that a system where no memory cgroups exists other than the root, the
> time cost of this implementation is a couple of branches in the slub
> code - none of them in fast paths. At the moment, this works only
> with the slub.
>
> At cgroup destruction, memory is billed to the parent. With no hierarchy,
> this would mean the root memcg. But since we are not billing to that,
> it simply ceases to be tracked.
>
> The caches that we want to be tracked need to explicit register into
> the infrastructure.

It would be hard to let users to register which slab to track
explicitly. We should track them all in general, even with the ones
without shrinker, we want to understand how much is used by which
cgroup.

--Ying

>
> If you would like to give it a try, you'll need one of Frederic's patches
> that is used as a basis for this
> (cgroups: ability to stop res charge propagation on bounded ancestor)
>
> Glauber Costa (7):
> =A0small cleanup for memcontrol.c
> =A0Basic kernel memory functionality for the Memory Controller
> =A0per-cgroup slab caches
> =A0chained slab caches: move pages to a different cache when a cache is
> =A0 =A0destroyed.
> =A0shrink support for memcg kmem controller
> =A0track dcache per-memcg
> =A0example shrinker for memcg-aware dcache
>
> =A0fs/dcache.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0136 +++++++++++++++++-
> =A0include/linux/dcache.h =A0 =A0 | =A0 =A04 +
> =A0include/linux/memcontrol.h | =A0 35 +++++
> =A0include/linux/shrinker.h =A0 | =A0 =A04 +
> =A0include/linux/slab.h =A0 =A0 =A0 | =A0 12 ++
> =A0include/linux/slub_def.h =A0 | =A0 =A03 +
> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0| =A0344 ++++++++++++++++++++++=
+++++++++++++++++++++-
> =A0mm/slub.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0237 ++++++++++++++++=
++++++++++++---
> =A0mm/vmscan.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 60 ++++++++-
> =A09 files changed, 806 insertions(+), 29 deletions(-)
>
> --
> 1.7.7.6
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
