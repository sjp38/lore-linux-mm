Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 501D3C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1630420C01
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1630420C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCB9B8E000B; Wed, 27 Feb 2019 12:06:57 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7AE08E0001; Wed, 27 Feb 2019 12:06:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A46858E000B; Wed, 27 Feb 2019 12:06:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4378E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:06:57 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o25so7120591edr.0
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:06:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZHm1cyXfjE8tEi0dNKBdwMdPKaBv8xSlMukgn6XJeJU=;
        b=AlWq8fAxr006EYuTE8MLztX04HseHXaeRKt5/q5jvnFZjcL+i2KV/sniCz+NOv0TLR
         9Rd/6/Rl8WL3ncOHj5kG5wL0QPC4x2SrWJJIrNLJQGWkHMQQBcFK5rRXXSiC6MxOudn3
         j3CqBIE//IMMGNEsVHitjbdOM58Xxwwru/gKEfLfIt75s0809G0EPramH2WjoEl7Uf66
         4bSSgH1fnlfkAfqSyXb9K/1bLulaDAtDO3ko5MwHe0xkFp3NOHWNEC2C+qMFZWyk+XQP
         xQCgR1lBQt0w59q07UhVpFncp2SBvNlVTqyZt/EnomSTP+7pHt836HPGR9Ni3AokViK9
         f3wA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubb/sT5623aMGHOO0i4Bz9MPBiSCDIyCJGekdyGSffjUIS3v8P6
	69UnLZl3hhxp/YNwxuyj+kdtGYLoOXNO7Hu+OWBqYNumHTDc5JDlh06c1tSIFEG/Lhq45Ya4UZA
	f4t8eMBHbu8LF/O8uLsXRUKaYNxWVJjGuCgKGFPb8AMXJM+JImwTq7s1AnJtBBd+B0Q==
X-Received: by 2002:a17:906:5586:: with SMTP id y6mr2289581ejp.197.1551287216813;
        Wed, 27 Feb 2019 09:06:56 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ4bVM1dAt1LOyn9IbcqlZyd62civEHohiNf+4aM0sSvuRRc5/iaxMpiWDU1+zsw5Sk8kjj
X-Received: by 2002:a17:906:5586:: with SMTP id y6mr2289519ejp.197.1551287215763;
        Wed, 27 Feb 2019 09:06:55 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287215; cv=none;
        d=google.com; s=arc-20160816;
        b=QkeiCsVAH7tAG35osYHEEZRYTK+zJliqA/QHhhYBeoDDoajyq0qQs85PoaBgQmdJlp
         r7MiaaWE1sxr/2wtOnFX0x0d223XsYlVR9Uuj4JB6haekVUntUQuYUi3fu12GRUkHWF/
         UdH43kvLKi+fu6N6g/CweNCLHOcRDP/8ZUk/AjaooUL5xuAILC5VK+CE/LsqUmaofLy+
         oO/WcKKlK3WQCkRYin4HX+n2BpjIBBoGyaWWnZ6kz9dENjPnbIWBgkihrgb0PgAZk3Ny
         O0CTXM9uML6nc8ZwPMnb/g7RjNXTdRRIUYQwpiyf2/vRIi8SPkFwveXmkm8EVAgZiwsA
         l7AA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ZHm1cyXfjE8tEi0dNKBdwMdPKaBv8xSlMukgn6XJeJU=;
        b=lZYS47ajllmeT5R9lAHDCnp8zQNZ384bPniHcPd2boJ+OH13W5uMUZluSGdyZW9mat
         82N3HNpEfrK6Cbo9zosZoh6b4oyyAXSJ64ouWVvF1l1TrMy2sqzUYu9CE1iAGljltAXa
         qBLw/wSCLhhbS6h1gjROh2omiacxBdEbpnv2xKcnlG1F0YetIw7WWx1eaA5sofMAcQQm
         EBiOj+0Cfx8sDuNeBaZcLuYnPwNzbIWfXH1jtZY9gs15WtRuEfPZ6MHNPzi98uMBh93G
         +YDGVdtCjK8nnllwohfpsoGxZZ9WcfocvQXTTEQCgSXMTkCHsQ9QJTsmhBrsdLxEkQlD
         YOWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i3si5075214ejc.34.2019.02.27.09.06.55
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:06:55 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7B91D1684;
	Wed, 27 Feb 2019 09:06:54 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id EE5103F738;
	Wed, 27 Feb 2019 09:06:50 -0800 (PST)
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
	Richard Kuo <rkuo@codeaurora.org>,
	linux-hexagon@vger.kernel.org
Subject: [PATCH v3 07/34] hexagon: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:41 +0000
Message-Id: <20190227170608.27963-8-steven.price@arm.com>
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

For hexagon, we don't support large pages, so add a stub returning 0.

CC: Richard Kuo <rkuo@codeaurora.org>
CC: linux-hexagon@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/hexagon/include/asm/pgtable.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/hexagon/include/asm/pgtable.h b/arch/hexagon/include/asm/pgtable.h
index 65125d0b02dd..422e6aa2a6ef 100644
--- a/arch/hexagon/include/asm/pgtable.h
+++ b/arch/hexagon/include/asm/pgtable.h
@@ -281,6 +281,11 @@ static inline int pmd_bad(pmd_t pmd)
 	return 0;
 }
 
+static inline int pmd_large(pmd_t pmd)
+{
+	return 0;
+}
+
 /*
  * pmd_page - converts a PMD entry to a page pointer
  */
-- 
2.20.1

