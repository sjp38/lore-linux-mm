Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8FAAC6B02AA
	for <linux-mm@kvack.org>; Thu, 24 May 2018 23:49:55 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id a21-v6so2910675qtp.19
        for <linux-mm@kvack.org>; Thu, 24 May 2018 20:49:55 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 35-v6si3694436qtr.180.2018.05.24.20.49.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 May 2018 20:49:54 -0700 (PDT)
From: Ming Lei <ming.lei@redhat.com>
Subject: [RESEND PATCH V5 16/33] dm: clone bio via bio_clone_seg_bioset
Date: Fri, 25 May 2018 11:46:04 +0800
Message-Id: <20180525034621.31147-17-ming.lei@redhat.com>
In-Reply-To: <20180525034621.31147-1-ming.lei@redhat.com>
References: <20180525034621.31147-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: David Sterba <dsterba@suse.cz>, Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

The incoming bio will become very big after multipage bvec is enabled,
so we can't clone bio page by page.

This patch uses the introduced bio_clone_seg_bioset(), so the incoming
bio can be cloned successfully. This way is safe because device mapping
won't modify the bio vector on the cloned multipage bio.

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/md/dm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/md/dm.c b/drivers/md/dm.c
index f1db181e082e..425e99e20f5c 100644
--- a/drivers/md/dm.c
+++ b/drivers/md/dm.c
@@ -1581,8 +1581,8 @@ static blk_qc_t __split_and_process_bio(struct mapped_device *md,
 				 * the usage of io->orig_bio in dm_remap_zone_report()
 				 * won't be affected by this reassignment.
 				 */
-				struct bio *b = bio_clone_bioset(bio, GFP_NOIO,
-								 md->queue->bio_split);
+				struct bio *b = bio_clone_seg_bioset(bio,
+						GFP_NOIO, md->queue->bio_split);
 				ci.io->orig_bio = b;
 				bio_advance(bio, (bio_sectors(bio) - ci.sector_count) << 9);
 				bio_chain(b, bio);
-- 
2.9.5
