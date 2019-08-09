Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8E847C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A7272085B
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:06:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A7272085B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 39E5A6B02ED; Fri,  9 Aug 2019 12:03:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34EB56B02EF; Fri,  9 Aug 2019 12:03:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F3576B02F0; Fri,  9 Aug 2019 12:03:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C67B36B02ED
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:03:25 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id f16so46659594wrw.5
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:03:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=wGH2/0D/AIK6mqgdbIG8ZVkP0eDAw1HU/Zv+XN5/02w=;
        b=Im/dUN/4TnWxPnVkCGdpRWgNpKF8jNqxn5012GU6T0mRnT7dJX/bgpEwBG5It9GFgW
         oaRVCEqq3C92OnNbzaHXwpft3uSjUuMh0RncyyM6HGxN7559XmdtJNAScaf1BWvuAcrT
         bbkv8CZcKVsT0zzzE9FqyxPXDGDLOSz6LiR91QngeiCddEHEqVY+6UEcUxSqWBQ2tcBc
         diSmKRuRW1o7qV3jTd20DZmzOPIYj1Qb3W8zbxdxvbEKFVtbiJsMbE6pDAtQNZT0Kk/8
         f4D8ljnEmR+o1jMn+WVByQHTDqIRKg9fA5kyXT48ySfaSVagnyhOeQcjUhLZFx/x/PQ9
         Rr/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAUo4a5inSfjKjAhJuIFDiL0m3UGiVO09vlv6goA8qjQl7P5SZM9
	WhjYuas3xlqnLI/6HFpl7mLeIB0ULAHs+i5bMFy6U32G+tmP0Uc8rdzXGYnmRk+duELpTkOPWrN
	MUQKNU8rgs04OjOGoruzU8452dzDUm02M57gaRwmpyt4BP7/vyZQOEIjYBajaXGFi3A==
X-Received: by 2002:adf:f04d:: with SMTP id t13mr24558478wro.133.1565366605358;
        Fri, 09 Aug 2019 09:03:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwhrLAC8Lg0qn0UQ6EYhWvAvJvx7mmxQiiaqC3GrDP8AEJZAwrmchip54hvHIqrqhlfxQiW
X-Received: by 2002:adf:f04d:: with SMTP id t13mr24548165wro.133.1565366505475;
        Fri, 09 Aug 2019 09:01:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366505; cv=none;
        d=google.com; s=arc-20160816;
        b=bSEXmdIAwReNb0fgE8r6MnQwPs5+ZA7EuJOdSbO+r1vk63YIX/p52egKa5aYL+IDJL
         EZwVX6bdLdtVo4YRRvTQ4ThamL3dZyuC+LFZmKw/2jijlBmbCoDzeB+U5DpVslbk8utP
         +ZgEsBjF5vmiFscPmsxdtEQ5Q8aDE9dX/9dOMyfuOeO2rIVZ9R6CvGZXSo2v10AKMRVp
         ar6uisUFGkV/5yGnPjDjUUE+vHQ7GjFjLyzIxgiK4wbuQ4oRia4KVB9xLgR8Ksy1si71
         yUvj/UcdxttSUG5XR0I1MSujyN61Zd1oVWBQoxzS/rFbWCPG/Bpwarg/vnzmcF1WBdSr
         mckA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=wGH2/0D/AIK6mqgdbIG8ZVkP0eDAw1HU/Zv+XN5/02w=;
        b=fZWZ4xAh4X7MwVZHVHJSaN9MRIbOh4QMs+s65nSTTKNgnJ44/bTnbXj8swXBEXytJU
         zF2qsWoobUPSmwSkrH6Y1xtxoAJU8HGCJZIOoTqOFsaAjUTL47w473EsMRUlrI/4JciW
         KFEUUsg8zpYh4aOXxOJfpSYq5M+I+9ysHc3d2/nhjT5Dlur2sRe9kdNHgpbmHuvjuWjy
         +0KRD7hcnt1/523oydTSGeQLn3AzmA29ORq14oSxg15CQZADsiiiwKsvHrBmaS0gytfG
         +kNPy5vsqRGvcovzjqeOVKJvlp+s4xQmezn/GVa/asMI7x6IjBKLLA0c4W4pH7dJBexj
         sZqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id s13si1505788wru.417.2019.08.09.09.01.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id E0CC5305D36B;
	Fri,  9 Aug 2019 19:01:44 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 97C8A305B7A1;
	Fri,  9 Aug 2019 19:01:44 +0300 (EEST)
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
Subject: [RFC PATCH v6 92/92] kvm: x86: fallback to the single-step on multipage CMPXCHG emulation
Date: Fri,  9 Aug 2019 19:00:47 +0300
Message-Id: <20190809160047.8319-93-alazar@bitdefender.com>
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

From: Mihai Donțu <mdontu@bitdefender.com>

There are cases where we need to emulate a CMPXCHG that touches two
pages (4 in one and another 4 in the next, for example). Because it
is not easy to map two pages in the kernel so that we can directly
execute the exchange instruction, we fallback to single-stepping.
Luckly, this is an uncommon occurrence making the overhead of the
single-step mechanism acceptable.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/x86.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 0e904782d303..e283b074db26 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -5671,6 +5671,12 @@ static int emulator_cmpxchg_emulated(struct x86_emulate_ctxt *ctxt,
 #define CMPXCHG_MAX_BYTES 8
 #endif
 
+	gpa = kvm_mmu_gva_to_gpa_write(vcpu, addr, NULL);
+
+	if (gpa == UNMAPPED_GVA ||
+	    (gpa & PAGE_MASK) == APIC_DEFAULT_PHYS_BASE)
+		goto emul_write;
+
 	/* guests cmpxchg{8,16}b have to be emulated atomically */
 	if (bytes > CMPXCHG_MAX_BYTES || (bytes & (bytes - 1)))
 		goto emul_write;
@@ -5678,12 +5684,6 @@ static int emulator_cmpxchg_emulated(struct x86_emulate_ctxt *ctxt,
 	if (bytes == 16 && !system_has_cmpxchg_double())
 		goto emul_write;
 
-	gpa = kvm_mmu_gva_to_gpa_write(vcpu, addr, NULL);
-
-	if (gpa == UNMAPPED_GVA ||
-	    (gpa & PAGE_MASK) == APIC_DEFAULT_PHYS_BASE)
-		goto emul_write;
-
 	if (((gpa + bytes - 1) & PAGE_MASK) != (gpa & PAGE_MASK))
 		goto emul_write;
 
@@ -5772,6 +5772,9 @@ static int emulator_cmpxchg_emulated(struct x86_emulate_ctxt *ctxt,
 	return X86EMUL_CONTINUE;
 
 emul_write:
+	if (kvmi_tracked_gfn(vcpu, gpa >> PAGE_SHIFT))
+		return X86EMUL_UNHANDLEABLE;
+
 	printk_once(KERN_WARNING "kvm: emulating exchange as write\n");
 
 	return emulator_write_emulated(ctxt, addr, new, bytes, exception);

