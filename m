Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id D57836B0387
	for <linux-mm@kvack.org>; Wed,  9 May 2018 03:54:23 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id b31-v6so3313745plb.5
        for <linux-mm@kvack.org>; Wed, 09 May 2018 00:54:23 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id 71-v6si12192763plc.164.2018.05.09.00.54.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 09 May 2018 00:54:22 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/6] scsi/osd: remove the gfp argument to osd_start_request
Date: Wed,  9 May 2018 09:54:03 +0200
Message-Id: <20180509075408.16388-2-hch@lst.de>
In-Reply-To: <20180509075408.16388-1-hch@lst.de>
References: <20180509075408.16388-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: Bart.VanAssche@wdc.com, willy@infradead.org, linux-block@vger.kernel.org, linux-mm@kvack.org

Always GFP_KERNEL, and keeping it would cause serious complications for
the next change.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 drivers/scsi/osd/osd_initiator.c | 24 +++++++++++-------------
 fs/exofs/ore.c                   | 10 +++++-----
 fs/exofs/super.c                 |  2 +-
 include/scsi/osd_initiator.h     |  6 +-----
 4 files changed, 18 insertions(+), 24 deletions(-)

diff --git a/drivers/scsi/osd/osd_initiator.c b/drivers/scsi/osd/osd_initiator.c
index e18877177f1b..f48bae267dc2 100644
--- a/drivers/scsi/osd/osd_initiator.c
+++ b/drivers/scsi/osd/osd_initiator.c
@@ -99,7 +99,7 @@ static int _osd_get_print_system_info(struct osd_dev *od,
 	int nelem = ARRAY_SIZE(get_attrs), a = 0;
 	int ret;
 
-	or = osd_start_request(od, GFP_KERNEL);
+	or = osd_start_request(od);
 	if (!or)
 		return -ENOMEM;
 
@@ -409,16 +409,15 @@ static void _osd_request_free(struct osd_request *or)
 	kfree(or);
 }
 
-struct osd_request *osd_start_request(struct osd_dev *dev, gfp_t gfp)
+struct osd_request *osd_start_request(struct osd_dev *dev)
 {
 	struct osd_request *or;
 
-	or = _osd_request_alloc(gfp);
+	or = _osd_request_alloc(GFP_KERNEL);
 	if (!or)
 		return NULL;
 
 	or->osd_dev = dev;
-	or->alloc_flags = gfp;
 	or->timeout = dev->def_timeout;
 	or->retries = OSD_REQ_RETRIES;
 
@@ -546,7 +545,7 @@ static int _osd_realloc_seg(struct osd_request *or,
 	if (seg->alloc_size >= max_bytes)
 		return 0;
 
-	buff = krealloc(seg->buff, max_bytes, or->alloc_flags);
+	buff = krealloc(seg->buff, max_bytes, GFP_KERNEL);
 	if (!buff) {
 		OSD_ERR("Failed to Realloc %d-bytes was-%d\n", max_bytes,
 			seg->alloc_size);
@@ -728,7 +727,7 @@ static int _osd_req_list_objects(struct osd_request *or,
 		_osd_req_encode_olist(or, list);
 
 	WARN_ON(or->in.bio);
-	bio = bio_map_kern(q, list, len, or->alloc_flags);
+	bio = bio_map_kern(q, list, len, GFP_KERNEL);
 	if (IS_ERR(bio)) {
 		OSD_ERR("!!! Failed to allocate list_objects BIO\n");
 		return PTR_ERR(bio);
@@ -1190,14 +1189,14 @@ static int _req_append_segment(struct osd_request *or,
 			pad_buff = io->pad_buff;
 
 		ret = blk_rq_map_kern(io->req->q, io->req, pad_buff, padding,
-				       or->alloc_flags);
+				       GFP_KERNEL);
 		if (ret)
 			return ret;
 		io->total_bytes += padding;
 	}
 
 	ret = blk_rq_map_kern(io->req->q, io->req, seg->buff, seg->total_bytes,
-			       or->alloc_flags);
+			       GFP_KERNEL);
 	if (ret)
 		return ret;
 
@@ -1564,14 +1563,14 @@ static int _osd_req_finalize_data_integrity(struct osd_request *or,
  * osd_finalize_request and helpers
  */
 static struct request *_make_request(struct request_queue *q, bool has_write,
-			      struct _osd_io_info *oii, gfp_t flags)
+			      struct _osd_io_info *oii)
 {
 	struct request *req;
 	struct bio *bio = oii->bio;
 	int ret;
 
 	req = blk_get_request(q, has_write ? REQ_OP_SCSI_OUT : REQ_OP_SCSI_IN,
-			flags);
+			GFP_KERNEL);
 	if (IS_ERR(req))
 		return req;
 
@@ -1589,13 +1588,12 @@ static struct request *_make_request(struct request_queue *q, bool has_write,
 static int _init_blk_request(struct osd_request *or,
 	bool has_in, bool has_out)
 {
-	gfp_t flags = or->alloc_flags;
 	struct scsi_device *scsi_device = or->osd_dev->scsi_device;
 	struct request_queue *q = scsi_device->request_queue;
 	struct request *req;
 	int ret;
 
-	req = _make_request(q, has_out, has_out ? &or->out : &or->in, flags);
+	req = _make_request(q, has_out, has_out ? &or->out : &or->in);
 	if (IS_ERR(req)) {
 		ret = PTR_ERR(req);
 		goto out;
@@ -1611,7 +1609,7 @@ static int _init_blk_request(struct osd_request *or,
 		or->out.req = req;
 		if (has_in) {
 			/* allocate bidi request */
-			req = _make_request(q, false, &or->in, flags);
+			req = _make_request(q, false, &or->in);
 			if (IS_ERR(req)) {
 				OSD_DEBUG("blk_get_request for bidi failed\n");
 				ret = PTR_ERR(req);
diff --git a/fs/exofs/ore.c b/fs/exofs/ore.c
index 3c6a9c156b7a..ddbf87246898 100644
--- a/fs/exofs/ore.c
+++ b/fs/exofs/ore.c
@@ -790,7 +790,7 @@ int ore_create(struct ore_io_state *ios)
 	for (i = 0; i < ios->oc->numdevs; i++) {
 		struct osd_request *or;
 
-		or = osd_start_request(_ios_od(ios, i), GFP_KERNEL);
+		or = osd_start_request(_ios_od(ios, i));
 		if (unlikely(!or)) {
 			ORE_ERR("%s: osd_start_request failed\n", __func__);
 			ret = -ENOMEM;
@@ -815,7 +815,7 @@ int ore_remove(struct ore_io_state *ios)
 	for (i = 0; i < ios->oc->numdevs; i++) {
 		struct osd_request *or;
 
-		or = osd_start_request(_ios_od(ios, i), GFP_KERNEL);
+		or = osd_start_request(_ios_od(ios, i));
 		if (unlikely(!or)) {
 			ORE_ERR("%s: osd_start_request failed\n", __func__);
 			ret = -ENOMEM;
@@ -847,7 +847,7 @@ static int _write_mirror(struct ore_io_state *ios, int cur_comp)
 		struct ore_per_dev_state *per_dev = &ios->per_dev[cur_comp];
 		struct osd_request *or;
 
-		or = osd_start_request(_ios_od(ios, dev), GFP_KERNEL);
+		or = osd_start_request(_ios_od(ios, dev));
 		if (unlikely(!or)) {
 			ORE_ERR("%s: osd_start_request failed\n", __func__);
 			ret = -ENOMEM;
@@ -966,7 +966,7 @@ int _ore_read_mirror(struct ore_io_state *ios, unsigned cur_comp)
 		return 0; /* Just an empty slot */
 
 	first_dev = per_dev->dev + first_dev % ios->layout->mirrors_p1;
-	or = osd_start_request(_ios_od(ios, first_dev), GFP_KERNEL);
+	or = osd_start_request(_ios_od(ios, first_dev));
 	if (unlikely(!or)) {
 		ORE_ERR("%s: osd_start_request failed\n", __func__);
 		return -ENOMEM;
@@ -1060,7 +1060,7 @@ static int _truncate_mirrors(struct ore_io_state *ios, unsigned cur_comp,
 		struct ore_per_dev_state *per_dev = &ios->per_dev[cur_comp];
 		struct osd_request *or;
 
-		or = osd_start_request(_ios_od(ios, cur_comp), GFP_KERNEL);
+		or = osd_start_request(_ios_od(ios, cur_comp));
 		if (unlikely(!or)) {
 			ORE_ERR("%s: osd_start_request failed\n", __func__);
 			return -ENOMEM;
diff --git a/fs/exofs/super.c b/fs/exofs/super.c
index 179cd5c2f52a..719a3152da80 100644
--- a/fs/exofs/super.c
+++ b/fs/exofs/super.c
@@ -229,7 +229,7 @@ void exofs_make_credential(u8 cred_a[OSD_CAP_LEN], const struct osd_obj_id *obj)
 static int exofs_read_kern(struct osd_dev *od, u8 *cred, struct osd_obj_id *obj,
 		    u64 offset, void *p, unsigned length)
 {
-	struct osd_request *or = osd_start_request(od, GFP_KERNEL);
+	struct osd_request *or = osd_start_request(od);
 /*	struct osd_sense_info osi = {.key = 0};*/
 	int ret;
 
diff --git a/include/scsi/osd_initiator.h b/include/scsi/osd_initiator.h
index a29d3086eb56..86a569d008b2 100644
--- a/include/scsi/osd_initiator.h
+++ b/include/scsi/osd_initiator.h
@@ -148,7 +148,6 @@ struct osd_request {
 		u8 *pad_buff;
 	} out, in;
 
-	gfp_t alloc_flags;
 	unsigned timeout;
 	unsigned retries;
 	unsigned sense_len;
@@ -202,14 +201,11 @@ static inline bool osd_req_is_ver1(struct osd_request *or)
  *
  * @osd_dev:    OSD device that holds the scsi-device and default values
  *              that the request is associated with.
- * @gfp:        The allocation flags to use for request allocation, and all
- *              subsequent allocations. This will be stored at
- *              osd_request->alloc_flags, can be changed by user later
  *
  * Allocate osd_request and initialize all members to the
  * default/initial state.
  */
-struct osd_request *osd_start_request(struct osd_dev *od, gfp_t gfp);
+struct osd_request *osd_start_request(struct osd_dev *od);
 
 enum osd_req_options {
 	OSD_REQ_FUA = 0x08,	/* Force Unit Access */
-- 
2.17.0
