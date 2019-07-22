Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E3D4C76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 509CC21E70
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 509CC21E70
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21ADA8E000C; Mon, 22 Jul 2019 11:42:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A6258E0001; Mon, 22 Jul 2019 11:42:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EECCD8E000C; Mon, 22 Jul 2019 11:42:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 921328E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:42:55 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19so26545958edv.16
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:42:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=o6ZQFuOhWTxaUQNBYLtlSVNvlI+gAHzIZURutjw1lXA=;
        b=QECUXUVoo9laINN2Ime/IsEhO8jOMouua34dQoMs1A63PhpDjESxw/5Aja5Jfhska7
         Kv5ytBla1Gyzox4KKa06V9jfng8T0iztqLK+79+srhjEIYuhp7Ax/e9vvXRvJn7DE4Tk
         SzES5kJYNWkcaYbW2e9ZQGGflzitakyWWKNbGrtx/Q8GQAnGYWUwaYMgDZwe9aH8v2ZD
         nMmq399y3l2HfINHFWIqhcKMuZFWF0TsA3RvTYSwtZOvjjagBLV4w+0nBaZ9AX9EHQJ9
         6Y6mZ4SCIr7YjdnKS2nW29zjoqKJmg60xQaTMWk4BtgiV8Ded1Tx2ty/+vu8Zj8Ju9XE
         tj8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWhA9YLfEIdx64hBvmIoWW9NZA7HSNqYEAMp7sbmyfQDipZV1DI
	d0RJF8snbi7ihP5W/7TmEDljk3usom7WUqfc30V6NJ+0iKvV0lt+8PsNpuTzWgV4R+30oKPie6W
	IK7AbbKT4S8YNbQW3NfML+BjxMZHOX8AsioX0AuhzoTVqZQxrDnfZPvbcAbP37LcHJg==
X-Received: by 2002:a17:906:6c97:: with SMTP id s23mr54392727ejr.136.1563810175176;
        Mon, 22 Jul 2019 08:42:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNgM0xt7u0YwrnLkEwyMtpBBgBSxJj0s9HxQLuucoVLxUMY00fT0D5FPrpWVk1sK6nFWL1
X-Received: by 2002:a17:906:6c97:: with SMTP id s23mr54392673ejr.136.1563810174371;
        Mon, 22 Jul 2019 08:42:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810174; cv=none;
        d=google.com; s=arc-20160816;
        b=g3sKpdKnLG8fU0yxhNhtpLkKQMBtvP3AAuXY0KpEzRdq/u3KvXwnBh+4yITas0sSc4
         L0sqk/WlHQyfQS6NRnd2aOk3k6c+7tLtpySNEHEtBdioXgF1U4+yzhC/+5b0wSos7UdI
         iTdw7c8DVC7khZPuD8XjBgDV7NtvyhFGyEAqEW9VGRgdsbr4lHd+pKdeMGt0X+9xHYlW
         AZsQS+ZEkUxGHV8aQ1v2QU0lS5hdxxWMDlPUD7SIQSuExwGN7wdrDw2Nl1wwGiio9MLo
         Df74hCB9cPXAq1hKZXBC+en0wzz2JsT17BoDbdFuyjDDpEQfYmPCIqnJ8yRreerr7pp7
         CCtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=o6ZQFuOhWTxaUQNBYLtlSVNvlI+gAHzIZURutjw1lXA=;
        b=kLPzmqYeh0XJ3GTPSXDLjgMivKG0a9byZU8QD54Q4lzcyeQpP/tf+8MVmc0Qx5vRJi
         uu66tQFnOlNs1Ly4s6PpeQeMrhXFXRAwAre3IURoPhwx6rWvauGElw+hUroRy1Ml2MLo
         DKnVhwHgLZ8lUBb0vSIgqpSAAIocLt5BdMZ4uWeQe6iOb1SK2dUdZZyBkZKt8GqnQAqW
         kGl9EFxALjbkOV31+XK8c6JwoRFTA0I8Iem2yYGsGay3lQyUzpVHyEmGA4yJsMIwmmh9
         YTBsXdzNhvu9MWoCgZ6b0mBgyEa5aXakSqoX8fyWSO+YZYi17YWkJpsx22Mfa95KpzOa
         TfQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id k27si4060350eji.268.2019.07.22.08.42.54
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:42:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 98F461509;
	Mon, 22 Jul 2019 08:42:53 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0FAD03F694;
	Mon, 22 Jul 2019 08:42:50 -0700 (PDT)
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
	Will Deacon <will@kernel.org>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v9 10/21] mm: Add generic p?d_leaf() macros
Date: Mon, 22 Jul 2019 16:41:59 +0100
Message-Id: <20190722154210.42799-11-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722154210.42799-1-steven.price@arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
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

For architectures that don't provide all p?d_leaf() macros, provide
generic do nothing default that are suitable where there cannot be leaf
pages that that level.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 include/asm-generic/pgtable.h | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 75d9d68a6de7..46275896ca66 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -1188,4 +1188,23 @@ static inline bool arch_has_pfn_modify_check(void)
 #define mm_pmd_folded(mm)	__is_defined(__PAGETABLE_PMD_FOLDED)
 #endif
 
+/*
+ * p?d_leaf() - true if this entry is a final mapping to a physical address.
+ * This differs from p?d_huge() by the fact that they are always available (if
+ * the architecture supports large pages at the appropriate level) even
+ * if CONFIG_HUGETLB_PAGE is not defined.
+ */
+#ifndef pgd_leaf
+#define pgd_leaf(x)	0
+#endif
+#ifndef p4d_leaf
+#define p4d_leaf(x)	0
+#endif
+#ifndef pud_leaf
+#define pud_leaf(x)	0
+#endif
+#ifndef pmd_leaf
+#define pmd_leaf(x)	0
+#endif
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
-- 
2.20.1

