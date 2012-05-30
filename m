Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 675906B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 11:12:16 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <20422.14538.833061.105058@quad.stoffel.home>
Date: Wed, 30 May 2012 11:12:10 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [RFC Patch] fs: implement per-file drop caches
In-Reply-To: <1338385120-14519-1-git-send-email-amwang@redhat.com>
References: <1338385120-14519-1-git-send-email-amwang@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cong Wang <amwang@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <xiyou.wangcong@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <matthew@wil.cx>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org


Cong> This is a draft patch of implementing per-file drop caches.

Interesting.  So can I do this from outside a process?  I'm a
SysAdmin, so my POV is from noticing, finding and fixing performance
problems when the system is under pressure.  

Cong> It introduces a new fcntl command  F_DROP_CACHES to drop
Cong> file caches of a specific file. The reason is that currently
Cong> we only have a system-wide drop caches interface, it could
Cong> cause system-wide performance down if we drop all page caches
Cong> when we actually want to drop the caches of some huge file.

How can I tell how much cache is used by a file?  And what is the
performance impact of this when run on a busy system?  And what does
this patch buy us since I figure the VM should already be dropping
caches once the system comes under mem pressure...

Cong> Below is small test case for this patch:

Cong> 	#include <unistd.h>
Cong> 	#include <stdlib.h>
Cong> 	#include <stdio.h>
Cong> 	#define __USE_GNU
Cong> 	#include <fcntl.h>

Cong> 	int
Cong> 	main(int argc, char *argv[])
Cong> 	{
Cong> 		int fd;
Cong> 		fd = open(argv[1], O_RDONLY);
Cong> 		if (fd == -1) {
Cong> 			perror("open");
Cong> 			return 1;
Cong> 		}
Cong> 		printf("Before readahead:\n");
Cong> 		system("grep ^Cache /proc/meminfo");
Cong> 		if (readahead(fd, 0, 1024*1024*100)) {
Cong> 			perror("open");
Cong> 			return 1;
Cong> 		}
Cong> 		printf("Before drop cache:\n");
Cong> 		system("grep ^Cache /proc/meminfo");
Cong> 		fcntl(fd, 1024+9, 3);
Cong> 		printf("After drop cache:\n");
Cong> 		system("grep ^Cache /proc/meminfo");
Cong> 		close(fd);
Cong> 		return 0;
Cong> 	}

Cong> I used a file of 100M size for testing, and I can see
Cong> the cache size of the whole system drops 70000K after
Cong> dropping the caches of this big file.

Cong> Any comments?

Cong> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Cong> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cong> Cc: Matthew Wilcox <matthew@wil.cx>
Cong> Cc: linux-fsdevel@vger.kernel.org
Cong> Cc: linux-kernel@vger.kernel.org
Cong> Cc: linux-mm@kvack.org

Cong> ---
Cong>  fs/dcache.c           |   56 ++++++++++++++++++++++++++++++------------------
Cong>  fs/drop_caches.c      |   30 ++++++++++++++++++++++++++
Cong>  fs/fcntl.c            |    4 +++
Cong>  fs/inode.c            |   37 ++++++++++++++++++++++++++++++++
Cong>  include/linux/fcntl.h |    1 +
Cong>  include/linux/fs.h    |    2 +
Cong>  include/linux/mm.h    |    1 +
Cong>  7 files changed, 110 insertions(+), 21 deletions(-)

Cong> diff --git a/fs/dcache.c b/fs/dcache.c
Cong> index 4435d8b..5262851 100644
Cong> --- a/fs/dcache.c
Cong> +++ b/fs/dcache.c
Cong> @@ -585,28 +585,14 @@ kill_it:
Cong>  }
Cong>  EXPORT_SYMBOL(dput);
 
Cong> -/**
Cong> - * d_invalidate - invalidate a dentry
Cong> - * @dentry: dentry to invalidate
Cong> - *
Cong> - * Try to invalidate the dentry if it turns out to be
Cong> - * possible. If there are other dentries that can be
Cong> - * reached through this one we can't delete it and we
Cong> - * return -EBUSY. On success we return 0.
Cong> - *
Cong> - * no dcache lock.
Cong> - */
Cong> - 
Cong> -int d_invalidate(struct dentry * dentry)
Cong> +int __d_invalidate(struct dentry * dentry)
Cong>  {
Cong>  	/*
Cong>  	 * If it's already been dropped, return OK.
Cong>  	 */
Cong> -	spin_lock(&dentry->d_lock);
Cong> -	if (d_unhashed(dentry)) {
Cong> -		spin_unlock(&dentry->d_lock);
Cong> +	if (d_unhashed(dentry))
Cong>  		return 0;
Cong> -	}
Cong> +
Cong>  	/*
Cong>  	 * Check whether to do a partial shrink_dcache
Cong>  	 * to get rid of unused child entries.
Cong> @@ -630,16 +616,33 @@ int d_invalidate(struct dentry * dentry)
Cong>  	 * directory or not.
Cong>  	 */
Cong>  	if (dentry->d_count > 1 && dentry->d_inode) {
Cong> -		if (S_ISDIR(dentry->d_inode->i_mode) || d_mountpoint(dentry)) {
Cong> -			spin_unlock(&dentry->d_lock);
Cong> +		if (S_ISDIR(dentry->d_inode->i_mode) || d_mountpoint(dentry))
Cong>  			return -EBUSY;
Cong> -		}
Cong>  	}
 
Cong>  	__d_drop(dentry);
Cong> -	spin_unlock(&dentry->d_lock);
Cong>  	return 0;
Cong>  }
Cong> +
Cong> +/**
Cong> + * d_invalidate - invalidate a dentry
Cong> + * @dentry: dentry to invalidate
Cong> + *
Cong> + * Try to invalidate the dentry if it turns out to be
Cong> + * possible. If there are other dentries that can be
Cong> + * reached through this one we can't delete it and we
Cong> + * return -EBUSY. On success we return 0.
Cong> + *
Cong> + * no dcache lock.
Cong> + */
Cong> +int d_invalidate(struct dentry * dentry)
Cong> +{
Cong> +	int ret;
Cong> +	spin_lock(&dentry->d_lock);
Cong> +	ret = __d_invalidate(dentry);
Cong> +	spin_unlock(&dentry->d_lock);
Cong> +	return ret;
Cong> +}
Cong>  EXPORT_SYMBOL(d_invalidate);
 
Cong>  /* This must be called with d_lock held */
Cong> @@ -898,6 +901,17 @@ relock:
Cong>  	shrink_dentry_list(&tmp);
Cong>  }
 
Cong> +void prune_dcache_one(struct dentry *dentry)
Cong> +{
Cong> +	spin_lock(&dentry->d_lock);
Cong> +	if (dentry->d_flags & DCACHE_REFERENCED)
Cong> +		dentry->d_flags &= ~DCACHE_REFERENCED;
Cong> +	dentry_lru_del(dentry);
Cong> +	dentry->d_flags |= DCACHE_SHRINK_LIST;
Cong> +	__d_invalidate(dentry);
Cong> +	spin_unlock(&dentry->d_lock);
Cong> +}
Cong> +
Cong>  /**
Cong>   * shrink_dcache_sb - shrink dcache for a superblock
Cong>   * @sb: superblock
Cong> diff --git a/fs/drop_caches.c b/fs/drop_caches.c
Cong> index c00e055..805f150 100644
Cong> --- a/fs/drop_caches.c
Cong> +++ b/fs/drop_caches.c
Cong> @@ -65,3 +65,33 @@ int drop_caches_sysctl_handler(ctl_table *table, int write,
Cong>  	}
Cong>  	return 0;
Cong>  }
Cong> +
Cong> +static void drop_pagecache_file(struct file *filp)
Cong> +{
Cong> +	struct inode *inode = filp->f_path.dentry->d_inode;
Cong> +
Cong> +	spin_lock(&inode->i_lock);
Cong> +	if ((inode->i_state & (I_FREEING|I_WILL_FREE|I_NEW)) ||
Cong> +	    (inode->i_mapping->nrpages == 0)) {
Cong> +		spin_unlock(&inode->i_lock);
Cong> +		return;
Cong> +	}
Cong> +	__iget(inode);
Cong> +	spin_unlock(&inode->i_lock);
Cong> +	invalidate_mapping_pages(inode->i_mapping, 0, -1);
Cong> +	iput(inode);
Cong> +}
Cong> +
Cong> +
Cong> +void file_drop_caches(struct file *filp, unsigned long which)
Cong> +{
Cong> +	if (which & 1)
Cong> +		drop_pagecache_file(filp);
Cong> +
Cong> +	if (which & 2) {
Cong> +		struct dentry *dentry = filp->f_path.dentry;
Cong> +
Cong> +		prune_dcache_one(dentry);
Cong> +		prune_icache_one(dentry->d_inode);
Cong> +	}
Cong> +}
Cong> diff --git a/fs/fcntl.c b/fs/fcntl.c
Cong> index d078b75..a97f10a 100644
Cong> --- a/fs/fcntl.c
Cong> +++ b/fs/fcntl.c
Cong> @@ -420,6 +420,10 @@ static long do_fcntl(int fd, unsigned int cmd, unsigned long arg,
Cong>  	case F_GETPIPE_SZ:
Cong>  		err = pipe_fcntl(filp, cmd, arg);
Cong>  		break;
Cong> +	case F_DROP_CACHES:
Cong> +		err = 0;
Cong> +		file_drop_caches(filp, arg);
Cong> +		break;
Cong>  	default:
Cong>  		break;
Cong>  	}
Cong> diff --git a/fs/inode.c b/fs/inode.c
Cong> index 6bc8761..a9e92bb 100644
Cong> --- a/fs/inode.c
Cong> +++ b/fs/inode.c
Cong> @@ -776,6 +776,43 @@ void prune_icache_sb(struct super_block *sb, int nr_to_scan)
Cong>  	dispose_list(&freeable);
Cong>  }
 
Cong> +void prune_icache_one(struct inode *inode)
Cong> +{
Cong> +	unsigned long reap = 0;
Cong> +
Cong> +	/* We are still holding this inode, and we are
Cong> +	 * expecting the last iput() will finally
Cong> +	 * evict it.
Cong> +	 */
Cong> +	spin_lock(&inode->i_lock);
Cong> +
Cong> +	if (inode->i_state & (I_NEW | I_FREEING | I_WILL_FREE)) {
Cong> +		spin_unlock(&inode->i_lock);
Cong> +		return;
Cong> +	}
Cong> +
Cong> +	if (inode->i_state & I_REFERENCED)
Cong> +		inode->i_state &= ~I_REFERENCED;
Cong> +
Cong> +	inode_lru_list_del(inode);
Cong> +
Cong> +	if (inode_has_buffers(inode) || inode->i_data.nrpages) {
Cong> +		__iget(inode);
Cong> +		spin_unlock(&inode->i_lock);
Cong> +		if (remove_inode_buffers(inode))
Cong> +			reap += invalidate_mapping_pages(&inode->i_data,
Cong> +							0, -1);
Cong> +		iput(inode);
Cong> +	} else
Cong> +		spin_unlock(&inode->i_lock);
Cong> +
Cong> +	if (reap) {
Cong> +		__count_vm_events(PGINODESTEAL, reap);
Cong> +		if (current->reclaim_state)
Cong> +			current->reclaim_state->reclaimed_slab += reap;
Cong> +	}
Cong> +}
Cong> +
Cong>  static void __wait_on_freeing_inode(struct inode *inode);
Cong>  /*
Cong>   * Called with the inode lock held.
Cong> diff --git a/include/linux/fcntl.h b/include/linux/fcntl.h
Cong> index f550f89..6f2b24b 100644
Cong> --- a/include/linux/fcntl.h
Cong> +++ b/include/linux/fcntl.h
Cong> @@ -27,6 +27,7 @@
Cong>  #define F_SETPIPE_SZ	(F_LINUX_SPECIFIC_BASE + 7)
Cong>  #define F_GETPIPE_SZ	(F_LINUX_SPECIFIC_BASE + 8)
 
Cong> +#define F_DROP_CACHES	(F_LINUX_SPECIFIC_BASE + 9)
Cong>  /*
Cong>   * Types of directory notifications that may be requested.
Cong>   */
Cong> diff --git a/include/linux/fs.h b/include/linux/fs.h
Cong> index 038076b..d39e4b9 100644
Cong> --- a/include/linux/fs.h
Cong> +++ b/include/linux/fs.h
Cong> @@ -1538,6 +1538,8 @@ struct super_block {
Cong>  /* superblock cache pruning functions */
Cong>  extern void prune_icache_sb(struct super_block *sb, int nr_to_scan);
Cong>  extern void prune_dcache_sb(struct super_block *sb, int nr_to_scan);
Cong> +extern void prune_icache_one(struct inode *inode);
Cong> +extern void prune_dcache_one(struct dentry *dentry);
 
Cong>  extern struct timespec current_fs_time(struct super_block *sb);
 
Cong> diff --git a/include/linux/mm.h b/include/linux/mm.h
Cong> index ce26716..1ad3fc1 100644
Cong> --- a/include/linux/mm.h
Cong> +++ b/include/linux/mm.h
Cong> @@ -1555,6 +1555,7 @@ int in_gate_area_no_mm(unsigned long addr);
 
Cong>  int drop_caches_sysctl_handler(struct ctl_table *, int,
Cong>  					void __user *, size_t *, loff_t *);
Cong> +void file_drop_caches(struct file *filp, unsigned long which);
Cong>  unsigned long shrink_slab(struct shrink_control *shrink,
Cong>  			  unsigned long nr_pages_scanned,
Cong>  			  unsigned long lru_pages);
Cong> --
Cong> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
Cong> the body of a message to majordomo@vger.kernel.org
Cong> More majordomo info at  http://vger.kernel.org/majordomo-info.html
Cong> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
