Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2E51C00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9358B20842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9358B20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 42B9C8E000C; Wed, 27 Feb 2019 12:07:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3D9208E0001; Wed, 27 Feb 2019 12:07:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A2F08E000C; Wed, 27 Feb 2019 12:07:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C4E3F8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:00 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id x47so7110445eda.8
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=oM9cZS/lHtdk47vkYK9PYvG9U6l+ctb4fui4NkIJKv4=;
        b=HQ9e7O5pgp4xj7po6sgZnFuVQiI3zZnRs4ODrdjfSvpSaWv2DPFJ2CecIy/slEo1bd
         A8qVSS/yZiVJTXDq6T5OTzDLHqxm2+CH4mrMHRPoGG6HwkKiM+nooMVUMKf9BrNStX/G
         ESMxX6nf8td+jV7IJkiW4Ap2wDpQuEJNfovMHHZrOu/2qSXkE9xJgausizxTN3NbAjsg
         MbmEoj4bB/sHUdqtKhGoV0a4M2YlUgOQpsO8X+PxiptC5ByXM4A7zvKpAWN83knOpBVn
         I6FnxcWtFAG6gsUJNZE6x7+NrjTxGpa79dVN8ukNMwU8YYOFqXuQ7ZbQ5GYXFDjgA08r
         1xHQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuZKCbc0LdaFcYdwj+Vz2I8OUnOddlkJn4U/es7yv0j1MNhUOSil
	5OhVUXBtrRinOjMoX499xe4UYVi2hzh1C7a4tniXQhByoQpiGSGnCWL+sNvb8SyLcq9x4SSYbdG
	mvfWZUQL19QB1ijrHvoVW6+tKe/Ana8JEoSBiaZLRCrSCDN8W9J66F3+qOBHU/Ib5JA==
X-Received: by 2002:a17:906:a12:: with SMTP id w18mr2296612ejf.70.1551287220312;
        Wed, 27 Feb 2019 09:07:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib3MDX51F7MbZYGBCg7OIzEZUVb4HPOxpoDtbitD26Xa6w4N2ZoHbqoBuTQQrx3ME8QdTkK
X-Received: by 2002:a17:906:a12:: with SMTP id w18mr2296555ejf.70.1551287219317;
        Wed, 27 Feb 2019 09:06:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287219; cv=none;
        d=google.com; s=arc-20160816;
        b=W821YtIkP32aRlWgvEgisd+jO1jcI8+vHwHXItWTqe18gGxLPpoQxOcuktu5TlrVKn
         1PXevU+PndZRoy8Y+bwdBpyNjVzTLu3dUBHBeR5Ww8xcZ+uaAi/qzAi9yn2Wq409MI9A
         csYQJq3yzZV2xthEXMC6Gnhs8eYSziOfjMCMdHe6c6EIZ4O/wRVgJ3l6/hZH04zZsbvF
         VKMpE6F3ZyuWM0S14N03ZIvT+wh9odBmnSTXItZyG2hKFOq6pnW1DwO8WdBM/01e/LaO
         I1oxjSiZIrgIbvsJqubNJ/M/o0bdBNX5aYCWn27IPvNA9ZMRyvvmszqs/Etuh7wQoU+v
         YpTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=oM9cZS/lHtdk47vkYK9PYvG9U6l+ctb4fui4NkIJKv4=;
        b=aGIVu8fD+DfzBXDdREH0fYyXxICEiqrn6Y+2tEuWUI+Oa3RMN+s2f99XsnKpr33Htb
         qVg4ZLlH3qAuwX2eYHIdlwDsZrM2XqwWFH8hdoaUIEf8kKuajE+Y6PeAP6g1tj10efj1
         +02zw8hzPH7AqcJCxWulTzQDUmKMxwHvTTwbuwIiG1rhStbqgloXHQWCtjIiV+suPjYs
         PeiWj5h1+tczEPPx/1LIvZsTHPu4S4K44Zh39sWvKO9S2DGj7TnPTz+3/k37wJxiEnlh
         ic/wI41mLKzaptl0eRAPi6rzo0ZBhYtxHGOniLBS/Qm2rvha0jC4kuRav52H/Q+3piDZ
         ilPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y57si4755582edd.320.2019.02.27.09.06.59
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:06:59 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6C7F3A78;
	Wed, 27 Feb 2019 09:06:58 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BB5463F738;
	Wed, 27 Feb 2019 09:06:54 -0800 (PST)
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
	Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	linux-ia64@vger.kernel.org
Subject: [PATCH v3 08/34] ia64: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:42 +0000
Message-Id: <20190227170608.27963-9-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
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

For ia64 leaf entries are always at the lowest level, so implement
stubs returning 0.

CC: Tony Luck <tony.luck@intel.com>
CC: Fenghua Yu <fenghua.yu@intel.com>
CC: linux-ia64@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/ia64/include/asm/pgtable.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/ia64/include/asm/pgtable.h b/arch/ia64/include/asm/pgtable.h
index b1e7468eb65a..84dda295391b 100644
--- a/arch/ia64/include/asm/pgtable.h
+++ b/arch/ia64/include/asm/pgtable.h
@@ -271,6 +271,7 @@ extern unsigned long VMALLOC_END;
 #define pmd_none(pmd)			(!pmd_val(pmd))
 #define pmd_bad(pmd)			(!ia64_phys_addr_valid(pmd_val(pmd)))
 #define pmd_present(pmd)		(pmd_val(pmd) != 0UL)
+#define pmd_large(pmd)			(0)
 #define pmd_clear(pmdp)			(pmd_val(*(pmdp)) = 0UL)
 #define pmd_page_vaddr(pmd)		((unsigned long) __va(pmd_val(pmd) & _PFN_MASK))
 #define pmd_page(pmd)			virt_to_page((pmd_val(pmd) + PAGE_OFFSET))
@@ -278,6 +279,7 @@ extern unsigned long VMALLOC_END;
 #define pud_none(pud)			(!pud_val(pud))
 #define pud_bad(pud)			(!ia64_phys_addr_valid(pud_val(pud)))
 #define pud_present(pud)		(pud_val(pud) != 0UL)
+#define pud_large(pud)			(0)
 #define pud_clear(pudp)			(pud_val(*(pudp)) = 0UL)
 #define pud_page_vaddr(pud)		((unsigned long) __va(pud_val(pud) & _PFN_MASK))
 #define pud_page(pud)			virt_to_page((pud_val(pud) + PAGE_OFFSET))
@@ -286,6 +288,7 @@ extern unsigned long VMALLOC_END;
 #define pgd_none(pgd)			(!pgd_val(pgd))
 #define pgd_bad(pgd)			(!ia64_phys_addr_valid(pgd_val(pgd)))
 #define pgd_present(pgd)		(pgd_val(pgd) != 0UL)
+#define pgd_large(pgd)			(0)
 #define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
 #define pgd_page_vaddr(pgd)		((unsigned long) __va(pgd_val(pgd) & _PFN_MASK))
 #define pgd_page(pgd)			virt_to_page((pgd_val(pgd) + PAGE_OFFSET))
-- 
2.20.1

