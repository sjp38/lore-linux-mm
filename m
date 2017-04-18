Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 496006B0390
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 11:31:41 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id o22so254651iod.6
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 08:31:41 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 20si3641442ioj.10.2017.04.18.08.31.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 08:31:40 -0700 (PDT)
Date: Tue, 18 Apr 2017 11:24:11 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 0/4] Properly invalidate data in the cleancache.
Message-ID: <20170418152411.GC12001@char.us.oracle.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170414140753.16108-1-aryabinin@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Steve French <sfrench@samba.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org

On Fri, Apr 14, 2017 at 05:07:49PM +0300, Andrey Ryabinin wrote:
> We've noticed that after direct IO write, buffered read sometimes gets
> stale data which is coming from the cleancache.

That is not good.
> The reason for this is that some direct write hooks call call invalidate_inode_pages2[_range]()
> conditionally iff mapping->nrpages is not zero, so we may not invalidate
> data in the cleancache.
> 
> Another odd thing is that we check only for ->nrpages and don't check for ->nrexceptional,

Yikes.
> but invalidate_inode_pages2[_range] also invalidates exceptional entries as well.
> So we invalidate exceptional entries only if ->nrpages != 0? This doesn't feel right.
> 
>  - Patch 1 fixes direct IO writes by removing ->nrpages check.
>  - Patch 2 fixes similar case in invalidate_bdev(). 
>      Note: I only fixed conditional cleancache_invalidate_inode() here.
>        Do we also need to add ->nrexceptional check in into invalidate_bdev()?
>      
>  - Patches 3-4: some optimizations.

Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

Thanks!
> 
> Andrey Ryabinin (4):
>   fs: fix data invalidation in the cleancache during direct IO
>   fs/block_dev: always invalidate cleancache in invalidate_bdev()
>   mm/truncate: bail out early from invalidate_inode_pages2_range() if
>     mapping is empty
>   mm/truncate: avoid pointless cleancache_invalidate_inode() calls.
> 
>  fs/9p/vfs_file.c |  2 +-
>  fs/block_dev.c   | 11 +++++------
>  fs/cifs/inode.c  |  2 +-
>  fs/dax.c         |  2 +-
>  fs/iomap.c       | 16 +++++++---------
>  fs/nfs/direct.c  |  6 ++----
>  fs/nfs/inode.c   |  8 +++++---
>  mm/filemap.c     | 26 +++++++++++---------------
>  mm/truncate.c    | 13 +++++++++----
>  9 files changed, 42 insertions(+), 44 deletions(-)
> 
> -- 
> 2.10.2
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
