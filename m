Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 725396B0069
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 02:18:53 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so10381072pbb.26
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 23:18:53 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id fn10si11230727pad.320.2014.04.15.23.18.51
        for <linux-mm@kvack.org>;
        Tue, 15 Apr 2014 23:18:52 -0700 (PDT)
Date: Wed, 16 Apr 2014 16:18:20 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 19/19] XFS: set PF_FSTRANS while ilock is held in
 xfs_free_eofblocks
Message-ID: <20140416061819.GF15995@dastard>
References: <20140416033623.10604.69237.stgit@notabene.brown>
 <20140416040337.10604.7488.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140416040337.10604.7488.stgit@notabene.brown>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, xfs@oss.sgi.com

On Wed, Apr 16, 2014 at 02:03:37PM +1000, NeilBrown wrote:
> memory allocates can happen while the xfs ilock is held in
> xfs_free_eofblocks, particularly
> 
>   [<ffffffff813e6667>] kmem_zone_alloc+0x67/0xc0
>   [<ffffffff813e5945>] xfs_trans_add_item+0x25/0x50
>   [<ffffffff8143d64c>] xfs_trans_ijoin+0x2c/0x60
>   [<ffffffff8142275e>] xfs_itruncate_extents+0xbe/0x400
>   [<ffffffff813c72f4>] xfs_free_eofblocks+0x1c4/0x240
> 
> So set PF_FSTRANS to avoid this causing a deadlock.

Another "You broke KM_NOFS" moment. You win a Kit Kat. ;)

xfs_trans_add_item():

	lidp = kmem_zone_zalloc(xfs_log_item_desc_zone, KM_SLEEP | KM_NOFS);

KM_NOFS needs to work, otherwise XFS is just a huge steaming pile of
memory reclaim deadlocks regardless of whether you are using
loopback NFS or not.

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
