Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D79BC10F02
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:05:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5348A21773
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:05:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5348A21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 582E18E0007; Tue, 19 Feb 2019 15:04:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 507F38E0002; Tue, 19 Feb 2019 15:04:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F7158E0007; Tue, 19 Feb 2019 15:04:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1911D8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:04:59 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id 43so20699347qtz.8
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:04:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=y4cTz0AvI8I1jPok9kmJHggRtXPyxbatRSaKY8cn6S8=;
        b=CjxrCzXSKto9toEYi5qpXqq26qV0pQV/6emn8lbQqsJaAShqOxm3Qe8ZmLtMslx9Em
         pLXXnDGM1ahfyyhUHGPAh9IySkfK/zeIhxLp+5pNgiFi08mI2LzJegV2cOYDJZfL4oNI
         dykQxCDKRRPcoF5UueSNnM8Hhca7DiaA2DaahRCeX5LVvePOv5QCCp/MRcVGCjGt9E8H
         Jfw5RSMI18beaTa252VXpshtRjU8M2G3Vnu60t6ww2syghJHzocroNzho0BxvVSGGCJe
         uK5x/R28JG1Z0WKjh6moBw98l7KXmwn/AJ58plh8aqVg7f3LUG0tT2/qPNhzsCrqUnXV
         O4cw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua9qMqWBBwuLAQvNhB9sUs4XNmQ8TcJo3J7f7nUVL2gW/rgiWRE
	NDj9/5Uz6XaaT/gaY6QWgcLZAneTpL8io8jg92myQWOoYLck0ZGXqtEQPo7zwpglj9hNoQYnnPh
	2NbUH7/r81/lENkw8YNDQtZd8MqaGvH1Fv01JQl4WAFH4//l10q/ggtZl1htLYt9ceQ==
X-Received: by 2002:ac8:3d51:: with SMTP id u17mr24443271qtf.127.1550606698885;
        Tue, 19 Feb 2019 12:04:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbJP7snB/dQg0koyC+po8j9DmRcoyH0dvCNTiVUpuDfYxKeh6M56c0yfQckJGBu1CiLtkKn
X-Received: by 2002:ac8:3d51:: with SMTP id u17mr24443205qtf.127.1550606698084;
        Tue, 19 Feb 2019 12:04:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550606698; cv=none;
        d=google.com; s=arc-20160816;
        b=rL3lMdqmwf+iB9qMw+KlK4ybX//aL72zws55mK2ebexBR+4ZlVpPMhKClyuangmROx
         smzYugi7t8R4anSDDbRYD92byrDq6ehwsnWOe253fIU6AbDH+mLH03aI5CVG5r8BKSs7
         FEOOcPAKn51KpL+UFuCM9u9EzRpse4v5rCzC9qzDKBB7fg1WwvNMI2ESzGprEQyiHsrM
         nqgmf9Ujo2FB3KyuUbkC/C5R8MHnQTNsZ7JTxLyADOlqDPMi/GGvYXTLuiIEzqug7ATs
         aV6LVrZ+anNCYLJkSGiV7eMw0pqlARqF6/iEBeEmgv/DGcUiWeWp+JAhv74U0zrMhdP/
         zPAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=y4cTz0AvI8I1jPok9kmJHggRtXPyxbatRSaKY8cn6S8=;
        b=C+QhqxcHvMjMRI8382BN6+jIZn+nTyGV6t6ulUQwKu2Rsz9Rr+hQy/7IGUxXZ8QmSl
         QlRnpO9RkPBhxLNKH3Rd9pGLnwmhbDqzV83sZ7fYLjDVzgWu94rxd7gJOwONu9Eu8ZYi
         Rm5yP+HXbsclFJ6aKynH3Fe0j6VF8QGg9hyTPI28+G+QjeP/DTW4AtSnaLIRltCCMshB
         omTun2bUspjpqnuAlglC7l5EMg0HR3Z/Ut7XQMqooyM0nVaOsjMZhZdgfAtInE9jfVrA
         G1sxStJ2GqFO49p6on0+U6awhkruqJ+lisIp6wnvjMZsXVmOW7XHEUtu9vzlU4Bp4sEM
         koXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b54si2286355qvh.217.2019.02.19.12.04.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 12:04:58 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 04C1DCA1FD;
	Tue, 19 Feb 2019 20:04:57 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-134.rdu2.redhat.com [10.10.122.134])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8FCED60141;
	Tue, 19 Feb 2019 20:04:53 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v5 3/9] mm/mmu_notifier: convert mmu_notifier_range->blockable to a flags
Date: Tue, 19 Feb 2019 15:04:24 -0500
Message-Id: <20190219200430.11130-4-jglisse@redhat.com>
In-Reply-To: <20190219200430.11130-1-jglisse@redhat.com>
References: <20190219200430.11130-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 19 Feb 2019 20:04:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Use an unsigned field for flags other than blockable and convert
the blockable field to be one of those flags.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Christian König <christian.koenig@amd.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Christian Koenig <christian.koenig@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: kvm@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-rdma@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/mmu_notifier.h | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index e630def131ce..c8672c366f67 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -25,11 +25,13 @@ struct mmu_notifier_mm {
 	spinlock_t lock;
 };
 
+#define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
+
 struct mmu_notifier_range {
 	struct mm_struct *mm;
 	unsigned long start;
 	unsigned long end;
-	bool blockable;
+	unsigned flags;
 };
 
 struct mmu_notifier_ops {
@@ -229,7 +231,7 @@ extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 static inline bool
 mmu_notifier_range_blockable(const struct mmu_notifier_range *range)
 {
-	return range->blockable;
+	return (range->flags & MMU_NOTIFIER_RANGE_BLOCKABLE);
 }
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
@@ -275,7 +277,7 @@ static inline void
 mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
 {
 	if (mm_has_notifiers(range->mm)) {
-		range->blockable = true;
+		range->flags |= MMU_NOTIFIER_RANGE_BLOCKABLE;
 		__mmu_notifier_invalidate_range_start(range);
 	}
 }
@@ -284,7 +286,7 @@ static inline int
 mmu_notifier_invalidate_range_start_nonblock(struct mmu_notifier_range *range)
 {
 	if (mm_has_notifiers(range->mm)) {
-		range->blockable = false;
+		range->flags &= ~MMU_NOTIFIER_RANGE_BLOCKABLE;
 		return __mmu_notifier_invalidate_range_start(range);
 	}
 	return 0;
@@ -331,6 +333,7 @@ static inline void mmu_notifier_range_init(struct mmu_notifier_range *range,
 	range->mm = mm;
 	range->start = start;
 	range->end = end;
+	range->flags = 0;
 }
 
 #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
-- 
2.17.2

