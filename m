Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CF75C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C67F6214DA
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C67F6214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6663A8E001B; Wed, 31 Jul 2019 11:46:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5EE498E0003; Wed, 31 Jul 2019 11:46:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4DC178E001B; Wed, 31 Jul 2019 11:46:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F22D68E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id r21so42680971edc.6
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nxKy+dHCcQ52WwJbQmiHduBQhK1uZKwGIaDaQ5m0n9k=;
        b=akgPoPCA/jXAB/FaxMIJu7B/0XpFUdU3c+L+GUTHWR9HSz/7M6bogKwE5rvleK+px4
         jKAu2IW3FtFwAQ6gokokEawC+rdaE/cSEwjyPelMD24kRynO+LGMfeSmqoRiAn12JAj3
         XXA6pXZzb4OcCcfo+5uZXJV9zo9MSOPEwcQpjXAcozfoWo8THpKRvJWkodyLWolRANdm
         DdiXHtEgwKBUY0IpLmiUzDQoVpgjXb04COE55YV7wNjsS1M/QnFmuK3wACZ5tEe5QUvV
         5f51kUDOidGbMf4l6WcN2vN8CRY/63q8hbWKnsqiETeZvdLfWSgeJtAUlGh/qm4BhqaU
         dABg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAX94QC/I+hfpC6PGS6ZC/TXQoURF1nH1ZvseRttl4Jflxdyv6lH
	n+5lVyVDR/6NcTvKexBtTUmsq+eCQl/UjJXmJW3axZ0fgSbleIU/rpdwOTPXcwF6J+tvRsYSYmf
	CvlmX7ru5r7gfDnDtHJxJxOJccUF6WWmGgQVNkEqmDkadlUt5+10TWIwAh26KutkHkA==
X-Received: by 2002:a17:906:634f:: with SMTP id a15mr93722948ejm.184.1564588003551;
        Wed, 31 Jul 2019 08:46:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyIsRYRr5SepoWPBzWcbJHfyW8/N1jjZTY9w+4Emb8m/grHPaQ5c6NqE4UdsgzjsGFsfuBw
X-Received: by 2002:a17:906:634f:: with SMTP id a15mr93722887ejm.184.1564588002713;
        Wed, 31 Jul 2019 08:46:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588002; cv=none;
        d=google.com; s=arc-20160816;
        b=KwsjkAHIG3VoLFolQE2HzG50LvQfM9DSV4z/pN8w9bXV3PXOMWgZ+NotktPKtgg+3R
         nER6w+Ztn1FaJmWalRSvvGoLadj2R9yg+rmA3NW9W5HLArgvgZih25t7Igs6CPrq8h1N
         Q0xCmM1kpRAgwI2Thp6Iqn4ntfckRDBrOaJ+jca6pxfo+ZCJNd30KoTiLLbaZB3Brv4G
         pDzsqq5/YAPrN/ercETWoVuMkuFIyxnp5Zfz9s7G88ocJRpovxGg5pi6NGGR+gkSg5ZK
         tPnjbMA5yWadlfYbGA+3iVc0ttC77TTMpVjAcaGd/jGGEdBmt6d7y5BfCm3RlJXNoYzR
         W9dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=nxKy+dHCcQ52WwJbQmiHduBQhK1uZKwGIaDaQ5m0n9k=;
        b=NWz5ouxTRfgT0MKuYdnJmsTrBo6n+ZRBNl5PQhC0SqSZf+nEXXDEg7uU3TdU2kukJj
         DlcEBBWqgWlRqb2zLokrE1uBxLoDstwAkbt03Gu44VtM8B44OO15uhsrUAyyf/QcRYs3
         L6x2lgRxgx+0ydj+vrevFHraFbPH1aInY9Gn0DJs+l3juK4Ii+uFjD059a38Bp2Wl1Ow
         t4GJC8C6zLeSeIzDVg9GJdTruZURhnoqfpV7mNZuHkKgvfYoCEHj9INR0yvVZRj7Petd
         nB1r0T60m6GEsQedgBk76ejMtpmGILkrX3kHI+P2aVnQm/OCZsr0j4zGEzxeCLJhKAqG
         f5VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id h53si21822459edh.114.2019.07.31.08.46.42
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E5E021596;
	Wed, 31 Jul 2019 08:46:41 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5CED33F694;
	Wed, 31 Jul 2019 08:46:39 -0700 (PDT)
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
Subject: [PATCH v10 10/22] x86: mm: Add p?d_leaf() definitions
Date: Wed, 31 Jul 2019 16:45:51 +0100
Message-Id: <20190731154603.41797-11-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190731154603.41797-1-steven.price@arm.com>
References: <20190731154603.41797-1-steven.price@arm.com>
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
p?d_leaf() functions/macros.

For x86 we already have p?d_large() functions, so simply add macros to
provide the generic p?d_leaf() names for the generic code.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/include/asm/pgtable.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 0bc530c4eb13..6986a451619e 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -239,6 +239,7 @@ static inline unsigned long pgd_pfn(pgd_t pgd)
 	return (pgd_val(pgd) & PTE_PFN_MASK) >> PAGE_SHIFT;
 }
 
+#define p4d_leaf	p4d_large
 static inline int p4d_large(p4d_t p4d)
 {
 	/* No 512 GiB pages yet */
@@ -247,6 +248,7 @@ static inline int p4d_large(p4d_t p4d)
 
 #define pte_page(pte)	pfn_to_page(pte_pfn(pte))
 
+#define pmd_leaf	pmd_large
 static inline int pmd_large(pmd_t pte)
 {
 	return pmd_flags(pte) & _PAGE_PSE;
@@ -874,6 +876,7 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
 	return (pmd_t *)pud_page_vaddr(*pud) + pmd_index(address);
 }
 
+#define pud_leaf	pud_large
 static inline int pud_large(pud_t pud)
 {
 	return (pud_val(pud) & (_PAGE_PSE | _PAGE_PRESENT)) ==
@@ -885,6 +888,7 @@ static inline int pud_bad(pud_t pud)
 	return (pud_flags(pud) & ~(_KERNPG_TABLE | _PAGE_USER)) != 0;
 }
 #else
+#define pud_leaf	pud_large
 static inline int pud_large(pud_t pud)
 {
 	return 0;
@@ -1233,6 +1237,7 @@ static inline bool pgdp_maps_userspace(void *__ptr)
 	return (((ptr & ~PAGE_MASK) / sizeof(pgd_t)) < PGD_KERNEL_START);
 }
 
+#define pgd_leaf	pgd_large
 static inline int pgd_large(pgd_t pgd) { return 0; }
 
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
-- 
2.20.1

