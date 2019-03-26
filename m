Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08291C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C23EF206DF
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C23EF206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6F5546B0274; Tue, 26 Mar 2019 12:27:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6A60D6B0275; Tue, 26 Mar 2019 12:27:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5459F6B0276; Tue, 26 Mar 2019 12:27:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 074366B0274
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:27:12 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f11so2270863edq.18
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:27:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=U1aR140X7RnjOrD7ClczvI1VvyAi5tuJM37h24SqYlk=;
        b=VpBYNp8KXzLrBJQvg0aGEZxgnly3bxJKLxbuBqXsXGUfmnCNWLEWVcCB46jFKIJ5Fo
         YHJwB0kHnqrj+CF159zF+tpj5iqUonNKwsCUTtLeAkOKWfuTwn0kcfAPiYVhP46LlVbS
         AXsSYlYAUPnhrcJQHyBKkrFZUdu4SYk2PQqrDhB7kPIaGv1IdzrEMuTiLx7+DVruSJZI
         c9kBw7lmtEASrNvFlFZekjwLtJlHC16pbXTDxhKOAUexSsFfQU5qK2IfK00ekS38THSd
         OMT0fhEEWNFcfHj/H9Cdlmcyl1TVHETP4wgRDRshpbhoI+v7ankIkD+o9gB6G07wklAT
         DkJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUgNm3jSwVT1rPn3kqbGfKsGMZAqOQjlzqvxZN3ccJcC/SeuVgB
	V0FrlPC7JpVEHP2FA3sXIV98ZutqczIS5Swn/yF9n8eOgjazG0Nb8LkvbxNaJCX3rKA2a3/8/LG
	aUza00BoQ2Vc0ggbimlAKPWD4kdndKEQM3RxtcP2LI57FYFvRyeuwGVWEzm4DAZ7ltw==
X-Received: by 2002:a17:906:c14f:: with SMTP id bp15mr11202916ejb.211.1553617631551;
        Tue, 26 Mar 2019 09:27:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwd4qbe1XwvYcR/1Fz89d6F1fQiVGzSWtMZyiJQh/APAKuR7FagroQpwTIvqPdE6Dgymsuz
X-Received: by 2002:a17:906:c14f:: with SMTP id bp15mr11202866ejb.211.1553617630633;
        Tue, 26 Mar 2019 09:27:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617630; cv=none;
        d=google.com; s=arc-20160816;
        b=o1nYt/bjYNymrazSg6UgjtM3BRIQHRSIYI++QgnTZLE513f1ywB7vaGd3Mw40pT6V/
         f1w2UloYVfHQY+zRfHlN2G1BwN8RSv623iT8L5OtyMEarzkNQ3JnlfhVnIlVuy6WaUcO
         zLvbqVULQysWqHajlNC6y1E9UX99l1quBFmWKPFNDanKfwkJbzhcajTr1Sy9iVcngWhx
         JOQ3WhoxlRCgv9n6sk3tn3PX74oszhTEtj9DZIJtEvWGzfxmO+xIsDCAwWnIoyvS49WM
         g3UlTJ2RX/bhu82mWjdPtBJrYcI9eyaWNDWElubi3cbFupmMLU6YwWYRqfEfpWCfCrwG
         2xzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=U1aR140X7RnjOrD7ClczvI1VvyAi5tuJM37h24SqYlk=;
        b=IdtKzsG1jxy/fNPy/SFd+C2bDvi1Cy7w1LljtES9bTLJmTNQj4ZzFE8LsU/Z6tJr2k
         9qQ1VyOREuw3U7+xkRYQY38ptVBWv2XHGiiMfxtZVEzdiK69tEnOg92qkbWYOEpd58RU
         VhVTG9AFP1g7yflXVPJ6JvPUXRfP59QBxtVSz1V437umclKuchrBTMR+uOMKT4IQ9iCZ
         KyMfjhGzPvYsj7c4iJmvaKdcOGPlSu8HecGqBESy6Kk2zKpcrJpCgwiAYV5evnLqdXC7
         klMDk251O620GDoDrtuSrtlUQInMtpL7eMrdrivnL5dC0if0Wt8cV8wkydwfv09GeZK/
         AJgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v13si1842484edc.285.2019.03.26.09.27.10
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:27:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B901615AB;
	Tue, 26 Mar 2019 09:27:09 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7DA913F614;
	Tue, 26 Mar 2019 09:27:06 -0700 (PDT)
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
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: [PATCH v6 09/19] mm: Add generic p?d_large() macros
Date: Tue, 26 Mar 2019 16:26:14 +0000
Message-Id: <20190326162624.20736-10-steven.price@arm.com>
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

Exposing the pud/pgd levels of the page tables to walk_page_range() means
we may come across the exotic large mappings that come with large areas
of contiguous memory (such as the kernel's linear map).

For architectures that don't provide p?d_large() macros, provide generic
does nothing defaults.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 include/asm-generic/pgtable.h | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index fa782fba51ee..9c5d0f73db67 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1186,4 +1186,23 @@ static inline bool arch_has_pfn_modify_check(void)
 #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
 #endif
 
+/*
+ * p?d_large() - true if this entry is a final mapping to a physical address.
+ * This differs from p?d_huge() by the fact that they are always available (if
+ * the architecture supports large pages at the appropriate level) even
+ * if CONFIG_HUGETLB_PAGE is not defined.
+ */
+#ifndef pgd_large
+#define pgd_large(x)	0
+#endif
+#ifndef p4d_large
+#define p4d_large(x)	0
+#endif
+#ifndef pud_large
+#define pud_large(x)	0
+#endif
+#ifndef pmd_large
+#define pmd_large(x)	0
+#endif
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
-- 
2.20.1

