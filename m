Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E164C76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 500C722296
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:42:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 500C722296
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F3AEA8E000A; Mon, 22 Jul 2019 11:42:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E77DF8E0001; Mon, 22 Jul 2019 11:42:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF1708E000A; Mon, 22 Jul 2019 11:42:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6D9588E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:42:50 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id a5so26537342edx.12
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:42:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=9yNPMoYJcGoxoxeHWzB9fU8wwaC0bR8nBAs+Hiw9CLE=;
        b=BJbmZYW5fUf/b7B+2zsBXrBAhvBUeQhGQo93lyXL8wKVNyceycNsLOwkUZt8ALrG9i
         4vAEp9ro8sJqfXagE1inYgPiQZocBi8jNNSQcemgC8yA8doeFp+1I9zhEE9iXRcgMtEd
         7CuTtCV7JFlXtJ3nOewyxW2/VVQAVvU9wgJRHbCZdzE1tjvo7AWxtWTFlzRdJ8Sy2vzY
         aHK6GWVup9RhT1J9hrrYbFAwxFU9S26E3OIyIPzynOzxaAy9qbRRXAbekvW2gY8wJNuV
         r61BgpkiSdgqfUkPBL7xey05hOf+GbW3KG439kEXbrkG0TR7k8DOHla7d7VLTHu9mDRo
         JVIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAV7/wQ3Uz9U0p8AkLvJBPilW4Z8zSPD9jJ7Csoybf40d7cZ+cTp
	xvSfMrIySEXYxdTcDsxVkgKhmFJ+YIOVaBP7FAA2MOCH4Axg+xU002p+iqpAfr+l2Ok98pjbACB
	TRWbxs1fcQ18wSjB6R+pBQPHhM9D45bzc7YbCGhmo60yx2h8JDZnhF4jf9nX4s3MnMw==
X-Received: by 2002:a17:906:401a:: with SMTP id v26mr54731451ejj.62.1563810170040;
        Mon, 22 Jul 2019 08:42:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5HcUT4FtM41Jr5HxxMZOXqbB98Ft7w7NdPfzyIxrhHl2mMDnFv24WsUf5aFU1ngwlMSac
X-Received: by 2002:a17:906:401a:: with SMTP id v26mr54731380ejj.62.1563810168869;
        Mon, 22 Jul 2019 08:42:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810168; cv=none;
        d=google.com; s=arc-20160816;
        b=rqkmTG5XO2rGVxP9UjOWyi8Ij1e9J+RLjpEvscr8gytC+rSZhf+D6kdz+oNI/sqwis
         t8xPB4qQyjtvbwj9NUQImxeBBRroTxSUwZFUK4O9+E+HoyqENrmaSAyTf7eb83Q3/tL/
         eb3XuiGhkz0/uhmybdaoKlz/eXrJZc33W97ckoAeYX1Vz2Y2L7GRNypUPmXcJniK5BiK
         6Tr1yATueGghz0+JUsRJvd//6/qPYoKeeJfc0olP2jhvjjeR8bKpbwED0CdF9482RWPA
         aiTQz4IRZvYiYnw60O76PsYk9+csDBCV9D+bPM+JVWa0ZKW4KJ+EtwaFWvNeHCMFZZ0k
         94xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=9yNPMoYJcGoxoxeHWzB9fU8wwaC0bR8nBAs+Hiw9CLE=;
        b=NhlQvnzKrCBnT0izA9jCai8wvoCHvzdjjFpk1DcLlZm+8Bbsp1kc+Mb5a72wWsnYQ4
         E5ROj8Rx77uwe+gF384uh/qMhGF93JZjnkOKsyBy1Yst/0ivaf6cBr9oOU3a+PEHWuZj
         UDxpDDRhNZAvYHLTpDacFe24gm/u/N7VgQBDPfrfQUGlVhCa8eIN/7NhvIzGfUPtrBJa
         KU+uCgu4C2LiiHwgmNKq0GiBzrWZb7B9g8lnMGq4DMQARZsaREXYyuMe7wtYf95FTU/u
         lorj8k/iXxoewupCmnAc0pQldfX6qvRP2o5zFctHIdFXkpdYDsL8ebeHw2qT+flga3up
         Y0/w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id r2si5156014eda.213.2019.07.22.08.42.48
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:42:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0D49F1596;
	Mon, 22 Jul 2019 08:42:48 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 41F493F694;
	Mon, 22 Jul 2019 08:42:45 -0700 (PDT)
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
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	sparclinux@vger.kernel.org
Subject: [PATCH v9 08/21] sparc: mm: Add p?d_leaf() definitions
Date: Mon, 22 Jul 2019 16:41:57 +0100
Message-Id: <20190722154210.42799-9-steven.price@arm.com>
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

walk_page_range() is going to be allowed to walk page tables other than
those of user space. For this it needs to know when it has reached a
'leaf' entry in the page tables. This information is provided by the
p?d_leaf() functions/macros.

For sparc 64 bit, pmd_large() and pud_large() are already provided, so
add macros to provide the p?d_leaf names required by the generic code.

CC: "David S. Miller" <davem@davemloft.net>
CC: sparclinux@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/sparc/include/asm/pgtable_64.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 1599de730532..a78b968ae3fa 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -683,6 +683,7 @@ static inline unsigned long pte_special(pte_t pte)
 	return pte_val(pte) & _PAGE_SPECIAL;
 }
 
+#define pmd_leaf	pmd_large
 static inline unsigned long pmd_large(pmd_t pmd)
 {
 	pte_t pte = __pte(pmd_val(pmd));
@@ -867,6 +868,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
 /* only used by the stubbed out hugetlb gup code, should never be called */
 #define pgd_page(pgd)			NULL
 
+#define pud_leaf	pud_large
 static inline unsigned long pud_large(pud_t pud)
 {
 	pte_t pte = __pte(pud_val(pud));
-- 
2.20.1

