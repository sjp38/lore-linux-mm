Received: by wa-out-1112.google.com with SMTP id m28so217500wag.8
        for <linux-mm@kvack.org>; Thu, 21 Aug 2008 00:31:31 -0700 (PDT)
Message-ID: <2f11576a0808210031r372c12bau7c94d86f2c9120d4@mail.gmail.com>
Date: Thu, 21 Aug 2008 16:31:31 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/2] quicklist shouldn't be proportional to # of CPUs
In-Reply-To: <20080821002757.b7c807ad.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080820195021.12E7.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080820200709.12F0.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <20080820234615.258a9c04.akpm@linux-foundation.org>
	 <20080821.001322.236658980.davem@davemloft.net>
	 <20080821002757.b7c807ad.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, tokunaga.keiich@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

>> IA64 seems to be one of the few platforms to define this as a macro
>> evaluating to the node-to-cpumask array entry, so it's clear what
>> platform Motohiro-san did build testing on :-)
>
> Seems to compile OK on x86_32, x86_64, ia64 and powerpc for some reason.
>
> This seems to fix things on sparc64:
>
> --- a/mm/quicklist.c~mm-quicklist-shouldnt-be-proportional-to-number-of-cpus-fix
> +++ a/mm/quicklist.c
> @@ -28,7 +28,7 @@ static unsigned long max_pages(unsigned
>        unsigned long node_free_pages, max;
>        int node = numa_node_id();
>        struct zone *zones = NODE_DATA(node)->node_zones;
> -       int num_cpus_per_node;
> +       cpumask_t node_cpumask;
>
>        node_free_pages =
>  #ifdef CONFIG_ZONE_DMA
> @@ -41,8 +41,8 @@ static unsigned long max_pages(unsigned
>
>        max = node_free_pages / FRACTION_OF_NODE_MEM;
>
> -       num_cpus_per_node = cpus_weight_nr(node_to_cpumask(node));
> -       max /= num_cpus_per_node;
> +       node_cpumask = node_to_cpumask(node);
> +       max /= cpus_weight_nr(node_cpumask);
>
>        return max(max, min_pages);
>  }

Thank you!!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
