Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32990C43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:16:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC82021B1A
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:16:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC82021B1A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8ABA28E000B; Fri, 15 Feb 2019 06:16:13 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80B468E0001; Fri, 15 Feb 2019 06:16:13 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D5058E000B; Fri, 15 Feb 2019 06:16:13 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3F0788E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:16:13 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id p5so8662246qtp.3
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:16:13 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=l7lN66KMtANDHHviPGwNxorL5gsXHpR77t2q1BoYAso=;
        b=lJHEikDigfbocZ/E2XgchiN9wIh+gCkrzWCWJax8eIQ/sLFQLAhejLkKFNfSRCy29+
         K2yKkZ5+eqU9nVszfcT4hhpNnI2Jq/UWqPuOjFly2gM0hJPWSDg+cTSTDzg+0mRucEtx
         /LCpuOktwFBh7/EHmrBLRUJm99v1NCrhSlDhlvV145oX8V0Hc4wO5w3cot+QkZ2IeQkl
         yXXVM6s/fMWYfXLkPqpJKZfKBH2PHKSPzqd8NS29pSq5kiaFJfDg7hWd3K6cItACn/0q
         iKB2T90EZvIg9H101Lwr3Cf6FO4ZXaSyNJ/AKdbZhxpDLPlRTW9taQaP+jgcL1WmZVhL
         gNHw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubnfM4wuopw26HS7NcX6stnsLufTsJ/eEaviV2xg8ytTJZEjxbm
	UKk5wI152AhDFNkNKribMdiFwMiMn5Dx15j4N+JhPO4bamVr8TUnjdSFBpCMaYGq5aNAGmefnV5
	Co0ddxCVqo6TdCVOkchUB8w1gpgdqH6+v3FbXtQmVQjmV9NJbnv8qOfTiWvHyPDoB9A==
X-Received: by 2002:ac8:7a8f:: with SMTP id x15mr6978944qtr.36.1550229373007;
        Fri, 15 Feb 2019 03:16:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYcJ9eEBAdYUJjN0vbqr18eVGiwt2uUfM8zwpC1P21CXOKhZkjmNW2LA7bixvzp5x6W5ntV
X-Received: by 2002:ac8:7a8f:: with SMTP id x15mr6978921qtr.36.1550229372584;
        Fri, 15 Feb 2019 03:16:12 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229372; cv=none;
        d=google.com; s=arc-20160816;
        b=q3LCPvs53lhEQWgPVa01ahFJ6vsQoCmvzH58O1q6bmJZ3GKTGCxVpd7aDQplvedlyS
         0a/sPkMOhr7j84qJT7WlO7JVrmivxNiZIKWFSWgZtXdah79NIVR3qoQlAhmcHz9NqFiS
         V+gfjxbzbmdDgp+C6ktNEpmJgsReuFlVv1pgjLm/uk5Hq00Vou8QZIxMRptGH9zViY27
         JENK1An1N0lrZU7XKZe+07KBSbQonrbipsfNgqwTNgZMpekEtJ6n8M+uav401boBuCZ2
         UsGm4+S0J0xNjZgoxXl3poAMWolshpygUG3v0xN1W4aLkgn95Lyclkf013f3cnlqLRVv
         wXCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=l7lN66KMtANDHHviPGwNxorL5gsXHpR77t2q1BoYAso=;
        b=KMXO5AWsRw5b1CRbTao9uBF67Vk9fBGHJuwP+aHIUvweufWXinMM8j6Fjjewc0+Dct
         ql+9k18uyMj87c4M6nNZ006DWcnbJQTQAi/vdsXb6JAY1G6P3Wukws0SgHIC9D0rkxyQ
         v5EJa3Tntwwc1eQfhfMscAJlSfDSyYo0QfT0J3B0rbA4eNT8qgMd+M7T3PBqoaGOEqQx
         SwemSCpN/TPwOH7r2mQZOWaUGKvZgyaQwfrJVYv8jXc8RgVQ0BA6G17JM9RWseamwOV8
         J7ltriXI2e5YhdZjzstt1gGjDNqoXxVk8mUPM7OMs1lX2DFBklWDh3Gm8PCT8/1DhXPv
         Gt3A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 132si24964qkg.155.2019.02.15.03.16.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:16:12 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6C8271219DF;
	Fri, 15 Feb 2019 11:16:11 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8D9335F9C2;
	Fri, 15 Feb 2019 11:15:53 +0000 (UTC)
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
Subject: [PATCH V15 09/18] fs/buffer.c: use bvec iterator to truncate the bio
Date: Fri, 15 Feb 2019 19:13:15 +0800
Message-Id: <20190215111324.30129-10-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 15 Feb 2019 11:16:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Once multi-page bvec is enabled, the last bvec may include more than one
page, this patch use mp_bvec_last_segment() to truncate the bio.

Reviewed-by: Omar Sandoval <osandov@fb.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 fs/buffer.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/buffer.c b/fs/buffer.c
index 52d024bfdbc1..817871274c77 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -3032,7 +3032,10 @@ void guard_bio_eod(int op, struct bio *bio)
 
 	/* ..and clear the end of the buffer for reads */
 	if (op == REQ_OP_READ) {
-		zero_user(bvec->bv_page, bvec->bv_offset + bvec->bv_len,
+		struct bio_vec bv;
+
+		mp_bvec_last_segment(bvec, &bv);
+		zero_user(bv.bv_page, bv.bv_offset + bv.bv_len,
 				truncated_bytes);
 	}
 }
-- 
2.9.5

