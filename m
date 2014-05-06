Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f42.google.com (mail-oa0-f42.google.com [209.85.219.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5F14B6B0035
	for <linux-mm@kvack.org>; Tue,  6 May 2014 16:54:26 -0400 (EDT)
Received: by mail-oa0-f42.google.com with SMTP id j17so57814oag.29
        for <linux-mm@kvack.org>; Tue, 06 May 2014 13:54:26 -0700 (PDT)
Received: from fieldses.org (fieldses.org. [174.143.236.118])
        by mx.google.com with ESMTPS id kg10si126427oeb.203.2014.05.06.13.54.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 06 May 2014 13:54:25 -0700 (PDT)
Date: Tue, 6 May 2014 16:54:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 3/5] nfsd: Only set PF_LESS_THROTTLE when really needed.
Message-ID: <20140506205418.GQ18281@fieldses.org>
References: <20140423022441.4725.89693.stgit@notabene.brown>
 <20140423024058.4725.38098.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140423024058.4725.38098.stgit@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Dave Chinner <david@fromorbit.com>, Mel Gorman <mgorman@suse.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Apr 23, 2014 at 12:40:58PM +1000, NeilBrown wrote:
> PF_LESS_THROTTLE has a very specific use case: to avoid deadlocks
> and live-locks while writing to the page cache in a loop-back
> NFS mount situation.
> 
> It therefore makes sense to *only* set PF_LESS_THROTTLE in this
> situation.
> We now know when a request came from the local-host so it could be a
> loop-back mount.  We already know when we are handling write requests,
> and when we are doing anything else.
> 
> So combine those two to allow nfsd to still be throttled (like any
> other process) in every situation except when it is known to be
> problematic.

Looks simple enough, ACK.--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  fs/nfsd/nfssvc.c |    6 ------
>  fs/nfsd/vfs.c    |   12 ++++++++++++
>  2 files changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 9a4a5f9e7468..1879e43f2868 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -591,12 +591,6 @@ nfsd(void *vrqstp)
>  	nfsdstats.th_cnt++;
>  	mutex_unlock(&nfsd_mutex);
>  
> -	/*
> -	 * We want less throttling in balance_dirty_pages() so that nfs to
> -	 * localhost doesn't cause nfsd to lock up due to all the client's
> -	 * dirty pages.
> -	 */
> -	current->flags |= PF_LESS_THROTTLE;
>  	set_freezable();
>  
>  	/*
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 6d7be3f80356..2acd00445ad0 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -913,6 +913,16 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp, struct file *file,
>  	int			stable = *stablep;
>  	int			use_wgather;
>  	loff_t			pos = offset;
> +	unsigned int		pflags = current->flags;
> +
> +	if (rqstp->rq_local)
> +		/*
> +		 * We want less throttling in balance_dirty_pages()
> +		 * and shrink_inactive_list() so that nfs to
> +		 * localhost doesn't cause nfsd to lock up due to all
> +		 * the client's dirty pages or its congested queue.
> +		 */
> +		current->flags |= PF_LESS_THROTTLE;
>  
>  	dentry = file->f_path.dentry;
>  	inode = dentry->d_inode;
> @@ -950,6 +960,8 @@ out_nfserr:
>  		err = 0;
>  	else
>  		err = nfserrno(host_err);
> +	if (rqstp->rq_local)
> +		tsk_restore_flags(current, pflags, PF_LESS_THROTTLE);
>  	return err;
>  }
>  
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
