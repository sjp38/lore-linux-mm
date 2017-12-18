Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED2D6B027C
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:25:38 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id v63so6971165oif.7
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:25:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l14si3735590oig.119.2017.12.18.04.25.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:25:37 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 11/45] dm-crypt: don't clear bvec->bv_page in crypt_free_buffer_pages()
Date: Mon, 18 Dec 2017 20:22:13 +0800
Message-Id: <20171218122247.3488-12-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>, Mike Snitzer <snitzer@redhat.com>

The bio is always freed after running crypt_free_buffer_pages(), so it
isn't necessary to clear the bv->bv_page.

Cc: Mike Snitzer <snitzer@redhat.com>
Cc:dm-devel@redhat.com
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 drivers/md/dm-crypt.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index 9fc12f556534..48332666fc38 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -1446,7 +1446,6 @@ static void crypt_free_buffer_pages(struct crypt_config *cc, struct bio *clone)
 	bio_for_each_segment_all(bv, clone, i) {
 		BUG_ON(!bv->bv_page);
 		mempool_free(bv->bv_page, cc->page_pool);
-		bv->bv_page = NULL;
 	}
 }
 
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
