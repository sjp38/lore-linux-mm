Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5DC6B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 07:42:43 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so204646940wib.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 04:42:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f6si9824006wiw.5.2015.08.05.04.42.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 04:42:41 -0700 (PDT)
Date: Wed, 5 Aug 2015 13:42:35 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC 4/8] jbd, jbd2: Do not fail journal because of
 frozen_buffer allocation failure
Message-ID: <20150805114235.GA5132@quack.suse.cz>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
 <1438768284-30927-5-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438768284-30927-5-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>

On Wed 05-08-15 11:51:20, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Journal transaction might fail prematurely because the frozen_buffer
> is allocated by GFP_NOFS request:
> [   72.440013] do_get_write_access: OOM for frozen_buffer
> [   72.440014] EXT4-fs: ext4_reserve_inode_write:4729: aborting transaction: Out of memory in __ext4_journal_get_write_access
> [   72.440015] EXT4-fs error (device sda1) in ext4_reserve_inode_write:4735: Out of memory
> (...snipped....)
> [   72.495559] do_get_write_access: OOM for frozen_buffer
> [   72.495560] EXT4-fs: ext4_reserve_inode_write:4729: aborting transaction: Out of memory in __ext4_journal_get_write_access
> [   72.496839] do_get_write_access: OOM for frozen_buffer
> [   72.496841] EXT4-fs: ext4_reserve_inode_write:4729: aborting transaction: Out of memory in __ext4_journal_get_write_access
> [   72.505766] Aborting journal on device sda1-8.
> [   72.505851] EXT4-fs (sda1): Remounting filesystem read-only
> 
> This wasn't a problem until "mm: page_alloc: do not lock up GFP_NOFS
> allocations upon OOM" because small GPF_NOFS allocations never failed.
> This allocation seems essential for the journal and GFP_NOFS is too
> restrictive to the memory allocator so let's use __GFP_NOFAIL here to
> emulate the previous behavior.
> 
> jbd code has the very same issue so let's do the same there as well.

The patch looks good. Btw, the patch 6 can be folded into this patch since
it fixes the issue you fix for jbd2 here... But jbd parts will be dropped
in the next merge window anyway so it doesn't really matter.

You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  fs/jbd/transaction.c  | 11 +----------
>  fs/jbd2/transaction.c | 14 +++-----------
>  2 files changed, 4 insertions(+), 21 deletions(-)
> 
> diff --git a/fs/jbd/transaction.c b/fs/jbd/transaction.c
> index 1695ba8334a2..bf7474deda2f 100644
> --- a/fs/jbd/transaction.c
> +++ b/fs/jbd/transaction.c
> @@ -673,16 +673,7 @@ do_get_write_access(handle_t *handle, struct journal_head *jh,
>  				jbd_unlock_bh_state(bh);
>  				frozen_buffer =
>  					jbd_alloc(jh2bh(jh)->b_size,
> -							 GFP_NOFS);
> -				if (!frozen_buffer) {
> -					printk(KERN_ERR
> -					       "%s: OOM for frozen_buffer\n",
> -					       __func__);
> -					JBUFFER_TRACE(jh, "oom!");
> -					error = -ENOMEM;
> -					jbd_lock_bh_state(bh);
> -					goto done;
> -				}
> +							 GFP_NOFS|__GFP_NOFAIL);
>  				goto repeat;
>  			}
>  			jh->b_frozen_data = frozen_buffer;
> diff --git a/fs/jbd2/transaction.c b/fs/jbd2/transaction.c
> index ff2f2e6ad311..bff071e21553 100644
> --- a/fs/jbd2/transaction.c
> +++ b/fs/jbd2/transaction.c
> @@ -923,16 +923,7 @@ do_get_write_access(handle_t *handle, struct journal_head *jh,
>  				jbd_unlock_bh_state(bh);
>  				frozen_buffer =
>  					jbd2_alloc(jh2bh(jh)->b_size,
> -							 GFP_NOFS);
> -				if (!frozen_buffer) {
> -					printk(KERN_ERR
> -					       "%s: OOM for frozen_buffer\n",
> -					       __func__);
> -					JBUFFER_TRACE(jh, "oom!");
> -					error = -ENOMEM;
> -					jbd_lock_bh_state(bh);
> -					goto done;
> -				}
> +							 GFP_NOFS|__GFP_NOFAIL);
>  				goto repeat;
>  			}
>  			jh->b_frozen_data = frozen_buffer;
> @@ -1157,7 +1148,8 @@ int jbd2_journal_get_undo_access(handle_t *handle, struct buffer_head *bh)
>  
>  repeat:
>  	if (!jh->b_committed_data) {
> -		committed_data = jbd2_alloc(jh2bh(jh)->b_size, GFP_NOFS);
> +		committed_data = jbd2_alloc(jh2bh(jh)->b_size,
> +					    GFP_NOFS|__GFP_NOFAIL);
>  		if (!committed_data) {
>  			printk(KERN_ERR "%s: No memory for committed data\n",
>  				__func__);
> -- 
> 2.5.0
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
