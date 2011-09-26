Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4D78B9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 02:54:29 -0400 (EDT)
Received: by yxi19 with SMTP id 19so5447713yxi.14
        for <linux-mm@kvack.org>; Sun, 25 Sep 2011 23:54:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1316940890-24138-6-git-send-email-gilad@benyossef.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	<1316940890-24138-6-git-send-email-gilad@benyossef.com>
Date: Mon, 26 Sep 2011 09:54:27 +0300
Message-ID: <CAOJsxLEHHJyPnCngQceRW04PLKFa3RUQEbc3rLwiOPXa7XZNeQ@mail.gmail.com>
Subject: Re: [PATCH 5/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>

On Sun, Sep 25, 2011 at 11:54 AM, Gilad Ben-Yossef <gilad@benyossef.com> wr=
ote:
> Try to send IPI to flush per cpu objects back to free lists
> to CPUs to seems to have such objects.
>
> The check which CPU to IPI is racy but we don't care since
> asking a CPU without per cpu objects to flush does no
> damage and as far as I can tell the flush_all by itself is
> racy against allocs on remote CPUs anyway, so if you meant
> the flush_all to be determinstic, you had to arrange for
> locking regardless.
>
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> CC: Frederic Weisbecker <fweisbec@gmail.com>
> CC: Russell King <linux@arm.linux.org.uk>
> CC: Chris Metcalf <cmetcalf@tilera.com>
> CC: linux-mm@kvack.org
> CC: Christoph Lameter <cl@linux-foundation.org>
> CC: Pekka Enberg <penberg@kernel.org>
> CC: Matt Mackall <mpm@selenic.com>
> ---
> =A0mm/slub.c | =A0 15 ++++++++++++++-
> =A01 files changed, 14 insertions(+), 1 deletions(-)
>
> diff --git a/mm/slub.c b/mm/slub.c
> index 9f662d7..8baae30 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1948,7 +1948,20 @@ static void flush_cpu_slab(void *d)
>
> =A0static void flush_all(struct kmem_cache *s)
> =A0{
> - =A0 =A0 =A0 on_each_cpu(flush_cpu_slab, s, 1);
> + =A0 =A0 =A0 cpumask_var_t cpus;
> + =A0 =A0 =A0 struct kmem_cache_cpu *c;
> + =A0 =A0 =A0 int cpu;
> +
> + =A0 =A0 =A0 if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_online_cpu(cpu) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 c =3D per_cpu_ptr(s->cpu_sl=
ab, cpu);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (c && c->page)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_set=
_cpu(cpu, cpus);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 on_each_cpu_mask(cpus, flush_cpu_slab, s, 1=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_cpumask_var(cpus);
> + =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 on_each_cpu(flush_cpu_slab, s, 1);
> =A0}

AFAICT, flush_all() isn't all that performance sensitive. Why do we
want to reduce IPIs here? Also, I'm somewhat unhappy about introducing
memory allocations in memory shrinking code paths. If we really want
to do this, can we preallocate cpumask in struct kmem_cache, for
example?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
