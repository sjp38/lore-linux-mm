Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 928476B0005
	for <linux-mm@kvack.org>; Wed, 27 Apr 2016 15:43:50 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id k200so50932535lfg.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 12:43:50 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id j142si10926283wmg.70.2016.04.27.12.43.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Apr 2016 12:43:49 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id n129so6849041wmn.1
        for <linux-mm@kvack.org>; Wed, 27 Apr 2016 12:43:49 -0700 (PDT)
Date: Wed, 27 Apr 2016 21:43:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1.1/2] xfs: abstract PF_FSTRANS to PF_MEMALLOC_NOFS
Message-ID: <20160427194347.GA22544@dhcp22.suse.cz>
References: <1461671772-1269-2-git-send-email-mhocko@kernel.org>
 <1461758075-21815-1-git-send-email-mhocko@kernel.org>
 <04798BA8-2157-4611-B4EA-B8BCBA88AEC3@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <04798BA8-2157-4611-B4EA-B8BCBA88AEC3@dilger.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andreas Dilger <adilger@dilger.ca>
Cc: Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <clm@fb.com>, Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, cluster-devel <cluster-devel@redhat.com>, Linux NFS Mailing List <linux-nfs@vger.kernel.org>, logfs@logfs.org, XFS Developers <xfs@oss.sgi.com>, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mtd@lists.infradead.org, reiserfs-devel@vger.kernel.org, linux-ntfs-dev@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, linux-afs@lists.infradead.org, LKML <linux-kernel@vger.kernel.org>

On Wed 27-04-16 11:41:51, Andreas Dilger wrote:
> On Apr 27, 2016, at 5:54 AM, Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > --- a/fs/xfs/kmem.c
> > +++ b/fs/xfs/kmem.c
> > @@ -80,13 +80,13 @@ kmem_zalloc_large(size_t size, xfs_km_flags_t flags)
> > 	 * context via PF_MEMALLOC_NOIO to prevent memory reclaim re-entering
> > 	 * the filesystem here and potentially deadlocking.
> > 	 */
> > -	if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
> > +	if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
> > 		noio_flag = memalloc_noio_save();
> > 
> > 	lflags = kmem_flags_convert(flags);
> > 	ptr = __vmalloc(size, lflags | __GFP_HIGHMEM | __GFP_ZERO, PAGE_KERNEL);
> > 
> > -	if ((current->flags & PF_FSTRANS) || (flags & KM_NOFS))
> > +	if ((current->flags & PF_MEMALLOC_NOFS) || (flags & KM_NOFS))
> > 		memalloc_noio_restore(noio_flag);
> 
> Not really the fault of this patch, but it brings this nasty bit of code into
> the light.  Is all of this machinery still needed given that __vmalloc() can
> accept GFP flags?  If yes, wouldn't it be better to fix __vmalloc() to honor
> the GFP flags instead of working around it in the filesystem code?

This is not that easy. __vmalloc can accept gfp flags but it doesn't
honor __GFP_IO 100%. IIRC some paths like page table allocations are
hardcoded GFP_KERNEL. Besides that I would like to have GFP_NOIO used
via memalloc_noio_{save,restore} API as well for the similar reasons as
GFP_NOFS - it is just easier to explain scope than particular code paths
which might be shared.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
