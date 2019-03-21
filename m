Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C79DBC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 915E2218FF
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 915E2218FF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11E686B0269; Thu, 21 Mar 2019 10:20:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0A5126B026A; Thu, 21 Mar 2019 10:20:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAD486B026B; Thu, 21 Mar 2019 10:20:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB9D6B0269
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:20:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m31so2296359edm.4
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:20:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PlduaFV1LjO5scXRf9kwcI+ukcg7zXNoRrXpWadVZPc=;
        b=N0Ep4EHLkLhXkL0NcjheJidPAdtipuUG8iMqIDeHzuw96iNHFCf3eNbyyZZ/6Nj/sF
         jJZNh4y+T/7uw15zuqssAP20HpNyud2cGUWAKdC8wIuMKzewN26VNRetJSLxA1YhBEav
         XQaqYgeDr8t0YGh3ysJp0+Ixll3GHkUEjHQomnOOUZYtDXKsEHr50vbrKHSi+oIzSbZf
         4Dq+1MKDQjG9By7l4/ZKOxugvK57UkOUDSQKpiosMWcZyz6qENs0ovFolDAhY6pvtCv7
         KzxlGYXw6awLetQZtYhDRRLp9hWi5dbbKARK9cVx41om+UVsPybqvkZmLZMGfLc5TJY3
         PGEA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVDph4mNvSn9dU0BoP/pXYuUXGjHOWObDOeh/alo1R3tnsZKw/B
	SEXvVqlQgAIM6gSpvWgmTFsolp8skfIUZk3jzZ+7mgiceloKP+RN/fLQ6qcRB8j10e6R/4LK/6W
	EU1164eSlrPvART5HqK1y/UD1wfEfR95bx3+k4oZLx2Iypi4X6NHWCs1HG1dYV7AAJQ==
X-Received: by 2002:a17:906:4453:: with SMTP id i19mr2471635ejp.39.1553178035114;
        Thu, 21 Mar 2019 07:20:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxh1CutLRerQM19q8hwnttsZNEouKSVvR52ngB5hcfs8JbXSdW3ydnk1Vh6QyrxjEEUPpq/
X-Received: by 2002:a17:906:4453:: with SMTP id i19mr2471593ejp.39.1553178034294;
        Thu, 21 Mar 2019 07:20:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178034; cv=none;
        d=google.com; s=arc-20160816;
        b=I9BllptGDmRfEOcyLdKBytFh1XQqfOOn1qGTIMrn4FRqIZienyY8Pc3nhN+y2qt+bC
         bbMuSJKXob+SQeiw4WEXNRuyf90Ce8UKEMvbqR9ilVzbcJvMuCtStY2TI4okX2Gdq+Id
         cwCENdDkJRhVn/P14Vsgt3+IjzmRawyHNMmqrnNTPNj+SpMvP7srvtSjs6KpQ3XhR2oS
         2qGa7IW1shYzEeMcOmdv30Hwn3eVVUQSaOYFSosEGIcCV3Ezw5U78JxzHO8hpiEdt5cT
         A4vF5/APu9yaZLZgoGWfLgnNu68yCK9q6Ej5Bn7+w228G3sDbv3EE9LgLPFYmcqFilKr
         dQJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PlduaFV1LjO5scXRf9kwcI+ukcg7zXNoRrXpWadVZPc=;
        b=r1yJI44aPNJ605WoZWPepc0x+BolHWAVlt5N8YKFdhyms/WfH1M+8x6QTzK6kIPNDy
         kiDkBBEg65XXwVTSLZnjVnhay9NFhzP0BkTwd/hDdHpzcTKqM/oSDF17NYpjul/Y9Clc
         PlIWrKeXjTNsrBG8fLKHuxEHjSwWVCJnCIts/NXjZv35w4AlaD/14ZS12151AGTiNYZu
         f/aaI1tmEIX2A1T2OGAYaTS/s6bZdoQWQqPQiSgtPFrPYf/zM0eUgmpHliDLTKYW2Hqy
         i+UeLz+LlCtlf4GLrPgm+QW30/oqI44dnacU9CwHrRbL3yGViywaVcW0kfsWimeGT7bB
         J9Ow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g18si1218846edh.169.2019.03.21.07.20.33
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:20:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4437D19BF;
	Thu, 21 Mar 2019 07:20:33 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B70D93F575;
	Thu, 21 Mar 2019 07:20:29 -0700 (PDT)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	sparclinux@vger.kernel.org
Subject: [PATCH v5 07/19] sparc: mm: Add p?d_large() definitions
Date: Thu, 21 Mar 2019 14:19:41 +0000
Message-Id: <20190321141953.31960-8-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190321141953.31960-1-steven.price@arm.com>
References: <20190321141953.31960-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information is provided by the
p?d_large() functions/macros.

For sparc 64 bit, pmd_large() and pud_large() are already provided, so
add #defines to prevent the generic versions (added in a later patch)
from being used.

CC: "David S. Miller" <davem@davemloft.net>
CC: sparclinux@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
Acked-by: David S. Miller <davem@davemloft.net>
---
 arch/sparc/include/asm/pgtable_64.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 1393a8ac596b..f502e937c8fe 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -713,6 +713,7 @@ static inline unsigned long pte_special(pte_t pte)
 	return pte_val(pte) & _PAGE_SPECIAL;
 }
 
+#define pmd_large	pmd_large
 static inline unsigned long pmd_large(pmd_t pmd)
 {
 	pte_t pte = __pte(pmd_val(pmd));
@@ -894,6 +895,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
 #define pgd_present(pgd)		(pgd_val(pgd) != 0U)
 #define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
 
+#define pud_large	pud_large
 static inline unsigned long pud_large(pud_t pud)
 {
 	pte_t pte = __pte(pud_val(pud));
-- 
2.20.1

