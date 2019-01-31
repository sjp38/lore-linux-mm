Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8F85C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 18:37:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CC4F218EA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 18:37:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CC4F218EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70EC78E0005; Thu, 31 Jan 2019 13:37:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 66BD78E0001; Thu, 31 Jan 2019 13:37:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50DD08E0005; Thu, 31 Jan 2019 13:37:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2110D8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 13:37:21 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id j5so4620858qtk.11
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 10:37:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=u45twQrCqvSrmqG5PGI8ES0fpLyoiBXcBf7TRg10A3c=;
        b=doTWko/A/1xi1iyrFgHOsjpIJKEpg+4iwX9VYOfPIxDeAl/sEKSc8zyeFAVBk61ZBw
         veonY5CPfSfMae4mBYnd23a6lQNOyZ6BQx5XO5QpW5i6KQdySIHq8RdHlerk9IHjNZyO
         LzhnZXwP/2wxA2KUfniFtMHzU596WtCV+GGawzt5ZtxfxN/9EDCEb/1xiLg/SkWUd/Ce
         5le6K0nOVdKscwwoNQTCtQFTwfvO+gf04xlKzWPcr3o9ig9C4PoysamornPremezXZtI
         icg+jiaxtolkDIjxEdSoDdjBojdjWMbxGR6u7rV6Wtp5RC/IDszHlEmOMzPa+Ktj/Uyw
         j4ng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeP4e2AbYE7h2xeA0kLACx8oE1xuaT3UrggzKlLZFd9ZYLfDFnz
	G7dsLT1EBmbz9mamls8XNzZJuOnCn87h9lvyGRNJeHIK0EqKSNvn+jUpbM5doh+UaD+MmIsG7/U
	GUrHD7M9w6XOO5CHEW2h6uYDA3y78/L0PUPrgM9/Apj6DZ+0QdbWRqeXYbIOMpD8VyQ==
X-Received: by 2002:a37:aa0c:: with SMTP id t12mr32111426qke.358.1548959840902;
        Thu, 31 Jan 2019 10:37:20 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6aqcKJI6SDstX/mlWDhUt6iXsi7DtjwZXYlNmVqLqD5Eir6odWI45tudrj4jsdj20UjUkn
X-Received: by 2002:a37:aa0c:: with SMTP id t12mr32111407qke.358.1548959840386;
        Thu, 31 Jan 2019 10:37:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548959840; cv=none;
        d=google.com; s=arc-20160816;
        b=YrKoKZCT7V5MURQikMbjL0IXwIBH2MkJEwoQycu1o4ZkG+615twuzIevCfxM9GI09C
         zsTfzD7aV0umZyT8J13U83do2MjZIA3tKJcyLdodowbNpnzD61pVAt3ht0JvWonTKaM1
         0SSPHFeo4hFBv9BNOSB4oV6SesndGr7O0Uzl/jhULMACt65Oh99MjlV+WmBefH9ANmRE
         11JL26VbScIYAL4HTDJzy5WNZb2Ji8kobVoAqmYCfrDz2Fg0okr2jRGuk+5yrNMVPZ/d
         JS6lpYYcHTHlyqIBmJySoKA9o6gnclW8ZvC+C94Ma5OP9UAtJPRIEFUgtDzSwyYEAOau
         NzFA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=u45twQrCqvSrmqG5PGI8ES0fpLyoiBXcBf7TRg10A3c=;
        b=OVmhCXR7H7Ioaw96QgRhqCzeXCgytrtv6kk73MwUHew/ocuKkIlxLApvX76LFpBpDY
         LP89+AETmYLSjFQfTsFdvpCM0SehJarxS3uqAdH5c5j32+Sff36cSXZ0V5RTwK4HkG82
         0gqjySDajAl16vcJhMJwx8CN3gLI6EyMnMpbcf+IhAb+qIdgWnfp9zxrkBrI5bgbbuqZ
         FgGc+cTLeP/pIkUI8Tq2o++GsiXl8iRmGQbdYKjMqiMoTbgnN58mRNjV3flq+OMHw2nX
         xU9IP1iIUXPFFBt95H6wKMlCHHx4dP4ZbrcU811ZwkljrO0eVJVXQKYg1LSSkt2fiDdT
         4dZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l13si67810qvm.104.2019.01.31.10.37.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 10:37:20 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8D85489AF1;
	Thu, 31 Jan 2019 18:37:19 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 87A7A18506;
	Thu, 31 Jan 2019 18:37:18 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	kvm@vger.kernel.org
Subject: [RFC PATCH 3/4] mm/mmu_notifier: set MMU_NOTIFIER_USE_CHANGE_PTE flag where appropriate
Date: Thu, 31 Jan 2019 13:37:05 -0500
Message-Id: <20190131183706.20980-4-jglisse@redhat.com>
In-Reply-To: <20190131183706.20980-1-jglisse@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Thu, 31 Jan 2019 18:37:19 +0000 (UTC)
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

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: kvm@vger.kernel.org
---
 include/linux/mmu_notifier.h | 13 +++++++++++++
 mm/ksm.c                     |  6 ++++--
 mm/memory.c                  |  3 ++-
 3 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index d7a35975c2bd..0885bf33dc9c 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -43,6 +43,19 @@ enum mmu_notifier_event {
 };
 
 #define MMU_NOTIFIER_EVENT_BITS order_base_2(MMU_NOTIFY_EVENT_MAX)
+/*
+ * Set MMU_NOTIFIER_USE_CHANGE_PTE only when the page table it updated with the
+ * set_pte_at_notify() and when pte is updated from read and write to read only
+ * with same pfn or from read only to read and write with different pfn. It is
+ * illegal to set in any other circumstances.
+ *
+ * Note that set_pte_at_notify() should not be use outside of the above cases.
+ * When updating a range in batch (like write protecting a range) it is better
+ * to rely on invalidate_range_start() and struct mmu_notifier_range to infer
+ * the kind of update that is happening (as an example you can look at the
+ * mmu_notifier_range_update_to_read_only() function).
+ */
+#define MMU_NOTIFIER_USE_CHANGE_PTE (1 << MMU_NOTIFIER_EVENT_BITS)
 
 #ifdef CONFIG_MMU_NOTIFIER
 
diff --git a/mm/ksm.c b/mm/ksm.c
index 97757c5fa15f..b7fb7b560cc0 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1051,7 +1051,8 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 
 	BUG_ON(PageTransCompound(page));
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR |
+				MMU_NOTIFIER_USE_CHANGE_PTE, vma, mm,
 				pvmw.address,
 				pvmw.address + PAGE_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
@@ -1140,7 +1141,8 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	if (!pmd)
 		goto out;
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, mm, addr,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR |
+				MMU_NOTIFIER_USE_CHANGE_PTE, vma, mm, addr,
 				addr + PAGE_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
 
diff --git a/mm/memory.c b/mm/memory.c
index a8c6922526f6..daf4b0f92af8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2275,7 +2275,8 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
 
 	__SetPageUptodate(new_page);
 
-	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, vma, mm,
+	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR |
+				MMU_NOTIFIER_USE_CHANGE_PTE, vma, mm,
 				vmf->address & PAGE_MASK,
 				(vmf->address & PAGE_MASK) + PAGE_SIZE);
 	mmu_notifier_invalidate_range_start(&range);
-- 
2.17.1

