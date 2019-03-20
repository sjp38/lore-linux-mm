Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10389C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B78C9217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B78C9217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 59E466B0006; Tue, 19 Mar 2019 22:08:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 54DC96B0010; Tue, 19 Mar 2019 22:08:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 43C3F6B0266; Tue, 19 Mar 2019 22:08:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8986B0006
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:08:12 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id w134so19494578qka.6
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:08:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=dMjQIHNpFGSe7O5uqRGBwJx8Nml7amhMVaY9sZK8RHg=;
        b=CTsDAABD+rvac5GVLKfRI60CKv9UAL11Z12zLo0g9tU5U+Wa0XSUAGw3VqT2iApql1
         PiaaEVAzIbZgiqAKR1lvnDaafox+McGgepjYjOEYJpKDpECK7zhbSyNlXV1GLbZ4s3rD
         D50QhqbWlkrBkDADDSwBpFRRjoTcPX5uOAmzGosPblipagT7wWHvVwrnx9XHSTjIBotA
         Jh5y0Bm+ev2DeuayO3Y1YlYJTftNpa3ev4iHgx1S9OZrHt/5Rex9NhF139BK2QlR3j+h
         m501B5paiBSwjUJaNsBO8GVWfGo1ZBSDqBsNQ/iakNLD3u+HTkb4z2flip9X/Ktu73sI
         kgOw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXLkX6p5+3mo/IecV5AfKVzwOAJ8i3839i5KPJd+1OiHfAOUAHS
	WM8qZJFzZGcdQmfH95lJkBiV4nmT48mCnydrWt+spZ6Ixm0bOA5c8vPA4FTDk/7GH99sXI/RCdS
	Ieqjdv75KgMn6qkhPz2TOMvGB+3FzMt0a8G0bb/eo7sKO0JbK/os3jX9Nprg7rPsHLg==
X-Received: by 2002:ac8:2ea6:: with SMTP id h35mr4833913qta.181.1553047691907;
        Tue, 19 Mar 2019 19:08:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwifI4B9Oie6OPr6IjSmB7AU51/k0KKopPuehP5hNp/qNQ51fqq0VsF7w60AmahTso1yFx1
X-Received: by 2002:ac8:2ea6:: with SMTP id h35mr4833868qta.181.1553047690903;
        Tue, 19 Mar 2019 19:08:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047690; cv=none;
        d=google.com; s=arc-20160816;
        b=h8tN3am/iyoylVmp4WQMJPHKj4+XA3VwphrSt/hEhQBuE+gd2wq/k306uWk251beeg
         1h9BdTyY7YRulGWm2JTcNK94j76Vw+qwouH0SLuQ72X6xJ4W2tQ/9sxoRkpM6qPufoxh
         A3Ap2WiEf4NvYmqdChI9zsxrbvMXYctmu1f0Dyyf6zRTaBnmE0CW/KL1A+n5s0pYss0p
         03bQl6DQL6/Hgh77BxdL4WNEsF6Yz8qaukqWplnpSP+FtyQWQUy5k4qB0Eb5kbXPP8pI
         ljDdHjrOjfqgEDABf2U1R6vUeR2VJr3Oy56bfwisXsECC+//nCtHIJ739qzYjjqCsMNi
         u9bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=dMjQIHNpFGSe7O5uqRGBwJx8Nml7amhMVaY9sZK8RHg=;
        b=QvbW7QGxs8k54nLug8nEd2L71t1WZbYrnoDiDpKWU7LSqxjx2hUxsXvJF/MC+5/QGB
         735trWViqkhcAVC1Jk3v2j4pmDyaW1MBIDNtnTiOewten4k/uYEp9aiHpuyiaD7ePlYx
         rXREGknIShYjkCOXS/9ATSjgdOin0uGdg//Vu019RDYKKmXaE93C6HhYkje97vm471U9
         pP4lyBO3ZPHNgT97v3rhT1F76/4eCcWxP+QnF/LT/UhUywbOcn3MifwjHQhCNscLnRs/
         DphS673ASXp/6081PUBAAXKlCadMr8EYqisT50F1iIWF0xYbhs1AL+F4ZFml8X8cmSwi
         b4Jw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v26si348190qkv.25.2019.03.19.19.08.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:08:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 16BD0307D91E;
	Wed, 20 Mar 2019 02:08:10 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 54B4C6014C;
	Wed, 20 Mar 2019 02:08:00 +0000 (UTC)
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
Subject: [PATCH v3 09/28] userfaultfd: wp: userfaultfd_pte/huge_pmd_wp() helpers
Date: Wed, 20 Mar 2019 10:06:23 +0800
Message-Id: <20190320020642.4000-10-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 20 Mar 2019 02:08:10 +0000 (UTC)
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
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
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

