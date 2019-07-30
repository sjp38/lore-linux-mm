Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83EAAC0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:02:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5284F2087F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 06:02:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5284F2087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D62A48E0015; Tue, 30 Jul 2019 02:02:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D12728E0003; Tue, 30 Jul 2019 02:02:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDAF28E0015; Tue, 30 Jul 2019 02:02:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 735568E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 02:02:23 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so39585991ede.23
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 23:02:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CozSP8ClhxqYRnTVyauC5EuB32xQZZhYjVFYo6YFdyo=;
        b=TwYyWJxDrqc/01Mpkq6pTB3wiVAqFLo71D6f7EAwgBiYVxw62+vM0QLjct2YNWWAih
         4meA2sm8vpKwvwJvLhYDRUrGsF7HCN5lOun8ChwcTwguXh+tTyPbcMOd7su7PraCMvGI
         PbSAYX3QBrEeNb0uePLRkzzUCppMRwj86hl3d5PAePSMqTGYb0SeB2/dmdxm85i+0zib
         GnzEJdRWHPgQoT+68rX2Khx1ls1IsF3OJQLeaOiTYJnwoAl3c8N/XW08sCt2ku147ZRf
         2gR5KRHplkJyakaV4CewDZa1C6mli1aQSAqFzyQa3ZJGe+EuESBh0g3rgIpDC/B6rlG0
         8VRw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXKJIcxQOkdZV0iWikQZqMKoqLRjcWlgykxREd6Z8/F0UEWcZWD
	6c5XKF8Z67fGvP0v6j6nZ5ajA6EJiMX2Xb3XA4b5CTANGWbsIS0V+hNRJW3186uu+ZTsQ1pmQbs
	tOOLQhjoeZOax9jPkQHyzvEnKDqs/NiEwrFo+77+T8mPIo8/bVbINYqIOXfan4Kg=
X-Received: by 2002:a17:906:b211:: with SMTP id p17mr87462398ejz.11.1564466543047;
        Mon, 29 Jul 2019 23:02:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVEW+5o53c3BLVdgf9ypjCSCVnd0/UnWcCWsDOL/0TOmCxXA9a1FCK3meTa8e8cRtEqDxm
X-Received: by 2002:a17:906:b211:: with SMTP id p17mr87462325ejz.11.1564466541880;
        Mon, 29 Jul 2019 23:02:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564466541; cv=none;
        d=google.com; s=arc-20160816;
        b=Rrwgh706Zrxr0Uhr5Oy6M9UncGsy4WHNfN08Gjl3nypkh578jgMQPuT+6fRaHQjzen
         5KzXAmnJS5yqYdrDyDj60c7p6gFgnMUPKm7vlmdPCKpfQHpKFnamUEcplbg+3BY7KAah
         H/E4rpMu9BATiSVY4GWvTSsXbyoui3IZgBtZS4rZ2sqQTgoslI4ItIRHatMSDLUlbye8
         VPQrHatDvlNiTwjbtDf5onGihr+nYhjgMIOVS+905pABO1ViexvB9DymyqOZbj8IcmoZ
         8mZCPg6krENOWLR3gjaZ6H64o6amVcXnJOWMIqHbHI7SnCzSMn+Q9au3Lg+bs8MhpN54
         /4jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=CozSP8ClhxqYRnTVyauC5EuB32xQZZhYjVFYo6YFdyo=;
        b=Lshu+1YzMnjVlD9n1EYGPHHw6RVuHNQUJEFIfQ4XeprYb3Q0TcveD9q63LM1Ng2yN9
         IG9AkyCIGE4jqsJ9hvYS7qAAsAwCl2TGitPgXbHkVjIT6yAnDNOAQKBzaOLF8J4I53xJ
         IeVfTolQn8qjh7VPCCVLyU3uS+DWiqJAMcX7frViCphas8MM5AYn55e/Vl/m5cvgG92p
         YGOLq+logOSDgPQRAf5rHWeKc6QYUPV9FvQ0iHE4YmgKPB6dbYstGnUCpCqxU3ke8Oz0
         J5phoJKduQqZL8FdZSc2r3p91W4Gv943KnukvAhBobit7fWKCud65+mtlRKQrW2vQ+li
         QV7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay8-d.mail.gandi.net (relay8-d.mail.gandi.net. [217.70.183.201])
        by mx.google.com with ESMTPS id z3si17199149edc.389.2019.07.29.23.02.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 23:02:21 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.201;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.201 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay8-d.mail.gandi.net (Postfix) with ESMTPSA id 925B41BF20E;
	Tue, 30 Jul 2019 06:02:17 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v5 10/14] mips: Use STACK_TOP when computing mmap base address
Date: Tue, 30 Jul 2019 01:51:09 -0400
Message-Id: <20190730055113.23635-11-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055113.23635-1-alex@ghiti.fr>
References: <20190730055113.23635-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

mmap base address must be computed wrt stack top address, using TASK_SIZE
is wrong since STACK_TOP and TASK_SIZE are not equivalent.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Kees Cook <keescook@chromium.org>
Acked-by: Paul Burton <paul.burton@mips.com>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/mips/mm/mmap.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/mips/mm/mmap.c b/arch/mips/mm/mmap.c
index f5c778113384..a7e84b2e71d7 100644
--- a/arch/mips/mm/mmap.c
+++ b/arch/mips/mm/mmap.c
@@ -22,7 +22,7 @@ EXPORT_SYMBOL(shm_align_mask);
 
 /* gap between mmap and stack */
 #define MIN_GAP		(128*1024*1024UL)
-#define MAX_GAP		((TASK_SIZE)/6*5)
+#define MAX_GAP		((STACK_TOP)/6*5)
 #define STACK_RND_MASK	(0x7ff >> (PAGE_SHIFT - 12))
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
@@ -54,7 +54,7 @@ static unsigned long mmap_base(unsigned long rnd, struct rlimit *rlim_stack)
 	else if (gap > MAX_GAP)
 		gap = MAX_GAP;
 
-	return PAGE_ALIGN(TASK_SIZE - gap - rnd);
+	return PAGE_ALIGN(STACK_TOP - gap - rnd);
 }
 
 #define COLOUR_ALIGN(addr, pgoff)				\
-- 
2.20.1

