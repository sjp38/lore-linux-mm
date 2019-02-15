Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47DE6C10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:14:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0139421B1A
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:14:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0139421B1A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A57C38E0006; Fri, 15 Feb 2019 06:14:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A08558E0001; Fri, 15 Feb 2019 06:14:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91D508E0006; Fri, 15 Feb 2019 06:14:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6842E8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:14:53 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id c9so768410qte.11
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:14:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Koc+x6ZPCcpLbp0ogoXEke8ZDu3+j/1e8qVxbzGR/dQ=;
        b=e5p62M5j1v1q20sXT4cHakibcNrOfXvwHJfKdgnPzU9NEVSl5BVn9rSlHz5pzSmIb9
         +6/xon3S6OmOkNCZBXJjif22Yt7SQIeRchHwPTjiA6YaHggkff2n7SLccj/BB1iTiaPS
         Rnup4yG2Yh/Dfe8wYNWC6+7fUDbSE7s7eE/PFDmjG0bJ5syr8sKXzQ71SmWpr5yaNw0Z
         6DcBveNgqb0byce+vaIuPBDJuEfcXPex/LW3Fcqmtk9QQV3S0GOCOU1Ne5wZIMY/tdx3
         ypGR3qTOqGkVgCkSH1hpKB1l+qP8kjCG6N/idrNinSruFgeslgmN47zLjqBOBOECnNdq
         /8pw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuauejrPHq+hg1An1hrVBlO6swHXDVQUA71bI7sNPxX/vqZYZgLQ
	pVBQisMGOwwQiAUET95+aMah1ohFNAKKDByU71yx2CkYH43nPBtpnLBrnbACgdB0js12tuVv9Hj
	i836eZXIQ2PxVZ7IszI/jgntVZMHELM5expPsguGUJr0wfRrhkIF4spO0flYxgl016A==
X-Received: by 2002:a0c:8971:: with SMTP id 46mr6641578qvq.224.1550229293174;
        Fri, 15 Feb 2019 03:14:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia2FtKHK38+RDxB+4uMkKDO5hSR8oPL3fKmAAdvgM3KWQ8Y7S2WQf9RLQ+2RhbePIHeL1aa
X-Received: by 2002:a0c:8971:: with SMTP id 46mr6641558qvq.224.1550229292668;
        Fri, 15 Feb 2019 03:14:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229292; cv=none;
        d=google.com; s=arc-20160816;
        b=LS49ZlYFvCSE9vyy7XFXtdLwBcdG9YZA3s2nMMTZ2n6wfn62Z4j4kEz1BOvs2aPpjK
         BcyJ2cBBH8UStcoDczQkKLisA9Tt8/aOESamB2Qh56tGmkw6rFPhP7RxqQdl8I6diTo8
         /3N9emQPfxceJBoFfj5ZdEME49/YqDjKyZtmgFVEfYAKx5X319py0LlE0fBQu/eACmgm
         8KoZK7Lf1H8GvuKYHVClh7LKIAvxB0UOSMwJg6sBy+WUUjDxX1FZtLu/hOPePwE22/OR
         W0GYT7ob1QCR7v4uakfHkSlxrGp74DZBvk8kJlerljFfPmRELJxdsSa7jY3ACmZ5+iqL
         9Ckw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Koc+x6ZPCcpLbp0ogoXEke8ZDu3+j/1e8qVxbzGR/dQ=;
        b=Dyz00CEl+MhOJxa6cKFIcXKgEkkeeSSW1Ct/9IvVr9PzJBBwM8eYM8U3+9hgA/Jbcd
         Rj68FFktvgYC/Ovot1l7AL3unJ3AldMZizE3vdlSexr54Hu7BZ56LKqd3b5nmrZAF58T
         U2AtfrTULg+UiyPkf0xCjjJsG1QKpnRL5zmxq8sLFQsTiJ5XJkG8eplbR4Ix3B72NnGG
         w/JFh53Q1F1jXiRT1LNBSMYpu8KA2VkKkcE8scKUUpSH5NFCckOom0l4JT9zxisaySYb
         MVh3RcK0DCScxX9UgJ7R9LtOsewGDUCjgm9tg3VHQXhNzgTuYBBUtdqQ2nZPmMvspSwL
         HTDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k7si2739775qtk.40.2019.02.15.03.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:14:52 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8FF3BC0AC913;
	Fri, 15 Feb 2019 11:14:51 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CD2F727BB3;
	Fri, 15 Feb 2019 11:14:41 +0000 (UTC)
From: Ming Lei <ming.lei@redhat.com>
To: Jens Axboe <axboe@kernel.dk>
Cc: linux-block@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Theodore Ts'o <tytso@mit.edu>,
	Omar Sandoval <osandov@fb.com>,
	Sagi Grimberg <sagi@grimberg.me>,
	Dave Chinner <dchinner@redhat.com>,
	Kent Overstreet <kent.overstreet@gmail.com>,
	Mike Snitzer <snitzer@redhat.com>,
	dm-devel@redhat.com,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	linux-fsdevel@vger.kernel.org,
	linux-raid@vger.kernel.org,
	David Sterba <dsterba@suse.com>,
	linux-btrfs@vger.kernel.org,
	"Darrick J . Wong" <darrick.wong@oracle.com>,
	linux-xfs@vger.kernel.org,
	Gao Xiang <gaoxiang25@huawei.com>,
	Christoph Hellwig <hch@lst.de>,
	linux-ext4@vger.kernel.org,
	Coly Li <colyli@suse.de>,
	linux-bcache@vger.kernel.org,
	Boaz Harrosh <ooo@electrozaur.com>,
	Bob Peterson <rpeterso@redhat.com>,
	cluster-devel@redhat.com,
	Ming Lei <ming.lei@redhat.com>
Subject: [PATCH V15 04/18] block: introduce multi-page bvec helpers
Date: Fri, 15 Feb 2019 19:13:10 +0800
Message-Id: <20190215111324.30129-5-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 15 Feb 2019 11:14:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch introduces helpers of 'mp_bvec_iter_*' for multi-page bvec
support.

The introduced helpers treate one bvec as real multi-page segment,
which may include more than one pages.

The existed helpers of bvec_iter_* are interfaces for supporting current
bvec iterator which is thought as single-page by drivers, fs, dm and
etc. These introduced helpers will build single-page bvec in flight, so
this way won't break current bio/bvec users, which needn't any change.

Follows some multi-page bvec background:

- bvecs stored in bio->bi_io_vec is always multi-page style

- bvec(struct bio_vec) represents one physically contiguous I/O
  buffer, now the buffer may include more than one page after
  multi-page bvec is supported, and all these pages represented
  by one bvec is physically contiguous. Before multi-page bvec
  support, at most one page is included in one bvec, we call it
  single-page bvec.

- .bv_page of the bvec points to the 1st page in the multi-page bvec

- .bv_offset of the bvec is the offset of the buffer in the bvec

The effect on the current drivers/filesystem/dm/bcache/...:

- almost everyone supposes that one bvec only includes one single
  page, so we keep the sp interface not changed, for example,
  bio_for_each_segment() still returns single-page bvec

- bio_for_each_segment_all() will return single-page bvec too

- during iterating, iterator variable(struct bvec_iter) is always
  updated in multi-page bvec style, and bvec_iter_advance() is kept
  not changed

- returned(copied) single-page bvec is built in flight by bvec
  helpers from the stored multi-page bvec

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bvec.h | 30 +++++++++++++++++++++++++++---
 1 file changed, 27 insertions(+), 3 deletions(-)

diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index ba0ae40e77c9..0ae729b1c9fe 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -23,6 +23,7 @@
 #include <linux/kernel.h>
 #include <linux/bug.h>
 #include <linux/errno.h>
+#include <linux/mm.h>
 
 /*
  * was unsigned short, but we might as well be ready for > 64kB I/O pages
@@ -50,16 +51,39 @@ struct bvec_iter {
  */
 #define __bvec_iter_bvec(bvec, iter)	(&(bvec)[(iter).bi_idx])
 
-#define bvec_iter_page(bvec, iter)				\
+/* multi-page (mp_bvec) helpers */
+#define mp_bvec_iter_page(bvec, iter)				\
 	(__bvec_iter_bvec((bvec), (iter))->bv_page)
 
-#define bvec_iter_len(bvec, iter)				\
+#define mp_bvec_iter_len(bvec, iter)				\
 	min((iter).bi_size,					\
 	    __bvec_iter_bvec((bvec), (iter))->bv_len - (iter).bi_bvec_done)
 
-#define bvec_iter_offset(bvec, iter)				\
+#define mp_bvec_iter_offset(bvec, iter)				\
 	(__bvec_iter_bvec((bvec), (iter))->bv_offset + (iter).bi_bvec_done)
 
+#define mp_bvec_iter_page_idx(bvec, iter)			\
+	(mp_bvec_iter_offset((bvec), (iter)) / PAGE_SIZE)
+
+#define mp_bvec_iter_bvec(bvec, iter)				\
+((struct bio_vec) {						\
+	.bv_page	= mp_bvec_iter_page((bvec), (iter)),	\
+	.bv_len		= mp_bvec_iter_len((bvec), (iter)),	\
+	.bv_offset	= mp_bvec_iter_offset((bvec), (iter)),	\
+})
+
+/* For building single-page bvec in flight */
+ #define bvec_iter_offset(bvec, iter)				\
+	(mp_bvec_iter_offset((bvec), (iter)) % PAGE_SIZE)
+
+#define bvec_iter_len(bvec, iter)				\
+	min_t(unsigned, mp_bvec_iter_len((bvec), (iter)),		\
+	      PAGE_SIZE - bvec_iter_offset((bvec), (iter)))
+
+#define bvec_iter_page(bvec, iter)				\
+	nth_page(mp_bvec_iter_page((bvec), (iter)),		\
+		 mp_bvec_iter_page_idx((bvec), (iter)))
+
 #define bvec_iter_bvec(bvec, iter)				\
 ((struct bio_vec) {						\
 	.bv_page	= bvec_iter_page((bvec), (iter)),	\
-- 
2.9.5

