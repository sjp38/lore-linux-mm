Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B3EBC4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:17:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6238021B1A
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:17:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6238021B1A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E74E48E0004; Fri, 15 Feb 2019 06:17:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFEA38E0001; Fri, 15 Feb 2019 06:17:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC6B48E0004; Fri, 15 Feb 2019 06:17:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB128E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:17:50 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id q193so7695004qke.12
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:17:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=wNodGZU7EcFMVOxNqWEpjAbmpaD39TDM+4us0d0SSCc=;
        b=hDSLTNng2q+TN+V/MBVcNklpn0T9K7rBPtgNWEQGpgbmCzfojNTBGjVtBheQPIUyG8
         cfiu/DJEx8dYcwGJtJSe6EO/9iBDfB19vt0jgM9ZtLpL1ZeozXkiDtOrruRWa1QsD2Yk
         UnR6UNCaAtvlrvqg4sSbEcbT1mEiwLOXm6scpCo+GMIRlLJRDOPJ4B0KgTwdN8mGMUuE
         3F4dWL0HKRe2IB3NMpoD1YS7akAxifYm9ispHIEAF5VCQLdD+NPhmx0RqyUanzO3MpVX
         Mrk/xhTLMahXjnYQWLb1Zrx37UY6+IwQZvgfeIrM7AuyX1Vz0KLIRDNj9tVgQs1FZIIw
         N7Ew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYczx3x0WcyhCN5NgUUipzsG5RPXFAqaqJ8Ruc9WMgU6p/JJ2h7
	r6mKxMplYSjxDr4yETJL/UHPYzfA7eY3nfPdXs9oTw1A8jx3JlzYzx8pJG4I4jAbIIlSp8n/JEi
	2DmLlgwyTOL/5st5voOp/hycHGMMPXaZBTa0E04j0TV3rysjA/SLyU8kHt9uCKaSJMw==
X-Received: by 2002:a37:9b89:: with SMTP id d131mr6290039qke.331.1550229470407;
        Fri, 15 Feb 2019 03:17:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYaKFLaYEAcm2n2nl2cEgDdmU4Ep17kmYWS3qPLpIETRCUOXXPbONP2tgs0J4S9KXMrZEa2
X-Received: by 2002:a37:9b89:: with SMTP id d131mr6290016qke.331.1550229469898;
        Fri, 15 Feb 2019 03:17:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229469; cv=none;
        d=google.com; s=arc-20160816;
        b=kXGQfKLh9MHhbYRFBQACBK0SCx37XVn13QJCKz15AmS0QsAvd7aGkf62aRQqYcMT1G
         PQ9RN64ai9yba0YsPqstj4ZHIWZ0ij5w8P7n9Wp2ucyIsjVvsMrVO1fUgq9iUuT988+M
         Zbj8Vn8TWPT7WnfGowRLQwlwssk9SUYog36qCKjFdSLXKEb0YBSFzSXXmUnFrCd+hV4a
         B6K5PSiiClsgvaKHvbVH4oY/9bYpBmkioDORhy9Hwr4enY8wT0n+zy8Zqb8xBDOXsp4+
         IAyozPVnHyZlbYNhaoUEVWYy2vm665jIzq2fpadiNKEn4ujsgMiFdC6xm0GPhZ9DdezY
         vQrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=wNodGZU7EcFMVOxNqWEpjAbmpaD39TDM+4us0d0SSCc=;
        b=d8gSBh7h+irXknl40fxA4FHI7mzAThR0P+aeWv2fYOX8+Jin5JsCtrqhyt4qiTfgLy
         fYjzHB3rqbQLvn+exfeKhV13L9eupnNEQhOcK1FoQguiJ2CFiwm9ZYJEOe+3fld7sx2S
         ChpOP3RKDlh4eY5dyV7G9l8tA05Te9rLbq13v6LDA1SzGaJgVBkT1j6OBT7SyRFwgk74
         VX0PSvn9fCN9hTW/tsU4QIeveendSzNTOErcNQvRvPjbhWHESVUvXXuWqIZH9uDMfQts
         4mwSNUf4eM7bsgU/s+TUSq+swRHQD6QDbcMf/RGaVIyGogPwMvF7VvBNFajaDN0bmmzD
         Z3zA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g4si3642274qtc.344.2019.02.15.03.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:17:49 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DB8D2124556;
	Fri, 15 Feb 2019 11:17:48 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2F51260F89;
	Fri, 15 Feb 2019 11:17:35 +0000 (UTC)
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
Subject: [PATCH V15 16/18] block: document usage of bio iterator helpers
Date: Fri, 15 Feb 2019 19:13:22 +0800
Message-Id: <20190215111324.30129-17-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 15 Feb 2019 11:17:49 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now multi-page bvec is supported, some helpers may return page by
page, meantime some may return segment by segment, this patch
documents the usage.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 Documentation/block/biovecs.txt | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/Documentation/block/biovecs.txt b/Documentation/block/biovecs.txt
index 25689584e6e0..ce6eccaf5df7 100644
--- a/Documentation/block/biovecs.txt
+++ b/Documentation/block/biovecs.txt
@@ -117,3 +117,28 @@ Other implications:
    size limitations and the limitations of the underlying devices. Thus
    there's no need to define ->merge_bvec_fn() callbacks for individual block
    drivers.
+
+Usage of helpers:
+=================
+
+* The following helpers whose names have the suffix of "_all" can only be used
+on non-BIO_CLONED bio. They are usually used by filesystem code. Drivers
+shouldn't use them because the bio may have been split before it reached the
+driver.
+
+	bio_for_each_segment_all()
+	bio_first_bvec_all()
+	bio_first_page_all()
+	bio_last_bvec_all()
+
+* The following helpers iterate over single-page segment. The passed 'struct
+bio_vec' will contain a single-page IO vector during the iteration
+
+	bio_for_each_segment()
+	bio_for_each_segment_all()
+
+* The following helpers iterate over multi-page bvec. The passed 'struct
+bio_vec' will contain a multi-page IO vector during the iteration
+
+	bio_for_each_bvec()
+	rq_for_each_bvec()
-- 
2.9.5

