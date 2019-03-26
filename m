Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	UNWANTED_LANGUAGE_BODY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65B5EC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:48:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 208BF205F4
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:48:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 208BF205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B04BF6B0006; Tue, 26 Mar 2019 12:48:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB4366B000D; Tue, 26 Mar 2019 12:48:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CBA26B000E; Tue, 26 Mar 2019 12:48:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E85C6B0006
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:48:05 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id f89so14147165qtb.4
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:48:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6S96iBiVeL+UBOi95MsTRx8DtQV0M6xKTn3indFi6wY=;
        b=EWEHB2+SK4+tQI99CgTAs8ZeHjet2C5IgWaGOveg6xXjgIiirOGwHqwrzvNjmSIubn
         faLo7H2s1AUwg2BIfDqHj8GtUlVsE5oITXMbBqMCni+CYgfAbjGTJ6tkm1YzzAtkIeDz
         bCcrSfBt7bQhoQiHwHvzSq4xsBskIC9ZtQIPjBEcNIYP5i7ZRjHPP5wJNXUko+lNrc+P
         2fjwG2e3RtHN7qkUwQtw34XXZmt1eLPC9FrAqAoN7MpCdAGI99u3DFsZaqyQiyeeW21N
         cA3MeV3sDxrLZDMdQFM+wovhpPR1v6b775f5pTpCi5cMhTVra5BW2ycanpnWi52tB1Cd
         ejHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU5xDwCMG3ZooDsSBuFe+xz7J6u9wle1uQqQ6bOAp7pTt+Qz9Eu
	3OM3Up8GyQXx1GZyZ3sbT5J4fmxpCVxsCtOM/WCz8/T2vPPsanq0Tx255/nboG3FXjpmo4zAMqY
	VmK0Ln2dat2FFvoZQ6C/x9VswbfhxZ817eHj4GrmgTJGf0CUyo4zM0Gpa3akv8XI5mQ==
X-Received: by 2002:a37:624e:: with SMTP id w75mr24216935qkb.11.1553618885241;
        Tue, 26 Mar 2019 09:48:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwO7cpNWCis0wtdRI9O7EKJOkK7NL1pinZ1nwU7Eu2nkiBgs4M0+z03xK4UqRD6Kk3BPsFM
X-Received: by 2002:a37:624e:: with SMTP id w75mr24216900qkb.11.1553618884697;
        Tue, 26 Mar 2019 09:48:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553618884; cv=none;
        d=google.com; s=arc-20160816;
        b=IT1uzDCkTfgGi0mX7+l+2x4l1+yYjS2Jo5XGFmvo7DCrMBuqzJVTakWlLY27x/Jf1w
         jByykmckxvAVZF23QCozZcsp5gzTo6TohhG1m3kI63TPVZe/chyAGFUYgLAz9HwJOWyz
         oQjSHeOtK/PQabKknikhqMdIC6wVnk8fvmoGTeuoc2+dcrmgzUr/WLrY7zNhuL27/Ska
         J9iBtqGe4/pCfulz046CfyYF/fRx63aBzMtsc1a34yI5+LrjawsmUvXPYLb5emip3iyC
         cx2z5GqRwEtLEus6aU32gblLmw63rWS5i6zMTTVe4pTjhGdmNgmvr6RiPRmg9CUfUKBC
         O7hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6S96iBiVeL+UBOi95MsTRx8DtQV0M6xKTn3indFi6wY=;
        b=WGF8FdDIUuvlt67XVFSAQ2cldWI0sYnQHaklDC97BL9v5XInu9vlHkhVv0A5BPr2Xn
         /a8tlZHlVpfFt2HLqh8dQrZia/NpLIRvfBaxMasTjZyakTkEzAVo3chimSdYUqjBJ0/P
         dfcVx6rg1M8DtKa9Zq8PSXrb/pc9OeWqx3mSELz5IuPeiL7hmDiKrtlT173kGdmjgtx4
         5B+7M36lxfP4yRarKbXzRfecByndMyxgIY+lPNJ0EenfcoOznTk8QMzz+aG+E2y35a6+
         M2gFkyjodH0W7aROs943LUpM/+sK2U8O1N97tFjt+2POz/gdK9invIEVvZEMv2xy4Dhn
         K0Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b3si3201314qta.369.2019.03.26.09.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 09:48:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A11473168906;
	Tue, 26 Mar 2019 16:48:03 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 672F517595;
	Tue, 26 Mar 2019 16:48:01 +0000 (UTC)
From: jglisse@redhat.com
To: linux-kernel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
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
Subject: [PATCH v6 1/8] mm/mmu_notifier: helper to test if a range invalidation is blockable
Date: Tue, 26 Mar 2019 12:47:40 -0400
Message-Id: <20190326164747.24405-2-jglisse@redhat.com>
In-Reply-To: <20190326164747.24405-1-jglisse@redhat.com>
References: <20190326164747.24405-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 26 Mar 2019 16:48:03 +0000 (UTC)
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
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
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
2.20.1

