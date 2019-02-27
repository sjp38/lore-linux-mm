Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E45A2C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEFF320C01
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEFF320C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5FFFD8E0017; Wed, 27 Feb 2019 12:07:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5ADB88E0001; Wed, 27 Feb 2019 12:07:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4788E8E0017; Wed, 27 Feb 2019 12:07:48 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id DC5338E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:47 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id h16so7211728edq.16
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nxjOX6LayepjKtF9PaCGEhuHv91+mgqyka9gC1xojUs=;
        b=NlLRuUxqFIy82wYJOJZx0P2voAxG6pNj2bRB9c9WPh4Rp7ewXowXNvPp8IlCZ3yIBa
         6ZOBSnzj2jrCpcVf4NgZkL4rWxIoWUaKc0hNUic36VyWAgUlUKG+qQpyVkNMn98Sr/CX
         PrgHH2IEiLAUs66IRMQKiL0ZptPmFgUonx5ArhfOGFUSMOM9LWGf+elvQWvUxNPNQW4i
         Gn7KX+5gYgRC3A3CTbJdbQfIr6lfmFAEZEWSjCjwDinikmZtC1kOvWVHzJwfNIy/Iecz
         hws0tr4ccNvFRa/+dI1D89ihQ+n6Ox7K3hpUEZgL0F01f6rkqYM8x96ENuyUqhEEk3/f
         wGJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuaQln5mLHxgI/15BGwEF5zuBa6XVrZRDBloV4rP6ftkBx/BM0og
	EbWoj+8c6NYaFFRpcckoQPtQ1Zfx+Onfq/Nq901sEBZ2lElOm9mmO0sjIpUt5BxAH5JrEOTUO3q
	keIsAtMVWqBoDE5MjI+bWAj9rEGcTtD3nPW1CUY3OiUrHuRAawNRetY4Gs32nNeh63w==
X-Received: by 2002:a17:906:4347:: with SMTP id z7mr2301074ejm.190.1551287267408;
        Wed, 27 Feb 2019 09:07:47 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaX/79sQE66n4F8zyJeAOLHMcFJr1KjiZ2VjJ3WcNRrRE7DvJPEu2tp3/R3FgRQHPjDj79l
X-Received: by 2002:a17:906:4347:: with SMTP id z7mr2301010ejm.190.1551287266346;
        Wed, 27 Feb 2019 09:07:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287266; cv=none;
        d=google.com; s=arc-20160816;
        b=RP01+Ikw71/zA1sGYWE7HoRNEIYy3OmxQnjjo08/TxBocqttHxf/Woz9UnG8Zexs21
         t75xTx39NcRJ10ByZGUXv080haMJ+pveJF5Zp7iJsKqIvv3mZWRlYnD1kYCkyWonh0Xy
         FLl/4WSaoBhP06Pgd/loWIJcRFpEvD2QEaSE5iFgr6uj8Mk3XhlM4kFBvy3FtpjSrPbm
         Ly5Lcpvai4F+4WijqUO9HVTYgBDpZUyCeG68REsuNhOuVJki5mKBu2vqLs4x9mQserxg
         1D5y7DmNUcyhkCPLl3u1GJGCZ8a59fnif0bNiLGElixlP6ZgQbOShpqMhW+0WfwVTOb6
         pKiQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=nxjOX6LayepjKtF9PaCGEhuHv91+mgqyka9gC1xojUs=;
        b=iPG/l7w2Cr/SPVWMTxbaCUQF8+63wfbHh5+1Nl73552dfV9Ax0SWkBreTGn+9JRpcP
         1968BlrplS/cJEdZXcqIbbNXwKCczilxdyvgRPhSrav/VizF6ihVESEqijW0Na++suQA
         TMOhC1n2xivcTwW3+3RE8hv7B4hZBb3kAJoPFUtsUPxUSqxAvC2VJyj7wysF6RPZOxH3
         LGakXpxO9RLPLNgFqkpgk269Pc+NUQKDaR92tl4bVhJp/NyF9cdtqpbGOIjokYe6kfPz
         jVVF8oiVXQ2BFsSQpytvbq35KGsKQROg/q5xmVJmNO2Z6UcEGBDe5hxF4t3Lo7t08NZ0
         uMtw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t38si4774738eda.121.2019.02.27.09.07.46
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:46 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6C3B4A78;
	Wed, 27 Feb 2019 09:07:45 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DE2B83F738;
	Wed, 27 Feb 2019 09:07:41 -0800 (PST)
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
	"David S. Miller" <davem@davemloft.net>,
	sparclinux@vger.kernel.org
Subject: [PATCH v3 20/34] sparc: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:54 +0000
Message-Id: <20190227170608.27963-21-steven.price@arm.com>
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

For sparc, we don't support large pages, so add stubs returning 0.

CC: "David S. Miller" <davem@davemloft.net>
CC: sparclinux@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/sparc/include/asm/pgtable_32.h | 10 ++++++++++
 arch/sparc/include/asm/pgtable_64.h |  1 +
 2 files changed, 11 insertions(+)

diff --git a/arch/sparc/include/asm/pgtable_32.h b/arch/sparc/include/asm/pgtable_32.h
index 4eebed6c6781..dbc533e4c460 100644
--- a/arch/sparc/include/asm/pgtable_32.h
+++ b/arch/sparc/include/asm/pgtable_32.h
@@ -177,6 +177,11 @@ static inline int pmd_none(pmd_t pmd)
 	return !pmd_val(pmd);
 }
 
+static inline int pmd_large(pmd_t pmd)
+{
+	return 0;
+}
+
 static inline void pmd_clear(pmd_t *pmdp)
 {
 	int i;
@@ -199,6 +204,11 @@ static inline int pgd_present(pgd_t pgd)
 	return ((pgd_val(pgd) & SRMMU_ET_MASK) == SRMMU_ET_PTD);
 }
 
+static inline int pgd_large(pgd_t pgd)
+{
+	return 0;
+}
+
 static inline void pgd_clear(pgd_t *pgdp)
 {
 	set_pte((pte_t *)pgdp, __pte(0));
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 1393a8ac596b..c32b26bdea53 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -892,6 +892,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
 #define pgd_page_vaddr(pgd)		\
 	((unsigned long) __va(pgd_val(pgd)))
 #define pgd_present(pgd)		(pgd_val(pgd) != 0U)
+#define pgd_large(pgd)			(0)
 #define pgd_clear(pgdp)			(pgd_val(*(pgdp)) = 0UL)
 
 static inline unsigned long pud_large(pud_t pud)
-- 
2.20.1

