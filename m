Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3DACC48BE0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:24:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F4652084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:24:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F4652084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DD798E000C; Wed, 19 Jun 2019 22:24:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28F1D8E0001; Wed, 19 Jun 2019 22:24:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A61C8E000C; Wed, 19 Jun 2019 22:24:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0EAA8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:24:47 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x10so1686704qti.11
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:24:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=e7eX1RveEOqtNN+ZGUkmQs0zHK+DZjZtAYbM/evoIws=;
        b=SESNwjZ5G/2cFxstyS7qt2sufNHrfouWZNtH0xjVeNXfbTYbQtBc+PbaFyQnV8jODh
         iEGI6O7pbIeWk/DRe75zEIUL9EEMsvhbPYQz5ME73npNd7L5rW2BJOsUrYKh3dqXL3U3
         JIxvzWQGh6hYGXuxN77xoE36LQZpfG/SQYDaPwbOXaFYBWcX0CQ9DHh8vbwpNjqEsgIo
         UYQHl6NBwL8no6uLf11V6vT+e7UwWmqwBx+Yha9C0dBBXNWt39B+XLZEd0qAB00ai5oh
         nmdB0Br7KPnO+2pbhjSBfeKF2XfNYPDzYh0IIzvb3Omm++sLMfjKt7zAmWMf1qnS4pjL
         aPSA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUyb3j1p5K/nkJk1Paggu35duWZ4OFnDoW0u1JJsUTJ1dmm31yZ
	S7/B4esaimCNcYKn5+XfiRDNeQy6DCPvX+QaOxDY79hBuaVkxBV4CVqm5ZWjMMc9wxYDwGzllBC
	/PhtBasPYnvuP39rQsPno8ugzIFY/zkGtA2zZeJfDqidZZRLFe5hogU6XpS+SJpG3IQ==
X-Received: by 2002:a37:dcc4:: with SMTP id v187mr103992184qki.290.1560997487766;
        Wed, 19 Jun 2019 19:24:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTrEz534li7eVYKp7LtSzLsKito2REI0+FPk9JWjUkAw1Ie1dwqXZEtLCt6FlD/M3m6u4g
X-Received: by 2002:a37:dcc4:: with SMTP id v187mr103992137qki.290.1560997486994;
        Wed, 19 Jun 2019 19:24:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997486; cv=none;
        d=google.com; s=arc-20160816;
        b=KO06zDPiZ3+eKxD9wMZvYqC53MTTLl57luqGt2VE+IoKR/pY5T++NgBhB01UZU9w6Z
         oVVqYbGOqIcjIT6Pc+XtiM8A3xW+FpRMR9gRl2z/3v2NRlgtDFQVBwyOLSsD6r63d0vm
         T2B8GNl8LGMp4Du6QoVFOySZr0pGHfYIzTSgfnToPUsLGEZoC5q2Vd/xOqasHAF/flqF
         m9i1ApqRHjpd5f7b9jGgvKUvD2GspNLUmB3IkyNXw2YlvP3mWkoaOlm3JL/QaQIqfD3d
         nRaijGOfFQV8ZImIQ9dPidcXmWK8h99lkOwn2rG8yotIV5NNvyHL/83h/4XAk2UQxtO6
         Q+8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=e7eX1RveEOqtNN+ZGUkmQs0zHK+DZjZtAYbM/evoIws=;
        b=jAky8OS8QxJNxEpknFpwsha6440DduxxLWkbWEow8biMLSCv7X7Etw0vT+2OByx8Pw
         W44u9kVOrcRPjLoiipneTjzS420r1ZpAmx59vsecw9SbnxrQ8hkoLo1CQwEIYQFpSjmV
         9dJ1EVGZLxmisVIJUvD5TPdaucs+sSDVajIja7qPlE/3sV7nLr9IeFRINH6FJ6/vAA6s
         HcH7x93A1RHYnvG7cyGAoR0kUUaveC9g6Z0jouDmLuxOfNj4Qa07OU0x/cW8j7m10dDb
         q7OlIbxSVGDZKr4YpiuWLI2LOsfHzd4LV7xE1F5QPPqgYU8B95Xhd1iu7QnABoQbdEtz
         dEjw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r188si13046123qkb.263.2019.06.19.19.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:24:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 354BF307844A;
	Thu, 20 Jun 2019 02:24:46 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 899C21001E6F;
	Thu, 20 Jun 2019 02:24:38 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v5 21/25] userfaultfd: wp: don't wake up when doing write protect
Date: Thu, 20 Jun 2019 10:20:04 +0800
Message-Id: <20190620022008.19172-22-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 20 Jun 2019 02:24:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

It does not make sense to try to wake up any waiting thread when we're
write-protecting a memory region.  Only wake up when resolving a write
protected page fault.

Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 fs/userfaultfd.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 3cf19aeaa0e0..498971fa9163 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1782,6 +1782,7 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
 	struct uffdio_writeprotect uffdio_wp;
 	struct uffdio_writeprotect __user *user_uffdio_wp;
 	struct userfaultfd_wake_range range;
+	bool mode_wp, mode_dontwake;
 
 	if (READ_ONCE(ctx->mmap_changing))
 		return -EAGAIN;
@@ -1800,18 +1801,20 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
 	if (uffdio_wp.mode & ~(UFFDIO_WRITEPROTECT_MODE_DONTWAKE |
 			       UFFDIO_WRITEPROTECT_MODE_WP))
 		return -EINVAL;
-	if ((uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP) &&
-	     (uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE))
+
+	mode_wp = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_WP;
+	mode_dontwake = uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE;
+
+	if (mode_wp && mode_dontwake)
 		return -EINVAL;
 
 	ret = mwriteprotect_range(ctx->mm, uffdio_wp.range.start,
-				  uffdio_wp.range.len, uffdio_wp.mode &
-				  UFFDIO_WRITEPROTECT_MODE_WP,
+				  uffdio_wp.range.len, mode_wp,
 				  &ctx->mmap_changing);
 	if (ret)
 		return ret;
 
-	if (!(uffdio_wp.mode & UFFDIO_WRITEPROTECT_MODE_DONTWAKE)) {
+	if (!mode_wp && !mode_dontwake) {
 		range.start = uffdio_wp.range.start;
 		range.len = uffdio_wp.range.len;
 		wake_userfault(ctx, &range);
-- 
2.21.0

