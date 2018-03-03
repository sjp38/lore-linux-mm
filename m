Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7BA6B0007
	for <linux-mm@kvack.org>; Sat,  3 Mar 2018 09:19:06 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a26so5375075pgn.18
        for <linux-mm@kvack.org>; Sat, 03 Mar 2018 06:19:06 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n1si5561976pgc.527.2018.03.03.06.19.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 03 Mar 2018 06:19:04 -0800 (PST)
Message-ID: <1520086742.4280.27.camel@kernel.org>
Subject: Re: [PATCH v7 08/61] xarray: Add the xa_lock to the radix_tree_root
From: Jeff Layton <jlayton@kernel.org>
Date: Sat, 03 Mar 2018 09:19:02 -0500
In-Reply-To: <20180219194556.6575-9-willy@infradead.org>
References: <20180219194556.6575-1-willy@infradead.org>
	 <20180219194556.6575-9-willy@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Mon, 2018-02-19 at 11:45 -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> This results in no change in structure size on 64-bit x86 as it fits in
> the padding between the gfp_t and the void *.
> 
> Initialising the spinlock requires a name for the benefit of lockdep,
> so RADIX_TREE_INIT() now needs to know the name of the radix tree it's
> initialising, and so do IDR_INIT() and IDA_INIT().
> 
> Also add the xa_lock() and xa_unlock() family of wrappers to make it
> easier to use the lock.  If we could rely on -fplan9-extensions in
> the compiler, we could avoid all of this syntactic sugar, but that
> wasn't added until gcc 4.6.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> ---
>  fs/f2fs/gc.c                   |  2 +-
>  include/linux/idr.h            | 19 ++++++++++---------
>  include/linux/radix-tree.h     |  7 +++++--
>  include/linux/xarray.h         | 24 ++++++++++++++++++++++++
>  kernel/pid.c                   |  2 +-
>  tools/include/linux/spinlock.h |  1 +
>  6 files changed, 42 insertions(+), 13 deletions(-)
>  create mode 100644 include/linux/xarray.h
> 
> diff --git a/fs/f2fs/gc.c b/fs/f2fs/gc.c
> index aa720cc44509..7aa15134180e 100644
> --- a/fs/f2fs/gc.c
> +++ b/fs/f2fs/gc.c
> @@ -1006,7 +1006,7 @@ int f2fs_gc(struct f2fs_sb_info *sbi, bool sync,
>  	unsigned int init_segno = segno;
>  	struct gc_inode_list gc_list = {
>  		.ilist = LIST_HEAD_INIT(gc_list.ilist),
> -		.iroot = RADIX_TREE_INIT(GFP_NOFS),
> +		.iroot = RADIX_TREE_INIT(gc_list.iroot, GFP_NOFS),
>  	};
>  
>  	trace_f2fs_gc_begin(sbi->sb, sync, background,
> diff --git a/include/linux/idr.h b/include/linux/idr.h
> index 913c335054f0..e856f4e0ab35 100644
> --- a/include/linux/idr.h
> +++ b/include/linux/idr.h
> @@ -32,27 +32,28 @@ struct idr {
>  #define IDR_RT_MARKER	(ROOT_IS_IDR | (__force gfp_t)			\
>  					(1 << (ROOT_TAG_SHIFT + IDR_FREE)))
>  
> -#define IDR_INIT_BASE(base) {						\
> -	.idr_rt = RADIX_TREE_INIT(IDR_RT_MARKER),			\
> +#define IDR_INIT_BASE(name, base) {					\
> +	.idr_rt = RADIX_TREE_INIT(name, IDR_RT_MARKER),			\
>  	.idr_base = (base),						\
>  	.idr_next = 0,							\
>  }
>  
>  /**
>   * IDR_INIT() - Initialise an IDR.
> + * @name: Name of IDR.
>   *
>   * A freshly-initialised IDR contains no IDs.
>   */
> -#define IDR_INIT	IDR_INIT_BASE(0)
> +#define IDR_INIT(name)	IDR_INIT_BASE(name, 0)
>  
>  /**
> - * DEFINE_IDR() - Define a statically-allocated IDR
> - * @name: Name of IDR
> + * DEFINE_IDR() - Define a statically-allocated IDR.
> + * @name: Name of IDR.
>   *
>   * An IDR defined using this macro is ready for use with no additional
>   * initialisation required.  It contains no IDs.
>   */
> -#define DEFINE_IDR(name)	struct idr name = IDR_INIT
> +#define DEFINE_IDR(name)	struct idr name = IDR_INIT(name)
>  
>  /**
>   * idr_get_cursor - Return the current position of the cyclic allocator
> @@ -219,10 +220,10 @@ struct ida {
>  	struct radix_tree_root	ida_rt;
>  };
>  
> -#define IDA_INIT	{						\
> -	.ida_rt = RADIX_TREE_INIT(IDR_RT_MARKER | GFP_NOWAIT),		\
> +#define IDA_INIT(name)	{						\
> +	.ida_rt = RADIX_TREE_INIT(name, IDR_RT_MARKER | GFP_NOWAIT),	\
>  }
> -#define DEFINE_IDA(name)	struct ida name = IDA_INIT
> +#define DEFINE_IDA(name)	struct ida name = IDA_INIT(name)
>  
>  int ida_pre_get(struct ida *ida, gfp_t gfp_mask);
>  int ida_get_new_above(struct ida *ida, int starting_id, int *p_id);
> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> index 6c4e2e716dac..34149e8b5f73 100644
> --- a/include/linux/radix-tree.h
> +++ b/include/linux/radix-tree.h
> @@ -110,20 +110,23 @@ struct radix_tree_node {
>  #define ROOT_TAG_SHIFT	(__GFP_BITS_SHIFT)
>  
>  struct radix_tree_root {
> +	spinlock_t		xa_lock;
>  	gfp_t			gfp_mask;
>  	struct radix_tree_node	__rcu *rnode;
>  };
>  
> -#define RADIX_TREE_INIT(mask)	{					\
> +#define RADIX_TREE_INIT(name, mask)	{				\
> +	.xa_lock = __SPIN_LOCK_UNLOCKED(name.xa_lock),			\
>  	.gfp_mask = (mask),						\
>  	.rnode = NULL,							\
>  }
>  
>  #define RADIX_TREE(name, mask) \
> -	struct radix_tree_root name = RADIX_TREE_INIT(mask)
> +	struct radix_tree_root name = RADIX_TREE_INIT(name, mask)
>  
>  #define INIT_RADIX_TREE(root, mask)					\
>  do {									\
> +	spin_lock_init(&(root)->xa_lock);				\
>  	(root)->gfp_mask = (mask);					\
>  	(root)->rnode = NULL;						\
>  } while (0)
> diff --git a/include/linux/xarray.h b/include/linux/xarray.h
> new file mode 100644
> index 000000000000..2dfc8006fe64
> --- /dev/null
> +++ b/include/linux/xarray.h
> @@ -0,0 +1,24 @@
> +/* SPDX-License-Identifier: GPL-2.0+ */
> +#ifndef _LINUX_XARRAY_H
> +#define _LINUX_XARRAY_H
> +/*
> + * eXtensible Arrays
> + * Copyright (c) 2017 Microsoft Corporation
> + * Author: Matthew Wilcox <mawilcox@microsoft.com>
> + */
> +
> +#include <linux/spinlock.h>
> +
> +#define xa_trylock(xa)		spin_trylock(&(xa)->xa_lock)
> +#define xa_lock(xa)		spin_lock(&(xa)->xa_lock)
> +#define xa_unlock(xa)		spin_unlock(&(xa)->xa_lock)
> +#define xa_lock_bh(xa)		spin_lock_bh(&(xa)->xa_lock)
> +#define xa_unlock_bh(xa)	spin_unlock_bh(&(xa)->xa_lock)
> +#define xa_lock_irq(xa)		spin_lock_irq(&(xa)->xa_lock)
> +#define xa_unlock_irq(xa)	spin_unlock_irq(&(xa)->xa_lock)
> +#define xa_lock_irqsave(xa, flags) \
> +				spin_lock_irqsave(&(xa)->xa_lock, flags)
> +#define xa_unlock_irqrestore(xa, flags) \
> +				spin_unlock_irqrestore(&(xa)->xa_lock, flags)
> +
> +#endif /* _LINUX_XARRAY_H */
> diff --git a/kernel/pid.c b/kernel/pid.c
> index ed6c343fe50d..157fe4b19971 100644
> --- a/kernel/pid.c
> +++ b/kernel/pid.c
> @@ -70,7 +70,7 @@ int pid_max_max = PID_MAX_LIMIT;
>   */
>  struct pid_namespace init_pid_ns = {
>  	.kref = KREF_INIT(2),
> -	.idr = IDR_INIT,
> +	.idr = IDR_INIT(init_pid_ns.idr),
>  	.pid_allocated = PIDNS_ADDING,
>  	.level = 0,
>  	.child_reaper = &init_task,
> diff --git a/tools/include/linux/spinlock.h b/tools/include/linux/spinlock.h
> index 4ed569fcb139..b21b586b9854 100644
> --- a/tools/include/linux/spinlock.h
> +++ b/tools/include/linux/spinlock.h
> @@ -7,6 +7,7 @@
>  
>  #define spinlock_t		pthread_mutex_t
>  #define DEFINE_SPINLOCK(x)	pthread_mutex_t x = PTHREAD_MUTEX_INITIALIZER;
> +#define __SPIN_LOCK_UNLOCKED(x)	(pthread_mutex_t)PTHREAD_MUTEX_INITIALIZER
>  
>  #define spin_lock_irqsave(x, f)		(void)f, pthread_mutex_lock(x)
>  #define spin_unlock_irqrestore(x, f)	(void)f, pthread_mutex_unlock(x)

Looks sane enough.

Reviewed-by: Jeff Layton <jlayton@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
