Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C89AF6B02B4
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 16:24:48 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id t10so85967425qte.14
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 13:24:48 -0700 (PDT)
Received: from mail-qt0-f181.google.com (mail-qt0-f181.google.com. [209.85.216.181])
        by mx.google.com with ESMTPS id 38si14194300qkp.394.2017.06.20.13.24.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 13:24:47 -0700 (PDT)
Received: by mail-qt0-f181.google.com with SMTP id u12so142632361qth.0
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 13:24:47 -0700 (PDT)
Subject: Re: [PATCH 22/23] usercopy: split user-controlled slabs to separate
 caches
References: <1497915397-93805-1-git-send-email-keescook@chromium.org>
 <1497915397-93805-23-git-send-email-keescook@chromium.org>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <06bde73d-ca3c-8f91-0142-ddf3af99875e@redhat.com>
Date: Tue, 20 Jun 2017 13:24:40 -0700
MIME-Version: 1.0
In-Reply-To: <1497915397-93805-23-git-send-email-keescook@chromium.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, kernel-hardening@lists.openwall.com
Cc: David Windsor <dave@nullcore.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/19/2017 04:36 PM, Kees Cook wrote:
> From: David Windsor <dave@nullcore.net>
> 
> Some userspace APIs (e.g. ipc, seq_file) provide precise control over
> the size of kernel kmallocs, which provides a trivial way to perform
> heap overflow attacks where the attacker must control neighboring
> allocations of a specific size. Instead, move these APIs into their own
> cache so they cannot interfere with standard kmallocs. This is enabled
> with CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC.
> 
> This patch is modified from Brad Spengler/PaX Team's PAX_USERCOPY_SLABS
> code in the last public patch of grsecurity/PaX based on my understanding
> of the code. Changes or omissions from the original code are mine and
> don't reflect the original grsecurity/PaX code.
> 
> Signed-off-by: David Windsor <dave@nullcore.net>
> [kees: added SLAB_NO_MERGE flag to allow split of future no-merge Kconfig]
> Signed-off-by: Kees Cook <keescook@chromium.org>

I just did a quick test of kspp/usercopy-whitelist/lateston my arm64 machine and got some spew:

[   21.818719] Unexpected gfp: 0x4000000 (0x4000000). Fixing up to gfp: 0x14000c0 (GFP_KERNEL). Fix your code!
[   21.828427] CPU: 7 PID: 652 Comm: irqbalance Tainted: G        W       4.12.0-rc5-whitelist+ #236
[   21.837259] Hardware name: AppliedMicro X-Gene Mustang Board/X-Gene Mustang Board, BIOS 3.06.12 Aug 12 2016
[   21.846955] Call trace:
[   21.849396] [<ffff000008089b18>] dump_backtrace+0x0/0x210
[   21.854770] [<ffff000008089d4c>] show_stack+0x24/0x30
[   21.859798] [<ffff00000845b7bc>] dump_stack+0x90/0xb4
[   21.864827] [<ffff00000826ff40>] new_slab+0x88/0x90
[   21.869681] [<ffff000008272218>] ___slab_alloc+0x428/0x6b0
[   21.875141] [<ffff0000082724f0>] __slab_alloc+0x50/0x68
[   21.880341] [<ffff000008273208>] __kmalloc_node+0xd0/0x348
[   21.885800] [<ffff000008223af0>] kvmalloc_node+0xa0/0xb8
[   21.891088] [<ffff0000082bb400>] single_open_size+0x40/0xb0
[   21.896636] [<ffff000008315a9c>] stat_open+0x54/0x60
[   21.901576] [<ffff00000830adf8>] proc_reg_open+0x90/0x168
[   21.906950] [<ffff00000828def4>] do_dentry_open+0x1c4/0x328
[   21.912496] [<ffff00000828f470>] vfs_open+0x58/0x88
[   21.917351] [<ffff0000082a1f14>] do_last+0x3d4/0x770
[   21.922292] [<ffff0000082a233c>] path_openat+0x8c/0x2e8
[   21.927492] [<ffff0000082a3888>] do_filp_open+0x70/0xe8
[   21.932692] [<ffff00000828f940>] do_sys_open+0x178/0x208
[   21.937977] [<ffff00000828fa54>] SyS_openat+0x3c/0x50
[   21.943005] [<ffff0000080835f0>] el0_svc_naked+0x24/0x28


I don't think 7e7844226f10 ("lockdep: allow to disable reclaim lockup detection")
is correct after new flags are added because we will still need space
for another bit even if lockdep is disabled. That might need to
be fixed separately.

I'm really not a fan the GFP approach though since the flags tend
to be a little bit fragile to manage. If we're going to have to
add something to callsites anyway, maybe we could just have an
alternate function (kmalloc_user?) instead of a GFP flag.


> ---
>  fs/seq_file.c        |  2 +-
>  include/linux/gfp.h  |  9 ++++++++-
>  include/linux/slab.h | 12 ++++++++++++
>  ipc/msgutil.c        |  5 +++--
>  mm/slab.h            |  3 ++-
>  mm/slab_common.c     | 29 ++++++++++++++++++++++++++++-
>  security/Kconfig     | 12 ++++++++++++
>  7 files changed, 66 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/seq_file.c b/fs/seq_file.c
> index dc7c2be963ed..5caa58a19bdc 100644
> --- a/fs/seq_file.c
> +++ b/fs/seq_file.c
> @@ -25,7 +25,7 @@ static void seq_set_overflow(struct seq_file *m)
>  
>  static void *seq_buf_alloc(unsigned long size)
>  {
> -	return kvmalloc(size, GFP_KERNEL);
> +	return kvmalloc(size, GFP_KERNEL | GFP_USERCOPY);
>  }
>  
>  /**
> diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> index a89d37e8b387..ff4f4a698ad0 100644
> --- a/include/linux/gfp.h
> +++ b/include/linux/gfp.h
> @@ -45,6 +45,7 @@ struct vm_area_struct;
>  #else
>  #define ___GFP_NOLOCKDEP	0
>  #endif
> +#define ___GFP_USERCOPY		0x4000000u
>  /* If the above are modified, __GFP_BITS_SHIFT may need updating */
>  
>  /*
> @@ -83,12 +84,17 @@ struct vm_area_struct;
>   *   node with no fallbacks or placement policy enforcements.
>   *
>   * __GFP_ACCOUNT causes the allocation to be accounted to kmemcg.
> + *
> + * __GFP_USERCOPY indicates that the page will be explicitly copied to/from
> + *   userspace, and may be allocated from a separate kmalloc pool.
> + *
>   */
>  #define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE)
>  #define __GFP_WRITE	((__force gfp_t)___GFP_WRITE)
>  #define __GFP_HARDWALL   ((__force gfp_t)___GFP_HARDWALL)
>  #define __GFP_THISNODE	((__force gfp_t)___GFP_THISNODE)
>  #define __GFP_ACCOUNT	((__force gfp_t)___GFP_ACCOUNT)
> +#define __GFP_USERCOPY	((__force gfp_t)___GFP_USERCOPY)
>  
>  /*
>   * Watermark modifiers -- controls access to emergency reserves
> @@ -188,7 +194,7 @@ struct vm_area_struct;
>  #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
>  
>  /* Room for N __GFP_FOO bits */
> -#define __GFP_BITS_SHIFT (25 + IS_ENABLED(CONFIG_LOCKDEP))
> +#define __GFP_BITS_SHIFT (26 + IS_ENABLED(CONFIG_LOCKDEP))
>  #define __GFP_BITS_MASK ((__force gfp_t)((1 << __GFP_BITS_SHIFT) - 1))
>  
>  /*
> @@ -268,6 +274,7 @@ struct vm_area_struct;
>  #define GFP_TRANSHUGE_LIGHT	((GFP_HIGHUSER_MOVABLE | __GFP_COMP | \
>  			 __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
>  #define GFP_TRANSHUGE	(GFP_TRANSHUGE_LIGHT | __GFP_DIRECT_RECLAIM)
> +#define GFP_USERCOPY	__GFP_USERCOPY
>  
>  /* Convert GFP flags to their corresponding migrate type */
>  #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 97f4a0117b3b..7d9d7d838991 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -25,6 +25,7 @@
>  #define SLAB_POISON		0x00000800UL	/* DEBUG: Poison objects */
>  #define SLAB_HWCACHE_ALIGN	0x00002000UL	/* Align objs on cache lines */
>  #define SLAB_CACHE_DMA		0x00004000UL	/* Use GFP_DMA memory */
> +#define SLAB_NO_MERGE		0x00008000UL	/* Keep this cache unmerged */
>  #define SLAB_STORE_USER		0x00010000UL	/* DEBUG: Store the last owner for bug hunting */
>  #define SLAB_PANIC		0x00040000UL	/* Panic if kmem_cache_create() fails */
>  /*
> @@ -287,6 +288,17 @@ extern struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
>  #endif
>  
>  /*
> + * Some userspace APIs (ipc, seq_file) provide precise control over
> + * the size of kernel kmallocs, which provides a trivial way to perform
> + * heap overflow attacks where the attacker must control neighboring
> + * allocations.  Instead, move these APIs into their own cache so they
> + * cannot interfere with standard kmallocs.
> + */
> +#ifdef CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC
> +extern struct kmem_cache *kmalloc_usersized_caches[KMALLOC_SHIFT_HIGH + 1];
> +#endif
> +
> +/*
>   * Figure out which kmalloc slab an allocation of a certain size
>   * belongs to.
>   * 0 = zero alloc
> diff --git a/ipc/msgutil.c b/ipc/msgutil.c
> index bf74eaa5c39f..5ae33d50da26 100644
> --- a/ipc/msgutil.c
> +++ b/ipc/msgutil.c
> @@ -53,7 +53,7 @@ static struct msg_msg *alloc_msg(size_t len)
>  	size_t alen;
>  
>  	alen = min(len, DATALEN_MSG);
> -	msg = kmalloc(sizeof(*msg) + alen, GFP_KERNEL_ACCOUNT);
> +	msg = kmalloc(sizeof(*msg) + alen, GFP_KERNEL_ACCOUNT | GFP_USERCOPY);
>  	if (msg == NULL)
>  		return NULL;
>  
> @@ -65,7 +65,8 @@ static struct msg_msg *alloc_msg(size_t len)
>  	while (len > 0) {
>  		struct msg_msgseg *seg;
>  		alen = min(len, DATALEN_SEG);
> -		seg = kmalloc(sizeof(*seg) + alen, GFP_KERNEL_ACCOUNT);
> +		seg = kmalloc(sizeof(*seg) + alen, GFP_KERNEL_ACCOUNT |
> +			GFP_USERCOPY);
>  		if (seg == NULL)
>  			goto out_err;
>  		*pseg = seg;
> diff --git a/mm/slab.h b/mm/slab.h
> index 4cdc8e64fdbd..874b755f278d 100644
> --- a/mm/slab.h
> +++ b/mm/slab.h
> @@ -130,7 +130,8 @@ static inline unsigned long kmem_cache_flags(unsigned long object_size,
>  
>  /* Legal flag mask for kmem_cache_create(), for various configurations */
>  #define SLAB_CORE_FLAGS (SLAB_HWCACHE_ALIGN | SLAB_CACHE_DMA | SLAB_PANIC | \
> -			 SLAB_TYPESAFE_BY_RCU | SLAB_DEBUG_OBJECTS )
> +			 SLAB_TYPESAFE_BY_RCU | SLAB_DEBUG_OBJECTS | \
> +			 SLAB_NO_MERGE)
>  
>  #if defined(CONFIG_DEBUG_SLAB)
>  #define SLAB_DEBUG_FLAGS (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER)
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index 2365dd21623d..6c14d765379f 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -40,7 +40,7 @@ static DECLARE_WORK(slab_caches_to_rcu_destroy_work,
>   */
>  #define SLAB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USER | \
>  		SLAB_TRACE | SLAB_TYPESAFE_BY_RCU | SLAB_NOLEAKTRACE | \
> -		SLAB_FAILSLAB | SLAB_KASAN)
> +		SLAB_FAILSLAB | SLAB_KASAN | SLAB_NO_MERGE)
>  
>  #define SLAB_MERGE_SAME (SLAB_RECLAIM_ACCOUNT | SLAB_CACHE_DMA | \
>  			 SLAB_NOTRACK | SLAB_ACCOUNT)
> @@ -940,6 +940,11 @@ struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
>  EXPORT_SYMBOL(kmalloc_dma_caches);
>  #endif
>  
> +#ifdef CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC
> +struct kmem_cache *kmalloc_usersized_caches[KMALLOC_SHIFT_HIGH + 1];
> +EXPORT_SYMBOL(kmalloc_usersized_caches);
> +#endif
> +
>  /*
>   * Conversion table for small slabs sizes / 8 to the index in the
>   * kmalloc array. This is necessary for slabs < 192 since we have non power
> @@ -1004,6 +1009,12 @@ struct kmem_cache *kmalloc_slab(size_t size, gfp_t flags)
>  		return kmalloc_dma_caches[index];
>  
>  #endif
> +
> +#ifdef CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC
> +	if (unlikely((flags & GFP_USERCOPY)))
> +		return kmalloc_usersized_caches[index];
> +#endif
> +
>  	return kmalloc_caches[index];
>  }
>  
> @@ -1125,6 +1136,22 @@ void __init create_kmalloc_caches(unsigned long flags)
>  		}
>  	}
>  #endif
> +
> +#ifdef CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC
> +	for (i = 0; i <= KMALLOC_SHIFT_HIGH; i++) {
> +		struct kmem_cache *s = kmalloc_caches[i];
> +
> +		if (s) {
> +			int size = kmalloc_size(i);
> +			char *n = kasprintf(GFP_NOWAIT,
> +				"usersized-kmalloc-%d", size);
> +
> +			BUG_ON(!n);
> +			kmalloc_usersized_caches[i] = create_kmalloc_cache(n,
> +				size, SLAB_NO_MERGE | flags, 0, size);
> +		}
> +	}
> +#endif /* CONFIG_HARDENED_USERCOPY_SPLIT_KMALLOC */
>  }
>  #endif /* !CONFIG_SLOB */
>  
> diff --git a/security/Kconfig b/security/Kconfig
> index 93027fdf47d1..0c181cebdb8a 100644
> --- a/security/Kconfig
> +++ b/security/Kconfig
> @@ -154,6 +154,18 @@ config HARDENED_USERCOPY_PAGESPAN
>  	  been removed. This config is intended to be used only while
>  	  trying to find such users.
>  
> +config HARDENED_USERCOPY_SPLIT_KMALLOC
> +	bool "Isolate kernel caches from user-controlled allocations"
> +	default HARDENED_USERCOPY
> +	help
> +	  This option creates a separate set of kmalloc caches used to
> +	  satisfy allocations from userspace APIs that allow for
> +	  fine-grained control over the size of kernel allocations.
> +	  Without this, it is much easier for attackers to precisely
> +	  size and attack heap overflows.  If their allocations are
> +	  confined to a separate cache, attackers must find other ways
> +	  to prepare heap attacks that will be near their desired target.
> +
>  config STATIC_USERMODEHELPER
>  	bool "Force all usermode helper calls through a single binary"
>  	help
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
