Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5EDDC31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6928820C01
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6928820C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1B056B029F; Fri,  9 Aug 2019 12:01:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7D1E6B02A1; Fri,  9 Aug 2019 12:01:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F6BC6B02A2; Fri,  9 Aug 2019 12:01:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 44CAB6B02A1
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:34 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id b67so2762846wmd.0
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eOCXFQt3aXUMAr96Izj7+XIYm2V1Lc68QhDY+S3pR4U=;
        b=qUxEWnVFMG9OfFXpJvC9Qck+s+EGeubBXOArKU10c6Fj+vloOWa+vT8pHrqO57OSlM
         HOIl+F8q4icSyh+N+MbzVCW8+Y01/r0Yqdw37pISpgKOq8P/4fvlrk9hl2HVB+3wpeBd
         ldhnOEbzAHnTr7psflyILomnsYD7d9lztqTs4E+6lEWrV+/xsAaiTHJU+fsckaec0Sqs
         y5NumHqYMfDlOC2Ptw1HFb7IsgU1ncQoYZXmwK5WOHIrpBbNh5TLrPxgA672NGYT0cQ2
         p5FffliUh/ybPKg3aYCn2DxGPKy5WJznxi6CT8Hp49NA/8nprstNWPnb/5PGg4ivs+gp
         M0nQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAVe4pSlZsj8RUNpraXW4aUhOyRHmOpm688JKvU3YXE2Cr1OndVm
	E9F0k2XG8MtPPR5zM0pIgZZsE8E4VkEHRD3b40kKKbTt1+5gE038HUNASd030CfEf4wA7Ob9EO0
	XEOLCOLN1AmK5GVBt0NuReN6mBtLYJ98XInWCccJBgLGd1EUXypAT3AcFgF19Kggx8Q==
X-Received: by 2002:adf:f584:: with SMTP id f4mr11404400wro.160.1565366493893;
        Fri, 09 Aug 2019 09:01:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHQELUVpSY8h6MN18fgw+++lJYND7p9TA2rXmu8LFPmSGXj2m0A2CTTztuAAnaj4UKRzic
X-Received: by 2002:adf:f584:: with SMTP id f4mr11404322wro.160.1565366493027;
        Fri, 09 Aug 2019 09:01:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366493; cv=none;
        d=google.com; s=arc-20160816;
        b=hXabBrwi3fUlWkSOvxbnJKMlqy7IsTCEBTk4ytHDtDlX+x9HrhvuQK3Qo5Zo2+q9yI
         aekagxB2r2wKepv08iipXjQNOwz35PmHtCiFmOaMD6rIVtzURNk/nfe0sLMUAmvLhpy8
         hExou1wQOqDkP2z8+POkghBixuf2himPFvb61HTqzoNu2WSoTT0Hslyyv8dspf23aciy
         A+tjg/ScBRut8Zphby6XKT2Vd6b7PLPxXYKz1Xzc4d6kiifda8ylwA/IJw0ZUbI4EW30
         koPX7Jqj8d+GUIzUvOZrAOFkJ1M9q+KENzyYfNm/SDdx8fgVPrDiPRTPSAQHVPeMPPeW
         be9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=eOCXFQt3aXUMAr96Izj7+XIYm2V1Lc68QhDY+S3pR4U=;
        b=0qbbQzjsUErGdt+mqsjtDNskFIbykf+nLR1btqWJeqNXOJofdMEWVe5e7ygGixKso8
         eYSRkTcG01YS9Cpft9oBqe8g1PNYSUgL6T8qebeY7E4fOkf9HuGcBcblQU0xAB4dGOlS
         4b4Rj0Rh5AFgXZyzFAStfBfO0iXkprAMa4ykM2e2gzhgosWe0NZpsqsUk1YXwN7xTivc
         zsdqE/iC+yE6oEAYOFNv94KeZTKsBQPhZvYyQvZfSuLsZhtnO9aqcZNZC0tEYKZ+8JQZ
         q+oEmxmF/9D9xnDWOGQMAvAQ8GpF2C6vJ4f6AqzDt26YzjYD/ewqwKYV3pvZorkzb6QL
         UiUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id 8si100549wmg.68.2019.08.09.09.01.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 728133031EC3;
	Fri,  9 Aug 2019 19:01:32 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 74CD0305B7A4;
	Fri,  9 Aug 2019 19:01:31 +0300 (EEST)
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
Subject: [RFC PATCH v6 69/92] kvm: x86: keep the page protected if tracked by the introspection tool
Date: Fri,  9 Aug 2019 19:00:24 +0300
Message-Id: <20190809160047.8319-70-alazar@bitdefender.com>
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

This patch might be obsolete thanks to single-stepping.

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/x86.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 2c06de73a784..06f44ce8ed07 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -6311,7 +6311,8 @@ static bool reexecute_instruction(struct kvm_vcpu *vcpu, gva_t cr2,
 		indirect_shadow_pages = vcpu->kvm->arch.indirect_shadow_pages;
 		spin_unlock(&vcpu->kvm->mmu_lock);
 
-		if (indirect_shadow_pages)
+		if (indirect_shadow_pages
+		    && !kvmi_tracked_gfn(vcpu, gpa_to_gfn(gpa)))
 			kvm_mmu_unprotect_page(vcpu->kvm, gpa_to_gfn(gpa));
 
 		return true;
@@ -6322,7 +6323,8 @@ static bool reexecute_instruction(struct kvm_vcpu *vcpu, gva_t cr2,
 	 * and it failed try to unshadow page and re-enter the
 	 * guest to let CPU execute the instruction.
 	 */
-	kvm_mmu_unprotect_page(vcpu->kvm, gpa_to_gfn(gpa));
+	if (!kvmi_tracked_gfn(vcpu, gpa_to_gfn(gpa)))
+		kvm_mmu_unprotect_page(vcpu->kvm, gpa_to_gfn(gpa));
 
 	/*
 	 * If the access faults on its page table, it can not
@@ -6374,6 +6376,9 @@ static bool retry_instruction(struct x86_emulate_ctxt *ctxt,
 	if (!vcpu->arch.mmu->direct_map)
 		gpa = kvm_mmu_gva_to_gpa_write(vcpu, cr2, NULL);
 
+	if (kvmi_tracked_gfn(vcpu, gpa_to_gfn(gpa)))
+		return false;
+
 	kvm_mmu_unprotect_page(vcpu->kvm, gpa_to_gfn(gpa));
 
 	return true;

