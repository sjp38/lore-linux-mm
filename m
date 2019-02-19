Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BB31C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:05:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5EF0321738
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:05:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5EF0321738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 075668E000C; Tue, 19 Feb 2019 15:05:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 024DC8E0002; Tue, 19 Feb 2019 15:05:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E7F608E000C; Tue, 19 Feb 2019 15:05:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id BFCF88E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:05:56 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id k37so21085645qtb.20
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:05:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1rXUTed8CnGwTcmPq0oCfhnLKbGw3aW6rBbzJhdygy8=;
        b=OvinrxoLH6511Q1lB4R3vQOdYyQNLHNoCC+L8/RhkpARDfZmD7L5x0qaFc0yHZpW3j
         Wz0kkEp3ekfpIvspAikNPUOoj73Ci9z5fYC2ULMNuFZlWwUJkhJTeabfvl0ZyW/oeFBd
         mhToYWYkzz9Y8nKKvnQDskQOIQbbbvLRaMNt+vOvXJcoaUZbT7hDMooq1PN8S3xKryYl
         eP0BziNwD2qpYDo3Mtu0ernPk8T5UIHv9QrXkle5v6wgRTNicCyqj8F8dY+NS7jx5D4b
         +L+gVy5m3rk9HOKpt2nBA1FB1BjYToQ9KAeIasfAlT6ZN0FU4YhFWpGOLI7ePFOdeMCd
         BZXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub2ii0luO2O+lJfGRPSPufJulmJGCO1gfSeW+SmMgbcISjGiMKg
	vuNunTbRORBIHDC91bHxTTdAIuPf7t0+4JUSsJPfFlBZHUsg+xpOjXyKaAv/PfHL0KR/LxbpOFP
	WSglIjMguqvfCLFQDXYj60s8vFcMncecMarJwiL473OQ86kch6ie/NlsXpoQb5HvaBg==
X-Received: by 2002:ae9:f712:: with SMTP id s18mr21289866qkg.83.1550606756572;
        Tue, 19 Feb 2019 12:05:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZTmRlwxO6eLrs5XFaoipVg3Usx61wFfpSW8neSkhankA3qBVcSfi/CYl40/27QjW9JYuPd
X-Received: by 2002:ae9:f712:: with SMTP id s18mr21289643qkg.83.1550606753137;
        Tue, 19 Feb 2019 12:05:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550606753; cv=none;
        d=google.com; s=arc-20160816;
        b=YaewFunTXgzL4shZLZKm44noUWnwnHyWzsdBpwHyjBfnn+rwxY7m6lCLS+c4euDcvc
         vYpLz05f7eEt+3lwPTP7tpy13R4Wjbd8wme5uTW91U5OTp7yurh+C/G2GOZN2Nx3Pylw
         ce3EtABmaAn4VoSwn8tBK0QdNB4G12CyGJBzMR2V1jGstC5//wWGWGGviQP0BbaXlXNm
         euHeBC+XMecVgsF8sBVh8Tqu5AqV2YLIUIO+DHD3V3d/E85uES9w8aJcPC8tk4VY3KU0
         jxob19nByyRdeku8a4FvjyzaYFhHXGmFifBFDO41bzYA5oTp2wWsvemQ9x/+80TnSDLQ
         uvUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1rXUTed8CnGwTcmPq0oCfhnLKbGw3aW6rBbzJhdygy8=;
        b=th+JWHhY0ksHW64edDGzHY5J3lfFR7Jp6MiswbpE//4icwjMJ/Vrxb/U5gl1/P/DiM
         V4K+RV6E6Z8iG9bP0x4SX29byr515tjPvb/EUbB7o+URj4xq+SuhTQNE/LjO+99cVGqv
         C6owOXQ/OuraxT/3w8o8XGgG1JcFFb+gGGM9+2EL/J6qjtfxCAkqWRDA2cdrf15asg4X
         olDWwAvuGIJAUWQOkggDbOA+8xKP/BGZzp3bsdwEgrrtGRMEQmOvRY5nJPfoUcFBC82/
         cVG+TjkBj2qASgf7XHWF6PNyVvyCjl720aggTgs8+T820Q/5tO4m/VHVp46ZyKeYDxo3
         +hEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b21si1399457qvd.134.2019.02.19.12.05.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 12:05:53 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0D706C074132;
	Tue, 19 Feb 2019 20:05:52 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-134.rdu2.redhat.com [10.10.122.134])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C1DEA6013C;
	Tue, 19 Feb 2019 20:05:30 +0000 (UTC)
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
Subject: [PATCH v5 8/9] mm/mmu_notifier: mmu_notifier_range_update_to_read_only() helper
Date: Tue, 19 Feb 2019 15:04:29 -0500
Message-Id: <20190219200430.11130-9-jglisse@redhat.com>
In-Reply-To: <20190219200430.11130-1-jglisse@redhat.com>
References: <20190219200430.11130-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 19 Feb 2019 20:05:52 +0000 (UTC)
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
2.17.2

