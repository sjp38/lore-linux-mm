Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFFDEC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 988B5206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 988B5206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2396A6B0010; Thu, 28 Mar 2019 11:22:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 199B76B0266; Thu, 28 Mar 2019 11:22:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2EA96B0269; Thu, 28 Mar 2019 11:22:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A41FA6B0010
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:22:27 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m32so8318255edd.9
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:22:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PlduaFV1LjO5scXRf9kwcI+ukcg7zXNoRrXpWadVZPc=;
        b=rZAQs5smBMDOZwPvDowL5B0x+BvDc1rxfevuIp2mYerRuzSuHFCna4k7J1YghAfyK2
         usaWClWi8UamvBjkRPjh9/K0Jjtq18U9q3RU5zJnSCWl2jTwGUxlCAG1Mat5ihteeHHt
         K8FUZ4cOSUd4SBlJZ6Nsg/5OC1zt7jGipk6UEDMIGOmf49Tq6YYa8KQyVLsscdRP/CoJ
         P34MbuhCKySOKSo+Ebb/pPr1InEKsFgUyd+W326KVM03esl/ir/KPAonRfE5pvlQxURW
         8Vi4Y1fJph1HiICLfEh1GOtRL/qVvBkXEUS1yaqrodounrXDLH7RGLslKLfFZLeNnBtv
         uLdg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAX+qpiMjmuqQ/0CiBVsQ7OljG/WcS7z2nv6Ewi2i4S4+thWWCJE
	KqFldzVvZzVkmhfOZRqZ4HCQYzdFxgwbTv/Fepep/NQgv+uo6xkK/09KLSXzJbIWaSB9reoI+Km
	XyI5sP5U2w6suz13+8oevr551kFA4WS7CMkZeeKW/Jm7uMa9+FD0TTG9mTt9Aq/qpRA==
X-Received: by 2002:a50:945a:: with SMTP id q26mr29257398eda.280.1553786547205;
        Thu, 28 Mar 2019 08:22:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqww8eH5zZxob5F4BA1Y0YAJqG0xrU1BnABS+vP8yzhCV8zYPfPibyNbxsGqunnwGp7pJVF4
X-Received: by 2002:a50:945a:: with SMTP id q26mr29257348eda.280.1553786546397;
        Thu, 28 Mar 2019 08:22:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786546; cv=none;
        d=google.com; s=arc-20160816;
        b=hq+5cgcwhihg4C1y7G1rA/J73DGDHkBaVBVjlKTgcJtqg0ms0O7R3Vo21XFsCueqyF
         o2FY2bCQP3rRgE8l2DGSE4M51c2fFzdOnl2O6yrOskiG2iZnW6HeHyOtWuN3+r6cJurs
         TNlSgJ36RJd2zTGX2dzWuTMQMVcfe9LEtlYiwQqSmquBgSzjsRmhDvVmYR5Tkkpgrv5A
         +mKenhavBC2VC4nqk8WsEFZWIsdJw6QeWT4X9H4pEau3tHPYhFyADZ7tPNe1v6tRhbX2
         w0hno6dchGdojfDX2jcjgX5q2f/8a3gbmzUgyqx9zurEBe4Pd0IZzSUo+KDpl3UYX0FJ
         sWmQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PlduaFV1LjO5scXRf9kwcI+ukcg7zXNoRrXpWadVZPc=;
        b=JFKR4Dv59sZkoSJEqYLe2zLTTWDEWaON3kB2+9D4kfQj3d0GlPvOsQlLKrEF13oi3I
         zcaZG1m+WyB569KBfMUEuAMGu3wgzByuLo1mWJAkZ3k/dwzzKCCMQKea1p0AVIC9knDT
         88yPcFfNBR5kOF7wRSvqITJkL2jrC/gNzwmoG7Y4lXABONY2svsETlFXQkM5jOswRXJ5
         S3mdr+fhGqVBwy3adP4/U/gENInx7wT0aJ9Aj9qYBkFsARNqlv0sAaq+cL9lgwDrJUDH
         wf+cMKq8ipXsiHSlbYwC+mh6fHdtDQcTnPQkzFxpMMnKPctogtRGN/gmRIuOcq3l1Seu
         MzEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a31si4024802edc.288.2019.03.28.08.22.26
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:22:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7B29A15AB;
	Thu, 28 Mar 2019 08:22:25 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E0AA03F557;
	Thu, 28 Mar 2019 08:22:21 -0700 (PDT)
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
Subject: [PATCH v7 08/20] sparc: mm: Add p?d_large() definitions
Date: Thu, 28 Mar 2019 15:20:52 +0000
Message-Id: <20190328152104.23106-9-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328152104.23106-1-steven.price@arm.com>
References: <20190328152104.23106-1-steven.price@arm.com>
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

