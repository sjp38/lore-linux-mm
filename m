Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3ECBDC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:16:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ED27521B1A
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:16:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ED27521B1A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96D6E8E000C; Fri, 15 Feb 2019 06:16:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F5F08E0001; Fri, 15 Feb 2019 06:16:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7BF0C8E000C; Fri, 15 Feb 2019 06:16:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4228E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:16:17 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id a199so7662803qkb.23
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:16:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=QsyyCrPYM4mSQKLdRXgny5EZIKPBaVsU+ab/s6p3Gys=;
        b=HjCrG0WvzxY7TD5V2hBMJv3rXAQTYfOjZKok7DyZ9skprkzbzxVZ9iuRfc1CH2hSjS
         TTbgLk5iCbprJGJdNXM9WyBLWb0yBUuUGVZS0xdabwyUO/pWwZ1h0pO3o6lrBoJaXR4A
         rM6LdBEddQHZ2a3FNgjQEtY+mGhNs0bcqR+ppULEDSzjlZ0VUPme7AvNFbX+W3+NIWuN
         mmF/fCdwqljwlPa1/9JIGCwi1UMOoq/iwl3mLLPGfU7kANfSHroJI5eGWFvgQt+RqLOM
         eWKZCjSr4DEUbbvH+jfNwF4ptfuy3P6C2axpfwhqdbKh6DOZRA5ehyqdwBTNFjcyBTku
         W++Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuaf2rPJCubmAVRVmM3c1nCfNjZNaoOEQdaTjNx2G6DQGBdXDr4R
	+8SjRB9BoeVEnLSkSQNwJ0tTTl1NWVZCok5o8xe+m7mORDjgEfY0sp9MAYH1Hzxg8h2h+mzCGIw
	q4Tjl+2KHoT9BssGfQqAOzeTbbV+YlrO1PbjLFdz+OWS6A/oYb4ty2200CPBc68bHgg==
X-Received: by 2002:ae9:ddc3:: with SMTP id r186mr6531868qkf.163.1550229377105;
        Fri, 15 Feb 2019 03:16:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibw2DDDE18GImCftpz1KZ+IjTfcxi5G83X+ajSvabQ+5YmY125OoJO2OiofJbf+IgZC/kUT
X-Received: by 2002:ae9:ddc3:: with SMTP id r186mr6531838qkf.163.1550229376623;
        Fri, 15 Feb 2019 03:16:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229376; cv=none;
        d=google.com; s=arc-20160816;
        b=NN5Atc3yoL0yrjX2zADRQ3K2zz+z1vawlftJGin5CVD/VRKULoiSMlPk32wC/KDEKQ
         ujOWWmOAPWAUyCh/U8bZAiHcwVd2tCATdmVrWzIYh+OLRqdCcSbvOXcV8Q92ovqADKIN
         d0fEyT8BlW2ota/HySiGzj5hjYwrKgbm42+QRYGENgSzD1vAq42mArRk5JUq650F41g7
         T9PXsq+EocBe8zuUI3AsAuDLhBIn6wQK0ZtFxS34blRHRsqtc4mQSBrDrJOpl5Evqhs6
         NOeNiypGD6+1YRPCNn5h6cguVqrK96ZnrIqG4zwUacvlUwyC8RKahFak4Vi88hh42qGB
         pTxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=QsyyCrPYM4mSQKLdRXgny5EZIKPBaVsU+ab/s6p3Gys=;
        b=yHJ8q0r1u6YYHEFJubYhYF5YsTc+87Xh0n3kdh+Su/tnu72pXAjvGOr3VYWaBsqc5I
         bbtHB4JV3TCcBNzHclOu2kZy/9m3suCgHelC2QzSogDUFFdXQ2jyCvr2WNMR1mC3UqJK
         beTGAtH9ZpIErdrpxozS6adJFKpTqW6yO2bNYRxOKYRYPeqkEn05e5RlB+876iyZBZZB
         5QfHnxcDmPmsd8+SdcWGLwEjR7K+aW/OhZLMKg7sO6ejP7HvWeZvoDUNaASB5wTuHAfI
         1+3ppeKrOOzZ3s1caqg+3FUxqJQ1NJpQynckptc/TPxThH9fYawBgyRvFhjrwloo7BGC
         A+lA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w3si3355857qth.85.2019.02.15.03.16.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:16:16 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0CEA2C0AD406;
	Fri, 15 Feb 2019 11:16:15 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 077AD60A9C;
	Fri, 15 Feb 2019 11:16:13 +0000 (UTC)
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
Subject: [PATCH V15 10/18] btrfs: use mp_bvec_last_segment to get bio's last page
Date: Fri, 15 Feb 2019 19:13:16 +0800
Message-Id: <20190215111324.30129-11-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 15 Feb 2019 11:16:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Preparing for supporting multi-page bvec.

Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/btrfs/extent_io.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index dc8ba3ee515d..986ef49b0269 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2697,11 +2697,12 @@ static int __must_check submit_one_bio(struct bio *bio, int mirror_num,
 {
 	blk_status_t ret = 0;
 	struct bio_vec *bvec = bio_last_bvec_all(bio);
-	struct page *page = bvec->bv_page;
+	struct bio_vec bv;
 	struct extent_io_tree *tree = bio->bi_private;
 	u64 start;
 
-	start = page_offset(page) + bvec->bv_offset;
+	mp_bvec_last_segment(bvec, &bv);
+	start = page_offset(bv.bv_page) + bv.bv_offset;
 
 	bio->bi_private = NULL;
 
-- 
2.9.5

