Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DB62C10F13
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03E4B2184B
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 21:09:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03E4B2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B67436B026E; Thu, 11 Apr 2019 17:08:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B190B6B026F; Thu, 11 Apr 2019 17:08:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CC3B6B0270; Thu, 11 Apr 2019 17:08:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 541346B026E
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 17:08:59 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id q127so6299633qkd.2
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 14:08:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oyrUSo91eDhxdOh05YKlJw+6sTseD2mU8BnjjedIJOk=;
        b=OY8MEwlW7YOt3IhjRgbVjwGe2bGnf4X6XZO2MXG4nWhJTYpyV01dY7cSIl5laUdN1O
         B+RRe4y+PhVQ3O4Ygxy1MfZPCEJbxKBK1y9QZCiuX1bQIA2VMTYKJ6Cefa2nFAE2EHqd
         L9hrSv4qyxe/szUtPP1qhsA+p0R3n+ZhDcqEj0GrzPYH8F/NgeRQmwdGL56Y45cBirdc
         ZSUww+EVpfwRJPEjIc4xI+N5ByA9/r4ZDZ+8SBzV1Y2k94gYqJqucnp/Sqgnss3mNbB1
         kkmi2LSnZ3leUQz6x1Fup7BId8zFMc3EXgt6aD8GQdZ7O8TZ3otCI7l8tqKrx0+WO18H
         TYYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVqsgZUaIravoVChZXayzcO9gGTdZjZusOSEMHrka6+/ouF2kyV
	JEFDsOCi0BHbKB2Fk4yN+YblVDYxqDgh1lL7WqWBB2jz1oNS2jq7A8edCJ+P70O4ORGCIdWUUYf
	MaCvInPWBAu60voy68bk1DLJzaB1qu9p+AMY+UqxsaGYwEYtivezo7aZTm/PXJZpUZg==
X-Received: by 2002:ac8:180b:: with SMTP id q11mr43109817qtj.113.1555016938875;
        Thu, 11 Apr 2019 14:08:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0gru9aUvvk0YRuDZhZkI3u4ee5OKEmjPpYFGAHZM6tUEfHA9C3rOh/K2LJLhEhSIEOgBv
X-Received: by 2002:ac8:180b:: with SMTP id q11mr43109520qtj.113.1555016935230;
        Thu, 11 Apr 2019 14:08:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555016935; cv=none;
        d=google.com; s=arc-20160816;
        b=PvdHlVkRXEqha0N/+ctGpJ2kW6lmREO9hT4eujfPdyVjHTus+fk/qZUS3oeIc6De5q
         QP1a29eHqdxoHzcWLx2grb2jrjeJxmNYsHyjTR80gkW9YVCFt7R8aactV0NLNLdR6KDM
         RW4H32BkipuZdjBU0DVjAluAQ9MoyK5X/4RGDhZyYFDKv+bcHkiE/P9mT+GJYh53Rm8p
         8acwTZftDvf07G8TLFMfNSjDy8hzrdulCZpJ4qIgpQRpffmQuRf251+BRwh+TQxgP85S
         0niPOt7IE9BhHWIIsgAoa20w3OPwRpsPzobue6EHoi6F20ghbswQOj+WG44Gg+3wgHxa
         yRHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=oyrUSo91eDhxdOh05YKlJw+6sTseD2mU8BnjjedIJOk=;
        b=MQP61jeHYO4aANT+uaiBhtl+OXpcnvUj5/2E+bAz1fuD2ylLBOKxc9pzG6oF8NYVwa
         Ym8hfBtTlaz8OjAHjo3TjlLfS2pM1XNeK4yHZliYUzSexvDQGhkBBVA4xET7UfKHrxpP
         ssr4fsAXF2CGi4bSNog/95gTEVXkAczGTHo6U3DNVzrK8+AZCnF9naWHjGRbY3RMwH32
         qG+1F448X0iUGg0NjPK24g2S1pCpGEip/gD7IzKZ5mCGUVHl1fq82VVencMLKkJ4OTXq
         crYE79e/2dv/DoTNBzTc3ARVmWfUnXtlXWUIILYfuaS0tNVZH1JF8lsVtZ4NGwU13z22
         5Utw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n1si2242033qtk.343.2019.04.11.14.08.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 14:08:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 19C1E8762D;
	Thu, 11 Apr 2019 21:08:54 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5E4575C219;
	Thu, 11 Apr 2019 21:08:52 +0000 (UTC)
From: jglisse@redhat.com
To: linux-kernel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	linux-fsdevel@vger.kernel.org,
	linux-block@vger.kernel.org,
	linux-mm@kvack.org,
	John Hubbard <jhubbard@nvidia.com>,
	Jan Kara <jack@suse.cz>,
	Dan Williams <dan.j.williams@intel.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Johannes Thumshirn <jthumshirn@suse.de>,
	Christoph Hellwig <hch@lst.de>,
	Jens Axboe <axboe@kernel.dk>,
	Ming Lei <ming.lei@redhat.com>,
	Dave Chinner <david@fromorbit.com>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v1 05/15] block: replace all bio_vec->bv_page by bvec_page()/bvec_set_page()
Date: Thu, 11 Apr 2019 17:08:24 -0400
Message-Id: <20190411210834.4105-6-jglisse@redhat.com>
In-Reply-To: <20190411210834.4105-1-jglisse@redhat.com>
References: <20190411210834.4105-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 11 Apr 2019 21:08:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

This replace almost all direct dereference of bv_page field of bio_vec
struct with bvec_page() or bvec_set_page() (the latter when setting the
field). Motivation is to allow to change bv_page field to include some
context information and thus we need to go through an helper.

This is done using a coccinelle patch and running it with (take ~30min):

spatch --include-headers --sp-file spfile --in-place --dir .

with spfile:
%<---------------------------------------------------------------------
@exists@
struct bio_vec BVEC;
expression E1;
identifier FN!={bvec_set_page};
@@
FN(...) {<...
-BVEC.bv_page = E1;
+bvec_set_page(&BVEC, E1);
...>}

@exists@
struct bio_vec *BVEC;
expression E1, E2;
@@
-BVEC[E1].bv_page = E2;
+bvec_set_page(&BVEC[E1], E2);

@exists@
struct bio_vec *BVEC;
expression E1;
identifier FN!={bvec_set_page};
@@
FN(...) {<...
-BVEC->bv_page = E1;
+bvec_set_page(BVEC, E1);
...>}

@exists@
struct bvec_iter_all *ITER;
expression E1;
@@
-ITER->bv.bv_page = E1;
+bvec_set_page(&ITER->bv, E1);

@exists@
struct request *req;
expression E1;
@@
-req->special_vec.bv_page = E1;
+bvec_set_page(&req->special_vec, E1);

@exists@
struct bio *BIO;
expression E1;
@@
-BIO->bi_io_vec->bv_page = E1;
+bvec_set_page(bio->bi_io_vec, E1);

@exists@
struct rbd_obj_request *req;
expression E1, E2;
@@
-req->copyup_bvecs[E1].bv_page = E2;
+bvec_set_page(&req->copyup_bvecs[E1], E2);

@exists@
struct pending_block *block;
expression E1, E2;
@@
-block->vecs[E1].bv_page = E2;
+bvec_set_page(&block->vecs[E1], E2);

@exists@
struct stripe_head *sh;
expression E1, E2;
@@
-sh->dev[E1].vec.bv_page = E2;
+bvec_set_page(&sh->dev[E1].vec, E2);

@exists@
struct io_mapped_ubuf *imu;
expression E1, E2;
@@
-imu->bvec[E1].bv_page = E2;
+bvec_set_page(&imu->bvec[E1], E2);

@exists@
struct afs_call *call;
expression E1, E2;
@@
-call->bvec[E1].bv_page = E2;
+bvec_set_page(&call->bvec[E1], E2);

@exists@
struct xdr_buf *buf;
expression E1, E2;
@@
-buf->bvec[E1].bv_page = E2;
+bvec_set_page(&buf->bvec[E1], E2);

@exists@
expression E1, E2;
@@
-bio_first_bvec_all(E1)->bv_page = E2;
+bvec_set_page(bio_first_bvec_all(E1), E2);

@exists@
struct bio_vec BVEC;
identifier FN!={bvec_set_page,bvec_page};
@@
FN(...) {<...
-BVEC.bv_page
+bvec_page(&BVEC)
...>}

@exists@
struct bio_vec *BVEC;
expression E1;
@@
-BVEC[E1].bv_page
+bvec_page(&BVEC[E1])

@exists@
struct bio_vec *BVEC;
identifier FN!={bvec_set_page,bvec_page};
@@
FN(...) {<...
-BVEC->bv_page
+bvec_page(BVEC)
...>}

@exists@
struct bvec_iter_all *ITER;
@@
-ITER->bv.bv_page
+bvec_page(&ITER->bv)

@exists@
struct request *req;
@@
-req->special_vec.bv_page
+bvec_page(&req->special_vec)

@exists@
struct rbd_obj_request *req;
expression E1;
@@
-req->copyup_bvecs[E1].bv_page
+bvec_page(&req->copyup_bvecs[E1])

@exists@
struct pending_block *block;
expression E1;
@@
-block->vecs[E1].bv_page
+bvec_page(&block->vecs[E1])

@exists@
struct stripe_head *sh;
expression E1;
@@
-sh->dev[E1].vec.bv_page
+bvec_page(&sh->dev[E1].vec)

@exists@
struct io_mapped_ubuf *imu;
expression E1;
@@
-imu->bvec[E1].bv_page
+bvec_page(&imu->bvec[E1])

@exists@
struct afs_call *call;
expression E1;
@@
-call->bvec[E1].bv_page
+bvec_page(&call->bvec[E1])

@exists@
struct xdr_buf *buf;
expression E1;
@@
-buf->bvec[E1].bv_page
+bvec_page(&buf->bvec[E1])

@exists@
struct bio_integrity_payload *bip;
@@
-bip->bip_vec->bv_page
+bvec_page(bip->bip_vec)

@exists@
struct bio *BIO;
@@
-BIO->bi_io_vec->bv_page
+bvec_page(BIO->bi_io_vec)

@exists@
struct bio *BIO;
@@
-BIO->bi_io_vec[0].bv_page
+bvec_page(&BIO->bi_io_vec)

@exists@
struct nvme_tcp_request *req;
@@
-req->iter.bvec->bv_page
+bvec_page(req->iter.bvec)

@exists@
expression E1;
@@
-bio_first_bvec_all(E1)->bv_page
+bvec_page(bio_first_bvec_all(E1))

@exists@
struct cache *ca;
@@
-ca->sb_bio.bi_inline_vecs[0].bv_page
+bvec_page(ca->sb_bio.bi_inline_vecs)

@exists@
struct nvm_rq *rqd;
expression E1;
@@
-rqd->bio->bi_io_vec[E1].bv_page
+bvec_page(&rqd->bio->bi_io_vec[E1])

@exists@
struct msghdr *msg;
@@
-msg->msg_iter.bvec->bv_page
+bvec_page(msg->msg_iter.bvec)
--------------------------------------------------------------------->%

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: linux-fsdevel@vger.kernel.org
Cc: linux-block@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>
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
---
 arch/m68k/emu/nfblock.c             |  2 +-
 arch/um/drivers/ubd_kern.c          |  2 +-
 arch/xtensa/platforms/iss/simdisk.c |  2 +-
 block/bio-integrity.c               |  8 +++---
 block/bio.c                         | 44 ++++++++++++++---------------
 block/blk-core.c                    |  2 +-
 block/blk-integrity.c               |  3 +-
 block/blk-lib.c                     |  2 +-
 block/blk-merge.c                   |  7 +++--
 block/blk.h                         |  4 +--
 block/bounce.c                      | 24 ++++++++--------
 block/t10-pi.c                      |  4 +--
 drivers/block/aoe/aoecmd.c          |  4 +--
 drivers/block/brd.c                 |  2 +-
 drivers/block/drbd/drbd_bitmap.c    |  2 +-
 drivers/block/drbd/drbd_main.c      |  4 +--
 drivers/block/drbd/drbd_receiver.c  |  4 +--
 drivers/block/drbd/drbd_worker.c    |  2 +-
 drivers/block/floppy.c              |  4 +--
 drivers/block/loop.c                | 16 +++++------
 drivers/block/null_blk_main.c       |  6 ++--
 drivers/block/ps3disk.c             |  2 +-
 drivers/block/ps3vram.c             |  2 +-
 drivers/block/rbd.c                 | 10 +++----
 drivers/block/rsxx/dma.c            |  3 +-
 drivers/block/umem.c                |  2 +-
 drivers/block/virtio_blk.c          |  4 +--
 drivers/block/zram/zram_drv.c       | 22 +++++++--------
 drivers/lightnvm/pblk-core.c        |  7 ++---
 drivers/lightnvm/pblk-read.c        |  6 ++--
 drivers/md/bcache/debug.c           |  4 +--
 drivers/md/bcache/request.c         |  4 +--
 drivers/md/bcache/super.c           |  6 ++--
 drivers/md/bcache/util.c            | 11 ++++----
 drivers/md/dm-crypt.c               | 16 +++++++----
 drivers/md/dm-integrity.c           | 18 ++++++------
 drivers/md/dm-io.c                  |  2 +-
 drivers/md/dm-log-writes.c          | 12 ++++----
 drivers/md/dm-verity-target.c       |  4 +--
 drivers/md/raid5.c                  | 10 ++++---
 drivers/nvdimm/blk.c                |  6 ++--
 drivers/nvdimm/btt.c                |  5 ++--
 drivers/nvdimm/pmem.c               |  4 +--
 drivers/nvme/host/core.c            |  4 +--
 drivers/nvme/host/tcp.c             |  2 +-
 drivers/nvme/target/io-cmd-file.c   |  2 +-
 drivers/s390/block/dasd_diag.c      |  2 +-
 drivers/s390/block/dasd_eckd.c      | 14 ++++-----
 drivers/s390/block/dasd_fba.c       |  6 ++--
 drivers/s390/block/dcssblk.c        |  2 +-
 drivers/s390/block/scm_blk.c        |  2 +-
 drivers/s390/block/xpram.c          |  2 +-
 drivers/scsi/sd.c                   | 25 ++++++++--------
 drivers/staging/erofs/data.c        |  2 +-
 drivers/staging/erofs/unzip_vle.c   |  2 +-
 drivers/target/target_core_file.c   |  6 ++--
 drivers/xen/biomerge.c              |  4 +--
 fs/9p/vfs_addr.c                    |  2 +-
 fs/afs/fsclient.c                   |  2 +-
 fs/afs/rxrpc.c                      |  4 +--
 fs/afs/yfsclient.c                  |  2 +-
 fs/block_dev.c                      |  8 +++---
 fs/btrfs/check-integrity.c          |  4 +--
 fs/btrfs/compression.c              | 12 ++++----
 fs/btrfs/disk-io.c                  |  4 +--
 fs/btrfs/extent_io.c                |  8 +++---
 fs/btrfs/file-item.c                |  8 +++---
 fs/btrfs/inode.c                    | 20 +++++++------
 fs/btrfs/raid56.c                   |  4 +--
 fs/buffer.c                         |  2 +-
 fs/ceph/file.c                      |  6 ++--
 fs/cifs/misc.c                      |  6 ++--
 fs/cifs/smb2ops.c                   |  2 +-
 fs/cifs/smbdirect.c                 |  2 +-
 fs/cifs/transport.c                 |  2 +-
 fs/crypto/bio.c                     |  2 +-
 fs/direct-io.c                      |  2 +-
 fs/ext4/page-io.c                   |  2 +-
 fs/ext4/readpage.c                  |  2 +-
 fs/f2fs/data.c                      | 10 +++----
 fs/gfs2/lops.c                      |  4 +--
 fs/gfs2/meta_io.c                   |  2 +-
 fs/io_uring.c                       |  4 +--
 fs/iomap.c                          |  4 +--
 fs/mpage.c                          |  2 +-
 fs/splice.c                         |  2 +-
 fs/xfs/xfs_aops.c                   |  6 ++--
 include/linux/bio.h                 |  6 ++--
 include/linux/bvec.h                | 10 +++----
 net/ceph/messenger.c                |  4 +--
 net/sunrpc/xdr.c                    |  2 +-
 net/sunrpc/xprtsock.c               |  4 +--
 92 files changed, 282 insertions(+), 267 deletions(-)

diff --git a/arch/m68k/emu/nfblock.c b/arch/m68k/emu/nfblock.c
index 40712e49381b..79b90d62e916 100644
--- a/arch/m68k/emu/nfblock.c
+++ b/arch/m68k/emu/nfblock.c
@@ -73,7 +73,7 @@ static blk_qc_t nfhd_make_request(struct request_queue *queue, struct bio *bio)
 		len = bvec.bv_len;
 		len >>= 9;
 		nfhd_read_write(dev->id, 0, dir, sec >> shift, len >> shift,
-				page_to_phys(bvec.bv_page) + bvec.bv_offset);
+				page_to_phys(bvec_page(&bvec)) + bvec.bv_offset);
 		sec += len;
 	}
 	bio_endio(bio);
diff --git a/arch/um/drivers/ubd_kern.c b/arch/um/drivers/ubd_kern.c
index aca09be2373e..da0f0229e2e9 100644
--- a/arch/um/drivers/ubd_kern.c
+++ b/arch/um/drivers/ubd_kern.c
@@ -1328,7 +1328,7 @@ static int ubd_queue_one_vec(struct blk_mq_hw_ctx *hctx, struct request *req,
 	io_req->error = 0;
 
 	if (bvec != NULL) {
-		io_req->buffer = page_address(bvec->bv_page) + bvec->bv_offset;
+		io_req->buffer = page_address(bvec_page(bvec)) + bvec->bv_offset;
 		io_req->length = bvec->bv_len;
 	} else {
 		io_req->buffer = NULL;
diff --git a/arch/xtensa/platforms/iss/simdisk.c b/arch/xtensa/platforms/iss/simdisk.c
index 026211e7ab09..bc792023bd92 100644
--- a/arch/xtensa/platforms/iss/simdisk.c
+++ b/arch/xtensa/platforms/iss/simdisk.c
@@ -109,7 +109,7 @@ static blk_qc_t simdisk_make_request(struct request_queue *q, struct bio *bio)
 	sector_t sector = bio->bi_iter.bi_sector;
 
 	bio_for_each_segment(bvec, bio, iter) {
-		char *buffer = kmap_atomic(bvec.bv_page) + bvec.bv_offset;
+		char *buffer = kmap_atomic(bvec_page(&bvec)) + bvec.bv_offset;
 		unsigned len = bvec.bv_len >> SECTOR_SHIFT;
 
 		simdisk_transfer(dev, sector, len, buffer,
diff --git a/block/bio-integrity.c b/block/bio-integrity.c
index 1b633a3526d4..adcbae6ac6f4 100644
--- a/block/bio-integrity.c
+++ b/block/bio-integrity.c
@@ -108,7 +108,7 @@ static void bio_integrity_free(struct bio *bio)
 	struct bio_set *bs = bio->bi_pool;
 
 	if (bip->bip_flags & BIP_BLOCK_INTEGRITY)
-		kfree(page_address(bip->bip_vec->bv_page) +
+		kfree(page_address(bvec_page(bip->bip_vec)) +
 		      bip->bip_vec->bv_offset);
 
 	if (bs && mempool_initialized(&bs->bio_integrity_pool)) {
@@ -150,7 +150,7 @@ int bio_integrity_add_page(struct bio *bio, struct page *page,
 			     &bip->bip_vec[bip->bip_vcnt - 1], offset))
 		return 0;
 
-	iv->bv_page = page;
+	bvec_set_page(iv, page);
 	iv->bv_len = len;
 	iv->bv_offset = offset;
 	bip->bip_vcnt++;
@@ -174,7 +174,7 @@ static blk_status_t bio_integrity_process(struct bio *bio,
 	struct bio_vec bv;
 	struct bio_integrity_payload *bip = bio_integrity(bio);
 	blk_status_t ret = BLK_STS_OK;
-	void *prot_buf = page_address(bip->bip_vec->bv_page) +
+	void *prot_buf = page_address(bvec_page(bip->bip_vec)) +
 		bip->bip_vec->bv_offset;
 
 	iter.disk_name = bio->bi_disk->disk_name;
@@ -183,7 +183,7 @@ static blk_status_t bio_integrity_process(struct bio *bio,
 	iter.prot_buf = prot_buf;
 
 	__bio_for_each_segment(bv, bio, bviter, *proc_iter) {
-		void *kaddr = kmap_atomic(bv.bv_page);
+		void *kaddr = kmap_atomic(bvec_page(&bv));
 
 		iter.data_buf = kaddr + bv.bv_offset;
 		iter.data_size = bv.bv_len;
diff --git a/block/bio.c b/block/bio.c
index 716510ecd7ff..c73ac2120ca0 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -541,7 +541,7 @@ void zero_fill_bio_iter(struct bio *bio, struct bvec_iter start)
 	__bio_for_each_segment(bv, bio, iter, start) {
 		char *data = bvec_kmap_irq(&bv, &flags);
 		memset(data, 0, bv.bv_len);
-		flush_dcache_page(bv.bv_page);
+		flush_dcache_page(bvec_page(&bv));
 		bvec_kunmap_irq(data, &flags);
 	}
 }
@@ -685,7 +685,7 @@ int bio_add_pc_page(struct request_queue *q, struct bio *bio, struct page
 	if (bio->bi_vcnt > 0) {
 		struct bio_vec *prev = &bio->bi_io_vec[bio->bi_vcnt - 1];
 
-		if (page == prev->bv_page &&
+		if (page == bvec_page(prev) &&
 		    offset == prev->bv_offset + prev->bv_len) {
 			prev->bv_len += len;
 			bio->bi_iter.bi_size += len;
@@ -708,7 +708,7 @@ int bio_add_pc_page(struct request_queue *q, struct bio *bio, struct page
 	 * cannot add the page
 	 */
 	bvec = &bio->bi_io_vec[bio->bi_vcnt];
-	bvec->bv_page = page;
+	bvec_set_page(bvec, page);
 	bvec->bv_len = len;
 	bvec->bv_offset = offset;
 	bio->bi_vcnt++;
@@ -737,7 +737,7 @@ int bio_add_pc_page(struct request_queue *q, struct bio *bio, struct page
 	return len;
 
  failed:
-	bvec->bv_page = NULL;
+	bvec_set_page(bvec, NULL);
 	bvec->bv_len = 0;
 	bvec->bv_offset = 0;
 	bio->bi_vcnt--;
@@ -770,7 +770,7 @@ bool __bio_try_merge_page(struct bio *bio, struct page *page,
 
 	if (bio->bi_vcnt > 0) {
 		struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
-		phys_addr_t vec_end_addr = page_to_phys(bv->bv_page) +
+		phys_addr_t vec_end_addr = page_to_phys(bvec_page(bv)) +
 			bv->bv_offset + bv->bv_len - 1;
 		phys_addr_t page_addr = page_to_phys(page);
 
@@ -805,7 +805,7 @@ void __bio_add_page(struct bio *bio, struct page *page,
 	WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED));
 	WARN_ON_ONCE(bio_full(bio));
 
-	bv->bv_page = page;
+	bvec_set_page(bv, page);
 	bv->bv_offset = off;
 	bv->bv_len = len;
 
@@ -846,7 +846,7 @@ static int __bio_iov_bvec_add_pages(struct bio *bio, struct iov_iter *iter)
 		return -EINVAL;
 
 	len = min_t(size_t, bv->bv_len - iter->iov_offset, iter->count);
-	size = bio_add_page(bio, bv->bv_page, len,
+	size = bio_add_page(bio, bvec_page(bv), len,
 				bv->bv_offset + iter->iov_offset);
 	if (size == len) {
 		if (!bio_flagged(bio, BIO_NO_PAGE_REF)) {
@@ -1022,8 +1022,8 @@ void bio_copy_data_iter(struct bio *dst, struct bvec_iter *dst_iter,
 
 		bytes = min(src_bv.bv_len, dst_bv.bv_len);
 
-		src_p = kmap_atomic(src_bv.bv_page);
-		dst_p = kmap_atomic(dst_bv.bv_page);
+		src_p = kmap_atomic(bvec_page(&src_bv));
+		dst_p = kmap_atomic(bvec_page(&dst_bv));
 
 		memcpy(dst_p + dst_bv.bv_offset,
 		       src_p + src_bv.bv_offset,
@@ -1032,7 +1032,7 @@ void bio_copy_data_iter(struct bio *dst, struct bvec_iter *dst_iter,
 		kunmap_atomic(dst_p);
 		kunmap_atomic(src_p);
 
-		flush_dcache_page(dst_bv.bv_page);
+		flush_dcache_page(bvec_page(&dst_bv));
 
 		bio_advance_iter(src, src_iter, bytes);
 		bio_advance_iter(dst, dst_iter, bytes);
@@ -1134,7 +1134,7 @@ static int bio_copy_from_iter(struct bio *bio, struct iov_iter *iter)
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		ssize_t ret;
 
-		ret = copy_page_from_iter(bvec->bv_page,
+		ret = copy_page_from_iter(bvec_page(bvec),
 					  bvec->bv_offset,
 					  bvec->bv_len,
 					  iter);
@@ -1166,7 +1166,7 @@ static int bio_copy_to_iter(struct bio *bio, struct iov_iter iter)
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		ssize_t ret;
 
-		ret = copy_page_to_iter(bvec->bv_page,
+		ret = copy_page_to_iter(bvec_page(bvec),
 					bvec->bv_offset,
 					bvec->bv_len,
 					&iter);
@@ -1188,7 +1188,7 @@ void bio_free_pages(struct bio *bio)
 	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment_all(bvec, bio, i, iter_all)
-		__free_page(bvec->bv_page);
+		__free_page(bvec_page(bvec));
 }
 EXPORT_SYMBOL(bio_free_pages);
 
@@ -1433,7 +1433,7 @@ struct bio *bio_map_user_iov(struct request_queue *q,
 
  out_unmap:
 	bio_for_each_segment_all(bvec, bio, j, iter_all) {
-		put_page(bvec->bv_page);
+		put_page(bvec_page(bvec));
 	}
 	bio_put(bio);
 	return ERR_PTR(ret);
@@ -1450,9 +1450,9 @@ static void __bio_unmap_user(struct bio *bio)
 	 */
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		if (bio_data_dir(bio) == READ)
-			set_page_dirty_lock(bvec->bv_page);
+			set_page_dirty_lock(bvec_page(bvec));
 
-		put_page(bvec->bv_page);
+		put_page(bvec_page(bvec));
 	}
 
 	bio_put(bio);
@@ -1543,7 +1543,7 @@ static void bio_copy_kern_endio_read(struct bio *bio)
 	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		memcpy(p, page_address(bvec->bv_page), bvec->bv_len);
+		memcpy(p, page_address(bvec_page(bvec)), bvec->bv_len);
 		p += bvec->bv_len;
 	}
 
@@ -1654,8 +1654,8 @@ void bio_set_pages_dirty(struct bio *bio)
 	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		if (!PageCompound(bvec->bv_page))
-			set_page_dirty_lock(bvec->bv_page);
+		if (!PageCompound(bvec_page(bvec)))
+			set_page_dirty_lock(bvec_page(bvec));
 	}
 }
 
@@ -1666,7 +1666,7 @@ static void bio_release_pages(struct bio *bio)
 	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment_all(bvec, bio, i, iter_all)
-		put_page(bvec->bv_page);
+		put_page(bvec_page(bvec));
 }
 
 /*
@@ -1716,7 +1716,7 @@ void bio_check_pages_dirty(struct bio *bio)
 	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		if (!PageDirty(bvec->bv_page) && !PageCompound(bvec->bv_page))
+		if (!PageDirty(bvec_page(bvec)) && !PageCompound(bvec_page(bvec)))
 			goto defer;
 	}
 
@@ -1789,7 +1789,7 @@ void bio_flush_dcache_pages(struct bio *bi)
 	struct bvec_iter iter;
 
 	bio_for_each_segment(bvec, bi, iter)
-		flush_dcache_page(bvec.bv_page);
+		flush_dcache_page(bvec_page(&bvec));
 }
 EXPORT_SYMBOL(bio_flush_dcache_pages);
 #endif
diff --git a/block/blk-core.c b/block/blk-core.c
index 4673ebe42255..ad6b3d4d3880 100644
--- a/block/blk-core.c
+++ b/block/blk-core.c
@@ -1535,7 +1535,7 @@ void rq_flush_dcache_pages(struct request *rq)
 	struct bio_vec bvec;
 
 	rq_for_each_segment(bvec, rq, iter)
-		flush_dcache_page(bvec.bv_page);
+		flush_dcache_page(bvec_page(&bvec));
 }
 EXPORT_SYMBOL_GPL(rq_flush_dcache_pages);
 #endif
diff --git a/block/blk-integrity.c b/block/blk-integrity.c
index 916a5406649d..7148e2a134fb 100644
--- a/block/blk-integrity.c
+++ b/block/blk-integrity.c
@@ -106,7 +106,8 @@ int blk_rq_map_integrity_sg(struct request_queue *q, struct bio *bio,
 				sg = sg_next(sg);
 			}
 
-			sg_set_page(sg, iv.bv_page, iv.bv_len, iv.bv_offset);
+			sg_set_page(sg, bvec_page(&iv), iv.bv_len,
+				    iv.bv_offset);
 			segments++;
 		}
 
diff --git a/block/blk-lib.c b/block/blk-lib.c
index 5f2c429d4378..02a0b398566d 100644
--- a/block/blk-lib.c
+++ b/block/blk-lib.c
@@ -158,7 +158,7 @@ static int __blkdev_issue_write_same(struct block_device *bdev, sector_t sector,
 		bio->bi_iter.bi_sector = sector;
 		bio_set_dev(bio, bdev);
 		bio->bi_vcnt = 1;
-		bio->bi_io_vec->bv_page = page;
+		bvec_set_page(bio->bi_io_vec, page);
 		bio->bi_io_vec->bv_offset = 0;
 		bio->bi_io_vec->bv_len = bdev_logical_block_size(bdev);
 		bio_set_op_attrs(bio, REQ_OP_WRITE_SAME, 0);
diff --git a/block/blk-merge.c b/block/blk-merge.c
index c355fb9e9e8e..35f8c76e5448 100644
--- a/block/blk-merge.c
+++ b/block/blk-merge.c
@@ -498,7 +498,7 @@ static unsigned blk_bvec_map_sg(struct request_queue *q,
 
 		offset = (total + bvec->bv_offset) % PAGE_SIZE;
 		idx = (total + bvec->bv_offset) / PAGE_SIZE;
-		pg = bvec_nth_page(bvec->bv_page, idx);
+		pg = bvec_nth_page(bvec_page(bvec), idx);
 
 		sg_set_page(*sg, pg, seg_size, offset);
 
@@ -529,7 +529,8 @@ __blk_segment_map_sg(struct request_queue *q, struct bio_vec *bvec,
 new_segment:
 		if (bvec->bv_offset + bvec->bv_len <= PAGE_SIZE) {
 			*sg = blk_next_sg(sg, sglist);
-			sg_set_page(*sg, bvec->bv_page, nbytes, bvec->bv_offset);
+			sg_set_page(*sg, bvec_page(bvec), nbytes,
+				    bvec->bv_offset);
 			(*nsegs) += 1;
 		} else
 			(*nsegs) += blk_bvec_map_sg(q, bvec, sglist, sg);
@@ -541,7 +542,7 @@ static inline int __blk_bvec_map_sg(struct request_queue *q, struct bio_vec bv,
 		struct scatterlist *sglist, struct scatterlist **sg)
 {
 	*sg = sglist;
-	sg_set_page(*sg, bv.bv_page, bv.bv_len, bv.bv_offset);
+	sg_set_page(*sg, bvec_page(&bv), bv.bv_len, bv.bv_offset);
 	return 1;
 }
 
diff --git a/block/blk.h b/block/blk.h
index 5d636ee41663..8276ce4b9b3c 100644
--- a/block/blk.h
+++ b/block/blk.h
@@ -70,8 +70,8 @@ static inline bool biovec_phys_mergeable(struct request_queue *q,
 		struct bio_vec *vec1, struct bio_vec *vec2)
 {
 	unsigned long mask = queue_segment_boundary(q);
-	phys_addr_t addr1 = page_to_phys(vec1->bv_page) + vec1->bv_offset;
-	phys_addr_t addr2 = page_to_phys(vec2->bv_page) + vec2->bv_offset;
+	phys_addr_t addr1 = page_to_phys(bvec_page(vec1)) + vec1->bv_offset;
+	phys_addr_t addr2 = page_to_phys(bvec_page(vec2)) + vec2->bv_offset;
 
 	if (addr1 + vec1->bv_len != addr2)
 		return false;
diff --git a/block/bounce.c b/block/bounce.c
index d6ba1cac969f..63529ec8ffe1 100644
--- a/block/bounce.c
+++ b/block/bounce.c
@@ -77,7 +77,7 @@ static void bounce_copy_vec(struct bio_vec *to, unsigned char *vfrom)
 {
 	unsigned char *vto;
 
-	vto = kmap_atomic(to->bv_page);
+	vto = kmap_atomic(bvec_page(to));
 	memcpy(vto + to->bv_offset, vfrom, to->bv_len);
 	kunmap_atomic(vto);
 }
@@ -143,17 +143,17 @@ static void copy_to_high_bio_irq(struct bio *to, struct bio *from)
 
 	bio_for_each_segment(tovec, to, iter) {
 		fromvec = bio_iter_iovec(from, from_iter);
-		if (tovec.bv_page != fromvec.bv_page) {
+		if (bvec_page(&tovec) != bvec_page(&fromvec)) {
 			/*
 			 * fromvec->bv_offset and fromvec->bv_len might have
 			 * been modified by the block layer, so use the original
 			 * copy, bounce_copy_vec already uses tovec->bv_len
 			 */
-			vfrom = page_address(fromvec.bv_page) +
+			vfrom = page_address(bvec_page(&fromvec)) +
 				tovec.bv_offset;
 
 			bounce_copy_vec(&tovec, vfrom);
-			flush_dcache_page(tovec.bv_page);
+			flush_dcache_page(bvec_page(&tovec));
 		}
 		bio_advance_iter(from, &from_iter, tovec.bv_len);
 	}
@@ -172,9 +172,9 @@ static void bounce_end_io(struct bio *bio, mempool_t *pool)
 	 */
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
 		orig_vec = bio_iter_iovec(bio_orig, orig_iter);
-		if (bvec->bv_page != orig_vec.bv_page) {
-			dec_zone_page_state(bvec->bv_page, NR_BOUNCE);
-			mempool_free(bvec->bv_page, pool);
+		if (bvec_page(bvec) != bvec_page(&orig_vec)) {
+			dec_zone_page_state(bvec_page(bvec), NR_BOUNCE);
+			mempool_free(bvec_page(bvec), pool);
 		}
 		bio_advance_iter(bio_orig, &orig_iter, orig_vec.bv_len);
 	}
@@ -299,7 +299,7 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	bio_for_each_segment(from, *bio_orig, iter) {
 		if (i++ < BIO_MAX_PAGES)
 			sectors += from.bv_len >> 9;
-		if (page_to_pfn(from.bv_page) > q->limits.bounce_pfn)
+		if (page_to_pfn(bvec_page(&from)) > q->limits.bounce_pfn)
 			bounce = true;
 	}
 	if (!bounce)
@@ -320,20 +320,20 @@ static void __blk_queue_bounce(struct request_queue *q, struct bio **bio_orig,
 	 * because the 'bio' is single-page bvec.
 	 */
 	for (i = 0, to = bio->bi_io_vec; i < bio->bi_vcnt; to++, i++) {
-		struct page *page = to->bv_page;
+		struct page *page = bvec_page(to);
 
 		if (page_to_pfn(page) <= q->limits.bounce_pfn)
 			continue;
 
-		to->bv_page = mempool_alloc(pool, q->bounce_gfp);
-		inc_zone_page_state(to->bv_page, NR_BOUNCE);
+		bvec_set_page(to, mempool_alloc(pool, q->bounce_gfp));
+		inc_zone_page_state(bvec_page(to), NR_BOUNCE);
 
 		if (rw == WRITE) {
 			char *vto, *vfrom;
 
 			flush_dcache_page(page);
 
-			vto = page_address(to->bv_page) + to->bv_offset;
+			vto = page_address(bvec_page(to)) + to->bv_offset;
 			vfrom = kmap_atomic(page) + to->bv_offset;
 			memcpy(vto, vfrom, to->bv_len);
 			kunmap_atomic(vfrom);
diff --git a/block/t10-pi.c b/block/t10-pi.c
index 62aed77d0bb9..b0894d2012ff 100644
--- a/block/t10-pi.c
+++ b/block/t10-pi.c
@@ -221,7 +221,7 @@ void t10_pi_prepare(struct request *rq, u8 protection_type)
 			void *p, *pmap;
 			unsigned int j;
 
-			pmap = kmap_atomic(iv.bv_page);
+			pmap = kmap_atomic(bvec_page(&iv));
 			p = pmap + iv.bv_offset;
 			for (j = 0; j < iv.bv_len; j += tuple_sz) {
 				struct t10_pi_tuple *pi = p;
@@ -276,7 +276,7 @@ void t10_pi_complete(struct request *rq, u8 protection_type,
 			void *p, *pmap;
 			unsigned int j;
 
-			pmap = kmap_atomic(iv.bv_page);
+			pmap = kmap_atomic(bvec_page(&iv));
 			p = pmap + iv.bv_offset;
 			for (j = 0; j < iv.bv_len && intervals; j += tuple_sz) {
 				struct t10_pi_tuple *pi = p;
diff --git a/drivers/block/aoe/aoecmd.c b/drivers/block/aoe/aoecmd.c
index 3cf9bc5d8d95..b73af6e22b90 100644
--- a/drivers/block/aoe/aoecmd.c
+++ b/drivers/block/aoe/aoecmd.c
@@ -300,7 +300,7 @@ skb_fillup(struct sk_buff *skb, struct bio *bio, struct bvec_iter iter)
 	struct bio_vec bv;
 
 	__bio_for_each_segment(bv, bio, iter, iter)
-		skb_fill_page_desc(skb, frag++, bv.bv_page,
+		skb_fill_page_desc(skb, frag++, bvec_page(&bv),
 				   bv.bv_offset, bv.bv_len);
 }
 
@@ -1028,7 +1028,7 @@ bvcpy(struct sk_buff *skb, struct bio *bio, struct bvec_iter iter, long cnt)
 	iter.bi_size = cnt;
 
 	__bio_for_each_segment(bv, bio, iter, iter) {
-		char *p = kmap_atomic(bv.bv_page) + bv.bv_offset;
+		char *p = kmap_atomic(bvec_page(&bv)) + bv.bv_offset;
 		skb_copy_bits(skb, soff, p, bv.bv_len);
 		kunmap_atomic(p);
 		soff += bv.bv_len;
diff --git a/drivers/block/brd.c b/drivers/block/brd.c
index c18586fccb6f..bf64e7bbe5ab 100644
--- a/drivers/block/brd.c
+++ b/drivers/block/brd.c
@@ -295,7 +295,7 @@ static blk_qc_t brd_make_request(struct request_queue *q, struct bio *bio)
 		unsigned int len = bvec.bv_len;
 		int err;
 
-		err = brd_do_bvec(brd, bvec.bv_page, len, bvec.bv_offset,
+		err = brd_do_bvec(brd, bvec_page(&bvec), len, bvec.bv_offset,
 				  bio_op(bio), sector);
 		if (err)
 			goto io_error;
diff --git a/drivers/block/drbd/drbd_bitmap.c b/drivers/block/drbd/drbd_bitmap.c
index 11a85b740327..e567bc234781 100644
--- a/drivers/block/drbd/drbd_bitmap.c
+++ b/drivers/block/drbd/drbd_bitmap.c
@@ -977,7 +977,7 @@ static void drbd_bm_endio(struct bio *bio)
 	bm_page_unlock_io(device, idx);
 
 	if (ctx->flags & BM_AIO_COPY_PAGES)
-		mempool_free(bio->bi_io_vec[0].bv_page, &drbd_md_io_page_pool);
+		mempool_free(bvec_page(bio->bi_io_vec), &drbd_md_io_page_pool);
 
 	bio_put(bio);
 
diff --git a/drivers/block/drbd/drbd_main.c b/drivers/block/drbd/drbd_main.c
index 714eb64fabfd..02d2e087226f 100644
--- a/drivers/block/drbd/drbd_main.c
+++ b/drivers/block/drbd/drbd_main.c
@@ -1605,7 +1605,7 @@ static int _drbd_send_bio(struct drbd_peer_device *peer_device, struct bio *bio)
 	bio_for_each_segment(bvec, bio, iter) {
 		int err;
 
-		err = _drbd_no_send_page(peer_device, bvec.bv_page,
+		err = _drbd_no_send_page(peer_device, bvec_page(&bvec),
 					 bvec.bv_offset, bvec.bv_len,
 					 bio_iter_last(bvec, iter)
 					 ? 0 : MSG_MORE);
@@ -1627,7 +1627,7 @@ static int _drbd_send_zc_bio(struct drbd_peer_device *peer_device, struct bio *b
 	bio_for_each_segment(bvec, bio, iter) {
 		int err;
 
-		err = _drbd_send_page(peer_device, bvec.bv_page,
+		err = _drbd_send_page(peer_device, bvec_page(&bvec),
 				      bvec.bv_offset, bvec.bv_len,
 				      bio_iter_last(bvec, iter) ? 0 : MSG_MORE);
 		if (err)
diff --git a/drivers/block/drbd/drbd_receiver.c b/drivers/block/drbd/drbd_receiver.c
index c7ad88d91a09..ee7c77445456 100644
--- a/drivers/block/drbd/drbd_receiver.c
+++ b/drivers/block/drbd/drbd_receiver.c
@@ -2044,10 +2044,10 @@ static int recv_dless_read(struct drbd_peer_device *peer_device, struct drbd_req
 	D_ASSERT(peer_device->device, sector == bio->bi_iter.bi_sector);
 
 	bio_for_each_segment(bvec, bio, iter) {
-		void *mapped = kmap(bvec.bv_page) + bvec.bv_offset;
+		void *mapped = kmap(bvec_page(&bvec)) + bvec.bv_offset;
 		expect = min_t(int, data_size, bvec.bv_len);
 		err = drbd_recv_all_warn(peer_device->connection, mapped, expect);
-		kunmap(bvec.bv_page);
+		kunmap(bvec_page(&bvec));
 		if (err)
 			return err;
 		data_size -= expect;
diff --git a/drivers/block/drbd/drbd_worker.c b/drivers/block/drbd/drbd_worker.c
index 268ef0c5d4ab..2fa4304f07af 100644
--- a/drivers/block/drbd/drbd_worker.c
+++ b/drivers/block/drbd/drbd_worker.c
@@ -339,7 +339,7 @@ void drbd_csum_bio(struct crypto_shash *tfm, struct bio *bio, void *digest)
 	bio_for_each_segment(bvec, bio, iter) {
 		u8 *src;
 
-		src = kmap_atomic(bvec.bv_page);
+		src = kmap_atomic(bvec_page(&bvec));
 		crypto_shash_update(desc, src + bvec.bv_offset, bvec.bv_len);
 		kunmap_atomic(src);
 
diff --git a/drivers/block/floppy.c b/drivers/block/floppy.c
index 95f608d1a098..6201106cb7e3 100644
--- a/drivers/block/floppy.c
+++ b/drivers/block/floppy.c
@@ -2372,7 +2372,7 @@ static int buffer_chain_size(void)
 	size = 0;
 
 	rq_for_each_segment(bv, current_req, iter) {
-		if (page_address(bv.bv_page) + bv.bv_offset != base + size)
+		if (page_address(bvec_page(&bv)) + bv.bv_offset != base + size)
 			break;
 
 		size += bv.bv_len;
@@ -2442,7 +2442,7 @@ static void copy_buffer(int ssize, int max_sector, int max_sector_2)
 		size = bv.bv_len;
 		SUPBOUND(size, remaining);
 
-		buffer = page_address(bv.bv_page) + bv.bv_offset;
+		buffer = page_address(bvec_page(&bv)) + bv.bv_offset;
 		if (dma_buffer + size >
 		    floppy_track_buffer + (max_buffer_sectors << 10) ||
 		    dma_buffer < floppy_track_buffer) {
diff --git a/drivers/block/loop.c b/drivers/block/loop.c
index bf1c61cab8eb..d9fd8b2a6b14 100644
--- a/drivers/block/loop.c
+++ b/drivers/block/loop.c
@@ -321,12 +321,12 @@ static int lo_write_transfer(struct loop_device *lo, struct request *rq,
 		return -ENOMEM;
 
 	rq_for_each_segment(bvec, rq, iter) {
-		ret = lo_do_transfer(lo, WRITE, page, 0, bvec.bv_page,
-			bvec.bv_offset, bvec.bv_len, pos >> 9);
+		ret = lo_do_transfer(lo, WRITE, page, 0, bvec_page(&bvec),
+				     bvec.bv_offset, bvec.bv_len, pos >> 9);
 		if (unlikely(ret))
 			break;
 
-		b.bv_page = page;
+		bvec_set_page(&b, page);
 		b.bv_offset = 0;
 		b.bv_len = bvec.bv_len;
 		ret = lo_write_bvec(lo->lo_backing_file, &b, &pos);
@@ -352,7 +352,7 @@ static int lo_read_simple(struct loop_device *lo, struct request *rq,
 		if (len < 0)
 			return len;
 
-		flush_dcache_page(bvec.bv_page);
+		flush_dcache_page(bvec_page(&bvec));
 
 		if (len != bvec.bv_len) {
 			struct bio *bio;
@@ -384,7 +384,7 @@ static int lo_read_transfer(struct loop_device *lo, struct request *rq,
 	rq_for_each_segment(bvec, rq, iter) {
 		loff_t offset = pos;
 
-		b.bv_page = page;
+		bvec_set_page(&b, page);
 		b.bv_offset = 0;
 		b.bv_len = bvec.bv_len;
 
@@ -395,12 +395,12 @@ static int lo_read_transfer(struct loop_device *lo, struct request *rq,
 			goto out_free_page;
 		}
 
-		ret = lo_do_transfer(lo, READ, page, 0, bvec.bv_page,
-			bvec.bv_offset, len, offset >> 9);
+		ret = lo_do_transfer(lo, READ, page, 0, bvec_page(&bvec),
+				     bvec.bv_offset, len, offset >> 9);
 		if (ret)
 			goto out_free_page;
 
-		flush_dcache_page(bvec.bv_page);
+		flush_dcache_page(bvec_page(&bvec));
 
 		if (len != bvec.bv_len) {
 			struct bio *bio;
diff --git a/drivers/block/null_blk_main.c b/drivers/block/null_blk_main.c
index 417a9f15c116..d917826108a4 100644
--- a/drivers/block/null_blk_main.c
+++ b/drivers/block/null_blk_main.c
@@ -1067,7 +1067,8 @@ static int null_handle_rq(struct nullb_cmd *cmd)
 	spin_lock_irq(&nullb->lock);
 	rq_for_each_segment(bvec, rq, iter) {
 		len = bvec.bv_len;
-		err = null_transfer(nullb, bvec.bv_page, len, bvec.bv_offset,
+		err = null_transfer(nullb, bvec_page(&bvec), len,
+				     bvec.bv_offset,
 				     op_is_write(req_op(rq)), sector,
 				     req_op(rq) & REQ_FUA);
 		if (err) {
@@ -1102,7 +1103,8 @@ static int null_handle_bio(struct nullb_cmd *cmd)
 	spin_lock_irq(&nullb->lock);
 	bio_for_each_segment(bvec, bio, iter) {
 		len = bvec.bv_len;
-		err = null_transfer(nullb, bvec.bv_page, len, bvec.bv_offset,
+		err = null_transfer(nullb, bvec_page(&bvec), len,
+				     bvec.bv_offset,
 				     op_is_write(bio_op(bio)), sector,
 				     bio->bi_opf & REQ_FUA);
 		if (err) {
diff --git a/drivers/block/ps3disk.c b/drivers/block/ps3disk.c
index 4e1d9b31f60c..da3e33ede30f 100644
--- a/drivers/block/ps3disk.c
+++ b/drivers/block/ps3disk.c
@@ -113,7 +113,7 @@ static void ps3disk_scatter_gather(struct ps3_storage_device *dev,
 		else
 			memcpy(buf, dev->bounce_buf+offset, size);
 		offset += size;
-		flush_kernel_dcache_page(bvec.bv_page);
+		flush_kernel_dcache_page(bvec_page(&bvec));
 		bvec_kunmap_irq(buf, &flags);
 		i++;
 	}
diff --git a/drivers/block/ps3vram.c b/drivers/block/ps3vram.c
index c0c50816a10b..881f90a13472 100644
--- a/drivers/block/ps3vram.c
+++ b/drivers/block/ps3vram.c
@@ -547,7 +547,7 @@ static struct bio *ps3vram_do_bio(struct ps3_system_bus_device *dev,
 
 	bio_for_each_segment(bvec, bio, iter) {
 		/* PS3 is ppc64, so we don't handle highmem */
-		char *ptr = page_address(bvec.bv_page) + bvec.bv_offset;
+		char *ptr = page_address(bvec_page(&bvec)) + bvec.bv_offset;
 		size_t len = bvec.bv_len, retlen;
 
 		dev_dbg(&dev->core, "    %s %zu bytes at offset %llu\n", op,
diff --git a/drivers/block/rbd.c b/drivers/block/rbd.c
index aa3b82be5946..4cb84c2507f3 100644
--- a/drivers/block/rbd.c
+++ b/drivers/block/rbd.c
@@ -1284,7 +1284,7 @@ static void zero_bvec(struct bio_vec *bv)
 
 	buf = bvec_kmap_irq(bv, &flags);
 	memset(buf, 0, bv->bv_len);
-	flush_dcache_page(bv->bv_page);
+	flush_dcache_page(bvec_page(bv));
 	bvec_kunmap_irq(buf, &flags);
 }
 
@@ -1587,8 +1587,8 @@ static void rbd_obj_request_destroy(struct kref *kref)
 	kfree(obj_request->img_extents);
 	if (obj_request->copyup_bvecs) {
 		for (i = 0; i < obj_request->copyup_bvec_count; i++) {
-			if (obj_request->copyup_bvecs[i].bv_page)
-				__free_page(obj_request->copyup_bvecs[i].bv_page);
+			if (bvec_page(&obj_request->copyup_bvecs[i]))
+				__free_page(bvec_page(&obj_request->copyup_bvecs[i]));
 		}
 		kfree(obj_request->copyup_bvecs);
 	}
@@ -2595,8 +2595,8 @@ static int setup_copyup_bvecs(struct rbd_obj_request *obj_req, u64 obj_overlap)
 	for (i = 0; i < obj_req->copyup_bvec_count; i++) {
 		unsigned int len = min(obj_overlap, (u64)PAGE_SIZE);
 
-		obj_req->copyup_bvecs[i].bv_page = alloc_page(GFP_NOIO);
-		if (!obj_req->copyup_bvecs[i].bv_page)
+		bvec_set_page(&obj_req->copyup_bvecs[i], alloc_page(GFP_NOIO));
+		if (!bvec_page(&obj_req->copyup_bvecs[i]))
 			return -ENOMEM;
 
 		obj_req->copyup_bvecs[i].bv_offset = 0;
diff --git a/drivers/block/rsxx/dma.c b/drivers/block/rsxx/dma.c
index af9cf0215164..699fa8c02bac 100644
--- a/drivers/block/rsxx/dma.c
+++ b/drivers/block/rsxx/dma.c
@@ -737,7 +737,8 @@ blk_status_t rsxx_dma_queue_bio(struct rsxx_cardinfo *card,
 				st = rsxx_queue_dma(card, &dma_list[tgt],
 							bio_data_dir(bio),
 							dma_off, dma_len,
-							laddr, bvec.bv_page,
+							laddr,
+							bvec_page(&bvec),
 							bv_off, cb, cb_data);
 				if (st)
 					goto bvec_err;
diff --git a/drivers/block/umem.c b/drivers/block/umem.c
index aa035cf8a51d..ba093a7bef6a 100644
--- a/drivers/block/umem.c
+++ b/drivers/block/umem.c
@@ -364,7 +364,7 @@ static int add_bio(struct cardinfo *card)
 	vec = bio_iter_iovec(bio, card->current_iter);
 
 	dma_handle = dma_map_page(&card->dev->dev,
-				  vec.bv_page,
+				  bvec_page(&vec),
 				  vec.bv_offset,
 				  vec.bv_len,
 				  bio_op(bio) == REQ_OP_READ ?
diff --git a/drivers/block/virtio_blk.c b/drivers/block/virtio_blk.c
index 4bc083b7c9b5..20671b0ca92b 100644
--- a/drivers/block/virtio_blk.c
+++ b/drivers/block/virtio_blk.c
@@ -198,7 +198,7 @@ static int virtblk_setup_discard_write_zeroes(struct request *req, bool unmap)
 		n++;
 	}
 
-	req->special_vec.bv_page = virt_to_page(range);
+	bvec_set_page(&req->special_vec, virt_to_page(range));
 	req->special_vec.bv_offset = offset_in_page(range);
 	req->special_vec.bv_len = sizeof(*range) * segments;
 	req->rq_flags |= RQF_SPECIAL_PAYLOAD;
@@ -211,7 +211,7 @@ static inline void virtblk_request_done(struct request *req)
 	struct virtblk_req *vbr = blk_mq_rq_to_pdu(req);
 
 	if (req->rq_flags & RQF_SPECIAL_PAYLOAD) {
-		kfree(page_address(req->special_vec.bv_page) +
+		kfree(page_address(bvec_page(&req->special_vec)) +
 		      req->special_vec.bv_offset);
 	}
 
diff --git a/drivers/block/zram/zram_drv.c b/drivers/block/zram/zram_drv.c
index d58a359a6622..04fb864b16f5 100644
--- a/drivers/block/zram/zram_drv.c
+++ b/drivers/block/zram/zram_drv.c
@@ -596,7 +596,7 @@ static int read_from_bdev_async(struct zram *zram, struct bio_vec *bvec,
 
 	bio->bi_iter.bi_sector = entry * (PAGE_SIZE >> 9);
 	bio_set_dev(bio, zram->bdev);
-	if (!bio_add_page(bio, bvec->bv_page, bvec->bv_len, bvec->bv_offset)) {
+	if (!bio_add_page(bio, bvec_page(bvec), bvec->bv_len, bvec->bv_offset)) {
 		bio_put(bio);
 		return -EIO;
 	}
@@ -656,7 +656,7 @@ static ssize_t writeback_store(struct device *dev,
 	for (index = 0; index < nr_pages; index++) {
 		struct bio_vec bvec;
 
-		bvec.bv_page = page;
+		bvec_set_page(&bvec, page);
 		bvec.bv_len = PAGE_SIZE;
 		bvec.bv_offset = 0;
 
@@ -712,7 +712,7 @@ static ssize_t writeback_store(struct device *dev,
 		bio.bi_iter.bi_sector = blk_idx * (PAGE_SIZE >> 9);
 		bio.bi_opf = REQ_OP_WRITE | REQ_SYNC;
 
-		bio_add_page(&bio, bvec.bv_page, bvec.bv_len,
+		bio_add_page(&bio, bvec_page(&bvec), bvec.bv_len,
 				bvec.bv_offset);
 		/*
 		 * XXX: A single page IO would be inefficient for write
@@ -1223,7 +1223,7 @@ static int __zram_bvec_read(struct zram *zram, struct page *page, u32 index,
 
 		zram_slot_unlock(zram, index);
 
-		bvec.bv_page = page;
+		bvec_set_page(&bvec, page);
 		bvec.bv_len = PAGE_SIZE;
 		bvec.bv_offset = 0;
 		return read_from_bdev(zram, &bvec,
@@ -1276,7 +1276,7 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 	int ret;
 	struct page *page;
 
-	page = bvec->bv_page;
+	page = bvec_page(bvec);
 	if (is_partial_io(bvec)) {
 		/* Use a temporary buffer to decompress the page */
 		page = alloc_page(GFP_NOIO|__GFP_HIGHMEM);
@@ -1289,7 +1289,7 @@ static int zram_bvec_read(struct zram *zram, struct bio_vec *bvec,
 		goto out;
 
 	if (is_partial_io(bvec)) {
-		void *dst = kmap_atomic(bvec->bv_page);
+		void *dst = kmap_atomic(bvec_page(bvec));
 		void *src = kmap_atomic(page);
 
 		memcpy(dst + bvec->bv_offset, src + offset, bvec->bv_len);
@@ -1312,7 +1312,7 @@ static int __zram_bvec_write(struct zram *zram, struct bio_vec *bvec,
 	unsigned int comp_len = 0;
 	void *src, *dst, *mem;
 	struct zcomp_strm *zstrm;
-	struct page *page = bvec->bv_page;
+	struct page *page = bvec_page(bvec);
 	unsigned long element = 0;
 	enum zram_pageflags flags = 0;
 
@@ -1442,13 +1442,13 @@ static int zram_bvec_write(struct zram *zram, struct bio_vec *bvec,
 		if (ret)
 			goto out;
 
-		src = kmap_atomic(bvec->bv_page);
+		src = kmap_atomic(bvec_page(bvec));
 		dst = kmap_atomic(page);
 		memcpy(dst + offset, src + bvec->bv_offset, bvec->bv_len);
 		kunmap_atomic(dst);
 		kunmap_atomic(src);
 
-		vec.bv_page = page;
+		bvec_set_page(&vec, page);
 		vec.bv_len = PAGE_SIZE;
 		vec.bv_offset = 0;
 	}
@@ -1516,7 +1516,7 @@ static int zram_bvec_rw(struct zram *zram, struct bio_vec *bvec, u32 index,
 	if (!op_is_write(op)) {
 		atomic64_inc(&zram->stats.num_reads);
 		ret = zram_bvec_read(zram, bvec, index, offset, bio);
-		flush_dcache_page(bvec->bv_page);
+		flush_dcache_page(bvec_page(bvec));
 	} else {
 		atomic64_inc(&zram->stats.num_writes);
 		ret = zram_bvec_write(zram, bvec, index, offset, bio);
@@ -1643,7 +1643,7 @@ static int zram_rw_page(struct block_device *bdev, sector_t sector,
 	index = sector >> SECTORS_PER_PAGE_SHIFT;
 	offset = (sector & (SECTORS_PER_PAGE - 1)) << SECTOR_SHIFT;
 
-	bv.bv_page = page;
+	bvec_set_page(&bv, page);
 	bv.bv_len = PAGE_SIZE;
 	bv.bv_offset = 0;
 
diff --git a/drivers/lightnvm/pblk-core.c b/drivers/lightnvm/pblk-core.c
index 6ca868868fee..6ddb1e8a7223 100644
--- a/drivers/lightnvm/pblk-core.c
+++ b/drivers/lightnvm/pblk-core.c
@@ -330,7 +330,7 @@ void pblk_bio_free_pages(struct pblk *pblk, struct bio *bio, int off,
 
 	for (i = off; i < nr_pages + off; i++) {
 		bv = bio->bi_io_vec[i];
-		mempool_free(bv.bv_page, &pblk->page_bio_pool);
+		mempool_free(bvec_page(&bv), &pblk->page_bio_pool);
 	}
 }
 
@@ -2188,8 +2188,7 @@ void *pblk_get_meta_for_writes(struct pblk *pblk, struct nvm_rq *rqd)
 		/* We need to reuse last page of request (packed metadata)
 		 * in similar way as traditional oob metadata
 		 */
-		buffer = page_to_virt(
-			rqd->bio->bi_io_vec[rqd->bio->bi_vcnt - 1].bv_page);
+		buffer = page_to_virt(bvec_page(&rqd->bio->bi_io_vec[rqd->bio->bi_vcnt - 1]));
 	}
 
 	return buffer;
@@ -2204,7 +2203,7 @@ void pblk_get_packed_meta(struct pblk *pblk, struct nvm_rq *rqd)
 	if (pblk_is_oob_meta_supported(pblk))
 		return;
 
-	page = page_to_virt(rqd->bio->bi_io_vec[rqd->bio->bi_vcnt - 1].bv_page);
+	page = page_to_virt(bvec_page(&rqd->bio->bi_io_vec[rqd->bio->bi_vcnt - 1]));
 	/* We need to fill oob meta buffer with data from packed metadata */
 	for (; i < rqd->nr_ppas; i++)
 		memcpy(pblk_get_meta(pblk, meta_list, i),
diff --git a/drivers/lightnvm/pblk-read.c b/drivers/lightnvm/pblk-read.c
index 3789185144da..20486aa4b25e 100644
--- a/drivers/lightnvm/pblk-read.c
+++ b/drivers/lightnvm/pblk-read.c
@@ -270,8 +270,8 @@ static void pblk_end_partial_read(struct nvm_rq *rqd)
 		src_bv = new_bio->bi_io_vec[i++];
 		dst_bv = bio->bi_io_vec[bio_init_idx + hole];
 
-		src_p = kmap_atomic(src_bv.bv_page);
-		dst_p = kmap_atomic(dst_bv.bv_page);
+		src_p = kmap_atomic(bvec_page(&src_bv));
+		dst_p = kmap_atomic(bvec_page(&dst_bv));
 
 		memcpy(dst_p + dst_bv.bv_offset,
 			src_p + src_bv.bv_offset,
@@ -280,7 +280,7 @@ static void pblk_end_partial_read(struct nvm_rq *rqd)
 		kunmap_atomic(src_p);
 		kunmap_atomic(dst_p);
 
-		mempool_free(src_bv.bv_page, &pblk->page_bio_pool);
+		mempool_free(bvec_page(&src_bv), &pblk->page_bio_pool);
 
 		hole = find_next_zero_bit(read_bitmap, nr_secs, hole + 1);
 	} while (hole < nr_secs);
diff --git a/drivers/md/bcache/debug.c b/drivers/md/bcache/debug.c
index 8b123be05254..5ee5aa937589 100644
--- a/drivers/md/bcache/debug.c
+++ b/drivers/md/bcache/debug.c
@@ -127,11 +127,11 @@ void bch_data_verify(struct cached_dev *dc, struct bio *bio)
 
 	citer.bi_size = UINT_MAX;
 	bio_for_each_segment(bv, bio, iter) {
-		void *p1 = kmap_atomic(bv.bv_page);
+		void *p1 = kmap_atomic(bvec_page(&bv));
 		void *p2;
 
 		cbv = bio_iter_iovec(check, citer);
-		p2 = page_address(cbv.bv_page);
+		p2 = page_address(bvec_page(&cbv));
 
 		cache_set_err_on(memcmp(p1 + bv.bv_offset,
 					p2 + bv.bv_offset,
diff --git a/drivers/md/bcache/request.c b/drivers/md/bcache/request.c
index f101bfe8657a..a9262f9e49ab 100644
--- a/drivers/md/bcache/request.c
+++ b/drivers/md/bcache/request.c
@@ -44,10 +44,10 @@ static void bio_csum(struct bio *bio, struct bkey *k)
 	uint64_t csum = 0;
 
 	bio_for_each_segment(bv, bio, iter) {
-		void *d = kmap(bv.bv_page) + bv.bv_offset;
+		void *d = kmap(bvec_page(&bv)) + bv.bv_offset;
 
 		csum = bch_crc64_update(csum, d, bv.bv_len);
-		kunmap(bv.bv_page);
+		kunmap(bvec_page(&bv));
 	}
 
 	k->ptr[KEY_PTRS(k)] = csum & (~0ULL >> 1);
diff --git a/drivers/md/bcache/super.c b/drivers/md/bcache/super.c
index a697a3a923cd..7631065e193f 100644
--- a/drivers/md/bcache/super.c
+++ b/drivers/md/bcache/super.c
@@ -1293,7 +1293,7 @@ static void register_bdev(struct cache_sb *sb, struct page *sb_page,
 	dc->bdev->bd_holder = dc;
 
 	bio_init(&dc->sb_bio, dc->sb_bio.bi_inline_vecs, 1);
-	bio_first_bvec_all(&dc->sb_bio)->bv_page = sb_page;
+	bvec_set_page(bio_first_bvec_all(&dc->sb_bio), sb_page);
 	get_page(sb_page);
 
 
@@ -2036,7 +2036,7 @@ void bch_cache_release(struct kobject *kobj)
 	for (i = 0; i < RESERVE_NR; i++)
 		free_fifo(&ca->free[i]);
 
-	if (ca->sb_bio.bi_inline_vecs[0].bv_page)
+	if (bvec_page(ca->sb_bio.bi_inline_vecs))
 		put_page(bio_first_page_all(&ca->sb_bio));
 
 	if (!IS_ERR_OR_NULL(ca->bdev))
@@ -2171,7 +2171,7 @@ static int register_cache(struct cache_sb *sb, struct page *sb_page,
 	ca->bdev->bd_holder = ca;
 
 	bio_init(&ca->sb_bio, ca->sb_bio.bi_inline_vecs, 1);
-	bio_first_bvec_all(&ca->sb_bio)->bv_page = sb_page;
+	bvec_set_page(bio_first_bvec_all(&ca->sb_bio), sb_page);
 	get_page(sb_page);
 
 	if (blk_queue_discard(bdev_get_queue(bdev)))
diff --git a/drivers/md/bcache/util.c b/drivers/md/bcache/util.c
index 62fb917f7a4f..c28bf9162184 100644
--- a/drivers/md/bcache/util.c
+++ b/drivers/md/bcache/util.c
@@ -244,9 +244,8 @@ void bch_bio_map(struct bio *bio, void *base)
 start:		bv->bv_len	= min_t(size_t, PAGE_SIZE - bv->bv_offset,
 					size);
 		if (base) {
-			bv->bv_page = is_vmalloc_addr(base)
-				? vmalloc_to_page(base)
-				: virt_to_page(base);
+			bvec_set_page(bv,
+				      is_vmalloc_addr(base) ? vmalloc_to_page(base) : virt_to_page(base));
 
 			base += bv->bv_len;
 		}
@@ -275,10 +274,10 @@ int bch_bio_alloc_pages(struct bio *bio, gfp_t gfp_mask)
 	 * bvec table directly.
 	 */
 	for (i = 0, bv = bio->bi_io_vec; i < bio->bi_vcnt; bv++, i++) {
-		bv->bv_page = alloc_page(gfp_mask);
-		if (!bv->bv_page) {
+		bvec_set_page(bv, alloc_page(gfp_mask));
+		if (!bvec_page(bv)) {
 			while (--bv >= bio->bi_io_vec)
-				__free_page(bv->bv_page);
+				__free_page(bvec_page(bv));
 			return -ENOMEM;
 		}
 	}
diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
index dd6565798778..ef7896c50814 100644
--- a/drivers/md/dm-crypt.c
+++ b/drivers/md/dm-crypt.c
@@ -1107,13 +1107,15 @@ static int crypt_convert_block_aead(struct crypt_config *cc,
 	sg_init_table(dmreq->sg_in, 4);
 	sg_set_buf(&dmreq->sg_in[0], sector, sizeof(uint64_t));
 	sg_set_buf(&dmreq->sg_in[1], org_iv, cc->iv_size);
-	sg_set_page(&dmreq->sg_in[2], bv_in.bv_page, cc->sector_size, bv_in.bv_offset);
+	sg_set_page(&dmreq->sg_in[2], bvec_page(&bv_in), cc->sector_size,
+		    bv_in.bv_offset);
 	sg_set_buf(&dmreq->sg_in[3], tag, cc->integrity_tag_size);
 
 	sg_init_table(dmreq->sg_out, 4);
 	sg_set_buf(&dmreq->sg_out[0], sector, sizeof(uint64_t));
 	sg_set_buf(&dmreq->sg_out[1], org_iv, cc->iv_size);
-	sg_set_page(&dmreq->sg_out[2], bv_out.bv_page, cc->sector_size, bv_out.bv_offset);
+	sg_set_page(&dmreq->sg_out[2], bvec_page(&bv_out), cc->sector_size,
+		    bv_out.bv_offset);
 	sg_set_buf(&dmreq->sg_out[3], tag, cc->integrity_tag_size);
 
 	if (cc->iv_gen_ops) {
@@ -1196,10 +1198,12 @@ static int crypt_convert_block_skcipher(struct crypt_config *cc,
 	sg_out = &dmreq->sg_out[0];
 
 	sg_init_table(sg_in, 1);
-	sg_set_page(sg_in, bv_in.bv_page, cc->sector_size, bv_in.bv_offset);
+	sg_set_page(sg_in, bvec_page(&bv_in), cc->sector_size,
+		    bv_in.bv_offset);
 
 	sg_init_table(sg_out, 1);
-	sg_set_page(sg_out, bv_out.bv_page, cc->sector_size, bv_out.bv_offset);
+	sg_set_page(sg_out, bvec_page(&bv_out), cc->sector_size,
+		    bv_out.bv_offset);
 
 	if (cc->iv_gen_ops) {
 		/* For READs use IV stored in integrity metadata */
@@ -1450,8 +1454,8 @@ static void crypt_free_buffer_pages(struct crypt_config *cc, struct bio *clone)
 	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment_all(bv, clone, i, iter_all) {
-		BUG_ON(!bv->bv_page);
-		mempool_free(bv->bv_page, &cc->page_pool);
+		BUG_ON(!bvec_page(bv));
+		mempool_free(bvec_page(bv), &cc->page_pool);
 	}
 }
 
diff --git a/drivers/md/dm-integrity.c b/drivers/md/dm-integrity.c
index d57d997a52c8..3c6873303190 100644
--- a/drivers/md/dm-integrity.c
+++ b/drivers/md/dm-integrity.c
@@ -1352,7 +1352,7 @@ static void integrity_metadata(struct work_struct *w)
 			char *mem, *checksums_ptr;
 
 again:
-			mem = (char *)kmap_atomic(bv.bv_page) + bv.bv_offset;
+			mem = (char *)kmap_atomic(bvec_page(&bv)) + bv.bv_offset;
 			pos = 0;
 			checksums_ptr = checksums;
 			do {
@@ -1404,8 +1404,8 @@ static void integrity_metadata(struct work_struct *w)
 				unsigned char *tag;
 				unsigned this_len;
 
-				BUG_ON(PageHighMem(biv.bv_page));
-				tag = lowmem_page_address(biv.bv_page) + biv.bv_offset;
+				BUG_ON(PageHighMem(bvec_page(&biv)));
+				tag = lowmem_page_address(bvec_page(&biv)) + biv.bv_offset;
 				this_len = min(biv.bv_len, data_to_process);
 				r = dm_integrity_rw_tag(ic, tag, &dio->metadata_block, &dio->metadata_offset,
 							this_len, !dio->write ? TAG_READ : TAG_WRITE);
@@ -1525,9 +1525,9 @@ static bool __journal_read_write(struct dm_integrity_io *dio, struct bio *bio,
 		n_sectors -= bv.bv_len >> SECTOR_SHIFT;
 		bio_advance_iter(bio, &bio->bi_iter, bv.bv_len);
 retry_kmap:
-		mem = kmap_atomic(bv.bv_page);
+		mem = kmap_atomic(bvec_page(&bv));
 		if (likely(dio->write))
-			flush_dcache_page(bv.bv_page);
+			flush_dcache_page(bvec_page(&bv));
 
 		do {
 			struct journal_entry *je = access_journal_entry(ic, journal_section, journal_entry);
@@ -1538,7 +1538,7 @@ static bool __journal_read_write(struct dm_integrity_io *dio, struct bio *bio,
 				unsigned s;
 
 				if (unlikely(journal_entry_is_inprogress(je))) {
-					flush_dcache_page(bv.bv_page);
+					flush_dcache_page(bvec_page(&bv));
 					kunmap_atomic(mem);
 
 					__io_wait_event(ic->copy_to_journal_wait, !journal_entry_is_inprogress(je));
@@ -1577,8 +1577,8 @@ static bool __journal_read_write(struct dm_integrity_io *dio, struct bio *bio,
 					struct bio_vec biv = bvec_iter_bvec(bip->bip_vec, bip->bip_iter);
 					unsigned tag_now = min(biv.bv_len, tag_todo);
 					char *tag_addr;
-					BUG_ON(PageHighMem(biv.bv_page));
-					tag_addr = lowmem_page_address(biv.bv_page) + biv.bv_offset;
+					BUG_ON(PageHighMem(bvec_page(&biv)));
+					tag_addr = lowmem_page_address(bvec_page(&biv)) + biv.bv_offset;
 					if (likely(dio->write))
 						memcpy(tag_ptr, tag_addr, tag_now);
 					else
@@ -1629,7 +1629,7 @@ static bool __journal_read_write(struct dm_integrity_io *dio, struct bio *bio,
 		} while (bv.bv_len -= ic->sectors_per_block << SECTOR_SHIFT);
 
 		if (unlikely(!dio->write))
-			flush_dcache_page(bv.bv_page);
+			flush_dcache_page(bvec_page(&bv));
 		kunmap_atomic(mem);
 	} while (n_sectors);
 
diff --git a/drivers/md/dm-io.c b/drivers/md/dm-io.c
index 81ffc59d05c9..81a346f9de17 100644
--- a/drivers/md/dm-io.c
+++ b/drivers/md/dm-io.c
@@ -211,7 +211,7 @@ static void bio_get_page(struct dpages *dp, struct page **p,
 	struct bio_vec bvec = bvec_iter_bvec((struct bio_vec *)dp->context_ptr,
 					     dp->context_bi);
 
-	*p = bvec.bv_page;
+	*p = bvec_page(&bvec);
 	*len = bvec.bv_len;
 	*offset = bvec.bv_offset;
 
diff --git a/drivers/md/dm-log-writes.c b/drivers/md/dm-log-writes.c
index 9ea2b0291f20..e403fcb5c30a 100644
--- a/drivers/md/dm-log-writes.c
+++ b/drivers/md/dm-log-writes.c
@@ -190,8 +190,8 @@ static void free_pending_block(struct log_writes_c *lc,
 	int i;
 
 	for (i = 0; i < block->vec_cnt; i++) {
-		if (block->vecs[i].bv_page)
-			__free_page(block->vecs[i].bv_page);
+		if (bvec_page(&block->vecs[i]))
+			__free_page(bvec_page(&block->vecs[i]));
 	}
 	kfree(block->data);
 	kfree(block);
@@ -370,7 +370,7 @@ static int log_one_block(struct log_writes_c *lc,
 		 * The page offset is always 0 because we allocate a new page
 		 * for every bvec in the original bio for simplicity sake.
 		 */
-		ret = bio_add_page(bio, block->vecs[i].bv_page,
+		ret = bio_add_page(bio, bvec_page(&block->vecs[i]),
 				   block->vecs[i].bv_len, 0);
 		if (ret != block->vecs[i].bv_len) {
 			atomic_inc(&lc->io_blocks);
@@ -387,7 +387,7 @@ static int log_one_block(struct log_writes_c *lc,
 			bio->bi_private = lc;
 			bio_set_op_attrs(bio, REQ_OP_WRITE, 0);
 
-			ret = bio_add_page(bio, block->vecs[i].bv_page,
+			ret = bio_add_page(bio, bvec_page(&block->vecs[i]),
 					   block->vecs[i].bv_len, 0);
 			if (ret != block->vecs[i].bv_len) {
 				DMERR("Couldn't add page on new bio?");
@@ -746,12 +746,12 @@ static int log_writes_map(struct dm_target *ti, struct bio *bio)
 			return DM_MAPIO_KILL;
 		}
 
-		src = kmap_atomic(bv.bv_page);
+		src = kmap_atomic(bvec_page(&bv));
 		dst = kmap_atomic(page);
 		memcpy(dst, src + bv.bv_offset, bv.bv_len);
 		kunmap_atomic(dst);
 		kunmap_atomic(src);
-		block->vecs[i].bv_page = page;
+		bvec_set_page(&block->vecs[i], page);
 		block->vecs[i].bv_len = bv.bv_len;
 		block->vec_cnt++;
 		i++;
diff --git a/drivers/md/dm-verity-target.c b/drivers/md/dm-verity-target.c
index f4c31ffaa88e..cafa738f3b57 100644
--- a/drivers/md/dm-verity-target.c
+++ b/drivers/md/dm-verity-target.c
@@ -388,7 +388,7 @@ static int verity_for_io_block(struct dm_verity *v, struct dm_verity_io *io,
 		 * until you consider the typical block size is 4,096B.
 		 * Going through this loops twice should be very rare.
 		 */
-		sg_set_page(&sg, bv.bv_page, len, bv.bv_offset);
+		sg_set_page(&sg, bvec_page(&bv), len, bv.bv_offset);
 		ahash_request_set_crypt(req, &sg, NULL, len);
 		r = crypto_wait_req(crypto_ahash_update(req), wait);
 
@@ -423,7 +423,7 @@ int verity_for_bv_block(struct dm_verity *v, struct dm_verity_io *io,
 		unsigned len;
 		struct bio_vec bv = bio_iter_iovec(bio, *iter);
 
-		page = kmap_atomic(bv.bv_page);
+		page = kmap_atomic(bvec_page(&bv));
 		len = bv.bv_len;
 
 		if (likely(len >= todo))
diff --git a/drivers/md/raid5.c b/drivers/md/raid5.c
index c033bfcb209e..4913cdbd18eb 100644
--- a/drivers/md/raid5.c
+++ b/drivers/md/raid5.c
@@ -1129,9 +1129,11 @@ static void ops_run_io(struct stripe_head *sh, struct stripe_head_state *s)
 				 * must be preparing for prexor in rmw; read
 				 * the data into orig_page
 				 */
-				sh->dev[i].vec.bv_page = sh->dev[i].orig_page;
+				bvec_set_page(&sh->dev[i].vec,
+				              sh->dev[i].orig_page);
 			else
-				sh->dev[i].vec.bv_page = sh->dev[i].page;
+				bvec_set_page(&sh->dev[i].vec,
+				              sh->dev[i].page);
 			bi->bi_vcnt = 1;
 			bi->bi_io_vec[0].bv_len = STRIPE_SIZE;
 			bi->bi_io_vec[0].bv_offset = 0;
@@ -1185,7 +1187,7 @@ static void ops_run_io(struct stripe_head *sh, struct stripe_head_state *s)
 						  + rrdev->data_offset);
 			if (test_bit(R5_SkipCopy, &sh->dev[i].flags))
 				WARN_ON(test_bit(R5_UPTODATE, &sh->dev[i].flags));
-			sh->dev[i].rvec.bv_page = sh->dev[i].page;
+			bvec_set_page(&sh->dev[i].rvec, sh->dev[i].page);
 			rbi->bi_vcnt = 1;
 			rbi->bi_io_vec[0].bv_len = STRIPE_SIZE;
 			rbi->bi_io_vec[0].bv_offset = 0;
@@ -1267,7 +1269,7 @@ async_copy_data(int frombio, struct bio *bio, struct page **page,
 
 		if (clen > 0) {
 			b_offset += bvl.bv_offset;
-			bio_page = bvl.bv_page;
+			bio_page = bvec_page(&bvl);
 			if (frombio) {
 				if (sh->raid_conf->skip_copy &&
 				    b_offset == 0 && page_offset == 0 &&
diff --git a/drivers/nvdimm/blk.c b/drivers/nvdimm/blk.c
index db45c6bbb7bb..61ddf27726d1 100644
--- a/drivers/nvdimm/blk.c
+++ b/drivers/nvdimm/blk.c
@@ -97,7 +97,7 @@ static int nd_blk_rw_integrity(struct nd_namespace_blk *nsblk,
 		 */
 
 		cur_len = min(len, bv.bv_len);
-		iobuf = kmap_atomic(bv.bv_page);
+		iobuf = kmap_atomic(bvec_page(&bv));
 		err = ndbr->do_io(ndbr, dev_offset, iobuf + bv.bv_offset,
 				cur_len, rw);
 		kunmap_atomic(iobuf);
@@ -191,8 +191,8 @@ static blk_qc_t nd_blk_make_request(struct request_queue *q, struct bio *bio)
 		unsigned int len = bvec.bv_len;
 
 		BUG_ON(len > PAGE_SIZE);
-		err = nsblk_do_bvec(nsblk, bip, bvec.bv_page, len,
-				bvec.bv_offset, rw, iter.bi_sector);
+		err = nsblk_do_bvec(nsblk, bip, bvec_page(&bvec), len,
+				    bvec.bv_offset, rw, iter.bi_sector);
 		if (err) {
 			dev_dbg(&nsblk->common.dev,
 					"io error in %s sector %lld, len %d,\n",
diff --git a/drivers/nvdimm/btt.c b/drivers/nvdimm/btt.c
index 4671776f5623..f3e7be5bdb25 100644
--- a/drivers/nvdimm/btt.c
+++ b/drivers/nvdimm/btt.c
@@ -1171,7 +1171,7 @@ static int btt_rw_integrity(struct btt *btt, struct bio_integrity_payload *bip,
 		 */
 
 		cur_len = min(len, bv.bv_len);
-		mem = kmap_atomic(bv.bv_page);
+		mem = kmap_atomic(bvec_page(&bv));
 		if (rw)
 			ret = arena_write_bytes(arena, meta_nsoff,
 					mem + bv.bv_offset, cur_len,
@@ -1472,7 +1472,8 @@ static blk_qc_t btt_make_request(struct request_queue *q, struct bio *bio)
 			break;
 		}
 
-		err = btt_do_bvec(btt, bip, bvec.bv_page, len, bvec.bv_offset,
+		err = btt_do_bvec(btt, bip, bvec_page(&bvec), len,
+				  bvec.bv_offset,
 				  bio_op(bio), iter.bi_sector);
 		if (err) {
 			dev_err(&btt->nd_btt->dev,
diff --git a/drivers/nvdimm/pmem.c b/drivers/nvdimm/pmem.c
index bc2f700feef8..04a6932fdd69 100644
--- a/drivers/nvdimm/pmem.c
+++ b/drivers/nvdimm/pmem.c
@@ -205,8 +205,8 @@ static blk_qc_t pmem_make_request(struct request_queue *q, struct bio *bio)
 
 	do_acct = nd_iostat_start(bio, &start);
 	bio_for_each_segment(bvec, bio, iter) {
-		rc = pmem_do_bvec(pmem, bvec.bv_page, bvec.bv_len,
-				bvec.bv_offset, bio_op(bio), iter.bi_sector);
+		rc = pmem_do_bvec(pmem, bvec_page(&bvec), bvec.bv_len,
+				  bvec.bv_offset, bio_op(bio), iter.bi_sector);
 		if (rc) {
 			bio->bi_status = rc;
 			break;
diff --git a/drivers/nvme/host/core.c b/drivers/nvme/host/core.c
index 470601980794..942287e38b14 100644
--- a/drivers/nvme/host/core.c
+++ b/drivers/nvme/host/core.c
@@ -600,7 +600,7 @@ static blk_status_t nvme_setup_discard(struct nvme_ns *ns, struct request *req,
 	cmnd->dsm.nr = cpu_to_le32(segments - 1);
 	cmnd->dsm.attributes = cpu_to_le32(NVME_DSMGMT_AD);
 
-	req->special_vec.bv_page = virt_to_page(range);
+	bvec_set_page(&req->special_vec, virt_to_page(range));
 	req->special_vec.bv_offset = offset_in_page(range);
 	req->special_vec.bv_len = sizeof(*range) * segments;
 	req->rq_flags |= RQF_SPECIAL_PAYLOAD;
@@ -691,7 +691,7 @@ void nvme_cleanup_cmd(struct request *req)
 	}
 	if (req->rq_flags & RQF_SPECIAL_PAYLOAD) {
 		struct nvme_ns *ns = req->rq_disk->private_data;
-		struct page *page = req->special_vec.bv_page;
+		struct page *page = bvec_page(&req->special_vec);
 
 		if (page == ns->ctrl->discard_page)
 			clear_bit_unlock(0, &ns->ctrl->discard_page_busy);
diff --git a/drivers/nvme/host/tcp.c b/drivers/nvme/host/tcp.c
index 68c49dd67210..0023d564d9fd 100644
--- a/drivers/nvme/host/tcp.c
+++ b/drivers/nvme/host/tcp.c
@@ -175,7 +175,7 @@ static inline bool nvme_tcp_has_inline_data(struct nvme_tcp_request *req)
 
 static inline struct page *nvme_tcp_req_cur_page(struct nvme_tcp_request *req)
 {
-	return req->iter.bvec->bv_page;
+	return bvec_page(req->iter.bvec);
 }
 
 static inline size_t nvme_tcp_req_cur_offset(struct nvme_tcp_request *req)
diff --git a/drivers/nvme/target/io-cmd-file.c b/drivers/nvme/target/io-cmd-file.c
index bc6ebb51b0bf..24f95424d814 100644
--- a/drivers/nvme/target/io-cmd-file.c
+++ b/drivers/nvme/target/io-cmd-file.c
@@ -77,7 +77,7 @@ int nvmet_file_ns_enable(struct nvmet_ns *ns)
 
 static void nvmet_file_init_bvec(struct bio_vec *bv, struct scatterlist *sg)
 {
-	bv->bv_page = sg_page(sg);
+	bvec_set_page(bv, sg_page(sg));
 	bv->bv_offset = sg->offset;
 	bv->bv_len = sg->length;
 }
diff --git a/drivers/s390/block/dasd_diag.c b/drivers/s390/block/dasd_diag.c
index e1fe02477ea8..65ee8b2a4953 100644
--- a/drivers/s390/block/dasd_diag.c
+++ b/drivers/s390/block/dasd_diag.c
@@ -546,7 +546,7 @@ static struct dasd_ccw_req *dasd_diag_build_cp(struct dasd_device *memdev,
 	dbio = dreq->bio;
 	recid = first_rec;
 	rq_for_each_segment(bv, req, iter) {
-		dst = page_address(bv.bv_page) + bv.bv_offset;
+		dst = page_address(bvec_page(&bv)) + bv.bv_offset;
 		for (off = 0; off < bv.bv_len; off += blksize) {
 			memset(dbio, 0, sizeof (struct dasd_diag_bio));
 			dbio->type = rw_cmd;
diff --git a/drivers/s390/block/dasd_eckd.c b/drivers/s390/block/dasd_eckd.c
index 6e294b4d3635..35948cc5c618 100644
--- a/drivers/s390/block/dasd_eckd.c
+++ b/drivers/s390/block/dasd_eckd.c
@@ -3078,7 +3078,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_cmd_single(
 			/* Eckd can only do full blocks. */
 			return ERR_PTR(-EINVAL);
 		count += bv.bv_len >> (block->s2b_shift + 9);
-		if (idal_is_needed (page_address(bv.bv_page), bv.bv_len))
+		if (idal_is_needed (page_address(bvec_page(&bv)), bv.bv_len))
 			cidaw += bv.bv_len >> (block->s2b_shift + 9);
 	}
 	/* Paranoia. */
@@ -3149,7 +3149,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_cmd_single(
 			      last_rec - recid + 1, cmd, basedev, blksize);
 	}
 	rq_for_each_segment(bv, req, iter) {
-		dst = page_address(bv.bv_page) + bv.bv_offset;
+		dst = page_address(bvec_page(&bv)) + bv.bv_offset;
 		if (dasd_page_cache) {
 			char *copy = kmem_cache_alloc(dasd_page_cache,
 						      GFP_DMA | __GFP_NOWARN);
@@ -3308,7 +3308,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_cmd_track(
 	idaw_dst = NULL;
 	idaw_len = 0;
 	rq_for_each_segment(bv, req, iter) {
-		dst = page_address(bv.bv_page) + bv.bv_offset;
+		dst = page_address(bvec_page(&bv)) + bv.bv_offset;
 		seg_len = bv.bv_len;
 		while (seg_len) {
 			if (new_track) {
@@ -3646,7 +3646,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_tpm_track(
 		new_track = 1;
 		recid = first_rec;
 		rq_for_each_segment(bv, req, iter) {
-			dst = page_address(bv.bv_page) + bv.bv_offset;
+			dst = page_address(bvec_page(&bv)) + bv.bv_offset;
 			seg_len = bv.bv_len;
 			while (seg_len) {
 				if (new_track) {
@@ -3679,7 +3679,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_tpm_track(
 		}
 	} else {
 		rq_for_each_segment(bv, req, iter) {
-			dst = page_address(bv.bv_page) + bv.bv_offset;
+			dst = page_address(bvec_page(&bv)) + bv.bv_offset;
 			last_tidaw = itcw_add_tidaw(itcw, 0x00,
 						    dst, bv.bv_len);
 			if (IS_ERR(last_tidaw)) {
@@ -3907,7 +3907,7 @@ static struct dasd_ccw_req *dasd_eckd_build_cp_raw(struct dasd_device *startdev,
 			idaws = idal_create_words(idaws, rawpadpage, PAGE_SIZE);
 	}
 	rq_for_each_segment(bv, req, iter) {
-		dst = page_address(bv.bv_page) + bv.bv_offset;
+		dst = page_address(bvec_page(&bv)) + bv.bv_offset;
 		seg_len = bv.bv_len;
 		if (cmd == DASD_ECKD_CCW_READ_TRACK)
 			memset(dst, 0, seg_len);
@@ -3968,7 +3968,7 @@ dasd_eckd_free_cp(struct dasd_ccw_req *cqr, struct request *req)
 	if (private->uses_cdl == 0 || recid > 2*blk_per_trk)
 		ccw++;
 	rq_for_each_segment(bv, req, iter) {
-		dst = page_address(bv.bv_page) + bv.bv_offset;
+		dst = page_address(bvec_page(&bv)) + bv.bv_offset;
 		for (off = 0; off < bv.bv_len; off += blksize) {
 			/* Skip locate record. */
 			if (private->uses_cdl && recid <= 2*blk_per_trk)
diff --git a/drivers/s390/block/dasd_fba.c b/drivers/s390/block/dasd_fba.c
index 56007a3e7f11..2c65118fa15e 100644
--- a/drivers/s390/block/dasd_fba.c
+++ b/drivers/s390/block/dasd_fba.c
@@ -471,7 +471,7 @@ static struct dasd_ccw_req *dasd_fba_build_cp_regular(
 			/* Fba can only do full blocks. */
 			return ERR_PTR(-EINVAL);
 		count += bv.bv_len >> (block->s2b_shift + 9);
-		if (idal_is_needed (page_address(bv.bv_page), bv.bv_len))
+		if (idal_is_needed (page_address(bvec_page(&bv)), bv.bv_len))
 			cidaw += bv.bv_len / blksize;
 	}
 	/* Paranoia. */
@@ -509,7 +509,7 @@ static struct dasd_ccw_req *dasd_fba_build_cp_regular(
 	}
 	recid = first_rec;
 	rq_for_each_segment(bv, req, iter) {
-		dst = page_address(bv.bv_page) + bv.bv_offset;
+		dst = page_address(bvec_page(&bv)) + bv.bv_offset;
 		if (dasd_page_cache) {
 			char *copy = kmem_cache_alloc(dasd_page_cache,
 						      GFP_DMA | __GFP_NOWARN);
@@ -591,7 +591,7 @@ dasd_fba_free_cp(struct dasd_ccw_req *cqr, struct request *req)
 	if (private->rdc_data.mode.bits.data_chain != 0)
 		ccw++;
 	rq_for_each_segment(bv, req, iter) {
-		dst = page_address(bv.bv_page) + bv.bv_offset;
+		dst = page_address(bvec_page(&bv)) + bv.bv_offset;
 		for (off = 0; off < bv.bv_len; off += blksize) {
 			/* Skip locate record. */
 			if (private->rdc_data.mode.bits.data_chain == 0)
diff --git a/drivers/s390/block/dcssblk.c b/drivers/s390/block/dcssblk.c
index 4e8aedd50cb0..77228e43c415 100644
--- a/drivers/s390/block/dcssblk.c
+++ b/drivers/s390/block/dcssblk.c
@@ -893,7 +893,7 @@ dcssblk_make_request(struct request_queue *q, struct bio *bio)
 	index = (bio->bi_iter.bi_sector >> 3);
 	bio_for_each_segment(bvec, bio, iter) {
 		page_addr = (unsigned long)
-			page_address(bvec.bv_page) + bvec.bv_offset;
+			page_address(bvec_page(&bvec)) + bvec.bv_offset;
 		source_addr = dev_info->start + (index<<12) + bytes_done;
 		if (unlikely((page_addr & 4095) != 0) || (bvec.bv_len & 4095) != 0)
 			// More paranoia.
diff --git a/drivers/s390/block/scm_blk.c b/drivers/s390/block/scm_blk.c
index e01889394c84..ea9afb84ae5b 100644
--- a/drivers/s390/block/scm_blk.c
+++ b/drivers/s390/block/scm_blk.c
@@ -201,7 +201,7 @@ static int scm_request_prepare(struct scm_request *scmrq)
 	rq_for_each_segment(bv, req, iter) {
 		WARN_ON(bv.bv_offset);
 		msb->blk_count += bv.bv_len >> 12;
-		aidaw->data_addr = (u64) page_address(bv.bv_page);
+		aidaw->data_addr = (u64) page_address(bvec_page(&bv));
 		aidaw++;
 	}
 
diff --git a/drivers/s390/block/xpram.c b/drivers/s390/block/xpram.c
index 3df5d68d09f0..3f86f269e89e 100644
--- a/drivers/s390/block/xpram.c
+++ b/drivers/s390/block/xpram.c
@@ -205,7 +205,7 @@ static blk_qc_t xpram_make_request(struct request_queue *q, struct bio *bio)
 	index = (bio->bi_iter.bi_sector >> 3) + xdev->offset;
 	bio_for_each_segment(bvec, bio, iter) {
 		page_addr = (unsigned long)
-			kmap(bvec.bv_page) + bvec.bv_offset;
+			kmap(bvec_page(&bvec)) + bvec.bv_offset;
 		bytes = bvec.bv_len;
 		if ((page_addr & 4095) != 0 || (bytes & 4095) != 0)
 			/* More paranoia. */
diff --git a/drivers/scsi/sd.c b/drivers/scsi/sd.c
index 2b2bc4b49d78..c355aff34ebf 100644
--- a/drivers/scsi/sd.c
+++ b/drivers/scsi/sd.c
@@ -828,10 +828,11 @@ static blk_status_t sd_setup_unmap_cmnd(struct scsi_cmnd *cmd)
 	unsigned int data_len = 24;
 	char *buf;
 
-	rq->special_vec.bv_page = mempool_alloc(sd_page_pool, GFP_ATOMIC);
-	if (!rq->special_vec.bv_page)
+	bvec_set_page(&rq->special_vec,
+		      mempool_alloc(sd_page_pool, GFP_ATOMIC));
+	if (!bvec_page(&rq->special_vec))
 		return BLK_STS_RESOURCE;
-	clear_highpage(rq->special_vec.bv_page);
+	clear_highpage(bvec_page(&rq->special_vec));
 	rq->special_vec.bv_offset = 0;
 	rq->special_vec.bv_len = data_len;
 	rq->rq_flags |= RQF_SPECIAL_PAYLOAD;
@@ -840,7 +841,7 @@ static blk_status_t sd_setup_unmap_cmnd(struct scsi_cmnd *cmd)
 	cmd->cmnd[0] = UNMAP;
 	cmd->cmnd[8] = 24;
 
-	buf = page_address(rq->special_vec.bv_page);
+	buf = page_address(bvec_page(&rq->special_vec));
 	put_unaligned_be16(6 + 16, &buf[0]);
 	put_unaligned_be16(16, &buf[2]);
 	put_unaligned_be64(lba, &buf[8]);
@@ -862,10 +863,11 @@ static blk_status_t sd_setup_write_same16_cmnd(struct scsi_cmnd *cmd,
 	u32 nr_blocks = sectors_to_logical(sdp, blk_rq_sectors(rq));
 	u32 data_len = sdp->sector_size;
 
-	rq->special_vec.bv_page = mempool_alloc(sd_page_pool, GFP_ATOMIC);
-	if (!rq->special_vec.bv_page)
+	bvec_set_page(&rq->special_vec,
+		      mempool_alloc(sd_page_pool, GFP_ATOMIC));
+	if (!bvec_page(&rq->special_vec))
 		return BLK_STS_RESOURCE;
-	clear_highpage(rq->special_vec.bv_page);
+	clear_highpage(bvec_page(&rq->special_vec));
 	rq->special_vec.bv_offset = 0;
 	rq->special_vec.bv_len = data_len;
 	rq->rq_flags |= RQF_SPECIAL_PAYLOAD;
@@ -893,10 +895,11 @@ static blk_status_t sd_setup_write_same10_cmnd(struct scsi_cmnd *cmd,
 	u32 nr_blocks = sectors_to_logical(sdp, blk_rq_sectors(rq));
 	u32 data_len = sdp->sector_size;
 
-	rq->special_vec.bv_page = mempool_alloc(sd_page_pool, GFP_ATOMIC);
-	if (!rq->special_vec.bv_page)
+	bvec_set_page(&rq->special_vec,
+		      mempool_alloc(sd_page_pool, GFP_ATOMIC));
+	if (!bvec_page(&rq->special_vec))
 		return BLK_STS_RESOURCE;
-	clear_highpage(rq->special_vec.bv_page);
+	clear_highpage(bvec_page(&rq->special_vec));
 	rq->special_vec.bv_offset = 0;
 	rq->special_vec.bv_len = data_len;
 	rq->rq_flags |= RQF_SPECIAL_PAYLOAD;
@@ -1304,7 +1307,7 @@ static void sd_uninit_command(struct scsi_cmnd *SCpnt)
 	u8 *cmnd;
 
 	if (rq->rq_flags & RQF_SPECIAL_PAYLOAD)
-		mempool_free(rq->special_vec.bv_page, sd_page_pool);
+		mempool_free(bvec_page(&rq->special_vec), sd_page_pool);
 
 	if (SCpnt->cmnd != scsi_req(rq)->cmd) {
 		cmnd = SCpnt->cmnd;
diff --git a/drivers/staging/erofs/data.c b/drivers/staging/erofs/data.c
index 526e0dbea5b5..ba467ba414ff 100644
--- a/drivers/staging/erofs/data.c
+++ b/drivers/staging/erofs/data.c
@@ -23,7 +23,7 @@ static inline void read_endio(struct bio *bio)
 	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		struct page *page = bvec->bv_page;
+		struct page *page = bvec_page(bvec);
 
 		/* page is already locked */
 		DBG_BUGON(PageUptodate(page));
diff --git a/drivers/staging/erofs/unzip_vle.c b/drivers/staging/erofs/unzip_vle.c
index 31eef8395774..11aa0c6f1994 100644
--- a/drivers/staging/erofs/unzip_vle.c
+++ b/drivers/staging/erofs/unzip_vle.c
@@ -852,7 +852,7 @@ static inline void z_erofs_vle_read_endio(struct bio *bio)
 	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		struct page *page = bvec->bv_page;
+		struct page *page = bvec_page(bvec);
 		bool cachemngd = false;
 
 		DBG_BUGON(PageUptodate(page));
diff --git a/drivers/target/target_core_file.c b/drivers/target/target_core_file.c
index 49b110d1b972..9a3e3bc1101e 100644
--- a/drivers/target/target_core_file.c
+++ b/drivers/target/target_core_file.c
@@ -296,7 +296,7 @@ fd_execute_rw_aio(struct se_cmd *cmd, struct scatterlist *sgl, u32 sgl_nents,
 	}
 
 	for_each_sg(sgl, sg, sgl_nents, i) {
-		bvec[i].bv_page = sg_page(sg);
+		bvec_set_page(&bvec[i], sg_page(sg));
 		bvec[i].bv_len = sg->length;
 		bvec[i].bv_offset = sg->offset;
 
@@ -346,7 +346,7 @@ static int fd_do_rw(struct se_cmd *cmd, struct file *fd,
 	}
 
 	for_each_sg(sgl, sg, sgl_nents, i) {
-		bvec[i].bv_page = sg_page(sg);
+		bvec_set_page(&bvec[i], sg_page(sg));
 		bvec[i].bv_len = sg->length;
 		bvec[i].bv_offset = sg->offset;
 
@@ -483,7 +483,7 @@ fd_execute_write_same(struct se_cmd *cmd)
 		return TCM_LOGICAL_UNIT_COMMUNICATION_FAILURE;
 
 	for (i = 0; i < nolb; i++) {
-		bvec[i].bv_page = sg_page(&cmd->t_data_sg[0]);
+		bvec_set_page(&bvec[i], sg_page(&cmd->t_data_sg[0]));
 		bvec[i].bv_len = cmd->t_data_sg[0].length;
 		bvec[i].bv_offset = cmd->t_data_sg[0].offset;
 
diff --git a/drivers/xen/biomerge.c b/drivers/xen/biomerge.c
index f3fbb700f569..fed2a4883817 100644
--- a/drivers/xen/biomerge.c
+++ b/drivers/xen/biomerge.c
@@ -8,8 +8,8 @@ bool xen_biovec_phys_mergeable(const struct bio_vec *vec1,
 			       const struct bio_vec *vec2)
 {
 #if XEN_PAGE_SIZE == PAGE_SIZE
-	unsigned long bfn1 = pfn_to_bfn(page_to_pfn(vec1->bv_page));
-	unsigned long bfn2 = pfn_to_bfn(page_to_pfn(vec2->bv_page));
+	unsigned long bfn1 = pfn_to_bfn(page_to_pfn(bvec_page(vec1)));
+	unsigned long bfn2 = pfn_to_bfn(page_to_pfn(bvec_page(vec2)));
 
 	return bfn1 + PFN_DOWN(vec1->bv_offset + vec1->bv_len) == bfn2;
 #else
diff --git a/fs/9p/vfs_addr.c b/fs/9p/vfs_addr.c
index b626b28f0ce9..5f581ba51a5a 100644
--- a/fs/9p/vfs_addr.c
+++ b/fs/9p/vfs_addr.c
@@ -172,7 +172,7 @@ static int v9fs_vfs_writepage_locked(struct page *page)
 	else
 		len = PAGE_SIZE;
 
-	bvec.bv_page = page;
+	bvec_set_page(&bvec, page);
 	bvec.bv_offset = 0;
 	bvec.bv_len = len;
 	iov_iter_bvec(&from, WRITE, &bvec, 1, len);
diff --git a/fs/afs/fsclient.c b/fs/afs/fsclient.c
index 0b37867b5c20..af7cdb8accf4 100644
--- a/fs/afs/fsclient.c
+++ b/fs/afs/fsclient.c
@@ -521,7 +521,7 @@ static int afs_deliver_fs_fetch_data(struct afs_call *call)
 			size = req->remain;
 		call->bvec[0].bv_len = size;
 		call->bvec[0].bv_offset = req->offset;
-		call->bvec[0].bv_page = req->pages[req->index];
+		bvec_set_page(&call->bvec[0], req->pages[req->index]);
 		iov_iter_bvec(&call->iter, READ, call->bvec, 1, size);
 		ASSERTCMP(size, <=, PAGE_SIZE);
 
diff --git a/fs/afs/rxrpc.c b/fs/afs/rxrpc.c
index 2c588f9bbbda..85caafeb9131 100644
--- a/fs/afs/rxrpc.c
+++ b/fs/afs/rxrpc.c
@@ -303,7 +303,7 @@ static void afs_load_bvec(struct afs_call *call, struct msghdr *msg,
 			to = call->last_to;
 			msg->msg_flags &= ~MSG_MORE;
 		}
-		bv[i].bv_page = pages[i];
+		bvec_set_page(&bv[i], pages[i]);
 		bv[i].bv_len = to - offset;
 		bv[i].bv_offset = offset;
 		bytes += to - offset;
@@ -349,7 +349,7 @@ static int afs_send_pages(struct afs_call *call, struct msghdr *msg)
 		ret = rxrpc_kernel_send_data(call->net->socket, call->rxcall, msg,
 					     bytes, afs_notify_end_request_tx);
 		for (loop = 0; loop < nr; loop++)
-			put_page(bv[loop].bv_page);
+			put_page(bvec_page(&bv[loop]));
 		if (ret < 0)
 			break;
 
diff --git a/fs/afs/yfsclient.c b/fs/afs/yfsclient.c
index 6e97a42d24d1..e05fb959b13e 100644
--- a/fs/afs/yfsclient.c
+++ b/fs/afs/yfsclient.c
@@ -567,7 +567,7 @@ static int yfs_deliver_fs_fetch_data64(struct afs_call *call)
 			size = req->remain;
 		call->bvec[0].bv_len = size;
 		call->bvec[0].bv_offset = req->offset;
-		call->bvec[0].bv_page = req->pages[req->index];
+		bvec_set_page(&call->bvec[0], req->pages[req->index]);
 		iov_iter_bvec(&call->iter, READ, call->bvec, 1, size);
 		ASSERTCMP(size, <=, PAGE_SIZE);
 
diff --git a/fs/block_dev.c b/fs/block_dev.c
index 78d3257435c0..7304fc309326 100644
--- a/fs/block_dev.c
+++ b/fs/block_dev.c
@@ -262,9 +262,9 @@ __blkdev_direct_IO_simple(struct kiocb *iocb, struct iov_iter *iter,
 	__set_current_state(TASK_RUNNING);
 
 	bio_for_each_segment_all(bvec, &bio, i, iter_all) {
-		if (should_dirty && !PageCompound(bvec->bv_page))
-			set_page_dirty_lock(bvec->bv_page);
-		put_page(bvec->bv_page);
+		if (should_dirty && !PageCompound(bvec_page(bvec)))
+			set_page_dirty_lock(bvec_page(bvec));
+		put_page(bvec_page(bvec));
 	}
 
 	if (unlikely(bio.bi_status))
@@ -342,7 +342,7 @@ static void blkdev_bio_end_io(struct bio *bio)
 			int i;
 
 			bio_for_each_segment_all(bvec, bio, i, iter_all)
-				put_page(bvec->bv_page);
+				put_page(bvec_page(bvec));
 		}
 		bio_put(bio);
 	}
diff --git a/fs/btrfs/check-integrity.c b/fs/btrfs/check-integrity.c
index b0c8094528d1..c5ee3ac73930 100644
--- a/fs/btrfs/check-integrity.c
+++ b/fs/btrfs/check-integrity.c
@@ -2824,7 +2824,7 @@ static void __btrfsic_submit_bio(struct bio *bio)
 
 		bio_for_each_segment(bvec, bio, iter) {
 			BUG_ON(bvec.bv_len != PAGE_SIZE);
-			mapped_datav[i] = kmap(bvec.bv_page);
+			mapped_datav[i] = kmap(bvec_page(&bvec));
 			i++;
 
 			if (dev_state->state->print_mask &
@@ -2838,7 +2838,7 @@ static void __btrfsic_submit_bio(struct bio *bio)
 					      bio, &bio_is_patched,
 					      NULL, bio->bi_opf);
 		bio_for_each_segment(bvec, bio, iter)
-			kunmap(bvec.bv_page);
+			kunmap(bvec_page(&bvec));
 		kfree(mapped_datav);
 	} else if (NULL != dev_state && (bio->bi_opf & REQ_PREFLUSH)) {
 		if (dev_state->state->print_mask &
diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index 4f2a8ae0aa42..fcedb69c4d7a 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -170,7 +170,7 @@ static void end_compressed_bio_read(struct bio *bio)
 		 */
 		ASSERT(!bio_flagged(bio, BIO_CLONED));
 		bio_for_each_segment_all(bvec, cb->orig_bio, i, iter_all)
-			SetPageChecked(bvec->bv_page);
+			SetPageChecked(bvec_page(bvec));
 
 		bio_endio(cb->orig_bio);
 	}
@@ -398,7 +398,7 @@ static u64 bio_end_offset(struct bio *bio)
 {
 	struct bio_vec *last = bio_last_bvec_all(bio);
 
-	return page_offset(last->bv_page) + last->bv_len + last->bv_offset;
+	return page_offset(bvec_page(last)) + last->bv_len + last->bv_offset;
 }
 
 static noinline int add_ra_bio_pages(struct inode *inode,
@@ -1105,7 +1105,7 @@ int btrfs_decompress_buf2page(const char *buf, unsigned long buf_start,
 	 * start byte is the first byte of the page we're currently
 	 * copying into relative to the start of the compressed data.
 	 */
-	start_byte = page_offset(bvec.bv_page) - disk_start;
+	start_byte = page_offset(bvec_page(&bvec)) - disk_start;
 
 	/* we haven't yet hit data corresponding to this page */
 	if (total_out <= start_byte)
@@ -1129,10 +1129,10 @@ int btrfs_decompress_buf2page(const char *buf, unsigned long buf_start,
 				PAGE_SIZE - buf_offset);
 		bytes = min(bytes, working_bytes);
 
-		kaddr = kmap_atomic(bvec.bv_page);
+		kaddr = kmap_atomic(bvec_page(&bvec));
 		memcpy(kaddr + bvec.bv_offset, buf + buf_offset, bytes);
 		kunmap_atomic(kaddr);
-		flush_dcache_page(bvec.bv_page);
+		flush_dcache_page(bvec_page(&bvec));
 
 		buf_offset += bytes;
 		working_bytes -= bytes;
@@ -1144,7 +1144,7 @@ int btrfs_decompress_buf2page(const char *buf, unsigned long buf_start,
 			return 0;
 		bvec = bio_iter_iovec(bio, bio->bi_iter);
 		prev_start_byte = start_byte;
-		start_byte = page_offset(bvec.bv_page) - disk_start;
+		start_byte = page_offset(bvec_page(&bvec)) - disk_start;
 
 		/*
 		 * We need to make sure we're only adjusting
diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
index 6fe9197f6ee4..490d734f73bc 100644
--- a/fs/btrfs/disk-io.c
+++ b/fs/btrfs/disk-io.c
@@ -837,8 +837,8 @@ static blk_status_t btree_csum_one_bio(struct bio *bio)
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		root = BTRFS_I(bvec->bv_page->mapping->host)->root;
-		ret = csum_dirty_buffer(root->fs_info, bvec->bv_page);
+		root = BTRFS_I(bvec_page(bvec)->mapping->host)->root;
+		ret = csum_dirty_buffer(root->fs_info, bvec_page(bvec));
 		if (ret)
 			break;
 	}
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index ca8b8e785cf3..7485910fdff0 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -157,7 +157,7 @@ static int __must_check submit_one_bio(struct bio *bio, int mirror_num,
 	u64 start;
 
 	mp_bvec_last_segment(bvec, &bv);
-	start = page_offset(bv.bv_page) + bv.bv_offset;
+	start = page_offset(bvec_page(&bv)) + bv.bv_offset;
 
 	bio->bi_private = NULL;
 
@@ -2456,7 +2456,7 @@ static void end_bio_extent_writepage(struct bio *bio)
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		struct page *page = bvec->bv_page;
+		struct page *page = bvec_page(bvec);
 		struct inode *inode = page->mapping->host;
 		struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
 
@@ -2528,7 +2528,7 @@ static void end_bio_extent_readpage(struct bio *bio)
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		struct page *page = bvec->bv_page;
+		struct page *page = bvec_page(bvec);
 		struct inode *inode = page->mapping->host;
 		struct btrfs_fs_info *fs_info = btrfs_sb(inode->i_sb);
 		bool data_inode = btrfs_ino(BTRFS_I(inode))
@@ -3648,7 +3648,7 @@ static void end_bio_extent_buffer_writepage(struct bio *bio)
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		struct page *page = bvec->bv_page;
+		struct page *page = bvec_page(bvec);
 
 		eb = (struct extent_buffer *)page->private;
 		BUG_ON(!eb);
diff --git a/fs/btrfs/file-item.c b/fs/btrfs/file-item.c
index 920bf3b4b0ef..419c70021617 100644
--- a/fs/btrfs/file-item.c
+++ b/fs/btrfs/file-item.c
@@ -208,7 +208,7 @@ static blk_status_t __btrfs_lookup_bio_sums(struct inode *inode, struct bio *bio
 			goto next;
 
 		if (!dio)
-			offset = page_offset(bvec.bv_page) + bvec.bv_offset;
+			offset = page_offset(bvec_page(&bvec)) + bvec.bv_offset;
 		count = btrfs_find_ordered_sum(inode, offset, disk_bytenr,
 					       (u32 *)csum, nblocks);
 		if (count)
@@ -446,14 +446,14 @@ blk_status_t btrfs_csum_one_bio(struct inode *inode, struct bio *bio,
 
 	bio_for_each_segment(bvec, bio, iter) {
 		if (!contig)
-			offset = page_offset(bvec.bv_page) + bvec.bv_offset;
+			offset = page_offset(bvec_page(&bvec)) + bvec.bv_offset;
 
 		if (!ordered) {
 			ordered = btrfs_lookup_ordered_extent(inode, offset);
 			BUG_ON(!ordered); /* Logic error */
 		}
 
-		data = kmap_atomic(bvec.bv_page);
+		data = kmap_atomic(bvec_page(&bvec));
 
 		nr_sectors = BTRFS_BYTES_TO_BLKS(fs_info,
 						 bvec.bv_len + fs_info->sectorsize
@@ -483,7 +483,7 @@ blk_status_t btrfs_csum_one_bio(struct inode *inode, struct bio *bio,
 					+ total_bytes;
 				index = 0;
 
-				data = kmap_atomic(bvec.bv_page);
+				data = kmap_atomic(bvec_page(&bvec));
 			}
 
 			sums->sums[index] = ~(u32)0;
diff --git a/fs/btrfs/inode.c b/fs/btrfs/inode.c
index 82fdda8ff5ab..90e216d67b50 100644
--- a/fs/btrfs/inode.c
+++ b/fs/btrfs/inode.c
@@ -7843,7 +7843,7 @@ static void btrfs_retry_endio_nocsum(struct bio *bio)
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
 	bio_for_each_segment_all(bvec, bio, i, iter_all)
 		clean_io_failure(BTRFS_I(inode)->root->fs_info, failure_tree,
-				 io_tree, done->start, bvec->bv_page,
+				 io_tree, done->start, bvec_page(bvec),
 				 btrfs_ino(BTRFS_I(inode)), 0);
 end:
 	complete(&done->done);
@@ -7880,10 +7880,10 @@ static blk_status_t __btrfs_correct_data_nocsum(struct inode *inode,
 		done.start = start;
 		init_completion(&done.done);
 
-		ret = dio_read_error(inode, &io_bio->bio, bvec.bv_page,
-				pgoff, start, start + sectorsize - 1,
-				io_bio->mirror_num,
-				btrfs_retry_endio_nocsum, &done);
+		ret = dio_read_error(inode, &io_bio->bio, bvec_page(&bvec),
+				     pgoff, start, start + sectorsize - 1,
+				     io_bio->mirror_num,
+				     btrfs_retry_endio_nocsum, &done);
 		if (ret) {
 			err = ret;
 			goto next;
@@ -7935,13 +7935,14 @@ static void btrfs_retry_endio(struct bio *bio)
 
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		ret = __readpage_endio_check(inode, io_bio, i, bvec->bv_page,
+		ret = __readpage_endio_check(inode, io_bio, i,
+					     bvec_page(bvec),
 					     bvec->bv_offset, done->start,
 					     bvec->bv_len);
 		if (!ret)
 			clean_io_failure(BTRFS_I(inode)->root->fs_info,
 					 failure_tree, io_tree, done->start,
-					 bvec->bv_page,
+					 bvec_page(bvec),
 					 btrfs_ino(BTRFS_I(inode)),
 					 bvec->bv_offset);
 		else
@@ -7987,7 +7988,8 @@ static blk_status_t __btrfs_subio_endio_read(struct inode *inode,
 		if (uptodate) {
 			csum_pos = BTRFS_BYTES_TO_BLKS(fs_info, offset);
 			ret = __readpage_endio_check(inode, io_bio, csum_pos,
-					bvec.bv_page, pgoff, start, sectorsize);
+					bvec_page(&bvec), pgoff, start,
+					sectorsize);
 			if (likely(!ret))
 				goto next;
 		}
@@ -7996,7 +7998,7 @@ static blk_status_t __btrfs_subio_endio_read(struct inode *inode,
 		done.start = start;
 		init_completion(&done.done);
 
-		status = dio_read_error(inode, &io_bio->bio, bvec.bv_page,
+		status = dio_read_error(inode, &io_bio->bio, bvec_page(&bvec),
 					pgoff, start, start + sectorsize - 1,
 					io_bio->mirror_num, btrfs_retry_endio,
 					&done);
diff --git a/fs/btrfs/raid56.c b/fs/btrfs/raid56.c
index 67a6f7d47402..f02532ef34f0 100644
--- a/fs/btrfs/raid56.c
+++ b/fs/btrfs/raid56.c
@@ -1160,7 +1160,7 @@ static void index_rbio_pages(struct btrfs_raid_bio *rbio)
 			bio->bi_iter = btrfs_io_bio(bio)->iter;
 
 		bio_for_each_segment(bvec, bio, iter) {
-			rbio->bio_pages[page_index + i] = bvec.bv_page;
+			rbio->bio_pages[page_index + i] = bvec_page(&bvec);
 			i++;
 		}
 	}
@@ -1448,7 +1448,7 @@ static void set_bio_pages_uptodate(struct bio *bio)
 	ASSERT(!bio_flagged(bio, BIO_CLONED));
 
 	bio_for_each_segment_all(bvec, bio, i, iter_all)
-		SetPageUptodate(bvec->bv_page);
+		SetPageUptodate(bvec_page(bvec));
 }
 
 /*
diff --git a/fs/buffer.c b/fs/buffer.c
index ce357602f471..91c4bfde03e5 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -3043,7 +3043,7 @@ void guard_bio_eod(int op, struct bio *bio)
 		struct bio_vec bv;
 
 		mp_bvec_last_segment(bvec, &bv);
-		zero_user(bv.bv_page, bv.bv_offset + bv.bv_len,
+		zero_user(bvec_page(&bv), bv.bv_offset + bv.bv_len,
 				truncated_bytes);
 	}
 }
diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index d3c8035335a2..5183f545b90a 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -160,10 +160,10 @@ static void put_bvecs(struct bio_vec *bvecs, int num_bvecs, bool should_dirty)
 	int i;
 
 	for (i = 0; i < num_bvecs; i++) {
-		if (bvecs[i].bv_page) {
+		if (bvec_page(&bvecs[i])) {
 			if (should_dirty)
-				set_page_dirty_lock(bvecs[i].bv_page);
-			put_page(bvecs[i].bv_page);
+				set_page_dirty_lock(bvec_page(&bvecs[i]));
+			put_page(bvec_page(&bvecs[i]));
 		}
 	}
 	kvfree(bvecs);
diff --git a/fs/cifs/misc.c b/fs/cifs/misc.c
index 9bc0d17a9d77..4b6a6317f125 100644
--- a/fs/cifs/misc.c
+++ b/fs/cifs/misc.c
@@ -802,8 +802,8 @@ cifs_aio_ctx_release(struct kref *refcount)
 
 		for (i = 0; i < ctx->npages; i++) {
 			if (ctx->should_dirty)
-				set_page_dirty(ctx->bv[i].bv_page);
-			put_page(ctx->bv[i].bv_page);
+				set_page_dirty(bvec_page(&ctx->bv[i]));
+			put_page(bvec_page(&ctx->bv[i]));
 		}
 		kvfree(ctx->bv);
 	}
@@ -885,7 +885,7 @@ setup_aio_ctx_iter(struct cifs_aio_ctx *ctx, struct iov_iter *iter, int rw)
 
 		for (i = 0; i < cur_npages; i++) {
 			len = rc > PAGE_SIZE ? PAGE_SIZE : rc;
-			bv[npages + i].bv_page = pages[i];
+			bvec_set_page(&bv[npages + i], pages[i]);
 			bv[npages + i].bv_offset = start;
 			bv[npages + i].bv_len = len - start;
 			rc -= len;
diff --git a/fs/cifs/smb2ops.c b/fs/cifs/smb2ops.c
index 00225e699d03..a61a16fb9d2f 100644
--- a/fs/cifs/smb2ops.c
+++ b/fs/cifs/smb2ops.c
@@ -3456,7 +3456,7 @@ init_read_bvec(struct page **pages, unsigned int npages, unsigned int data_size,
 		return -ENOMEM;
 
 	for (i = 0; i < npages; i++) {
-		bvec[i].bv_page = pages[i];
+		bvec_set_page(&bvec[i], pages[i]);
 		bvec[i].bv_offset = (i == 0) ? cur_off : 0;
 		bvec[i].bv_len = min_t(unsigned int, PAGE_SIZE, data_size);
 		data_size -= bvec[i].bv_len;
diff --git a/fs/cifs/smbdirect.c b/fs/cifs/smbdirect.c
index b943b74cd246..08658dab6ee7 100644
--- a/fs/cifs/smbdirect.c
+++ b/fs/cifs/smbdirect.c
@@ -2070,7 +2070,7 @@ int smbd_recv(struct smbd_connection *info, struct msghdr *msg)
 		break;
 
 	case ITER_BVEC:
-		page = msg->msg_iter.bvec->bv_page;
+		page = bvec_page(msg->msg_iter.bvec);
 		page_offset = msg->msg_iter.bvec->bv_offset;
 		to_read = msg->msg_iter.bvec->bv_len;
 		rc = smbd_recv_page(info, page, page_offset, to_read);
diff --git a/fs/cifs/transport.c b/fs/cifs/transport.c
index 1de8e996e566..1f18ae00fdcd 100644
--- a/fs/cifs/transport.c
+++ b/fs/cifs/transport.c
@@ -369,7 +369,7 @@ __smb_send_rqst(struct TCP_Server_Info *server, int num_rqst,
 		for (i = 0; i < rqst[j].rq_npages; i++) {
 			struct bio_vec bvec;
 
-			bvec.bv_page = rqst[j].rq_pages[i];
+			bvec_set_page(&bvec, rqst[j].rq_pages[i]);
 			rqst_page_get_length(&rqst[j], i, &bvec.bv_len,
 					     &bvec.bv_offset);
 
diff --git a/fs/crypto/bio.c b/fs/crypto/bio.c
index 5759bcd018cd..51763b09a11b 100644
--- a/fs/crypto/bio.c
+++ b/fs/crypto/bio.c
@@ -33,7 +33,7 @@ static void __fscrypt_decrypt_bio(struct bio *bio, bool done)
 	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment_all(bv, bio, i, iter_all) {
-		struct page *page = bv->bv_page;
+		struct page *page = bvec_page(bv);
 		int ret = fscrypt_decrypt_page(page->mapping->host, page,
 				PAGE_SIZE, 0, page->index);
 
diff --git a/fs/direct-io.c b/fs/direct-io.c
index 52a18858e3e7..e9f3b79048ae 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -554,7 +554,7 @@ static blk_status_t dio_bio_complete(struct dio *dio, struct bio *bio)
 		struct bvec_iter_all iter_all;
 
 		bio_for_each_segment_all(bvec, bio, i, iter_all) {
-			struct page *page = bvec->bv_page;
+			struct page *page = bvec_page(bvec);
 
 			if (dio->op == REQ_OP_READ && !PageCompound(page) &&
 					dio->should_dirty)
diff --git a/fs/ext4/page-io.c b/fs/ext4/page-io.c
index 3e9298e6a705..4cd321328c18 100644
--- a/fs/ext4/page-io.c
+++ b/fs/ext4/page-io.c
@@ -66,7 +66,7 @@ static void ext4_finish_bio(struct bio *bio)
 	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		struct page *page = bvec->bv_page;
+		struct page *page = bvec_page(bvec);
 #ifdef CONFIG_FS_ENCRYPTION
 		struct page *data_page = NULL;
 #endif
diff --git a/fs/ext4/readpage.c b/fs/ext4/readpage.c
index 3adadf461825..84222b89da52 100644
--- a/fs/ext4/readpage.c
+++ b/fs/ext4/readpage.c
@@ -83,7 +83,7 @@ static void mpage_end_io(struct bio *bio)
 		}
 	}
 	bio_for_each_segment_all(bv, bio, i, iter_all) {
-		struct page *page = bv->bv_page;
+		struct page *page = bvec_page(bv);
 
 		if (!bio->bi_status) {
 			SetPageUptodate(page);
diff --git a/fs/f2fs/data.c b/fs/f2fs/data.c
index 9727944139f2..51bf04ba2599 100644
--- a/fs/f2fs/data.c
+++ b/fs/f2fs/data.c
@@ -90,7 +90,7 @@ static void __read_end_io(struct bio *bio)
 	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment_all(bv, bio, i, iter_all) {
-		page = bv->bv_page;
+		page = bvec_page(bv);
 
 		/* PG_error was set if any post_read step failed */
 		if (bio->bi_status || PageError(page)) {
@@ -173,7 +173,7 @@ static void f2fs_write_end_io(struct bio *bio)
 	}
 
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		struct page *page = bvec->bv_page;
+		struct page *page = bvec_page(bvec);
 		enum count_type type = WB_DATA_TYPE(page);
 
 		if (IS_DUMMY_WRITTEN_PAGE(page)) {
@@ -360,10 +360,10 @@ static bool __has_merged_page(struct f2fs_bio_info *io, struct inode *inode,
 
 	bio_for_each_segment_all(bvec, io->bio, i, iter_all) {
 
-		if (bvec->bv_page->mapping)
-			target = bvec->bv_page;
+		if (bvec_page(bvec)->mapping)
+			target = bvec_page(bvec);
 		else
-			target = fscrypt_control_page(bvec->bv_page);
+			target = fscrypt_control_page(bvec_page(bvec));
 
 		if (inode && inode == target->mapping->host)
 			return true;
diff --git a/fs/gfs2/lops.c b/fs/gfs2/lops.c
index 8722c60b11fe..e0523ef8421e 100644
--- a/fs/gfs2/lops.c
+++ b/fs/gfs2/lops.c
@@ -173,7 +173,7 @@ static void gfs2_end_log_write_bh(struct gfs2_sbd *sdp,
 				  blk_status_t error)
 {
 	struct buffer_head *bh, *next;
-	struct page *page = bvec->bv_page;
+	struct page *page = bvec_page(bvec);
 	unsigned size;
 
 	bh = page_buffers(page);
@@ -217,7 +217,7 @@ static void gfs2_end_log_write(struct bio *bio)
 	}
 
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		page = bvec->bv_page;
+		page = bvec_page(bvec);
 		if (page_has_buffers(page))
 			gfs2_end_log_write_bh(sdp, bvec, bio->bi_status);
 		else
diff --git a/fs/gfs2/meta_io.c b/fs/gfs2/meta_io.c
index 3201342404a7..a7e645d08942 100644
--- a/fs/gfs2/meta_io.c
+++ b/fs/gfs2/meta_io.c
@@ -193,7 +193,7 @@ static void gfs2_meta_read_endio(struct bio *bio)
 	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment_all(bvec, bio, i, iter_all) {
-		struct page *page = bvec->bv_page;
+		struct page *page = bvec_page(bvec);
 		struct buffer_head *bh = page_buffers(page);
 		unsigned int len = bvec->bv_len;
 
diff --git a/fs/io_uring.c b/fs/io_uring.c
index bbdbd56cf2ac..32f4b4ddd20b 100644
--- a/fs/io_uring.c
+++ b/fs/io_uring.c
@@ -2346,7 +2346,7 @@ static int io_sqe_buffer_unregister(struct io_ring_ctx *ctx)
 		struct io_mapped_ubuf *imu = &ctx->user_bufs[i];
 
 		for (j = 0; j < imu->nr_bvecs; j++)
-			put_page(imu->bvec[j].bv_page);
+			put_page(bvec_page(&imu->bvec[j]));
 
 		if (ctx->account_mem)
 			io_unaccount_mem(ctx->user, imu->nr_bvecs);
@@ -2504,7 +2504,7 @@ static int io_sqe_buffer_register(struct io_ring_ctx *ctx, void __user *arg,
 			size_t vec_len;
 
 			vec_len = min_t(size_t, size, PAGE_SIZE - off);
-			imu->bvec[j].bv_page = pages[j];
+			bvec_set_page(&imu->bvec[j], pages[j]);
 			imu->bvec[j].bv_len = vec_len;
 			imu->bvec[j].bv_offset = off;
 			off = 0;
diff --git a/fs/iomap.c b/fs/iomap.c
index abdd18e404f8..ed5f249cf0d4 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -235,7 +235,7 @@ iomap_read_finish(struct iomap_page *iop, struct page *page)
 static void
 iomap_read_page_end_io(struct bio_vec *bvec, int error)
 {
-	struct page *page = bvec->bv_page;
+	struct page *page = bvec_page(bvec);
 	struct iomap_page *iop = to_iomap_page(page);
 
 	if (unlikely(error)) {
@@ -1595,7 +1595,7 @@ static void iomap_dio_bio_end_io(struct bio *bio)
 			int i;
 
 			bio_for_each_segment_all(bvec, bio, i, iter_all)
-				put_page(bvec->bv_page);
+				put_page(bvec_page(bvec));
 		}
 		bio_put(bio);
 	}
diff --git a/fs/mpage.c b/fs/mpage.c
index 3f19da75178b..e234c9a8802d 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -51,7 +51,7 @@ static void mpage_end_io(struct bio *bio)
 	struct bvec_iter_all iter_all;
 
 	bio_for_each_segment_all(bv, bio, i, iter_all) {
-		struct page *page = bv->bv_page;
+		struct page *page = bvec_page(bv);
 		page_endio(page, bio_op(bio),
 			   blk_status_to_errno(bio->bi_status));
 	}
diff --git a/fs/splice.c b/fs/splice.c
index 3ee7e82df48f..4a0b522a0cb4 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -735,7 +735,7 @@ iter_file_splice_write(struct pipe_inode_info *pipe, struct file *out,
 				goto done;
 			}
 
-			array[n].bv_page = buf->page;
+			bvec_set_page(&array[n], buf->page);
 			array[n].bv_len = this_len;
 			array[n].bv_offset = buf->offset;
 			left -= this_len;
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 3619e9e8d359..d152d1ab2ad1 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -66,10 +66,10 @@ xfs_finish_page_writeback(
 	struct bio_vec	*bvec,
 	int			error)
 {
-	struct iomap_page	*iop = to_iomap_page(bvec->bv_page);
+	struct iomap_page	*iop = to_iomap_page(bvec_page(bvec));
 
 	if (error) {
-		SetPageError(bvec->bv_page);
+		SetPageError(bvec_page(bvec));
 		mapping_set_error(inode->i_mapping, -EIO);
 	}
 
@@ -77,7 +77,7 @@ xfs_finish_page_writeback(
 	ASSERT(!iop || atomic_read(&iop->write_count) > 0);
 
 	if (!iop || atomic_dec_and_test(&iop->write_count))
-		end_page_writeback(bvec->bv_page);
+		end_page_writeback(bvec_page(bvec));
 }
 
 /*
diff --git a/include/linux/bio.h b/include/linux/bio.h
index bb6090aa165d..6ac4f6b192e6 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -280,7 +280,7 @@ static inline struct bio_vec *bio_first_bvec_all(struct bio *bio)
 
 static inline struct page *bio_first_page_all(struct bio *bio)
 {
-	return bio_first_bvec_all(bio)->bv_page;
+	return bvec_page(bio_first_bvec_all(bio));
 }
 
 static inline struct bio_vec *bio_last_bvec_all(struct bio *bio)
@@ -544,7 +544,7 @@ static inline char *bvec_kmap_irq(struct bio_vec *bvec, unsigned long *flags)
 	 * balancing is a lot nicer this way
 	 */
 	local_irq_save(*flags);
-	addr = (unsigned long) kmap_atomic(bvec->bv_page);
+	addr = (unsigned long) kmap_atomic(bvec_page(bvec));
 
 	BUG_ON(addr & ~PAGE_MASK);
 
@@ -562,7 +562,7 @@ static inline void bvec_kunmap_irq(char *buffer, unsigned long *flags)
 #else
 static inline char *bvec_kmap_irq(struct bio_vec *bvec, unsigned long *flags)
 {
-	return page_address(bvec->bv_page) + bvec->bv_offset;
+	return page_address(bvec_page(bvec)) + bvec->bv_offset;
 }
 
 static inline void bvec_kunmap_irq(char *buffer, unsigned long *flags)
diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 8f8fb528ce53..d701cd968f13 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -157,7 +157,7 @@ static inline bool bvec_iter_advance(const struct bio_vec *bv,
 
 static inline struct bio_vec *bvec_init_iter_all(struct bvec_iter_all *iter_all)
 {
-	iter_all->bv.bv_page = NULL;
+	bvec_set_page(&iter_all->bv, NULL);
 	iter_all->done = 0;
 
 	return &iter_all->bv;
@@ -168,11 +168,11 @@ static inline void mp_bvec_next_segment(const struct bio_vec *bvec,
 {
 	struct bio_vec *bv = &iter_all->bv;
 
-	if (bv->bv_page) {
-		bv->bv_page = nth_page(bv->bv_page, 1);
+	if (bvec_page(bv)) {
+		bvec_set_page(bv, nth_page(bvec_page(bv), 1));
 		bv->bv_offset = 0;
 	} else {
-		bv->bv_page = bvec->bv_page;
+		bvec_set_page(bv, bvec_page(bvec));
 		bv->bv_offset = bvec->bv_offset;
 	}
 	bv->bv_len = min_t(unsigned int, PAGE_SIZE - bv->bv_offset,
@@ -189,7 +189,7 @@ static inline void mp_bvec_last_segment(const struct bio_vec *bvec,
 	unsigned total = bvec->bv_offset + bvec->bv_len;
 	unsigned last_page = (total - 1) / PAGE_SIZE;
 
-	seg->bv_page = bvec_nth_page(bvec->bv_page, last_page);
+	bvec_set_page(seg, bvec_nth_page(bvec_page(bvec), last_page));
 
 	/* the whole segment is inside the last page */
 	if (bvec->bv_offset >= last_page * PAGE_SIZE) {
diff --git a/net/ceph/messenger.c b/net/ceph/messenger.c
index 3e16187491d8..26eedf080df7 100644
--- a/net/ceph/messenger.c
+++ b/net/ceph/messenger.c
@@ -829,7 +829,7 @@ static struct page *ceph_msg_data_bio_next(struct ceph_msg_data_cursor *cursor,
 
 	*page_offset = bv.bv_offset;
 	*length = bv.bv_len;
-	return bv.bv_page;
+	return bvec_page(&bv);
 }
 
 static bool ceph_msg_data_bio_advance(struct ceph_msg_data_cursor *cursor,
@@ -890,7 +890,7 @@ static struct page *ceph_msg_data_bvecs_next(struct ceph_msg_data_cursor *cursor
 
 	*page_offset = bv.bv_offset;
 	*length = bv.bv_len;
-	return bv.bv_page;
+	return bvec_page(&bv);
 }
 
 static bool ceph_msg_data_bvecs_advance(struct ceph_msg_data_cursor *cursor,
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index aa8177ddcbda..93f1c6e2891b 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -148,7 +148,7 @@ xdr_alloc_bvec(struct xdr_buf *buf, gfp_t gfp)
 		if (!buf->bvec)
 			return -ENOMEM;
 		for (i = 0; i < n; i++) {
-			buf->bvec[i].bv_page = buf->pages[i];
+			bvec_set_page(&buf->bvec[i], buf->pages[i]);
 			buf->bvec[i].bv_len = PAGE_SIZE;
 			buf->bvec[i].bv_offset = 0;
 		}
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 732d4b57411a..373c5a4bbc97 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -334,7 +334,7 @@ xs_alloc_sparse_pages(struct xdr_buf *buf, size_t want, gfp_t gfp)
 	for (i = 0; i < n; i++) {
 		if (buf->pages[i])
 			continue;
-		buf->bvec[i].bv_page = buf->pages[i] = alloc_page(gfp);
+		bvec_set_page(&buf->bvec[i], buf->pages[i] = alloc_page(gfp));
 		if (!buf->pages[i]) {
 			i *= PAGE_SIZE;
 			return i > buf->page_base ? i - buf->page_base : 0;
@@ -389,7 +389,7 @@ xs_flush_bvec(const struct bio_vec *bvec, size_t count, size_t seek)
 
 	bvec_iter_advance(bvec, &bi, seek & PAGE_MASK);
 	for_each_bvec(bv, bvec, bi, bi)
-		flush_dcache_page(bv.bv_page);
+		flush_dcache_page(bvec_page(&bv));
 }
 #else
 static inline void
-- 
2.20.1

