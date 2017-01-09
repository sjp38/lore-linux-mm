Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A20C46B025E
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 09:08:33 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id l1so7071495wja.2
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 06:08:33 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r126si2701393wmb.109.2017.01.09.06.08.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 06:08:32 -0800 (PST)
Subject: Re: [PATCH 4/8] xfs: use memalloc_nofs_{save,restore} instead of
 memalloc_noio*
References: <20170106141107.23953-1-mhocko@kernel.org>
 <20170106141107.23953-5-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <18f9363f-144d-0bfd-5116-08d5f4648869@suse.cz>
Date: Mon, 9 Jan 2017 15:08:27 +0100
MIME-Version: 1.0
In-Reply-To: <20170106141107.23953-5-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 01/06/2017 03:11 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> kmem_zalloc_large and _xfs_buf_map_pages use memalloc_noio_{save,restore}
> API to prevent from reclaim recursion into the fs because vmalloc can
> invoke unconditional GFP_KERNEL allocations and these functions might be
> called from the NOFS contexts. The memalloc_noio_save will enforce
> GFP_NOIO context which is even weaker than GFP_NOFS and that seems to be
> unnecessary. Let's use memalloc_nofs_{save,restore} instead as it should
> provide exactly what we need here - implicit GFP_NOFS context.
> 
> Changes since v1
> - s@memalloc_noio_restore@memalloc_nofs_restore@ in _xfs_buf_map_pages
>   as per Brian Foster
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Not a xfs expert, but seems correct.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

Nit below:

> ---
>  fs/xfs/kmem.c    | 10 +++++-----
>  fs/xfs/xfs_buf.c |  8 ++++----
>  2 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> index a76a05dae96b..d69ed5e76621 100644
> --- a/fs/xfs/kmem.c
> +++ b/fs/xfs/kmem.c
> @@ -65,7 +65,7 @@ kmem_alloc(size_t size, xfs_km_flags_t flags)
>  void *
>  kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
>  {
> -	unsigned noio_flag = 0;
> +	unsigned nofs_flag = 0;
>  	void	*ptr;
>  	gfp_t	lflags;
>  
> @@ -80,14 +80,14 @@ kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
>  	 * context via PF_MEMALLOC_NOIO to prevent memory reclaim re-entering
>  	 * the filesystem here and potentially deadlocking.

The comment above is now largely obsolete, or minimally should be
changed to PF_MEMALLOC_NOFS?

>  	 */
> -	if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
> -		noio_flag = memalloc_noio_save();
> +	if (flags & KM_NOFS)
> +		nofs_flag = memalloc_nofs_save();
>  
>  	lflags = kmem_flags_convert(flags);
>  	ptr = __vmalloc(size, lflags | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
>  
> -	if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
> -		memalloc_noio_restore(noio_flag);
> +	if (flags & KM_NOFS)
> +		memalloc_nofs_restore(nofs_flag);
>  
>  	return ptr;
>  }
> diff --git a/fs/xfs/xfs_buf.c b/fs/xfs/xfs_buf.c
> index 7f0a01f7b592..8cb8dd4cdfd8 100644
> --- a/fs/xfs/xfs_buf.c
> +++ b/fs/xfs/xfs_buf.c
> @@ -441,17 +441,17 @@ _xfs_buf_map_pages(
>  		bp->b_addr = NULL;
>  	} else {
>  		int retried = 0;
> -		unsigned noio_flag;
> +		unsigned nofs_flag;
>  
>  		/*
>  		 * vm_map_ram() will allocate auxillary structures (e.g.
>  		 * pagetables) with GFP_KERNEL, yet we are likely to be under
>  		 * GFP_NOFS context here. Hence we need to tell memory reclaim
> -		 * that we are in such a context via PF_MEMALLOC_NOIO to prevent
> +		 * that we are in such a context via PF_MEMALLOC_NOFS to prevent
>  		 * memory reclaim re-entering the filesystem here and
>  		 * potentially deadlocking.
>  		 */
> -		noio_flag = memalloc_noio_save();
> +		nofs_flag = memalloc_nofs_save();
>  		do {
>  			bp->b_addr = vm_map_ram(bp->b_pages, bp->b_page_count,
>  						-1, PAGE_KERNEL);
> @@ -459,7 +459,7 @@ _xfs_buf_map_pages(
>  				break;
>  			vm_unmap_aliases();
>  		} while (retried++ <= 1);
> -		memalloc_noio_restore(noio_flag);
> +		memalloc_nofs_restore(nofs_flag);
>  
>  		if (!bp->b_addr)
>  			return -ENOMEM;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
