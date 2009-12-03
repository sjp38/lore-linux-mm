Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EB91E600762
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 17:44:20 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nB3MVs2k016763
	for <linux-mm@kvack.org>; Thu, 3 Dec 2009 15:31:54 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id nB3Mi4a4159014
	for <linux-mm@kvack.org>; Thu, 3 Dec 2009 15:44:08 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB3Mi3eF023909
	for <linux-mm@kvack.org>; Thu, 3 Dec 2009 15:44:04 -0700
Date: Thu, 3 Dec 2009 16:44:02 -0600
From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [RFC PATCH 5/6] vfs: make init-file static
Message-ID: <20091203224402.GA12995@us.ibm.com>
References: <20091203195851.8925.30926.stgit@paris.rdu.redhat.com>
 <20091203195925.8925.21416.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091203195925.8925.21416.stgit@paris.rdu.redhat.com>
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

Quoting Eric Paris (eparis@redhat.com):
> init-file is no longer used by anything except alloc_file.  Make it static and
> remove from headers.

Should these go through a deprecation period?  (Same for the next patch)

> Signed-off-by: Eric Paris <eparis@redhat.com>
> ---
> 
>  fs/file_table.c      |   73 ++++++++++++++++++++++----------------------------
>  include/linux/file.h |    3 --
>  2 files changed, 32 insertions(+), 44 deletions(-)
> 
> diff --git a/fs/file_table.c b/fs/file_table.c
> index 4bef4c0..0f9d2f2 100644
> --- a/fs/file_table.c
> +++ b/fs/file_table.c
> @@ -150,53 +150,16 @@ fail:
>  EXPORT_SYMBOL(get_empty_filp);
> 
>  /**
> - * alloc_file - allocate and initialize a 'struct file'
> - * @mnt: the vfsmount on which the file will reside
> - * @dentry: the dentry representing the new file
> - * @mode: the mode with which the new file will be opened
> - * @fop: the 'struct file_operations' for the new file
> - *
> - * Use this instead of get_empty_filp() to get a new
> - * 'struct file'.  Do so because of the same initialization
> - * pitfalls reasons listed for init_file().  This is a
> - * preferred interface to using init_file().
> - *
> - * If all the callers of init_file() are eliminated, its
> - * code should be moved into this function.
> - */
> -struct file *alloc_file(struct vfsmount *mnt, struct dentry *dentry,
> -		fmode_t mode, const struct file_operations *fop)
> -{
> -	struct file *file;
> -
> -	file = get_empty_filp();
> -	if (!file)
> -		return NULL;
> -
> -	init_file(file, mnt, dentry, mode, fop);
> -	return file;
> -}
> -EXPORT_SYMBOL(alloc_file);
> -
> -/**
>   * init_file - initialize a 'struct file'
>   * @file: the already allocated 'struct file' to initialized
>   * @mnt: the vfsmount on which the file resides
>   * @dentry: the dentry representing this file
>   * @mode: the mode the file is opened with
>   * @fop: the 'struct file_operations' for this file
> - *
> - * Use this instead of setting the members directly.  Doing so
> - * avoids making mistakes like forgetting the mntget() or
> - * forgetting to take a write on the mnt.
> - *
> - * Note: This is a crappy interface.  It is here to make
> - * merging with the existing users of get_empty_filp()
> - * who have complex failure logic easier.  All users
> - * of this should be moving to alloc_file().
>   */
> -int init_file(struct file *file, struct vfsmount *mnt, struct dentry *dentry,
> -	   fmode_t mode, const struct file_operations *fop)
> +static int init_file(struct file *file, struct vfsmount *mnt,
> +		     struct dentry *dentry, fmode_t mode,
> +		     const struct file_operations *fop)
>  {
>  	int error = 0;
>  	file->f_path.dentry = dentry;
> @@ -218,7 +181,35 @@ int init_file(struct file *file, struct vfsmount *mnt, struct dentry *dentry,
>  	}
>  	return error;
>  }
> -EXPORT_SYMBOL(init_file);
> +
> +/**
> + * alloc_file - allocate and initialize a 'struct file'
> + * @mnt: the vfsmount on which the file will reside
> + * @dentry: the dentry representing the new file
> + * @mode: the mode with which the new file will be opened
> + * @fop: the 'struct file_operations' for the new file
> + *
> + * Use this instead of get_empty_filp() to get a new
> + * 'struct file'.  Do so because of the same initialization
> + * pitfalls reasons listed for init_file().  This is a
> + * preferred interface to using init_file().
> + *
> + * If all the callers of init_file() are eliminated, its
> + * code should be moved into this function.
> + */
> +struct file *alloc_file(struct vfsmount *mnt, struct dentry *dentry,
> +		fmode_t mode, const struct file_operations *fop)
> +{
> +	struct file *file;
> +
> +	file = get_empty_filp();
> +	if (!file)
> +		return NULL;
> +
> +	init_file(file, mnt, dentry, mode, fop);
> +	return file;
> +}
> +EXPORT_SYMBOL(alloc_file);
> 
>  void fput(struct file *file)
>  {
> diff --git a/include/linux/file.h b/include/linux/file.h
> index 335a0a5..6a8d361 100644
> --- a/include/linux/file.h
> +++ b/include/linux/file.h
> @@ -18,9 +18,6 @@ extern void drop_file_write_access(struct file *file);
>  struct file_operations;
>  struct vfsmount;
>  struct dentry;
> -extern int init_file(struct file *, struct vfsmount *mnt,
> -		struct dentry *dentry, fmode_t mode,
> -		const struct file_operations *fop);
>  extern struct file *alloc_file(struct vfsmount *, struct dentry *dentry,
>  		fmode_t mode, const struct file_operations *fop);
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-fsdevel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
