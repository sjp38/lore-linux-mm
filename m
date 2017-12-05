Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0AFFE6B0069
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 17:21:07 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id f4so895927wre.9
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 14:21:06 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b8si820551wrf.273.2017.12.05.14.21.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Dec 2017 14:21:05 -0800 (PST)
Date: Tue, 5 Dec 2017 14:21:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH v3 2/7] ktask: multithread CPU-intensive kernel work
Message-Id: <20171205142102.8b53c7d6eca231b07dbf422e@linux-foundation.org>
In-Reply-To: <20171205195220.28208-3-daniel.m.jordan@oracle.com>
References: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
	<20171205195220.28208-3-daniel.m.jordan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aaron.lu@intel.com, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mhocko@kernel.org, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

On Tue,  5 Dec 2017 14:52:15 -0500 Daniel Jordan <daniel.m.jordan@oracle.com> wrote:

> ktask is a generic framework for parallelizing CPU-intensive work in the
> kernel.  The intended use is for big machines that can use their CPU power to
> speed up large tasks that can't otherwise be multithreaded in userland.  The
> API is generic enough to add concurrency to many different kinds of tasks--for
> example, zeroing a range of pages or evicting a list of inodes--and aims to
> save its clients the trouble of splitting up the work, choosing the number of
> threads to use, maintaining an efficient concurrency level, starting these
> threads, and load balancing the work between them.
> 
> The Documentation patch earlier in this series has more background.
> 
> Introduces the ktask API; consumers appear in subsequent patches.
> 
> Based on work by Pavel Tatashin, Steve Sistare, and Jonathan Adams.
>
> ...
>
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -319,6 +319,18 @@ config AUDIT_TREE
>  	depends on AUDITSYSCALL
>  	select FSNOTIFY
>  
> +config KTASK
> +	bool "Multithread cpu-intensive kernel tasks"
> +	depends on SMP
> +	depends on NR_CPUS > 16

Why this?

It would make sense to relax (or eliminate) this at least for the
development/test period, so more people actually run and test the new
code.

> +	default n
> +	help
> +	  Parallelize expensive kernel tasks such as zeroing huge pages.  This
> +          feature is designed for big machines that can take advantage of their
> +          cpu count to speed up large kernel tasks.
> +
> +          If unsure, say 'N'.
> +
>  source "kernel/irq/Kconfig"
>  source "kernel/time/Kconfig"
>  
>
> ...
>
> +/*
> + * Initialize internal limits on work items queued.  Work items submitted to
> + * cmwq capped at 80% of online cpus both system-wide and per-node to maintain
> + * an efficient level of parallelization at these respective levels.
> + */
> +bool ktask_rlim_init(void)

Why not static __init?

> +{
> +	int node;
> +	unsigned nr_node_cpus;
> +
> +	spin_lock_init(&ktask_rlim_lock);

This can be done at compile time.  Unless there's a real reason for
ktask_rlim_init to be non-static, non-__init, in which case I'm
worried: reinitializing a static spinlock is weird.

> +	ktask_rlim_node_cur = kcalloc(num_possible_nodes(),
> +					       sizeof(size_t),
> +					       GFP_KERNEL);
> +	if (!ktask_rlim_node_cur) {
> +		pr_warn("can't alloc rlim counts (ktask disabled)");
> +		return false;
> +	}
> +
> +	ktask_rlim_node_max = kmalloc_array(num_possible_nodes(),
> +						     sizeof(size_t),
> +						     GFP_KERNEL);
> +	if (!ktask_rlim_node_max) {
> +		kfree(ktask_rlim_node_cur);
> +		pr_warn("can't alloc rlim maximums (ktask disabled)");
> +		return false;
> +	}
> +
> +	ktask_rlim_max = mult_frac(num_online_cpus(), KTASK_CPUFRAC_NUMER,
> +						      KTASK_CPUFRAC_DENOM);
> +	for_each_node(node) {
> +		nr_node_cpus = cpumask_weight(cpumask_of_node(node));
> +		ktask_rlim_node_max[node] = mult_frac(nr_node_cpus,
> +						      KTASK_CPUFRAC_NUMER,
> +						      KTASK_CPUFRAC_DENOM);
> +	}
> +
> +	return true;
> +}
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
