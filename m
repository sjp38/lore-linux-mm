Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5548A6B0035
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 01:38:41 -0400 (EDT)
Received: by mail-pb0-f51.google.com with SMTP id uo5so10453643pbc.38
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 22:38:40 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id w4si12040940paa.157.2014.04.15.22.38.38
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 22:38:40 -0700 (PDT)
Date: Wed, 16 Apr 2014 15:37:56 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 04/19] Make effect of PF_FSTRANS to disable __GFP_FS
 universal.
Message-ID: <20140416053756.GC15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
 <20140416040336.10604.58240.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140416040336.10604.58240.stgit@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Ming Lei <ming.lei@canonical.com>, xfs@oss.sgi.com

On Wed, Apr 16, 2014 at 02:03:36PM +1000, NeilBrown wrote:
> Currently both xfs and nfs will handle PF_FSTRANS by disabling
> __GFP_FS.
> 
> Make this effect global by repurposing memalloc_noio_flags (which
> does the same thing for PF_MEMALLOC_NOIO and __GFP_IO) to generally
> impost the task flags on a gfp_t.
> Due to this repurposing we change the name of memalloc_noio_flags
> to gfp_from_current().
> 
> As PF_FSTRANS now uniformly removes __GFP_FS we can remove special
> code for this from xfs and nfs.
> 
> As we can now expect other code to set PF_FSTRANS, its meaning is more
> general, so the WARN_ON in xfs_vm_writepage() which checks PF_FSTRANS
> is not set is no longer appropriate.  PF_FSTRANS may be set for other
> reasons than an XFS transaction.

So PF_FSTRANS no longer means "filesystem in transaction context".
Are you going to rename to match whatever it's meaning is now?
I'm not exactly clear on what it means now...


> As lockdep cares about __GFP_FS, we need to translate PF_FSTRANS to
> __GFP_FS before calling lockdep_alloc_trace() in various places.
> 
> Signed-off-by: NeilBrown <neilb@suse.de>
....
> diff --git a/fs/xfs/kmem.h b/fs/xfs/kmem.h
> index 64db0e53edea..882b86270ebe 100644
> --- a/fs/xfs/kmem.h
> +++ b/fs/xfs/kmem.h
> @@ -50,8 +50,6 @@ kmem_flags_convert(xfs_km_flags_t flags)
>  		lflags = GFP_ATOMIC | __GFP_NOWARN;
>  	} else {
>  		lflags = GFP_KERNEL | __GFP_NOWARN;
> -		if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
> -			lflags &= ~__GFP_FS;
>  	}

I think KM_NOFS needs to remain here, as it has use outside of
transaction contexts that set PF_FSTRANS....

>  	if (flags & KM_ZERO)
> diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
> index db2cfb067d0b..207a7f86d5d7 100644
> --- a/fs/xfs/xfs_aops.c
> +++ b/fs/xfs/xfs_aops.c
> @@ -952,13 +952,6 @@ xfs_vm_writepage(
>  			PF_MEMALLOC))
>  		goto redirty;
>  
> -	/*
> -	 * Given that we do not allow direct reclaim to call us, we should
> -	 * never be called while in a filesystem transaction.
> -	 */
> -	if (WARN_ON(current->flags & PF_FSTRANS))
> -		goto redirty;

We still need to ensure this rule isn't broken. If it is, the
filesystem will silently deadlock in delayed allocation rather than
gracefully handle the problem with a warning....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
