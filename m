Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id C8B006B026C
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 11:37:53 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id y124so95299717iof.4
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 08:37:53 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h190si3231684ite.62.2016.12.16.08.37.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 08:37:53 -0800 (PST)
Date: Fri, 16 Dec 2016 11:37:50 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [PATCH 2/9 v2] xfs: introduce and use KM_NOLOCKDEP to silence
 reclaim lockdep false positives
Message-ID: <20161216163749.GE8447@bfoster.bfoster>
References: <20161215140715.12732-1-mhocko@kernel.org>
 <20161215140715.12732-3-mhocko@kernel.org>
 <20161216154041.GA7645@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216154041.GA7645@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Dec 16, 2016 at 04:40:41PM +0100, Michal Hocko wrote:
> Updated patch after Mike noticed a BUG_ON when KM_NOLOCKDEP is used.
> ---
> From 1497e713e11639157aef21cae29052cb3dc7ab44 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 15 Dec 2016 13:06:43 +0100
> Subject: [PATCH] xfs: introduce and use KM_NOLOCKDEP to silence reclaim
>  lockdep false positives
> 
> Now that the page allocator offers __GFP_NOLOCKDEP let's introduce
> KM_NOLOCKDEP alias for the xfs allocation APIs. While we are at it
> also change KM_NOFS users introduced by b17cb364dbbb ("xfs: fix missing
> KM_NOFS tags to keep lockdep happy") and use the new flag for them
> instead. There is really no reason to make these allocations contexts
> weaker just because of the lockdep which even might not be enabled
> in most cases.
> 

Hi Michal,

I haven't gone back to fully grok b17cb364dbbb ("xfs: fix missing
KM_NOFS tags to keep lockdep happy"), so I'm not really familiar with
the original problem. FWIW, there was another KM_NOFS instance added by
that commit in xlog_cil_prepare_log_vecs() that is now in
xlog_cil_alloc_shadow_bufs(). Perhaps Dave can confirm whether the
original issue still applies..?

Brian

> Changes since v1
> - check for KM_NOLOCKDEP in kmem_flags_convert to not hit sanity BUG_ON
>   as per Mike Galbraith
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  fs/xfs/kmem.h                | 6 +++++-
>  fs/xfs/libxfs/xfs_da_btree.c | 4 ++--
>  fs/xfs/xfs_buf.c             | 2 +-
>  fs/xfs/xfs_dir2_readdir.c    | 2 +-
>  4 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
> index 689f746224e7..d5d634ef1f7f 100644
> --- a/fs/xfs/kmem.h
> +++ b/fs/xfs/kmem.h
> @@ -33,6 +33,7 @@ typedef unsigned __bitwise xfs_km_flags_t;
>  #define KM_NOFS		((__force xfs_km_flags_t)0x0004u)
>  #define KM_MAYFAIL	((__force xfs_km_flags_t)0x0008u)
>  #define KM_ZERO		((__force xfs_km_flags_t)0x0010u)
> +#define KM_NOLOCKDEP	((__force xfs_km_flags_t)0x0020u)
>  
>  /*
>   * We use a special process flag to avoid recursive callbacks into
> @@ -44,7 +45,7 @@ kmem_flags_convert(xfs_km_flags_t flags)
>  {
>  	gfp_t	lflags;
>  
> -	BUG_ON(flags & ~(KM_SLEEP|KM_NOSLEEP|KM_NOFS|KM_MAYFAIL|KM_ZERO));
> +	BUG_ON(flags & ~(KM_SLEEP|KM_NOSLEEP|KM_NOFS|KM_MAYFAIL|KM_ZERO|KM_NOLOCKDEP));
>  
>  	if (flags & KM_NOSLEEP) {
>  		lflags = GFP_ATOMIC | __GFP_NOWARN;
> @@ -57,6 +58,9 @@ kmem_flags_convert(xfs_km_flags_t flags)
>  	if (flags & KM_ZERO)
>  		lflags |= __GFP_ZERO;
>  
> +	if (flags & KM_NOLOCKDEP)
> +		lflags |= __GFP_NOLOCKDEP;
> +
>  	return lflags;
>  }
>  
> diff --git a/fs/xfs/libxfs/xfs_da_btree.c b/fs/xfs/libxfs/xfs_da_btree.c
> index f2dc1a950c85..b8b5f6914863 100644
> --- a/fs/xfs/libxfs/xfs_da_btree.c
> +++ b/fs/xfs/libxfs/xfs_da_btree.c
> @@ -2429,7 +2429,7 @@ xfs_buf_map_from_irec(
>  
>  	if (nirecs > 1) {
>  		map = kmem_zalloc(nirecs * sizeof(struct xfs_buf_map),
> -				  KM_SLEEP | KM_NOFS);
> +				  KM_SLEEP | KM_NOLOCKDEP);
>  		if (!map)
>  			return -ENOMEM;
>  		*mapp = map;
> @@ -2488,7 +2488,7 @@ xfs_dabuf_map(
>  		 */
>  		if (nfsb != 1)
>  			irecs = kmem_zalloc(sizeof(irec) * nfsb,
> -					    KM_SLEEP | KM_NOFS);
> +					    KM_SLEEP | KM_NOLOCKDEP);
>  
>  		nirecs = nfsb;
>  		error = xfs_bmapi_read(dp, (xfs_fileoff_t)bno, nfsb, irecs,
> diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
> index 7f0a01f7b592..f31ae592dcae 100644
> --- a/fs/xfs/xfs_buf.c
> +++ b/fs/xfs/xfs_buf.c
> @@ -1785,7 +1785,7 @@ xfs_alloc_buftarg(
>  {
>  	xfs_buftarg_t		*btp;
>  
> -	btp = kmem_zalloc(sizeof(*btp), KM_SLEEP | KM_NOFS);
> +	btp = kmem_zalloc(sizeof(*btp), KM_SLEEP | KM_NOLOCKDEP);
>  
>  	btp->bt_mount = mp;
>  	btp->bt_dev =  bdev->bd_dev;
> diff --git a/fs/xfs/xfs_dir2_readdir.c b/fs/xfs/xfs_dir2_readdir.c
> index 003a99b83bd8..033ed65d7ce6 100644
> --- a/fs/xfs/xfs_dir2_readdir.c
> +++ b/fs/xfs/xfs_dir2_readdir.c
> @@ -503,7 +503,7 @@ xfs_dir2_leaf_getdents(
>  	length = howmany(bufsize + geo->blksize, (1 << geo->fsblog));
>  	map_info = kmem_zalloc(offsetof(struct xfs_dir2_leaf_map_info, map) +
>  				(length * sizeof(struct xfs_bmbt_irec)),
> -			       KM_SLEEP | KM_NOFS);
> +			       KM_SLEEP | KM_NOLOCKDEP);
>  	map_info->map_size = length;
>  
>  	/*
> -- 
> 2.10.2
> 
> -- 
> Michal Hocko
> SUSE Labs
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
