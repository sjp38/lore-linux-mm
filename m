Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5246B0031
	for <linux-mm@kvack.org>; Mon, 27 Jan 2014 17:43:40 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id q10so6302000pdj.10
        for <linux-mm@kvack.org>; Mon, 27 Jan 2014 14:43:39 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id to9si12960140pbc.335.2014.01.27.14.43.37
        for <linux-mm@kvack.org>;
        Mon, 27 Jan 2014 14:43:38 -0800 (PST)
Date: Mon, 27 Jan 2014 14:43:36 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: numa: Initialse numa balancing after jump label
 initialisation
Message-Id: <20140127144336.6e9428d317bc2f476fa8de3e@linux-foundation.org>
In-Reply-To: <20140127155127.GJ4963@suse.de>
References: <20140127155127.GJ4963@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 27 Jan 2014 15:51:27 +0000 Mel Gorman <mgorman@suse.de> wrote:

> The command line parsing takes place before jump labels are initialised which
> generates a warning if numa_balancing= is specified and CONFIG_JUMP_LABEL
> is set. On older kernls before commit c4b2c0c5 (static_key: WARN on
> usage before jump_label_init was called) the kernel would have crashed.
> This patch enables automatic numa balancing later in the initialisation
> process if numa_balancing= is specified.
> 
> ...
>
> @@ -2666,9 +2666,14 @@ static void __init check_numabalancing_enable(void)
>  	if (IS_ENABLED(CONFIG_NUMA_BALANCING_DEFAULT_ENABLED))
>  		numabalancing_default = true;
>  
> +	/* Parsed by setup_numabalancing. override == 1 enables, -1 disables */
> +	if (numabalancing_override)
> +		set_numabalancing_state(numabalancing_override == 1);
> +
>  	if (nr_node_ids > 1 && !numabalancing_override) {
> -		printk(KERN_INFO "Enabling automatic NUMA balancing. "
> -			"Configure with numa_balancing= or sysctl");
> +		printk(KERN_INFO "%s automatic NUMA balancing. "
> +			"Configure with numa_balancing= or sysctl",
> +			numabalancing_default ? "Enabling" : "Disabling");
>  		set_numabalancing_state(numabalancing_default);
>  	}
>  }

Current mainline is a bit different from this:

		printk(KERN_INFO "Enabling automatic NUMA balancing. "
			"Configure with numa_balancing= or the kernel.numa_balancing sysctl");

So this won't apply as-is to -stable.

I assume you suggested the -stable backport to fix the
it-crashes-before-c4b2c0c5 thing, so it isn't really needed in 3.12.x.

Or something.  Please sort all that out when Greg comes back with
a hey-that-didnt-apply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
