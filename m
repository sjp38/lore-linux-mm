Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47D04C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:10:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 046F5217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:10:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 046F5217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA4FD6B027E; Tue, 19 Mar 2019 22:10:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2DBE6B0280; Tue, 19 Mar 2019 22:10:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D0B86B0281; Tue, 19 Mar 2019 22:10:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 678FC6B027E
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:10:11 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g17so888377qte.17
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:10:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Br5Y+z06NFL6Gv3oN9scI1im/YhSUPS/BrUXGI+L5ts=;
        b=Q6V7LduXXPc5k7CAsCL5KIiwx6wrYvRZW62GW6lfPYkiL4olGx2Dk8wBv3G34WKqMj
         jUckMJv2m77rHwVDwuuer1dB0o3kol0U0or8T3qJ84bmYeXkK6hTcM/1ovZ65e8eH2h3
         J32l7xCrXPICoWARkH8ULzfHGN/z2cayz9HKWE8Z6a8X7RkzZWj2tfx5/vIJAZAiZaH/
         BtCP39hKvndGqoiEg8lLjI9C7gSA1u2dtau+gfyy6DRlE8gdkht9b3IwYsz8ARLjllf6
         Cdl9RbpTUchUXK6YackW4/9XjJ8ahdYAe+Ky0X1qXw76jXjvvWSz1wEbJgKdDs9w6x3J
         MkMA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV5fiXxa0ZDFUal257gSsVqBLq/k8kbYPHHPwHi6YHhTrz8AX7X
	w+Ga0wEJAAR5vwT0R4d39ZcURaUKiM+6reUgyBPSFIpX6YJ4+FB/LcEjVZMsq3zm6GpQbZwugHn
	JmoGk5DvlTm8TW0xE7pOzl++Y7nl1Gw3RiI3rdPotXkjz4L7PDWdeOUTkO7Nz9SWo0Q==
X-Received: by 2002:a05:620a:1245:: with SMTP id a5mr4288799qkl.340.1553047811161;
        Tue, 19 Mar 2019 19:10:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzK4X+Y6P7Mlo4Gy9nrCDQ3YbTMNLPmpzldQzOdryg9YmNMa8ias3B6DrA7IUUQtvutx9Ub
X-Received: by 2002:a05:620a:1245:: with SMTP id a5mr4288742qkl.340.1553047810100;
        Tue, 19 Mar 2019 19:10:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047810; cv=none;
        d=google.com; s=arc-20160816;
        b=qh/bhNb6PHXqq40uFjjUWQdyIBuUBvI889/4lQZgAxttEcu01O+5dM8O7xpijskjUd
         57EkwvjdNGDYzUAkmeTnNz/0AUjoT1lfwTKShX0meioO3a3xUM81JhX7idjNRhSnYN4j
         OzsHLXr+Asy9zk5Lm97VH168NT7Muc7Jr+TCX3shCS5V8NWHpGPWHoAYNeZOq70ARLM4
         bm+8cYia4rnuANsgXpLGC44P2f9ZKmH/rCEWPUPoeG/N1a+GByy5SUG5i/15PvKx3tUX
         6QzT4asvtYHfOcMuAUKIAurEdg18zs4drjuO1R6Zjlz4QMJWTBa1IpH2vvTecUMR0HNc
         bw6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Br5Y+z06NFL6Gv3oN9scI1im/YhSUPS/BrUXGI+L5ts=;
        b=yAlxGgE2vIh6dDVJbCdQP8Dge8xH7qyaaW2Q6oWoxKioo2SIiwSTnDAci52mrljmYf
         em7oWQic3uediB1xKyJ7WbqjVEKF3MIC7JgragbQsa3lP0l5Hm/90D451N5+8u9OqHcg
         QpGCA5lb2XjGkHkFb7mdx8gdSe+H+j6v3BDd+JKKcEIsuE9kcHRtPDaNPkuVibIMZ/rc
         bSHja2IukKodCG4Q6v/qyFdQtAswHznsOYOdtfJSKP1TLy2fTez7bMYIfHRs31UTvGk1
         LUpIdzjFOk7GsBDCWIluBPZaXiZtLQgk0nVee29S5uKYbckEV3XsDouw5l8zsNQTy6gm
         NThw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d21si274180qvd.68.2019.03.19.19.10.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:10:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3107E8535C;
	Wed, 20 Mar 2019 02:10:09 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A06456014C;
	Wed, 20 Mar 2019 02:09:57 +0000 (UTC)
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
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v3 23/28] userfaultfd: wp: don't wake up when doing write protect
Date: Wed, 20 Mar 2019 10:06:37 +0800
Message-Id: <20190320020642.4000-24-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 20 Mar 2019 02:10:09 +0000 (UTC)
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

