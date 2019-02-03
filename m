Return-Path: <SRS0=zbpI=QK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 80003C282DB
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 13:49:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4703C218FF
	for <linux-mm@archiver.kernel.org>; Sun,  3 Feb 2019 13:49:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4703C218FF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=decadent.org.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D9718E0026; Sun,  3 Feb 2019 08:49:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 062448E001C; Sun,  3 Feb 2019 08:49:53 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E44728E0026; Sun,  3 Feb 2019 08:49:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 900AC8E001C
	for <linux-mm@kvack.org>; Sun,  3 Feb 2019 08:49:53 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id e17so3864015wrw.13
        for <linux-mm@kvack.org>; Sun, 03 Feb 2019 05:49:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state
         :content-disposition:content-transfer-encoding:mime-version:from:to
         :cc:date:message-id:subject:in-reply-to;
        bh=yYfxpL36Hi5EHzhjbBaOt9oOvmnQUND+SSi9GnVnnV0=;
        b=f0XVImss0nmgI1AAmdmtTpsagJwZZKM2WP7OYmOp+8r//hIt79SxQjvSTp/RsonV9N
         bjRHvP709H9iuh8n6AUSMNz3CU9SToNmNYMm6jpCaGYsU/G1xTxp5TQsWvczQEUf/TeX
         w7+NkXEJI1VWRndc1U+6T8ZNjvkFlyDJievDnEGpzP813PGCE6w/HZkrkn1KPO6Yzp42
         o4gFqlwDoFyo5gztDsMM/Fl7sichpcz1eOJ87Tc4eEWRTxk5rgt4xdEkuZIiI0qNXgYt
         AjAdsxpRveVlYzinR7msTEQIqLVdgE+DaTCzI6ytQJOlwvewMifT48FJrnKBgorWGPm6
         LjZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
X-Gm-Message-State: AJcUukfbkDBtl2r7fUs8uENjFixb57foQVnXbUjVzrt4yB+lkt2IriEy
	QPFzYjQ9v0w+zNWJwnSHKBsaUbzbD6Uix6pRTMxx+f1HKXXocotMVF/85kaM4y4VPwK5mwx3O11
	XjlgWfC1zM9wA7InV64fXHxrOwGagWk6kosQQeFmvkjN//jBGwZj055x9uo0FEG/gJQ==
X-Received: by 2002:adf:9123:: with SMTP id j32mr47932566wrj.122.1549201793056;
        Sun, 03 Feb 2019 05:49:53 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4Wmw3hFL1i3Bfzp7WGz1246dL/XE6Fxhy+p/nSTv5UG7861znkdTHrIXwncXd2zoHEdxZG
X-Received: by 2002:adf:9123:: with SMTP id j32mr47932528wrj.122.1549201792047;
        Sun, 03 Feb 2019 05:49:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549201792; cv=none;
        d=google.com; s=arc-20160816;
        b=gkEgZ0IbRKI20Ace3sSk+KGy/fQSTWcMVW5d68AtOFlccPk3haFuIs0C4ob3XnT/p2
         t9fa4Sah1sfAqSE4vUiN3qYuJdclLXmsG8osnIRiwtZRN+w1Xbmy9TZGxZ6lSjzJwm63
         vifB1LE6ObqVzSPsHh0ywHDd8frl0oTFWKIzZJP88OHFV+DlHzd3DcXhBGHw5AuOS2sz
         wUhUJnm9OuUDCf0+25bw0N5/be8cc+kmcfwYlX/8zxzr8z4R6H/EkX9l1ymwr98LS44c
         hAvMHnbW6S3DF9I2wT2zxMZllHDqJsHzJV/qsJTsEN0NPeQYz6EMMF2pycwcSIpsB3Ow
         iQAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:subject:message-id:date:cc:to:from:mime-version
         :content-transfer-encoding:content-disposition;
        bh=yYfxpL36Hi5EHzhjbBaOt9oOvmnQUND+SSi9GnVnnV0=;
        b=nD1WEV+WeovTikrNGvGRKm0qNS9CWAQ7Hn1dCiEuRCK7l5fsgGKnrTmtB925HXEn3w
         J17EyAQ/TwM6LTCDU++y297OWq+/YjVn5kXnywYbkAix/dxiTmeVY/CiITWPdx+3ddLf
         U/lJSByWhBEatjN7Uv605zqbakuJ7Qj6tmMngrXTs5O/GeUxAdGQuxaL5ZHASKvXwCIe
         GLtzWOftEw5PwjaYRLEViwjfPO8/WZWoqN25q44TFN9poPndllakKRumlHyWPTu6JrhC
         +UjhdmfIEczusP3TzTX26ivUKIh6WJKFZjn1tfkrnAjVl65TbHyJt2gXtMkWowaOPOzL
         G2hQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
Received: from shadbolt.e.decadent.org.uk (shadbolt.e.decadent.org.uk. [88.96.1.126])
        by mx.google.com with ESMTPS id t20si5236476wmi.14.2019.02.03.05.49.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 03 Feb 2019 05:49:52 -0800 (PST)
Received-SPF: pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) client-ip=88.96.1.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ben@decadent.org.uk designates 88.96.1.126 as permitted sender) smtp.mailfrom=ben@decadent.org.uk
Received: from cable-78.29.236.164.coditel.net ([78.29.236.164] helo=deadeye)
	by shadbolt.decadent.org.uk with esmtps (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.89)
	(envelope-from <ben@decadent.org.uk>)
	id 1gqI9T-0003tg-3f; Sun, 03 Feb 2019 13:49:39 +0000
Received: from ben by deadeye with local (Exim 4.92-RC4)
	(envelope-from <ben@decadent.org.uk>)
	id 1gqI9T-0006n6-B2; Sun, 03 Feb 2019 14:49:39 +0100
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
MIME-Version: 1.0
From: Ben Hutchings <ben@decadent.org.uk>
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
CC: akpm@linux-foundation.org, Denis Kirjanov <kda@linux-powerpc.org>,
 "Konrad Wilk" <konrad.wilk@oracle.com>,
 "H. Peter Anvin" <hpa@zytor.com>,
 "Robert Elliot" <elliott@hpe.com>,
 "Wenkuan Wang" <Wenkuan.Wang@windriver.com>,
 "Thomas Gleixner" <tglx@linutronix.de>,
 "Borislav Petkov" <bp@alien8.de>,
 "Toshi Kani" <toshi.kani@hpe.com>,
 linux-mm@kvack.org,
 "Ingo Molnar" <mingo@redhat.com>,
 "Juergen Gross" <jgross@suse.com>
Date: Sun, 03 Feb 2019 14:45:08 +0100
Message-ID: <lsq.1549201508.606689081@decadent.org.uk>
X-Mailer: LinuxStableQueue (scripts by bwh)
X-Patchwork-Hint: ignore
Subject: [PATCH 3.16 001/305] x86/asm: Add pud/pmd mask interfaces to
 handle large  PAT bit
In-Reply-To: <lsq.1549201507.384106140@decadent.org.uk>
X-SA-Exim-Connect-IP: 78.29.236.164
X-SA-Exim-Mail-From: ben@decadent.org.uk
X-SA-Exim-Scanned: No (on shadbolt.decadent.org.uk); SAEximRunCond expanded to false
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

3.16.63-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: Toshi Kani <toshi.kani@hpe.com>

commit 4be4c1fb9a754b100466ebaec50f825be0b2050b upstream.

The PAT bit gets relocated to bit 12 when PUD and PMD mappings are
used.  This bit 12, however, is not covered by PTE_FLAGS_MASK, which
is used for masking pfn and flags for all levels.

Add pud/pmd mask interfaces to handle pfn and flags properly by using
P?D_PAGE_MASK when PUD/PMD mappings are used, i.e. PSE bit is set.

Suggested-by: Juergen Gross <jgross@suse.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Juergen Gross <jgross@suse.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Konrad Wilk <konrad.wilk@oracle.com>
Cc: Robert Elliot <elliott@hpe.com>
Cc: linux-mm@kvack.org
Link: http://lkml.kernel.org/r/1442514264-12475-4-git-send-email-toshi.kani@hpe.com
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Wenkuan Wang <Wenkuan.Wang@windriver.com>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 arch/x86/include/asm/pgtable_types.h | 36 ++++++++++++++++++++++++++++++++++--
 1 file changed, 34 insertions(+), 2 deletions(-)

--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -257,10 +257,10 @@
 
 #include <linux/types.h>
 
-/* PTE_PFN_MASK extracts the PFN from a (pte|pmd|pud|pgd)val_t */
+/* Extracts the PFN from a (pte|pmd|pud|pgd)val_t of a 4KB page */
 #define PTE_PFN_MASK		((pteval_t)PHYSICAL_PAGE_MASK)
 
-/* PTE_FLAGS_MASK extracts the flags from a (pte|pmd|pud|pgd)val_t */
+/* Extracts the flags from a (pte|pmd|pud|pgd)val_t of a 4KB page */
 #define PTE_FLAGS_MASK		(~PTE_PFN_MASK)
 
 typedef struct pgprot { pgprotval_t pgprot; } pgprot_t;
@@ -329,11 +329,43 @@ static inline pmdval_t native_pmd_val(pm
 }
 #endif
 
+static inline pudval_t pud_pfn_mask(pud_t pud)
+{
+	if (native_pud_val(pud) & _PAGE_PSE)
+		return PUD_PAGE_MASK & PHYSICAL_PAGE_MASK;
+	else
+		return PTE_PFN_MASK;
+}
+
+static inline pudval_t pud_flags_mask(pud_t pud)
+{
+	if (native_pud_val(pud) & _PAGE_PSE)
+		return ~(PUD_PAGE_MASK & (pudval_t)PHYSICAL_PAGE_MASK);
+	else
+		return ~PTE_PFN_MASK;
+}
+
 static inline pudval_t pud_flags(pud_t pud)
 {
 	return native_pud_val(pud) & PTE_FLAGS_MASK;
 }
 
+static inline pmdval_t pmd_pfn_mask(pmd_t pmd)
+{
+	if (native_pmd_val(pmd) & _PAGE_PSE)
+		return PMD_PAGE_MASK & PHYSICAL_PAGE_MASK;
+	else
+		return PTE_PFN_MASK;
+}
+
+static inline pmdval_t pmd_flags_mask(pmd_t pmd)
+{
+	if (native_pmd_val(pmd) & _PAGE_PSE)
+		return ~(PMD_PAGE_MASK & (pmdval_t)PHYSICAL_PAGE_MASK);
+	else
+		return ~PTE_PFN_MASK;
+}
+
 static inline pmdval_t pmd_flags(pmd_t pmd)
 {
 	return native_pmd_val(pmd) & PTE_FLAGS_MASK;

