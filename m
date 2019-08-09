Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9669AC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46A3E2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:03:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46A3E2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEA7B6B0287; Fri,  9 Aug 2019 12:01:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9D606B0289; Fri,  9 Aug 2019 12:01:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CCBFF6B028B; Fri,  9 Aug 2019 12:01:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A26E6B0287
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:17 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id e8so46642774wrw.15
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yquaGfW2+nfmqcdNbDOv/m1HA9hMGeQCbqvynbv34WI=;
        b=dn/AcbldnfsLdPZXTjh7O7zXqUT8pY66bphxTrOMYk1lj83SuDZok9ncJpqGxOGAEt
         lTYwTmYVrcJcIp8Iieu7UuYl1VI00K/kF0LTmN6qgimNSzRxgqbH2S1PbgXYCep9zxbx
         QvxC1+3O9tV2suA45G3aopKbBFehMpcikFG1WEU3Qr7pP71F5GNzk+3CamaAQgG7Q6Mg
         8x+U9afxS+QAghILc6UaVTsO5+JvFZo+YTdKSuqF3bjSV1TZ9ByvroPKJ828UB9sFNMT
         64kHOGDGVovRLdI6rrjqoCt2S1HCaBaHCLYky01H3Ez30xKktuFC3n5iE5X2WbEDrKhA
         +VWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXtJWOO6/RC4Mje9iyCuLVi3wBiyn3EctSbkMY4NkuqEAFV89Uk
	FyKbIJB4i25kz5gnsurA/86lcwx8NSdF3oFyt5AxHm0KWRAJtp8EcdxW5vwreQN9vNq+ZXonwbx
	BAcTGDR35MYWsdBNbjo6yqlvyhWGACQ5Ujpnk9TMbF7vGXWSLe3rCF2vMd17gMW+lFg==
X-Received: by 2002:a1c:a909:: with SMTP id s9mr11677676wme.20.1565366477018;
        Fri, 09 Aug 2019 09:01:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDJ2223+gZu7+0Fb9fbTQRC6Lf0i2B2hsBL22mLVKBtHit7W2YXJvkEpPjL9K92WXF5dYJ
X-Received: by 2002:a1c:a909:: with SMTP id s9mr11677434wme.20.1565366474158;
        Fri, 09 Aug 2019 09:01:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366474; cv=none;
        d=google.com; s=arc-20160816;
        b=bVSacdJyK4dBVLVkhQtXYuO+2rigaiThNpN81L/0w3hMCWd0UirxBD3gHeekiw9wF5
         uJocwgSAQgKA7sUtcClEaOFWff+a9l0XZz0zCwr+w8O6NGdbFHz2mp98ahbxOFb8lBT+
         K9zjbiTMuuVZ/nzUlLGwNQH6VQT/W1vsvZHIaFmxuVq3elsW0UVWPmrhE+qncXLqVKcL
         N91bZhMFYZ7uHtRuRGBznU1teipD3H2uwST94zZUbxWhyQpU4g8QcWBkMYWWBnHy00Tv
         U5v2eanJRPfAueYk0QjJCpNptTZOJelOuTpnPr+4E2tz6a/VKLc+mkV/YJG+oU6cburz
         4EBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=yquaGfW2+nfmqcdNbDOv/m1HA9hMGeQCbqvynbv34WI=;
        b=GdrQf9P92kHxkhkulz2KcUYP6nAKzr5PWC9JTK+0QPQMN4NC97dDIe+f8uzY8AgZyD
         mba9IcY/w2ChI2UiZHPWFONNdS4WZgmYQoDODOtoEiw747bEPkifbu8E2yjFk9yZflbw
         KefBhaaEmrBlmQXXI3WZjVMk5jw0TLIQqgV8I4hlDB6BixORpxnzbJdFqqWdnh+SYsFX
         Kf4U4JGDFf0U14JwABRn57jrPZ678Yj+QfjvLhPtcozoZmv2hB47GSrpAIt5qTsMlXTc
         3g4Q2x3SOYJqx0Z9vL50GJfmEKEvQ77l+GQ8wdsWDiTsA/oTUASIXqhRZ4KULntSIWz7
         PYdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id b131si3986237wmc.75.2019.08.09.09.01.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 932DB3031EB7;
	Fri,  9 Aug 2019 19:01:13 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 9C12A305B7A9;
	Fri,  9 Aug 2019 19:01:12 +0300 (EEST)
From: =?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
To: kvm@vger.kernel.org
Cc: linux-mm@kvack.org, virtualization@lists.linux-foundation.org,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tamas K Lengyel <tamas@tklengyel.com>,
	Mathieu Tarral <mathieu.tarral@protonmail.com>,
	=?UTF-8?q?Samuel=20Laur=C3=A9n?= <samuel.lauren@iki.fi>,
	Patrick Colp <patrick.colp@oracle.com>,
	Jan Kiszka <jan.kiszka@siemens.com>,
	Stefan Hajnoczi <stefanha@redhat.com>,
	Weijiang Yang <weijiang.yang@intel.com>, Zhang@kvack.org,
	Yu C <yu.c.zhang@intel.com>,
	=?UTF-8?q?Mihai=20Don=C8=9Bu?= <mdontu@bitdefender.com>,
	=?UTF-8?q?Adalbert=20Laz=C4=83r?= <alazar@bitdefender.com>
Subject: [RFC PATCH v6 42/92] KVM: MMU: Handle host memory remapping and reclaim
Date: Fri,  9 Aug 2019 18:59:57 +0300
Message-Id: <20190809160047.8319-43-alazar@bitdefender.com>
In-Reply-To: <20190809160047.8319-1-alazar@bitdefender.com>
References: <20190809160047.8319-1-alazar@bitdefender.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Yang Weijiang <weijiang.yang@intel.com>

Host page swapping/migration may change the translation in
EPT leaf entry, if the target page is SPP protected,
re-enable SPP protection in MMU notifier. If SPPT shadow
page is reclaimed, the level1 pages don't have rmap to clear.

Signed-off-by: Yang Weijiang <weijiang.yang@intel.com>
Message-Id: <20190717133751.12910-10-weijiang.yang@intel.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/mmu.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 24222e3add91..0b859b1797f6 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -2004,6 +2004,24 @@ static int kvm_set_pte_rmapp(struct kvm *kvm, struct kvm_rmap_head *rmap_head,
 			new_spte &= ~PT_WRITABLE_MASK;
 			new_spte &= ~SPTE_HOST_WRITEABLE;
 
+			/*
+			 * if it's EPT leaf entry and the physical page is
+			 * SPP protected, then re-enable SPP protection for
+			 * the page.
+			 */
+			if (kvm->arch.spp_active &&
+			    level == PT_PAGE_TABLE_LEVEL) {
+				struct kvm_subpage spp_info = {0};
+				int i;
+
+				spp_info.base_gfn = gfn;
+				spp_info.npages = 1;
+				i = kvm_mmu_get_subpages(kvm, &spp_info, true);
+				if (i == 1 &&
+				    spp_info.access_map[0] != FULL_SPP_ACCESS)
+					new_spte |= PT_SPP_MASK;
+			}
+
 			new_spte = mark_spte_for_access_track(new_spte);
 
 			mmu_spte_clear_track_bits(sptep);
@@ -2905,6 +2923,10 @@ static bool mmu_page_zap_pte(struct kvm *kvm, struct kvm_mmu_page *sp,
 	pte = *spte;
 	if (is_shadow_present_pte(pte)) {
 		if (is_last_spte(pte, sp->role.level)) {
+			/* SPPT leaf entries don't have rmaps*/
+			if (sp->role.level == PT_PAGE_TABLE_LEVEL &&
+			    is_spp_spte(sp))
+				return true;
 			drop_spte(kvm, spte);
 			if (is_large_pte(pte))
 				--kvm->stat.lpages;

