Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 0192E6B004D
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 11:12:11 -0500 (EST)
Received: by vcge1 with SMTP id e1so14097669vcg.14
        for <linux-mm@kvack.org>; Sun, 01 Jan 2012 08:12:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F00547A.9090204@redhat.com>
References: <1321960128-15191-1-git-send-email-gilad@benyossef.com>
	<1321960128-15191-5-git-send-email-gilad@benyossef.com>
	<alpine.LFD.2.02.1111230822270.1773@tux.localdomain>
	<4F00547A.9090204@redhat.com>
Date: Sun, 1 Jan 2012 18:12:10 +0200
Message-ID: <CAOtvUMcCzK=tNkHudOrzxjdGkdkZPt02krO8QYRGjyXm+cvRSw@mail.gmail.com>
Subject: Re: [PATCH v4 4/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, apkm@linux-foundation.org

On Sun, Jan 1, 2012 at 2:41 PM, Avi Kivity <avi@redhat.com> wrote:
> On 11/23/2011 08:23 AM, Pekka Enberg wrote:
>> On Tue, 22 Nov 2011, Gilad Ben-Yossef wrote:
>>> static void flush_all(struct kmem_cache *s)
>>> {
>>> - =A0 =A0on_each_cpu(flush_cpu_slab, s, 1);
>>> + =A0 =A0cpumask_var_t cpus;
>>> + =A0 =A0struct kmem_cache_cpu *c;
>>> + =A0 =A0int cpu;
>>> +
>>> + =A0 =A0if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {
>>
>> __GFP_NOWARN too maybe?
>>
>>> + =A0 =A0 =A0 =A0for_each_online_cpu(cpu) {
>>> + =A0 =A0 =A0 =A0 =A0 =A0c =3D per_cpu_ptr(s->cpu_slab, cpu);
>>> + =A0 =A0 =A0 =A0 =A0 =A0if (c->page)
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cpumask_set_cpu(cpu, cpus);
>>> + =A0 =A0 =A0 =A0}
>>> + =A0 =A0 =A0 =A0on_each_cpu_mask(cpus, flush_cpu_slab, s, 1);
>>> + =A0 =A0 =A0 =A0free_cpumask_var(cpus);
>>> + =A0 =A0} else
>>> + =A0 =A0 =A0 =A0on_each_cpu(flush_cpu_slab, s, 1);
>>> }
>>
>
> Since this seems to be a common pattern, how about:
>
> =A0 zalloc_cpumask_var_or_all_online_cpus(&cpus, GFTP_ATOMIC);
> =A0 ...
> =A0 free_cpumask_var(cpus);
>
> The long-named function at the top of the block either returns a newly
> allocated zeroed cpumask, or a static cpumask with all online cpus set.
> The code in the middle is only allowed to set bits in the cpumask
> (should be the common usage). =A0free_cpumask_var() needs to check whethe=
r
> the freed object is the static variable.

Thanks for the feedback and advice! I totally agree the repeating
pattern needs abstracting.

I ended up chosing to try a different abstraction though - basically a wrap=
per
on_each_cpu_cond that gets a predicate function to run per CPU to
build the mask
to send the IPI to. It seems cleaner to me not having to mess with
free_cpumask_var
and it abstracts more of the general pattern.

I intend to run the new code through some more testing tomorrow and send ou=
t V5
of the patch set. I'd be delighted if you can have a look through it then.

Thanks!
Gilad

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
