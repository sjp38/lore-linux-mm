Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4B95A6B0069
	for <linux-mm@kvack.org>; Fri, 15 Sep 2017 08:00:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y77so4045911pfd.2
        for <linux-mm@kvack.org>; Fri, 15 Sep 2017 05:00:56 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p64si521935pga.766.2017.09.15.05.00.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Sep 2017 05:00:55 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when kernel
 panic
References: <1505409289-57031-1-git-send-email-yang.s@alibaba-inc.com>
 <1505409289-57031-4-git-send-email-yang.s@alibaba-inc.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <2f7b69d1-8aa2-c2b8-92bd-167998145a28@I-love.SAKURA.ne.jp>
Date: Fri, 15 Sep 2017 21:00:43 +0900
MIME-Version: 1.0
In-Reply-To: <1505409289-57031-4-git-send-email-yang.s@alibaba-inc.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.s@alibaba-inc.com>, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2017/09/15 2:14, Yang Shi wrote:
> @@ -1274,6 +1276,29 @@ static int slab_show(struct seq_file *m, void *p)
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
> +	mutex_lock(&slab_mutex);

Please avoid sleeping locks which potentially depend on memory allocation.
There are

	mutex_lock(&slab_mutex);
	kmalloc(GFP_KERNEL);
	mutex_unlock(&slab_mutex);

users which will fail to call panic() if they hit this path.

> +	list_for_each_entry(s, &slab_caches, list) {
> +		if (!is_root_cache(s))
> +			continue;
> +
> +		get_slabinfo(s, &sinfo);
> +
> +		if (!is_reclaimable(s) && sinfo.num_objs > 0)
> +			printk("%-17s %luKB\n", cache_name(s), K(sinfo.num_objs * s->size));
> +	}
> +	mutex_unlock(&slab_mutex);
> +}
> +EXPORT_SYMBOL(show_unreclaimable_slab);
> +#undef K
> +
>  #if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
>  void *memcg_slab_start(struct seq_file *m, loff_t *pos)
>  {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
