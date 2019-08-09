Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNWANTED_LANGUAGE_BODY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F052C32756
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C60FD2086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C60FD2086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28D4C6B02B2; Fri,  9 Aug 2019 12:01:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 242946B02B3; Fri,  9 Aug 2019 12:01:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0BB486B02B4; Fri,  9 Aug 2019 12:01:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id B0BC46B02B2
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:45 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id v11so4024239wrg.2
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=imRD5NB52iga2KKVcygvQN0ZiL58l8rn5ygGIsOhu84=;
        b=PHTSRJG1H176K9bKd8R2iFRmAyhap9Sd8WeJBpCXl0hjrrKUny+THdea0lIgI2Ss9K
         L9qscDejEYp5tTEcPu4iuZYRQHRWtjQBdZQUzHAgiAH9hQMZF12rsHsDglT20OB/mUqp
         +lySM5XKsVsilKCNS4/gZXPNXNLCRBIZtUxPgDT4r2bdr60U/5DBl+idK+zImrLgSjGH
         nLYPGr0yPvaC6lTW4zwJVQ9trdkEcrYLoIeWl5neALA8x+iQb/fVNOSY2TOtId2M+mDJ
         gS4csDXl/nMQIsjOhtqM0/UHVOlYaUEzExysL/sPKOUOlCdumq4ZyJ1Vm+/q2qmrpmvL
         z4hA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAWbob7er02n7Q754hhiyIWVZtq/zWU+LqklMACvhjdQbfIdd0eC
	h+4xJ5hASf/6nnOq0e8ptXxjrknUaRyCck8OiH33dgCspn3pk/J23ZojSXspmYsg2VVl3612NQv
	HWcoH14/mnYO7sIW7Koi7iKR26mc0cxYpHb1cz5WcWtJ32lJL6qP7sfThVs2JtXNehQ==
X-Received: by 2002:adf:b64e:: with SMTP id i14mr25209703wre.248.1565366505336;
        Fri, 09 Aug 2019 09:01:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrCczpdUbeb0mVtaKYSRsCmOeJ8/Hk3tLM2Afzi+C409fSjuvtlRwCYvW6Vdpw/zjwPkM7
X-Received: by 2002:adf:b64e:: with SMTP id i14mr25209576wre.248.1565366504162;
        Fri, 09 Aug 2019 09:01:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366504; cv=none;
        d=google.com; s=arc-20160816;
        b=uQ3cnUYCHdya0aHyJ7DeX7Y9WPd9xeIXg5sRC4VTnFRVGB6F3XV5N/zC43j8BAXBaE
         xxXesaeGEjx3USbid0NBM/usjoI8XAJxGk6fctYI/tgnuXNkVKypNvyDE9O1p+uHEdP9
         hQwVQxoI+Fm8zoOzuERQdKiIV5v462MnU41hHk8VOAndKTyS9uALIKR7Ie/9U1geGxlL
         iTaCcqEDza7Eulv3VxI93bRWUNpVfFA1QVEmKvuZ1zu+EPpmT+2SayEyALH7bK+cDGJA
         YTsKHG6j5QwU/S2+kvA69Oc3JFdOzRMcv/RMl9OPW2tub2j2d3CrR80mj2pndU401cbd
         dRzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=imRD5NB52iga2KKVcygvQN0ZiL58l8rn5ygGIsOhu84=;
        b=L1YW5n2BmC+LMyYPjRhHs64V+qNMfBmYNAzshY4w806otvtu7nv1cUiJ4c3BXrIlVM
         wzjNL9OOJgMTI+OEaMvdUbZfdD1ZWBqqs//TewhRg5UtpJTvwyOT8XCyM9XA5XAw1tIK
         9rNexDtWKp0vGmQ3FLiwiVuGOxZRm9AA4cxqDp2G3ZcfGIKJ1zPbkLccAs5VWxYnAoRL
         g5pp8zW4A/IMJK2RTuy7ovyhhoHQrJ9/tYKFFUzl+nlIYOAVEelROKX7+da+fgt2TOxO
         vS8Johfv5jCFHWaThrDoMVoLWUTvBuwj8ArwMH/I1Tbwpun6BfFHa171H6pBDFnfFDGA
         iMKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id i6si82764482wrv.400.2019.08.09.09.01.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id 90267305D367;
	Fri,  9 Aug 2019 19:01:43 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 37A7F305B7A1;
	Fri,  9 Aug 2019 19:01:43 +0300 (EEST)
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
Subject: [RFC PATCH v6 88/92] kvm: x86: emulate fst/fstp m64fp
Date: Fri,  9 Aug 2019 19:00:43 +0300
Message-Id: <20190809160047.8319-89-alazar@bitdefender.com>
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

This adds support for fst m64fp and fstp m64fp.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/emulate.c | 23 ++++++++++++++++++++++-
 1 file changed, 22 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index 14895c043edc..7261b94c6c00 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -1178,6 +1178,26 @@ static int em_fnstsw(struct x86_emulate_ctxt *ctxt)
 	return X86EMUL_CONTINUE;
 }
 
+static int em_fstp(struct x86_emulate_ctxt *ctxt)
+{
+	if (ctxt->ops->get_cr(ctxt, 0) & (X86_CR0_TS | X86_CR0_EM))
+		return emulate_nm(ctxt);
+
+	asm volatile("fstpl %0" : "=m"(ctxt->dst.val));
+
+	return X86EMUL_CONTINUE;
+}
+
+static int em_fst(struct x86_emulate_ctxt *ctxt)
+{
+	if (ctxt->ops->get_cr(ctxt, 0) & (X86_CR0_TS | X86_CR0_EM))
+		return emulate_nm(ctxt);
+
+	asm volatile("fstl %0" : "=m"(ctxt->dst.val));
+
+	return X86EMUL_CONTINUE;
+}
+
 static int em_xorps(struct x86_emulate_ctxt *ctxt)
 {
 	const sse128_t *src = &ctxt->src.vec_val;
@@ -4678,7 +4698,8 @@ static const struct escape escape_db = { {
 } };
 
 static const struct escape escape_dd = { {
-	N, N, N, N, N, N, N, I(DstMem16 | Mov, em_fnstsw),
+	N, N, I(DstMem64 | Mov, em_fst), I(DstMem64 | Mov, em_fstp),
+	N, N, N, I(DstMem16 | Mov, em_fnstsw),
 }, {
 	/* 0xC0 - 0xC7 */
 	N, N, N, N, N, N, N, N,

