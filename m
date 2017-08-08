Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 058D46B02C3
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:50:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g9so31510059pfk.13
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:50:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 201si770342pga.93.2017.08.08.05.50.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 05:50:02 -0700 (PDT)
Date: Tue, 8 Aug 2017 05:49:59 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1 2/6] fs: use on-stack-bio if backing device has
 BDI_CAP_SYNC capability
Message-ID: <20170808124959.GB31390@bombadil.infradead.org>
References: <1502175024-28338-1-git-send-email-minchan@kernel.org>
 <1502175024-28338-3-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502175024-28338-3-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, jack@suse.cz, Jens Axboe <axboe@kernel.dk>, Vishal Verma <vishal.l.verma@intel.com>, linux-nvdimm@lists.01.org, kernel-team <kernel-team@lge.com>

On Tue, Aug 08, 2017 at 03:50:20PM +0900, Minchan Kim wrote:
> There is no need to use dynamic bio allocation for BDI_CAP_SYNC
> devices. They can with on-stack-bio without concern about waiting
> bio allocation from mempool under heavy memory pressure.

This seems ... more complex than necessary?  Why not simply do this:

diff --git a/fs/mpage.c b/fs/mpage.c
index baff8f820c29..6db6bf5131ed 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -157,6 +157,8 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 	unsigned page_block;
 	unsigned first_hole = blocks_per_page;
 	struct block_device *bdev = NULL;
+	struct bio sbio;
+	struct bio_vec sbvec;
 	int length;
 	int fully_mapped = 1;
 	unsigned nblocks;
@@ -281,10 +283,17 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 								page))
 				goto out;
 		}
-		bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
+		if (bdi_cap_synchronous_io(inode_to_bdi(inode))) {
+			bio = &sbio;
+			bio_init(bio, &sbvec, nr_pages);
+			sbio.bi_bdev = bdev;
+			sbio.bi_iter.bi_sector = blocks[0] << (blkbits - 9);
+		} else {
+			bio = mpage_alloc(bdev, blocks[0] << (blkbits - 9),
 				min_t(int, nr_pages, BIO_MAX_PAGES), gfp);
-		if (bio == NULL)
-			goto confused;
+			if (bio == NULL)
+				goto confused;
+		}
 	}
 
 	length = first_hole << blkbits;
@@ -301,6 +310,8 @@ do_mpage_readpage(struct bio *bio, struct page *page, unsigned nr_pages,
 	else
 		*last_block_in_bio = blocks[blocks_per_page - 1];
 out:
+	if (bio == &sbio)
+		bio = mpage_bio_submit(REQ_OP_READ, 0, bio);
 	return bio;
 
 confused:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
