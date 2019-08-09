Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC4DFC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A9A42089E
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:04:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A9A42089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17D5E6B02A8; Fri,  9 Aug 2019 12:01:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1329B6B02A4; Fri,  9 Aug 2019 12:01:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC1FA6B02A8; Fri,  9 Aug 2019 12:01:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9CFD96B02A4
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:40 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id f16so46657131wrw.5
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iQ+oa5DZ+wUxac2LQrUbLpJ5TnHWOE6r+fiPpWmwTog=;
        b=fYIIaVEnPlG5wL1QeUcnKgm4kWBfA06Bi/f/Zv5qq+0JNs3Ed2OdExNEq6VrUxP9Pl
         94CFOMA8D4HhKTds2RP6v1PQBgaR0uRdtzjHX/G0eDc7Gsb26Z1uuDfCTK5wUZ34LgZB
         m3onWdhocGig6n1B92FX49gEXiwejle57gZCwYjpYXr6DyOgu2XerQ8QJsJc4molbUoZ
         B9mLqWT4wHMNA/ihqdHn0udDjsjiLqhsqVkU4QX0Bp0lrUB+iPAU5TplVigYEIr8vI7t
         V7J+WcudQr0Tya3w5qlckXnIhyRKgZJHZaN6cIpuP9pCZ3e5PBgSiqG6NuzVey5jHoXM
         USTw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAXvTwN3pYdMtWkKUqc7Y0l6TgI2Jb5lG4fgGJeT2tWmqjgKmb49
	PnN5RoWoVJ2g+JK3Uwe2uO7j04ZP8J9ArIELDHgP1ADF1syjyijh58cpeRqADF0r62Up4+rr14b
	pP3ptrVQWgPEVtnjpB0Fyi6TcOes14kIDMvDP6TcHJEZhK0wG8TwLkzxZcckbcKwovQ==
X-Received: by 2002:a1c:7e85:: with SMTP id z127mr12044447wmc.95.1565366500229;
        Fri, 09 Aug 2019 09:01:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVbwsZgaWz59QRfpxoAozXRt5F4Vr4pl+DMfln4umUvy/OvEP1w94dwLWPuav7NPdkiaJy
X-Received: by 2002:a1c:7e85:: with SMTP id z127mr12044367wmc.95.1565366499278;
        Fri, 09 Aug 2019 09:01:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366499; cv=none;
        d=google.com; s=arc-20160816;
        b=jOeOP40XuQrXDzyPVRElZ/p6vFv1j/G+D+oizEOcsT8+M30BsqbYYa1SXEiMFQrtTv
         AUHw0pcgEFQKdFrf3iOvCH7HiPeP5tcEblbmQWY7ew0NZbKlV1r5R2Vhax+IvvtjXkQC
         RZxBNyrymOWeLv2wpoQEokoLvGoD/onzPPwsQUnZ4LJbALIOAhAuV7WUTgZqBjXxxLfn
         HuIws7au11q7hiiNoZdDZo6wsyyczvPAvlob7Gd2M/CY3SstUbZEdvTc1QjkZ1IWcc7E
         nq7kg9f/I+mizYIUrs/wqkL4bFq1dL6eqI7V1i1c+q1ltxD3mCiIZVUUV0Fn19it2LHz
         1jXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=iQ+oa5DZ+wUxac2LQrUbLpJ5TnHWOE6r+fiPpWmwTog=;
        b=iADdJ0WiW4vuKZ3K+ZGxC8sCZH+vp00/wPxnzC0yRAdK/BHciALVn7h1W3kA2dV9pV
         cmmT006U8ZLkSXgiXIay3sFJ/KzDMxiE1hTWeTv2MtI+rTYU+uiSDj6vMPq2H82OhCd1
         LXgAG/rTMVU5bNllwyLRNQA66+aRgefTQggTl30+wi9h4hcOZl/F82Lkq9RpsZAa56ts
         6nJje3g1KgrLRc1ADryfMp5jqBCrWPPqbCixzYlzJfnZnqg+P4qsnAFJxjpoJFZQzBAa
         RhactpI7AhfZ3/5ZHcdngTNxv2G9UwbXO9cqeq0CZv3UjcHrqselQHwt52a31tjTDIDB
         Jhqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id f4si4267564wml.125.2019.08.09.09.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id B0DAB305D35D;
	Fri,  9 Aug 2019 19:01:38 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id E6041305B7A5;
	Fri,  9 Aug 2019 19:01:37 +0300 (EEST)
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
Subject: [RFC PATCH v6 75/92] kvm: x86: disable gpa_available optimization in emulator_read_write_onepage()
Date: Fri,  9 Aug 2019 19:00:30 +0300
Message-Id: <20190809160047.8319-76-alazar@bitdefender.com>
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

If the EPT violation was caused by an execute restriction imposed by the
introspection tool, gpa_available will point to the instruction pointer,
not the to the read/write location that has to be used to emulate the
current instruction.

This optimization should be disabled only when the VM is introspected,
not just because the introspection subsystem is present.

Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/x86.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 965c4f0108eb..3975331230b9 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -5532,7 +5532,7 @@ static int emulator_read_write_onepage(unsigned long addr, void *val,
 	 * operation using rep will only have the initial GPA from the NPF
 	 * occurred.
 	 */
-	if (vcpu->arch.gpa_available &&
+	if (vcpu->arch.gpa_available && !kvmi_is_present() &&
 	    emulator_can_use_gpa(ctxt) &&
 	    (addr & ~PAGE_MASK) == (vcpu->arch.gpa_val & ~PAGE_MASK)) {
 		gpa = vcpu->arch.gpa_val;

