Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01DD3C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C03F6206BA
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:22:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C03F6206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BF756B000E; Thu, 28 Mar 2019 11:22:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 47F326B0010; Thu, 28 Mar 2019 11:22:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 320686B0266; Thu, 28 Mar 2019 11:22:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D5F2D6B000E
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:22:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id 41so8307798edr.19
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:22:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=EIMxzs3KcJ4jmgX2iikj+tJ0Q4+Nen0h2D0kdVtq1V0=;
        b=H4C51xk01eiBRDczKBIRegSzyVdpKL4//yXpGBX6ShZOZsuYMflJvGwA1jb4Nq1mQt
         47chRlYev+VwxosZQoo28eC+2CJdM/VksNGpDMu3CA0xWnQMHEnccyiAmGPtfoStmn/A
         TglSMDoq5QYElW+bQcD8ZI8ZcN3wrprJgQXUMO7ssSTApqsHK+avoIMibTTnKSYDRW2f
         J1QCaNvqExETNyvY3BZ8haZp4vw2hbnoIS619hdW4FUvhLk6lA1WVmgVJmVfSSoWiJnX
         +IXyaqqPaGgRF4rcJxrrHB24ZueZpHEe31qeX/xXZEP/xp5ajfrQyH4gzrVfG4D/XkwT
         iXBQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXMCkC8LBja8hXPsWrr68WZvBChVj66HcYQyz4PlXyCmHdP9O1Y
	bp7ajIbvXLZ4QIwRCXvgxwk1CMR+qQafUELsjcu4bJEd1KE9kuY1FAiuTkuyvV0YI2Jf/lODpEs
	ozm6TctPo6et+/+5jBZyhKq/IvYOUfbqZy1qUsLB6S+Kb7007OvnsaaJPvcMuB3PgyQ==
X-Received: by 2002:a50:eb0c:: with SMTP id y12mr27097490edp.237.1553786543400;
        Thu, 28 Mar 2019 08:22:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyhjyWi/oYoGydgVrTzWA/a44MqBpkLYI3n3azmf3YFIXRyQ/tAvSLZXj+tOp7WbHtVSuu
X-Received: by 2002:a50:eb0c:: with SMTP id y12mr27097453edp.237.1553786542502;
        Thu, 28 Mar 2019 08:22:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786542; cv=none;
        d=google.com; s=arc-20160816;
        b=o2oy/P9HPGEnCsjkUPsMkjiJDGw/yqCoN1UJgZGtD54wc6z0vNk2NU1adUvLCnZXgK
         g0u0RX9vqZHFSu6U8XSBC8SGYw0jxosU+9KTpneUxOM2BIIRJqYQ4Saws6d+eucWNQOa
         35yLRQorD7G6J60lGS9GeKzYktvhIblMj0a5q5Nws/o6u+0Mp9sLiv9s+7gWtFlTorEs
         7627rtG+0OgybN/ozmtwNvC/WXtuv1ytf7FXamI5DqhLVm5ArNj3BHGIJkPooUFhQuw4
         ka1CRmAasJTqIFdRWrkfEbPSmZ0fQZeTP1F9xd4EF/c6LpADE89YG/kU5j8uJGXbcVBX
         vGqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=EIMxzs3KcJ4jmgX2iikj+tJ0Q4+Nen0h2D0kdVtq1V0=;
        b=wYdjSGKDARc9BA+KHo0lGZhM5fywsPjhHqAq2fCuGu+AbN76/L80OFgyt3rbWfIdlh
         mJ4UDcN0epWU0lvKTxcwzdRftNWY4eZOHoGg+zggSROpZeca8ZPwg3A28cEZ8Tvq/dff
         r7Xjrtcdy5D2JRlhX40sHC+lhMzH7T1wLTQOLsdpZS5FQiSzcNWreXERoiGKlnnMZ1It
         9swjprIXH08BTROqmZbSPRQxgKtJ3n6Yz37fWsY5STw8JfuyOHGojXsbxs4zzc24Zfv3
         /je3I62h3rD7+VtvUlcuBR+zb7k7x2IoawD9MNaeWMAknKi3pN6m2Pw0AEqK95GzPRy7
         AsKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e35si9186795eda.186.2019.03.28.08.22.22
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:22:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9FED7165C;
	Thu, 28 Mar 2019 08:22:21 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E1F133F557;
	Thu, 28 Mar 2019 08:22:17 -0700 (PDT)
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
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux-s390@vger.kernel.org
Subject: [PATCH v7 07/20] s390: mm: Add p?d_large() definitions
Date: Thu, 28 Mar 2019 15:20:51 +0000
Message-Id: <20190328152104.23106-8-steven.price@arm.com>
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

