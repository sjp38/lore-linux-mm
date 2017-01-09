Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 243126B0261
	for <linux-mm@kvack.org>; Mon,  9 Jan 2017 09:25:40 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so15283702wms.7
        for <linux-mm@kvack.org>; Mon, 09 Jan 2017 06:25:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k129si10294274wmb.68.2017.01.09.06.25.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 09 Jan 2017 06:25:38 -0800 (PST)
Date: Mon, 9 Jan 2017 15:25:36 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/8] xfs: use memalloc_nofs_{save,restore} instead of
 memalloc_noio*
Message-ID: <20170109142536.GK7495@dhcp22.suse.cz>
References: <20170106141107.23953-1-mhocko@kernel.org>
 <20170106141107.23953-5-mhocko@kernel.org>
 <18f9363f-144d-0bfd-5116-08d5f4648869@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <18f9363f-144d-0bfd-5116-08d5f4648869@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, djwong@kernel.org, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel@redhat.com, linux-nfs@vger.kernel.org, logfs@logfs.org, linux-xfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Mon 09-01-17 15:08:27, Vlastimil Babka wrote:
> On 01/06/2017 03:11 PM, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > kmem_zalloc_large and _xfs_buf_map_pages use memalloc_noio_{save,restore}
> > API to prevent from reclaim recursion into the fs because vmalloc can
> > invoke unconditional GFP_KERNEL allocations and these functions might be
> > called from the NOFS contexts. The memalloc_noio_save will enforce
> > GFP_NOIO context which is even weaker than GFP_NOFS and that seems to be
> > unnecessary. Let's use memalloc_nofs_{save,restore} instead as it should
> > provide exactly what we need here - implicit GFP_NOFS context.
> > 
> > Changes since v1
> > - s@memalloc_noio_restore@memalloc_nofs_restore@ in _xfs_buf_map_pages
> >   as per Brian Foster
> > 
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Not a xfs expert, but seems correct.
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!

> 
> Nit below:
> 
> > ---
> >  fs/xfs/kmem.c    | 10 +++++-----
> >  fs/xfs/xfs_buf.c |  8 ++++----
> >  2 files changed, 9 insertions(+), 9 deletions(-)
> > 
> > diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
> > index a76a05dae96b..d69ed5e76621 100644
> > --- a/fs/xfs/kmem.c
> > +++ b/fs/xfs/kmem.c
> > @@ -65,7 +65,7 @@ kmem_alloc(size_t size, xfs_km_flags_t flags)
> >  void *
> >  kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
> >  {
> > -	unsigned noio_flag = 0;
> > +	unsigned nofs_flag = 0;
> >  	void	*ptr;
> >  	gfp_t	lflags;
> >  
> > @@ -80,14 +80,14 @@ kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
> >  	 * context via PF_MEMALLOC_NOIO to prevent memory reclaim re-entering
> >  	 * the filesystem here and potentially deadlocking.
> 
> The comment above is now largely obsolete, or minimally should be
> changed to PF_MEMALLOC_NOFS?
---
diff --git a/fs/xfs/kmem.c b/fs/xfs/kmem.c
index d69ed5e76621..0c9f94f41b6c 100644
--- a/fs/xfs/kmem.c
+++ b/fs/xfs/kmem.c
@@ -77,7 +77,7 @@ kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
 	 * __vmalloc() will allocate data pages and auxillary structures (e.g.
 	 * pagetables) with GFP_KERNEL, yet we may be under GFP_NOFS context
 	 * here. Hence we need to tell memory reclaim that we are in such a
-	 * context via PF_MEMALLOC_NOIO to prevent memory reclaim re-entering
+	 * context via PF_MEMALLOC_NOFS to prevent memory reclaim re-entering
 	 * the filesystem here and potentially deadlocking.
 	 */
 	if (flags & KM_NOFS)

I will fold it into the original patch.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
