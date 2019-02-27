Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 999F4C00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 63DBD20842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 63DBD20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1437D8E0010; Wed, 27 Feb 2019 12:07:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F2DC8E0001; Wed, 27 Feb 2019 12:07:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F25C48E0010; Wed, 27 Feb 2019 12:07:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 957768E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:16 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u25so7228972edd.15
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vbZU3Jpl8GuYX6FyWhyD9GsHMstn/Gx+XRtazXG+JbY=;
        b=J2OpAxc5A8ksa10EK61PycxltU0JTcKwvM1pRI8A4HdNPFhu8ABtyKTM9XjgbyiQ4A
         R7ucZKzEiBtMTbCyshmwu1tFGMctu/SaUCPcAoJHs8VrGbbwkTKkmlUkFUhoz0KhwBmn
         UHSlpOySTKB7G+vWa5EmfBvfPTKJGG/x3Vh046fPQmzVk5p2x1iIncUXaXOEJja90XK7
         M/lBg90SPG7Zsy3w+KWk7/wY5JfcAFgCU8AwN0vjEYq72QOAExg895y2PLgnpK6kluz5
         Rzi7f3TC6Bh+qkEMyD8OcJzVEAoG1NAxCMzImajpjX/gW4WzbqywdQQF5//awhURM8lr
         UZFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubr9M6sOzxukjgfM1D0Z0CB+JdiN8oNWaCmhaF0f4EHFDjBtEuQ
	giJiV2MaNgYEdilMv9WBSFUSjypzEN4v8UarKFelo/mznpskGLzds8iZMgH1I3Qk2TmHCDDlXfe
	OYzHm4fAu6Y2M1mlRD9G4elB9V4xmd8rLg15vvIdXFed2Vf5Kdbaqkb9VJ5x+4aPL9w==
X-Received: by 2002:a50:97d5:: with SMTP id f21mr3116316edb.293.1551287235959;
        Wed, 27 Feb 2019 09:07:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbVpDu5DIlyvkeavVC8HjxryTmwWPTRKwUEUYryb94kagt16vBK16lJrM2k00HX9L+iADMC
X-Received: by 2002:a50:97d5:: with SMTP id f21mr3116231edb.293.1551287234708;
        Wed, 27 Feb 2019 09:07:14 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287234; cv=none;
        d=google.com; s=arc-20160816;
        b=R/FFE8AIviEaX2VT6NwkYO7TqmTrpSNCwbGqGH5BTIS9yL4SYjvQCXFBol7oD1yyY1
         PSNuQLZVv3BvIz3MDaZY/2kAtV6DiNtQ3EFK3tCoBZlNsqhi7sBDnIIhOh2GpuRSrvRO
         1dS437a6F/0nTN7bMR1eMQQLkzE9eCZAqoTBGAQxjqFXI3eMMszvuJurG5cP37EKjJd1
         GaOrx+4qtKn3pPKXYipDpGtKYR9Y5GLe9yt5I7dQcokiIezDOprlBz2U0cD6QdKPz9a5
         ONBBqtmC2BZXWuC+KoAqm7UdDO0KphovIUsfCN2uIh4F33CLPeBLz+XG05gUYkCYRq/8
         wfwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=vbZU3Jpl8GuYX6FyWhyD9GsHMstn/Gx+XRtazXG+JbY=;
        b=S4k8IYx7pQMsQth2/A/PnScrb8klyQ4v3Sokq/6h/M6iHeKNsjZ8qZqqNuu5gjKj2z
         eJJn2aYHOGX/iZQyJnfSoRJFaSZd0ZEUPjtYFYg3piKMUqgJqHwc2sw6yPQeIOzeItYS
         TINE7Ziurl9CeRwZAAwS6pD7eucCHmA8HqggL3U9vYpWDqGhnmsOBDpJ9JTYNQVpwUFb
         1B0uqoaQwFol1mT6GUpyhtReS7NUi2yQISKux4OmBLFv0edyGSKYq5tMNrZM/OCM+LNS
         VbDgJgoz7G20ggPY5zzGUNzW4VnMmevcSxgMgp3jYNPz0cv1CqXIAj609C23/NFYgvRP
         HtHg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e17si1612372ejr.1.2019.02.27.09.07.14
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:14 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BD4F5174E;
	Wed, 27 Feb 2019 09:07:13 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 384C63F738;
	Wed, 27 Feb 2019 09:07:10 -0800 (PST)
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
	Greentime Hu <green.hu@gmail.com>,
	Vincent Chen <deanbo422@gmail.com>
Subject: [PATCH v3 12/34] nds32: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:46 +0000
Message-Id: <20190227170608.27963-13-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
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

For nds32, we don't support large pages, so add stubs returning 0.

CC: Greentime Hu <green.hu@gmail.com>
CC: Vincent Chen <deanbo422@gmail.com>
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/nds32/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/nds32/include/asm/pgtable.h b/arch/nds32/include/asm/pgtable.h
index 9f52db930c00..202ac93c0a6b 100644
--- a/arch/nds32/include/asm/pgtable.h
+++ b/arch/nds32/include/asm/pgtable.h
@@ -309,6 +309,7 @@ static inline pte_t pte_mkspecial(pte_t pte)
 
 #define pmd_none(pmd)         (pmd_val(pmd)&0x1)
 #define pmd_present(pmd)      (!pmd_none(pmd))
+#define pmd_large(pmd)        (0)
 #define	pmd_bad(pmd)	      pmd_none(pmd)
 
 #define copy_pmd(pmdpd,pmdps)	set_pmd((pmdpd), *(pmdps))
@@ -349,6 +350,7 @@ static inline pmd_t __mk_pmd(pte_t * ptep, unsigned long prot)
 #define pgd_none(pgd)		(0)
 #define pgd_bad(pgd)		(0)
 #define pgd_present(pgd)  	(1)
+#define pgd_large(pgd)		(0)
 #define pgd_clear(pgdp)		do { } while (0)
 
 #define page_pte_prot(page,prot)     	mk_pte(page, prot)
-- 
2.20.1

