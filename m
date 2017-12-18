Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 677676B02AB
	for <linux-mm@kvack.org>; Mon, 18 Dec 2017 07:31:46 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id c33so5334748ote.1
        for <linux-mm@kvack.org>; Mon, 18 Dec 2017 04:31:46 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k51si3977840otc.367.2017.12.18.04.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Dec 2017 04:31:45 -0800 (PST)
From: Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V4 36/45] f2fs: conver to bio_for_each_page_all2
Date: Mon, 18 Dec 2017 20:22:38 +0800
Message-Id: <20171218122247.3488-37-ming.lei@redhat.com>
In-Reply-To: <20171218122247.3488-1-ming.lei@redhat.com>
References: <20171218122247.3488-1-ming.lei@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Christoph Hellwig <hch@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Kent Overstreet <kent.overstreet@gmail.com>
Cc: Huang Ying <ying.huang@intel.com>, linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>, "Darrick J . Wong" <darrick.wong@oracle.com>, Coly Li <colyli@suse.de>, Filipe Manana <fdmanana@gmail.com>, Ming Lei <ming.lei@redhat.com>

bio_for_each_page_all() can't be used any more after multipage bvec is
enabled, so we have to convert to bio_for_each_page_all2().

Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/f2fs/data.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index c404bd86169e..dc76e0b38ebb 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -54,6 +54,7 @@ static void f2fs_read_end_io(struct bio *bio)
 {
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all bia;
 
 #ifdef CONFIG_F2FS_FAULT_INJECTION
 	if (time_to_inject(F2FS_P_SB(bio_first_page_all(bio)), FAULT_IO)) {
@@ -71,7 +72,7 @@ static void f2fs_read_end_io(struct bio *bio)
 		}
 	}
 
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 
 		if (!bio->bi_status) {
@@ -91,8 +92,9 @@ static void f2fs_write_end_io(struct bio *bio)
 	struct f2fs_sb_info *sbi = bio->bi_private;
 	struct bio_vec *bvec;
 	int i;
+	struct bvec_iter_all bia;
 
-	bio_for_each_page_all(bvec, bio, i) {
+	bio_for_each_page_all2(bvec, bio, i, bia) {
 		struct page *page = bvec->bv_page;
 		enum count_type type = WB_DATA_TYPE(page);
 
@@ -253,6 +255,7 @@ static bool __has_merged_page(struct f2fs_bio_info *io,
 	struct bio_vec *bvec;
 	struct page *target;
 	int i;
+	struct bvec_iter_all bia;
 
 	if (!io->bio)
 		return false;
@@ -260,7 +263,7 @@ static bool __has_merged_page(struct f2fs_bio_info *io,
 	if (!inode && !ino)
 		return true;
 
-	bio_for_each_page_all(bvec, io->bio, i) {
+	bio_for_each_page_all2(bvec, io->bio, i, bia) {
 
 		if (bvec->bv_page->mapping)
 			target = bvec->bv_page;
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
