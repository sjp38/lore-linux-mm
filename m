Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNWANTED_LANGUAGE_BODY autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 239EDC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:04:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DAB8521738
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:04:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DAB8521738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CAD78E0005; Tue, 19 Feb 2019 15:04:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77D868E0002; Tue, 19 Feb 2019 15:04:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F30B8E0005; Tue, 19 Feb 2019 15:04:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 34A598E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:04:55 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id e31so20691255qtb.22
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:04:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vhT/JRh5Ora1ssBCghfNtXJPPBh/LCkkIILPHCIsWjs=;
        b=U7HwqYJMYPwhaRlK5t8+dxSWFn5bLeLe1a7Dmv4CPTqH6BhePz3YBktH+NKW2DXIMh
         LVom+4DrZcvLLWr9wh6JXxL77Tp/KJ4LgCRWIQR/zlX0DHNamemvypaqzDxKKMgAIjxP
         HhsMgNFM/03KPU7smaTA481dFJu5DdecYbxAMWpIhUn+Nqcv5Px1llsMQYVPyqcw1WUV
         uJHHp+grDj0MzJLduVP9yi8IOVGBM9n1iEEhj4UlcDGU3FeFAThdsMVJ7bEQeHKIC+wk
         Hdbh8PV65BavWI+yKfxbg5GqA2hqtTboQeaEQqBzKp6plOs7BqSSi2GxIesixfO4rSUA
         EZow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubonPKsp7cj7KXPJ9Xe2eOznYuRacoHWOvCMySv45u2aPdeA16N
	fenr3z3ppEVwI9UU2WmyQueXi0v6uK+samPRYB6UYFSdu0Km0SydcAWoN5f6PdIaQwRzAwVBGiJ
	zeVngCT5dHO0joFkg07XPtPuHg370JQKQn2e0TAB56LeOK9AyDBSOnHHA86h0367Pqg==
X-Received: by 2002:a0c:e1c9:: with SMTP id v9mr23859754qvl.186.1550606695015;
        Tue, 19 Feb 2019 12:04:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZYt5kwL+Ql/RzVXU0yYNH5XUHO+EXh+v0tpWj417ywk0aCWR5s6/1gAhBfybko3IqH+oJa
X-Received: by 2002:a0c:e1c9:: with SMTP id v9mr23859365qvl.186.1550606689708;
        Tue, 19 Feb 2019 12:04:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550606689; cv=none;
        d=google.com; s=arc-20160816;
        b=jgi0+pwTJFtzwuG1c03z37y7K4Yd23PGMFYxjUfOtOawpbrQ/SJNV4qVtW6c2BiwNG
         Q4TBrOKZdXBdnAFhaWvoFcUYck3aB8S6TY4XlEmLSUD7ABUEs/DdvysSuz2Eld87ap8x
         djPdkU7IzQbJOiUgx5QduplYmtwq4xz1wFEJHKXXyzpOjqGEuXHGRh7fj9aRVoYgDceU
         X//kIaoo4WsPPu1WOY8P2NgX/mcEf8VIrmdrQKybvEzgvXxRfQTGbjhKJNCvcTCxf+9i
         z4l6EB2+qR/nis/WWYsVvC5E+97V1Kmz1oxDqSP6TTbq9HN6LRZ0RchdTjpgursBxQIV
         TG6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=vhT/JRh5Ora1ssBCghfNtXJPPBh/LCkkIILPHCIsWjs=;
        b=QdnviGAJc8jzycK0hq3MTbn3XuowIXUvS2zXU9/WY7K65WdxPrh0NA2eWRorWNrh3o
         n8/Qg3HLzt3/hjV4GjfexVJKuzuOPGHwCRZJDYYeKU9HRdKWgtGx5+GnGshnYWRdltSN
         9UREOTNL0B8MhEercSpvc/5MSxFC6kVQQ5TNN+zTxLLKi6e/qQ7jZrpKTesPLPYnVaB+
         kT+vso3xGRr1+KbEMLrUgGSNSRSrmEA9DxIEdxy53ueL8wlidq2Hx7d25tkKsvyAAFBy
         fDQYC5oqRLgLJpd20bM6ql3x1xxSuFuSOUt2ko5b++iAtgOb53RoNlOFtM5239sjr8HW
         kZEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t53si1076265qtc.72.2019.02.19.12.04.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 12:04:49 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6A42A369A0;
	Tue, 19 Feb 2019 20:04:48 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-134.rdu2.redhat.com [10.10.122.134])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5ABE86013D;
	Tue, 19 Feb 2019 20:04:45 +0000 (UTC)
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
	linux-fsdevel@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v5 1/9] mm/mmu_notifier: helper to test if a range invalidation is blockable
Date: Tue, 19 Feb 2019 15:04:22 -0500
Message-Id: <20190219200430.11130-2-jglisse@redhat.com>
In-Reply-To: <20190219200430.11130-1-jglisse@redhat.com>
References: <20190219200430.11130-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 19 Feb 2019 20:04:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Simple helpers to test if range invalidation is blockable. Latter
patches use cocinnelle to convert all direct dereference of range->
blockable to use this function instead so that we can convert the
blockable field to an unsigned for more flags.

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
Cc: linux-fsdevel@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/mmu_notifier.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 4050ec1c3b45..e630def131ce 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -226,6 +226,12 @@ extern void __mmu_notifier_invalidate_range_end(struct mmu_notifier_range *r,
 extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 
+static inline bool
+mmu_notifier_range_blockable(const struct mmu_notifier_range *range)
+{
+	return range->blockable;
+}
+
 static inline void mmu_notifier_release(struct mm_struct *mm)
 {
 	if (mm_has_notifiers(mm))
@@ -455,6 +461,11 @@ static inline void _mmu_notifier_range_init(struct mmu_notifier_range *range,
 #define mmu_notifier_range_init(range, mm, start, end) \
 	_mmu_notifier_range_init(range, start, end)
 
+static inline bool
+mmu_notifier_range_blockable(const struct mmu_notifier_range *range)
+{
+	return true;
+}
 
 static inline int mm_has_notifiers(struct mm_struct *mm)
 {
-- 
2.17.2

