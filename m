Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C3BDC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:17:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2996421B1A
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:17:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2996421B1A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D16EB8E0003; Fri, 15 Feb 2019 06:17:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC6518E0001; Fri, 15 Feb 2019 06:17:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B8F9C8E0003; Fri, 15 Feb 2019 06:17:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0508E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:17:35 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id a199so7665010qkb.23
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:17:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=aF6gUNu009UZpBqyr2snXpzRNTFx8cnDNBm84vQPuaQ=;
        b=Ht30F7QHVydPOzN0vXzx183UVgFqLYdyW4TzUE6obzFCtw9l/oCJ+Uuy/bNtbzaJiy
         oQsL+aRmgg6HwSTKbIr/NEE9jBQ/L2fwFd+fAeJwKhze16TFKx/V8YqfbSgcFHh353sG
         ElOomeTnb/0Ivxmw3XvLTixuY9bAMdhbcriqDgDuPVhw91AC/BN36MGPMixkhfh2Dy2B
         nIXkrldwzHR0Ov5AOe3HTdVJM25APRwJgSQ8/qIZLbfrVa1fAvzm2rAhBpPH7QKJjhmn
         7uDGtg3ATVxbSDv8nDXb93t5vgXIg+vHEp2sgzt6bSXVYB3yPg0yctBbN1EBCGLcrew0
         btYw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZDmozpZB4RPX3rZjCw/qOVvcBhCDRg26d5XLyFGGMBdSbKgZFL
	XND6gR68G+NLzX3ga0Drpx4halZG/ao3IsyPjT53vLZnsTvLSl/0YabAUS5x4O8NNtQ3LSuCGtc
	5zbxhaB4DmbHvtk9SHCSbbe8HmlQxzHUMOP0pLocntkx3fstkjTtyyQBGnaifN7Ok9A==
X-Received: by 2002:a0c:ae76:: with SMTP id z51mr6916069qvc.103.1550229455354;
        Fri, 15 Feb 2019 03:17:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZBOoxnicAsaZtL6NI7f95yF2uzvafo3I8dozuvm0AqgWxJaNTO/swTncxh8u7qbDDX6fnx
X-Received: by 2002:a0c:ae76:: with SMTP id z51mr6916051qvc.103.1550229454945;
        Fri, 15 Feb 2019 03:17:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229454; cv=none;
        d=google.com; s=arc-20160816;
        b=aZFHLxqzhNgCOAiPjRA1DjvQiJWX1+aMq4X55FG/fdfHL8a+S0itsZcOIRwvh/ppwL
         aJr9Ic08SCDMl6r/98YIVQNR6qf6lI8Fam6KEPdmm1cwu/IWLDZXwjrLOIF/Or9vR4S9
         /K3JNb8ML0jUyEChP2OBc+V5fCt/lwBVd9TTaQPHq84dqwutk18R2f81L+1Xk66Z60qw
         kALmsNw9QQgIRsJ/MSYPsg7JFPj6p37rOhU8u+YOusiQE7P0mFJYatwgf+gFKdVQs6K4
         eAbtk9X5U5UucMewNa2gFpQyByDS2DXZV+ADCw/i73INn3DZeir3ZYw8bKxgH5AVBwO9
         d29A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=aF6gUNu009UZpBqyr2snXpzRNTFx8cnDNBm84vQPuaQ=;
        b=xhHIF+GjaJl8nz33yARV9jZVLPRq+BNxGPG5oKmmODaJmqUrtOutvX0B55zPp1JsFq
         dKDZmvlSGSBd7yHE+mjCHYAuA2d9csrC67AINj2z1G1hzEMPGenNsWDX2ilN0ITQXACo
         quX657IoxBpShiKLklZ8NB35AQDDsis7KG6wUmLZhWU/S/ndbSWdv+OcbblqC/VDQA/u
         /fhvKgy5Y5E3jp+5raIB9x/m79F1kP4CjcE0Awv884pQeRXTlpKPrPMYcXrM38k3WykK
         T6NpXXe61/7ZOLIy+dSorVRFk1J8x1QvIunOa9dx3GPyVQx6q1myQ/y8vcplGRuDiLvE
         5KmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d39si604845qvc.142.2019.02.15.03.17.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:17:34 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ECFE6C0AD406;
	Fri, 15 Feb 2019 11:17:33 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9B90A26E74;
	Fri, 15 Feb 2019 11:17:06 +0000 (UTC)
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
Subject: [PATCH V15 15/18] block: always define BIO_MAX_PAGES as 256
Date: Fri, 15 Feb 2019 19:13:21 +0800
Message-Id: <20190215111324.30129-16-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 15 Feb 2019 11:17:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now multi-page bvec can cover CONFIG_THP_SWAP, so we don't need to
increase BIO_MAX_PAGES for it.

CONFIG_THP_SWAP needs to split one THP into normal pages and adds
them all to one bio. With multipage-bvec, it just takes one bvec to
hold them all.

Reviewed-by: Omar Sandoval <osandov@fb.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bio.h | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/include/linux/bio.h b/include/linux/bio.h
index 9f77adcfde82..bdd11d4c2f05 100644
--- a/include/linux/bio.h
+++ b/include/linux/bio.h
@@ -34,15 +34,7 @@
 #define BIO_BUG_ON
 #endif
 
-#ifdef CONFIG_THP_SWAP
-#if HPAGE_PMD_NR > 256
-#define BIO_MAX_PAGES		HPAGE_PMD_NR
-#else
 #define BIO_MAX_PAGES		256
-#endif
-#else
-#define BIO_MAX_PAGES		256
-#endif
 
 #define bio_prio(bio)			(bio)->bi_ioprio
 #define bio_set_prio(bio, prio)		((bio)->bi_ioprio = prio)
-- 
2.9.5

