Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94221C10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B206222D0
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B206222D0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0CACE8E0004; Fri, 15 Feb 2019 12:03:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 078DE8E0001; Fri, 15 Feb 2019 12:03:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA7C08E0004; Fri, 15 Feb 2019 12:03:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 953A28E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:03:11 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so4251018edd.2
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:03:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3FSyeGjDNZIADKBQFr5V22ox8XwqOpOZQRYVkJgSrP0=;
        b=oE9D7IhT3kBGEkzrX/ajsqvLPJsBOLBiaSTbnrmHCI2D8V/V0SsiSS4BjChABGUqxc
         9UMLHpOHuKOfkYPiW+sJW3Qx6Xf7VUW56QVd0jh7d1wJGLFh632GfAx3Uuk8OiKGl1vb
         sI5MyzA7Ar0HEmMnApUiu5waoYJLEh3x+TAGhho4WUEa/pbT3qa3O5d1vRUZtr56D6L+
         uLdQJxJqhXP65XQoqohZHZ/PD1otGltytRRKx5ZkVfMwMuK4leql5FyQuOuLC7B/CQEc
         nAVxbvPIe9lTPdbS+AaQM8bbo6wI/k6PfNsT2C2qsy9FCZkNYyXvkTejqmLNSNwCKc/Z
         VEgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuZsIRaBd8pkebIZv+QVRUKdzk/Rjsq/8xMtcdTJ2xY8JEQXFMtd
	nKFxJ0hyxUQ/5ZJxQWPCxdEu9mKCjJO551TY2gdolNluhvy1MjJNed4ZsCyPdQ68Uzb1H1kUcAI
	O5B+a5q6QsvLkB2Uz3Zrr7prT72H75VvQecKLbOZjkvJGqoxFX/y5Qw4oS2n/wxseRw==
X-Received: by 2002:a17:906:4a53:: with SMTP id a19mr7245743ejv.229.1550250191091;
        Fri, 15 Feb 2019 09:03:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYI8KwL1zFsylxBtU+j9jnuNApN3AN7XbQtW6p/39X9XfwsAGYsFr4Ucz1s/l5B5Pa34v7U
X-Received: by 2002:a17:906:4a53:: with SMTP id a19mr7245685ejv.229.1550250190055;
        Fri, 15 Feb 2019 09:03:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550250190; cv=none;
        d=google.com; s=arc-20160816;
        b=tz8WbNCXaoU4eEe9x4hBHYZZNWN2GgwYTh19NiqYeTvvpQvlLPd5Ma98CfHpn2OXYB
         8qGw0mqLVmMsb9XtqaQVpAXPcGEyjvzGqEcV9/ovwS3Wkq8HxkRbEiZ6UQbkGP3R487i
         4xo8ecGEcuwDUouvVkI+i+XLIVsFf3qk59iWGhsJ/VseJ1nxBhY/3A2JXe27Qmem8BUe
         Ag8hBdNCFK/TBz/AdFKzqexF5sA5TSE3t2vJ2oh/yKSPFSNbihY2LXFY2Pj87o1jSZDv
         X6J14nyIAedKMRVH4ItIVRUKg2qROZrn1BUUWlkpaDdP/3Eih6Vm91R1DFXaVsil24i9
         SG0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=3FSyeGjDNZIADKBQFr5V22ox8XwqOpOZQRYVkJgSrP0=;
        b=z1icTpBOW+D7lSsoa4teeZCwl/R2MavDX11OvSZONloul6/gS7aiH1e/+M52SgNu4/
         yMTF8zUZMAvSW1qgSm1fdQRCK1gG5uek//KG8QbVg4z69htt3gZ14mADzHo/OmY6TRFX
         0pIBx3kg1e5JbIoJB5A/AP2kU9az90vGiRwpA6vMMZw3aHfysiP9Kp2N7jf6t2BIijlq
         IJ4R4n1rjSx54q2tmqvkQCPtkdf9ciXOHFc1SWdxI7kUme0YavrI/mIUHTDFQjRuVZuP
         W219s3kZcRcMJjRO41eZB4k/Csmt+8B/Vo6v4M5H/pEpZRzLgFosEvFqbQw4oGuqdeCU
         nZLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k10si2156756ejd.85.2019.02.15.09.03.09
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 09:03:10 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0AE541596;
	Fri, 15 Feb 2019 09:03:09 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 172FC3F557;
	Fri, 15 Feb 2019 09:03:05 -0800 (PST)
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
	linux-kernel@vger.kernel.org
Subject: [PATCH 01/13] arm64: mm: Add p?d_large() definitions
Date: Fri, 15 Feb 2019 17:02:22 +0000
Message-Id: <20190215170235.23360-2-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215170235.23360-1-steven.price@arm.com>
References: <20190215170235.23360-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: James Morse <james.morse@arm.com>

Exposing the pud/pgd levels of the page tables to walk_page_range() means
we may come across the exotic large mappings that come with large areas
of contiguous memory (such as the kernel's linear map).

Expose p?d_large() from each architecture to detect these large mappings.

arm64 already has these macros defined, but with a different name.
p?d_large() is used by s390, sparc and x86. Only arm/arm64 use p?d_sect().
Add a macro to allow both names.

By not providing a pgd_large(), we get the generic version that always
returns 0.

Signed-off-by: James Morse <james.morse@arm.com>
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm64/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index de70c1eabf33..09d308921625 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -428,6 +428,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 				 PMD_TYPE_TABLE)
 #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
 				 PMD_TYPE_SECT)
+#define pmd_large(x)		pmd_sect(x)
 
 #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
 #define pud_sect(pud)		(0)
@@ -435,6 +436,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 #else
 #define pud_sect(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
 				 PUD_TYPE_SECT)
+#define pud_large(x)		pud_sect(x)
 #define pud_table(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
 				 PUD_TYPE_TABLE)
 #endif
-- 
2.20.1

