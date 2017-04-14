Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E75D6B03A1
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 10:08:07 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id m66so50454202pga.15
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 07:08:07 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50113.outbound.protection.outlook.com. [40.107.5.113])
        by mx.google.com with ESMTPS id 5si2153452plx.87.2017.04.14.07.08.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 14 Apr 2017 07:08:06 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 3/4] mm/truncate: bail out early from invalidate_inode_pages2_range() if mapping is empty
Date: Fri, 14 Apr 2017 17:07:52 +0300
Message-ID: <20170414140753.16108-4-aryabinin@virtuozzo.com>
In-Reply-To: <20170414140753.16108-1-aryabinin@virtuozzo.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Steve French <sfrench@samba.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org

If mapping is empty (both ->nrpages and ->nrexceptional is zero) we can avoid
pointless lookups in empty radix tree and bail out immediately after cleancache
invalidation.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/truncate.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/truncate.c b/mm/truncate.c
index 6263aff..8f12b0e 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -624,6 +624,9 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	int did_range_unmap = 0;
 
 	cleancache_invalidate_inode(mapping);
+	if (mapping->nrpages == 0 && mapping->nrexceptional == 0)
+		return 0;
+
 	pagevec_init(&pvec, 0);
 	index = start;
 	while (index <= end && pagevec_lookup_entries(&pvec, mapping, index,
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
