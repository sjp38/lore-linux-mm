Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id B0FAA6B0038
	for <linux-mm@kvack.org>; Sun, 28 Dec 2014 19:08:12 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id ft15so15867015pdb.8
        for <linux-mm@kvack.org>; Sun, 28 Dec 2014 16:08:12 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ot2si23535511pbb.123.2014.12.28.16.08.09
        for <linux-mm@kvack.org>;
        Sun, 28 Dec 2014 16:08:10 -0800 (PST)
Date: Mon, 29 Dec 2014 09:10:13 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm/zsmalloc: add statistics support
Message-ID: <20141229001013.GB27095@bbox>
References: <1419599180-4422-1-git-send-email-opensource.ganesh@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1419599180-4422-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: ngupta@vflare.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Dec 26, 2014 at 09:06:20PM +0800, Ganesh Mahendran wrote:
> Keeping fragmentation of zsmalloc in a low level is our target. But now
> we still need to add the debug code in zsmalloc to get the quantitative data.
> 
> This patch adds a new configuration CONFIG_ZSMALLOC_STAT to enable the
> statistics collection for developers. Currently only the objects statatitics
> in each class are collected. User can get the information via debugfs.
>      cat /sys/kernel/debug/zsmalloc/zram0/...
> 
> For example:
> 
> After I copied "jdk-8u25-linux-x64.tar.gz" to zram with ext4 filesystem:
>  class  size obj_allocated   obj_used pages_used
>      0    32             0          0          0
>      1    48           256         12          3
>      2    64            64         14          1
>      3    80            51          7          1
>      4    96           128          5          3
>      5   112            73          5          2
>      6   128            32          4          1
>      7   144             0          0          0
>      8   160             0          0          0
>      9   176             0          0          0
>     10   192             0          0          0
>     11   208             0          0          0
>     12   224             0          0          0
>     13   240             0          0          0
>     14   256            16          1          1
>     15   272            15          9          1
>     16   288             0          0          0
>     17   304             0          0          0
>     18   320             0          0          0
>     19   336             0          0          0
>     20   352             0          0          0
>     21   368             0          0          0
>     22   384             0          0          0
>     23   400             0          0          0
>     24   416             0          0          0
>     25   432             0          0          0
>     26   448             0          0          0
>     27   464             0          0          0
>     28   480             0          0          0
>     29   496            33          1          4
>     30   512             0          0          0
>     31   528             0          0          0
>     32   544             0          0          0
>     33   560             0          0          0
>     34   576             0          0          0
>     35   592             0          0          0
>     36   608             0          0          0
>     37   624             0          0          0
>     38   640             0          0          0
>     40   672             0          0          0
>     42   704             0          0          0
>     43   720            17          1          3
>     44   736             0          0          0
>     46   768             0          0          0
>     49   816             0          0          0
>     51   848             0          0          0
>     52   864            14          1          3
>     54   896             0          0          0
>     57   944            13          1          3
>     58   960             0          0          0
>     62  1024             4          1          1
>     66  1088            15          2          4
>     67  1104             0          0          0
>     71  1168             0          0          0
>     74  1216             0          0          0
>     76  1248             0          0          0
>     83  1360             3          1          1
>     91  1488            11          1          4
>     94  1536             0          0          0
>    100  1632             5          1          2
>    107  1744             0          0          0
>    111  1808             9          1          4
>    126  2048             4          4          2
>    144  2336             7          3          4
>    151  2448             0          0          0
>    168  2720            15         15         10
>    190  3072            28         27         21
>    202  3264             0          0          0
>    254  4096         36209      36209      36209
> 
>  Total               37022      36326      36288
> 
> We can calculate the overall fragentation by the last line:
>     Total               37022      36326      36288
>     (37022 - 36326) / 37022 = 1.87%
> 
> Also by analysing objects alocated in every class we know why we got so low fragmentation:
>     Most of the allocated objects is in <class 254>. And there is only 1 page in class
>     254 zspage.  So, No fragmentation will be introduced by allocating objs in class 254.
> 
> And in the future, we can collect other zsmalloc statistics as we need and analyse them.
> 
> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> Suggested-by: Minchan Kim <minchan@kernel.org>
> Cc: Nitin Gupta <ngupta@vflare.org>

If you fix minors below,
Acked-by: Minchan Kim <minchan@kernel.org>

> ---
>  mm/Kconfig    |   10 +++
>  mm/zsmalloc.c |  244 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  2 files changed, 250 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 1d1ae6b..95c5728 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -601,6 +601,16 @@ config PGTABLE_MAPPING
>  	  You can check speed with zsmalloc benchmark:
>  	  https://github.com/spartacus06/zsmapbench
>  
> +config ZSMALLOC_STAT
> +	bool "Export zsmalloc statistics"
> +	depends on ZSMALLOC
> +	select DEBUG_FS
> +	help
> +	  This option enables code in the zsmalloc to collect various
> +	  statistics about whats happening in zsmalloc and exports that
> +	  information to userspace via debugfs.
> +	  If unsure, say N.
> +
>  config GENERIC_EARLY_IOREMAP
>  	bool
>  
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 2359e61..f5ae7c6 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -91,6 +91,7 @@
>  #include <linux/hardirq.h>
>  #include <linux/spinlock.h>
>  #include <linux/types.h>
> +#include <linux/debugfs.h>
>  #include <linux/zsmalloc.h>
>  #include <linux/zpool.h>
>  
> @@ -168,6 +169,22 @@ enum fullness_group {
>  	ZS_FULL
>  };
>  
> +enum zs_stat_type {
> +	OBJ_ALLOCATED,
> +	OBJ_USED,
> +};
> +
> +#ifdef CONFIG_ZSMALLOC_STAT
> +
> +static struct dentry *zs_stat_root;
> +
> +struct zs_size_stat {
> +	unsigned long obj_allocated;
> +	unsigned long obj_used;
> +};

I hope you makes it array so that we could use zs_stat_type as index.
It could remove if-conditions in zs_stat_xxx.

> +
> +#endif
> +
>  /*
>   * number of size_classes
>   */
> @@ -200,6 +217,10 @@ struct size_class {
>  	/* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
>  	int pages_per_zspage;
>  
> +#ifdef CONFIG_ZSMALLOC_STAT
> +	struct zs_size_stat stats;
> +#endif
> +
>  	spinlock_t lock;
>  
>  	struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
> @@ -217,10 +238,16 @@ struct link_free {
>  };
>  
>  struct zs_pool {
> +	char *name;
> +
>  	struct size_class **size_class;
>  
>  	gfp_t flags;	/* allocation flags used when growing pool */
>  	atomic_long_t pages_allocated;
> +
> +#ifdef CONFIG_ZSMALLOC_STAT
> +	struct dentry *stat_dentry;
> +#endif
>  };
>  
>  /*
> @@ -942,6 +969,177 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
>  	return true;
>  }
>  
> +#ifdef CONFIG_ZSMALLOC_STAT
> +
> +static inline void zs_stat_inc(struct size_class *class,
> +				enum zs_stat_type type, unsigned long cnt)
> +{
> +	if (type == OBJ_ALLOCATED)
> +		class->stats.obj_allocated += cnt;
> +	else if (type == OBJ_USED)
> +		class->stats.obj_used += cnt;
> +}
> +
> +static inline void zs_stat_dec(struct size_class *class,
> +				enum zs_stat_type type, unsigned long cnt)
> +{
> +	if (type == OBJ_ALLOCATED)
> +		class->stats.obj_allocated -= cnt;
> +	else if (type == OBJ_USED)
> +		class->stats.obj_used -= cnt;
> +}
> +
> +static inline unsigned long zs_stat_get(struct size_class *class,
> +				enum zs_stat_type type)
> +{
> +	if (type == OBJ_ALLOCATED)
> +		return class->stats.obj_allocated;
> +	else if (type == OBJ_USED)
> +		return class->stats.obj_used;
> +
> +	return 0;
> +}
> +
> +static int __init zs_stat_init(void)
> +{
> +	if (!debugfs_initialized())
> +		return -ENODEV;
> +
> +	zs_stat_root = debugfs_create_dir("zsmalloc", NULL);
> +	if (!zs_stat_root)
> +		return -ENOMEM;
> +
> +	return 0;
> +}
> +
> +static void __exit zs_stat_exit(void)
> +{
> +	debugfs_remove_recursive(zs_stat_root);
> +}
> +
> +static int zs_stats_size_show(struct seq_file *s, void *v)
> +{
> +	int i;
> +	struct zs_pool *pool = s->private;
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
> +
> +static int zs_stats_size_open(struct inode *inode, struct file *file)
> +{
> +	return single_open(file, zs_stats_size_show, inode->i_private);
> +}
> +
> +static const struct file_operations zs_stat_size_ops = {
> +	.open           = zs_stats_size_open,
> +	.read           = seq_read,
> +	.llseek         = seq_lseek,
> +	.release        = single_release,
> +};
> +
> +static int zs_pool_stat_create(char *name, struct zs_pool *pool)
> +{
> +	struct dentry *entry;
> +
> +	if (!zs_stat_root)
> +		return -ENODEV;
> +
> +	entry = debugfs_create_dir(name, zs_stat_root);
> +	if (!entry) {
> +		pr_warn("debugfs dir <%s> creation failed\n", name);
> +		return -ENOMEM;
> +	}
> +	pool->stat_dentry = entry;
> +
> +	entry = debugfs_create_file("obj_in_classes", S_IFREG | S_IRUGO,
> +			pool->stat_dentry, pool, &zs_stat_size_ops);
> +	if (!entry) {
> +		pr_warn("%s: debugfs file entry <%s> creation failed\n",
> +				name, "obj_in_classes");
> +		return -ENOMEM;
> +	}
> +
> +	return 0;
> +}
> +
> +static void zs_pool_stat_destroy(struct zs_pool *pool)
> +{
> +	debugfs_remove_recursive(pool->stat_dentry);
> +}
> +
> +#else /* CONFIG_ZSMALLOC_STAT */
> +
> +static inline void zs_stat_inc(struct size_class *class,
> +				enum zs_stat_type type, unsigned long cnt)
> +{
> +}
> +
> +static inline void zs_stat_dec(struct size_class *class,
> +				enum zs_stat_type type, unsigned long cnt)
> +{
> +}
> +
> +static inline unsigned long zs_stat_get(struct size_class *class,
> +				enum zs_stat_type type)
> +{
> +	return 0;
> +}
> +
> +static int __init zs_stat_init(void)
> +{
> +	return 0;
> +}
> +
> +static void __exit zs_stat_exit(void)
> +{
> +}
> +
> +static inline int zs_pool_stat_create(struct zs_pool *pool)

                                         char *name, struct zs_pool *pool

Thanks for the nice work, Ganesh!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
