Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA206B0023
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 04:50:19 -0400 (EDT)
Received: by gyf3 with SMTP id 3so4524491gyf.14
        for <linux-mm@kvack.org>; Fri, 28 Oct 2011 01:50:17 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1110272257040.14619@router.home>
References: <1319385413-29665-1-git-send-email-gilad@benyossef.com>
	<1319385413-29665-6-git-send-email-gilad@benyossef.com>
	<alpine.DEB.2.00.1110272257040.14619@router.home>
Date: Fri, 28 Oct 2011 10:50:16 +0200
Message-ID: <CAOtvUMd3vWPfPFoLiZ7O1M1Ka1=py0p0Lx_G1PoH4bG2tfAJEQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/6] slub: Only IPI CPUs that have per cpu obj to flush
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>

On Fri, Oct 28, 2011 at 6:06 AM, Christoph Lameter <cl@gentwo.org> wrote:
> On Sun, 23 Oct 2011, Gilad Ben-Yossef wrote:
>
>> diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
>> index f58d641..b130f61 100644
>> --- a/include/linux/slub_def.h
>> +++ b/include/linux/slub_def.h
>> @@ -102,6 +102,9 @@ struct kmem_cache {
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 int remote_node_defrag_ratio;
>> =A0#endif
>> +
>> + =A0 =A0 /* Which CPUs hold local slabs for this cache. */
>> + =A0 =A0 cpumask_var_t cpus_with_slabs;
>> =A0 =A0 =A0 struct kmem_cache_node *node[MAX_NUMNODES];
>> =A0};
>
> Please do not add fields to structures for passing parameters to
> functions. This just increases the complexity of the patch and extends a
> structures needlessly.

The field was added to provide storage to cpus_with_slabs during
flush_all, since otherwise cpus_with_slabs, being a cpumask, would
require a kmem_cache allocation in the middle of flush_all  for
CONFIG_CPUMASK_OFF_STACK=3Dy case, which Pekka E. objected to.

The next patch in the series makes the field (and overhead) only added
for  CONFIG_CPUMASK_OFF_STACK=3Dy case but I wanted to break out the
addition to the patch core feature and the optimization of only adding
the field for CONFIG_CPUMASK_OFF_STACK=3Dy, so this patch as is without
the next one is only good for bisect value.

I should have probably have commented about it in the description of
this patch and not only in the next one. Sorry about that. I will fix
it for the next round.

>
>> diff --git a/mm/slub.c b/mm/slub.c
>> index 7c54fe8..f8cbf2d 100644
>> --- a/mm/slub.c
>> +++ b/mm/slub.c
>> @@ -1948,7 +1948,18 @@ static void flush_cpu_slab(void *d)
>>
>> =A0static void flush_all(struct kmem_cache *s)
>> =A0{
>> - =A0 =A0 on_each_cpu(flush_cpu_slab, s, 1);
>> + =A0 =A0 struct kmem_cache_cpu *c;
>> + =A0 =A0 int cpu;
>> +
>> + =A0 =A0 for_each_online_cpu(cpu) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 c =3D per_cpu_ptr(s->cpu_slab, cpu);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (c && c->page)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_set_cpu(cpu, s->cpus_w=
ith_slabs);
>> + =A0 =A0 =A0 =A0 =A0 =A0 else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_clear_cpu(cpu, s->cpus=
_with_slabs);
>> + =A0 =A0 }
>> +
>> + =A0 =A0 on_each_cpu_mask(s->cpus_with_slabs, flush_cpu_slab, s, 1);
>> =A0}
>
>
> You do not need s->cpus_with_slabs to be in kmem_cache. Make it a local
> variable instead.

That is what the next patch does - for CONFIG_CPUMASK_OFFSTACK=3Dn, alt lea=
st.

Thanks,
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
