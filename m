Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12964C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:26:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6FC720863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:26:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6FC720863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 791B96B026A; Tue, 26 Mar 2019 12:26:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 740F66B026B; Tue, 26 Mar 2019 12:26:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 630956B026C; Tue, 26 Mar 2019 12:26:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 149776B026A
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:26:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m31so5516358edm.4
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:26:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MqMqukGILHQS5vjuNGdSQFWysz8AgSB4keSNgmoOKiU=;
        b=TPp+T1UP6Ccus0+EVMwZu3IUN+U2tSHbLyUOto77es7U7uVDjJftKvKgb/de1IYGAX
         5gOsYJiJp6B7Qmp1rry1O0x4MzkHxJoqMs89DnqO+DYLJaXmkz8xrr8p8KH8P0l9AX1b
         vQY2IBm+5tE6I7f4cNakfnSIjZpd+jXvoHyYSibV11UETzgF2xarI7RI9qaHQ3aK7Nz6
         wGYBnOSTybPW3pD2YvSHmcUkMfwT/OXkP7LaZXrv+8hOQtHoWB4baCB5Aevc/CNWfaRq
         vaAn4n42Lp2cywcJoYr/bLmQC3uaZfk9XTi3/EOEf+uc7T+GmnsH9ZyiweORmN0OuFZB
         Ernw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXMRAN3mStsFbxOZKRwNp73BMQLPuXWraD1ig8TT+ZuwWIfVspg
	HWpbemS5AM0hp6Jc01+BZGP8zDJzN6stBcuTzLdBcYnlK/lCQfMTnBMB/C8dvnYlcToYXJRThiL
	vephyhSDTuiPOtOvNhkXH8ekHpliEom2UZxx6LSP8++WidTPQA7WS+PJ8vhan8BGa+w==
X-Received: by 2002:aa7:dcca:: with SMTP id w10mr3758017edu.73.1553617608604;
        Tue, 26 Mar 2019 09:26:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfQp5E7gzU410rPovwdpFzSLRTHGhu8lZy32pu6Us22FyRMJA12PWf6doT2bbc0aOMmXqH
X-Received: by 2002:aa7:dcca:: with SMTP id w10mr3757973edu.73.1553617607755;
        Tue, 26 Mar 2019 09:26:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617607; cv=none;
        d=google.com; s=arc-20160816;
        b=l9Pj28l32saqTr8Sbaf4zVqlktxtfwLFUaSKgrMxZQKnmBUoMUH9q76DBxy/aFrx0R
         w7sz7EYHXtzZu6Wp/ft/uslZBtcz+ytUuiF/lIO/yPM5UDwtOJKV0sjdvtb7+2WnE7rf
         bqZgJ1hcVEAnhN6S6qKT8U5b7J7102E2TNAS7te/YR6e7fkSoLnRluc8EFn26HdsVXAM
         CzWzuGJh1TbdSZCmuAnj8VyA7D1kxHPBM+GhIH3KyBaWVZyNUVS86ylwnBC6XTc4khMF
         RiM6VyDtuhcjAcAv64/9RvsngHiNPvHItqr5aJyZVInezMQDCfXw7dZnl7Wgq6BA4Pb/
         BMxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=MqMqukGILHQS5vjuNGdSQFWysz8AgSB4keSNgmoOKiU=;
        b=03GCP112GSVVMkdBEb8nG3b63E7KciHk21NIU+QrpU1Cbi3xLZEFtSXzvWU+zcOocP
         chBthy4LV2Y2+taRWfxxkGAeBSpiG4ITH7rSqdFt/wL6tUqVMSJmckTInycPjOnvdYeK
         TbEV/bgNBPcDVp4K//PST0z3+GbAh59J4U+N6jYUHjuPcf5erj1HEuX3FYCAOMXk4MLw
         rbMlO/BF8sB5ZMK/dDuD6lqIps7JvlwlhPAnRPhbS9UMGPkateie88qKy0aaOFrPVeNB
         DShW+BtMkZFmTQ+loQqXPdzlKfAtLAdP7+TOQJJCtPLmCHI3mChjFK6MgPXOJZphQah4
         O/Ng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d27si149961edb.436.2019.03.26.09.26.47
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:26:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C66841684;
	Tue, 26 Mar 2019 09:26:46 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id F09503F614;
	Tue, 26 Mar 2019 09:26:42 -0700 (PDT)
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
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	linux-mips@vger.kernel.org
Subject: [PATCH v6 03/19] mips: mm: Add p?d_large() definitions
Date: Tue, 26 Mar 2019 16:26:08 +0000
Message-Id: <20190326162624.20736-4-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190326162624.20736-1-steven.price@arm.com>
References: <20190326162624.20736-1-steven.price@arm.com>
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

