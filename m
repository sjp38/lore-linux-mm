Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66FBFC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:53:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33A40208C3
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:53:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33A40208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C75826B0269; Fri, 26 Apr 2019 00:53:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C256C6B026A; Fri, 26 Apr 2019 00:53:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEEB26B026B; Fri, 26 Apr 2019 00:53:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6446B0269
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:53:00 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id j49so1860171qtk.19
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:53:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=e0fxVMddmA9GXiTtSfkbRCEUFj7blRCWENdC7N/YeF0=;
        b=koH2Q6a0OfCSJcRf+oxL0C0pQh46GAmffjzrpZixmsMd0AN/CeJXtUxKw2puVOCnSv
         8bn8ketf2S8U14LwLmItDiwrPxUgQAee6aYb5ia8nEWetV4a5UFmbx2AotHD9ChGtMhF
         DNsMQQib/wQRABDdb11/7DyKDR71vdjL1sdHRuj6QVhI0rcQfDhfniYDkcM/Ad9g84Vv
         AAeVWUTyoyXKyDtn419gdJbJW4UWlY9g2dG7ZDcs/iBhH6SyC81Tq/iuh5dC9R7j+98h
         aVvVxZqf3mCOvy3cIuyZl3SrlCvSbyTt7+9FPxSRmr1Rnuac29fBG8qWnd3lYhwmGdNN
         ERpQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWFSalXKwY92b9B5Ke7aOM/N+Bn/IKJMyfTFpcFzV87OYduJ/rA
	J8XLJhoGK/ivn5ffyRxkbzDUS08ZRweHEDHPUgXDx9FIw4khH8BI4tfYjMqyMf34n5rlgq+8qI2
	LGmHHFP0JtKpGiYpFJtfOQEcr91OkD3O20IjsXHYOg/tXjVRSBuhDByi5PWB1OdS+4Q==
X-Received: by 2002:a05:620a:129a:: with SMTP id w26mr14676885qki.297.1556254380357;
        Thu, 25 Apr 2019 21:53:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyX6L5fpCvCo72vbKc8wBrlscdfmVFm4J14JPEvxBQcWVSeECZoshU3PwzOgIH4XMb2i06b
X-Received: by 2002:a05:620a:129a:: with SMTP id w26mr14676868qki.297.1556254379851;
        Thu, 25 Apr 2019 21:52:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254379; cv=none;
        d=google.com; s=arc-20160816;
        b=EMz1z3Xpbsece9LKsdMf6mx3MFBoQ7I1aPx8xQovOB3s6GncxNRaEQ1YSgACN9Oy/I
         OBNA25YzCd4AFuIS8C1hp+OFjFTRh3kF4heEeuOf6OSKr1Do3DWPal7Y1NBfKbSf9oyn
         /RA5q0ITfr7AOS8hBG8e3JM5EUR4CloyFi+eDToTYDsf88VtOJLoIrFO2PQZZwgIo4dB
         qhypfA9u7mriNtF+bVObrLAnR1oqQskDVZ24FzJNuefP/ecWcuP5R7PU0df1Q1rKRaPn
         cooab7pRf/P65E6UU+oXIX/UHGFjjWwCBzv1Oe0kVjT6mfzUdX6KhMuWiSMq1a2Irap7
         vZbA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=e0fxVMddmA9GXiTtSfkbRCEUFj7blRCWENdC7N/YeF0=;
        b=E1muo9S3rCySkE+VKY9V7N40+JF0he5VzocNj64zWpdc5jQYDdOoWjM6qAt3rZxix7
         DzNwMSI+OsPyPPoUTDZdpeO3RstJLCLufnhXnNCl0lx8LzMMea5iu90+Bfo74zXZb0m4
         bbO5hz3wb6asH24npeMfCIa+MiyN+QJ2PsuHCr7ZetqbMv9GLYkfhoqAbYsthlBb0yU9
         M6YNxhFBcOnd9tDLCo1a8MXy3ySyCDS/y7Lg+CqnynFZ248SoYYpALP/c4XhlJ4z1mMK
         W12mOnOjNqcvkxESpM1ubDUFW9BOpFa1j7o8tUvBiWemHAzNSdKAEA9fvfX1WfkPFAEw
         Lx1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g24si418882qtb.300.2019.04.25.21.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:52:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0C8822DA988;
	Fri, 26 Apr 2019 04:52:59 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4AE4617B2E;
	Fri, 26 Apr 2019 04:52:50 +0000 (UTC)
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Rik van Riel <riel@redhat.com>
Subject: [PATCH v4 06/27] userfaultfd: wp: add helper for writeprotect check
Date: Fri, 26 Apr 2019 12:51:30 +0800
Message-Id: <20190426045151.19556-7-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Fri, 26 Apr 2019 04:52:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Shaohua Li <shli@fb.com>

add helper for writeprotect check. Will use it later.

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
 include/linux/userfaultfd_k.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 37c9eba75c98..38f748e7186e 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -50,6 +50,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
 	return vma->vm_flags & VM_UFFD_MISSING;
 }
 
+static inline bool userfaultfd_wp(struct vm_area_struct *vma)
+{
+	return vma->vm_flags & VM_UFFD_WP;
+}
+
 static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 {
 	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
@@ -94,6 +99,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
 	return false;
 }
 
+static inline bool userfaultfd_wp(struct vm_area_struct *vma)
+{
+	return false;
+}
+
 static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 {
 	return false;
-- 
2.17.1

