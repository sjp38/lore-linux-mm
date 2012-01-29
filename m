Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 07D2D6B004D
	for <linux-mm@kvack.org>; Sun, 29 Jan 2012 07:04:26 -0500 (EST)
Received: by vbbfd1 with SMTP id fd1so2872272vbb.14
        for <linux-mm@kvack.org>; Sun, 29 Jan 2012 04:04:26 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20120127155725.86654035.akpm@linux-foundation.org>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327572121-13673-5-git-send-email-gilad@benyossef.com>
	<20120127155725.86654035.akpm@linux-foundation.org>
Date: Sun, 29 Jan 2012 14:04:25 +0200
Message-ID: <CAOtvUMfceR8zZf5resfcNQFWZyrKG5BdB00gqq3GZRpgFRD=yw@mail.gmail.com>
Subject: Re: [v7 4/8] smp: add func to IPI cpus based on parameter func
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Sat, Jan 28, 2012 at 1:57 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 26 Jan 2012 12:01:57 +0200
> Gilad Ben-Yossef <gilad@benyossef.com> wrote:
...
>>
>> @@ -153,6 +162,16 @@ static inline int up_smp_call_function(smp_call_fun=
c_t func, void *info)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_enable(); =A0 =A0 =
=A0 =A0 =A0 =A0 \
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
>> =A0 =A0 =A0 } while (0)
>> +#define on_each_cpu_cond(cond_func, func, info, wait, gfpflags) \
>> + =A0 =A0 do { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
>> + =A0 =A0 =A0 =A0 =A0 =A0 preempt_disable(); =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0\
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (cond_func(0, info)) { =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 \
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_disable(); =A0 =A0 =
=A0 =A0 =A0 =A0\
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (func)(info); =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 \
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_enable(); =A0 =A0 =
=A0 =A0 =A0 =A0 \
>
> Ordinarily, local_irq_enable() in such a low-level thing is dangerous,
> because it can cause horrid bugs when called from local_irq_disable()d
> code.
>
> However I think we're OK here because it is a bug to call on_each_cpu()
> and friends with local irqs disabled, yes?

Yes, that is my understanding and this way the function gets called in
the same conditions in UP and SMP.

> Do we have any warnings printks if someone calls the ipi-sending
> functions with local interrupts disabled? =A0I didn't see any, but didn't
> look very hard.

There is this check in smp_call_function_many():

        WARN_ON_ONCE(cpu_online(this_cpu) && irqs_disabled()
                     && !oops_in_progress && !early_boot_irqs_disabled);

Only catches SMP offenders though.


> If my above claims are correct then why does on_each_cpu() use
> local_irq_save()? =A0hrm.

The comment in on_each_cpu() in kernel.smp.c says: "May be
used during early boot while early_boot_irqs_disabled is set.  Use
local_irq_save/restore() instead of local_irq_disable/enable()."


>
>> + =A0 =A0 =A0 =A0 =A0 =A0 } =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
>> + =A0 =A0 =A0 =A0 =A0 =A0 preempt_enable(); =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 \
>> + =A0 =A0 } while (0)
>>
>> =A0static inline void smp_send_reschedule(int cpu) { }
>> =A0#define num_booting_cpus() =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1
>> diff --git a/kernel/smp.c b/kernel/smp.c
>> index a081e6c..fa0912a 100644
>> --- a/kernel/smp.c
>> +++ b/kernel/smp.c
>> @@ -730,3 +730,61 @@ void on_each_cpu_mask(const struct cpumask *mask, s=
mp_call_func_t func,
>> =A0 =A0 =A0 put_cpu();
>> =A0}
>> =A0EXPORT_SYMBOL(on_each_cpu_mask);
>> +
>> +/*
>> + * on_each_cpu_cond(): Call a function on each processor for which
>> + * the supplied function cond_func returns true, optionally waiting
>> + * for all the required CPUs to finish. This may include the local
>> + * processor.
>> + * @cond_func: =A0 =A0 =A0 A callback function that is passed a cpu id =
and
>> + * =A0 =A0 =A0 =A0 =A0 the the info parameter. The function is called
>> + * =A0 =A0 =A0 =A0 =A0 with preemption disabled. The function should
>> + * =A0 =A0 =A0 =A0 =A0 return a blooean value indicating whether to IPI
>> + * =A0 =A0 =A0 =A0 =A0 the specified CPU.
>> + * @func: =A0 =A0The function to run on all applicable CPUs.
>> + * =A0 =A0 =A0 =A0 =A0 This must be fast and non-blocking.
>> + * @info: =A0 =A0An arbitrary pointer to pass to both functions.
>> + * @wait: =A0 =A0If true, wait (atomically) until function has
>> + * =A0 =A0 =A0 =A0 =A0 completed on other CPUs.
>> + * @gfpflags: =A0 =A0 =A0 =A0GFP flags to use when allocating the cpuma=
sk
>> + * =A0 =A0 =A0 =A0 =A0 used internally by the function.
>> + *
>> + * The function might sleep if the GFP flags indicates a non
>> + * atomic allocation is allowed.
>> + *
>> + * You must not call this function with disabled interrupts or
>> + * from a hardware interrupt handler or from a bottom half handler.
>> + */
>> +void on_each_cpu_cond(bool (*cond_func)(int cpu, void *info),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 smp_call_func_t func, void *in=
fo, bool wait,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfpflags)
>
> bah.
>
> z:/usr/src/linux-3.3-rc1> grep -r gfpflags . | wc -l
> 78
> z:/usr/src/linux-3.3-rc1> grep -r gfp_flags . | wc -l
> 548
>

I have no specific preference. Should I switch?

>> +{
>> + =A0 =A0 cpumask_var_t cpus;
>> + =A0 =A0 int cpu, ret;
>> +
>> + =A0 =A0 might_sleep_if(gfpflags & __GFP_WAIT);
>
> For the zalloc_cpumask_var(), it seems. =A0I expect there are
> might_sleep() elsewhere in the memory allocation paths, but putting one
> here will detect bugs even if CONFIG_CPUMASK_OFFSTACK=3Dn.

Well, yes, although I didn't think about that :-)

>
>> + =A0 =A0 if (likely(zalloc_cpumask_var(&cpus, (gfpflags|__GFP_NOWARN)))=
) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 preempt_disable();
>> + =A0 =A0 =A0 =A0 =A0 =A0 for_each_online_cpu(cpu)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cond_func(cpu, info))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_set_cp=
u(cpu, cpus);
>> + =A0 =A0 =A0 =A0 =A0 =A0 on_each_cpu_mask(cpus, func, info, wait);
>> + =A0 =A0 =A0 =A0 =A0 =A0 preempt_enable();
>> + =A0 =A0 =A0 =A0 =A0 =A0 free_cpumask_var(cpus);
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* No free cpumask, bother. No matter, we'll
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0* just have to IPI them one by one.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 preempt_disable();
>> + =A0 =A0 =A0 =A0 =A0 =A0 for_each_online_cpu(cpu)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cond_func(cpu, info)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D smp_ca=
ll_function_single(cpu, func,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 info, wait);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ON_ONCE(!=
ret);
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 preempt_enable();
>> + =A0 =A0 }
>> +}
>> +EXPORT_SYMBOL(on_each_cpu_cond);
>
> I assume the preempt_disable()s here are to suspend CPU hotplug?

Yes.  Also, I figured that since the original code disabled
preemption for the entire on_each_cpu run time, including waiting for all
the CPUs to ack the IPI, and since we (hopefully) wait for less CPUs, the
overall runtime with  preemption disabled will be (usually) lower then the
original  code most of the time and we'll get a more robust interface.

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
