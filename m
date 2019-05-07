Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E2D4C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB008206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cT2LDruM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB008206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CB976B0005; Tue,  7 May 2019 00:06:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47C2E6B0007; Tue,  7 May 2019 00:06:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 36B376B0008; Tue,  7 May 2019 00:06:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 098376B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 00:06:13 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id f1so1268918pfb.0
        for <linux-mm@kvack.org>; Mon, 06 May 2019 21:06:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=BRgPkk2neO2a0h0yodkhojkyCRKojKVvK274UfwK7Vw=;
        b=qAT438w3A488bAc0XMXux1ToBQpNrQCdMTl8kttdnA8mCFqyYjsc+Zi6x+KD8eCE6v
         wBs6rxOwcatrPrCXUOIW4Wltu9+SHv/vRlbjVG3jFR3+XFJnGVvdGNmzU3nwpZ2xWL+j
         l7NF0UTa96TCa3Dy5y0EsgkGp0NKfNDp5rpMQ4NDBlV7TP7jhdAt8mHzeTjisSDWd9gf
         PEHo/pxxQoY43chud7rtQIVeRd8S9WH7QsMPBIWgP6S1rYmrIY4MDQCDGrsJvscJ3tKM
         kHjwdr5u4KqOnWqvO84ldyd5siVOIS9I9mpWcd/Rfcae+CgO3qKLWE/a3vvdLBj2M+Iy
         5qaA==
X-Gm-Message-State: APjAAAWmAJ7qzeMFzezOHGN9mnTe2YQ1Leoeao49i7q21PN1sk6TuYVP
	sN4gnoBH5shrNt6VRPHZSEJP76Rg/rEh6BNpIJUCc+yPp9WRmV+Sj0xWLkeoPO/vWlvKB7rS7Z0
	zFBVcpyuSIwq2D3FCybLmchc7jlF/HJxstc9sTD9pM2e16LqZoFrHPOipD8hPMLXfAA==
X-Received: by 2002:a65:628b:: with SMTP id f11mr35611062pgv.95.1557201972573;
        Mon, 06 May 2019 21:06:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyKOqLDItyUB96kA3tNYkr53Fx5kZkXIYcV++3ZuF9SO2HyRhZkzROTDdqDBsisFgsWZnPZ
X-Received: by 2002:a65:628b:: with SMTP id f11mr35611000pgv.95.1557201971715;
        Mon, 06 May 2019 21:06:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557201971; cv=none;
        d=google.com; s=arc-20160816;
        b=cb+di+Z9C3Q+CcdjXzrU4IiEg89hmeH++R+6gs0e8UPoBSA4M1ySWFYcGIU15EPPaB
         Vw2FeJHuVjtT4GtPaxTwHoVwjtaUTGpBuOAUhCnk5X0MzuPnjvZt+x/Q7G7DAehnlJcL
         DxR1K9a6egMBSKTVO8Y3z5aPFHidYAzG/zpQUvfIEoUauRcOGjZb3gG6Z8wmmF2sJjtj
         AMTWGvYgqXjB6aAoE9pqZjpF5qeCB10VlsBT2RR3yS5XfpTfrS6UtW/CBr0reAuzTYPw
         fIIR6z+R8rApNxNVYRKQGMe5bZci/SgicqxVtQ4xHhxKz4m2jpLocUS+INhuz1BFnkDy
         ynsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=BRgPkk2neO2a0h0yodkhojkyCRKojKVvK274UfwK7Vw=;
        b=Rzh4lChjrwUJez5tKQDZA+9q5HhONtcIgkBKnD86pjVQRGmrHjjr5iMm3QGVSq0v7X
         pkOwzapP/qsEz+MA/Ez0wivBBFsWWOwbd5J3BegcctM7TpW7OAIxouolYhY7yP7t8VB9
         jsA+Pf5eugd2eiBFKn2jdcFcvtbwYaQlH8L+ToQChpVyaSx2AvGFv8rwDMsnVvbaKlKa
         ZNZsyBoJBqWa/wgvntZ/8FJ8gaTfimG7dwznqecn8Sgm+EKXzZ6r5u8t3pmaMsyn7TA8
         gCCO876gRCe5Y+exuQkEMDn/NgXmGjbJgHIp/S8cvrlvWIt9KqUG5vamKL0pwqJq8r00
         Cmxw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cT2LDruM;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id y10si13884056pll.316.2019.05.06.21.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 21:06:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cT2LDruM;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=BRgPkk2neO2a0h0yodkhojkyCRKojKVvK274UfwK7Vw=; b=cT2LDruMwXsdfKeZMyTbLWmoo
	8XRhYOinQ0dEiq1NFjHiSgRGBc2HDYXJisHFpwMkuatV4HcL9AUtXldbXlpcVfhjYjdDkCrGTdqy/
	1g1zr14TztAqX/cgmCofEjBzsAsMvfttNE41GKxK/HluYfuhZw+G0673/Xop0M52FB+UuMubGGneM
	AAq/eAkWdVPd4AjJGfrMvZdJh/+sfOuBeX8F2WGtr/4ZX43ptFm12VR2C/Q1vOcEZnYQIbJTHjtm+
	K0KrLhcp2oFrddtd0+fVQpzH1I4o3DUl9wndX3n8DKZSyjS3SrPfU7PBRJ7pQmZmzWlLX3XjbcYUh
	N2lK7moJw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hNrMp-0005he-5L; Tue, 07 May 2019 04:06:11 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH 01/11] fix function alignment
Date: Mon,  6 May 2019 21:05:59 -0700
Message-Id: <20190507040609.21746-2-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190507040609.21746-1-willy@infradead.org>
References: <20190507040609.21746-1-willy@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

---
 arch/x86/Makefile_32.cpu | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/x86/Makefile_32.cpu b/arch/x86/Makefile_32.cpu
index 1f5faf8606b4..55d333187d13 100644
--- a/arch/x86/Makefile_32.cpu
+++ b/arch/x86/Makefile_32.cpu
@@ -45,6 +45,8 @@ cflags-$(CONFIG_MGEODE_LX)	+= $(call cc-option,-march=geode,-march=pentium-mmx)
 # cpu entries
 cflags-$(CONFIG_X86_GENERIC) 	+= $(call tune,generic,$(call tune,i686))
 
+cflags-y			+= $(call cc-option,-falign-functions=1)
+
 # Bug fix for binutils: this option is required in order to keep
 # binutils from generating NOPL instructions against our will.
 ifneq ($(CONFIG_X86_P6_NOP),y)
-- 
2.20.1

