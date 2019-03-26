Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E44FC10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1B6C206DF
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1B6C206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 918626B0272; Tue, 26 Mar 2019 12:27:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F0656B0273; Tue, 26 Mar 2019 12:27:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 793CE6B0274; Tue, 26 Mar 2019 12:27:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 27A586B0272
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:27:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id e55so5483925edd.6
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:27:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PlduaFV1LjO5scXRf9kwcI+ukcg7zXNoRrXpWadVZPc=;
        b=Kea7u3VwZ8toY3ZBqByzyJh7ybbVLQKgII5Ck7bCYdT6UdcyN524J9HXR9HGFZVXHV
         66OjpmZ44UpSrUloCAmQdLxRiMmR1J91xu2nVHpDOPr8zowSuUuA4/dgvRQa8Poe8nln
         vE9hZMNUyrqxsWtvZfqRO7p5Eb6ikeHDZllg3Sdz2oqvbzYvtyQxAMsw8bg6fezIry7I
         BrzIvmvcFL+1dJWZP+44VUqna1IDqRsp/ySy0bH6oICqkdu8pSfJqFSY2pTra5k7J1dV
         3tY06kJ2ZOC+LYcSwFu3Q+xQIAjMqFHyJN6FQbS1kq2sZuyEO0ueaSDakW6eV1+EFmyV
         rB8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXh8csnkTTnzZJrybZyy0ph/W/2zyUkQSG62ynK6xSkmTaGsx3Q
	xPRw8Dt2DDq/X01t5G18qysMLNCuSBcVRRxxZrsVTHEjUnw4gNPwYVFtaqZ0s0UZ2jGU2IUDfZI
	r8JFDGxUQAxxekQ6BJxbnJE3cfEgF9vPb71e6Ey5iG0CW8UltwY57MdsCzpHvt/qeTQ==
X-Received: by 2002:aa7:c6c6:: with SMTP id b6mr12263480eds.69.1553617624661;
        Tue, 26 Mar 2019 09:27:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyX0a7SQ79B/4HCWA+gAQRutVxEfpDc48GOI3XcxnR/eQMF9bRaymgb15ezu9Sb2QaeQXW
X-Received: by 2002:aa7:c6c6:: with SMTP id b6mr12263450eds.69.1553617623780;
        Tue, 26 Mar 2019 09:27:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617623; cv=none;
        d=google.com; s=arc-20160816;
        b=W4Z83oiaJW7KIAWMoE4ReM0T1m4iCw+gHYsxkB5lbjy1YYs93UnOcBIxYp6tj48M3+
         /m2JQa95Y7X7gbnikByP/QpYBz13o5w2kj4GqMiU1o65p4u6E7chULvTZptMxsz1NC+b
         2inEi813PKj8AtYeQ25A+Sq2guuXxODvKqXT4OHdcfmJ3wZSfSvEKHl7NR1wGwtrinIR
         6KW12KMS5SeRyeB8sKiHeUiBfs9xMAww1sIs351s8llZ1k2IJY43ay15z6jsUon3EcL5
         X9pHva6Wct7hgspb/JSSEMii5D+zyOLDtjWh7v2XaASeo5/uBK21PJX72L+rsZ4J51Mf
         m6nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PlduaFV1LjO5scXRf9kwcI+ukcg7zXNoRrXpWadVZPc=;
        b=fnX1JAs0IbqxxSjRbH0CeQdysBXfRzCd31JCvA0+8zj4Iw1v5cdx4mjWAIoQoNJ41K
         g1SqEHuZBTTi6OZDSmnnuhPyIISO9n2oNyDuxDmifB8sq/0WjAGJJRZvAQDRhQ4kMtdr
         zjkrI9Hk5B2teIBqenTaWibdmW1hkKLmvViAytHB2/wltkdhTRDjztjo4LN9uC820Uxl
         VLHrSqRSBuFguOMmfByNpbPK/Gi8nLr1HyjZdbsh0/Ug7EOR/uuH0kexFLE8nBoKYATL
         j1UblHEv/APRLL2l91Rg6f5+Q6Nd45DkZKiyujISmifgwM/OZehi633bD4SvMmR97wJ7
         iCFg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y7si2569353ejc.246.2019.03.26.09.27.03
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:27:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B41F4174E;
	Tue, 26 Mar 2019 09:27:02 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 319873F614;
	Tue, 26 Mar 2019 09:26:59 -0700 (PDT)
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
Subject: [PATCH v6 07/19] sparc: mm: Add p?d_large() definitions
Date: Tue, 26 Mar 2019 16:26:12 +0000
Message-Id: <20190326162624.20736-8-steven.price@arm.com>
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

