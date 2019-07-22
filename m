Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C533C76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DCB52199C
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DCB52199C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB45D8E0006; Mon, 22 Jul 2019 11:42:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D95638E0001; Mon, 22 Jul 2019 11:42:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C30C98E0006; Mon, 22 Jul 2019 11:42:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A14B8E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:42:37 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id a5so26537014edx.12
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:42:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GFoSGCQZUb3PnmR959rCzy1mnzvRnBqgnRMQdV1X/EU=;
        b=YKejT/8/o7PySvK0ehH4o9xmMZXcARHFT79OChh6gALSlf6mIXuaGYk4cMpoLEvp1+
         CZmKgjV7Qgk/j1+qdPCIOtd+6Z0ut0lB8QCdbHr1z9KycLBKji4w0lKjXOt5WmUWYcSV
         QEfMH1fZFeNq3WUKQcGomcGWHONDbZpHu94uSMHoP2gGUzpgeB3rUqZLVNeT5kGbG1ce
         fV44upy79hbcHvmlsJSqmZSIcbZdrDiZDGz+wdthDw1fv3k0m7FLbjAZfQsyxby9utdB
         4BYs8Phuu3uM4ZC8sB+g5U9EQqgHjnxNLO9rst1EXFkOokgkdCNftpRTWtO7Unf4+/bo
         tvlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAU/FxRj+4QZBsnf1HGzK9djvmoo+OWG/+iV4lzXpDMEEwzlIEVh
	agMPTS0qjAUgaf4n3Dwa/Hr8lbpl8c809Wjtjz7isVGQdVoV1EJGoWRUHFLvtCuvRXF+KqmkX8a
	RaGteZCu5KUik/Aik82f/9lWIZhzHQ/AFbjNH5n8kpj2qja5oH0GkzgExRidBoEbFBA==
X-Received: by 2002:a17:906:6582:: with SMTP id x2mr32058275ejn.2.1563810157010;
        Mon, 22 Jul 2019 08:42:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEH202mAR9PhflBc9IZ9+cKSF4fRqV48h6GRTMG4IGniHzqjaRggAITJs+QI35MtRcgC7i
X-Received: by 2002:a17:906:6582:: with SMTP id x2mr32058224ejn.2.1563810156231;
        Mon, 22 Jul 2019 08:42:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810156; cv=none;
        d=google.com; s=arc-20160816;
        b=qgqYUPmqwIVOkhkt/zNrlPdaoOwRkMpPmfZ2gvrvhgsxmxkwGt3+afDJp4Wl7A0lB7
         PVKI7LupFy1hRgErgvoDKRnq2VATYxSsOeFW3MPlhqcV22gCqatDih8acK4kR4bohNDj
         8v/Km3FHc4QKC3KEVb3BberSP4nIHhJInCHE3BjKge2K8PI33yJm1UZVl8cWlxGVTGDt
         KFklX+NVOVmg5LdXllPkrrPIhrYYdYYj1hdU6Cp5Wj+qv5qTsZ0cc/IyBraSzztJXWqA
         HDq8ILUzXI63amKur3iV9bqYnbD/mNtDFx7TDObPacs37/Ep26b6XyCF0TMzTdCfrocW
         K+hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=GFoSGCQZUb3PnmR959rCzy1mnzvRnBqgnRMQdV1X/EU=;
        b=oU+Sbwd5+TEfxTpGvJVwwuJDuMui8H+nysCu4ZqpYSt+2KVJT2Yi4tzdZvUU3ByGyl
         xURILmocaDvUbBofwUuH/9IX/zwtlQTcrqxgvSpmLIdRRkoU+csf1y2hA7E2/xAT2Aje
         a0Id76RtBvR87TMkk6Rbeb4Xf+fpQ9wX1bohUYtP4gHmhAZVjUW/GDGOYrKust/Lsfy+
         unYtWOLzavTVIZ8CQyLuEDuLrKOhTJwIDwZyVzmnv4OltbJjB9Dr7VW4K+Zt/mvH8329
         a3o7Nk7DtyhQcI1Xq09quGFo54trg2+u9H8Nw6dVZ9T1DNxdVUBgSe8ZVKjAZnOCWKmi
         0r9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id v6si4342402ejx.120.2019.07.22.08.42.35
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:42:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 740AF15A1;
	Mon, 22 Jul 2019 08:42:35 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 71F6A3F694;
	Mon, 22 Jul 2019 08:42:32 -0700 (PDT)
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
	Will Deacon <will@kernel.org>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	linux-mips@vger.kernel.org
Subject: [PATCH v9 04/21] mips: mm: Add p?d_leaf() definitions
Date: Mon, 22 Jul 2019 16:41:53 +0100
Message-Id: <20190722154210.42799-5-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722154210.42799-1-steven.price@arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
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
p?d_leaf() functions/macros.

For mips, we only support large pages on 64 bit.

For 64 bit if _PAGE_HUGE is defined we can simply look for it. When not
defined we can be confident that there are no leaf pages in existence
and fall back on the generic implementation (added in a later patch)
which returns 0.

CC: Ralf Baechle <ralf@linux-mips.org>
CC: Paul Burton <paul.burton@mips.com>
CC: James Hogan <jhogan@kernel.org>
CC: linux-mips@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/mips/include/asm/pgtable-64.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/mips/include/asm/pgtable-64.h b/arch/mips/include/asm/pgtable-64.h
index 93a9dce31f25..2bdbf8652b5f 100644
--- a/arch/mips/include/asm/pgtable-64.h
+++ b/arch/mips/include/asm/pgtable-64.h
@@ -273,6 +273,10 @@ static inline int pmd_present(pmd_t pmd)
 	return pmd_val(pmd) != (unsigned long) invalid_pte_table;
 }
 
+#ifdef _PAGE_HUGE
+#define pmd_leaf(pmd)	((pmd_val(pmd) & _PAGE_HUGE) != 0)
+#endif
+
 static inline void pmd_clear(pmd_t *pmdp)
 {
 	pmd_val(*pmdp) = ((unsigned long) invalid_pte_table);
@@ -297,6 +301,10 @@ static inline int pud_present(pud_t pud)
 	return pud_val(pud) != (unsigned long) invalid_pmd_table;
 }
 
+#ifdef _PAGE_HUGE
+#define pud_leaf(pud)	((pud_val(pud) & _PAGE_HUGE) != 0)
+#endif
+
 static inline void pud_clear(pud_t *pudp)
 {
 	pud_val(*pudp) = ((unsigned long) invalid_pmd_table);
-- 
2.20.1

