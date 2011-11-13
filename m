Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 382F56B002D
	for <linux-mm@kvack.org>; Sun, 13 Nov 2011 07:20:18 -0500 (EST)
Received: by wwf10 with SMTP id 10so3814358wwf.26
        for <linux-mm@kvack.org>; Sun, 13 Nov 2011 04:20:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1321179449-6675-5-git-send-email-gilad@benyossef.com>
References: <1321179449-6675-1-git-send-email-gilad@benyossef.com>
	<1321179449-6675-5-git-send-email-gilad@benyossef.com>
Date: Sun, 13 Nov 2011 20:20:12 +0800
Message-ID: <CAJd=RBC0eTkjF8CSKXv-SK5Zef1G+9x-FUYRBXKmVg6Gbno5gw@mail.gmail.com>
Subject: Re: [PATCH v3 4/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On Sun, Nov 13, 2011 at 6:17 PM, Gilad Ben-Yossef <gilad@benyossef.com> wro=
te:
> flush_all() is called for each kmem_cahce_destroy(). So every cache
> being destroyed dynamically ended up sending an IPI to each CPU in the
> system, regardless if the cache has ever been used there.
>
> For example, if you close the Infinband ipath driver char device file,
> the close file ops calls kmem_cache_destroy(). So running some
> infiniband config tool on one a single CPU dedicated to system tasks
> might interrupt the rest of the 127 CPUs I dedicated to some CPU
> intensive task.
>
> I suspect there is a good chance that every line in the output of "git
> grep kmem_cache_destroy linux/ | grep '\->'" has a similar scenario.
>
> This patch attempts to rectify this issue by sending an IPI to flush
> the per cpu objects back to the free lists only to CPUs that seems to
> have such objects.
>
> The check which CPU to IPI is racy but we don't care since asking a
> CPU without per cpu objects to flush does no damage and as far as I
> can tell the flush_all by itself is racy against allocs on remote
> CPUs anyway, so if you meant the flush_all to be determinstic, you
> had to arrange for locking regardless.
>
> Without this patch the following artificial test case:
>
> $ cd /sys/kernel/slab
> $ for DIR in *; do cat $DIR/alloc_calls > /dev/null; done
>
> produces 166 IPIs on an cpuset isolated CPU. With it it produces none.
>
> The code path of memory allocation failure for CPUMASK_OFFSTACK=3Dy
> config was tested using fault injection framework.
>
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> Acked-by: Chris Metcalf <cmetcalf@tilera.com>
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: Frederic Weisbecker <fweisbec@gmail.com>
> CC: Russell King <linux@arm.linux.org.uk>
> CC: linux-mm@kvack.org
> CC: Christoph Lameter <cl@linux-foundation.org>
> CC: Pekka Enberg <penberg@kernel.org>
> CC: Matt Mackall <mpm@selenic.com>
> CC: Sasha Levin <levinsasha928@gmail.com>
> CC: Rik van Riel <riel@redhat.com>
> CC: Andi Kleen <andi@firstfloor.org>
> ---
> =C2=A0mm/slub.c | =C2=A0 15 ++++++++++++++-
> =C2=A01 files changed, 14 insertions(+), 1 deletions(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 7d2a996..caf4b3a 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -2006,7 +2006,20 @@ static void flush_cpu_slab(void *d)
>
> =C2=A0static void flush_all(struct kmem_cache *s)
> =C2=A0{
> - =C2=A0 =C2=A0 =C2=A0 on_each_cpu(flush_cpu_slab, s, 1);
> + =C2=A0 =C2=A0 =C2=A0 cpumask_var_t cpus;
> + =C2=A0 =C2=A0 =C2=A0 struct kmem_cache_cpu *c;
> + =C2=A0 =C2=A0 =C2=A0 int cpu;
> +
> + =C2=A0 =C2=A0 =C2=A0 if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC)))=
 {

Perhaps, the technique of local_cpu_mask defined in kernel/sched_rt.c
could be used to replace the above atomic allocation.

Best regards

Hillf

> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 for_each_online_cpu(cp=
u) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 c =3D per_cpu_ptr(s->cpu_slab, cpu);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 if (c && c->page)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cpumask_set_cpu(cpu, cpus);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 on_each_cpu_mask(cpus,=
 flush_cpu_slab, s, 1);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 free_cpumask_var(cpus)=
;
> + =C2=A0 =C2=A0 =C2=A0 } else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 on_each_cpu(flush_cpu_=
slab, s, 1);
> =C2=A0}
>
> =C2=A0/*
> --
> 1.7.0.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =C2=A0http://www.tux.org/lkml/
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
