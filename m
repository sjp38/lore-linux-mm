Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C8D6C43218
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:55:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 14DB4206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:55:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 14DB4206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A2A9F6B0286; Fri, 26 Apr 2019 00:55:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D8E36B0288; Fri, 26 Apr 2019 00:55:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8EFA36B0289; Fri, 26 Apr 2019 00:55:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6F80C6B0286
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:55:37 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id 54so1869806qtn.15
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:55:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Br5Y+z06NFL6Gv3oN9scI1im/YhSUPS/BrUXGI+L5ts=;
        b=EcGkk9/P2UkfmHUbpuFvm14Ig0XjmXTclRetz8FCe/ypAf45zbwpVxBuTiMeTCRz6G
         ZCGaBkJu+7JIJJiTJWMc07CSklr6VzUUpmyRegXNGSbF78cWWONR4m7bqhTLoheoPNYf
         KImfDsL4nLfsa/rQdwzfpX3Hb4Yn94vG93CRQAZrzuy0iZw95Vrb1D1iIurB8JR4xr65
         e6WzanrCgr3QM5qO4w/Py/Ww8um/MtabYMVaAW5nmJGLMIRGw+GvVtgyxjb/eYuB3SPd
         Feat4YAKmd58uXPWi8Wliy98vDRXpgztIdaoVUEo70TIR4EbbzPCQuMYdBkdHkUkwFbz
         +qRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXBp3jEZCVxu5mkelRtocAElA3X2KUco9OZT8kMQC3LZtAZ541y
	Ex5cJCYRRT760wnFyDuUC+M61Y8JshJz50O2/xrX4v8ZMBpWc7xtP4E5i2G4JertX8osKkOpWJC
	4e1k984hUUdaeqsyfGVQqB6r2sose97LhtOTUaPIE7QUQsJKZ4onu7gxr4W4cOQem4A==
X-Received: by 2002:a05:620a:3d0:: with SMTP id r16mr32725589qkm.210.1556254537242;
        Thu, 25 Apr 2019 21:55:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYn69FquMln6zjTSiH8BJX1JTHSar2l6IAg3I/J0XGWPexo4fJI1NHfesTzp0HbS9rXtYI
X-Received: by 2002:a05:620a:3d0:: with SMTP id r16mr32725558qkm.210.1556254536413;
        Thu, 25 Apr 2019 21:55:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254536; cv=none;
        d=google.com; s=arc-20160816;
        b=iLSjoyuQFJ80KW9nWZQSOTYIMsW+GRI80/RMJrRtHDlYPx1TsaCPP3gOPlpGtomlHl
         i6bxkRGZoH7/KBkaE6SY1AX3k+RJuTMYa6SenqZm2p4f6k+AZ8o8NQ6DM9tZMC9btSVL
         FvJ7I0rPfdi/3/Qnuu2gaGjyIRnvwtvdGDA/PGyjDzkovQMsl5/2hf3w4bpH4YJN7Zh0
         JYauLNr+SmutqvkCcH1GslGF12b+DFKHWHSGT1jPHv+wsfI3E7EocTaPf730vYUCn7DK
         nqjVCr+GeiG5z6/av+MgWfQjDavdluxZTkfIYJk4gQWia53OORaeUDexojhQHM20rS0D
         V+yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Br5Y+z06NFL6Gv3oN9scI1im/YhSUPS/BrUXGI+L5ts=;
        b=wvYHFFhvP7KmWcKx0cd6dDYMN+enpNMC2F6lsJaHSG10cS5KgZw+/pnGTpw3g/Cskd
         0PswnxW9Is6u8XTlIEO/hsG1UmTpHAlW7p+GDEZmwQcbcQ4pErDO3suZrUqmSreUDSBn
         P1/GwycjNtQxeF8t2Kh96/ZZJp96rg+0XQe/AfJvVRAVMLUNsgF/YVtF2ffySfrv/bJh
         KhvkA9TtsyvYg2ryoyAo4uBz+O1LVy/HPWPMaJ0n6Cp79+v6qiqNZLPPamxL4GRvjFTN
         +R4eQEptJVGSTpoh4eX8K1iLs4xZIoR0WwIqyB4NGDLUgN+4ZJUd69WgQrKlrCSrQsVD
         uCpA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k5si2432889qtc.85.2019.04.25.21.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:55:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 95E9A3082132;
	Fri, 26 Apr 2019 04:55:35 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id F356918500;
	Fri, 26 Apr 2019 04:55:24 +0000 (UTC)
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
Subject: [PATCH v4 23/27] userfaultfd: wp: don't wake up when doing write protect
Date: Fri, 26 Apr 2019 12:51:47 +0800
Message-Id: <20190426045151.19556-24-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 26 Apr 2019 04:55:35 +0000 (UTC)
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
index 81962d62520c..f1f61a0278c2 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1771,6 +1771,7 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
 	struct uffdio_writeprotect uffdio_wp;
 	struct uffdio_writeprotect __user *user_uffdio_wp;
 	struct userfaultfd_wake_range range;
+	bool mode_wp, mode_dontwake;
 
 	if (READ_ONCE(ctx->mmap_changing))
 		return -EAGAIN;
@@ -1789,18 +1790,20 @@ static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
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
2.17.1

