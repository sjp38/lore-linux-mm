Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0FEB66B02C4
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 12:40:26 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t7so16401645pgt.0
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:40:26 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50136.outbound.protection.outlook.com. [40.107.5.136])
        by mx.google.com with ESMTPS id m1si19631188plb.2.2017.04.24.09.40.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Apr 2017 09:40:22 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v2 0/4] Properly invalidate data in the cleancache.
Date: Mon, 24 Apr 2017 19:41:31 +0300
Message-ID: <20170424164135.22350-1-aryabinin@virtuozzo.com>
In-Reply-To: <20170414140753.16108-1-aryabinin@virtuozzo.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, Nikolay Borisov <n.borisov.lkml@gmail.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

Changes since v1:
 - Exclude DAX/nfs/cifs/9p hunks from the first patch. All these fs'es
     doesn't call cleancache_get_page() (nor directly, nor via mpage_readpage[s]()),
     so they are not affected by this bug.
 - Updated changelog.
     

We've noticed that after direct IO write, buffered read sometimes gets
stale data which is coming from the cleancache.
The reason for this is that some direct write hooks call call invalidate_inode_pages2[_range]()
conditionally iff mapping->nrpages is not zero, so we may not invalidate
data in the cleancache.

Another odd thing is that we check only for ->nrpages and don't check for ->nrexceptional,
but invalidate_inode_pages2[_range] also invalidates exceptional entries as well.
So we invalidate exceptional entries only if ->nrpages != 0? This doesn't feel right.

 - Patch 1 fixes direct IO writes by removing ->nrpages check.
 - Patch 2 fixes similar case in invalidate_bdev(). 
     Note: I only fixed conditional cleancache_invalidate_inode() here.
       Do we also need to add ->nrexceptional check in into invalidate_bdev()?
     
 - Patches 3-4: some optimizations.

Andrey Ryabinin (4):
  fs: fix data invalidation in the cleancache during direct IO
  fs/block_dev: always invalidate cleancache in invalidate_bdev()
  mm/truncate: bail out early from invalidate_inode_pages2_range() if
    mapping is empty
  mm/truncate: avoid pointless cleancache_invalidate_inode() calls.

 fs/block_dev.c | 11 +++++------
 fs/iomap.c     | 18 ++++++++----------
 mm/filemap.c   | 26 +++++++++++---------------
 mm/truncate.c  | 13 +++++++++----
 4 files changed, 33 insertions(+), 35 deletions(-)

-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
