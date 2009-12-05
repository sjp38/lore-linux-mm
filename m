Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 65C116B0044
	for <linux-mm@kvack.org>; Sat,  5 Dec 2009 15:26:49 -0500 (EST)
Date: Sat, 5 Dec 2009 20:26:39 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [RFC PATCH 02/15] shmem: use alloc_file instead of init_file
In-Reply-To: <20091204204656.18286.15131.stgit@paris.rdu.redhat.com>
Message-ID: <Pine.LNX.4.64.0912052023270.6368@sister.anvils>
References: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
 <20091204204656.18286.15131.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 2009, Eric Paris wrote:

> shmem uses get_empty_filp() and then init_file().  Their is no good reason

                                                     There

> not to just use alloc_file() like everything else.
> 
> Acked-by: Miklos Szeredi <miklos@szeredi.hu>
> Signed-off-by: Eric Paris <eparis@redhat.com>

Right, what deterred me from using alloc_file() when it came in,
was that d_instantiate() done before the alloc_file().  But looking
through it now, I think it's okay, and I'm hoping you know it's okay.

Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> ---
> 
>  mm/shmem.c |   17 +++++++----------
>  1 files changed, 7 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index e7f8968..b212184 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2640,21 +2640,20 @@ struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags
>  	if (!dentry)
>  		goto put_memory;
>  
> -	error = -ENFILE;
> -	file = get_empty_filp();
> -	if (!file)
> -		goto put_dentry;
> -
>  	error = -ENOSPC;
>  	inode = shmem_get_inode(root->d_sb, S_IFREG | S_IRWXUGO, 0, flags);
>  	if (!inode)
> -		goto close_file;
> +		goto put_dentry;
>  
>  	d_instantiate(dentry, inode);
>  	inode->i_size = size;
>  	inode->i_nlink = 0;	/* It is unlinked */
> -	init_file(file, shm_mnt, dentry, FMODE_WRITE | FMODE_READ,
> -		  &shmem_file_operations);
> +
> +	error = -ENFILE;
> +	file = alloc_file(shm_mnt, dentry, FMODE_WRITE | FMODE_READ,
> +			  &shmem_file_operations);
> +	if (!file)
> +		goto put_dentry;
>  
>  	ima_counts_get(file);
>  
> @@ -2667,8 +2666,6 @@ struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags
>  #endif
>  	return file;
>  
> -close_file:
> -	put_filp(file);
>  put_dentry:
>  	dput(dentry);
>  put_memory:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
