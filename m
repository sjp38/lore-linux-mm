Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f169.google.com (mail-ie0-f169.google.com [209.85.223.169])
	by kanga.kvack.org (Postfix) with ESMTP id D5E1C6B0031
	for <linux-mm@kvack.org>; Wed, 26 Mar 2014 20:07:14 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id to1so2515386ieb.28
        for <linux-mm@kvack.org>; Wed, 26 Mar 2014 17:07:14 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0135.hostedemail.com. [216.40.44.135])
        by mx.google.com with ESMTP id u6si203240icp.128.2014.03.26.17.07.13
        for <linux-mm@kvack.org>;
        Wed, 26 Mar 2014 17:07:14 -0700 (PDT)
Message-ID: <1395878830.3726.55.camel@joe-AO722>
Subject: Re: [PATCH] mm: convert some level-less printks to pr_*
From: Joe Perches <joe@perches.com>
Date: Wed, 26 Mar 2014 17:07:10 -0700
In-Reply-To: <1395877783-18910-2-git-send-email-mitchelh@codeaurora.org>
References: <1395877783-18910-1-git-send-email-mitchelh@codeaurora.org>
	 <1395877783-18910-2-git-send-email-mitchelh@codeaurora.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mitchel Humpherys <mitchelh@codeaurora.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 2014-03-26 at 16:49 -0700, Mitchel Humpherys wrote:
> printk is meant to be used with an associated log level. There are some
> instances of printk scattered around the mm code where the log level is
> missing. Add a log level and adhere to suggestions by
> scripts/checkpatch.pl by moving to the pr_* macros.

There are some defects in this patch:
Conversions of printk to pr_info that should be pr_cont.

I've also got some other trivial comments about it.

For each file modified, if it's not already there,
please add before any #include

#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

[]

> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
[]
> @@ -2751,7 +2752,7 @@ void __init numa_policy_init(void)
>  		node_set(prefer, interleave_nodes);
>  
>  	if (do_set_mempolicy(MPOL_INTERLEAVE, 0, &interleave_nodes))
> -		printk("numa_policy_init: interleaving failed\n");
> +		pr_warn("numa_policy_init: interleaving failed\n");

That seems more like pr_err to me.

Also please remove embedded function names and use
"%s: ", __func__

> @@ -3237,7 +3238,7 @@ static struct notifier_block reserve_mem_nb = {
>  static int __meminit init_reserve_notifier(void)
>  {
>  	if (register_hotmemory_notifier(&reserve_mem_nb))
> -		printk("Failed registering memory add/remove notifier for admin reserve");
> +		pr_info("Failed registering memory add/remove notifier for admin reserve");

Another more likely pr_err
Also missing a "\n" terminating newline

> diff --git a/mm/nommu.c b/mm/nommu.c
[]
> @@ -1241,7 +1242,7 @@ error_free:
>  	return ret;
>  
>  enomem:
> -	printk("Allocation of length %lu from process %d (%s) failed\n",
> +	pr_warn("Allocation of length %lu from process %d (%s) failed\n",
>  	       len, current->pid, current->comm);

pr_err

> diff --git a/mm/slub.c b/mm/slub.c
[]
> @@ -1774,15 +1775,15 @@ static inline void note_cmpxchg_failure(const char *n,
>  
>  #ifdef CONFIG_PREEMPT
>  	if (tid_to_cpu(tid) != tid_to_cpu(actual_tid))
> -		printk("due to cpu change %d -> %d\n",
> +		pr_info("due to cpu change %d -> %d\n",
>  			tid_to_cpu(tid), tid_to_cpu(actual_tid));

This should be pr_cont

>  	else
>  #endif
>  	if (tid_to_event(tid) != tid_to_event(actual_tid))
> -		printk("due to cpu running other code. Event %ld->%ld\n",
> +		pr_info("due to cpu running other code. Event %ld->%ld\n",

pr_cont

>  			tid_to_event(tid), tid_to_event(actual_tid));
>  	else
> -		printk("for unknown reason: actual=%lx was=%lx target=%lx\n",
> +		pr_info("for unknown reason: actual=%lx was=%lx target=%lx\n",

pr_cont

>  			actual_tid, tid, next_tid(tid));
>  #endif
>  	stat(s, CMPXCHG_DOUBLE_CPU_FAIL);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
