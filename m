Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id CE9F16B0035
	for <linux-mm@kvack.org>; Wed, 30 Jul 2014 17:02:43 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so2206351pab.34
        for <linux-mm@kvack.org>; Wed, 30 Jul 2014 14:02:43 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id by6si3572167pab.140.2014.07.30.14.02.42
        for <linux-mm@kvack.org>;
        Wed, 30 Jul 2014 14:02:42 -0700 (PDT)
Date: Wed, 30 Jul 2014 17:02:40 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v7 07/22] Replace the XIP page fault handler with the DAX
 page fault handler
Message-ID: <20140730210239.GS6754@linux.intel.com>
References: <cover.1395591795.git.matthew.r.wilcox@intel.com>
 <c2e602f401a580c4fac54b9b8f4a6f8dd0ac1071.1395591795.git.matthew.r.wilcox@intel.com>
 <20140409102758.GM32103@quack.suse.cz>
 <20140409205111.GG5727@linux.intel.com>
 <20140409214331.GQ32103@quack.suse.cz>
 <20140729121259.GL6754@linux.intel.com>
 <20140729210457.GA17807@quack.suse.cz>
 <20140729212333.GO6754@linux.intel.com>
 <20140730095229.GA19205@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140730095229.GA19205@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 30, 2014 at 11:52:29AM +0200, Jan Kara wrote:
>   I see the problem now. How about an attached patch? Do you see other
> lockdep warnings with it?

This patch fixes the problem, thanks!  Regardless of DAX, I think this
patch should be applied in order to avoid creating a dependency between
i_mmap_mutex and jbd2_handle.

I've now run into a different problem with COW pages ... more later.

> >From c01c905cf3c4c6304a5ea9836389d9cf0d575884 Mon Sep 17 00:00:00 2001
> From: Jan Kara <jack@suse.cz>
> Date: Wed, 30 Jul 2014 11:49:07 +0200
> Subject: [PATCH] ext4: Avoid lock inversion between i_mmap_mutex and
>  transaction start
> 
> When DAX is enabled, it uses i_mmap_mutex as a protection against
> truncate during page fault. This inevitably forces i_mmap_mutex to rank
> outside of a transaction start and thus we have to avoid calling
> pagecache purging operations when transaction is started.
> 
> Signed-off-by: Jan Kara <jack@suse.cz>
> ---
>  fs/ext4/inode.c | 14 ++++++++++----
>  1 file changed, 10 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
> index 8a064734e6eb..494a8645d63e 100644
> --- a/fs/ext4/inode.c
> +++ b/fs/ext4/inode.c
> @@ -3631,13 +3631,19 @@ int ext4_punch_hole(struct inode *inode, loff_t offset, loff_t length)
>  	if (IS_SYNC(inode))
>  		ext4_handle_sync(handle);
>  
> -	/* Now release the pages again to reduce race window */
> +	inode->i_mtime = inode->i_ctime = ext4_current_time(inode);
> +	ext4_mark_inode_dirty(handle, inode);
> +	ext4_journal_stop(handle);
> +
> +	/*
> +	 * Now release the pages again to reduce race window. This has to happen
> +	 * outside of a transaction to avoid lock inversion on i_mmap_mutex
> +	 * when DAX is enabled.
> +	 */
>  	if (last_block_offset > first_block_offset)
>  		truncate_pagecache_range(inode, first_block_offset,
>  					 last_block_offset);
> -
> -	inode->i_mtime = inode->i_ctime = ext4_current_time(inode);
> -	ext4_mark_inode_dirty(handle, inode);
> +	goto out_dio;
>  out_stop:
>  	ext4_journal_stop(handle);
>  out_dio:
> -- 
> 1.8.1.4
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
