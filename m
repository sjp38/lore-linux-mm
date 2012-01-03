Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id A2FE36B00A2
	for <linux-mm@kvack.org>; Tue,  3 Jan 2012 17:26:26 -0500 (EST)
Date: Tue, 3 Jan 2012 14:26:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 1/8] smp: Introduce a generic on_each_cpu_mask
 function
Message-Id: <20120103142624.faf46d77.akpm@linux-foundation.org>
In-Reply-To: <1325499859-2262-2-git-send-email-gilad@benyossef.com>
References: <1325499859-2262-1-git-send-email-gilad@benyossef.com>
	<1325499859-2262-2-git-send-email-gilad@benyossef.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Mon,  2 Jan 2012 12:24:12 +0200
Gilad Ben-Yossef <gilad@benyossef.com> wrote:

> on_each_cpu_mask calls a function on processors specified my cpumask,
> which may include the local processor.
> 
> All the limitation specified in smp_call_function_many apply.
> 
> ...
>
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
> +/*
>   * Mark the boot cpu "online" so that it can call console drivers in
>   * printk() and can access its per-cpu storage.
>   */
> @@ -132,6 +139,15 @@ static inline int up_smp_call_function(smp_call_func_t func, void *info)
>  		local_irq_enable();		\
>  		0;				\
>  	})
> +#define on_each_cpu_mask(mask, func, info, wait) \
> +	do {						\
> +		if (cpumask_test_cpu(0, (mask))) {	\
> +			local_irq_disable();		\
> +			(func)(info);			\
> +			local_irq_enable();		\
> +		}					\
> +	} while (0)

Why is the cpumask_test_cpu() call there?  It's hard to think of a
reason why "mask" would specify any CPU other than "0" in a
uniprocessor kernel.

If this code remains as-is, please add a comment here explaining this,
so others don't wonder the same thing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
