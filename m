Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44016C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E476A2089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:02:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E476A2089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BDDAC6B0285; Fri,  9 Aug 2019 12:01:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B978D6B0286; Fri,  9 Aug 2019 12:01:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A0716B0287; Fri,  9 Aug 2019 12:01:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4A8296B0285
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:15 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id b1so46834484wru.4
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sjTbtBNVc706F6PJIxdpB0VaL0+XOcEWscuac7rNd0s=;
        b=LtCRAec2lnvSeUlS26RRmEDmt/reIe8KXBooPWXNiTlsTI7G3eAjKWlymVaEfDYDcv
         OKsbaPfTYdG14lqZOAsr6yRfC9FblhWksFct7Ton5r7SNiQX8i3lWElwq3TCWH/X9KlH
         5szcetUjs0RqREVN/NM/7+OJeX5XjJO5mahh6sg6HtD8Ye0Iyy/jExewGOd0zAU9F6I6
         +csmJtGkJzwiJXQRttTyMkuL9dfXgYzGtKO8RhpR3d6ilQTP3WpgHtP/ZIFEEuhLE1vf
         zaJz+EnCak2gd1w9PdAFZOEd4oZyCH66+15AfJ4uUOiQwGY4JkTIYM/5v7TM+UvxDFbW
         QhEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXko3yjNVhk8HwkgtjpvrVfHBy2eFMYXa5Q5HOr8pQtTPbhW9Q0
	Xl7RWQVif+8f41GYiLNyXJB2FwODeXNSOQVykHEt94u0Eh9+/a1xpKVD9bQ4MbqjN1cgTr3/K+b
	9lut0Ddz+AZNHARgwvznaMIDAO8NIc0XoWCGAR1Ty3wZWhaknI69zWbSdEAfVGtPJnw==
X-Received: by 2002:a05:600c:34a:: with SMTP id u10mr11393670wmd.43.1565366474906;
        Fri, 09 Aug 2019 09:01:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGc2J4/Bwz9YCGoWYa4UKnINFEF4wNFmeJOA6QeAh9rz8O6yJ3m4q0w6BQl4IFvL0IQr0V
X-Received: by 2002:a05:600c:34a:: with SMTP id u10mr11393516wmd.43.1565366473197;
        Fri, 09 Aug 2019 09:01:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366473; cv=none;
        d=google.com; s=arc-20160816;
        b=FJH5XRDaN/35YO8SDILv9NCGo3bNWpNszJS6YGeGC/sbZtc6Ibr6Wr2kXSmcBh+0+R
         89D7pjJaXRY5vDcn/V6e0QzG4WaoTrePQiKtWS5FXk1mtoepZpIjBN26LX7wRkSWpaVW
         JAmHt5wMBVBZZgPZoWPqXmBZrGjpAhADEFFgKfzlTMNBIPFzSzsBelQjWOYDfizznVVz
         yemG6nX/8IqTp/QfqGOhwlfnXN+5mby+qK2E8pcVlmcdmzuC48ZQRbhqUH68s9ruxnsL
         pNw3XR/2FwAq1HzUw0Zd262ImVbZmg6OwF7/4v8IWzX/TWX/IhdmkNf4p5wwzhJVJk0o
         2/hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=sjTbtBNVc706F6PJIxdpB0VaL0+XOcEWscuac7rNd0s=;
        b=xmqdy6u+TkekLyRj65rej86rYeuojQp2inGlBUOlFuVNQbOi1WWQd5O8OXMU78FP1i
         P44fTJz6KI45fT1HnngC3eVqVrL+so9eiMUmg09Q8p1uZW51fdiXVcH8kLmW3pyzOXze
         2xBbGO7wAmzu1PK74RD91mBUkYcs/kAmzmd7gmQjKf1m9raSaKJ+q1Bqkya92c5drx6u
         brYSY5wDK4Rp1SKRbN254yKBeYnK9PgSxVPLx2mJDP33OFRxuPmE/psG8E72Qsc59btf
         CRT1zVgNX2U+kpYQmp5qOZFl6cFLFPA1My1vWq0NIGjxciuBeLSr40Ph0iYgx7hnksLD
         gUNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id p5si85828735wru.252.2019.08.09.09.01.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 9EECC3031EB6;
	Fri,  9 Aug 2019 19:01:12 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 46431305B7A0;
	Fri,  9 Aug 2019 19:01:11 +0300 (EEST)
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
Subject: [RFC PATCH v6 41/92] KVM: MMU: Enable Lazy mode SPPT setup
Date: Fri,  9 Aug 2019 18:59:56 +0300
Message-Id: <20190809160047.8319-42-alazar@bitdefender.com>
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

If SPP subpages are set while the physical page are not
available in EPT leaf entry, the mapping is first stored
in SPP access bitmap buffer. SPPT setup is deferred to
access to the protected page, in EPT page fault handler,
the SPPT enries are set up.

Signed-off-by: Yang Weijiang <weijiang.yang@intel.com>
Message-Id: <20190717133751.12910-9-weijiang.yang@intel.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/mmu.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index d59108a3ebbf..24222e3add91 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -4400,6 +4400,26 @@ check_hugepage_cache_consistency(struct kvm_vcpu *vcpu, gfn_t gfn, int level)
 	return kvm_mtrr_check_gfn_range_consistency(vcpu, gfn, page_num);
 }
 
+static int kvm_enable_spp_protection(struct kvm *kvm, u64 gfn)
+{
+	struct kvm_subpage spp_info = {0};
+	struct kvm_memory_slot *slot;
+
+	slot = gfn_to_memslot(kvm, gfn);
+	if (!slot)
+		return -EFAULT;
+
+	spp_info.base_gfn = gfn;
+	spp_info.npages = 1;
+
+	if (kvm_mmu_get_subpages(kvm, &spp_info, true) < 0)
+		return -EFAULT;
+
+	if (spp_info.access_map[0] != FULL_SPP_ACCESS)
+		kvm_mmu_set_subpages(kvm, &spp_info, true);
+
+	return 0;
+}
 static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa, u32 error_code,
 			  bool prefault)
 {
@@ -4451,6 +4471,10 @@ static int tdp_page_fault(struct kvm_vcpu *vcpu, gva_t gpa, u32 error_code,
 	if (likely(!force_pt_level))
 		transparent_hugepage_adjust(vcpu, &gfn, &pfn, &level);
 	r = __direct_map(vcpu, write, map_writable, level, gfn, pfn, prefault);
+
+	if (vcpu->kvm->arch.spp_active && level == PT_PAGE_TABLE_LEVEL)
+		kvm_enable_spp_protection(vcpu->kvm, gfn);
+
 	spin_unlock(&vcpu->kvm->mmu_lock);
 
 	return r;

