Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id CD9EF6B03A2
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 10:08:09 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id d201so67289563oib.23
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 07:08:09 -0700 (PDT)
Received: from EUR01-DB5-obe.outbound.protection.outlook.com (mail-db5eur01on0105.outbound.protection.outlook.com. [104.47.2.105])
        by mx.google.com with ESMTPS id a28si1172064ote.204.2017.04.14.07.08.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 14 Apr 2017 07:08:08 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 4/4] mm/truncate: avoid pointless cleancache_invalidate_inode() calls.
Date: Fri, 14 Apr 2017 17:07:53 +0300
Message-ID: <20170414140753.16108-5-aryabinin@virtuozzo.com>
In-Reply-To: <20170414140753.16108-1-aryabinin@virtuozzo.com>
References: <20170414140753.16108-1-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Steve French <sfrench@samba.org>, Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@kernel.dk>, Johannes Weiner <hannes@cmpxchg.org>, Alexey Kuznetsov <kuznet@virtuozzo.com>, Christoph Hellwig <hch@lst.de>, v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-cifs@vger.kernel.org, samba-technical@lists.samba.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org

cleancache_invalidate_inode() called truncate_inode_pages_range()
and invalidate_inode_pages2_range() twice - on entry and on exit.
It's stupid and waste of time. It's enough to call it once at
exit.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/truncate.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/mm/truncate.c b/mm/truncate.c
index 8f12b0e..83a059e 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -266,9 +266,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	pgoff_t		index;
 	int		i;
 
-	cleancache_invalidate_inode(mapping);
 	if (mapping->nrpages == 0 && mapping->nrexceptional == 0)
-		return;
+		goto out;
 
 	/* Offsets within partial pages */
 	partial_start = lstart & (PAGE_SIZE - 1);
@@ -363,7 +362,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	 * will be released, just zeroed, so we can bail out now.
 	 */
 	if (start >= end)
-		return;
+		goto out;
 
 	index = start;
 	for ( ; ; ) {
@@ -410,6 +409,8 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		pagevec_release(&pvec);
 		index++;
 	}
+
+out:
 	cleancache_invalidate_inode(mapping);
 }
 EXPORT_SYMBOL(truncate_inode_pages_range);
@@ -623,9 +624,8 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	int ret2 = 0;
 	int did_range_unmap = 0;
 
-	cleancache_invalidate_inode(mapping);
 	if (mapping->nrpages == 0 && mapping->nrexceptional == 0)
-		return 0;
+		goto out;
 
 	pagevec_init(&pvec, 0);
 	index = start;
@@ -689,6 +689,8 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 		cond_resched();
 		index++;
 	}
+
+out:
 	cleancache_invalidate_inode(mapping);
 	return ret;
 }
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
