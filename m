Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 451896B0044
	for <linux-mm@kvack.org>; Sat,  5 Dec 2009 15:23:29 -0500 (EST)
Date: Sat, 5 Dec 2009 20:23:18 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [RFC PATCH 01/15] shmem: do not call fput_filp on an initialized
 filp
In-Reply-To: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
Message-ID: <Pine.LNX.4.64.0912052020360.6368@sister.anvils>
References: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 4 Dec 2009, Eric Paris wrote:

> fput_filp is supposed to be used when the filp was not used.  But in the

   put_filp

> ifndef CONFIG_MMU case shmem_setup_file could call this one an initialized

                                                          on

> filp.  It should be using fput() instead.  Since the fput() will dec the ima
> counts we also need to move the ima hook to make sure that is set up before
> the fput().
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>
> Acked-by: Miklos Szeredi <miklos@szeredi.hu>

Thanks,
Acked-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>

> ---
> 
>  mm/shmem.c |    9 ++++++---
>  1 files changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/shmem.c b/mm/shmem.c
> index 356dd99..e7f8968 100644
> --- a/mm/shmem.c
> +++ b/mm/shmem.c
> @@ -2656,12 +2656,15 @@ struct file *shmem_file_setup(const char *name, loff_t size, unsigned long flags
>  	init_file(file, shm_mnt, dentry, FMODE_WRITE | FMODE_READ,
>  		  &shmem_file_operations);
>  
> +	ima_counts_get(file);
> +
>  #ifndef CONFIG_MMU
>  	error = ramfs_nommu_expand_for_mapping(inode, size);
> -	if (error)
> -		goto close_file;
> +	if (error) {
> +		fput(file);
> +		return error;
> +	}
>  #endif
> -	ima_counts_get(file);
>  	return file;
>  
>  close_file:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
