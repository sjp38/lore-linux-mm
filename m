Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AECFC10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C62C20830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C62C20830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B9796B000A; Wed,  3 Apr 2019 10:17:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 969366B000C; Wed,  3 Apr 2019 10:17:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 808B56B000D; Wed,  3 Apr 2019 10:17:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 34D986B000A
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:17:18 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h27so7509317eda.8
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:17:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3GzvBNszJ2F9qzyq8uNQC4ioxjUcI3EqpQkesdmXCx4=;
        b=oV6bi4qCwI6esbCxTRPn71LCs/3mTqqw9El6WyAIfS2EWwyutlF9AeQiRbLqs+Y/i/
         m5+MTjCBch38zrZvK1OGdjKE/ZugYeQUKOWlkwXDYK7azFTMr1SZmzzQ7c3OH9vVe7Tj
         anD8irsbXF+u5YYStV3gH6n++96Ui2EtKlQlTTZlGTJCbb2p7DB1+VO+rK98GlBdVOTP
         JgqG9VzJmuHnxhdx1A7gFhm114gS5Br1Q+WcCx0L4fHgbV0265f7+jS29wqYiGhD6SoH
         3mw/bfytomRKiirmW/sFR+G0iwi7BARJ8dl+48G32bii5UaghmH1kXNenr8T22j19Pxt
         30eg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVNAHtEuWCiq/Xh4/MwjMtnADBMUYU81wPbLh/OTXCZKSKp98k2
	SsCeW7q3aH/htHNnZxU8SxZT4sXtBOMZg6DyrybISavWkZDPcQRV5whLEM91YaSML+BJxm1c4Wz
	gLgpPxeOvb8SNV/TucOGwicfPOjNG+yZ3vxLe9T/v0EPxtS5pDYgE0i3aeGyGWM1aLg==
X-Received: by 2002:a17:906:950b:: with SMTP id u11mr4775ejx.154.1554301037682;
        Wed, 03 Apr 2019 07:17:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8gdkcOm4S6/Ynw4bWrhpaWnsaZH10XXPlh8b0VIA0cTJZNytDu/f81XTcQzpBxeCg0I/L
X-Received: by 2002:a17:906:950b:: with SMTP id u11mr4706ejx.154.1554301036420;
        Wed, 03 Apr 2019 07:17:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301036; cv=none;
        d=google.com; s=arc-20160816;
        b=MmPyXIDqIGwGmWCz9fMu9PVv8j85iuYjDjQEIk3AhE6AUuxA9KzSzAZm2kPWdyW9hc
         DrXnJbCojNal5w12Ojx+siGQgcalXL9sKpVDZgHSYgEFUwMs7baixRYajQGc5qugNKXR
         8tU7h2RM9VlxV9ZtjcvbGDVfknsZF6TxpE1hkYYUJFfqaS5Vcr+wOq5RcykiZTdv3LJt
         bKX5J6guLM01x0zmJSdczjCc5BDP5zwba9tjOcBzk1tv45zJgtZAgLn2yg/N0BFp14P3
         f4zQ40IzEqAvUOCZaG1B81y8dVpDDXtVaX2ri/mvwWL60GkFH3NGgAbFNUXE93f0SaMR
         qcxA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=3GzvBNszJ2F9qzyq8uNQC4ioxjUcI3EqpQkesdmXCx4=;
        b=dsFEm/dnyrZhuNDgv1Q7Kt03FbUfmAMcwc+fushhUGq77yJjqFNJNryHZKxMJ4EHOD
         qZs/xuOFPGGohun/UDhBHdHaEodRWuAkHZ0LU/y2nREJ+htusboctT1z5j6T2FW8nxPh
         wD+CUti9DhalZBeJ/DxUZP4GYgY9Aa5scpFMUXYK0Ieh+NrBJE7JAtq2neDG5rwVm0+x
         BAfMCKb59WXTvYxErFBGa8U0E7XGy5P43eqTXj9bG7F5AAO2qfdAH1FK5vnfWc2UDVbF
         q0v66vyIEHPNksYn94Hc/dBazfgV/4ZB5bLa0Wz6OsGaMlSBtZbwYbf6Br1en+83/bKO
         tESg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p5si3352535edr.211.2019.04.03.07.17.16
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:17:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6F9FEEBD;
	Wed,  3 Apr 2019 07:17:15 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BE3033F68F;
	Wed,  3 Apr 2019 07:17:11 -0700 (PDT)
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
	Andrew Morton <akpm@linux-foundation.org>,
	Vineet Gupta <vgupta@synopsys.com>,
	linux-snps-arc@lists.infradead.org
Subject: [PATCH v8 01/20] arc: mm: Add p?d_large() definitions
Date: Wed,  3 Apr 2019 15:16:08 +0100
Message-Id: <20190403141627.11664-2-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190403141627.11664-1-steven.price@arm.com>
References: <20190403141627.11664-1-steven.price@arm.com>
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

