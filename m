Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 748E96B0033
	for <linux-mm@kvack.org>; Tue, 19 Sep 2017 16:57:18 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f84so1184038pfj.0
        for <linux-mm@kvack.org>; Tue, 19 Sep 2017 13:57:18 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 37sor112791ple.46.2017.09.19.13.57.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Sep 2017 13:57:17 -0700 (PDT)
Date: Tue, 19 Sep 2017 13:57:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/2] mm: oom: show unreclaimable slab info when kernel
 panic
In-Reply-To: <1505759209-102539-3-git-send-email-yang.s@alibaba-inc.com>
Message-ID: <alpine.DEB.2.10.1709191356020.7458@chino.kir.corp.google.com>
References: <1505759209-102539-1-git-send-email-yang.s@alibaba-inc.com> <1505759209-102539-3-git-send-email-yang.s@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>
Cc: cl@linux.com, penberg@kernel.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 19 Sep 2017, Yang Shi wrote:

> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -35,6 +35,8 @@
>  static DECLARE_WORK(slab_caches_to_rcu_destroy_work,
>  		    slab_caches_to_rcu_destroy_workfn);
>  
> +#define K(x) ((x)/1024)
> +
>  /*
>   * Set of flags that will prevent slab merging
>   */
> @@ -1272,6 +1274,34 @@ static int slab_show(struct seq_file *m, void *p)
>  	return 0;
>  }
>  
> +void show_unreclaimable_slab()
> +{
> +	struct kmem_cache *s = NULL;
> +	struct slabinfo sinfo;
> +
> +	memset(&sinfo, 0, sizeof(sinfo));
> +
> +	printk("Unreclaimable slabs:\n");
> +
> +	/*
> +	 * Here acquiring slab_mutex is unnecessary since we don't prefer to
> +	 * get sleep in oom path right before kernel panic, and avoid race condition.
> +	 * Since it is already oom, so there should be not any big allocation
> +	 * which could change the statistics significantly.
> +	 */
> +	list_for_each_entry(s, &slab_caches, list) {
> +		if (!is_root_cache(s))
> +			continue;
> +
> +		get_slabinfo(s, &sinfo);
> +
> +		if (!is_reclaimable(s) && sinfo.num_objs > 0)
> +			printk("%-17s %luKB\n", cache_name(s), K(sinfo.num_objs * s->size));
> +	}

I like this, but could we be even more helpful by giving the user more 
information from sinfo beyond just the total size of objects allocated?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
