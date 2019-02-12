Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52084C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:58:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BF332084D
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:58:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BF332084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7BF48E017F; Mon, 11 Feb 2019 21:58:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2B478E000E; Mon, 11 Feb 2019 21:58:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1AB78E017F; Mon, 11 Feb 2019 21:58:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 763CC8E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:58:29 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id u32so1313833qte.1
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:58:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=KLP2440TXQRdVyNsG670UipiAgbAuOUsK8ZDtYYU72c=;
        b=MTnrK/Qkp4HJ3FNdf3MadIclL7nmJfxB2xzz4igwp1WozEC8PNWtqOqVBJgCABiTn/
         wj7c0AFvfRZ2kctEpUnUzedBnOsBnBuakIC4qiURvCX+mjN5DrOKsHbl/5P0Yxn2034w
         YmIrCPBtcWUewjP1dRqXAQIA3UIUmFcJfChIvHJZcP4ChaGspvU2QQOxz1wojN/hXKXh
         3erxNLIlLB5w2axiD5FiEuN9q3V2sEm71Ph4HDcxcvOZlZD44/MkFEVmdFvwOsqU+heC
         XaT7Gy0zTc6y9zXw+BSPyOGoq4j9tAwHRnx7bKyEXP+usbrNuBPGWHspodMQU4Xc5vQx
         SMVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYu/oG0dAYzLL53J0WsGXYbOix3WfugVHOIVbQbeJXxehIvRbBH
	RptredcV0AhJ4KjY26aGZ+Tw7W4OPRMIEhI1cfElfsqcBWMfkBzNt/DVI0roLGd7QVswM3HQB1T
	zU1dtmisclrQTowpdtsp2taiS1QC8TNA+AK+kKsRccFxF53AYFQ991bqT4YMkLEWvWA==
X-Received: by 2002:a37:9906:: with SMTP id b6mr1048766qke.208.1549940309274;
        Mon, 11 Feb 2019 18:58:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbvvOncL3skbu1v5yegTzxXSfydY5+eKSevpRZGbIEqUsccMvLQDaTykXV7XFuHat2PDu7w
X-Received: by 2002:a37:9906:: with SMTP id b6mr1048742qke.208.1549940308781;
        Mon, 11 Feb 2019 18:58:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940308; cv=none;
        d=google.com; s=arc-20160816;
        b=IJzohMz3hwtzokiGggrarnxxWzqOU7zhUDePneC7EsCRAkgY5mcvvPc3CvawdKzlmx
         mysi3EihgOrIP+8WzsptVnHYzGAj/uN/wA4bzI0p5lHUbLin7bPzU0d6puuwhoegXih3
         8YUA5Jp2DCsVP8H2aH+GyiAwvj32eCAmdLpn/FEpEVYqh6OHOFOcs9EoyDNMhiA7GNi4
         7n2MBdQ4Pj7ZtTHkHMMqdbc2tmSN0cj/bqpvaXjRtbmjJ2OZIdwXHbnSJGDRDneQd6Xa
         vUGPpWgF67WQTafxenbIohjV6K2QmRaAi0v7KQKHwyHZ0Zq5uLK5sjz6Dc9aHJ79sWX1
         Jyrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=KLP2440TXQRdVyNsG670UipiAgbAuOUsK8ZDtYYU72c=;
        b=KpD3DiIVimFJHJREUhBiEPSpL2Nrv9MfbdeqfxSVIOp+/h/J4Aj2v4pywvH2SZonRZ
         IIuWgXhPhcOZrmLlp33iMGcSkPRrmRou9pX0446vlcoJRp8MxVAh0Q6zkMjPx8gIfXR9
         qvo7EiokNhRBL4IR/wgKtkEgCSHQs/FEp4X+q9SzKWb98X130hsJz44QuTfCOqHqDtjv
         5WVssgH8ilj5KSjZgIR6GmqGhKbl308y7EZf+uqo9KnWaHn5WIQJGkfRoDJIyWEjwsBB
         RrVqukgQ3MNtXQC0vOf63mFVQ34dERNyd1whpFdhPjUjcQBh/u8+kqOQC4nJ3C3kUfi2
         1Csw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q5si1439139qvr.203.2019.02.11.18.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:58:28 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E1D537F6C8;
	Tue, 12 Feb 2019 02:58:27 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D8D26600CC;
	Tue, 12 Feb 2019 02:58:14 +0000 (UTC)
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
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v2 09/26] userfaultfd: wp: userfaultfd_pte/huge_pmd_wp() helpers
Date: Tue, 12 Feb 2019 10:56:15 +0800
Message-Id: <20190212025632.28946-10-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 12 Feb 2019 02:58:28 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

Implement helpers methods to invoke userfaultfd wp faults more
selectively: not only when a wp fault triggers on a vma with
vma->vm_flags VM_UFFD_WP set, but only if the _PAGE_UFFD_WP bit is set
in the pagetable too.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/userfaultfd_k.h | 27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 38f748e7186e..c6590c58ce28 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -14,6 +14,8 @@
 #include <linux/userfaultfd.h> /* linux/include/uapi/linux/userfaultfd.h */
 
 #include <linux/fcntl.h>
+#include <linux/mm.h>
+#include <asm-generic/pgtable_uffd.h>
 
 /*
  * CAREFUL: Check include/uapi/asm-generic/fcntl.h when defining
@@ -55,6 +57,18 @@ static inline bool userfaultfd_wp(struct vm_area_struct *vma)
 	return vma->vm_flags & VM_UFFD_WP;
 }
 
+static inline bool userfaultfd_pte_wp(struct vm_area_struct *vma,
+				      pte_t pte)
+{
+	return userfaultfd_wp(vma) && pte_uffd_wp(pte);
+}
+
+static inline bool userfaultfd_huge_pmd_wp(struct vm_area_struct *vma,
+					   pmd_t pmd)
+{
+	return userfaultfd_wp(vma) && pmd_uffd_wp(pmd);
+}
+
 static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 {
 	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
@@ -104,6 +118,19 @@ static inline bool userfaultfd_wp(struct vm_area_struct *vma)
 	return false;
 }
 
+static inline bool userfaultfd_pte_wp(struct vm_area_struct *vma,
+				      pte_t pte)
+{
+	return false;
+}
+
+static inline bool userfaultfd_huge_pmd_wp(struct vm_area_struct *vma,
+					   pmd_t pmd)
+{
+	return false;
+}
+
+
 static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 {
 	return false;
-- 
2.17.1

