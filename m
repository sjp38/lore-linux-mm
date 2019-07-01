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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5609BC5B578
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:40:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B70F2145D
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 06:40:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Yv7ONmA4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B70F2145D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA4CF8E000E; Mon,  1 Jul 2019 02:40:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A55FF8E0002; Mon,  1 Jul 2019 02:40:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9446C8E000E; Mon,  1 Jul 2019 02:40:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f206.google.com (mail-pg1-f206.google.com [209.85.215.206])
	by kanga.kvack.org (Postfix) with ESMTP id 5E6598E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 02:40:55 -0400 (EDT)
Received: by mail-pg1-f206.google.com with SMTP id f18so478080pgb.10
        for <linux-mm@kvack.org>; Sun, 30 Jun 2019 23:40:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pKOh82x9P2FXMy8MB5i8VNrUUku24zVBdhYruM45v1s=;
        b=M2Nm7sMpSedNWAiuuUql2OU/WPdnb9r6FFkuEN3i8bQ8LFmvp1WnpqvW+mUihORxjc
         LdcCuNFpY5t2atOcrgcwZaHRKMxYQJuQX7n6415Hs5MsoL7lliwgWikLQ6SZtqsLOg3W
         RmRuQOeLMHAZbDAMmgp3EyqGm7Zpez6lK49yls/fxQL5bzXiI0kpvCg/zGnnllVy3Z/w
         9Vw1YhrmuAimcl8UeGYmp29Z6mqjBaS24Wo5XcAsrg14MdbF6mOpFpLCoA8Drr5rIGJE
         WXxrIx3A2eFwYjtXGfoFY/8FAR/UFqbqGVTzG41/YU52AoazEX0nnRlCGr80BaU5kqeY
         rLcw==
X-Gm-Message-State: APjAAAVEzGilXeVLhaPc1MNzyr50TtZKm4TgXAI62yLGCeVEz3QqhawN
	ZYh49GelaZkR9XbrZlvApfQsWfeG/YgPI7rp7B9lL2GJY4Cg0s8HrnmbvJo3Q74Gmu6pkWqY57e
	m/jbk3oFBVXf9brgYu3PF/6a9r0qvIBrfD9kFvxOv53N/tKzEaGh6diDgjgp0ST/LaQ==
X-Received: by 2002:a17:90a:214e:: with SMTP id a72mr30072358pje.0.1561963255082;
        Sun, 30 Jun 2019 23:40:55 -0700 (PDT)
X-Received: by 2002:a17:90a:214e:: with SMTP id a72mr30072299pje.0.1561963254335;
        Sun, 30 Jun 2019 23:40:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561963254; cv=none;
        d=google.com; s=arc-20160816;
        b=x30ACrXpJSQchLfL1nUB4g8P0mf4psOSqoCzcw1PRpxFNLyXGw31B1BxjRR3HXIk3k
         HO7g58ob7UFqsmZP25hp+l6Inn056kEZcqnXg2zP/ca1RY1TTunVKDZe5LtwTIJ7d9Y7
         4lETCrsPH6/6DJ77t4UkNNbeAjWbY64UbypYWQ1hKdgjsROvrgLWakJESW5rZ2u64bXi
         wLfXlgKz3dsHB6mBV6IDV+xpP985Q5EiAf0RfWtzjUTUd5qgKADBS7cKyT7HS4sLsrP3
         pjALwWEgnf5kIDiTdC/xlz1HNnVgyxyyaMmPYlkZM3rykhXcTwbo2JMiDITdCUSqczLs
         nJ6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pKOh82x9P2FXMy8MB5i8VNrUUku24zVBdhYruM45v1s=;
        b=DXyRhMhOP1b4EtP1ALWOMzelkL1E/U6xuIcDD4KuWM2xlpQdLibISCZErxjopBpyNx
         mTvKxtb/Wx23W5tbHq8qqQ5wFM3BdzH2pZSy8Zjau7QgBFt1FqprlkbNScrXN7xRjLA4
         xfSBwMJD69BJ9dMtJn/Xkqk62Gpby0dRlLay1qRvySH+pmOIhdwXYK4857tqoFQ5BO8o
         bo94miFFPQREl99wvcxNYl31But7/hk12o1tW7cnfwUnTetXKe8VlNGUygVVNs7jZYSR
         lAlP5BLJH4ihGSn9aYaU4JE9b+w0o0X2PKM5duzJaABsPFWa/fuBDXWvyMze5cUmjeQz
         st9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Yv7ONmA4;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor11558924pju.0.2019.06.30.23.40.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 30 Jun 2019 23:40:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Yv7ONmA4;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=pKOh82x9P2FXMy8MB5i8VNrUUku24zVBdhYruM45v1s=;
        b=Yv7ONmA4HXrBg5Z7fqXzGOQbgQwuhlK4G2llLAPL9hd//uUhAJCdLP1gC4MiqhQmS1
         PV4CZ1/6GPjUs6tQxXSl9GVwIuOpYlj0kPjLUd5KNaZDhIEToxG1Sa+JbI0gqbWYCnK1
         nlIT45EuZA6x+yj65DFrpUmE+ukUb3brmWRiJ0sEST0egchnVhKD3wf61QoTZodMZhmy
         k4LLY0TR+zKUetQRGdhUpKeJcCk0KpXMV/eM/4aPeAhRmDX3A00d0snpwA3wONNLJH4u
         fRpP7dt48AfYD+D5tlNpsUuYik0uEhm3cuSW3WNaRLnnooak0yNkr7b21OrBtbTM1gge
         bOuA==
X-Google-Smtp-Source: APXvYqyuG0y2ZSl0o0Y8HuBhNNVpR47p1znHr/GTjxdAJLwOfhhJ0EB9nOQKOhPc/GH1Qv7SUWLDfA==
X-Received: by 2002:a17:90a:eb08:: with SMTP id j8mr14461754pjz.72.1561963253877;
        Sun, 30 Jun 2019 23:40:53 -0700 (PDT)
Received: from bobo.ozlabs.ibm.com ([122.99.82.10])
        by smtp.gmail.com with ESMTPSA id x128sm24238285pfd.17.2019.06.30.23.40.49
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 30 Jun 2019 23:40:53 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: "linux-mm @ kvack . org" <linux-mm@kvack.org>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	"linux-arm-kernel @ lists . infradead . org" <linux-arm-kernel@lists.infradead.org>,
	"linuxppc-dev @ lists . ozlabs . org" <linuxppc-dev@lists.ozlabs.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Steven Price <steven.price@arm.com>
Subject: [PATCH v2 1/3] arm64: mm: Add p?d_large() definitions
Date: Mon,  1 Jul 2019 16:40:24 +1000
Message-Id: <20190701064026.970-2-npiggin@gmail.com>
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

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information will be provided by the
p?d_large() functions/macros.

For arm64, we already have p?d_sect() macros which we can reuse for
p?d_large().

pud_sect() is defined as a dummy function when CONFIG_PGTABLE_LEVELS < 3
or CONFIG_ARM64_64K_PAGES is defined. However when the kernel is
configured this way then architecturally it isn't allowed to have a
large page that this level, and any code using these page walking macros
is implicitly relying on the page size/number of levels being the same as
the kernel. So it is safe to reuse this for p?d_large() as it is an
architectural restriction.

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm64/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index fca26759081a..0e973201bc16 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -417,6 +417,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
 				 PMD_TYPE_TABLE)
 #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
 				 PMD_TYPE_SECT)
+#define pmd_large(pmd)		pmd_sect(pmd)
 
 #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
 #define pud_sect(pud)		(0)
@@ -499,6 +500,7 @@ static inline void pte_unmap(pte_t *pte) { }
 #define pud_none(pud)		(!pud_val(pud))
 #define pud_bad(pud)		(!(pud_val(pud) & PUD_TABLE_BIT))
 #define pud_present(pud)	pte_present(pud_pte(pud))
+#define pud_large(pud)		pud_sect(pud)
 #define pud_valid(pud)		pte_valid(pud_pte(pud))
 
 static inline void set_pud(pud_t *pudp, pud_t pud)
-- 
2.20.1

