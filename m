Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 679E2C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 280A22084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 280A22084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D5FC66B026C; Wed,  3 Apr 2019 10:17:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D37CF6B026D; Wed,  3 Apr 2019 10:17:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C29486B026F; Wed,  3 Apr 2019 10:17:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7727B6B026C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:17:46 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w3so1095859edt.2
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:17:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=PlduaFV1LjO5scXRf9kwcI+ukcg7zXNoRrXpWadVZPc=;
        b=WxPh95VNghjy+vXGPiLpsq+DwrhRnv0b5GJp+yxxYUapsk4GSurhKPDRK2/fWwnksV
         cFPPbvC5MH4yjsjZW+Tz6BTjv0N6igGiC90kTulJch/PL+BbANnmcFKZ75o+C+eX5/Lh
         CR5Ry7n1oyTZMlsRxV3bEpfcQQl9bE70VZ8ucJRvPsSBvTfwSOE3Pi/e0B84ZmReks5u
         lB6alYYhsgHIJP7GZAqmFvt0oDV8SUlEOT0NjgxHOPHM9m16hCnKib/V22O3lm/+6Gjo
         IyoC2oSd8m0WRlnpO7uPaNtqbGr0p6J61HoYjLTnZyjaWuKo/xi55KA59a9yczEVlGM2
         76gQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVzhKgr36d/DB6ZZmGN+xBKp4gMcDWXAoKTGCmAfwNALbX2m5Gl
	E/YpyaE/7Xdi+Zt7yHfHYhU82Au/Qb5/rAJewAiI127DExeRnR9o6azP/sMiqkeC36NF0mfFMdU
	nWDepA1i0K3WUngGUT5vnegNyIVEEDwC7n7cRIn3S2V5epzlCpbFvbDQVUWoUkIILow==
X-Received: by 2002:a17:906:4d81:: with SMTP id s1mr35694855eju.231.1554301066010;
        Wed, 03 Apr 2019 07:17:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweXZDzyfuvMCyUQZLn/z95mtzGbxe5hhWG98NOtkkndHe1RL4g9AnK2iwG4+X5tp+WTeBx
X-Received: by 2002:a17:906:4d81:: with SMTP id s1mr35694817eju.231.1554301065150;
        Wed, 03 Apr 2019 07:17:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301065; cv=none;
        d=google.com; s=arc-20160816;
        b=lAlXOFG1Fjz+jstjibzKjeDhiEtfXK9MqqkhjHlsAnCXncIggSoTx1nbFgKB07wigE
         KbsLdSsI9liSvmbr2V7uCzZdmHrJTds7I+VxrTXs/c5A2IFiSH8t3XpnjXjjnlpd+H8t
         CmlYnDnxbVNZrVaepq6PYCnEk7Xb7T6BS/iwDIyKHTwG9SicoZiWuElWscFyFNQrm/iw
         MxLerolt6RMYcEJHAlYCFYRx7AcSiGflD2gH7KoguCukPfeL6WB5/O6l6Uctcy217xki
         XvJco4VoTbKoZ2Lrf0k5OY7sP++GcyuZfsPaS65coQXgjAusXdv3BhgWYpLB3Q50eJ4v
         LChA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=PlduaFV1LjO5scXRf9kwcI+ukcg7zXNoRrXpWadVZPc=;
        b=bhpaRr6rwP/9s/2RFJX7NkKNtrjoBywTU4rgE2kDk7vyIbaar0vu21RCFIkepFsFs0
         H9PgFevUZ5RlysXz0HZmIq08KZBY1Hi8ILyYrSqDn2CwwKonD5183lRQ3ukVZ9lg1zvg
         vz8in6Es2aqtGvS0OC3+0VoN2nEX+yiuCsX2R9Zqo9jQob5hQ16I2VWUC9wRPIimkdXu
         Zmt9dQEXAZzfApKCJ0hED5uW7BL4P4Wx90KQZ45KXDX0ufaQ3hIddurljpFNbtJJkKyP
         8jqEInZRZljCxd9Y+ASKDu+nFysr9oimAtPOokIJN9Vk9/ESLM7SElNorN9SeEThJ7l2
         v4DQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c22si2694161ejd.12.2019.04.03.07.17.44
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:17:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 41BC4A78;
	Wed,  3 Apr 2019 07:17:44 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8F2073F68F;
	Wed,  3 Apr 2019 07:17:40 -0700 (PDT)
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
	"David S. Miller" <davem@davemloft.net>,
	sparclinux@vger.kernel.org
Subject: [PATCH v8 08/20] sparc: mm: Add p?d_large() definitions
Date: Wed,  3 Apr 2019 15:16:15 +0100
Message-Id: <20190403141627.11664-9-steven.price@arm.com>
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

