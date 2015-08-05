Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id CBD3A6B0255
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 07:43:41 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so62778955wib.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 04:43:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mi6si28163745wic.25.2015.08.05.04.43.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 04:43:40 -0700 (PDT)
Date: Wed, 5 Aug 2015 13:43:36 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC 5/8] ext4: Do not fail journal due to block allocator
Message-ID: <20150805114336.GB5132@quack.suse.cz>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
 <1438768284-30927-6-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438768284-30927-6-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.com>

On Wed 05-08-15 11:51:21, mhocko@kernel.org wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Since "mm: page_alloc: do not lock up GFP_NOFS allocations upon OOM"
> memory allocator doesn't endlessly loop to satisfy low-order allocations
> and instead fails them to allow callers to handle them gracefully.
> 
> Some of the callers are not yet prepared for this behavior though. ext4
> block allocator relies solely on GFP_NOFS allocation requests and
> allocation failures lead to aborting yournal too easily:
> 
> [  345.028333] oom-trash: page allocation failure: order:0, mode:0x50
> [  345.028336] CPU: 1 PID: 8334 Comm: oom-trash Tainted: G        W       4.0.0-nofs3-00006-gdfe9931f5f68 #588
> [  345.028337] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.8.1-20150428_134905-gandalf 04/01/2014
> [  345.028339]  0000000000000000 ffff880005a17708 ffffffff81538a54 ffffffff8107a40f
> [  345.028341]  0000000000000050 ffff880005a17798 ffffffff810fe854 0000000180000000
> [  345.028342]  0000000000000046 0000000000000000 ffffffff81a52100 0000000000000246
> [  345.028343] Call Trace:
> [  345.028348]  [<ffffffff81538a54>] dump_stack+0x4f/0x7b
> [  345.028370]  [<ffffffff810fe854>] warn_alloc_failed+0x12a/0x13f
> [  345.028373]  [<ffffffff81101bd2>] __alloc_pages_nodemask+0x7f3/0x8aa
> [  345.028375]  [<ffffffff810f9933>] pagecache_get_page+0x12a/0x1c9
> [  345.028390]  [<ffffffffa005bc64>] ext4_mb_load_buddy+0x220/0x367 [ext4]
> [  345.028414]  [<ffffffffa006014f>] ext4_free_blocks+0x522/0xa4c [ext4]
> [  345.028425]  [<ffffffffa0054e14>] ext4_ext_remove_space+0x833/0xf22 [ext4]
> [  345.028434]  [<ffffffffa005677e>] ext4_ext_truncate+0x8c/0xb0 [ext4]
> [  345.028441]  [<ffffffffa00342bf>] ext4_truncate+0x20b/0x38d [ext4]
> [  345.028462]  [<ffffffffa003573c>] ext4_evict_inode+0x32b/0x4c1 [ext4]
> [  345.028464]  [<ffffffff8116d04f>] evict+0xa0/0x148
> [  345.028466]  [<ffffffff8116dca8>] iput+0x1a1/0x1f0
> [  345.028468]  [<ffffffff811697b4>] __dentry_kill+0x136/0x1a6
> [  345.028470]  [<ffffffff81169a3e>] dput+0x21a/0x243
> [  345.028472]  [<ffffffff81157cda>] __fput+0x184/0x19b
> [  345.028473]  [<ffffffff81157d29>] ____fput+0xe/0x10
> [  345.028475]  [<ffffffff8105a05f>] task_work_run+0x8a/0xa1
> [  345.028477]  [<ffffffff810452f0>] do_exit+0x3c6/0x8dc
> [  345.028482]  [<ffffffff8104588a>] do_group_exit+0x4d/0xb2
> [  345.028483]  [<ffffffff8104eeeb>] get_signal+0x5b1/0x5f5
> [  345.028488]  [<ffffffff81002202>] do_signal+0x28/0x5d0
> [...]
> [  345.028624] EXT4-fs error (device hdb1) in ext4_free_blocks:4879: Out of memory
> [  345.033097] Aborting journal on device hdb1-8.
> [  345.036339] EXT4-fs (hdb1): Remounting filesystem read-only
> [  345.036344] EXT4-fs error (device hdb1) in ext4_reserve_inode_write:4834: Journal has aborted
> [  345.036766] EXT4-fs error (device hdb1) in ext4_reserve_inode_write:4834: Journal has aborted
> [  345.038583] EXT4-fs error (device hdb1) in ext4_ext_remove_space:3048: Journal has aborted
> [  345.049115] EXT4-fs error (device hdb1) in ext4_ext_truncate:4669: Journal has aborted
> [  345.050434] EXT4-fs error (device hdb1) in ext4_reserve_inode_write:4834: Journal has aborted
> [  345.053064] EXT4-fs error (device hdb1) in ext4_truncate:3668: Journal has aborted
> [  345.053582] EXT4-fs error (device hdb1) in ext4_reserve_inode_write:4834: Journal has aborted
> [  345.053946] EXT4-fs error (device hdb1) in ext4_orphan_del:2686: Journal has aborted
> [  345.055367] EXT4-fs error (device hdb1) in ext4_reserve_inode_write:4834: Journal has aborted
> 
> The failure is really premature because GFP_NOFS allocation context is
> very restricted - especially in the fs metadata heavy loads. Before we
> go with a more sofisticated solution, let's simply imitate the previous
> behavior of non-failing NOFS allocation and use __GFP_NOFAIL for the
> buddy block allocator. I wasn't able to trigger the issue with this
> patch anymore.
 
The patch looks good. You can add:

Reviewed-by: Jan Kara <jack@suse.com>

								Honza

> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  fs/ext4/mballoc.c | 12 ++++++++----
>  1 file changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
> index 5b1613a54307..e6361622bfd5 100644
> --- a/fs/ext4/mballoc.c
> +++ b/fs/ext4/mballoc.c
> @@ -992,7 +992,8 @@ static int ext4_mb_get_buddy_page_lock(struct super_block *sb,
>  	block = group * 2;
>  	pnum = block / blocks_per_page;
>  	poff = block % blocks_per_page;
> -	page = find_or_create_page(inode->i_mapping, pnum, GFP_NOFS);
> +	page = find_or_create_page(inode->i_mapping, pnum,
> +				   GFP_NOFS|__GFP_NOFAIL);
>  	if (!page)
>  		return -ENOMEM;
>  	BUG_ON(page->mapping != inode->i_mapping);
> @@ -1006,7 +1007,8 @@ static int ext4_mb_get_buddy_page_lock(struct super_block *sb,
>  
>  	block++;
>  	pnum = block / blocks_per_page;
> -	page = find_or_create_page(inode->i_mapping, pnum, GFP_NOFS);
> +	page = find_or_create_page(inode->i_mapping, pnum,
> +				   GFP_NOFS|__GFP_NOFAIL);
>  	if (!page)
>  		return -ENOMEM;
>  	BUG_ON(page->mapping != inode->i_mapping);
> @@ -1158,7 +1160,8 @@ ext4_mb_load_buddy(struct super_block *sb, ext4_group_t group,
>  			 * wait for it to initialize.
>  			 */
>  			page_cache_release(page);
> -		page = find_or_create_page(inode->i_mapping, pnum, GFP_NOFS);
> +		page = find_or_create_page(inode->i_mapping, pnum,
> +					   GFP_NOFS|__GFP_NOFAIL);
>  		if (page) {
>  			BUG_ON(page->mapping != inode->i_mapping);
>  			if (!PageUptodate(page)) {
> @@ -1194,7 +1197,8 @@ ext4_mb_load_buddy(struct super_block *sb, ext4_group_t group,
>  	if (page == NULL || !PageUptodate(page)) {
>  		if (page)
>  			page_cache_release(page);
> -		page = find_or_create_page(inode->i_mapping, pnum, GFP_NOFS);
> +		page = find_or_create_page(inode->i_mapping, pnum,
> +					   GFP_NOFS|__GFP_NOFAIL);
>  		if (page) {
>  			BUG_ON(page->mapping != inode->i_mapping);
>  			if (!PageUptodate(page)) {
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
