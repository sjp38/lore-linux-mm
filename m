Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 13A5F6B005A
	for <linux-mm@kvack.org>; Sun,  8 Jan 2012 11:09:05 -0500 (EST)
Received: by vcge1 with SMTP id e1so2663675vcg.14
        for <linux-mm@kvack.org>; Sun, 08 Jan 2012 08:09:04 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120103143417.7cbea589.akpm@linux-foundation.org>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
	<1325499859-2262-5-git-send-email-gilad@benyossef.com>
	<20120103143417.7cbea589.akpm@linux-foundation.org>
Date: Sun, 8 Jan 2012 18:09:03 +0200
Message-ID: <CAOtvUMdY3ZST0Pb+tbec1WSfPgOQtAZQtc6ZMs16U5pBriomXA@mail.gmail.com>
Subject: Re: [PATCH v5 4/8] smp: Add func to IPI cpus based on parameter func
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Wed, Jan 4, 2012 at 12:34 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, =A02 Jan 2012 12:24:15 +0200
> Gilad Ben-Yossef <gilad@benyossef.com> wrote:
>
>> Add the on_each_cpu_required() function that wraps on_each_cpu_mask()
>> and calculates the cpumask of cpus to IPI by calling a function supplied
>> as a parameter in order to determine whether to IPI each specific cpu.
>
> The name is actually "on_each_cpu_cond".

Oopss... I started out with on_each_cpu_required as a name and switched but
missed the description. Thanks for pointing it out.

<SNIP>

>> + * Call a function on each processor for which the supplied function
>> + * cond_func returns a positive value. This may include the local
>> + * processor, optionally waiting for all the required CPUs to finish.
>> + * The function may be called on all online CPUs without running the
>> + * cond_func function in extreme circumstance (memory allocation
>> + * failure condition when CONFIG_CPUMASK_OFFSTACK=3Dy)
>> + * All the limitations specified in smp_call_function_many apply.
>> + */
>> +void on_each_cpu_cond(int (*cond_func) (int cpu, void *info),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 void (*func)(void *), void *in=
fo, bool wait)
>> +{
>> + =A0 =A0 cpumask_var_t cpus;
>> + =A0 =A0 int cpu;
>> +
>> + =A0 =A0 if (likely(zalloc_cpumask_var(&cpus, GFP_ATOMIC))) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 for_each_online_cpu(cpu)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cond_func(cpu, info))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_set_cp=
u(cpu, cpus);
>> + =A0 =A0 =A0 =A0 =A0 =A0 on_each_cpu_mask(cpus, func, info, wait);
>> + =A0 =A0 =A0 =A0 =A0 =A0 free_cpumask_var(cpus);
>> + =A0 =A0 } else
>> + =A0 =A0 =A0 =A0 =A0 =A0 on_each_cpu(func, info, wait);
>> +}
>> +EXPORT_SYMBOL(on_each_cpu_cond);
>
> If zalloc_cpumask_var() fails, can we not fall back to
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for_each_online_cpu(cpu)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cond_func(cpu, info))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0smp_call_f=
unction_single(...);
>

Indeed we can and probably should :-)

I'll send out v6 with this and other fixes momentarily.

Thanks,
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
