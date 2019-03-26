Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F056CC10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:48:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AD46A205F4
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:48:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AD46A205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86BB56B0297; Tue, 26 Mar 2019 12:48:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81F826B0298; Tue, 26 Mar 2019 12:48:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70F156B0299; Tue, 26 Mar 2019 12:48:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 391026B0297
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:48:28 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id 35so14059494qty.12
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:48:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=jnvlAV+GWfMx/7xQbFXaF0JgvpgKRF2qvBTJuIYTYOk=;
        b=D76z0XJ5uO/yoYIMbDnWQx63DTyNH0Bjs5Xdvya4ZGp6WgDfKjBpvptf5gBe6HtI1B
         ev5KHAVyZBQ/b2XOYXhAVdNFRKGJG8KNtSNI0lcrMg7m/TDA+KK7f8s327G38hgW5ZWD
         9ee8fSH2qhdWQB9xQNzrKcR+b1rxB0LTaZ/nE7/SPXhEsW0ZhE38QDF7/+wo4+nYHC7H
         ZEABkAPdpAM0WHeyVY2D/FNNuoDGOItoBazUkAaRDNO1XKE+opJxF6zBt7U5x6to80dE
         BOqiOB3pnIqwl70rImJtWb/e332UO7uFQBDcvFK7QHl7EnczBC/oRcGAfGzQxgkejrXh
         TsGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWlFQGi5HIp8QHQWFhGbbbqpnJJiJY7ya1s0sPRDzkb9yqZDMj0
	csxnVx9DaG5ff6+nh7oQ6nZSZTGXiqwHfLiVkESd0QlXLhGprm4bPJ8WAEwzHOWucu7+xo8GkOx
	DwQtmhPqmyCx9PycXUHvPEKKyhefhMbTxmB1S7HCeI78kISIRgQOYNAQ9lQJ+ieHyIg==
X-Received: by 2002:a37:784:: with SMTP id 126mr24287211qkh.10.1553618908011;
        Tue, 26 Mar 2019 09:48:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx55GVNwmoFPjHG9+7g6vF5xHLfb9AH86ZrSYRkOI4V2NJmqECy3VkHTyg7UyHMjj9clmKi
X-Received: by 2002:a37:784:: with SMTP id 126mr24287174qkh.10.1553618907430;
        Tue, 26 Mar 2019 09:48:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553618907; cv=none;
        d=google.com; s=arc-20160816;
        b=R1kozFGrKbJFishz2n3MdnZMZegfuNgoX1VF2KTCgy2jtNwKa4Qr+hLkRYr1eLm6bD
         wWEKAVX23RQJa4pR0xRc3J+kAZl7kVcSLv8yzm4DObdUCFvYw8ydfZ23FS5wouy2nTWq
         ZkPlOOzG4dcHkb28puQFGPjmmbMY2UA7lL5SWiKlu5WmbKbW4UrZxpJg15wL2oVSf4LA
         jJ99yCFApNhbTmlPYKYdIpyCi0+hgeB/iq2CP2cCB8mOkbe0Tajx3xWx29pBYay3c3rj
         kAav3BLt/5s1llm2G/VhscNv1dAWEu7d/QRU1I9G90azMDe+YOQhKR8E1j44WuNi2QDs
         Bnjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=jnvlAV+GWfMx/7xQbFXaF0JgvpgKRF2qvBTJuIYTYOk=;
        b=Dv6ITq7bnQ/gUW2hVcvcPI7ea6d1Y+j21nNveq57O7xMaPygOnBGJuuB+AW/J/61U7
         /b8qNnyCYOf+DOYkTFM2//g4v6toJHvriFb8vIm1RSn5cuI/vbPs1Zy3ZIi8AGqGuRnw
         A0edqf2tNZxbOj9fjHNTvYLtdt1eS1tjNUi2yk0fJLicorzh35u2WNnvi+dPmb5agixK
         /U8CvpbGmssVtgbmJipUChBHEYRepTRlqLtx2myX/vEO1By5QVJ+GsbAfVIcD1/lTAGq
         pNR6LYSdaOD2/7vCHApiTz4FMlLZmX6LT8wY1DJ1Yu1qLWrs8uEalI/F7rtLMx9Y6HHg
         MSAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k26si11111636qve.94.2019.03.26.09.48.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 09:48:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7399A3086212;
	Tue, 26 Mar 2019 16:48:26 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 485878428A;
	Tue, 26 Mar 2019 16:48:24 +0000 (UTC)
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
	Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v6 8/8] mm/mmu_notifier: mmu_notifier_range_update_to_read_only() helper
Date: Tue, 26 Mar 2019 12:47:47 -0400
Message-Id: <20190326164747.24405-9-jglisse@redhat.com>
In-Reply-To: <20190326164747.24405-1-jglisse@redhat.com>
References: <20190326164747.24405-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 26 Mar 2019 16:48:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Helper to test if a range is updated to read only (it is still valid
to read from the range). This is useful for device driver or anyone
who wish to optimize out update when they know that they already have
the range map read only.

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
 include/linux/mmu_notifier.h |  4 ++++
 mm/mmu_notifier.c            | 10 ++++++++++
 2 files changed, 14 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 0379956fff23..b6c004bd9f6a 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -259,6 +259,8 @@ extern void __mmu_notifier_invalidate_range_end(struct mmu_notifier_range *r,
 				  bool only_end);
 extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
+extern bool
+mmu_notifier_range_update_to_read_only(const struct mmu_notifier_range *range);
 
 static inline bool
 mmu_notifier_range_blockable(const struct mmu_notifier_range *range)
@@ -568,6 +570,8 @@ static inline void mmu_notifier_mm_destroy(struct mm_struct *mm)
 {
 }
 
+#define mmu_notifier_range_update_to_read_only(r) false
+
 #define ptep_clear_flush_young_notify ptep_clear_flush_young
 #define pmdp_clear_flush_young_notify pmdp_clear_flush_young
 #define ptep_clear_young_notify ptep_test_and_clear_young
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index abd88c466eb2..ee36068077b6 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -395,3 +395,13 @@ void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
 	mmdrop(mm);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister_no_release);
+
+bool
+mmu_notifier_range_update_to_read_only(const struct mmu_notifier_range *range)
+{
+	if (!range->vma || range->event != MMU_NOTIFY_PROTECTION_VMA)
+		return false;
+	/* Return true if the vma still have the read flag set. */
+	return range->vma->vm_flags & VM_READ;
+}
+EXPORT_SYMBOL_GPL(mmu_notifier_range_update_to_read_only);
-- 
2.20.1

