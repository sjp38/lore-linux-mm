Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 170D99003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 06:40:27 -0400 (EDT)
Received: by igr7 with SMTP id 7so64404992igr.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 03:40:27 -0700 (PDT)
Received: from mailout4.samsung.com (mailout4.samsung.com. [203.254.224.34])
        by mx.google.com with ESMTPS id b1si2962806pdk.16.2015.07.22.03.40.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 03:40:26 -0700 (PDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NRV00I4XXNC81C0@mailout4.samsung.com> for linux-mm@kvack.org;
 Wed, 22 Jul 2015 19:40:24 +0900 (KST)
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: [RFC v3 2/4] ext4: Add helper function to mark group as corrupted
Date: Wed, 22 Jul 2015 12:40:03 +0200
Message-id: <3417027.tdShitEpvE@amdc1976>
In-reply-to: <1434460173-18427-3-git-send-email-b.michalska@samsung.com>
References: <1434460173-18427-1-git-send-email-b.michalska@samsung.com>
 <1434460173-18427-3-git-send-email-b.michalska@samsung.com>
MIME-version: 1.0
Content-transfer-encoding: 7Bit
Content-type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>, tytso@mit.edu
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, greg@kroah.com, jack@suse.cz, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org


Hi,

On Tuesday, June 16, 2015 03:09:31 PM Beata Michalska wrote:
> Add ext4_mark_group_corrupted helper function to
> simplify the code and to keep the logic in one place.
> 
> Signed-off-by: Beata Michalska <b.michalska@samsung.com>

This small cleanup patch is not really required for your
notifications framework to work and it seems to be a good
change on its own.  Maybe it can be merged independently of
other patches?  Ted, what is your opinion on it?

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung R&D Institute Poland
Samsung Electronics

> ---
>  fs/ext4/balloc.c  |   15 +++------------
>  fs/ext4/ext4.h    |    9 +++++++++
>  fs/ext4/ialloc.c  |    5 +----
>  fs/ext4/mballoc.c |   11 ++---------
>  4 files changed, 15 insertions(+), 25 deletions(-)
> 
> diff --git a/fs/ext4/balloc.c b/fs/ext4/balloc.c
> index 83a6f49..e95b27a 100644
> --- a/fs/ext4/balloc.c
> +++ b/fs/ext4/balloc.c
> @@ -193,10 +193,7 @@ static int ext4_init_block_bitmap(struct super_block *sb,
>  	 * essentially implementing a per-group read-only flag. */
>  	if (!ext4_group_desc_csum_verify(sb, block_group, gdp)) {
>  		grp = ext4_get_group_info(sb, block_group);
> -		if (!EXT4_MB_GRP_BBITMAP_CORRUPT(grp))
> -			percpu_counter_sub(&sbi->s_freeclusters_counter,
> -					   grp->bb_free);
> -		set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT, &grp->bb_state);
> +		ext4_mark_group_corrupted(sbi, grp);
>  		if (!EXT4_MB_GRP_IBITMAP_CORRUPT(grp)) {
>  			int count;
>  			count = ext4_free_inodes_count(sb, gdp);
> @@ -379,20 +376,14 @@ static void ext4_validate_block_bitmap(struct super_block *sb,
>  		ext4_unlock_group(sb, block_group);
>  		ext4_error(sb, "bg %u: block %llu: invalid block bitmap",
>  			   block_group, blk);
> -		if (!EXT4_MB_GRP_BBITMAP_CORRUPT(grp))
> -			percpu_counter_sub(&sbi->s_freeclusters_counter,
> -					   grp->bb_free);
> -		set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT, &grp->bb_state);
> +		ext4_mark_group_corrupted(sbi, grp);
>  		return;
>  	}
>  	if (unlikely(!ext4_block_bitmap_csum_verify(sb, block_group,
>  			desc, bh))) {
>  		ext4_unlock_group(sb, block_group);
>  		ext4_error(sb, "bg %u: bad block bitmap checksum", block_group);
> -		if (!EXT4_MB_GRP_BBITMAP_CORRUPT(grp))
> -			percpu_counter_sub(&sbi->s_freeclusters_counter,
> -					   grp->bb_free);
> -		set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT, &grp->bb_state);
> +		ext4_mark_group_corrupted(sbi, grp);
>  		return;
>  	}
>  	set_buffer_verified(bh);
> diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
> index f63c3d5..163afe2 100644
> --- a/fs/ext4/ext4.h
> +++ b/fs/ext4/ext4.h
> @@ -2535,6 +2535,15 @@ static inline spinlock_t *ext4_group_lock_ptr(struct super_block *sb,
>  	return bgl_lock_ptr(EXT4_SB(sb)->s_blockgroup_lock, group);
>  }
>  
> +static inline
> +void ext4_mark_group_corrupted(struct ext4_sb_info *sbi,
> +				struct ext4_group_info *grp)
> +{
> +	if (!EXT4_MB_GRP_BBITMAP_CORRUPT(grp))
> +		percpu_counter_sub(&sbi->s_freeclusters_counter, grp->bb_free);
> +	set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT, &grp->bb_state);
> +}
> +
>  /*
>   * Returns true if the filesystem is busy enough that attempts to
>   * access the block group locks has run into contention.
> diff --git a/fs/ext4/ialloc.c b/fs/ext4/ialloc.c
> index ac644c3..ebe0499 100644
> --- a/fs/ext4/ialloc.c
> +++ b/fs/ext4/ialloc.c
> @@ -79,10 +79,7 @@ static unsigned ext4_init_inode_bitmap(struct super_block *sb,
>  	if (!ext4_group_desc_csum_verify(sb, block_group, gdp)) {
>  		ext4_error(sb, "Checksum bad for group %u", block_group);
>  		grp = ext4_get_group_info(sb, block_group);
> -		if (!EXT4_MB_GRP_BBITMAP_CORRUPT(grp))
> -			percpu_counter_sub(&sbi->s_freeclusters_counter,
> -					   grp->bb_free);
> -		set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT, &grp->bb_state);
> +		ext4_mark_group_corrupted(sbi, grp);
>  		if (!EXT4_MB_GRP_IBITMAP_CORRUPT(grp)) {
>  			int count;
>  			count = ext4_free_inodes_count(sb, gdp);
> diff --git a/fs/ext4/mballoc.c b/fs/ext4/mballoc.c
> index 8d1e602..24a4b6d 100644
> --- a/fs/ext4/mballoc.c
> +++ b/fs/ext4/mballoc.c
> @@ -760,10 +760,7 @@ void ext4_mb_generate_buddy(struct super_block *sb,
>  		 * corrupt and update bb_free using bitmap value
>  		 */
>  		grp->bb_free = free;
> -		if (!EXT4_MB_GRP_BBITMAP_CORRUPT(grp))
> -			percpu_counter_sub(&sbi->s_freeclusters_counter,
> -					   grp->bb_free);
> -		set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT, &grp->bb_state);
> +		ext4_mark_group_corrupted(sbi, grp);
>  	}
>  	mb_set_largest_free_order(sb, grp);
>  
> @@ -1448,12 +1445,8 @@ static void mb_free_blocks(struct inode *inode, struct ext4_buddy *e4b,
>  				      "freeing already freed block "
>  				      "(bit %u); block bitmap corrupt.",
>  				      block);
> -		if (!EXT4_MB_GRP_BBITMAP_CORRUPT(e4b->bd_info))
> -			percpu_counter_sub(&sbi->s_freeclusters_counter,
> -					   e4b->bd_info->bb_free);
>  		/* Mark the block group as corrupt. */
> -		set_bit(EXT4_GROUP_INFO_BBITMAP_CORRUPT_BIT,
> -			&e4b->bd_info->bb_state);
> +		ext4_mark_group_corrupted(sbi, e4b->bd_info);
>  		mb_regenerate_buddy(e4b);
>  		goto done;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
