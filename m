Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 2B28D6B002C
	for <linux-mm@kvack.org>; Sun,  5 Feb 2012 10:46:43 -0500 (EST)
Received: by vbip1 with SMTP id p1so4578938vbi.14
        for <linux-mm@kvack.org>; Sun, 05 Feb 2012 07:46:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F2EA206.3000707@linux.vnet.ibm.com>
References: <1328448800-15794-1-git-send-email-gilad@benyossef.com>
	<1328449722-15959-3-git-send-email-gilad@benyossef.com>
	<4F2EA206.3000707@linux.vnet.ibm.com>
Date: Sun, 5 Feb 2012 17:46:41 +0200
Message-ID: <CAOtvUMdqpwOedhZHq6QpUnDyg1FzfK_K3=9HQujjoN9yU3XWnA@mail.gmail.com>
Subject: Re: [PATCH v8 4/8] smp: add func to IPI cpus based on parameter func
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Christoph Lameter <cl@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Milton Miller <miltonm@bga.com>

On Sun, Feb 5, 2012 at 5:36 PM, Srivatsa S. Bhat
<srivatsa.bhat@linux.vnet.ibm.com> wrote:
> On 02/05/2012 07:18 PM, Gilad Ben-Yossef wrote:
>
>> Add the on_each_cpu_cond() function that wraps on_each_cpu_mask()
>> and calculates the cpumask of cpus to IPI by calling a function supplied
>> as a parameter in order to determine whether to IPI each specific cpu.
>>
>> The function works around allocation failure of cpumask variable in
>> CONFIG_CPUMASK_OFFSTACK=3Dy by itereating over cpus sending an IPI a
>> time via smp_call_function_single().
>>
>> The function is useful since it allows to seperate the specific
>> code that decided in each case whether to IPI a specific cpu for
>> a specific request from the common boilerplate code of handling
>> creating the mask, handling failures etc.
>>
>> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> ...
>> diff --git a/include/linux/smp.h b/include/linux/smp.h
>> index d0adb78..da4d034 100644
>> --- a/include/linux/smp.h
>> +++ b/include/linux/smp.h
>> @@ -109,6 +109,15 @@ void on_each_cpu_mask(const struct cpumask *mask, s=
mp_call_func_t func,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 void *info, bool wait);
>>
>> =A0/*
>> + * Call a function on each processor for which the supplied function
>> + * cond_func returns a positive value. This may include the local
>> + * processor.
>> + */
>> +void on_each_cpu_cond(bool (*cond_func)(int cpu, void *info),
>> + =A0 =A0 =A0 =A0 =A0 =A0 smp_call_func_t func, void *info, bool wait,
>> + =A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_flags);
>> +
>> +/*
>> =A0 * Mark the boot cpu "online" so that it can call console drivers in
>> =A0 * printk() and can access its per-cpu storage.
>> =A0 */
>> @@ -153,6 +162,21 @@ static inline int up_smp_call_function(smp_call_fun=
c_t func, void *info)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 local_irq_enable(); =A0 =A0 =
=A0 =A0 =A0 =A0 \
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 } =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
>> =A0 =A0 =A0 } while (0)
>> +/*
>> + * Preemption is disabled here to make sure the
>> + * cond_func is called under the same condtions in UP
>> + * and SMP.
>> + */
>> +#define on_each_cpu_cond(cond_func, func, info, wait, gfp_flags) \
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
>> + =A0 =A0 =A0 =A0 =A0 =A0 } =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
>> + =A0 =A0 =A0 =A0 =A0 =A0 preempt_enable(); =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 \
>> + =A0 =A0 } while (0)
>>
>> =A0static inline void smp_send_reschedule(int cpu) { }
>> =A0#define num_booting_cpus() =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1
>> diff --git a/kernel/smp.c b/kernel/smp.c
>> index a081e6c..28cbcc5 100644
>> --- a/kernel/smp.c
>> +++ b/kernel/smp.c
>> @@ -730,3 +730,63 @@ void on_each_cpu_mask(const struct cpumask *mask, s=
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
>> + * @gfp_flags: =A0 =A0 =A0 GFP flags to use when allocating the cpumask
>> + * =A0 =A0 =A0 =A0 =A0 used internally by the function.
>> + *
>> + * The function might sleep if the GFP flags indicates a non
>> + * atomic allocation is allowed.
>> + *
>> + * Preemption is disabled to protect against a hotplug event.
>
>
> Well, disabling preemption protects us only against CPU offline right?
> (because we use the stop_machine thing during cpu offline).
>
> What about CPU online?
>
> Just to cross-check my understanding of the code with the existing
> documentation on CPU hotplug, I looked up Documentation/cpu-hotplug.txt
> and this is what I found:
>
> "If you merely need to avoid cpus going away, you could also use
> preempt_disable() and preempt_enable() for those sections....
> ...The preempt_disable() will work as long as stop_machine_run() is used
> to take a cpu down."
>
> So even this only talks about using preempt_disable() to prevent CPU offl=
ine,
> not CPU online. Or, am I missing something?

You are not missing anything, this is simply a bad choice of words on my pa=
rt.
Thank you for pointing this out.

I should write:

" Preemption is disabled to protect against CPU going offline but not onlin=
e.
  CPUs going online during the call will not be seen or sent an IPI."

Protecting against CPU going online during the function is useless
since they might
as well go online right after the call is finished, so the caller has
to take care of it, if they
cares.

Thanks,
Gilad

>
>> + *
>> + * You must not call this function with disabled interrupts or
>> + * from a hardware interrupt handler or from a bottom half handler.
>> + */
>> +void on_each_cpu_cond(bool (*cond_func)(int cpu, void *info),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 smp_call_func_t func, void *in=
fo, bool wait,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 gfp_t gfp_flags)
>> +{
>> + =A0 =A0 cpumask_var_t cpus;
>> + =A0 =A0 int cpu, ret;
>> +
>> + =A0 =A0 might_sleep_if(gfp_flags & __GFP_WAIT);
>> +
>> + =A0 =A0 if (likely(zalloc_cpumask_var(&cpus, (gfp_flags|__GFP_NOWARN))=
)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 preempt_disable();
>> + =A0 =A0 =A0 =A0 =A0 =A0 for_each_online_cpu(cpu)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (cond_func(cpu, info))
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 cpumask_set_cp=
u(cpu, cpus);
>
>
> IOW, what prevents a new CPU from becoming online at this point?
>
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
>
>
> Regards,
> Srivatsa S. Bhat
>



--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
=A0-- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
