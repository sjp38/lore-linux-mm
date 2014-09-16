Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id C10A86B0036
	for <linux-mm@kvack.org>; Tue, 16 Sep 2014 08:39:49 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kq14so8763607pab.33
        for <linux-mm@kvack.org>; Tue, 16 Sep 2014 05:39:46 -0700 (PDT)
Received: from mx12.netapp.com (mx12.netapp.com. [216.240.18.77])
        by mx.google.com with ESMTPS id db9si7071188pdb.36.2014.09.16.05.39.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 16 Sep 2014 05:39:45 -0700 (PDT)
Message-ID: <54182F8B.8010302@Netapp.com>
Date: Tue, 16 Sep 2014 08:39:39 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] NFS: avoid deadlocks with loop-back mounted NFS filesystems.
References: <20140916051911.22257.24658.stgit@notabene.brown> <20140916053135.22257.68002.stgit@notabene.brown>
In-Reply-To: <20140916053135.22257.68002.stgit@notabene.brown>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@primarydata.com>, Ingo Molnar <mingo@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Jeff Layton <jeff.layton@primarydata.com>

On 09/16/2014 01:31 AM, NeilBrown wrote:
> Support for loop-back mounted NFS filesystems is useful when NFS is
> used to access shared storage in a high-availability cluster.
>
> If the node running the NFS server fails, some other node can mount the
> filesystem and start providing NFS service.  If that node already had
> the filesystem NFS mounted, it will now have it loop-back mounted.
>
> nfsd can suffer a deadlock when allocating memory and entering direct
> reclaim.
> While direct reclaim does not write to the NFS filesystem it can send
> and wait for a COMMIT through nfs_release_page().

Is there anything that can be done on the nfsd side to prevent the deadlocks?

Anna

>
> This patch modifies nfs_release_page() to wait a limited time for the
> commit to complete - one second.  If the commit doesn't complete
> in this time, nfs_release_page() will fail.  This means it might now
> fail in some cases where it wouldn't before.  These cases are only
> when 'gfp' includes '__GFP_WAIT'.
>
> nfs_release_page() is only called by try_to_release_page(), and that
> can only be called on an NFS page with required 'gfp' flags from
>  - page_cache_pipe_buf_steal() in splice.c
>  - shrink_page_list() in vmscan.c
>  - invalidate_inode_pages2_range() in truncate.c
>
> The first two handle failure quite safely.  The last is only called
> after ->launder_page() has been called, and that will have waited
> for the commit to finish already.
>
> So aborting if the commit takes longer than 1 second is perfectly safe.
>
> 1 second may be longer than is really necessary, but it is much
> shorter than the current maximum wait, so this is not a regression.
> Some waiting is needed to help slow down memory allocation to the
> rate that we can complete writeout of pages.
>
> In those rare cases where it is nfsd, or something that nfsd is
> waiting for, that is calling nfs_release_page(), this delay will at
> most cause a small hic-cough in places where it currently deadlocks.
>
> Signed-off-by: NeilBrown <neilb@suse.de>
> ---
>  fs/nfs/file.c  |   24 ++++++++++++++----------
>  fs/nfs/write.c |    2 ++
>  2 files changed, 16 insertions(+), 10 deletions(-)
>
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 524dd80d1898..8d74983417af 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -468,17 +468,21 @@ static int nfs_release_page(struct page *page, gfp_t gfp)
>  
>  	dfprintk(PAGECACHE, "NFS: release_page(%p)\n", page);
>  
> -	/* Only do I/O if gfp is a superset of GFP_KERNEL, and we're not
> -	 * doing this memory reclaim for a fs-related allocation.
> +	/* Always try to initiate a 'commit' if relevant, but only
> +	 * wait for it if __GFP_WAIT is set and the calling process is
> +	 * allowed to block.  Even then, only wait 1 second.  Waiting
> +	 * indefinitely can cause deadlocks when the NFS server is on
> +	 * this machine, and there is no particular need to wait
> +	 * extensively here.  A short wait has the benefit that
> +	 * someone else can worry about the freezer.
>  	 */
> -	if (mapping && (gfp & GFP_KERNEL) == GFP_KERNEL &&
> -	    !(current->flags & PF_FSTRANS)) {
> -		int how = FLUSH_SYNC;
> -
> -		/* Don't let kswapd deadlock waiting for OOM RPC calls */
> -		if (current_is_kswapd())
> -			how = 0;
> -		nfs_commit_inode(mapping->host, how);
> +	if (mapping) {
> +		nfs_commit_inode(mapping->host, 0);
> +		if ((gfp & __GFP_WAIT) &&
> +		    !current_is_kswapd() &&
> +		    !(current->flags & PF_FSTRANS))
> +			wait_on_page_bit_killable_timeout(page, PG_private,
> +							  HZ);
>  	}
>  	/* If PagePrivate() is set, then the page is not freeable */
>  	if (PagePrivate(page))
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 175d5d073ccf..b5d83c7545d4 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -731,6 +731,8 @@ static void nfs_inode_remove_request(struct nfs_page *req)
>  		if (likely(!PageSwapCache(head->wb_page))) {
>  			set_page_private(head->wb_page, 0);
>  			ClearPagePrivate(head->wb_page);
> +			smp_mb__after_atomic();
> +			wake_up_page(head->wb_page, PG_private);
>  			clear_bit(PG_MAPPED, &head->wb_flags);
>  		}
>  		nfsi->npages--;
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
