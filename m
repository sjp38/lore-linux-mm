Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44B66C169C4
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 18:37:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 064CE218AC
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 18:37:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 064CE218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5ABA48E0006; Thu, 31 Jan 2019 13:37:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 507E98E0001; Thu, 31 Jan 2019 13:37:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3ACD88E0006; Thu, 31 Jan 2019 13:37:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1DD8E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 13:37:22 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id t18so4712571qtj.3
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 10:37:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8tiJVUoyMizFoUbRG/0d46To2uc9w1MUhAWOmZ5Ruc8=;
        b=rEWlHRiTGKhEu+KG5oS2u4XfBwurbWNPvhFB1ShFEjhazS6KO4Wt4oDIT5U7y+Fct/
         dnlbyNdyO3RrCh1pJg/hbXD0071DZYFNATJgJ1aoOZIKliy7b+tvAqzvzKyHs6W4baXH
         tBa0XDyaDHpo7aPe3agUuSez5tT+cWmkNLsnr6wgwD1VRYlR1f5jCzJODR7FLjkr6Ub1
         1V8CdZiA95Oy5xZPEJm7GGNRu9B4qU/8yp9oE0/Xa49ppBCNJ6aEBEeMUtdcyppymPjq
         Ro7tFuQ5oEUIbvgf7mzXi/2EG0KrzZxT3nCNGnnmjjwKvv1yD/FQXeqysO5SgilOF/l4
         OggQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeZfavoxxYebcv93JlN8s6CIqIvp01M2zK3x5axvtClPuYmqN6V
	ojGOmZlGC6rc1fTWd9qH5P+8ePKiiSRRZEkYLm0rANG+vVS2kl918n1H0vYX0o4iA5PwkfgTL6R
	k2Jx98Ak962iSNQ3RRG8PsBNq0VOinXAcNXFEgUBD5zD0Ekj88rQHM1+LgmRFOEEf+w==
X-Received: by 2002:a0c:b786:: with SMTP id l6mr34159889qve.244.1548959841830;
        Thu, 31 Jan 2019 10:37:21 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6nuDUQbrz4HAgGzRjeRlvY0G5+9Ct7BGNaYohaNpa5IIw6LFgOs4FxbZQhEU/rZH6fBEJ/
X-Received: by 2002:a0c:b786:: with SMTP id l6mr34159860qve.244.1548959841376;
        Thu, 31 Jan 2019 10:37:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548959841; cv=none;
        d=google.com; s=arc-20160816;
        b=WQ/0Kc/fdl8hTRDZhbVCPVN9YMzO9enjYSiIKJDp1YPxQlJZXSXlcKjh6H5Ni9ZxTW
         o8wIayKr+ZMYLTto2JQUurUUeR5uinqlLHS0GhTIYZ2Mi4IXmsKRusVMg0IpY/zlIkLH
         YRSXG2HLIqrf7fr0HNz7RV/9IeZsdQgSy4zuQZGDW1zchtM9jjJAy2pF5em0HLGOYPtb
         7Nst4pW5ZfxzgaC/HC17kICBpTLpO1dJQSX6NAcQzY4zNYDaePHiC4ri+Y9cYHx7sLtA
         IxdL1pCYKCMD6u9TMLYGiXmWd55EEQbOwNwVjHQcIfxcSTMDvGEchGh3i38DlieNxwI0
         QHtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=8tiJVUoyMizFoUbRG/0d46To2uc9w1MUhAWOmZ5Ruc8=;
        b=nsI1VpwCPYjMLTU8kq0IBqEPavF4gzrRjZxjfM4RYMGDcIpegNAfI4cPeNCQYyuTtJ
         noNMNTuZdUfA0C5RCovfvoBVMWsf4ESw1MdbH7ojjUN1qLyVIBm/0WRu6QGY/KhNiZwE
         6gfoSRuGn+ybAmhhDTYXCpTIYP0C5nrA13E5H6ZQkBirCAtSMaTqXZXm3rr3C109Woxm
         quSSoIc0PBLDaQiRJDqhpQ5KMUgfRX9TYfVJsmVCMJNY3jLWJTAtjk1BVMgktlwVPbXT
         e4NoMbfM+INCgYHsEa7kvmsAEFPC1NdKAKuZsgVSJDu0prG3tbKBjfK/ZXf9MM9Gxz/J
         ekiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o5si1654531qta.399.2019.01.31.10.37.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 10:37:21 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9F27F3D09;
	Thu, 31 Jan 2019 18:37:20 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A757217F7D;
	Thu, 31 Jan 2019 18:37:19 +0000 (UTC)
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
Subject: [RFC PATCH 4/4] kvm/mmu_notifier: re-enable the change_pte() optimization.
Date: Thu, 31 Jan 2019 13:37:06 -0500
Message-Id: <20190131183706.20980-5-jglisse@redhat.com>
In-Reply-To: <20190131183706.20980-1-jglisse@redhat.com>
References: <20190131183706.20980-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 31 Jan 2019 18:37:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Since changes to mmu notifier the change_pte() optimization was lost
for kvm. This re-enable it, when ever a pte is going from read and
write to read only with same pfn, or from read only to read and write
with different pfn.

It is safe to update the secondary MMUs, because the primary MMU
pte invalidate must have already happened with a ptep_clear_flush()
before set_pte_at_notify() is invoked (and thus before change_pte()
callback).

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: kvm@vger.kernel.org
---
 virt/kvm/kvm_main.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 5ecea812cb6a..fec155c2d7b8 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -369,6 +369,14 @@ static int kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 	int need_tlb_flush = 0, idx;
 	int ret;
 
+	/*
+	 * Nothing to do when MMU_NOTIFIER_USE_CHANGE_PTE is set as it means
+	 * that change_pte() will be call and it is a situation in which we
+	 * allow to only rely on change_pte().
+	 */
+	if (range->event & MMU_NOTIFIER_USE_CHANGE_PTE)
+		return 0;
+
 	idx = srcu_read_lock(&kvm->srcu);
 	spin_lock(&kvm->mmu_lock);
 	/*
@@ -398,6 +406,14 @@ static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 
+	/*
+	 * Nothing to do when MMU_NOTIFIER_USE_CHANGE_PTE is set as it means
+	 * that change_pte() will be call and it is a situation in which we
+	 * allow to only rely on change_pte().
+	 */
+	if (range->event & MMU_NOTIFIER_USE_CHANGE_PTE)
+		return;
+
 	spin_lock(&kvm->mmu_lock);
 	/*
 	 * This sequence increase will notify the kvm page fault that
-- 
2.17.1

