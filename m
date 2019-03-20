Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98BCEC10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:10:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59DF92184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:10:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59DF92184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 091E86B0284; Tue, 19 Mar 2019 22:10:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0447A6B0286; Tue, 19 Mar 2019 22:10:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E25586B0287; Tue, 19 Mar 2019 22:10:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id BCE6A6B0284
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:10:33 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x12so933674qtk.2
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:10:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=+j5GaOU8poBAgZzks6hdkrPmZ/icMeiWJOPNT8FmFtc=;
        b=gydYWKEVa/Rj41uHQMgnfFLPu80NM24b1kFfgCfFSmUvNXZPkoZhZcD1kGfBolVvdo
         VtmlCPBHNljbQwGvLMF7LatO0qlbcGRPm9c/tC++opGxsg06qGHIgwL8pzV6AvoeZd+q
         gmVMQD/sgrbtkI9GDYL7MRYkKHtQZTy0bp0tOZVSCx+rQ6Sy0axJPVUkuh59WMlF7jn9
         SjY52kmAMpESJDdJGjaJxR9sX2nI7tVyufrf3c+Zd30GgUO58jFmY3HE95cYmxIAEPQ9
         JwSq/rpiWxU5eSK4B8UMV/vAuX/LN79jbSPjQ2kXTwtkz9+G7zbcn+XyBRF8sehSVwQM
         HcZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXfTE6/fA8PwNztclozOFoZJKOVmAhoLi/r/sa8QwohMkMCb+7f
	2Pkr+vtfRvbDynqy62x/LXiv0pPn+lkFqNTZI5TYQi0KCg8GSFexV3W2eyLaQ/bs/75lRVod9t2
	qK9XPYgKIo8XOK5CX5h4IuaGZc+VP7kTbtgZ57k5vFUSgMhX8QzVpr1/yHV6x+THerA==
X-Received: by 2002:ae9:f00b:: with SMTP id l11mr4549810qkg.84.1553047833561;
        Tue, 19 Mar 2019 19:10:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqUGo2aMBtSfnOP54dQ4gpaUoIIdnMdhCs8kspl81z7A3Jdyo8YS6/0Oww2RJsLiq6TKGe
X-Received: by 2002:ae9:f00b:: with SMTP id l11mr4549780qkg.84.1553047832631;
        Tue, 19 Mar 2019 19:10:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047832; cv=none;
        d=google.com; s=arc-20160816;
        b=RHKeRGyclaG/96tjfi1mwBrDGiqtCSP8SpD4kDRdRpeXeaSElcRaniE2V2qFICiAyH
         iJsycRgHQzlWM+Ge3uybnuvp9LjiCWRdf6NcSRtYYzm6Eyp31tSBScfKGsmN66EeeX3D
         NEcNMJuHVA21MDH6kcOUQEPR4rwb7cDHFNbqSujJAv/oWXd+Kttwe3pXupT+iWuAklX+
         uL9X72USD8hWtyZW5hEo22H0ReUmTIpcht2LO+v0+8NuncK6UgYT+12QI4wh6ZTXdDdo
         +5FmfYONTHIQBeFQ7Ek2WJzf9w9UW7Y8uVwL0ZbNiRt5rJ/uzxesE5ve6OFayJjeH6tG
         7b6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=+j5GaOU8poBAgZzks6hdkrPmZ/icMeiWJOPNT8FmFtc=;
        b=OqnZh7GTrSM6KIpSxJpJhI8CvBHgGex8n0agrXE+jPLG0zWrRJly/37VNIhqdSnI6K
         K4bb772pm/UQMT01dja7XChONnx4XLPrkmcrw3HevC6xhSdumLVEy1sQPywgUwn33Qow
         w5Tat7KUdYLB1DWaGpRLJD+eiGMeAkXh3ZXWn6w69VrfvR4ItJf0Dv1Iu38zq9J6tYrd
         rjupIDzaZwaKCOOsimVDxeJVPkLKoYVwElgYFlq0+1M2OAviRz9nIEQm06i8xg1OBOqE
         jLXIlyUk9S3KALkIkZN1lZmlf2eTeZWLm1EMFs0OSD+JsGIp7LqlmQjAcjstXRHtdF2K
         ZbCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o44si425985qtf.243.2019.03.19.19.10.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:10:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C0138C049E20;
	Wed, 20 Mar 2019 02:10:31 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1E4735B0BE;
	Wed, 20 Mar 2019 02:10:23 +0000 (UTC)
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
Subject: [PATCH v3 26/28] userfaultfd: wp: declare _UFFDIO_WRITEPROTECT conditionally
Date: Wed, 20 Mar 2019 10:06:40 +0800
Message-Id: <20190320020642.4000-27-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 20 Mar 2019 02:10:31 +0000 (UTC)
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

