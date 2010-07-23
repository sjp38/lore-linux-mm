Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1645E6B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 11:32:50 -0400 (EDT)
Date: Fri, 23 Jul 2010 17:32:22 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [patch 6/6] jbd2: remove dependency on __GFP_NOFAIL
Message-ID: <20100723153221.GE3305@quack.suse.cz>
References: <alpine.DEB.2.00.1007201936210.8728@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1007201943340.8728@chino.kir.corp.google.com>
 <20100722141437.GA14882@thunk.org>
 <alpine.DEB.2.00.1007221108360.30080@chino.kir.corp.google.com>
 <20100722230935.GB16373@thunk.org>
 <alpine.DEB.2.00.1007221618001.4856@chino.kir.corp.google.com>
 <20100723141054.GE13090@thunk.org>
 <20100723145730.GD3305@quack.suse.cz>
 <20100723150543.GG13090@thunk.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100723150543.GG13090@thunk.org>
Sender: owner-linux-mm@kvack.org
To: Ted Ts'o <tytso@mit.edu>
Cc: Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andreas Dilger <adilger@sun.com>, Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-ext4@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri 23-07-10 11:05:43, Ted Ts'o wrote:
> Yeah, oops.  Nice catches.  I also hadn't done a test compile, so
> there were some missing #include's.
> 
> So once more, this time with feeling...
> 
> 					- Ted
> 
> From d24408e1b50e47b21b7d2ec5857b710e9b752dc9 Mon Sep 17 00:00:00 2001
> From: Theodore Ts'o <tytso@mit.edu>
> Date: Fri, 23 Jul 2010 11:03:45 -0400
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
  Now the patch looks good.
Acked-by: Jan Kara <jack@suse.cz>

								Honza

> ---
>  fs/jbd2/journal.c     |   15 +++++++++--
>  fs/jbd2/transaction.c |   61 +++++++++++++++++++++++++++++++++---------------
>  include/linux/jbd2.h  |    4 ++-
>  3 files changed, 57 insertions(+), 23 deletions(-)
> 
> diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
> index f7bf157..a79d334 100644
> --- a/fs/jbd2/journal.c
> +++ b/fs/jbd2/journal.c
> @@ -41,6 +41,7 @@
>  #include <linux/hash.h>
>  #include <linux/log2.h>
>  #include <linux/vmalloc.h>
> +#include <linux/backing-dev.h>
>  
>  #define CREATE_TRACE_POINTS
>  #include <trace/events/jbd2.h>
> @@ -48,8 +49,6 @@
>  #include <asm/uaccess.h>
>  #include <asm/page.h>
>  
> -EXPORT_SYMBOL(jbd2_journal_start);
> -EXPORT_SYMBOL(jbd2_journal_restart);
>  EXPORT_SYMBOL(jbd2_journal_extend);
>  EXPORT_SYMBOL(jbd2_journal_stop);
>  EXPORT_SYMBOL(jbd2_journal_lock_updates);
> @@ -311,7 +310,17 @@ int jbd2_journal_write_metadata_buffer(transaction_t *transaction,
>  	 */
>  	J_ASSERT_BH(bh_in, buffer_jbddirty(bh_in));
>  
> -	new_bh = alloc_buffer_head(GFP_NOFS|__GFP_NOFAIL);
> +retry_alloc:
> +	new_bh = alloc_buffer_head(GFP_NOFS);
> +	if (!new_bh) {
> +		/*
> +		 * Failure is not an option, but __GFP_NOFAIL is going
> +		 * away; so we retry ourselves here.
> +		 */
> +		congestion_wait(BLK_RW_ASYNC, HZ/50);
> +		goto retry_alloc;
> +	}
> +
>  	/* keep subsequent assertions sane */
>  	new_bh->b_state = 0;
>  	init_buffer(new_bh, NULL, NULL);
> diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
> index e214d68..001e95f 100644
> --- a/fs/jbd2/transaction.c
> +++ b/fs/jbd2/transaction.c
> @@ -26,6 +26,8 @@
>  #include <linux/mm.h>
>  #include <linux/highmem.h>
>  #include <linux/hrtimer.h>
> +#include <linux/backing-dev.h>
> +#include <linux/module.h>
>  
>  static void __jbd2_journal_temp_unlink_buffer(struct journal_head *jh);
>  
> @@ -83,30 +85,38 @@ jbd2_get_transaction(journal_t *journal, transaction_t *transaction)
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
> +			if ((gfp_mask & __GFP_FS) == 0) {
> +				congestion_wait(BLK_RW_ASYNC, HZ/50);
> +				goto alloc_transaction;
> +			}
> +			return -ENOMEM;
>  		}
>  	}
>  
> @@ -123,8 +133,8 @@ repeat_locked:
>  	if (is_journal_aborted(journal) ||
>  	    (journal->j_errno != 0 && !(journal->j_flags & JBD2_ACK_ERR))) {
>  		spin_unlock(&journal->j_state_lock);
> -		ret = -EROFS;
> -		goto out;
> +		kfree(new_transaction);
> +		return -EROFS;
>  	}
>  
>  	/* Wait on the journal's transaction barrier if necessary */
> @@ -240,10 +250,8 @@ repeat_locked:
>  	spin_unlock(&journal->j_state_lock);
>  
>  	lock_map_acquire(&handle->h_lockdep_map);
> -out:
> -	if (unlikely(new_transaction))		/* It's usually NULL */
> -		kfree(new_transaction);
> -	return ret;
> +	kfree(new_transaction);
> +	return 0;
>  }
>  
>  static struct lock_class_key jbd2_handle_key;
> @@ -278,7 +286,7 @@ static handle_t *new_handle(int nblocks)
>   *
>   * Return a pointer to a newly allocated handle, or NULL on failure
>   */
> -handle_t *jbd2_journal_start(journal_t *journal, int nblocks)
> +handle_t *jbd2__journal_start(journal_t *journal, int nblocks, int gfp_mask)
>  {
>  	handle_t *handle = journal_current_handle();
>  	int err;
> @@ -298,7 +306,7 @@ handle_t *jbd2_journal_start(journal_t *journal, int nblocks)
>  
>  	current->journal_info = handle;
>  
> -	err = start_this_handle(journal, handle);
> +	err = start_this_handle(journal, handle, gfp_mask);
>  	if (err < 0) {
>  		jbd2_free_handle(handle);
>  		current->journal_info = NULL;
> @@ -308,6 +316,15 @@ handle_t *jbd2_journal_start(journal_t *journal, int nblocks)
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
> @@ -394,8 +411,7 @@ out:
>   * transaction capabable of guaranteeing the requested number of
>   * credits.
>   */
> -
> -int jbd2_journal_restart(handle_t *handle, int nblocks)
> +int jbd2__journal_restart(handle_t *handle, int nblocks, int gfp_mask)
>  {
>  	transaction_t *transaction = handle->h_transaction;
>  	journal_t *journal = transaction->t_journal;
> @@ -428,10 +444,17 @@ int jbd2_journal_restart(handle_t *handle, int nblocks)
>  
>  	lock_map_release(&handle->h_lockdep_map);
>  	handle->h_buffer_credits = nblocks;
> -	ret = start_this_handle(journal, handle);
> +	ret = start_this_handle(journal, handle, gfp_mask);
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
> diff --git a/include/linux/jbd2.h b/include/linux/jbd2.h
> index a4d2e9f..5a72bc7 100644
> --- a/include/linux/jbd2.h
> +++ b/include/linux/jbd2.h
> @@ -1081,7 +1081,9 @@ static inline handle_t *journal_current_handle(void)
>   */
>  
>  extern handle_t *jbd2_journal_start(journal_t *, int nblocks);
> -extern int	 jbd2_journal_restart (handle_t *, int nblocks);
> +extern handle_t *jbd2__journal_start(journal_t *, int nblocks, int gfp_mask);
> +extern int	 jbd2_journal_restart(handle_t *, int nblocks);
> +extern int	 jbd2__journal_restart(handle_t *, int nblocks, int gfp_mask);
>  extern int	 jbd2_journal_extend (handle_t *, int nblocks);
>  extern int	 jbd2_journal_get_write_access(handle_t *, struct buffer_head *);
>  extern int	 jbd2_journal_get_create_access (handle_t *, struct buffer_head *);
> -- 
> 1.7.0.4
> 
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
