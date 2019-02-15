Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C649EC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:17:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D22F21B1C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:17:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D22F21B1C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3030F8E0002; Fri, 15 Feb 2019 06:17:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28C388E0001; Fri, 15 Feb 2019 06:17:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 155C38E0002; Fri, 15 Feb 2019 06:17:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA07B8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:17:06 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id c84so7842557qkb.13
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:17:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=o364efRtKvzLvt+ZEMVS/ez57YOCJqD0TpkJltjZPDU=;
        b=hWatIi5D8NW3TsfPCjzEZG66fWgz3ck/3VS5a/hB0oGxbsg4u9aPtq6dyHpj6l51kM
         XLA3NV+3UH/4pu1qjBbPwZvVMFwzg6wKomMAmZp+vkrg+TqtmvjmJUlOupGmwFUF4Bwm
         kw/DJw18pD8H40p2LsBm5d10Lq9YLFuMQUbMH6vb1wXbdPX7sZAVwhXwMiRw/1dar+V4
         T99PjhVo4QLn7T5VBD682hzSwFkaPHnAKy/NdyoYe1jUvrxrcn++an901Xj6Imtld9/3
         Z0LS8n/Yi1f8ezJj207z3/jEeVH83uzU3ULKTvzJdpuWBlUiv9JUcQt/NyYIDWC9azya
         dQWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuagRRxlhFdb9e0hL97Gx1aj997ZR/kQMjLTQXKvbMNPI0waOZgr
	2HnF3j5bvSeSwM8dp207tv5eLw5CjFbFvhRqCks3aNIFfflpcSFUJQNDZsOE5JwOf8gsfPfki8F
	9qAZfIehPBGS2MZRDDaFbjQNhdz/Tju/bY7NxvjTv1ut+XR6bB78UyKg0+3CBYGfAIw==
X-Received: by 2002:ae9:dec5:: with SMTP id s188mr6486385qkf.127.1550229426635;
        Fri, 15 Feb 2019 03:17:06 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia38Ovd3GR/jWWT6P1/njYIqJtl8wlqvlUL78hV7D5OqQ/JpR/rSjaSekMSZ1B04rUDMqTJ
X-Received: by 2002:ae9:dec5:: with SMTP id s188mr6486345qkf.127.1550229425975;
        Fri, 15 Feb 2019 03:17:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229425; cv=none;
        d=google.com; s=arc-20160816;
        b=T+GW/hkSEt/OalOJMXs64pu0WZqirX/In2z3S2gt4xwLbfcXTTNzekmBx6g8NhiP7m
         pubwzv77fimIgN5yyxnrOb7+7MnWwzT85StAxd5jmFiC0QjsBOxG77BRlppO9XfHHnd3
         KgiMdoFFBWAyDgRZVu0SdXnjDRcyT9dUugAgKThzBUclvGaA2JFlQEfKR2EuTzg9ybxG
         35rN3Wx41M8+VJ1w49JdFW7QlaJKtLjziyRThOR5NHAvxmoIYm7pDEmd6tR2K70DUUrl
         Sics4qIITBGflbzRVqB/gbsG7R0B5ZYCyk6M10t1DNGDEER4gshdaxLOhJqARdCBDOrE
         M4PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=o364efRtKvzLvt+ZEMVS/ez57YOCJqD0TpkJltjZPDU=;
        b=vzbW+KUu8791jPKjFehbnFBblvH+H2Rs7EVTYLd2FuscjbZOV0FfcYfDyM/6wtdAL7
         L7eDFsrvWT9v0pTt9w1T7LjsV6YS/4BAnEU+cwASQdilkTLMOttaUQAFaB4DbUrFW1Um
         phyavA5ByPaXvLUvI+WZJu5aFh/8O8c8WpicjcqijVYapr3d/mg+KSoyLsFPWZdlezHY
         2NY6UVhQTtkNHRZThGYrSJrbbRGAQvjTvwVew8VzO3GybAp23L7jZcqa8uF+afAcT+Es
         9SbjmGSwXs9Fw5UydX3mEQiwgCPpifIJcu/EaIpcNoVKXDdTZf6N3wv5JivX+0gNrQpi
         0QQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f12si303816qvh.98.2019.02.15.03.17.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:17:05 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 826C08E6E5;
	Fri, 15 Feb 2019 11:17:04 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C61CD5D6A9;
	Fri, 15 Feb 2019 11:16:43 +0000 (UTC)
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
Subject: [PATCH V15 14/18] block: enable multipage bvecs
Date: Fri, 15 Feb 2019 19:13:20 +0800
Message-Id: <20190215111324.30129-15-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 15 Feb 2019 11:17:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch pulls the trigger for multi-page bvecs.

Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 block/bio.c         | 22 +++++++++++++++-------
 fs/iomap.c          |  4 ++--
 fs/xfs/xfs_aops.c   |  4 ++--
 include/linux/bio.h |  2 +-
 4 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/block/bio.c b/block/bio.c
index 968b12fea564..83a2dfa417ca 100644
--- a/block/bio.c
+++ b/block/bio.c
@@ -753,6 +753,8 @@ EXPORT_SYMBOL(bio_add_pc_page);
  * @page: page to add
  * @len: length of the data to add
  * @off: offset of the data in @page
+ * @same_page: if %true only merge if the new data is in the same physical
+ *		page as the last segment of the bio.
  *
  * Try to add the data at @page + @off to the last bvec of @bio.  This is a
  * a useful optimisation for file systems with a block size smaller than the
@@ -761,19 +763,25 @@ EXPORT_SYMBOL(bio_add_pc_page);
  * Return %true on success or %false on failure.
  */
 bool __bio_try_merge_page(struct bio *bio, struct page *page,
-		unsigned int len, unsigned int off)
+		unsigned int len, unsigned int off, bool same_page)
 {
 	if (WARN_ON_ONCE(bio_flagged(bio, BIO_CLONED)))
 		return false;
 
 	if (bio->bi_vcnt > 0) {
 		struct bio_vec *bv = &bio->bi_io_vec[bio->bi_vcnt - 1];
+		phys_addr_t vec_end_addr = page_to_phys(bv->bv_page) +
+			bv->bv_offset + bv->bv_len - 1;
+		phys_addr_t page_addr = page_to_phys(page);
 
-		if (page == bv->bv_page && off == bv->bv_offset + bv->bv_len) {
-			bv->bv_len += len;
-			bio->bi_iter.bi_size += len;
-			return true;
-		}
+		if (vec_end_addr + 1 != page_addr + off)
+			return false;
+		if (same_page && (vec_end_addr & PAGE_MASK) != page_addr)
+			return false;
+
+		bv->bv_len += len;
+		bio->bi_iter.bi_size += len;
+		return true;
 	}
 	return false;
 }
@@ -819,7 +827,7 @@ EXPORT_SYMBOL_GPL(__bio_add_page);
 int bio_add_page(struct bio *bio, struct page *page,
 		 unsigned int len, unsigned int offset)
 {
-	if (!__bio_try_merge_page(bio, page, len, offset)) {
+	if (!__bio_try_merge_page(bio, page, len, offset, false)) {
 		if (bio_full(bio))
 			return 0;
 		__bio_add_page(bio, page, len, offset);
diff --git a/fs/iomap.c b/fs/iomap.c
index af736acd9006..0c350e658b7f 100644
--- a/fs/iomap.c
+++ b/fs/iomap.c
@@ -318,7 +318,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 	 */
 	sector = iomap_sector(iomap, pos);
 	if (ctx->bio && bio_end_sector(ctx->bio) == sector) {
-		if (__bio_try_merge_page(ctx->bio, page, plen, poff))
+		if (__bio_try_merge_page(ctx->bio, page, plen, poff, true))
 			goto done;
 		is_contig = true;
 	}
@@ -349,7 +349,7 @@ iomap_readpage_actor(struct inode *inode, loff_t pos, loff_t length, void *data,
 		ctx->bio->bi_end_io = iomap_read_end_io;
 	}
 
-	__bio_add_page(ctx->bio, page, plen, poff);
+	bio_add_page(ctx->bio, page, plen, poff);
 done:
 	/*
 	 * Move the caller beyond our range so that it keeps making progress.
diff --git a/fs/xfs/xfs_aops.c b/fs/xfs/xfs_aops.c
index 1f1829e506e8..b9fd44168f61 100644
--- a/fs/xfs/xfs_aops.c
+++ b/fs/xfs/xfs_aops.c
@@ -616,12 +616,12 @@ xfs_add_to_ioend(
 				bdev, sector);
 	}
 
-	if (!__bio_try_merge_page(wpc->ioend->io_bio, page, len, poff)) {
+	if (!__bio_try_merge_page(wpc->ioend->io_bio, page, len, poff, true)) {
 		if (iop)
 			atomic_inc(&iop->write_count);
 		if (bio_full(wpc->ioend->io_bio))
 			xfs_chain_bio(wpc->ioend, wbc, bdev, sector);
-		__bio_add_page(wpc->ioend->io_bio, page, len, poff);
+		bio_add_page(wpc->ioend->io_bio, page, len, poff);
 	}
 
 	wpc->ioend->io_size += len;
diff --git a/include/linux/bio.h b/include/linux/bio.h
index 089370eb84d9..9f77adcfde82 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -441,7 +441,7 @@ extern int bio_add_page(struct bio *, struct page *, unsigned int,unsigned int);
 extern int bio_add_pc_page(struct request_queue *, struct bio *, struct page *,
 			   unsigned int, unsigned int);
 bool __bio_try_merge_page(struct bio *bio, struct page *page,
-		unsigned int len, unsigned int off);
+		unsigned int len, unsigned int off, bool same_page);
 void __bio_add_page(struct bio *bio, struct page *page,
 		unsigned int len, unsigned int off);
 int bio_iov_iter_get_pages(struct bio *bio, struct iov_iter *iter);
-- 
2.9.5

