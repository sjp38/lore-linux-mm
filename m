Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A331AC10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D6282171F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D6282171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 23FD66B026B; Wed,  3 Apr 2019 10:17:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 214DA6B026C; Wed,  3 Apr 2019 10:17:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 105486B026D; Wed,  3 Apr 2019 10:17:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B5DDB6B026B
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:17:42 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c41so7596391edb.7
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:17:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EIMxzs3KcJ4jmgX2iikj+tJ0Q4+Nen0h2D0kdVtq1V0=;
        b=fgnA1Pb7dnyzUXRQgHajqu0Y0pwcykM5+fHo5EH1YZtCiqndkYGwkrbSxhkFBUmpUs
         DUJyeFuoeZb9irGuvF8PNqmAGiEGCJqQkPriBFnNra58Y9Kydd0+PuBbDXjZGUsCVjxp
         lPu311d61XkPLmM91MT9mIGRjIUY17LGxq/5m0N4sf44WxuTG3Xmi6Av039O1kbe2+En
         umx/foqRTZlc/iheziCCRGU7Gake/hCm7j91N5c80vRd5D/t7DpgPi3U3/kFSuTyknTl
         MLuDfj8lpRMsaBZu49rrgjfrCeUHgPaGSIUsjleUc4Mzkt8Te2dDZSWIS/3Jm5tbq7+u
         C/Vg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWKfPsQViBgcwBs5jLQqa+qEyQHgjF95rcrw9cMOvId1pf5PgVP
	HsnaRG4fBIafKb8Hgr4VImqR+PrrseXOup2beJjgY04y5AvNb1e2NXD0Oj/h6uG8B4rV8K9C+a1
	vW0WNzBLLnE4cp8ihXPig01JVQXqJSY0447Dlo1v6FBUt6fw72UvyJFrrARQCy0xJfQ==
X-Received: by 2002:a50:92f6:: with SMTP id l51mr53032957eda.15.1554301062266;
        Wed, 03 Apr 2019 07:17:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZuhDng9RjdCCV5e/qY5OJXa7Q/58y65yQNB6MQDejGMo4sIA9yNrliZCY4ijfDX8gmHH7
X-Received: by 2002:a50:92f6:: with SMTP id l51mr53032893eda.15.1554301061148;
        Wed, 03 Apr 2019 07:17:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301061; cv=none;
        d=google.com; s=arc-20160816;
        b=Kiz9h0RCwcDsQ70WJrnLHSPfov/ElQKOUoVKDSt/d5ZwyhXqBGS7dmyiDNzj53RKm7
         si9OUjdnx3YtWqxYTVF16eIkqsVpf00kfgZH8aXkoHQ4SLoZgM1u89o04qhs/eawwCzb
         N3YwpxSirFsW50B1VCDAsR99cjsvxfh/ISQQZ43Y0YgOH+RrRNQM/eGVTNSf8Ox4GjJ5
         4RpifJpc2cbtUrgMt6i6jy0PjGDXOwzq7xd5HkOkoCenERLQp7dA3w9rcHTjakIYDeif
         U0RYmPwy4zNWp56N05R/71OTvIEbPcXxw+YEpY8KOLqmLhjNlkYTu0G4U8w78UiZ3mjh
         TciA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=EIMxzs3KcJ4jmgX2iikj+tJ0Q4+Nen0h2D0kdVtq1V0=;
        b=Q2QtEUHwvhphL0q6TIUsnXeplmnoCuXGk9R39ItQBlriP1H32KFUW+3mM04V3UZ9vM
         saHQjk0PTUVJ6Y87cA1FFlYOZAr97YzHLh49eAP5NCrXWjcUetoPnXHGAQxw6Xuagz7l
         DpIBF2ZUXJfL8XhmT6FZs5gXh1wTLI1YG7/lvPTdc+fThdUoj9pT8mSlpJjny2Gaa3Tt
         9jg9ix7JAmajbtTinHBmJo0UsTdQrBKO1pTWxZSddy6nd/Mggrg5HS4VFphoM/TEWZaq
         s541g180Gl6hkDKiMHD9pkrP5ZDEInKebKGLUa4qJ8tCCCxTP26+ylc20fy72Q1vqk5d
         4yCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b41si6892897eda.179.2019.04.03.07.17.40
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:17:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4F4521682;
	Wed,  3 Apr 2019 07:17:40 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 75C643F68F;
	Wed,  3 Apr 2019 07:17:36 -0700 (PDT)
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
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux-s390@vger.kernel.org
Subject: [PATCH v8 07/20] s390: mm: Add p?d_large() definitions
Date: Wed,  3 Apr 2019 15:16:14 +0100
Message-Id: <20190403141627.11664-8-steven.price@arm.com>
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

For s390, pud_large() and pmd_large() are already implemented as static
inline functions. Add a #define so we don't pick up the generic version
introduced in a later patch.

CC: Martin Schwidefsky <schwidefsky@de.ibm.com>
CC: Heiko Carstens <heiko.carstens@de.ibm.com>
CC: linux-s390@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/s390/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 76dc344edb8c..3ad4c69e1f2d 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -679,6 +679,7 @@ static inline int pud_none(pud_t pud)
 	return pud_val(pud) == _REGION3_ENTRY_EMPTY;
 }
 
+#define pud_large	pud_large
 static inline int pud_large(pud_t pud)
 {
 	if ((pud_val(pud) & _REGION_ENTRY_TYPE_MASK) != _REGION_ENTRY_TYPE_R3)
@@ -696,6 +697,7 @@ static inline unsigned long pud_pfn(pud_t pud)
 	return (pud_val(pud) & origin_mask) >> PAGE_SHIFT;
 }
 
+#define pmd_large	pmd_large
 static inline int pmd_large(pmd_t pmd)
 {
 	return (pmd_val(pmd) & _SEGMENT_ENTRY_LARGE) != 0;
-- 
2.20.1

