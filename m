Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 129236B0032
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 17:32:48 -0500 (EST)
Received: by mail-wi0-f172.google.com with SMTP id n3so3288808wiv.11
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 14:32:47 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y7si19765386wjy.65.2014.12.19.14.32.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Dec 2014 14:32:47 -0800 (PST)
Date: Fri, 19 Dec 2014 14:32:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/zsmalloc: add statistics support
Message-Id: <20141219143244.1e5fabad8b6733204486f5bc@linux-foundation.org>
In-Reply-To: <1418993719-14291-1-git-send-email-opensource.ganesh@gmail.com>
References: <1418993719-14291-1-git-send-email-opensource.ganesh@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: minchan@kernel.org, ngupta@vflare.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 19 Dec 2014 20:55:19 +0800 Ganesh Mahendran <opensource.ganesh@gmail.com> wrote:

> Keeping fragmentation of zsmalloc in a low level is our target. But now
> we still need to add the debug code in zsmalloc to get the quantitative data.
> 
> This patch adds a new configuration CONFIG_ZSMALLOC_STAT to enable the
> statistics collection for developers. Currently only the objects statatitics
> in each class are collected. User can get the information via debugfs.
>      cat /sys/kernel/debug/zsmalloc/pool-1/...

Is everyone OK with this now?

> --- a/include/linux/zsmalloc.h
> +++ b/include/linux/zsmalloc.h
> @@ -48,4 +48,13 @@ void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
>  
>  unsigned long zs_get_total_pages(struct zs_pool *pool);
>  
> +#ifdef CONFIG_ZSMALLOC_STAT
> +int get_zs_pool_index(struct zs_pool *pool);

The name is inconsistent with the rest of zsmalloc and with preferred
kernel naming conventions.  Should be "zs_get_pool_index".

> +#else
> +static inline int get_zs_pool_index(struct zs_pool *pool)
> +{
> +	return -1;
> +}
> +#endif
> +
>  #endif
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 1d1ae6b..95c5728 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
>
> ...
>
> +static int zs_stats_size_show(struct seq_file *s, void *v)
> +{
> +	int i;
> +	struct zs_pool *pool = (struct zs_pool *)s->private;

The typecast is unneeded and undesirable (it defeats typechecking).

> +	struct size_class *class;
> +	int objs_per_zspage;
> +	unsigned long obj_allocated, obj_used, pages_used;
> +	unsigned long total_objs = 0, total_used_objs = 0, total_pages = 0;
> +
> +	seq_printf(s, " %5s %5s %13s %10s %10s\n", "class", "size",
> +				"obj_allocated", "obj_used", "pages_used");
> +
> +	for (i = 0; i < zs_size_classes; i++) {
> +		class = pool->size_class[i];
> +
> +		if (class->index != i)
> +			continue;
> +
> +		spin_lock(&class->lock);
> +		obj_allocated = zs_stat_get(class, OBJ_ALLOCATED);
> +		obj_used = zs_stat_get(class, OBJ_USED);
> +		spin_unlock(&class->lock);
> +
> +		objs_per_zspage = get_maxobj_per_zspage(class->size,
> +				class->pages_per_zspage);
> +		pages_used = obj_allocated / objs_per_zspage *
> +				class->pages_per_zspage;
> +
> +		seq_printf(s, " %5u %5u    %10lu %10lu %10lu\n", i,
> +			class->size, obj_allocated, obj_used, pages_used);
> +
> +		total_objs += obj_allocated;
> +		total_used_objs += obj_used;
> +		total_pages += pages_used;
> +	}
> +
> +	seq_puts(s, "\n");
> +	seq_printf(s, " %5s %5s    %10lu %10lu %10lu\n", "Total", "",
> +			total_objs, total_used_objs, total_pages);
> +
> +	return 0;
> +}
>
> ...
>
> +static int zs_pool_stat_create(struct zs_pool *pool)
> +{
> +	char name[10];

This is not good.  If the kernel creates and then destroys a pool 10000
times, zs_pool_index==10000 and we overrun the buffer.  Could use
kasprintf() in here to fix this.

zs_pool_index isn't a very good name - it doesn't index anything. 
zs_pool_id would be better.

> +	struct dentry *entry;
> +
> +	if (!zs_stat_root)
> +		return -ENODEV;
> +
> +	pool->index = atomic_inc_return(&zs_pool_index);
> +	snprintf(name, sizeof(name), "pool-%d", pool->index);
> +	entry = debugfs_create_dir(name, zs_stat_root);
> +	if (!entry) {
> +		pr_warn("pool %d, debugfs dir <%s> creation failed\n",
> +				pool->index, name);
> +		return -ENOMEM;

Sigh.  The debugfs interface does suck.  Doesn't matter much.

> +	}
> +	pool->stat_dentry = entry;
> +
> +	entry = debugfs_create_file("obj_in_classes", S_IFREG | S_IRUGO,
> +			pool->stat_dentry, pool, &zs_stat_size_ops);
> +	if (!entry) {
> +		pr_warn("pool %d, debugfs file entry <%s> creation failed\n",
> +				pool->index, "obj_in_classes");
> +		return -ENOMEM;
> +	}
> +
> +	return 0;
> +}
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
