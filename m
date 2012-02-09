Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 7539C6B13F0
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 17:26:27 -0500 (EST)
Date: Thu, 9 Feb 2012 14:26:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v9 4/8] smp: add func to IPI cpus based on parameter
 func
Message-Id: <20120209142625.0664e055.akpm@linux-foundation.org>
In-Reply-To: <1328776585-22518-5-git-send-email-gilad@benyossef.com>
References: <1328776585-22518-1-git-send-email-gilad@benyossef.com>
	<1328776585-22518-5-git-send-email-gilad@benyossef.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Christoph Lameter <cl@linux-foundation.org>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Thu,  9 Feb 2012 10:36:21 +0200
Gilad Ben-Yossef <gilad@benyossef.com> wrote:

> @@ -153,6 +162,22 @@ static inline int up_smp_call_function(smp_call_func_t func, void *info)
>  			local_irq_enable();		\
>  		}					\
>  	} while (0)
> +/*
> + * Preemption is disabled here to make sure the
> + * cond_func is called under the same condtions in UP
> + * and SMP.
> + */
> +#define on_each_cpu_cond(cond_func, func, info, wait, gfp_flags) \
> +	do {
> +		void *__info = (info);			\
> +		preempt_disable();			\
> +		if ((cond_func)(0, __info)) {		\
> +			local_irq_disable();		\
> +			(func)(__info);			\
> +			local_irq_enable();		\
> +		}					\
> +		preempt_enable();			\
> +	} while (0)

That wasn't compile-tested!

This is one of the many reasons why I convert replacement patches into
incremental patches - so I can see what was done.

Here's what I queued after converting this patch into a delta:

--- a/kernel/smp.c~smp-add-func-to-ipi-cpus-based-on-parameter-func-v9
+++ a/kernel/smp.c
@@ -771,7 +771,9 @@ EXPORT_SYMBOL(on_each_cpu_mask);
  * The function might sleep if the GFP flags indicates a non
  * atomic allocation is allowed.
  *
- * Preemption is disabled to protect against a hotplug event.
+ * Preemption is disabled to protect against CPU going offline but not
+ * online. CPUs going online during the call will not be seen or sent
+ * an IPI.
  *
  * You must not call this function with disabled interrupts or
  * from a hardware interrupt handler or from a bottom half handler.
_

And I queued a small fix to that:

From: Andrew Morton <akpm@linux-foundation.org>
Subject: smp-add-func-to-ipi-cpus-based-on-parameter-func-v9-fix

s/CPU/CPUs, use all 80 cols in comment

Cc: Gilad Ben-Yossef <gilad@benyossef.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 kernel/smp.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

--- a/kernel/smp.c~smp-add-func-to-ipi-cpus-based-on-parameter-func-v9-fix
+++ a/kernel/smp.c
@@ -771,9 +771,8 @@ EXPORT_SYMBOL(on_each_cpu_mask);
  * The function might sleep if the GFP flags indicates a non
  * atomic allocation is allowed.
  *
- * Preemption is disabled to protect against CPU going offline but not
- * online. CPUs going online during the call will not be seen or sent
- * an IPI.
+ * Preemption is disabled to protect against CPUs going offline but not online.
+ * CPUs going online during the call will not be seen or sent an IPI.
  *
  * You must not call this function with disabled interrupts or
  * from a hardware interrupt handler or from a bottom half handler.
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
