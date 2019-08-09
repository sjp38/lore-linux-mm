Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67100C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 164D72086A
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 16:05:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 164D72086A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=bitdefender.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 526FF6B02AE; Fri,  9 Aug 2019 12:01:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FF816B02AF; Fri,  9 Aug 2019 12:01:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 351026B02B1; Fri,  9 Aug 2019 12:01:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C56DB6B02AE
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 12:01:43 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id f9so46817327wrq.14
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 09:01:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eG/E66m41oxyAYdmcZWNT7Zx1FPyclhYj75TuBnEk+o=;
        b=cJf3TSSfI6GXbN/swyUQQgdvauaGUwYea8AbBBUNvF1AF7ddQzNfvA4Dm+GbWGfBuk
         mkWs4Rs2b5yOWkLhbXW5R6LaxCef8xSyKjJYUe1V7Cjlub5cbeAcIOtQ6qqCfYHSJnLE
         G7yPUsFYN6Vivl46IyBxQLIfQe5NwQI27rDmw/43rj6csddyO4o/s/At5Mg4hZ+jsI7r
         0aiyX4+UMKzv/WlXjI/pTeOkpiMz1pBm/0dj97MCJAsY9/gtjnOU7P4rY5X1mkoOsdmZ
         MiH67hb2lMdE0wgDq4mg8w5F8li1sFq2xuKdL7bjkaOnOIiuquOCe/uzpvjh+SkiZB7n
         WhwA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
X-Gm-Message-State: APjAAAW26n/h/3ePvoNNYG8BCydlgumgpwwbupjb7mL4KkSkoE7ynQT2
	1OP7RZovGtLyflX31iVOHzVleSskI1uJJZuhjiOh/qiI6JzAfYNXJsjOIkl8hQdm9rpMc/vIxEL
	9cOW2kxDPvAnllYu/hBAxYr3RqrcYkAyZcDSkMeqjXgF6l7nILvGlJ36jAUlajjIiZw==
X-Received: by 2002:adf:db0e:: with SMTP id s14mr12365973wri.333.1565366503387;
        Fri, 09 Aug 2019 09:01:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5gD0smRFIZoZ3KSegOGM7+lYVzoxXNiscAAZ676thel3/Qj59supQVQcdWKATp6LsE76A
X-Received: by 2002:adf:db0e:: with SMTP id s14mr12365865wri.333.1565366502289;
        Fri, 09 Aug 2019 09:01:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565366502; cv=none;
        d=google.com; s=arc-20160816;
        b=VlEOYKdCyv/M+5mjHH6+ll2Mc1Evh94l0w1Qw0DSbOQYyrECEv8r+h/7CPsNccW9+b
         eNuiTeswCRe5QuhYlztRQCWbC4CGkt64eZ89BBhQzgsMF6JCputGuDYAIFX06J5FB5ng
         O4yV5zl6r9alBcf15tXlegCJpTpBd1obNU1M6UmZsR+p64QhmbE0P0a/6LUIw6qJzxdf
         G3SpSivHIGi0mNwP7hron0y353P5OvyNFTrh3AmrIR/dnPSsq4IppO6QPPGvprAq4c6q
         MZnSBMQZdy4KLTLlo0MXu5MbxKGeUsBzAG4nAuNEFV7nHfo7X/pOgPcDiNdwbzqbBHsy
         mejg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=eG/E66m41oxyAYdmcZWNT7Zx1FPyclhYj75TuBnEk+o=;
        b=Ns5HrvkGqS0edBK8xTVS0LqUi8eIzMc2UQDyiP8aCj4uNYdWn1UUpyCY+Dh+wGesl6
         MIDJIMz5LYAD7Be38IaMRojMLl7NJ8zllxP95+f38HzKMNCvyKqQ7DyO0XS7U8rju/Ol
         tFwRrkImhXsay9aNMKN3Wlj/jDZj6CJOkkHF8o+AH8cbpsyy61oJ/88GMq9Y1NSvyPkN
         G/c7FdvJBcg4h4lXx/k/27IYi0Jnhi2sLQwHfA+Mwj/9HAsMDOnldftGofvsCyfXL56v
         bQReoFxh2OYpyICRnGdXQ17w3uLoaMo+CLeSXTjfFFfwtrjRIBzLWiKwZG9N/eO+T8x6
         Vbgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from mx01.bbu.dsd.mx.bitdefender.com (mx01.bbu.dsd.mx.bitdefender.com. [91.199.104.161])
        by mx.google.com with ESMTPS id t123si4182915wmt.175.2019.08.09.09.01.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 09:01:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) client-ip=91.199.104.161;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of alazar@bitdefender.com designates 91.199.104.161 as permitted sender) smtp.mailfrom=alazar@bitdefender.com
Received: from smtp.bitdefender.com (smtp02.buh.bitdefender.net [10.17.80.76])
	by mx01.bbu.dsd.mx.bitdefender.com (Postfix) with ESMTPS id AFF0D305D364;
	Fri,  9 Aug 2019 19:01:41 +0300 (EEST)
Received: from localhost.localdomain (unknown [89.136.169.210])
	by smtp.bitdefender.com (Postfix) with ESMTPSA id 67CE6305B7A1;
	Fri,  9 Aug 2019 19:01:41 +0300 (EEST)
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
Subject: [RFC PATCH v6 85/92] kvm: x86: emulate lfence
Date: Fri,  9 Aug 2019 19:00:40 +0300
Message-Id: <20190809160047.8319-86-alazar@bitdefender.com>
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

This adds support for all encoding variants of lfence (0x0f 0xae 0xe[8-f]).

I did not use rmb() in case it will be made to use a different instruction
on future architectures.

Signed-off-by: Mihai Donțu <mdontu@bitdefender.com>
Signed-off-by: Adalbert Lazăr <alazar@bitdefender.com>
---
 arch/x86/kvm/emulate.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kvm/emulate.c b/arch/x86/kvm/emulate.c
index a2e5e63bd94a..287d3751675d 100644
--- a/arch/x86/kvm/emulate.c
+++ b/arch/x86/kvm/emulate.c
@@ -4168,6 +4168,12 @@ static int em_fxrstor(struct x86_emulate_ctxt *ctxt)
 	return rc;
 }
 
+static int em_lfence(struct x86_emulate_ctxt *ctxt)
+{
+	asm volatile ("lfence" ::: "memory");
+	return X86EMUL_CONTINUE;
+}
+
 static bool valid_cr(int nr)
 {
 	switch (nr) {
@@ -4554,7 +4560,7 @@ static const struct group_dual group15 = { {
 	I(ModRM | Aligned16, em_fxrstor),
 	N, N, N, N, N, GP(0, &pfx_0f_ae_7),
 }, {
-	N, N, N, N, N, N, N, N,
+	N, N, N, N, N, I(ModRM | Sse, em_lfence), N, N,
 } };
 
 static const struct gprefix pfx_0f_6f_0f_7f = {

