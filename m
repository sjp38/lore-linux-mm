Date: Thu, 23 Aug 2007 14:24:55 -0400
From: Josef Sipek <jsipek@fsl.cs.sunysb.edu>
Subject: Re: [PATCH 09/23] lib: percpu_counter_init error handling
Message-ID: <20070823182455.GB1608@filer.fsl.cs.sunysb.edu>
References: <20070816074525.065850000@chello.nl> <20070816074626.739944000@chello.nl> <20070817155659.GD24323@filer.fsl.cs.sunysb.edu> <1187424574.6114.136.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1187424574.6114.136.camel@twins>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Sat, Aug 18, 2007 at 10:09:34AM +0200, Peter Zijlstra wrote:
> On Fri, 2007-08-17 at 11:56 -0400, Josef Sipek wrote:
> > On Thu, Aug 16, 2007 at 09:45:34AM +0200, Peter Zijlstra wrote:
 
Sorry...this mail got lost in the flood of email after a procmail rule
stopped working...

> The actual value of err is irrelevant, it is not used after this not
> zero check.
> 
> But how about this:
> ---
> Subject: lib: percpu_counter_init error handling
> 
> alloc_percpu can fail, propagate that error.
> 
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> ---
>  fs/ext2/super.c                |   15 ++++++++++++---
>  fs/ext3/super.c                |   21 +++++++++++++++------
>  fs/ext4/super.c                |   21 +++++++++++++++------
>  include/linux/percpu_counter.h |    5 +++--
>  lib/percpu_counter.c           |    8 +++++++-
>  5 files changed, 52 insertions(+), 18 deletions(-)
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
> @@ -996,12 +997,20 @@ static int ext2_fill_super(struct super_
>  	sbi->s_rsv_window_head.rsv_goal_size = 0;
>  	ext2_rsv_window_add(sb, &sbi->s_rsv_window_head);
>  
> -	percpu_counter_init(&sbi->s_freeblocks_counter,
> +	err = percpu_counter_init(&sbi->s_freeblocks_counter,
>  				ext2_count_free_blocks(sb));
> -	percpu_counter_init(&sbi->s_freeinodes_counter,
> +	if (!err) {
> +		err = percpu_counter_init(&sbi->s_freeinodes_counter,
>  				ext2_count_free_inodes(sb));
> -	percpu_counter_init(&sbi->s_dirs_counter,
> +	}
> +	if (!err) {
> +		err = percpu_counter_init(&sbi->s_dirs_counter,
>  				ext2_count_dirs(sb));
> +	}
> +	if (err) {
> +		printk(KERN_ERR "EXT2-fs: insufficient memory\n");
> +		goto failed_mount3;
> +	}
>  	/*
>  	 * set up enough so that it can read an inode
>  	 */

I find this more readable as I don't have to try to figure out what the
bitops are doing :)

Jeff.

-- 
Mankind invented the atomic bomb, but no mouse would ever construct a
mousetrap.
		- Albert Einstein

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
