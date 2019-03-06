Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1012C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:02:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B95E20657
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 19:02:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B95E20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 170258E0007; Wed,  6 Mar 2019 14:02:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11FD98E0002; Wed,  6 Mar 2019 14:02:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 036058E0007; Wed,  6 Mar 2019 14:02:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A4A458E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 14:02:48 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i20so6793058edv.21
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 11:02:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eYR89qBSmbOgWLjfBNFsSAnq8PZAFEQq6qjut3XM6yg=;
        b=Ko1L9b/NVJ0X7qpcm3dMCIhtBdcwuera2V7uEBQhy1Fr8pQzxe4+IgUtw5nUVJBwOm
         ku5uBJO469qDfTRNeFD+7rQexwGC9vBzR0CRbxLmbdCWIwBG9eKrTY3yRjgCk4icJzpF
         gs205KmXzZnN1DNQQd922sQL4Wx9AUwKTCdf1x9gPne2lRdOHkjJ8K7tNqjMLcLx1X8B
         ss9eAqlUqWAUsDDma5Vy23qEV4WG9TLZ+otIuSoEmad7Rpja0Vonv68IAnT8N5RJGp5S
         f7Zs7RWzCTMLkynZ+/T4Aa7T1jZvY8HFepfHRAEFcrIc2CXz0DUHwQjto/7uI2LmV1Jd
         TK7A==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUJ1ElYIYtaMJkdEoquCZSX378w1fk1qPNZXf/2zVUOMoug7ZYo
	nCKViVYpv6Pk/JgfQnB9Kj4cUWCS5aaDbBGJl1oRKIgNIIONK02i2+2IJdTBIXFDOW3a/q42TbG
	41TRuQGCa2nSaz+f3qSqmXrA3KoDQFQ3kueQIkQYIsef4qSf8SqJIzZA3V2V/Epc=
X-Received: by 2002:a17:906:e107:: with SMTP id gj7mr5008690ejb.208.1551898967842;
        Wed, 06 Mar 2019 11:02:47 -0800 (PST)
X-Google-Smtp-Source: APXvYqw4U+MR8YZT0NOwYZ8TPAhH7tLylMNB0picseerDLk9lcx+fXrkKemTga24kLSvQrrzsCew
X-Received: by 2002:a17:906:e107:: with SMTP id gj7mr5008619ejb.208.1551898966386;
        Wed, 06 Mar 2019 11:02:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551898966; cv=none;
        d=google.com; s=arc-20160816;
        b=vzqTvSplLCPfRMl5HftZlPckgNJ+T92l/JeimNnaGfdZgGI96bPGi3cxv05Yd+7Jkk
         FS3205eon5d4hZoYe3oUcU7zdHeD0QiAZI0/0gqr8GhoovraspmBa5nI/FLGlq2IT6yL
         uorvZho/q26e38zzFwtkcemI1rgYrDhHRHfD2Mj+OuhrcVK12Gx4emuiHnONRmiPafaO
         wtOf7Vk1M0JAvOQpXw6PAQHUGYpZWXGdg+PDzCtaEIK+QnJArTc/kAZ/ZMjRT5Kox53R
         cvWnmc55oPrRajMgaInd8ByirHd/JpdAT1aXTyOhd4Rs6tCcEA3JmicrTvH/BbAwLCSM
         N/4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=eYR89qBSmbOgWLjfBNFsSAnq8PZAFEQq6qjut3XM6yg=;
        b=js1DhydGXstCILTzyczBITvBldgiUApv8Z8vmpuMUjrRuPwWRoBNyZIer3BS03f74m
         32i4XM5mZvvz1dEwiQ3HbMk5Jzj78plF39EiD8IsUedt+XGVQRkgO8b0GbvyvCjO84zX
         txPGKSbDxpxsIA1RjZcgnmZwfAjIpR/8aiTfE/RGUXlUlt12CvWx8tmiW5GQ3kzWlmgT
         jWIrgCmLyfPM9QjlYbwNmwkhkcTKEcewmy+FMNW7oyFD7s28McAt0KfE9VUUSQJ0P80f
         FR4fb6IXnE+BhKsxmbH8YvJUzjUy+OGXZmsZz/RLRN8NUrrkfHj3H/HZ3EodBmhjbGOK
         NjTw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay9-d.mail.gandi.net (relay9-d.mail.gandi.net. [217.70.183.199])
        by mx.google.com with ESMTPS id l1si966308edc.151.2019.03.06.11.02.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 06 Mar 2019 11:02:46 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.199;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.199 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay9-d.mail.gandi.net (Postfix) with ESMTPSA id 98D4EFF804;
	Wed,  6 Mar 2019 19:02:28 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Vlastimil Babka <vbabka@suse.cz>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S . Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v5 2/4] sparc: Advertise gigantic page support
Date: Wed,  6 Mar 2019 14:00:03 -0500
Message-Id: <20190306190005.7036-3-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190306190005.7036-1-alex@ghiti.fr>
References: <20190306190005.7036-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

sparc actually supports gigantic pages and selecting
ARCH_HAS_GIGANTIC_PAGE allows it to allocate and free
gigantic pages at runtime.

sparc allows configuration such as huge pages of 16GB,
pages of 8KB and MAX_ORDER = 13 (default):
HPAGE_SHIFT (34) - PAGE_SHIFT (13) = 21 >= MAX_ORDER (13)

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---
 arch/sparc/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index d5dd652fb8cc..0b7f0e0fefa5 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -90,6 +90,7 @@ config SPARC64
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_HAS_PTE_SPECIAL
 	select PCI_DOMAINS if PCI
+	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 
 config ARCH_DEFCONFIG
 	string
-- 
2.20.1

