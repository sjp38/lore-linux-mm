Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7ABFF6B0038
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 12:49:30 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so8341337pab.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 09:49:30 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id fx5si6129857pdb.170.2015.08.05.09.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 09:49:29 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so20927909pdr.2
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 09:49:29 -0700 (PDT)
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org> <1438768284-30927-5-git-send-email-mhocko@kernel.org>
From: Greg Thelen <gthelen@google.com>
Subject: Re: [RFC 4/8] jbd, jbd2: Do not fail journal because of frozen_buffer allocation failure
In-reply-to: <1438768284-30927-5-git-send-email-mhocko@kernel.org>
Date: Wed, 05 Aug 2015 09:49:24 -0700
Message-ID: <xr93twsdwui3.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>


mhocko@kernel.org wrote:

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

Is this "if (!committed_data) {" check now dead code?

I also see other similar suspected dead sites in the rest of the series.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
