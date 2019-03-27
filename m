Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46208C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 06:39:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E7A0206BA
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 06:39:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E7A0206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9A4926B000A; Wed, 27 Mar 2019 02:39:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 952A36B000C; Wed, 27 Mar 2019 02:39:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81D746B000D; Wed, 27 Mar 2019 02:39:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D1906B000A
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 02:39:06 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m31so6238037edm.4
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 23:39:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nuw9ssOH0zc6a25wh1vBTWVvL+74YlKCUDSQBwfYm4M=;
        b=khipl2A8gM2lZskV8Kkl9jeEJECFxTwDvvLTBaNAD6KN4aTHAerbPE2p0KBkN+8j85
         w3zgIHqzCEIr+/AwwrGkfsTbKBKynayqz1/n2YmsNRoXj1uy2L+zxHp1fnK1PfoFsDlm
         ryBZZZmkFB7n1DDxWwYTnbdkzLQ2V7UppkH31Ft4WoVD42xE7l3/qGYMtz+P7NKTRHEe
         mk15s67zIBzGPyuN82cWJEeGic5muEScTm+1D+n6JzyWWL8ATmtEQvUnlUYsEo2ekKoB
         gmX6VzyfUJjhLHj6fxfmLD44U22MdiZc6ZHB5qLGCZslTgQni7gwfEMMvE7e3jvYPIct
         AM5g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAW0sjyTumz9sksEinnbUyyCtZGj9w2zUnw36Ouu+lZuVV0Z1LwV
	ds6KEGsB4+mTOgZmDpImPqbdwBgIEY6ZaIkOmdRsjCbx0hnfYnyQblWBrLvbd0TpDNxoxlmQPHF
	3XkcNm7TQJDV5riGS/iFaZNrnuDJeiS1nzhu3/ex2nqaHYLy0yxY444o95zYBaVo=
X-Received: by 2002:a50:b284:: with SMTP id p4mr6169710edd.27.1553668745728;
        Tue, 26 Mar 2019 23:39:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUmk9utEL2vlDHBQBjxDXsORaXhkZ9I193j7Pr0q4LVEMzunljnWn7TX0Y/P5NA2ZB2q+W
X-Received: by 2002:a50:b284:: with SMTP id p4mr6169675edd.27.1553668744913;
        Tue, 26 Mar 2019 23:39:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553668744; cv=none;
        d=google.com; s=arc-20160816;
        b=P3Wd6jz/IRl0Z07kCdV7OrD/IzTEjBxIkzd3Scg6adpKy5HODapFw1twQxfh1xQaRQ
         c+m9FAdozoKL4Wbc6lcs5jg1t/8ShRUYxhCEMwApPnA9ZygSktg1YyCJhUJI1oXu+RFh
         xTcxLFejkI7F27tzdMj4eOnCZ3709+MhA589ZeRprgeqyGVV+vzE3N/INxJYm9FHRPYw
         z5QJ72schVEEyKQiMtFo4BkOCilcjQWh2Ps+WThIfuV0vodhBEDilG4CC+GPGu1+qMAU
         9SkoQDMtKXG5IItFhOVIfRYzDPr1D9/UrYi3I7J2izGaBanA3wpydQSm0qNFLwIU74ft
         lSVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=nuw9ssOH0zc6a25wh1vBTWVvL+74YlKCUDSQBwfYm4M=;
        b=G7sFXpwY+M6t4Q9COAqgwqq1pbVCm+Lgp7nCp2wq7mUdDD765qrGD0upXKGUsR9pXz
         fc43/jNPYsGglmqBG1CAlqbP7wFGY3tuuyKMjmLo5XcGtKTdhGMZuQGGQp2I2b2QgRcW
         SviZJVO9GpsWbsgPansk92gqLmXhtI5HPgCfZ4vbk7ij3urBoekTBA+QrRmii1PK9UmU
         0Ut+PeZu3NzLBxTvMQXlwCGy8EdGGzWsfDEuCD6b1arh/1N776GTgB5REPNOrvOTH/Cb
         ZjJbw8omno3hyaRzxAlaqhxJ7SOEsp83TllIWBjWREMrJ7QQUG/6iAhWpEtvY8InuHaV
         TxfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id y13si157496edp.88.2019.03.26.23.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Mar 2019 23:39:04 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id AFEE060009;
	Wed, 27 Mar 2019 06:38:53 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: aneesh.kumar@linux.ibm.com,
	mpe@ellerman.id.au,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
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
Subject: [PATCH v8 2/4] sparc: Advertise gigantic page support
Date: Wed, 27 Mar 2019 02:36:24 -0400
Message-Id: <20190327063626.18421-3-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190327063626.18421-1-alex@ghiti.fr>
References: <20190327063626.18421-1-alex@ghiti.fr>
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
Acked-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 40f8f4f73fe8..ebcc9435db08 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -91,6 +91,7 @@ config SPARC64
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_HAS_PTE_SPECIAL
 	select PCI_DOMAINS if PCI
+	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 
 config ARCH_DEFCONFIG
 	string
-- 
2.20.1

