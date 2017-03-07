Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 166FD6B0389
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 06:33:59 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w37so74143614wrc.2
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 03:33:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q188si101995wme.156.2017.03.07.03.33.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Mar 2017 03:33:57 -0800 (PST)
Date: Tue, 7 Mar 2017 12:33:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] xfs: remove kmem_zalloc_greedy
Message-ID: <20170307113354.GG28642@dhcp22.suse.cz>
References: <20170306184109.GC5280@birch.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170306184109.GC5280@birch.djwong.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Brian Foster <bfoster@redhat.com>, Christoph Hellwig <hch@lst.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Xiong Zhou <xzhou@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>

On Mon 06-03-17 10:41:09, Darrick J. Wong wrote:
> The sole remaining caller of kmem_zalloc_greedy is bulkstat, which uses
> it to grab 1-4 pages for staging of inobt records.  The infinite loop in
> the greedy allocation function is causing hangs[1] in generic/269, so
> just get rid of the greedy allocator in favor of kmem_zalloc_large.
> This makes bulkstat somewhat more likely to ENOMEM if there's really no
> pages to spare, but eliminates a source of hangs.
> 
> [1] https://lkml.org/lkml/2017/2/28/832

I cannot really comment on the patch but I would suggest not using
lkml.org reference in the changelog because I've seen those links being
broken many times. Could you use
http://lkml.kernel.org/r/20170301044634.rgidgdqqiiwsmfpj%40XZHOUW.usersys.redhat.com

instead please? Thanks for taking care of this!

> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>  fs/xfs/kmem.c       |   18 ------------------
>  fs/xfs/kmem.h       |    2 --
>  fs/xfs/xfs_itable.c |   14 ++++++++------
>  3 files changed, 8 insertions(+), 26 deletions(-)
> 
> diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> index 339c696..bb2beae 100644
> --- a/fs/xfs/kmem.c
> +++ b/fs/xfs/kmem.c
> @@ -24,24 +24,6 @@
>  #include "kmem.h"
>  #include "xfs_message.h"
>  
> -/*
> - * Greedy allocation.  May fail and may return vmalloced memory.
> - */
> -void *
> -kmem_zalloc_greedy(size_t *size, size_t minsize, size_t maxsize)
> -{
> -	void		*ptr;
> -	size_t		kmsize = maxsize;
> -
> -	while (!(ptr = vzalloc(kmsize))) {
> -		if ((kmsize >>= 1) <= minsize)
> -			kmsize = minsize;
> -	}
> -	if (ptr)
> -		*size = kmsize;
> -	return ptr;
> -}
> -
>  void *
>  kmem_alloc(size_t size, xfs_km_flags_t flags)
>  {
> diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
> index 689f746..f0fc84f 100644
> --- a/fs/xfs/kmem.h
> +++ b/fs/xfs/kmem.h
> @@ -69,8 +69,6 @@ static inline void  kmem_free(const void *ptr)
>  }
>  
>  
> -extern void *kmem_zalloc_greedy(size_t *, size_t, size_t);
> -
>  static inline void *
>  kmem_zalloc(size_t size, xfs_km_flags_t flags)
>  {
> diff --git a/fs/xfs/xfs_itable.c b/fs/xfs/xfs_itable.c
> index 8b2150d..283e76c 100644
> --- a/fs/xfs/xfs_itable.c
> +++ b/fs/xfs/xfs_itable.c
> @@ -362,7 +362,6 @@ xfs_bulkstat(
>  	xfs_agino_t		agino;	/* inode # in allocation group */
>  	xfs_agnumber_t		agno;	/* allocation group number */
>  	xfs_btree_cur_t		*cur;	/* btree cursor for ialloc btree */
> -	size_t			irbsize; /* size of irec buffer in bytes */
>  	xfs_inobt_rec_incore_t	*irbuf;	/* start of irec buffer */
>  	int			nirbuf;	/* size of irbuf */
>  	int			ubcount; /* size of user's buffer */
> @@ -389,11 +388,14 @@ xfs_bulkstat(
>  	*ubcountp = 0;
>  	*done = 0;
>  
> -	irbuf = kmem_zalloc_greedy(&irbsize, PAGE_SIZE, PAGE_SIZE * 4);
> -	if (!irbuf)
> -		return -ENOMEM;
> -
> -	nirbuf = irbsize / sizeof(*irbuf);
> +	nirbuf = (PAGE_SIZE * 4) / sizeof(*irbuf);
> +	irbuf = kmem_zalloc_large(PAGE_SIZE * 4, KM_SLEEP);
> +	if (!irbuf) {
> +		irbuf = kmem_zalloc_large(PAGE_SIZE, KM_SLEEP);
> +		if (!irbuf)
> +			return -ENOMEM;
> +		nirbuf /= 4;
> +	}
>  
>  	/*
>  	 * Loop over the allocation groups, starting from the last

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
