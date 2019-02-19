Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24A38C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:05:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCE0C21773
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:05:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCE0C21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 46D368E000B; Tue, 19 Feb 2019 15:05:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41DF08E0002; Tue, 19 Feb 2019 15:05:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2E6068E000B; Tue, 19 Feb 2019 15:05:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 04E7C8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:05:36 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id k66so635373qkf.1
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:05:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=X8kdPUvC42ROC7+rczfKExqL8lE4yK5xysqqrdCsrac=;
        b=el/aSMUgaBKssnr1y0XI9YaNMcB8s14JqUEPf8q1WJ5edCVqSJ7xYwxPzcJ9M7zMuL
         JmScHonaNFAr4QGQoTdcCWWsOp2PoSRXvRuP5kped72dhRdHV6+Svj8dCgcO0WI2zS65
         XTfcjuDqy/vQtZ3vDZWUw+Ktesib59lir12Zit97gXrkIZyAeyPRMo3CAU2OQme9a3Z0
         xTC1FfwF6BFkxzqMbFP8bjEfDlC1MGPetDVniBdV0WQhxQ+dkJWxgK8O5KG4eMXvk7Cl
         +itxY106QsKWaJb6OhA3VvtQhv4Ai483oe7gIgdNlB8wwAAR+IgbJCOw155GEKuk8h1H
         gfpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYAK/Y1FuNrwkCqHbAOSfyPfIt/lh8nBqRZu6NnlAUVR/f9cOcB
	2SZAlnC8oTKjZaVNkZ0qBpGLE2XhSr9AmHh908vHo8X3h7uO5TPqtnHuyw9oRDAPAJ60kRPO2tZ
	bDuX2ctkbxzmwyrJRqb7GvMdJQOsm0p9G/extuLvy/SBXsGyOs9dUlqjDxidkvnwzZg==
X-Received: by 2002:a37:2fc1:: with SMTP id v184mr2883735qkh.71.1550606735750;
        Tue, 19 Feb 2019 12:05:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYnWazzmcAi/IOtmEWULoOUL2oqzab11C9R2eafftHeW00Cwq1nlyn9VfLu1wb5ugxEO+ex
X-Received: by 2002:a37:2fc1:: with SMTP id v184mr2883473qkh.71.1550606731930;
        Tue, 19 Feb 2019 12:05:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550606731; cv=none;
        d=google.com; s=arc-20160816;
        b=n5W0rSUenVweayvIbJs26ElE17dIqLA1roZkDc3c5wpPt1W1gcc8YDjyeRldVves8m
         OcMIOzT0xZkziG0oRWTadbqcU/3Lypob1Ia2elYni3To8+ENFbZKQH6jTGnqLA8qMa/u
         YYYY97S+DL65wbMSbsqCf4ovIm73GW5BlfrNFDYRqLLJY4kgEYPZbW0XyKyMMW2cAHdM
         C8oEHPRu5wY8ABWIB3/Kp0ogStra/RFahc6HT3yTOEHi0DHgHnH6cByhS7jjKd9ggtwY
         h9EbM+aIspzJWD0rEia14CmHLn+kP/jpPs5F4cVaapvRbwMwPMWR5mBcv7pIjWH2E8sE
         U4LQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=X8kdPUvC42ROC7+rczfKExqL8lE4yK5xysqqrdCsrac=;
        b=nExwS0sneL27pkYjhBwc0sVqNNiMX8NqzPZMHwJrckKBewsSm90IvQ36i+LeAxj9DY
         T8w2gZObZXMwotF2OIl+ib6M3Fg1vk6AZzelzn9UorYSkGw2delCIbwAoFilLgCLVWDi
         Ay8RKLO+qGqAmEyIIjk7bl3rMsY1Q+LXgq6QTtUYPD9QdVyzky336GqMI6E+gS4YKTto
         pO5KQlQNyjdw+QTJNpW/T+OnlEdYNr1RrcawATGWM9+Bw3RYWY5PX/UOqYmPBJ3rDZA9
         LBsoBMBRn/RR2WKCcCHvp/t+WVNjIHQ5t97Li7FNilr5FKGk/ZCmklYJhdckBbt43t8a
         DZ+g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k27si10334410qki.263.2019.02.19.12.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 12:05:31 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B1E58C074132;
	Tue, 19 Feb 2019 20:05:30 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-134.rdu2.redhat.com [10.10.122.134])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BA9FC6013C;
	Tue, 19 Feb 2019 20:05:27 +0000 (UTC)
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
Subject: [PATCH v5 7/9] mm/mmu_notifier: pass down vma and reasons why mmu notifier is happening v2
Date: Tue, 19 Feb 2019 15:04:28 -0500
Message-Id: <20190219200430.11130-8-jglisse@redhat.com>
In-Reply-To: <20190219200430.11130-1-jglisse@redhat.com>
References: <20190219200430.11130-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 19 Feb 2019 20:05:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

CPU page table update can happens for many reasons, not only as a result
of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
as a result of kernel activities (memory compression, reclaim, migration,
...).

Users of mmu notifier API track changes to the CPU page table and take
specific action for them. While current API only provide range of virtual
address affected by the change, not why the changes is happening

This patch is just passing down the new informations by adding it to the
mmu_notifier_range structure.

Changes since v1:
    - Initialize flags field from mmu_notifier_range_init() arguments

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
 include/linux/mmu_notifier.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 62f94cd85455..0379956fff23 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -58,10 +58,12 @@ struct mmu_notifier_mm {
 #define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
 
 struct mmu_notifier_range {
+	struct vm_area_struct *vma;
 	struct mm_struct *mm;
 	unsigned long start;
 	unsigned long end;
 	unsigned flags;
+	enum mmu_notifier_event event;
 };
 
 struct mmu_notifier_ops {
@@ -363,10 +365,12 @@ static inline void mmu_notifier_range_init(struct mmu_notifier_range *range,
 					   unsigned long start,
 					   unsigned long end)
 {
+	range->vma = vma;
+	range->event = event;
 	range->mm = mm;
 	range->start = start;
 	range->end = end;
-	range->flags = 0;
+	range->flags = flags;
 }
 
 #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
-- 
2.17.2

