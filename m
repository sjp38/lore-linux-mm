Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50F74C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:06:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 063BE21738
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 20:06:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 063BE21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A38AA8E0003; Tue, 19 Feb 2019 15:06:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E84B8E0002; Tue, 19 Feb 2019 15:06:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D8908E0003; Tue, 19 Feb 2019 15:06:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65F9C8E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 15:06:09 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id b6so620398qkg.4
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 12:06:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7aZ3rlOSOpqeHvTkHcjlxdFQmNAzoKPyodvuVEMV8wI=;
        b=hX0ZqLMYXyi4ZDnVaAmsq/AxV8owcBNFD4R8uEoVdAWNE+dmKxm91fq8e6VPnztUux
         CKlYWvH8q0UNlGJpesPGES2uJwAGnCWpcffhz7JTcRZDoPTrX3lvt6GKjSsL4SEXFNiH
         NpzLpMllW1RbywFZcR63Em0HgsY9csAaQKNFN7CduqVFtGiMqNclQN5BSQIp4tHGBK3A
         L5y2fm+sXVOBAMbeBO4IH2DPkwkvSLcb5ElaHQH3NgKF9rj6Uhs2gmWqlYbe0h3d8ONZ
         iJ+24LDaxV+B/NbwLedPURL1eqXrEVuvu69VSyd0aJT2NCJRMQtEITqJq/vNHhqGJx28
         EPHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZVjw+otmSWknjPZwQEeMaF50IbWbkhP7F1AXPgj1IRPaPmDorM
	wmepD7GwUutYF4RcpeXaw+udIVOJRysDK/7gN9GHJAd8x0DD6+iCv3JCDgHxScrS4sp1pEQK/6N
	X8MTBNHT1Kx7VHh8TkZNINrSWoXS3l+4EwWJEgnv+/8ObSuUmxBmkr+LdLQX5othP2A==
X-Received: by 2002:a37:884:: with SMTP id 126mr22559083qki.56.1550606769172;
        Tue, 19 Feb 2019 12:06:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbssxnD7/Ql4h4gTxERe3lmGDj8lD97l9MH38ttWWza8pK8jPHIKaXp5MIVkuRHfMH57U/K
X-Received: by 2002:a37:884:: with SMTP id 126mr22558678qki.56.1550606763179;
        Tue, 19 Feb 2019 12:06:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550606763; cv=none;
        d=google.com; s=arc-20160816;
        b=Z8kOomHu7tCgjM47k9/I4yripPbhTD2slZzljY0fZ/dPK7qIuhG2hNHS+C3UVYla+H
         zP6nJ3E6+flAMdsWQDb3ASdwB/q+UuH6tTpGTLCcjHTZU+Ohh4tuOdXHbmnpUi3EVpvF
         CwvYPDSawbV0Pv02w1s5smJ0ZErT74dAoZtnRppG7kZ7aSiAS8f1toRTDyOLAbMhqc8i
         nzlQzLkTTywZXtI5PsY09hMcqKyd39hxxNPGDFtIP/YrsodLblSFeJeK903b1Qwy5tjK
         UMfKaPM9//EX1lDEYW69b2aKv2HOiTunKseU4pQVOZLYlteYvBvZGpxnSdR4kBzG40M0
         +3BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=7aZ3rlOSOpqeHvTkHcjlxdFQmNAzoKPyodvuVEMV8wI=;
        b=H1caZn/YnZCnAi+wgqjmItCfZR9dC7Q8pFTOeQDWDUuj/NOJb5bcxCYXTUaS2knLzj
         D7UC4/Z8taHYq7zwssfP1MoUxLsH8bEpyyxMXWhDxZwhHcsu8cC/teH6tXMdKBKWBgkH
         TCGd7zW9JVwo3B9uXlEgEuX+EcHIpZWk0qU1fBq3btYTP8HbsElT/dmQl9Ifn5OWEEP1
         bpOL0lwh20eM/I/iRRnKtGUsdY018zPCSfOVLqOmcaxY4/01uYa5QamDlaHezVC30jvn
         Dlee0GmZ00al1Y8Bpzn4xmFWXR+d358ZnDGokxj9KSkB5ggjlNJB1auET1IB/57J29As
         bNPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m39si3264294qtf.226.2019.02.19.12.06.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 12:06:03 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 30C07C074F05;
	Tue, 19 Feb 2019 20:06:02 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-134.rdu2.redhat.com [10.10.122.134])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3E7616013D;
	Tue, 19 Feb 2019 20:05:52 +0000 (UTC)
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
Subject: [PATCH v5 9/9] mm/mmu_notifier: set MMU_NOTIFIER_USE_CHANGE_PTE flag where appropriate v2
Date: Tue, 19 Feb 2019 15:04:30 -0500
Message-Id: <20190219200430.11130-10-jglisse@redhat.com>
In-Reply-To: <20190219200430.11130-1-jglisse@redhat.com>
References: <20190219200430.11130-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 19 Feb 2019 20:06:02 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

When notifying change for a range use MMU_NOTIFIER_USE_CHANGE_PTE flag
for page table update that use set_pte_at_notify() and where the we are
going either from read and write to read only with same pfn or read only
to read and write with new pfn.

Note that set_pte_at_notify() itself should only be use in rare cases
ie we do not want to use it when we are updating a significant range of
virtual addresses and thus a significant number of pte. Instead for
those cases the event provided to mmu notifer invalidate_range_start()
callback should be use for optimization.

Changes since v1:
    - Use the new unsigned flags field in struct mmu_notifier_range
    - Use the new flags parameter to mmu_notifier_range_init()
    - Explicitly list all the patterns where we can use change_pte()

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
 include/linux/mmu_notifier.h | 34 ++++++++++++++++++++++++++++++++--
 mm/ksm.c                     | 11 ++++++-----
 mm/memory.c                  |  5 +++--
 3 files changed, 41 insertions(+), 9 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index b6c004bd9f6a..0230a4b06b46 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -40,6 +40,26 @@ enum mmu_notifier_event {
 	MMU_NOTIFY_SOFT_DIRTY,
 };
 
+/*
+ * @MMU_NOTIFIER_RANGE_BLOCKABLE: can the mmu notifier range_start/range_end
+ * callback block or not ? If set then the callback can block.
+ *
+ * @MMU_NOTIFIER_USE_CHANGE_PTE: only set when the page table it updated with
+ * the set_pte_at_notify() the valid patterns for this are:
+ *      - pte read and write to read only same pfn
+ *      - pte read only to read and write (pfn can change or stay the same)
+ *      - pte read only to read only with different pfn
+ * It is illegal to set in any other circumstances.
+ *
+ * Note that set_pte_at_notify() should not be use outside of the above cases.
+ * When updating a range in batch (like write protecting a range) it is better
+ * to rely on invalidate_range_start() and struct mmu_notifier_range to infer
+ * the kind of update that is happening (as an example you can look at the
+ * mmu_notifier_range_update_to_read_only() function).
+ */
+#define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
+#define MMU_NOTIFIER_USE_CHANGE_PTE (1 << 1)
+
 #ifdef CONFIG_MMU_NOTIFIER
 
 /*
@@ -55,8 +75,6 @@ struct mmu_notifier_mm {
 	spinlock_t lock;
 };
 
-#define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
-
 struct mmu_notifier_range {
 	struct vm_area_struct *vma;
 	struct mm_struct *mm;
@@ -268,6 +286,12 @@ mmu_notifier_range_blockable(const struct mmu_notifier_range *range)
 	return (range->flags & MMU_NOTIFIER_RANGE_BLOCKABLE);
 }
 
+static inline bool
+mmu_notifier_range_use_change_pte(const struct mmu_notifier_range *range)
+{
+	return (range->flags & MMU_NOTIFIER_USE_CHANGE_PTE);
+}
+
 static inline void mmu_notifier_release(struct mm_struct *mm)
 {
 	if (mm_has_notifiers(mm))
@@ -509,6 +533,12 @@ mmu_notifier_range_blockable(const struct mmu_notifier_range *range)
 	return true;
 }
 
+static inline bool
+mmu_notifier_range_use_change_pte(const struct mmu_notifier_range *range)
+{
+	return false;
+}
+
 static inline int mm_has_notifiers(struct mm_struct *mm)
 {
 	return 0;
diff --git a/mm/ksm.c b/mm/ksm.c
index b782fadade8f..41e51882f999 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1066,9 +1066,9 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 	BUG_ON(PageTransCompound(page));
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm,
-				pvmw.address,
-				pvmw.address + PAGE_SIZE);
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR,
+				MMU_NOTIFIER_USE_CHANGE_PTE, vma, mm,
+				pvmw.address, pvmw.address + PAGE_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
 
 	if (!page_vma_mapped_walk(&pvmw))
@@ -1155,8 +1155,9 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	if (!pmd)
 		goto out;
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm, addr,
-				addr + PAGE_SIZE);
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR,
+				MMU_NOTIFIER_USE_CHANGE_PTE,
+				vma, mm, addr, addr + PAGE_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
 
 	ptep = pte_offset_map_lock(mm, pmd, addr, &ptl);
diff --git a/mm/memory.c b/mm/memory.c
index 45dbc174a88c..cb71d3ff1b97 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2282,8 +2282,9 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 
 	__SetPageUptodate(new_page);
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm,
-				vmf->address & PAGE_MASK,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR,
+				MMU_NOTIFIER_USE_CHANGE_PTE,
+				vma, mm, vmf->address & PAGE_MASK,
 				(vmf->address & PAGE_MASK) + PAGE_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
 
-- 
2.17.2

