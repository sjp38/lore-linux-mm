Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D0FAC10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67CE120830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67CE120830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17A566B000D; Wed,  3 Apr 2019 10:17:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12C736B000E; Wed,  3 Apr 2019 10:17:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 019E56B0010; Wed,  3 Apr 2019 10:17:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A7F3A6B000D
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:17:25 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l19so7505505edr.12
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:17:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MqMqukGILHQS5vjuNGdSQFWysz8AgSB4keSNgmoOKiU=;
        b=o8Qk1cc6LFZ8YLvUQNDoV2i0gv6OtOf7vsEtPqrWMrKItUrqs94liwd3STbszBnJdg
         46/DqSKGe/lif0+BYw7GHw3si/sp3cMYu38CQw08sFpWh4LoUP505rEwi4GKUeyFP0rj
         lJeuSawovU/ophqFqKVlG1uSqnJnL0/S3KGpSi6rdKcjUihqbC+5+CzHshaW+kmfXN1v
         bP9VH7v/lkUFFRUV4Do2DzuqnmDRMLbW6SmIUrb7Z3aieoXGrj9MFNAcn71KS1dn9aS1
         RVKCIBfg5KrdCsJ+gua7NBoS/lteUH7eoMRzZsM42y903gaVEt4MSBD85wk9L0ZguCSt
         2PJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAU/ILlmRDxf9rlG1RlMfAYRhyKzq7/z1FjdYOfmc8gUW/OLbQ1V
	x0iR4IZSL5gYPt8cq1LbSIla9pFRUSLfUsikZzMIFIFafTSEyVpN/FL0hUBDHB2znNrgaIaW21+
	AbumMfTRXQ5LAU8MdCrC2WpOLV810yD4Wn5f4KEDcg00Af7R2KHuwIPz8ywWauW1ucQ==
X-Received: by 2002:a50:b6a9:: with SMTP id d38mr50401035ede.98.1554301045211;
        Wed, 03 Apr 2019 07:17:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfeB19XcgSAHCGppBvscGbZbZ5gJefz0Tbm9nutsLt8y2P1ALT5M6OM5aGHCb2/OfvI+/X
X-Received: by 2002:a50:b6a9:: with SMTP id d38mr50400988ede.98.1554301044371;
        Wed, 03 Apr 2019 07:17:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301044; cv=none;
        d=google.com; s=arc-20160816;
        b=gPKHl2HUP8uCo70kZSNfZAQJ2CoKHwqniF2j7BghBUUrqtgYkUCMHPJouBCumd1OTd
         6z2e20OLkQPf2wxVgLmdHSoa6L21h0Vdff59q4AJTv+qTeUHTtzrJoqskNApJ3OHvd6k
         uH8TFtRfG8BeVdtBT5EfmUrfo91Kr0NZ1V2tm3DR9Q8QUONBJqHGLuqAE+tGcGlZhI9Z
         skoTs7Wfjs8I1KPFdsRtqgyeTilLbuhl7312qfr6GlRf4VmL+xfcELqHTmACVwS0vKZi
         XbtPCdQW1m/52hE9mIDqsSRMVvYKP/R9XdN5zdO9oWAuqPmjlvVZS8ptdOoieNHbUp9s
         dHEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=MqMqukGILHQS5vjuNGdSQFWysz8AgSB4keSNgmoOKiU=;
        b=Y/g8q6JyFhyUyO/M4tJnadGXKfyiJvX7FGBSCKGQiG/jEYhsl4CDrJCiq5ckK14ozM
         ndql2l6Wl0f80RZ92h67ErbLMZTwOJ/UIbx8H4fBL1hPXW4i7akPxNUeFpF4AtcgQG3C
         fNftQcyYyzQEFVQvOY8L16herXcuAIQGe/CZBiDEhkxgUUNZcLpe59uZY7+2ORvEvtpE
         yYvGChAbBY+sR7NFCtj26kByDweJIqBO0r/wW3+uHF5KdEjeMVlU5AGLpcbdSiFWtHN/
         KpYX3FgU5czlv+7mglT8ZddEB4rla1qeDoC6bfya/0MeBu/kQecsoNfeIL1Yaa1ftWjL
         JhQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e4si2203466ejl.232.2019.04.03.07.17.24
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:17:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 52CBD1596;
	Wed,  3 Apr 2019 07:17:23 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5A7813F68F;
	Wed,  3 Apr 2019 07:17:19 -0700 (PDT)
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
	Andrew Morton <akpm@linux-foundation.org>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	linux-mips@vger.kernel.org
Subject: [PATCH v8 03/20] mips: mm: Add p?d_large() definitions
Date: Wed,  3 Apr 2019 15:16:10 +0100
Message-Id: <20190403141627.11664-4-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190403141627.11664-1-steven.price@arm.com>
References: <20190403141627.11664-1-steven.price@arm.com>
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

For mips, we only support large pages on 64 bit.

For 64 bit if _PAGE_HUGE is defined we can simply look for it. When not
defined we can be confident that there are no large pages in existence
and fall back on the generic implementation (added in a later patch)
which returns 0.

CC: Ralf Baechle <ralf@linux-mips.org>
CC: Paul Burton <paul.burton@mips.com>
CC: James Hogan <jhogan@kernel.org>
CC: linux-mips@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
Acked-by: Paul Burton <paul.burton@mips.com>
---
 arch/mips/include/asm/pgtable-64.h | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/arch/mips/include/asm/pgtable-64.h b/arch/mips/include/asm/pgtable-64.h
index 93a9dce31f25..42162877ac62 100644
--- a/arch/mips/include/asm/pgtable-64.h
+++ b/arch/mips/include/asm/pgtable-64.h
@@ -273,6 +273,10 @@ static inline int pmd_present(pmd_t pmd)
 	return pmd_val(pmd) != (unsigned long) invalid_pte_table;
 }
 
+#ifdef _PAGE_HUGE
+#define pmd_large(pmd)	((pmd_val(pmd) & _PAGE_HUGE) != 0)
+#endif
+
 static inline void pmd_clear(pmd_t *pmdp)
 {
 	pmd_val(*pmdp) = ((unsigned long) invalid_pte_table);
@@ -297,6 +301,10 @@ static inline int pud_present(pud_t pud)
 	return pud_val(pud) != (unsigned long) invalid_pmd_table;
 }
 
+#ifdef _PAGE_HUGE
+#define pud_large(pud)	((pud_val(pud) & _PAGE_HUGE) != 0)
+#endif
+
 static inline void pud_clear(pud_t *pudp)
 {
 	pud_val(*pudp) = ((unsigned long) invalid_pmd_table);
-- 
2.20.1

