Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3539C48BE0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:25:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4C142084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:25:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4C142084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 551178E000E; Wed, 19 Jun 2019 22:25:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 526B88E0001; Wed, 19 Jun 2019 22:25:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 415148E000E; Wed, 19 Jun 2019 22:25:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2206B8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:25:12 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id u129so1723106qkd.12
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:25:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Lm0S7FSq2A9HYbt5saNCQ4d83jxh4YmQI2wDIQ8lFTc=;
        b=CeduDrsCZwUip3iN/CRY1J/uS0zC6vQBuJld1idLsMrfNCVc6IOpJ1UAwkqOMzMN56
         G4wVzyG5yuZEKAwUuXEbf6lKjj7TfHXWJSsbnkU/Nmmp0sqEx8uNKVz/f8ekrO12ebuC
         cjputnL4FpzQG2bR6IxMsXIR4ONlnacrw2qm/nODqXYrsj/egGrcGQHyen+75yqA5wiN
         MTjL26jZNFatuscF2mP/Nru1HO3NmvI3TQ7Fqh8Dj+UudSIZ0/Qbu1XJi7hLyOK66LtI
         v9+2m19AtF/uzFpIn6X7PRtF/pC6S7q4CTtJoXAUX8LZgBET7iWTQb5CwRno+2Y7UjuN
         a/2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXstdbF/QlGKPccq/eGrUsCRBIKJrmninKmKkan51z6C4bGdD6A
	is4xEoly4kvzYNFmcxgXzGQO004rpeK74TDLlkm4h/MQNQqENO3DRFkrVpttZtWuwRebukDLLpf
	BRRSoOrgHv7VJGvaaj2IeZcSCYBxSYG6xeQAspwO/AlX1WkFcpnQsEyErwWOiYGLpVg==
X-Received: by 2002:a05:620a:14a8:: with SMTP id x8mr47497464qkj.35.1560997511916;
        Wed, 19 Jun 2019 19:25:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwR1XVlXQIHbJWJGgh1hz1pEQ/8/sXqVN0n6oOYMDUwSIF1MBV88rgEnWMNXSkbLMld0B/U
X-Received: by 2002:a05:620a:14a8:: with SMTP id x8mr47497434qkj.35.1560997511407;
        Wed, 19 Jun 2019 19:25:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997511; cv=none;
        d=google.com; s=arc-20160816;
        b=wuT5WgWgDLTDKbKXMpJFlpha2mxv8NQ7ZuCy7i3ja1nnWuE+o67MrJfQDdQC+Su2c1
         f79JfbqYbNlIq2X7d61N4WD56SuY1s8Ig1DdKYAcYcSf3ZMoAp3gvnqBphZpTWXmAyYF
         2MM/d4eM/WjhEnklH5IC9rnUwsZJKKINdKuZuc4rrZqUTWKHXl2Cg85vz0yBikM3yEhi
         SzIbBN9b4q5BEkuues8xN2oHbzK5fr6/y+BlNb9bkuzC5iql8erGPY5DZsEmRfd8z/Vq
         KwLdGuIR9Ud5KzdTPUcjdhmszaQ+aNDnMwarYlSG38/pmTdt3NfZ2ktWzAThZJ6dL9hQ
         YNWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Lm0S7FSq2A9HYbt5saNCQ4d83jxh4YmQI2wDIQ8lFTc=;
        b=KpljIwSh4eian7NWTHYS+Su2M+sRy/ktVqLMXwv3Se5OPg3XaHQxaLjhU94LN5oIj0
         Any1K/PoDf/M0Wg7RM7euxBnlqq8YirgncO+pmLPOs9YKBJpmb/1qMDw8OZf0UrzVT22
         rlwy3Yqud/xgkB7xhfCSO5Mit24oB20xXdQ8kKdYv0TYf7VwXtYp5wSvK4EA+VNunsnC
         O4hia2eRH3Vjk9AghsYm81Jza8V4bbzYKSmUSoS36E4mF+Al3Stg5uwXteR0AWUnxkkM
         ueKjeCUX+h1/WaS0ACes5XfcCGAq/x1wvjPY1CfKSk8nWC4qlbfmxzxOrTI2wr0/8xdk
         R0SA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x8si3756887qtf.386.2019.06.19.19.25.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:25:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C7B6F22386D;
	Thu, 20 Jun 2019 02:25:09 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0F7811001E69;
	Thu, 20 Jun 2019 02:24:59 +0000 (UTC)
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
Subject: [PATCH v5 23/25] userfaultfd: wp: declare _UFFDIO_WRITEPROTECT conditionally
Date: Thu, 20 Jun 2019 10:20:06 +0800
Message-Id: <20190620022008.19172-24-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 20 Jun 2019 02:25:10 +0000 (UTC)
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
index 498971fa9163..4e1d7748224a 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -1465,14 +1465,24 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
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
2.21.0

