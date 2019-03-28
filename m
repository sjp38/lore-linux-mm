Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B45DAC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F5B2206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F5B2206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 20F2B6B0008; Thu, 28 Mar 2019 11:22:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 197D16B000A; Thu, 28 Mar 2019 11:22:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03E056B000C; Thu, 28 Mar 2019 11:22:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id A4EB96B0008
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:22:07 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id s27so8225093eda.16
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:22:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=MqMqukGILHQS5vjuNGdSQFWysz8AgSB4keSNgmoOKiU=;
        b=ioyim2sJiEoc7KHgC24UfYPXQCcZA5sMt/om4ESj2LCri+zZ43+6bcASFxFtvuYA2Y
         wwAM4ebl2wJ5i7evrRLN6/ojdwxr1ENIvF2N9evMd9fYmgoS/8tOGK4zGVjescH9djUV
         A8msuugLbfzun4V/yw4N9BQv7tg1YVmxPEDyiafi/yCgafUHM+2a3+M7upVJfDX9bTQO
         BJPY80zlTsVLBs0K5PszjVeHBcW26cs0WCJbswnXT8mhBrve7sYYYsKaHcI6Naoe+xUc
         aJQczI6OU8Xt0J4tRWo+lH9cpAU7wChOLMv9wyMu+a5PqnIHhyh5fSc7UOj4aA2XZfHB
         Eljw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVTM/vg1NxG7n/A/iyaOjd2aEh6jPBdnfQKngu9GKRhxX7LwtTv
	6j+XMnDP87BfdKArpM/DJbCu+GmZ/ruV3IJfMlA95VVFPzcy8KfYYDE5Z4+KS3V3IxHJeRupZzA
	YgvL7n67uuixKQW6ap3lILzFyC+/4zTHcVDWmFXwkxxrzChbHJjCDKW+qPbLw3oGkwA==
X-Received: by 2002:a50:ad8e:: with SMTP id a14mr29415121edd.221.1553786527194;
        Thu, 28 Mar 2019 08:22:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwIslgshqYdGIbn/5PaX46T+NbPeXzpfwfHcJUGK+m+NL3Wv4Fw/sGTqwwJLIhn5KI1p7zS
X-Received: by 2002:a50:ad8e:: with SMTP id a14mr29415050edd.221.1553786526045;
        Thu, 28 Mar 2019 08:22:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786526; cv=none;
        d=google.com; s=arc-20160816;
        b=dofK8DXDSsaFZLT+//h9FcHIJWaXMWGxYm08wr0ogQ60bXej+gEcbbTAmuymXGqe11
         fosxIJlKHPbg0GcEP3MCbyaS7RpCO9BGBUYzE5G6q1DpUsq7mK1CPEyzgVtzhiTx1rwL
         moF4+IeJcj/iBZhxGVB/X8qm14/0IXbP+g1w/Ixrb9/RRkKQc4RaZuBCKjdW55r0LbNR
         nLRRfZaVHL3im+QUuTRTIAV513vEH4olEGp1My3WUDX5Bx4z24+SPnGzfhUOvPPXPZcr
         IcJ8xVzIj3CEd3tlMEbZhi+X1i6xEzxXBknZQoUJ+k4W8qLbO+L70GrVoruw0HV+yMoL
         f19w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=MqMqukGILHQS5vjuNGdSQFWysz8AgSB4keSNgmoOKiU=;
        b=XSqcfnrWNGZDT1Y1ml9+qYwoHBLjVE5rPqA2biqOr2YSL749LPsda+B2ISrfNplC8q
         KoSFCekH9ovpv4B+xAZBz0Ci+C20EOunDMEDA0iXJ1Xlrn//G6hW5ecnR3E5dvFbinUp
         uOTSOLwGZSQYqgE/nJCqVo1aWJvUNy5EJhHNT00BFscnTfuCiXDA5IOIEbbtyRpPAMhp
         VHqK1oCpEHHmU2eaPvDEikMSg8XudaaeJyJEUGuyD8q5m8h7BINA7X46YxoOZpqKHktq
         h548QTd7gOghIwBQP2wOzNk8qB4yEOgDyy+xtXCh7DRz+2L9q0mB50CzebWL8i+D2TS/
         eh9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u23si3786443eds.112.2019.03.28.08.22.05
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:22:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0EBB81684;
	Thu, 28 Mar 2019 08:22:05 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2C39E3F557;
	Thu, 28 Mar 2019 08:22:01 -0700 (PDT)
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
Subject: [PATCH v7 03/20] mips: mm: Add p?d_large() definitions
Date: Thu, 28 Mar 2019 15:20:47 +0000
Message-Id: <20190328152104.23106-4-steven.price@arm.com>
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

