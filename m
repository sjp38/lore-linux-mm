Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 212BDC10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:14:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA79E21B1C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:14:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA79E21B1C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8AC208E0005; Fri, 15 Feb 2019 06:14:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 85A7D8E0001; Fri, 15 Feb 2019 06:14:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 770778E0005; Fri, 15 Feb 2019 06:14:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4DBF28E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:14:41 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id e9so7714418qka.11
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:14:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=SN4quS8rBSk+7OkD/UQdCM5DjNZfyv3PfpiunvnHKgo=;
        b=PpG3pIajnBXhZHJ/APZ8VSIEp0WZmpl5R8OB5A4Jx1Cvg+dQik+ZU7ByCZ016sFlWY
         p0waPHrlBrIEAl99nhM8tPSgdWIZIh+Mft7hZ3cv2RHG5Z2T0GVz9qMAgsC7VXTvGFC+
         +QqMlivQeLfCDKEsmBXn5wxZVHbSmlYh0ILqKcaXuwZPoffaSiGWdt+9E1YhBvyR3qRx
         TpSVcOWXnwsv9LUWMWBYbdB3OYS7xIFqkGMq/7D/pcNxuMCPaJiTg8Ga/26rPU0UYIOn
         HID+bZGpjfgZxrgQFOoegfDI1cor2KdtvdIeDHzoJP/0JvnpttAGV0z57s7xtE3OiD/Z
         nGsQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaRX0HtpMZMYkmDFkDSniPr/upqM9+fMPqfrpWSCreMA2lwHQwo
	n+ILj49HCwwU+9FlN/tvh1cKqW3cRLxFe7hbUCC4lkWM+La8bC8FDg9VkFJ6c9Pq9CLnOxk2iWx
	J2U6JHO6NB9b8v4UWYMb9xKu/zJ7psOSOXeCeAtRTx08YTJ30MH3ndWTIO8I0B5DJQA==
X-Received: by 2002:a0c:d1f4:: with SMTP id k49mr6916346qvh.164.1550229281106;
        Fri, 15 Feb 2019 03:14:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaqgF65hN8bEwWC7DjGj2fepcQBAwaXRS8UuVpuHgllHnng46cwHiUq/mVjH+G499NOV0kR
X-Received: by 2002:a0c:d1f4:: with SMTP id k49mr6916325qvh.164.1550229280697;
        Fri, 15 Feb 2019 03:14:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229280; cv=none;
        d=google.com; s=arc-20160816;
        b=F1TlHL6N5fOd5UfTntxmCsjVmv3ynFhGYGvxTalXx1lRJS+yDc+wrd9RoLxXmOwtP4
         SU/T0/oey4gOb/Xs3EDBsAnuMUz6QVdc3LYP0B3Ee7ZaqhRuNg1NTWBZLHon0OD3w/1Z
         58hj1dPeJ1sJ4h1sl0+fC5AspF2dVW/oY4Om2XQFMin3SxICsCLQ4j6Gokep0a8gCtKK
         OCLS0bTtVERGZmtc+hKQAq/4+gF8xBnoY9Pr6ilmGiQ1kf03uA7zg5f857tZ52+qLWoP
         wa1zVUPiTt3sOtIDCMEx0GtZMzyhz0gRgRmM55e7UgVHX2IOP13xnH3msvOxup/wfBFt
         lBFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=SN4quS8rBSk+7OkD/UQdCM5DjNZfyv3PfpiunvnHKgo=;
        b=YBexlKpRPeEq7+Fsp46jRKM1qYlkhyIm3MWPadjiUYHCJkCuJZbdtEwNiRAH0h0xhS
         syJr4xMOF/x0DfkENI4xHHRv/+sMN5isJb9WbfYuVJmq1b0/zDQopiVOO0kt92sEfv/q
         C6SvwH+GUTDEy197JJHthwhrtUW17Gb/W1TBfdWGHdF2cOfJrn8EqPPDMu1MV4jTv/CN
         DYzb++dHJU4UTt/VWqLj+mwUmbcACh77PnGrajut0RgBL+fDhV56HXi68bHrUdcTFx2t
         E6lg09uP/rQwl/TEtUl1zHk/ztCeUUcTdqmGxzGSOHh3J+uXXU7QxJFHrgAkFJbdLQmY
         gDkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l22si2318267qtk.384.2019.02.15.03.14.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:14:40 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9A4FB2FE56E;
	Fri, 15 Feb 2019 11:14:39 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D72B560C62;
	Fri, 15 Feb 2019 11:14:18 +0000 (UTC)
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
Subject: [PATCH V15 03/18] block: remove bvec_iter_rewind()
Date: Fri, 15 Feb 2019 19:13:09 +0800
Message-Id: <20190215111324.30129-4-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Fri, 15 Feb 2019 11:14:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 7759eb23fd980 ("block: remove bio_rewind_iter()") removes
bio_rewind_iter(), then no one uses bvec_iter_rewind() any more,
so remove it.

Reviewed-by: Omar Sandoval <osandov@fb.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bvec.h | 24 ------------------------
 1 file changed, 24 deletions(-)

diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 02c73c6aa805..ba0ae40e77c9 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -92,30 +92,6 @@ static inline bool bvec_iter_advance(const struct bio_vec *bv,
 	return true;
 }
 
-static inline bool bvec_iter_rewind(const struct bio_vec *bv,
-				     struct bvec_iter *iter,
-				     unsigned int bytes)
-{
-	while (bytes) {
-		unsigned len = min(bytes, iter->bi_bvec_done);
-
-		if (iter->bi_bvec_done == 0) {
-			if (WARN_ONCE(iter->bi_idx == 0,
-				      "Attempted to rewind iter beyond "
-				      "bvec's boundaries\n")) {
-				return false;
-			}
-			iter->bi_idx--;
-			iter->bi_bvec_done = __bvec_iter_bvec(bv, *iter)->bv_len;
-			continue;
-		}
-		bytes -= len;
-		iter->bi_size += len;
-		iter->bi_bvec_done -= len;
-	}
-	return true;
-}
-
 #define for_each_bvec(bvl, bio_vec, iter, start)			\
 	for (iter = (start);						\
 	     (iter).bi_size &&						\
-- 
2.9.5

