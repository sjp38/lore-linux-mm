Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F2D746B00C6
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 02:52:49 -0500 (EST)
Received: by ywm14 with SMTP id 14so261633ywm.14
        for <linux-mm@kvack.org>; Tue, 22 Nov 2011 23:52:48 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAOJsxLFJimmLDev2UjgTYam37zv90gWGnKTPvjKOBre4_Uv81A@mail.gmail.com>
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
	<1321960128-15191-5-git-send-email-gilad@benyossef.com>
	<alpine.LFD.2.02.1111230822270.1773@tux.localdomain>
	<CAOJsxLFJimmLDev2UjgTYam37zv90gWGnKTPvjKOBre4_Uv81A@mail.gmail.com>
Date: Wed, 23 Nov 2011 09:52:47 +0200
Message-ID: <CAOtvUMfYw-QNCq+zXZZrZJaz-i--HSpeH_mdPgN7Bc0Z=u+TjQ@mail.gmail.com>
Subject: Re: [PATCH v4 4/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Nov 23, 2011 at 8:57 AM, Pekka Enberg <penberg@kernel.org> wrote:
> On Wed, Nov 23, 2011 at 8:23 AM, Pekka Enberg <penberg@kernel.org> wrote:
>> On Tue, 22 Nov 2011, Gilad Ben-Yossef wrote:
>>>
>>> static void flush_all(struct kmem_cache *s)
>>> {
>>> - =A0 =A0 =A0 on_each_cpu(flush_cpu_slab, s, 1);
>>> + =A0 =A0 =A0 cpumask_var_t cpus;
>>> + =A0 =A0 =A0 struct kmem_cache_cpu *c;
>>> + =A0 =A0 =A0 int cpu;
>>> +
>>> + =A0 =A0 =A0 if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {
>>
>> __GFP_NOWARN too maybe?
>>

Right, the allocation failure here is harmless. I should probably do
the same for the page_alloc.c case as well.

>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for_each_online_cpu(cpu) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 c =3D per_cpu_ptr(s->cpu_=
slab, cpu);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (c->page)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_s=
et_cpu(cpu, cpus);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 on_each_cpu_mask(cpus, flush_cpu_slab, s,=
 1);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_cpumask_var(cpus);
>>> + =A0 =A0 =A0 } else
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 on_each_cpu(flush_cpu_slab, s, 1);
>>> }
>>
>> Acked-by: Pekka Enberg <penberg@kernel.org>
>>
>> I can't take the patch because it depends on a new API introduced in the
>> first patch.
>>
>> I'm CC'ing Andrew.

Thanks!

There's a git tree of these over at: git://github.com/gby/linux.git
branch ipi_noise_v4 in case that helps.

I will send v5 (and create a new git branch for it) with the above
changes and the Arm patch  description update once I get an Ack from
Russel K.

Cheers,
Gilad

>



--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"Unfortunately, cache misses are an equal opportunity pain provider."
-- Mike Galbraith, LKML

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
