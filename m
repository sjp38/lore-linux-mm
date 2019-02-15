Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A870AC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:15:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 66E6521B1C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 11:15:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 66E6521B1C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 157B78E000A; Fri, 15 Feb 2019 06:15:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 106B28E0001; Fri, 15 Feb 2019 06:15:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3C258E000A; Fri, 15 Feb 2019 06:15:52 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC1A08E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 06:15:52 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 65so8485804qte.18
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:15:52 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=UPqY5b1JqVkM1npPaeOz/GFx2XqKiaYkjhq3oYeVa/0=;
        b=EQha5vmxHqnN/duaFCczJ/1Z/lq1mOXYn3FSQQjE8e8aIV7uE/gvI30bRBDR1Gcnhx
         1Fosv3bCOj0RG5ba74wBnPKfgux3OAe1KtqMRl3eSyfJkt9TM/gc/HPg5YiH3Wb+Ftf2
         I+fxQhh/fcoxxTAi8DJlRMhyhNRYeo3TowHpBhkfbIiEq9hrrO2xSOaqlRKzfi22xqKg
         nenDaYgDhVHX44vNhakoCyHi97LRHaOHSo8Wf271tRI1AdvyDdRHq7fIUgBHl2xhcNDH
         KmB0y9f+q4u2gLq+oQ3E2HJ0fRC86DUWDEdrdTg+ovh5kL5UPfKTBlD1ZrGlJc0CcAq0
         j4XQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYaFHgDiLf2fYCqPpQHTVDsRMK7FzH2eZ6d3hdtlDlD9s9TGLeP
	LOTnUJx3b8whBfiEceZ8RUfzkjsCF8lSJghTK657+NtFQftt6Q3kabgehYodiEGDHXNRx2b6WEu
	FWaeiRv/1khhSYegbiEh5dnpWoxOOsCfpZ5JNhzdg2NNkqULbzs+g+w1TuhRk4dVvwQ==
X-Received: by 2002:a0c:ae76:: with SMTP id z51mr6910611qvc.103.1550229352603;
        Fri, 15 Feb 2019 03:15:52 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY/vN+8lUgfupCwOVsoNZSiHK6VJSDktrqcgbVpaDi3FGSCaIlLv9rFuY9VjUEUCaN81B3b
X-Received: by 2002:a0c:ae76:: with SMTP id z51mr6910580qvc.103.1550229352100;
        Fri, 15 Feb 2019 03:15:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550229352; cv=none;
        d=google.com; s=arc-20160816;
        b=gf3Vjavu6hB4sSEPXhFabOVw9WSLSgH88zdmY19ApjPPqD7EIpix5ZTrM5jvDwItY6
         BtkBXxcOX6SHEKpu6BNOfuF3pLsilzrZcAX/b37ab6XQOgWVgg7aL574W0sCMg3kg8mC
         ElLBJL4qVJ+xvLwbPrOXBy4XdsN+h4JocJqIYi9pSbEIEVe5b7LC82eu0p09BaqltyeI
         vxWROVZWkPQBkZBFCnrzSKOXTK07aGcLLUscZgWdznW7lE91XXloYxA55G7auRYiwZs/
         V9zqha2iUPgUSQI1Khtu7GTaDoh3nffgFPZqq0n5Gx6bhtU5Yi1aJr0hbXIcdyQi4XFQ
         RNkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=UPqY5b1JqVkM1npPaeOz/GFx2XqKiaYkjhq3oYeVa/0=;
        b=HSwSVUNO+cJKJDgyeagAy3oe0C4icJoYttNIk38yzUWrWJswc04uYzTmVsOu0O2cqB
         a2bF7XrvsUMdWdFzDicNUwEA6MLfjUn2xYJokSMwpAA4/jgXohYHcwWP+AZ+nfyW9mLl
         C8YVI+E1gF4qtcxgmaTtHl05RQRK+wlyULPplSAwHGn33Byptfi5pGdtBLsxeUDVXrny
         B8LxUQMAGLqb3MNzVM9jWxYn79cPYEI2uWDS8JYtN6tRr6BKT+yQ6FPu3FsDMzkIQ+tH
         AMKSVvkRpa2cYjPLG6YKwdjSS4UtmM5GTqDhrPEPb4GviPAYblW8gVK/hXmLRH6XYYkB
         vdOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o4si551284qti.312.2019.02.15.03.15.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 03:15:52 -0800 (PST)
Received-SPF: pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ming.lei@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=ming.lei@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F39521244C3;
	Fri, 15 Feb 2019 11:15:50 +0000 (UTC)
Received: from localhost (ovpn-8-22.pek2.redhat.com [10.72.8.22])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 312215DD6B;
	Fri, 15 Feb 2019 11:15:49 +0000 (UTC)
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
Subject: [PATCH V15 08/18] block: introduce mp_bvec_last_segment()
Date: Fri, 15 Feb 2019 19:13:14 +0800
Message-Id: <20190215111324.30129-9-ming.lei@redhat.com>
In-Reply-To: <20190215111324.30129-1-ming.lei@redhat.com>
References: <20190215111324.30129-1-ming.lei@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 15 Feb 2019 11:15:51 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

BTRFS and guard_bio_eod() need to get the last singlepage segment
from one multipage bvec, so introduce this helper to make them happy.

Reviewed-by: Omar Sandoval <osandov@fb.com>
Signed-off-by: Ming Lei <ming.lei@redhat.com>
---
 include/linux/bvec.h | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/include/linux/bvec.h b/include/linux/bvec.h
index 0ae729b1c9fe..21f76bad7be2 100644
--- a/include/linux/bvec.h
+++ b/include/linux/bvec.h
@@ -131,4 +131,26 @@ static inline bool bvec_iter_advance(const struct bio_vec *bv,
 	.bi_bvec_done	= 0,						\
 }
 
+/*
+ * Get the last single-page segment from the multi-page bvec and store it
+ * in @seg
+ */
+static inline void mp_bvec_last_segment(const struct bio_vec *bvec,
+					struct bio_vec *seg)
+{
+	unsigned total = bvec->bv_offset + bvec->bv_len;
+	unsigned last_page = (total - 1) / PAGE_SIZE;
+
+	seg->bv_page = nth_page(bvec->bv_page, last_page);
+
+	/* the whole segment is inside the last page */
+	if (bvec->bv_offset >= last_page * PAGE_SIZE) {
+		seg->bv_offset = bvec->bv_offset % PAGE_SIZE;
+		seg->bv_len = bvec->bv_len;
+	} else {
+		seg->bv_offset = 0;
+		seg->bv_len = total - last_page * PAGE_SIZE;
+	}
+}
+
 #endif /* __LINUX_BVEC_ITER_H */
-- 
2.9.5

