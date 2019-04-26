Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67123C43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:55:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35E9A206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:55:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35E9A206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC0726B028A; Fri, 26 Apr 2019 00:55:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C70D46B028C; Fri, 26 Apr 2019 00:55:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B87406B028D; Fri, 26 Apr 2019 00:55:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 965316B028A
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:55:49 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g28so1569502qtk.7
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:55:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=q9EArJHlwfMAuKhsKXQeuL6ijYZfZ9vQpvzHYfctpTk=;
        b=jwzCw290gwN1pcHAGG7z2IcSkhFUpgD6mKE1HUbwIwijERtBgy/ES30imtmidEDHmE
         dqKRljM1ugGkerGcBn/UmxsK+RkQxMpNMNtnwgyGOJfmW+/SLRaM3xrMgoPLPwTExSx8
         3FGLvUghBvaik0aThqse9lb31UGa/bNP8fJgC6M12RXUheRf81s+jTeqGNGUvaqDkki1
         CEqcOxUL565OKqNGaO1pbt6O7eEWJASlyHTx3F1oXS8B5gdY2aYdjZyCUEXwPst70tSe
         nkrP7rl063cHc0FTzyCzSStINtz9aaiFF7nyShJ9MfdJINon63Bdy/R+ZIXegNnCuLUZ
         ZVSg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX5cFjozfCiU/397FDODzI3PLCgrmvyFvJ8EpMQTzs9ez0n63Tq
	FmaT/1gW+3+CKQ6vPciNIPCw5DSkbVbELQKtuQ1HLGWsGAjdIPI3Z1sfg0sPwK/+/JH/zvIM1Mh
	M+MVDnsElCXtiL+v/QTCPl3vPLroJ9+r7FdoPS65hFJCvOAIjbdcqUX2uq3Wz6qYR8w==
X-Received: by 2002:ac8:2649:: with SMTP id v9mr34918097qtv.275.1556254549407;
        Thu, 25 Apr 2019 21:55:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxuxMweeYAtd2b/wojLKZB0tsm2eTUZeZQw1EQoRkgjbl57ygBvh5MgqpsSPqOc1g4zkx/k
X-Received: by 2002:ac8:2649:: with SMTP id v9mr34918068qtv.275.1556254548625;
        Thu, 25 Apr 2019 21:55:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254548; cv=none;
        d=google.com; s=arc-20160816;
        b=iz48OPV6Hu7cGUs1tl+AtxF+v96j7rkPgrVUMHyH4MuR5wgowSq+KhxXmpTz3nTRO6
         RmM1EUInsSxWUYxlafISgoWCzdDT331NmAU+AKGZlmqPiHc9i0z+L5K4FgDI3vMv5xkZ
         skNanK09ufgixKxBSQZ6sHVPlkxTT4XilqbNM87CM0m6O+kynuF9mKCT5gA6tkaFfJWf
         T592H68+BXhOZlYOu1qyMFT1Sz7/aLcMpcCJFvVlb1k6YlfLdoR3slqnsgfXLeJZRvqR
         BuHB4Jyis87dvBGCvZGmR1OCCHsrBAXOj86Ev2E8xOdIbvNIOLlvDvFLSaep3uKjbBvd
         y7cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=q9EArJHlwfMAuKhsKXQeuL6ijYZfZ9vQpvzHYfctpTk=;
        b=CDWmb6wzXCU0JfbsQKOuZjOk0fiYBzkk1N+w4Rc5CLU4FVK5onaJPDbndKuz+qCI5u
         e617C7a+OgNTwr149pZ2K0WjkfUgIbBtAPhuQ1Nn0msgCQUWdByn2s6WpJjO7qkYB0Bg
         Yyvfz7l4cGRE5MBaxBywWtcTWOZYTZ2UjkCrP6f2HUvEBP5n8GjFlezCcFmblLH9GEWh
         SibaDaXJJD/HL5KAsimxmm2rYXxNcZSeZUfRsHTV0/AKbV9BQ8rusEgMzUV9niC23AFR
         qP5bM9vLRWVItyFEatWyHphGwfEpxpR6Idv+gZJHu9s2T1/StmJjIQh+bwpW6T96irR1
         dtFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v33si3681742qvf.120.2019.04.25.21.55.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:55:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BF56A11DBA7;
	Fri, 26 Apr 2019 04:55:47 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3088818500;
	Fri, 26 Apr 2019 04:55:41 +0000 (UTC)
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
	Shaohua Li <shli@fb.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v4 25/27] userfaultfd: wp: declare _UFFDIO_WRITEPROTECT conditionally
Date: Fri, 26 Apr 2019 12:51:49 +0800
Message-Id: <20190426045151.19556-26-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Fri, 26 Apr 2019 04:55:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Only declare _UFFDIO_WRITEPROTECT if the user specified
UFFDIO_REGISTER_MODE_WP and if all the checks passed.  Then when the
user registers regions with shmem/hugetlbfs we won't expose the new
ioctl to them.  Even with complete anonymous memory range, we'll only
expose the new WP ioctl bit if the register mode has MODE_WP.

Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 fs/userfaultfd.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index f1f61a0278c2..7f87e9e4fb9b 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1456,14 +1456,24 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
 	up_write(&mm->mmap_sem);
 	mmput(mm);
 	if (!ret) {
+		__u64 ioctls_out;
+
+		ioctls_out = basic_ioctls ? UFFD_API_RANGE_IOCTLS_BASIC :
+		    UFFD_API_RANGE_IOCTLS;
+
+		/*
+		 * Declare the WP ioctl only if the WP mode is
+		 * specified and all checks passed with the range
+		 */
+		if (!(uffdio_register.mode & UFFDIO_REGISTER_MODE_WP))
+			ioctls_out &= ~((__u64)1 << _UFFDIO_WRITEPROTECT);
+
 		/*
 		 * Now that we scanned all vmas we can already tell
 		 * userland which ioctls methods are guaranteed to
 		 * succeed on this range.
 		 */
-		if (put_user(basic_ioctls ? UFFD_API_RANGE_IOCTLS_BASIC :
-			     UFFD_API_RANGE_IOCTLS,
-			     &user_uffdio_register->ioctls))
+		if (put_user(ioctls_out, &user_uffdio_register->ioctls))
 			ret = -EFAULT;
 	}
 out:
-- 
2.17.1

