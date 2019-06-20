Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E084C48BDF
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:24:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 535012084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:24:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 535012084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E026C8E000B; Wed, 19 Jun 2019 22:24:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB28E8E0001; Wed, 19 Jun 2019 22:24:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC7D58E000B; Wed, 19 Jun 2019 22:24:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id AAD6A8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:24:39 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id z6so1689290qtj.7
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:24:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ULiOcDZKihkOBhbiRwYSv6/Li2uCDaTi6jb3hQtUL44=;
        b=Lz7eCAPDwVDwhmxjEwXT1dqcyzLFVdGpzwz9Mpe4MJXDwTK+HUAfyTdvqtuzR19OHu
         XrTBD/2SlUsJ93hklGe1iXqLuBwFSruuVSSXkcAM86vFtETF5+Lm8rgf0zzqMbB5PFdR
         2EPbXt+kAVXy7lcwg3TuEUbjtOaOq3VgiXeWJxIT3L/x/VHUDuz5pnxSkLm5h3iBs881
         ioQx0kSLZlbNlYfKDvm9H7qXOTCyto5PNH/FzWBPSIcE0fELCVsme4cOZOAQIGz0clBP
         erXtbXej3PNi6rHpEoeF0k3NhuT2STXtcjBLJfoMIXrl9kPxu0fj2Gi7BV8TwTIECxUQ
         uNqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUJiy4NnN4oeZt8lmQPfDoa4j8tNv5dK22kn0fk6Dm/K8epoNFu
	7g+DheIW8s+DHtiorlaY+C4HL7FoUSCoZa/s2EDOxQA7gSqud+WAAehDQcHH0c+JiM+bbpfZ/40
	Z4EcEPXTu6PWKTWZJcEWyG1ub0Uu9k+cGEY/BuzKxVxbjwKt3313qfJVUFkBlz2Caaw==
X-Received: by 2002:ac8:374d:: with SMTP id p13mr106516107qtb.389.1560997479493;
        Wed, 19 Jun 2019 19:24:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIGPTwhqODCCpEo1D8IHXEFCHgmLGGflY8ctWORrOQucbiIDVCIZ7EQ5Ml+Ry7eePq6gEy
X-Received: by 2002:ac8:374d:: with SMTP id p13mr106516079qtb.389.1560997478940;
        Wed, 19 Jun 2019 19:24:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997478; cv=none;
        d=google.com; s=arc-20160816;
        b=NgwVpWebcG7KFo5hMiD8q1gf53KUx8NcGDXtszjAwox5jyPoAtY3lQHR1xNpdUbhbk
         QhB/CTMB0QgsRibFQhZGSfhiSE52ioekr2cCwIgsx1/44PHGJ6+GrJFPRptlGgP51NBR
         Xqqsl0pkTK5GlR8Gm86vIGZmSlEfUxPzBpaKEhY0PnYmVmfqXl4PRvRVwQ21cauLlEKp
         3OP6NbKA/TcZxVXb9cOO85hI90qlOZk5i8excryGu6cA4jFH1TDCX5i1J/Q0ed8xMM/A
         A1qxuj8kmT001L2KhWMFttAfFtfleKQGYraBDnY4XLJ9D35PLjBSAxBWPYMLwcIWb6QR
         mFdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ULiOcDZKihkOBhbiRwYSv6/Li2uCDaTi6jb3hQtUL44=;
        b=OffyBmfmbfkeQT5t82ha3wi2WyyUP1J5WgA7lfDikvPoBJRsIz0MXJH/qkcr5EUtt0
         eHjELKd6ghSLmYF6q0qBxryX6eB/84l1kO8HWd10JQX0+pxHsR20lB0W2m2Jz4DQAc6y
         Ee56nQ1RpFziF3XcxyjiwYEXgCKHxMG6wOKCcFA8SqUSP4cxoUYhkbbtMA4sQ5cI92U5
         W2OUjtB9JQU9z5C0o1+CJ69S6XnwYKj+vg14GwBLz1BZ6LNFBwfUXohflEdnluqY3AJh
         9O/wLmNM14lUQqwvK/gx8iI9bZMeWrbAXrdnfIdIieejZPKswJi1u7EIcw4c9y8gKVWy
         UF1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 16si3684828qta.329.2019.06.19.19.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:24:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0BEE1C05D3E4;
	Thu, 20 Jun 2019 02:24:38 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 02BE01001DE7;
	Thu, 20 Jun 2019 02:24:19 +0000 (UTC)
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Rik van Riel <riel@redhat.com>
Subject: [PATCH v5 20/25] userfaultfd: wp: enabled write protection in userfaultfd API
Date: Thu, 20 Jun 2019 10:20:03 +0800
Message-Id: <20190620022008.19172-21-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 20 Jun 2019 02:24:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Shaohua Li <shli@fb.com>

Now it's safe to enable write protection in userfaultfd API

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Shaohua Li <shli@fb.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/uapi/linux/userfaultfd.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 95c4a160e5f8..e7e98bde221f 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -19,7 +19,8 @@
  * means the userland is reading).
  */
 #define UFFD_API ((__u64)0xAA)
-#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |		\
+#define UFFD_API_FEATURES (UFFD_FEATURE_PAGEFAULT_FLAG_WP |	\
+			   UFFD_FEATURE_EVENT_FORK |		\
 			   UFFD_FEATURE_EVENT_REMAP |		\
 			   UFFD_FEATURE_EVENT_REMOVE |	\
 			   UFFD_FEATURE_EVENT_UNMAP |		\
@@ -34,7 +35,8 @@
 #define UFFD_API_RANGE_IOCTLS			\
 	((__u64)1 << _UFFDIO_WAKE |		\
 	 (__u64)1 << _UFFDIO_COPY |		\
-	 (__u64)1 << _UFFDIO_ZEROPAGE)
+	 (__u64)1 << _UFFDIO_ZEROPAGE |		\
+	 (__u64)1 << _UFFDIO_WRITEPROTECT)
 #define UFFD_API_RANGE_IOCTLS_BASIC		\
 	((__u64)1 << _UFFDIO_WAKE |		\
 	 (__u64)1 << _UFFDIO_COPY)
-- 
2.21.0

