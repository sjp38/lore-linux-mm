Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 834A26B0026
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:06:30 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 1-v6so1724869plv.6
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 06:06:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l5si2523001pgn.723.2018.03.28.06.06.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Mar 2018 06:06:29 -0700 (PDT)
Date: Wed, 28 Mar 2018 15:06:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Use octal not symbolic permissions
Message-ID: <20180328130623.GB8976@dhcp22.suse.cz>
References: <2e032ef111eebcd4c5952bae86763b541d373469.1522102887.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2e032ef111eebcd4c5952bae86763b541d373469.1522102887.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 26-03-18 15:22:32, Joe Perches wrote:
> mm/*.c files use symbolic and octal styles for permissions.
> 
> Using octal and not symbolic permissions is preferred by many as more
> readable.
> 
> https://lkml.org/lkml/2016/8/2/1945
> 
> Prefer the direct use of octal for permissions.
> 
> Done using
> $ scripts/checkpatch.pl -f --types=SYMBOLIC_PERMS --fix-inplace mm/*.c
> and some typing.
> 
> Before:	 $ git grep -P -w "0[0-7]{3,3}" mm | wc -l
> 44
> After:	 $ git grep -P -w "0[0-7]{3,3}" mm | wc -l
> 86

Ohh, I absolutely detest those symbolic names. I always have to check
what they actually mean to be sure. Octal representation is quite
natural to read. So for once I am really happy about such a clean up
change.

Btw. something like this should be quite easy to automate via
coccinelle AFAIU. 

> Miscellanea:
> 
> o Whitespace neatening around these conversions.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

I hope I haven't overlooked any potential mismatch...

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/cleancache.c  | 10 ++++------
>  mm/cma_debug.c   | 25 ++++++++++---------------
>  mm/compaction.c  |  2 +-
>  mm/dmapool.c     |  2 +-
>  mm/failslab.c    |  2 +-
>  mm/frontswap.c   | 11 +++++------
>  mm/memblock.c    |  9 ++++++---
>  mm/page_alloc.c  |  2 +-
>  mm/page_idle.c   |  2 +-
>  mm/page_owner.c  |  4 ++--
>  mm/shmem.c       |  9 +++++----
>  mm/slab_common.c |  4 ++--
>  mm/vmalloc.c     |  2 +-
>  mm/zsmalloc.c    |  5 +++--
>  mm/zswap.c       | 38 +++++++++++++++++++-------------------
>  15 files changed, 62 insertions(+), 65 deletions(-)
> 
> diff --git a/mm/cleancache.c b/mm/cleancache.c
> index f7b9fdc79d97..60d65448f4d0 100644
> --- a/mm/cleancache.c
> +++ b/mm/cleancache.c
> @@ -307,12 +307,10 @@ static int __init init_cleancache(void)
>  	struct dentry *root = debugfs_create_dir("cleancache", NULL);
>  	if (root == NULL)
>  		return -ENXIO;
> -	debugfs_create_u64("succ_gets", S_IRUGO, root, &cleancache_succ_gets);
> -	debugfs_create_u64("failed_gets", S_IRUGO,
> -				root, &cleancache_failed_gets);
> -	debugfs_create_u64("puts", S_IRUGO, root, &cleancache_puts);
> -	debugfs_create_u64("invalidates", S_IRUGO,
> -				root, &cleancache_invalidates);
> +	debugfs_create_u64("succ_gets", 0444, root, &cleancache_succ_gets);
> +	debugfs_create_u64("failed_gets", 0444, root, &cleancache_failed_gets);
> +	debugfs_create_u64("puts", 0444, root, &cleancache_puts);
> +	debugfs_create_u64("invalidates", 0444, root, &cleancache_invalidates);
>  #endif
>  	return 0;
>  }
> diff --git a/mm/cma_debug.c b/mm/cma_debug.c
> index 275df8b5b22e..f23467291cfb 100644
> --- a/mm/cma_debug.c
> +++ b/mm/cma_debug.c
> @@ -172,23 +172,18 @@ static void cma_debugfs_add_one(struct cma *cma, int idx)
>  
>  	tmp = debugfs_create_dir(name, cma_debugfs_root);
>  
> -	debugfs_create_file("alloc", S_IWUSR, tmp, cma,
> -				&cma_alloc_fops);
> -
> -	debugfs_create_file("free", S_IWUSR, tmp, cma,
> -				&cma_free_fops);
> -
> -	debugfs_create_file("base_pfn", S_IRUGO, tmp,
> -				&cma->base_pfn, &cma_debugfs_fops);
> -	debugfs_create_file("count", S_IRUGO, tmp,
> -				&cma->count, &cma_debugfs_fops);
> -	debugfs_create_file("order_per_bit", S_IRUGO, tmp,
> -				&cma->order_per_bit, &cma_debugfs_fops);
> -	debugfs_create_file("used", S_IRUGO, tmp, cma, &cma_used_fops);
> -	debugfs_create_file("maxchunk", S_IRUGO, tmp, cma, &cma_maxchunk_fops);
> +	debugfs_create_file("alloc", 0200, tmp, cma, &cma_alloc_fops);
> +	debugfs_create_file("free", 0200, tmp, cma, &cma_free_fops);
> +	debugfs_create_file("base_pfn", 0444, tmp,
> +			    &cma->base_pfn, &cma_debugfs_fops);
> +	debugfs_create_file("count", 0444, tmp, &cma->count, &cma_debugfs_fops);
> +	debugfs_create_file("order_per_bit", 0444, tmp,
> +			    &cma->order_per_bit, &cma_debugfs_fops);
> +	debugfs_create_file("used", 0444, tmp, cma, &cma_used_fops);
> +	debugfs_create_file("maxchunk", 0444, tmp, cma, &cma_maxchunk_fops);
>  
>  	u32s = DIV_ROUND_UP(cma_bitmap_maxno(cma), BITS_PER_BYTE * sizeof(u32));
> -	debugfs_create_u32_array("bitmap", S_IRUGO, tmp, (u32*)cma->bitmap, u32s);
> +	debugfs_create_u32_array("bitmap", 0444, tmp, (u32 *)cma->bitmap, u32s);
>  }
>  
>  static int __init cma_debugfs_init(void)
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 028b7210a669..1dd3e6b2d19e 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1897,7 +1897,7 @@ static ssize_t sysfs_compact_node(struct device *dev,
>  
>  	return count;
>  }
> -static DEVICE_ATTR(compact, S_IWUSR, NULL, sysfs_compact_node);
> +static DEVICE_ATTR(compact, 0200, NULL, sysfs_compact_node);
>  
>  int compaction_register_node(struct node *node)
>  {
> diff --git a/mm/dmapool.c b/mm/dmapool.c
> index 4d90a64b2fdc..6d4b97e7e9e9 100644
> --- a/mm/dmapool.c
> +++ b/mm/dmapool.c
> @@ -105,7 +105,7 @@ show_pools(struct device *dev, struct device_attribute *attr, char *buf)
>  	return PAGE_SIZE - size;
>  }
>  
> -static DEVICE_ATTR(pools, S_IRUGO, show_pools, NULL);
> +static DEVICE_ATTR(pools, 0444, show_pools, NULL);
>  
>  /**
>   * dma_pool_create - Creates a pool of consistent memory blocks, for dma.
> diff --git a/mm/failslab.c b/mm/failslab.c
> index 1f2f248e3601..b135ebb88b6f 100644
> --- a/mm/failslab.c
> +++ b/mm/failslab.c
> @@ -42,7 +42,7 @@ __setup("failslab=", setup_failslab);
>  static int __init failslab_debugfs_init(void)
>  {
>  	struct dentry *dir;
> -	umode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
> +	umode_t mode = S_IFREG | 0600;
>  
>  	dir = fault_create_debugfs_attr("failslab", NULL, &failslab.attr);
>  	if (IS_ERR(dir))
> diff --git a/mm/frontswap.c b/mm/frontswap.c
> index fec8b5044040..89942a323767 100644
> --- a/mm/frontswap.c
> +++ b/mm/frontswap.c
> @@ -486,12 +486,11 @@ static int __init init_frontswap(void)
>  	struct dentry *root = debugfs_create_dir("frontswap", NULL);
>  	if (root == NULL)
>  		return -ENXIO;
> -	debugfs_create_u64("loads", S_IRUGO, root, &frontswap_loads);
> -	debugfs_create_u64("succ_stores", S_IRUGO, root, &frontswap_succ_stores);
> -	debugfs_create_u64("failed_stores", S_IRUGO, root,
> -				&frontswap_failed_stores);
> -	debugfs_create_u64("invalidates", S_IRUGO,
> -				root, &frontswap_invalidates);
> +	debugfs_create_u64("loads", 0444, root, &frontswap_loads);
> +	debugfs_create_u64("succ_stores", 0444, root, &frontswap_succ_stores);
> +	debugfs_create_u64("failed_stores", 0444, root,
> +			   &frontswap_failed_stores);
> +	debugfs_create_u64("invalidates", 0444, root, &frontswap_invalidates);
>  #endif
>  	return 0;
>  }
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 9b04568ad42a..8078eb8b5088 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -1803,10 +1803,13 @@ static int __init memblock_init_debugfs(void)
>  	struct dentry *root = debugfs_create_dir("memblock", NULL);
>  	if (!root)
>  		return -ENXIO;
> -	debugfs_create_file("memory", S_IRUGO, root, &memblock.memory, &memblock_debug_fops);
> -	debugfs_create_file("reserved", S_IRUGO, root, &memblock.reserved, &memblock_debug_fops);
> +	debugfs_create_file("memory", 0444, root,
> +			    &memblock.memory, &memblock_debug_fops);
> +	debugfs_create_file("reserved", 0444, root,
> +			    &memblock.reserved, &memblock_debug_fops);
>  #ifdef CONFIG_HAVE_MEMBLOCK_PHYS_MAP
> -	debugfs_create_file("physmem", S_IRUGO, root, &memblock.physmem, &memblock_debug_fops);
> +	debugfs_create_file("physmem", 0444, root,
> +			    &memblock.physmem, &memblock_debug_fops);
>  #endif
>  
>  	return 0;
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 905db9d7962f..fe827b099fb3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3086,7 +3086,7 @@ static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
>  
>  static int __init fail_page_alloc_debugfs(void)
>  {
> -	umode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
> +	umode_t mode = S_IFREG | 0600;
>  	struct dentry *dir;
>  
>  	dir = fault_create_debugfs_attr("fail_page_alloc", NULL,
> diff --git a/mm/page_idle.c b/mm/page_idle.c
> index e412a63b2b74..6302bc62c27d 100644
> --- a/mm/page_idle.c
> +++ b/mm/page_idle.c
> @@ -201,7 +201,7 @@ static ssize_t page_idle_bitmap_write(struct file *file, struct kobject *kobj,
>  }
>  
>  static struct bin_attribute page_idle_bitmap_attr =
> -		__BIN_ATTR(bitmap, S_IRUSR | S_IWUSR,
> +		__BIN_ATTR(bitmap, 0600,
>  			   page_idle_bitmap_read, page_idle_bitmap_write, 0);
>  
>  static struct bin_attribute *page_idle_bin_attrs[] = {
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 77d9e791ae8a..c2494f034d02 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -631,8 +631,8 @@ static int __init pageowner_init(void)
>  		return 0;
>  	}
>  
> -	dentry = debugfs_create_file("page_owner", S_IRUSR, NULL,
> -			NULL, &proc_page_owner_operations);
> +	dentry = debugfs_create_file("page_owner", 0400, NULL,
> +				     NULL, &proc_page_owner_operations);
>  
>  	return PTR_ERR_OR_ZERO(dentry);
>  }
> diff --git a/mm/shmem.c b/mm/shmem.c
> index a9b6d536b6f1..1d9b4c998738 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2998,7 +2998,8 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
>  	if (len > PAGE_SIZE)
>  		return -ENAMETOOLONG;
>  
> -	inode = shmem_get_inode(dir->i_sb, dir, S_IFLNK|S_IRWXUGO, 0, VM_NORESERVE);
> +	inode = shmem_get_inode(dir->i_sb, dir, S_IFLNK | 0777, 0,
> +				VM_NORESERVE);
>  	if (!inode)
>  		return -ENOSPC;
>  
> @@ -3421,7 +3422,7 @@ static int shmem_show_options(struct seq_file *seq, struct dentry *root)
>  			sbinfo->max_blocks << (PAGE_SHIFT - 10));
>  	if (sbinfo->max_inodes != shmem_default_max_inodes())
>  		seq_printf(seq, ",nr_inodes=%lu", sbinfo->max_inodes);
> -	if (sbinfo->mode != (S_IRWXUGO | S_ISVTX))
> +	if (sbinfo->mode != (0777 | S_ISVTX))
>  		seq_printf(seq, ",mode=%03ho", sbinfo->mode);
>  	if (!uid_eq(sbinfo->uid, GLOBAL_ROOT_UID))
>  		seq_printf(seq, ",uid=%u",
> @@ -3461,7 +3462,7 @@ int shmem_fill_super(struct super_block *sb, void *data, int silent)
>  	if (!sbinfo)
>  		return -ENOMEM;
>  
> -	sbinfo->mode = S_IRWXUGO | S_ISVTX;
> +	sbinfo->mode = 0777 | S_ISVTX;
>  	sbinfo->uid = current_fsuid();
>  	sbinfo->gid = current_fsgid();
>  	sb->s_fs_info = sbinfo;
> @@ -3904,7 +3905,7 @@ static struct file *__shmem_file_setup(struct vfsmount *mnt, const char *name, l
>  	d_set_d_op(path.dentry, &anon_ops);
>  
>  	res = ERR_PTR(-ENOSPC);
> -	inode = shmem_get_inode(sb, NULL, S_IFREG | S_IRWXUGO, 0, flags);
> +	inode = shmem_get_inode(sb, NULL, S_IFREG | 0777, 0, flags);
>  	if (!inode)
>  		goto put_memory;
>  
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 61ab2ca8bea7..d315e6cb4b61 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1231,9 +1231,9 @@ void cache_random_seq_destroy(struct kmem_cache *cachep)
>  
>  #if defined(CONFIG_SLAB) || defined(CONFIG_SLUB_DEBUG)
>  #ifdef CONFIG_SLAB
> -#define SLABINFO_RIGHTS (S_IWUSR | S_IRUSR)
> +#define SLABINFO_RIGHTS (0600)
>  #else
> -#define SLABINFO_RIGHTS S_IRUSR
> +#define SLABINFO_RIGHTS (0400)
>  #endif
>  
>  static void print_slabinfo_header(struct seq_file *m)
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index ebff729cc956..7d11db35e350 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -2769,7 +2769,7 @@ static const struct file_operations proc_vmalloc_operations = {
>  
>  static int __init proc_vmalloc_init(void)
>  {
> -	proc_create("vmallocinfo", S_IRUSR, NULL, &proc_vmalloc_operations);
> +	proc_create("vmallocinfo", 0400, NULL, &proc_vmalloc_operations);
>  	return 0;
>  }
>  module_init(proc_vmalloc_init);
> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> index 61cb05dc950c..8d87e973a4f5 100644
> --- a/mm/zsmalloc.c
> +++ b/mm/zsmalloc.c
> @@ -661,8 +661,9 @@ static void zs_pool_stat_create(struct zs_pool *pool, const char *name)
>  	}
>  	pool->stat_dentry = entry;
>  
> -	entry = debugfs_create_file("classes", S_IFREG | S_IRUGO,
> -			pool->stat_dentry, pool, &zs_stats_size_fops);
> +	entry = debugfs_create_file("classes", S_IFREG | 0444,
> +				    pool->stat_dentry, pool,
> +				    &zs_stats_size_fops);
>  	if (!entry) {
>  		pr_warn("%s: debugfs file entry <%s> creation failed\n",
>  				name, "classes");
> diff --git a/mm/zswap.c b/mm/zswap.c
> index 61a5c41972db..7d34e69507e3 100644
> --- a/mm/zswap.c
> +++ b/mm/zswap.c
> @@ -1256,26 +1256,26 @@ static int __init zswap_debugfs_init(void)
>  	if (!zswap_debugfs_root)
>  		return -ENOMEM;
>  
> -	debugfs_create_u64("pool_limit_hit", S_IRUGO,
> -			zswap_debugfs_root, &zswap_pool_limit_hit);
> -	debugfs_create_u64("reject_reclaim_fail", S_IRUGO,
> -			zswap_debugfs_root, &zswap_reject_reclaim_fail);
> -	debugfs_create_u64("reject_alloc_fail", S_IRUGO,
> -			zswap_debugfs_root, &zswap_reject_alloc_fail);
> -	debugfs_create_u64("reject_kmemcache_fail", S_IRUGO,
> -			zswap_debugfs_root, &zswap_reject_kmemcache_fail);
> -	debugfs_create_u64("reject_compress_poor", S_IRUGO,
> -			zswap_debugfs_root, &zswap_reject_compress_poor);
> -	debugfs_create_u64("written_back_pages", S_IRUGO,
> -			zswap_debugfs_root, &zswap_written_back_pages);
> -	debugfs_create_u64("duplicate_entry", S_IRUGO,
> -			zswap_debugfs_root, &zswap_duplicate_entry);
> -	debugfs_create_u64("pool_total_size", S_IRUGO,
> -			zswap_debugfs_root, &zswap_pool_total_size);
> -	debugfs_create_atomic_t("stored_pages", S_IRUGO,
> -			zswap_debugfs_root, &zswap_stored_pages);
> +	debugfs_create_u64("pool_limit_hit", 0444,
> +			   zswap_debugfs_root, &zswap_pool_limit_hit);
> +	debugfs_create_u64("reject_reclaim_fail", 0444,
> +			   zswap_debugfs_root, &zswap_reject_reclaim_fail);
> +	debugfs_create_u64("reject_alloc_fail", 0444,
> +			   zswap_debugfs_root, &zswap_reject_alloc_fail);
> +	debugfs_create_u64("reject_kmemcache_fail", 0444,
> +			   zswap_debugfs_root, &zswap_reject_kmemcache_fail);
> +	debugfs_create_u64("reject_compress_poor", 0444,
> +			   zswap_debugfs_root, &zswap_reject_compress_poor);
> +	debugfs_create_u64("written_back_pages", 0444,
> +			   zswap_debugfs_root, &zswap_written_back_pages);
> +	debugfs_create_u64("duplicate_entry", 0444,
> +			   zswap_debugfs_root, &zswap_duplicate_entry);
> +	debugfs_create_u64("pool_total_size", 0444,
> +			   zswap_debugfs_root, &zswap_pool_total_size);
> +	debugfs_create_atomic_t("stored_pages", 0444,
> +				zswap_debugfs_root, &zswap_stored_pages);
>  	debugfs_create_atomic_t("same_filled_pages", 0444,
> -			zswap_debugfs_root, &zswap_same_filled_pages);
> +				zswap_debugfs_root, &zswap_same_filled_pages);
>  
>  	return 0;
>  }
> -- 
> 2.15.0

-- 
Michal Hocko
SUSE Labs
