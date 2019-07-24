Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB3AEC76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 548F022387
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 04:25:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rzlDdGXt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 548F022387
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 014826B026A; Wed, 24 Jul 2019 00:25:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EBA2C8E0003; Wed, 24 Jul 2019 00:25:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE8E58E0002; Wed, 24 Jul 2019 00:25:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 89F906B026A
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 00:25:37 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x19so27451797pgx.1
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:25:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ConQbG+Oem1Q8xZVMGorLyFV++CtkhuR2d2QhctIH1U=;
        b=QrAo6hmNPA5ZqHLw1qqC3CP67vUZXNvXrE8ibuXfaQC8ay1sKtTQGzs/6jKjoIPu05
         xe02zIiHC/qob2MZhDsdEEAffwErgNBVPo//3ClWHWiSUAY/swuOPD8+oe7Qv8+bW1ql
         Rn0XFKf/i1TFbz24dkqYMqZIfCZK07dm8Vw2TuZFZuAigzlzA3pkB43PX8jcQqPA8HRP
         0WMq2bxeX9xfNJid/rMVR2y2H1ioZajrQzjZ2ezojaO2Hwkwyezjme34EF7fiE1jV/OD
         leCKmbqaFYk2amOFIF77/qb/E9TAZjaqTTN+IatctaD2g8dIhXwaP9AEv/drxBquLR7J
         nh5w==
X-Gm-Message-State: APjAAAWvwwZIGI7lEDCAVjGgIcLD7raEGK6BugkxiUpV3ip/3D96NGqw
	EWsEQ3iq4WEyM4kVzIOxbwQKCIgsiL5ziKHmIMTA6FICUXrOw7L6dmZtiN3inEJNSpGn1f5SWiB
	XHrpL/bb/9J2f+gN2e/Kd7AwdMyZzDn8Kqrlqrc9rZ4OX9gOY+Ll1Dhqqml/u0TsJPQ==
X-Received: by 2002:a17:902:44a4:: with SMTP id l33mr83462231pld.174.1563942337228;
        Tue, 23 Jul 2019 21:25:37 -0700 (PDT)
X-Received: by 2002:a17:902:44a4:: with SMTP id l33mr83462171pld.174.1563942336123;
        Tue, 23 Jul 2019 21:25:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563942336; cv=none;
        d=google.com; s=arc-20160816;
        b=co7fDh28uePRHusk1DWN6qauj1QjXHqHnCuYfmd1tEDYJJXqA17EhdOikX5axbkB+l
         VGZQPyl+d+sJAG5GfRuh03iJrkHxZIvxaRGjf+n4z77KDW4amn0WwX8qi0OgHOGZXUQO
         4T8CXCq9EKHzTf9H6yoJrhO9XkXCo57W1SZpWQ2LYHpjoFmiVDj6vzPlhWbhxIDf4B6N
         LuLhXevZs8ILPbG9OawitoHUPZuDZ23QlEJv9tQ0BpYkDVWhyELEm9j2wLrn0+oJ6w2h
         ieozS50QfQ87xLwvwTt49UVUdzG1AzHdhKfBwvw4gSPesu5egV781aVYlW53V8dNG+By
         zi3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ConQbG+Oem1Q8xZVMGorLyFV++CtkhuR2d2QhctIH1U=;
        b=Y9UoOVZ4F3D4OIXv0HLUX/SFmCROAv3MNyGJ2CPsm1j4uVz9DtSuuspnJ9ANk+y1fr
         Gku43oaSUZnCX8oxHj8msa8za1mA9yHhkZto95uYc6/SJZWLfHXp1ktVZUQ8YZMMNttb
         MBvKxsjymiLMlMjg+NxD6zKeFBBbHYF2+IgdSboF1XCgmJlQVN2bmNdqsbW7C0jOg236
         cipBKdQRmIZY95/dIPbKFExfV7gPmfr9gc7E/ZK/g2BrKc2zI0zg7nmnt0tl1FvVMSxC
         dXYMTmy911J2y3liZwWSLmnT0qOGJxC4J/pBU5uThpp85MJQsBfxGT46/3tqbgghEJNo
         wFdw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rzlDdGXt;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s7sor54552075plq.42.2019.07.23.21.25.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 21:25:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=rzlDdGXt;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ConQbG+Oem1Q8xZVMGorLyFV++CtkhuR2d2QhctIH1U=;
        b=rzlDdGXtnPNF/N6VGSj5OlnkKQVNzuJZSX88h3k0QaSU7x9XxY6d4zWea62ZR3fNtS
         gNMZr45iIvfH5HQRUOMwyNN/jLIH836GcUp8Lf+aNFxxaV9vdrr625gCfyA8XZW5PN/Q
         pwujb2Pq5pgz78btiFjK3sxUmpLDWtYh/fYuVQy1tXkvqQxjANX5Mpn0h7bykgaCkfn1
         tCFvQq5xWW5YoxVJrXQ4tXX8LNF75ePai0HBYrs+WY7yUOWhn6yI6XBVflq1lgPq7qJv
         MiEt1P/meAHMnJy5EKWXyM1HfNJ7Mhgk5eJlB+ONmrDSnY2e4Df2D52oQWcyMMCO39pJ
         Eo+g==
X-Google-Smtp-Source: APXvYqyQhtv0FnqZ/I/TW3TWJg4eP/mju41WYZg75l/6hWymbmp//VEgOy1EsZaAb3L+vlqi+tLiHg==
X-Received: by 2002:a17:902:6b44:: with SMTP id g4mr83239156plt.152.1563942335854;
        Tue, 23 Jul 2019 21:25:35 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id a15sm34153364pgw.3.2019.07.23.21.25.34
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 23 Jul 2019 21:25:35 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Anna Schumaker <anna.schumaker@netapp.com>,
	"David S . Miller" <davem@davemloft.net>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Eric Van Hensbergen <ericvh@gmail.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Jason Wang <jasowang@redhat.com>,
	Jens Axboe <axboe@kernel.dk>,
	Latchesar Ionkov <lucho@ionkov.net>,
	"Michael S . Tsirkin" <mst@redhat.com>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Christoph Hellwig <hch@lst.de>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	ceph-devel@vger.kernel.org,
	kvm@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-cifs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org,
	samba-technical@lists.samba.org,
	v9fs-developer@lists.sourceforge.net,
	virtualization@lists.linux-foundation.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	John Hubbard <jhubbard@nvidia.com>,
	Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Boaz Harrosh <boaz@plexistor.com>,
	"Yan, Zheng" <zyan@redhat.com>,
	Sage Weil <sage@redhat.com>,
	Ilya Dryomov <idryomov@gmail.com>
Subject: [PATCH 10/12] fs/ceph: convert put_page() to put_user_page*()
Date: Tue, 23 Jul 2019 21:25:16 -0700
Message-Id: <20190724042518.14363-11-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190724042518.14363-1-jhubbard@nvidia.com>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Changes from Jérôme's original patch:

* Use the enhanced put_user_pages_dirty_lock().

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-block@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: ceph-devel@vger.kernel.org
Cc: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Jens Axboe <axboe@kernel.dk>
Cc: Ming Lei <ming.lei@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Boaz Harrosh <boaz@plexistor.com>
Cc: "Yan, Zheng" <zyan@redhat.com>
Cc: Sage Weil <sage@redhat.com>
Cc: Ilya Dryomov <idryomov@gmail.com>
---
 fs/ceph/file.c | 62 ++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 48 insertions(+), 14 deletions(-)

diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index 685a03cc4b77..c628a1f96978 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -158,18 +158,26 @@ static ssize_t iter_get_bvecs_alloc(struct iov_iter *iter, size_t maxsize,
 	return bytes;
 }
 
-static void put_bvecs(struct bio_vec *bvecs, int num_bvecs, bool should_dirty)
+static void put_bvecs(struct bio_vec *bv, int num_bvecs, bool should_dirty,
+		      bool from_gup)
 {
 	int i;
 
+
 	for (i = 0; i < num_bvecs; i++) {
-		if (bvecs[i].bv_page) {
+		if (!bv[i].bv_page)
+			continue;
+
+		if (from_gup) {
+			put_user_pages_dirty_lock(&bv[i].bv_page, 1,
+						  should_dirty);
+		} else {
 			if (should_dirty)
-				set_page_dirty_lock(bvecs[i].bv_page);
-			put_page(bvecs[i].bv_page);
+				set_page_dirty_lock(bv[i].bv_page);
+			put_page(bv[i].bv_page);
 		}
 	}
-	kvfree(bvecs);
+	kvfree(bv);
 }
 
 /*
@@ -730,6 +738,7 @@ struct ceph_aio_work {
 };
 
 static void ceph_aio_retry_work(struct work_struct *work);
+static void ceph_aio_from_gup_retry_work(struct work_struct *work);
 
 static void ceph_aio_complete(struct inode *inode,
 			      struct ceph_aio_request *aio_req)
@@ -774,7 +783,7 @@ static void ceph_aio_complete(struct inode *inode,
 	kfree(aio_req);
 }
 
-static void ceph_aio_complete_req(struct ceph_osd_request *req)
+static void _ceph_aio_complete_req(struct ceph_osd_request *req, bool from_gup)
 {
 	int rc = req->r_result;
 	struct inode *inode = req->r_inode;
@@ -793,7 +802,9 @@ static void ceph_aio_complete_req(struct ceph_osd_request *req)
 
 		aio_work = kmalloc(sizeof(*aio_work), GFP_NOFS);
 		if (aio_work) {
-			INIT_WORK(&aio_work->work, ceph_aio_retry_work);
+			INIT_WORK(&aio_work->work, from_gup ?
+				  ceph_aio_from_gup_retry_work :
+				  ceph_aio_retry_work);
 			aio_work->req = req;
 			queue_work(ceph_inode_to_client(inode)->inode_wq,
 				   &aio_work->work);
@@ -830,7 +841,7 @@ static void ceph_aio_complete_req(struct ceph_osd_request *req)
 	}
 
 	put_bvecs(osd_data->bvec_pos.bvecs, osd_data->num_bvecs,
-		  aio_req->should_dirty);
+		  aio_req->should_dirty, from_gup);
 	ceph_osdc_put_request(req);
 
 	if (rc < 0)
@@ -840,7 +851,17 @@ static void ceph_aio_complete_req(struct ceph_osd_request *req)
 	return;
 }
 
-static void ceph_aio_retry_work(struct work_struct *work)
+static void ceph_aio_complete_req(struct ceph_osd_request *req)
+{
+	_ceph_aio_complete_req(req, false);
+}
+
+static void ceph_aio_from_gup_complete_req(struct ceph_osd_request *req)
+{
+	_ceph_aio_complete_req(req, true);
+}
+
+static void _ceph_aio_retry_work(struct work_struct *work, bool from_gup)
 {
 	struct ceph_aio_work *aio_work =
 		container_of(work, struct ceph_aio_work, work);
@@ -891,7 +912,8 @@ static void ceph_aio_retry_work(struct work_struct *work)
 
 	ceph_osdc_put_request(orig_req);
 
-	req->r_callback = ceph_aio_complete_req;
+	req->r_callback = from_gup ? ceph_aio_from_gup_complete_req :
+			  ceph_aio_complete_req;
 	req->r_inode = inode;
 	req->r_priv = aio_req;
 
@@ -899,13 +921,23 @@ static void ceph_aio_retry_work(struct work_struct *work)
 out:
 	if (ret < 0) {
 		req->r_result = ret;
-		ceph_aio_complete_req(req);
+		_ceph_aio_complete_req(req, from_gup);
 	}
 
 	ceph_put_snap_context(snapc);
 	kfree(aio_work);
 }
 
+static void ceph_aio_retry_work(struct work_struct *work)
+{
+	_ceph_aio_retry_work(work, false);
+}
+
+static void ceph_aio_from_gup_retry_work(struct work_struct *work)
+{
+	_ceph_aio_retry_work(work, true);
+}
+
 static ssize_t
 ceph_direct_read_write(struct kiocb *iocb, struct iov_iter *iter,
 		       struct ceph_snap_context *snapc,
@@ -927,6 +959,7 @@ ceph_direct_read_write(struct kiocb *iocb, struct iov_iter *iter,
 	loff_t pos = iocb->ki_pos;
 	bool write = iov_iter_rw(iter) == WRITE;
 	bool should_dirty = !write && iter_is_iovec(iter);
+	bool from_gup = iov_iter_get_pages_use_gup(iter);
 
 	if (write && ceph_snap(file_inode(file)) != CEPH_NOSNAP)
 		return -EROFS;
@@ -1023,7 +1056,8 @@ ceph_direct_read_write(struct kiocb *iocb, struct iov_iter *iter,
 			aio_req->num_reqs++;
 			atomic_inc(&aio_req->pending_reqs);
 
-			req->r_callback = ceph_aio_complete_req;
+			req->r_callback = !from_gup ? ceph_aio_complete_req :
+					  ceph_aio_from_gup_complete_req;
 			req->r_inode = inode;
 			req->r_priv = aio_req;
 			list_add_tail(&req->r_private_item, &aio_req->osd_reqs);
@@ -1054,7 +1088,7 @@ ceph_direct_read_write(struct kiocb *iocb, struct iov_iter *iter,
 				len = ret;
 		}
 
-		put_bvecs(bvecs, num_pages, should_dirty);
+		put_bvecs(bvecs, num_pages, should_dirty, from_gup);
 		ceph_osdc_put_request(req);
 		if (ret < 0)
 			break;
@@ -1093,7 +1127,7 @@ ceph_direct_read_write(struct kiocb *iocb, struct iov_iter *iter,
 							      req, false);
 			if (ret < 0) {
 				req->r_result = ret;
-				ceph_aio_complete_req(req);
+				_ceph_aio_complete_req(req, from_gup);
 			}
 		}
 		return -EIOCBQUEUED;
-- 
2.22.0

