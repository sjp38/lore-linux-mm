Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id AFF599000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 04:35:34 -0400 (EDT)
Received: by gya6 with SMTP id 6so5346403gya.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 01:35:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1317022420.9084.57.camel@twins>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	<1316940890-24138-6-git-send-email-gilad@benyossef.com>
	<1317022420.9084.57.camel@twins>
Date: Mon, 26 Sep 2011 11:35:21 +0300
Message-ID: <CAOtvUMeMsd0Jk1k4wP9Y+7NW3FYZZAqV1-cRj5Zt4+eaugWoPg@mail.gmail.com>
Subject: Re: [PATCH 5/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Mon, Sep 26, 2011 at 10:33 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> w=
rote:
> On Sun, 2011-09-25 at 11:54 +0300, Gilad Ben-Yossef wrote:
>> + =A0 =A0 =A0 if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_online_cpu(cpu) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 c =3D per_cpu_ptr(s->cpu_s=
lab, cpu);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (c && c->page)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_se=
t_cpu(cpu, cpus);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 on_each_cpu_mask(cpus, flush_cpu_slab, s, =
1);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_cpumask_var(cpus);
>
> Right, having to do that for_each_oneline_cpu() loop only to then IPI
> them can cause a massive cacheline bounce fest.. Ideally you'd want to
> keep a cpumask per kmem_cache, although I bet the memory overhead of
> that isn't attractive.
>
> Also, what Pekka says, having that alloc here isn't good either.

Yes, the alloc in the flush_all path definitively needs to go. I
wonder if just to resolve that allocating the mask per cpu and not in
kmem_cache itself is not better - after all, all we need is a single
mask per cpu when we wish to do a flush_all and no per cache. The
memory overhead of that is slightly better. This doesn't cover the
cahce bounce issue.

My thoughts regarding that were that since the flush_all() was a
rather rare operation it is preferable to do some more
work/interference here, if it allows us to avoid having to do more
work in the hotter alloc/dealloc paths, especially since it allows us
to have less IPIs that I figured are more intrusive then cacheline
steals (are they?)

After all, for each CPU that actually needs to do a flush, we are
making the flush a bit more expensive because of the cache bounce just
before we send the IPI, but that IPI and further operations are an
expensive operations anyway. For CPUs that don't need to do a flush, I
replaced an IPI for a cacheline(s) steal. I figured it was still a
good bargain

I will spin a new patch that moves this to kmem_cache if you believe
this is the right way to go.

Thanks!
Gilad


--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"I've seen things you people wouldn't believe. Goto statements used to
implement co-routines. I watched C structures being stored in
registers. All those moments will be lost in time... like tears in
rain... Time to die. "

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
