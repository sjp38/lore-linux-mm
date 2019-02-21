Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D957C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 01:22:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E71D12086D
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 01:22:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E71D12086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D7F618E0054; Wed, 20 Feb 2019 20:22:53 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C65788E0002; Wed, 20 Feb 2019 20:22:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ADFDA8E0054; Wed, 20 Feb 2019 20:22:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8260D8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 20:22:53 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id d13so24978692qth.6
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:22:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=DdNsBAsE5yh9vKBSWGYssGXDEeXdUI7+ToEzejghKHA=;
        b=mVkre4/r2NQ5XelamCAVffOVWvalqXsTUGm6jYP/Au4CMZDoS+cIKOds2O+R2llm0o
         MkDXy9mRf2fsay63e1lI19piJjjzYo2UFuhkEb6cZ9kuf9XpcUtlfO1gBFvb3EWNKc+K
         AqN/4VXO227yBOhtflZxLbvWY9hXOCGUHr8GMxGU6hbU39YKGAtgJ+L4KAT8sJFNtXps
         VlwbvbL19x05ZB9XckIp0iMm5Oo5eBRShuk4J8Tlz6NsCuK0dsbP3Y3U0GI1gu18egxU
         5x+xJgMAg2amVwtT3L78/muZ4/EJLmykZCEp5aJDl9gfMR3PvWcuh485/VhyOQ3eREIa
         90Pw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubfw9ccjvW3SJZykijNDRHT5IHDOjufsm2kB/RDOgcxGAJxpefc
	Jh5R+O8RSSxJUKeLjq45P8ghYQBUxCoYOS+/FFKW+JegZeqELFb8gOlTcjbjhzTtibrIdoqW9fL
	Z98UNF8joLzSMhJUqYP8X6746Q7wus6PBbqW7Pk79l0M4+ZUyGF81zAd9UWL9ieTPpA==
X-Received: by 2002:a05:620a:123b:: with SMTP id v27mr25556623qkj.29.1550712173320;
        Wed, 20 Feb 2019 17:22:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iak87PI6cpJSynN+uzfsQRKrPQqvG9oK26BjVdkunwVnEcFgsuKJr8E9M33wXVReGmx/YA1
X-Received: by 2002:a05:620a:123b:: with SMTP id v27mr25556604qkj.29.1550712172892;
        Wed, 20 Feb 2019 17:22:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550712172; cv=none;
        d=google.com; s=arc-20160816;
        b=Y/DsBANHUJsfO6uz0EJUvPaxS//5wLJewRnsKJvwmfLMD1c7OmsEJE8IN9fLRVNuXZ
         jNVMe3WivnEqsmbV4/IoETdJihT4Du4M3Fh1gpZW2BM02A7NMfmPSx2NNOhVsqLJ56Sw
         KopicMm50MFUO0coj4VCsO6PlQXof3uTKVi4qDoPxxSvmabG3S5G8XgWI6P/+BZBwjhs
         qE5O8kv31nT+ICYYahuxG+gH1Xfsp6FcLOf/wrfm2DN2gFB1ipdbrqbCPhBSk+mprq0Y
         c4i4xwZpqmNsADIh06bYiJVlz/7FT73y1fFuOaozVrIDu/1hDgNhIfWgWZBwkC/uwBIU
         ghtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=DdNsBAsE5yh9vKBSWGYssGXDEeXdUI7+ToEzejghKHA=;
        b=iD9zngrqy4bV2+JAPOL4LpYxHmO7UnIkJmeNFDUf0t/UFptCRIxiZZCR1WMkDJiupO
         ASWSvpw9sr9moDiIXBJgWxaPltoyY39gfA1M+9LfuCFi79N5qiYrOEhVDUT+P2EPSIQU
         +rxNKkQ3y+ls3KQrBZ2SpiRpJhG/Ni4/ZAVhdyycX/++xEXQwEqC297dkTEEc7olgH4o
         ejDr+PwvLwuyqjK+Jen/LGj2h9RlwKJQyrvFN1HoMyq5tsKYpuzptjpjeu8q84Ix1euZ
         6sGv7Dyi8TRkT8tx+9WVTqGES2NxXL2OTkCiZSaOBXuMwPxPbMvQfY/Ca2ZqExbym1rr
         5dBw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o6si245353qtq.127.2019.02.20.17.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 17:22:52 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 349DD307D911;
	Thu, 21 Feb 2019 01:22:52 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-120-249.rdu2.redhat.com [10.10.120.249])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B468F60BF2;
	Thu, 21 Feb 2019 01:22:50 +0000 (UTC)
From: jglisse@redhat.com
To: Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	kvm@vger.kernel.org
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v2 1/1] kvm/mmu_notifier: re-enable the change_pte() optimization.
Date: Wed, 20 Feb 2019 20:22:27 -0500
Message-Id: <20190221012227.13236-2-jglisse@redhat.com>
In-Reply-To: <20190221012227.13236-1-jglisse@redhat.com>
References: <20190221012227.13236-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Thu, 21 Feb 2019 01:22:52 +0000 (UTC)
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
---
 virt/kvm/kvm_main.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 629760c0fb95..0f979f02bf1c 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -369,6 +369,14 @@ static int kvm_mmu_notifier_invalidate_range_start(struct mmu_notifier *mn,
 	int need_tlb_flush = 0, idx;
 	int ret;
 
+	/*
+	 * Nothing to do when using change_pte() which will be call for each
+	 * individual pte update at the right time. See mmu_notifier.h for more
+	 * informations.
+	 */
+	if (mmu_notifier_range_use_change_pte(range))
+		return 0;
+
 	idx = srcu_read_lock(&kvm->srcu);
 	spin_lock(&kvm->mmu_lock);
 	/*
@@ -399,6 +407,14 @@ static void kvm_mmu_notifier_invalidate_range_end(struct mmu_notifier *mn,
 {
 	struct kvm *kvm = mmu_notifier_to_kvm(mn);
 
+	/*
+	 * Nothing to do when using change_pte() which will be call for each
+	 * individual pte update at the right time. See mmu_notifier.h for more
+	 * informations.
+	 */
+	if (mmu_notifier_range_use_change_pte(range))
+		return;
+
 	spin_lock(&kvm->mmu_lock);
 	/*
 	 * This sequence increase will notify the kvm page fault that
-- 
2.17.2

