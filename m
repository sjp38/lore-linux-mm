Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EA5296B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 10:57:59 -0400 (EDT)
Date: Fri, 23 Jul 2010 16:57:30 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [patch 6/6] jbd2: remove dependency on __GFP_NOFAIL
Message-ID: <20100723145730.GD3305@quack.suse.cz>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1007201943340.8728@chino.kir.corp.google.com>
 <20100722141437.GA14882@thunk.org>
 <alpine.DEB.2.00.1007221108360.30080@chino.kir.corp.google.com>
 <20100722230935.GB16373@thunk.org>
 <alpine.DEB.2.00.1007221618001.4856@chino.kir.corp.google.com>
 <20100723141054.GE13090@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100723141054.GE13090@thunk.org>
Sender: owner-linux-mm@kvack.org
To: Ted Ts'o <tytso@mit.edu>
Cc: David Rientjes <rientjes@google.com>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andreas Dilger <adilger@sun.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri 23-07-10 10:10:54, Ted Ts'o wrote:
> On Thu, Jul 22, 2010 at 04:24:23PM -0700, David Rientjes wrote:
> > 
> > I didn't think about converting the existing GFP_NOFS | __GFP_NOFAIL 
> > callers into the do-while loop above until you mentioned it, thanks.  I'll 
> > send patches to do that shortly.
...
> From 814be805d5e3d12343e590631ff9bc2d65c8f60a Mon Sep 17 00:00:00 2001
> From: Theodore Ts'o <tytso@mit.edu>
> Date: Fri, 23 Jul 2010 10:06:53 -0400
> Subject: [PATCH] jbd2: Remove __GFP_NOFAIL from jbd2 layer
> 
> __GFP_NOFAIL is going away, so add our own retry loop.  Also add
> jbd2__journal_start() and jbd2__journal_restart() which take a gfp
> mask, so that file systems can optionally (re)start transaction
> handles using GFP_KERNEL.  If they do this, then they need to be
> prepared to handle receiving an PTR_ERR(-ENOMEM) error, and be ready
> to reflect that error up to userspace.
> 
> Signed-off-by: "Theodore Ts'o" <tytso@mit.edu>
> ---
>  fs/jbd2/journal.c     |   14 +++++++++--
>  fs/jbd2/transaction.c |   60 +++++++++++++++++++++++++++++++++---------------
>  include/linux/jbd2.h  |    4 ++-
>  3 files changed, 55 insertions(+), 23 deletions(-)
> 
> diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
> index e214d68..43241c0 100644
> --- a/fs/jbd2/transaction.c
> +++ b/fs/jbd2/transaction.c
> @@ -83,30 +83,39 @@ jbd2_get_transaction(journal_t *journal, transaction_t *transaction)
>   * transaction's buffer credits.
>   */
>  
> -static int start_this_handle(journal_t *journal, handle_t *handle)
> +static int start_this_handle(journal_t *journal, handle_t *handle,
> +			     int gfp_mask)
>  {
>  	transaction_t *transaction;
>  	int needed;
>  	int nblocks = handle->h_buffer_credits;
>  	transaction_t *new_transaction = NULL;
> -	int ret = 0;
>  	unsigned long ts = jiffies;
>  
>  	if (nblocks > journal->j_max_transaction_buffers) {
>  		printk(KERN_ERR "JBD: %s wants too many credits (%d > %d)\n",
>  		       current->comm, nblocks,
>  		       journal->j_max_transaction_buffers);
> -		ret = -ENOSPC;
> -		goto out;
> +		return -ENOSPC;
>  	}
>  
>  alloc_transaction:
>  	if (!journal->j_running_transaction) {
> -		new_transaction = kzalloc(sizeof(*new_transaction),
> -						GFP_NOFS|__GFP_NOFAIL);
> +	retry_alloc:
> +		new_transaction = kzalloc(sizeof(*new_transaction), gfp_mask);
>  		if (!new_transaction) {
> -			ret = -ENOMEM;
> -			goto out;
> +			/*
> +			 * If __GFP_FS is not present, then we may be
> +			 * being called from inside the fs writeback
> +			 * layer, so we MUST NOT fail.  Since
> +			 * __GFP_NOFAIL is going away, we will arrange
> +			 * to retry the allocation ourselves.
> +			 */
> +			if ((gfp & __GFP_FS) == 0) {
> +				congestion_wait(BLK_RW_ASYNC, HZ/50);
> +				goto retry_alloc;
    You could as well go to alloc_transaction label above...

> +			}
> +			return -ENOMEM;
>  		}
>  	}
>  
...
> @@ -278,7 +285,7 @@ static handle_t *new_handle(int nblocks)
>   *
>   * Return a pointer to a newly allocated handle, or NULL on failure
>   */
> -handle_t *jbd2_journal_start(journal_t *journal, int nblocks)
> +handle_t *jbd2__journal_start(journal_t *journal, int nblocks, int gfp_mask)
>  {
>  	handle_t *handle = journal_current_handle();
>  	int err;
> @@ -298,7 +305,7 @@ handle_t *jbd2_journal_start(journal_t *journal, int nblocks)
>  
>  	current->journal_info = handle;
>  
> -	err = start_this_handle(journal, handle);
> +	err = start_this_handle(journal, handle, GFP_NOFS);
  Here you want to use gfp_mask I guess.

>  	if (err < 0) {
>  		jbd2_free_handle(handle);
>  		current->journal_info = NULL;
> @@ -308,6 +315,15 @@ handle_t *jbd2_journal_start(journal_t *journal, int nblocks)
>  out:
>  	return handle;
>  }
> +EXPORT_SYMBOL(jbd2__journal_start);
> +
> +
> +handle_t *jbd2_journal_start(journal_t *journal, int nblocks)
> +{
> +	return jbd2__journal_start(journal, nblocks, GFP_NOFS);
> +}
> +EXPORT_SYMBOL(jbd2_journal_start);
> +
>  
>  /**
>   * int jbd2_journal_extend() - extend buffer credits.
> @@ -394,8 +410,7 @@ out:
>   * transaction capabable of guaranteeing the requested number of
>   * credits.
>   */
> -
> -int jbd2_journal_restart(handle_t *handle, int nblocks)
> +int jbd2__journal_restart(handle_t *handle, int nblocks, int gfp_mask)
>  {
>  	transaction_t *transaction = handle->h_transaction;
>  	journal_t *journal = transaction->t_journal;
> @@ -428,10 +443,17 @@ int jbd2_journal_restart(handle_t *handle, int nblocks)
>  
>  	lock_map_release(&handle->h_lockdep_map);
>  	handle->h_buffer_credits = nblocks;
> -	ret = start_this_handle(journal, handle);
> +	ret = start_this_handle(journal, handle, GFP_NOFS);
  And here you want to use gfp_mask as well.

>  	return ret;
>  }
> +EXPORT_SYMBOL(jbd2__journal_restart);
> +
>  
> +int jbd2_journal_restart(handle_t *handle, int nblocks)
> +{
> +	return jbd2__journal_restart(handle, nblocks, GFP_NOFS);
> +}
> +EXPORT_SYMBOL(jbd2_journal_restart);
>  
>  /**
>   * void jbd2_journal_lock_updates () - establish a transaction barrier.


								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
