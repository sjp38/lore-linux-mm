Date: Fri, 17 Aug 2007 11:56:59 -0400
From: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Subject: Re: [PATCH 09/23] lib: percpu_counter_init error handling
Message-ID: <20070817155659.GD24323@filer.fsl.cs.sunysb.edu>
References: <20070816074525.065850000@chello.nl> <20070816074626.739944000@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070816074626.739944000@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 16, 2007 at 09:45:34AM +0200, Peter Zijlstra wrote:
> alloc_percpu can fail, propagate that error.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  fs/ext2/super.c                |   11 ++++++++---
>  fs/ext3/super.c                |   11 ++++++++---
>  fs/ext4/super.c                |   11 ++++++++---
>  include/linux/percpu_counter.h |    5 +++--
>  lib/percpu_counter.c           |    8 +++++++-
>  5 files changed, 34 insertions(+), 12 deletions(-)
> 
> Index: linux-2.6/fs/ext2/super.c
> ===================================================================
> --- linux-2.6.orig/fs/ext2/super.c
> +++ linux-2.6/fs/ext2/super.c
> @@ -725,6 +725,7 @@ static int ext2_fill_super(struct super_
>  	int db_count;
>  	int i, j;
>  	__le32 features;
> +	int err;
>  
>  	sbi = kzalloc(sizeof(*sbi), GFP_KERNEL);
>  	if (!sbi)
> @@ -996,12 +997,16 @@ static int ext2_fill_super(struct super_
>  	sbi->s_rsv_window_head.rsv_goal_size = 0;
>  	ext2_rsv_window_add(sb, &sbi->s_rsv_window_head);
>  
> -	percpu_counter_init(&sbi->s_freeblocks_counter,
> +	err = percpu_counter_init(&sbi->s_freeblocks_counter,
>  				ext2_count_free_blocks(sb));
> -	percpu_counter_init(&sbi->s_freeinodes_counter,
> +	err |= percpu_counter_init(&sbi->s_freeinodes_counter,
>  				ext2_count_free_inodes(sb));
> -	percpu_counter_init(&sbi->s_dirs_counter,
> +	err |= percpu_counter_init(&sbi->s_dirs_counter,
>  				ext2_count_dirs(sb));
> +	if (err) {
> +		printk(KERN_ERR "EXT2-fs: insufficient memory\n");
> +		goto failed_mount3;
> +	}

Can percpu_counter_init fail with only one error code? If not, the error
code potentially used in future at failed_mount3 could be nonsensical
because of the bitwise or-ing.

> Index: linux-2.6/lib/percpu_counter.c
> ===================================================================
> --- linux-2.6.orig/lib/percpu_counter.c
> +++ linux-2.6/lib/percpu_counter.c
> @@ -68,21 +68,27 @@ s64 __percpu_counter_sum(struct percpu_c
>  }
>  EXPORT_SYMBOL(__percpu_counter_sum);
>  
> -void percpu_counter_init(struct percpu_counter *fbc, s64 amount)
> +int percpu_counter_init(struct percpu_counter *fbc, s64 amount)
>  {
>  	spin_lock_init(&fbc->lock);
>  	fbc->count = amount;
>  	fbc->counters = alloc_percpu(s32);
> +	if (!fbc->counters)
> +		return -ENOMEM;
>  #ifdef CONFIG_HOTPLUG_CPU
>  	mutex_lock(&percpu_counters_lock);
>  	list_add(&fbc->list, &percpu_counters);
>  	mutex_unlock(&percpu_counters_lock);
>  #endif
> +	return 0;
>  }

I guess this answers my question. But I'd still be weary because a trivial
change here could produce very strange error codes in ext2/3/4.

Josef 'Jeff' Sipek.

-- 
Once you have their hardware. Never give it back.
(The First Rule of Hardware Acquisition)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
