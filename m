Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 703509000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 03:34:11 -0400 (EDT)
Subject: Re: [PATCH 5/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 26 Sep 2011 09:33:40 +0200
In-Reply-To: <1316940890-24138-6-git-send-email-gilad@benyossef.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	 <1316940890-24138-6-git-send-email-gilad@benyossef.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317022420.9084.57.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Sun, 2011-09-25 at 11:54 +0300, Gilad Ben-Yossef wrote:
> +       if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {
> +               for_each_online_cpu(cpu) {
> +                       c =3D per_cpu_ptr(s->cpu_slab, cpu);
> +                       if (c && c->page)
> +                               cpumask_set_cpu(cpu, cpus);
> +               }
> +               on_each_cpu_mask(cpus, flush_cpu_slab, s, 1);
> +               free_cpumask_var(cpus);=20

Right, having to do that for_each_oneline_cpu() loop only to then IPI
them can cause a massive cacheline bounce fest.. Ideally you'd want to
keep a cpumask per kmem_cache, although I bet the memory overhead of
that isn't attractive.

Also, what Pekka says, having that alloc here isn't good either.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
