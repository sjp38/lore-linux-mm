Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B019C5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:41:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 325A12145D
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:41:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ouq5FzdI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 325A12145D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C79CF8E000F; Mon,  1 Jul 2019 02:40:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C29678E0002; Mon,  1 Jul 2019 02:40:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B190A8E000F; Mon,  1 Jul 2019 02:40:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f207.google.com (mail-pl1-f207.google.com [209.85.214.207])
	by kanga.kvack.org (Postfix) with ESMTP id 7F7B48E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:40:59 -0400 (EDT)
Received: by mail-pl1-f207.google.com with SMTP id n1so6774766plk.11
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:40:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6Zlw/hCGICkGVg8omOyX/d2u3HngLNHtlfTr8g+whbg=;
        b=OA8pueYhxVi9BPeoJlt/kPWW/XZoYn0FdcPyuUhIp0hcpbQFKgcmFvuh8IHRdRhXaM
         a0gO/FtoSMWRuYMmCmLfwVZ9pxgvi1uTi6a0W/84K9YuvyYztXVDHmO+DKgC56NW7rBm
         pHvyxufxFO1fsclyyAXw8qVuJ9/xGzMh+9rJDqtNSWIpvEOJC6WDRdECu5pguNFeipTf
         FKFdfzuOUIs7aYcUlTgGX34byRGa/ExQYDj5v72H8CxeqVB4SNdMmDrp57uCGLwUraB2
         H/gyRf008SuHfXa9KASOR0M/1h9v6YsGnWoISTn8jkgKgTtBwXFz0hNA93mCHrXk8Lk1
         O2Jg==
X-Gm-Message-State: APjAAAUjkHOFBFFszurXeEKk640L6MIF20dBJP4DoUbsLPAGHxbX7aiX
	SlQL44s8Mcac17KLM76jvgpsKb41QGS97r5/0fw/TEDSUKXLMZxjygYZt6wyQEpuhcXfl+ucuzg
	4dMMkvhEnIYMS5d4xf/DqQ4reY9CLKJazbfZHpwqfsnT9pbNYz7zI9w4FUaSGvL09mg==
X-Received: by 2002:a63:24c1:: with SMTP id k184mr23641527pgk.120.1561963259121;
        Sun, 30 Jun 2019 23:40:59 -0700 (PDT)
X-Received: by 2002:a63:24c1:: with SMTP id k184mr23641456pgk.120.1561963257966;
        Sun, 30 Jun 2019 23:40:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561963257; cv=none;
        d=google.com; s=arc-20160816;
        b=PNlWD0rZ3UHzJKsq6Yvha1ZaC6wQq9YymGPRl3sQKOQxUUR+Nxb8lxSb76HmW4yqai
         f9ZgjFWIb+ir8XCkeNUP5SZhvORGjCJWJeejrBN7Z43H7xtW+xSw7jGpCmPTcsUfeqEN
         UqGkt/iRevyQBUR5yYeaRjAgztKzQ3Aaho/6oy2n7Td1znlIgqejbLZF0KCjWom/wc6N
         /2zQ3fg7NcgFJ3XJpNVfKrQErGTQpCiqe87/9NYymULa89+KTbJ23qVZ22pf5o2bvQoG
         0O0iklrz1GqUZip9FemTaEjwMCi5jE0Z1oAUz4JhFICKxfL/SQ6y9qIC+Pm90tRe2XcE
         f83Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=6Zlw/hCGICkGVg8omOyX/d2u3HngLNHtlfTr8g+whbg=;
        b=0HGKgxbpum37fer0g0+7nvA6xzTlsAkljWb4ApLcFv3FPB6nQwK3fHECkLjLF7H0wr
         5ZJbWk59B+AjNozZ/1rayhzkrwSc7gAfK4Um4Fl5PEsNQWn7QxVtDshbGuPJSaL0QXyV
         5gKp+Z151LIKWdHNIR80hijLcINMFsHryM2aD4KsPPoHVNHNTV/0yrDIEpemLEpzOkoX
         0jWC51FhdvRm/u/jmlbpOeJqNO3oZECd3QaKhV94EsffU51nHhrSxLESONoInI1m8+kT
         74nnvFo8v7uY2BlOIn0nn2Qv+4t2WN5aXy2utVZrtBAUUEIPlEKRzKCDTsgKWAMLz7fj
         Slcg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ouq5FzdI;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i96sor11376065pje.17.2019.06.30.23.40.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Jun 2019 23:40:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ouq5FzdI;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=6Zlw/hCGICkGVg8omOyX/d2u3HngLNHtlfTr8g+whbg=;
        b=ouq5FzdIf9rNySj7b3zWVPcAwWspCJDbKnSjFCLmfjwBeC3LJPB34aIN0+a7wQ8McC
         p1Txuhs4kMtY+16Cqhhps3AA30X2hrE5mj6QueTPMfgLdP9ZAL77JuJMAafKBj8Wct8b
         QjxaYZ1kTJ5UE+4AUmDCQjs7UUTxxBoXRQu5Wj84zOrGTJ8ez4CMlZFv3/c0+r5SCFqa
         UrMNuge9PYhXovbwW/X9u2mXxujZnpVUsInRSBgusFGBG9eoHqQ+JcLGdPYGoL91mbVG
         Yu1phLwtKP+clAkHJhLFNUWD84oz9qvm0JbedtUx+FFMqCYLfFmH0zttRDXk8AY+NjND
         E4nA==
X-Google-Smtp-Source: APXvYqx98EZ/1NGwoXYug6FXGMmAdVT2/AyL1LfX+2sBRIhK5AVZczoBxviaDZiO/22AP1OmmeXKEg==
X-Received: by 2002:a17:90a:ac11:: with SMTP id o17mr29589490pjq.134.1561963257515;
        Sun, 30 Jun 2019 23:40:57 -0700 (PDT)
Received: from bobo.ozlabs.ibm.com ([122.99.82.10])
        by smtp.gmail.com with ESMTPSA id x128sm24238285pfd.17.2019.06.30.23.40.54
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:40:57 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: "linux-mm @ kvack . org" <linux-mm@kvack.org>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	"linux-arm-kernel @ lists . infradead . org" <linux-arm-kernel@lists.infradead.org>,
	"linuxppc-dev @ lists . ozlabs . org" <linuxppc-dev@lists.ozlabs.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Mark Rutland <mark.rutland@arm.com>
Subject: [PATCH v2 2/3] powerpc/64s: Add p?d_large definitions
Date: Mon,  1 Jul 2019 16:40:25 +1000
Message-Id: <20190701064026.970-3-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190701064026.970-1-npiggin@gmail.com>
References: <20190701064026.970-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The subsequent patch to fix vmalloc_to_page with huge vmap requires
HUGE_VMAP archs to provide p?d_large definitions for the non-pgd page
table levels they support.

Cc: linuxppc-dev@lists.ozlabs.org
Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h | 24 ++++++++++++--------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index ccf00a8b98c6..c19c8396a1bd 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -915,6 +915,11 @@ static inline int pud_present(pud_t pud)
 	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
 }
 
+static inline int pud_large(pud_t pud)
+{
+	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PTE));
+}
+
 extern struct page *pud_page(pud_t pud);
 extern struct page *pmd_page(pmd_t pmd);
 static inline pte_t pud_pte(pud_t pud)
@@ -958,6 +963,11 @@ static inline int pgd_present(pgd_t pgd)
 	return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
 }
 
+static inline int pgd_large(pgd_t pgd)
+{
+	return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PTE));
+}
+
 static inline pte_t pgd_pte(pgd_t pgd)
 {
 	return __pte_raw(pgd_raw(pgd));
@@ -1083,6 +1093,11 @@ static inline pte_t *pmdp_ptep(pmd_t *pmd)
 #define pmd_mk_savedwrite(pmd)	pte_pmd(pte_mk_savedwrite(pmd_pte(pmd)))
 #define pmd_clear_savedwrite(pmd)	pte_pmd(pte_clear_savedwrite(pmd_pte(pmd)))
 
+static inline int pmd_large(pmd_t pmd)
+{
+	return !!(pmd_raw(pmd) & cpu_to_be64(_PAGE_PTE));
+}
+
 #ifdef CONFIG_HAVE_ARCH_SOFT_DIRTY
 #define pmd_soft_dirty(pmd)    pte_soft_dirty(pmd_pte(pmd))
 #define pmd_mksoft_dirty(pmd)  pte_pmd(pte_mksoft_dirty(pmd_pte(pmd)))
@@ -1151,15 +1166,6 @@ pmd_hugepage_update(struct mm_struct *mm, unsigned long addr, pmd_t *pmdp,
 	return hash__pmd_hugepage_update(mm, addr, pmdp, clr, set);
 }
 
-/*
- * returns true for pmd migration entries, THP, devmap, hugetlb
- * But compile time dependent on THP config
- */
-static inline int pmd_large(pmd_t pmd)
-{
-	return !!(pmd_raw(pmd) & cpu_to_be64(_PAGE_PTE));
-}
-
 static inline pmd_t pmd_mknotpresent(pmd_t pmd)
 {
 	return __pmd(pmd_val(pmd) & ~_PAGE_PRESENT);
-- 
2.20.1

