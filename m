Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3A4A7C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F41B4218E2
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F41B4218E2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81F606B0007; Thu, 21 Mar 2019 10:20:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CEEA6B000C; Thu, 21 Mar 2019 10:20:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6BFBC6B000D; Thu, 21 Mar 2019 10:20:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 204686B0007
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:20:12 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x29so2273799edb.17
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:20:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3GzvBNszJ2F9qzyq8uNQC4ioxjUcI3EqpQkesdmXCx4=;
        b=ArTxfEe91Pup0vvlmVWj5vsj8Ox30CogQokc1gnIL5gnZwZJ/pbzofaYkFdn+/hK/T
         K9gSqVPoxu0rNeFsRcRIzSw5sKpo32y0WKUPtj0Ozjv7aiLwHXCg9/g/kKN6ZTpp3vW8
         npcSQhSpUcW/JnGqgTt+SaqPDkjlNgtwkq+Gy8F0V7R53QzQMinHNvIDepRwMy/zUcpx
         RhbhH+sJTJF8SPrflWr0AvMTS0yS8QKpoYCWTdlM8Y5cnEXzpyhInxgp4U+EuLsHD+Kr
         MZ0NnllW+NmeYPXwNNTYFGhwgqN3yY0ouHigFOXTjaje+76pMp0gZB2xX7nJqw2hQL0x
         pU+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUcWLjisyd8paFWXmWx9nYnb/knA6+qIRnEecJRTi7ZJbG6X4tZ
	WB/KooejqdvHGrc/GYLOG8OjVArL/uYX0lRpXRxQlwm1FCUSlrrisBE6usw4YcWh7w2CrBguzT7
	zsFUXbBT4/wWvd0+5pX5xens/skeGPAj9zMMMveeQESFGF9kM5rt13XhUYUVEVNqiqA==
X-Received: by 2002:a17:906:278a:: with SMTP id j10mr2475288ejc.12.1553178011665;
        Thu, 21 Mar 2019 07:20:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCqfwMDqbJIAcawGEBR7p/BeRKn8bKU3wrUIA+ZbrDf6HZp1dLAjXirKJoReWXdNkNLwJq
X-Received: by 2002:a17:906:278a:: with SMTP id j10mr2475250ejc.12.1553178010813;
        Thu, 21 Mar 2019 07:20:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178010; cv=none;
        d=google.com; s=arc-20160816;
        b=QM1dYvdrZWHqKazIrkg2EGg6EwLYjwuxSqpKc7vZCggs53GVOImkWOhVLvy+t2BQk2
         3VabhxXxmvrPSgolZAAuO+VtOUGZso+2Xd5IwXsMiCCad/4HS29rh8grj0nVMU3og/Ec
         5PSxfPjHkqwUhCzPeonT/iGvfcWON28Em8p/2EsN+rrcesDpy8O2KnZ6tQ2jHCf/vT1v
         YI3sgL7RWglD56ebNFLqb18b5Tb1jRhkubscIhBmtpLOa83UukZLRuPFBlv2Ab7PhuIJ
         jQfotMyunK2D3FTENylMHQFH6+/1MtHmiA0X5+3fe66Xf60labUwRJTfj+VhZVJqypDC
         yGwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=3GzvBNszJ2F9qzyq8uNQC4ioxjUcI3EqpQkesdmXCx4=;
        b=uDBzc6lE/3EETcX1AE+DYJm2cvK7bE7ZByEkD8vRJ2R4HRuBHF3StiKvo0kzoZ6oxN
         ku2Fevou3hR8mUa2nnsocGlGMrLKKQ/t8OBVxQlhnlGaS2LZIekcEAXyTaTKO4xcxu1G
         ZN7qI6u3Km2SjFTzWNgjthoJ/0TcV23zOVU1PAy4QMImYcJXPOnG0D6o2Kq+5dtDIyWT
         7x/PlxRX+pDXhnkucB0peDZDwIXbiAfcQUAEDjaT7yY9wUWD7juQP89KohI7+k/T8qqH
         TzYM3ws2kcETF+jEyq+B3qSbrN6IiK5X9XvXmHB5Hl4pwDjOwLJqia3y86obeFwFOCZT
         0uAQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d13si2081850edx.162.2019.03.21.07.20.10
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:20:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BBFCBEBD;
	Thu, 21 Mar 2019 07:20:09 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3A4E93F575;
	Thu, 21 Mar 2019 07:20:06 -0700 (PDT)
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
	Vineet Gupta <vgupta@synopsys.com>,
	linux-snps-arc@lists.infradead.org
Subject: [PATCH v5 01/19] arc: mm: Add p?d_large() definitions
Date: Thu, 21 Mar 2019 14:19:35 +0000
Message-Id: <20190321141953.31960-2-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190321141953.31960-1-steven.price@arm.com>
References: <20190321141953.31960-1-steven.price@arm.com>
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

For arc, we only have two levels, so only pmd_large() is needed.

CC: Vineet Gupta <vgupta@synopsys.com>
CC: linux-snps-arc@lists.infradead.org
Signed-off-by: Steven Price <steven.price@arm.com>
Acked-by: Vineet Gupta <vgupta@synopsys.com>
---
 arch/arc/include/asm/pgtable.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index cf4be70d5892..0edd27bc7018 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -277,6 +277,7 @@ static inline void pmd_set(pmd_t *pmdp, pte_t *ptep)
 #define pmd_none(x)			(!pmd_val(x))
 #define	pmd_bad(x)			((pmd_val(x) & ~PAGE_MASK))
 #define pmd_present(x)			(pmd_val(x))
+#define pmd_large(x)			(pmd_val(pmd) & _PAGE_HW_SZ)
 #define pmd_clear(xp)			do { pmd_val(*(xp)) = 0; } while (0)
 
 #define pte_page(pte)		pfn_to_page(pte_pfn(pte))
-- 
2.20.1

