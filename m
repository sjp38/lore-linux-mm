Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id BCC426B005C
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 02:05:17 -0500 (EST)
From: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH v6 0/8] Reduce cross CPU IPI interference
In-Reply-To: <1326040026-7285-1-git-send-email-gilad@benyossef.com>
References: <1326040026-7285-1-git-send-email-gilad@benyossef.com>
Date: Wed, 11 Jan 2012 01:04:09 -0600
Message-ID: <1326265449_1658@mail4.comsite.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>, linux-kernel@vger.kernel.org
Cc: Christoph Lameter <cl@linux.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.org>, Kosaki Motohiro <kosaki.motohiro@gmail.com>

Hi Gilad.   A few minor corrections for several of the patch logs, but some
meater discussions on several of the patches.

Overall I like the series and hope you see it through.

On Sun Jan 08 2012 about 11:27:52 EST, Gilad Ben-Yossef wrote:

> 
> We have lots of infrastructure in place to partition a multi-core systems

partition multi-core systems

> such that we have a group of CPUs that are dedicated to specific task:
> cgroups, scheduler and interrupt affinity and cpuisol boot parameter.

interrupt affinity, and isolcpus= boot parameter

> Still, kernel code will some time interrupt all CPUs in the system via IPIs

will at times

> for various needs. These IPIs are useful and cannot be avoided altogether,
> but in certain cases it is possible to interrupt only specific CPUs that
> have useful work to do and not the entire system.
> 
> This patch set, inspired by discussions with Peter Zijlstra and Frederic
> Weisbecker when testing the nohz task patch set, is a first stab at trying
> to explore doing this by locating the places where such global IPI calls
> are being made and turning a global IPI into an IPI for a specific group

turning the global IPI

> of CPUs. The purpose of the patch set is to get feedback if this is the
> right way to go for dealing with this issue and indeed, if the issue is
> even worth dealing with at all. Based on the feedback from this patch set
> I plan to offer further patches that address similar issue in other code
> paths.
> 
> The patch creates an on_each_cpu_mask and on_each_cpu_conf infrastructure

on_each_cpu_cond

> API (the former derived from existing arch specific versions in Tile and
> Arm) and and uses them to turn several global IPI invocation to per CPU
> group invocations.
> 
> This 6th iteration includes the following changes:
> 
> - In case of cpumask allocation failure, have on_each_cpu_cond
>   send an IPI to each needed CPU seperately via
>   smp_call_function_single so no cpumask var is needed, as
>   suggested by Andrew Morton.
> - Document why on_each_cpu_mask need to check the mask even on
>   UP in a code comment, as suggested by Andrew Morton.
> - Various typo cleanup in patch descriptions
> 

milton
MAIL FROM: <miltonm@bga.com>
RCPT TO: <miltonm@bga.com>
RCPT TO: <gilad@benyossef.com>
RCPT TO: <linux-kernel@vger.kernel.org>
RCPT TO: <cl@linux.com>
RCPT TO: <cmetcalf@tilera.com>
RCPT TO: <a.p.zijlstra@chello.nl>
RCPT TO: <fweisbec@gmail.com>
RCPT TO: <linux@arm.linux.org.uk>
RCPT TO: <linux-mm@kvack.org>
RCPT TO: <penberg@kernel.org>
RCPT TO: <mpm@selenic.com>
RCPT TO: <riel@redhat.com>
RCPT TO: <andi@firstfloor.org>
RCPT TO: <levinsasha928@gmail.com>
RCPT TO: <mel@csn.ul.ie>
RCPT TO: <akpm@linux-foundation.org>
RCPT TO: <viro@zeniv.linux.org.uk>
RCPT TO: <linux-fsdevel@vger.kernel.org>
RCPT TO: <avi@redhat.com>
RCPT TO: <mina86@mina86.org>
RCPT TO: <kosaki.motohiro@gmail.com>
DATA
From: Milton Miller <miltonm@bga.com>
Bcc: Milton Miller <miltonm@bga.com>
Subject: Re: [PATCH v6 1/8] smp: Introduce a generic on_each_cpu_mask function
In-Reply-To: <1326040026-7285-2-git-send-email-gilad@benyossef.com>
References: <1326040026-7285-2-git-send-email-gilad@benyossef.com>
To: Gilad Ben-Yossef <gilad@benyossef.com>,
	<linux-kernel@vger.kernel.org>
Cc:    Christoph Lameter <cl@linux.com>,
    Chris Metcalf <cmetcalf@tilera.com>,
    Peter Zijlstra <a.p.zijlstra@chello.nl>,
    Frederic Weisbecker <fweisbec@gmail.com>,
    Russell King <linux@arm.linux.org.uk>,
    <linux-mm@kvack.org>,
    Pekka Enberg <penberg@kernel.org>,
    Matt Mackall <mpm@selenic.com>,
    Rik van Riel <riel@redhat.com>,
    Andi Kleen <andi@firstfloor.org>,
    Sasha Levin <levinsasha928@gmail.com>,
    Mel Gorman <mel@csn.ul.ie>,
    Andrew Morton <akpm@linux-foundation.org>,
    Alexander Viro <viro@zeniv.linux.org.uk>,
    <linux-fsdevel@vger.kernel.org>,
    Avi Kivity <avi@redhat.com>,
    Michal Nazarewicz <mina86@mina86.org>,
    Kosaki Motohiro <kosaki.motohiro@gmail.com>


On Sun, 8 Jan 2012 about 18:26:59 +0200, Gilad Ben-Yossef wrote:
>
> on_each_cpu_mask calls a function on processors specified by
> cpumask, which may or may not include the local processor.
> 
> All the limitation specified in smp_call_function_many apply.

limitations

Except they don't, see below

> 
> Signed-off-by: Gilad Ben-Yossef <gilad@benyossef.com>
> Reviewed-by: Christoph Lameter <cl@linux.com>
..
> ---
>  include/linux/smp.h |   22 ++++++++++++++++++++++
>  kernel/smp.c        |   20 ++++++++++++++++++++
>  2 files changed, 42 insertions(+), 0 deletions(-)
> diff --git a/include/linux/smp.h b/include/linux/smp.h
> index 8cc38d3..a3a14d9 100644
> --- a/include/linux/smp.h
> +++ b/include/linux/smp.h
> @@ -102,6 +102,13 @@ static inline void call_function_init(void) { }
>  int on_each_cpu(smp_call_func_t func, void *info, int wait);
>  
>  /*
> + * Call a function on processors specified by mask, which might include
> + * the local one.
> + */
> +void on_each_cpu_mask(const struct cpumask *mask, void (*func)(void *),
> +		void *info, bool wait);
> +

func should be smp_call_func_t

> +/*
>   * Mark the boot cpu "online" so that it can call console drivers in
>   * printk() and can access its per-cpu storage.
>   */
> @@ -132,6 +139,21 @@ static inline int up_smp_call_function(smp_call_func_t func, void *info)
>  		local_irq_enable();		\
>  		0;				\
>  	})
> +/*
> + * Note we still need to test the mask even for UP
> + * because we actually can get an empty mask from
> + * code that on SMP might call us without the local
> + * CPU in the mask.
> + */
> +#define on_each_cpu_mask(mask, func, info, wait) \
> +	do {						\
> +		if (cpumask_test_cpu(0, (mask))) {	\
> +			local_irq_disable();		\
> +			(func)(info);			\
> +			local_irq_enable();		\
> +		}					\
> +	} while (0)
> +
>  static inline void smp_send_reschedule(int cpu) { }
>  #define num_booting_cpus()			1
>  #define smp_prepare_boot_cpu()			do {} while (0)
> diff --git a/kernel/smp.c b/kernel/smp.c
> index db197d6..7c0cbd7 100644
> --- a/kernel/smp.c
> +++ b/kernel/smp.c
> @@ -701,3 +701,23 @@ int on_each_cpu(void (*func) (void *info), void *info, int wait)
>  	return ret;
>  }
>  EXPORT_SYMBOL(on_each_cpu);
> +
> +/*
> + * Call a function on processors specified by cpumask, which may include
> + * the local processor. All the limitation specified in smp_call_function_many
> + * apply.
> + */

Please turn this comment into kerneldoc like the smp_call_function* family.

Also, this is not accurate, as smp_call_function_many requires
preemption to have been disabled while on_each_cpu_mask disables
preemption (via get_cpu).

> +void on_each_cpu_mask(const struct cpumask *mask, void (*func)(void *),
> +			void *info, bool wait)
> +{
> +	int cpu = get_cpu();
> +
> +	smp_call_function_many(mask, func, info, wait);
> +	if (cpumask_test_cpu(cpu, mask)) {
> +		local_irq_disable();
> +		func(info);
> +		local_irq_enable();
> +	}
> +	put_cpu();
> +}
> +EXPORT_SYMBOL(on_each_cpu_mask);

It should be less code if we rewrite on_each_cpu as the one liner
on_each_cpu_mask(cpu_online_mask).  I think the trade off of less
code is worth the cost of the added test of cpu being in online_mask.

That could be a seperate patch, but will be easier to read the result
if on_each_cpu_mask is placed above on_each_cpu in this one.

milton

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
