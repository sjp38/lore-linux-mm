Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1F3EC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7AD9020842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7AD9020842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F0AE8E0006; Wed, 27 Feb 2019 12:06:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C6D58E0001; Wed, 27 Feb 2019 12:06:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 169B28E0006; Wed, 27 Feb 2019 12:06:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id B55D08E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:06:38 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id i22so7222381eds.20
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:06:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=64nlTJ5kHDNpXPvnMC77gIztv7iCOTrax7wYjYpzDA0=;
        b=EsDlAPyQRHNLb/urXCB/IzqJXtIk7HChOg8ezzKvDLegBLmMr+cbh6eS1f1cH3IJYZ
         IEscP2fcV6b4wFvoyZ6BKuccF6NzkUTWs4hKrPXkXtJ/4hlsMu5f8eRPPFU8FWqI7PA4
         RFYu5aEQtn45yia8x1ogm7pwsTEvJXbsGUeVbrZf6d/L1C/Yh8CSrxoouqT5z1ci+jDl
         R3cJehOULfzu+hZWRJfg+0MJ88Qed+LkXJrMeaWx10ZhJej5rNM1NNe8bXWk9sxDPdwg
         v1e8hq24LuXdt1oB4iZwelVeAdptmxF+IBb4CTiPMewB+I36KBbkYVz8LFuw5GgpXvql
         FfGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAua45znXo4W2ULpmY38bsRDLW97fjO6JXFHoOXIC5eEt48cHtOlL
	nkgnt2CoI8Wa5mcbTVejvlaS1z7a7Gyf0oaMf9DtIyAaCA6KlPdFIrwxK8D2d+z1igg0cFpf5yv
	TawfvgRSMuhdP3uEjUFC9qlgggg/QdbBLZxi6+L9OmGld1zHYYX3FmZErRDSTbsRCuw==
X-Received: by 2002:a17:906:ee2:: with SMTP id x2mr2295614eji.202.1551287198189;
        Wed, 27 Feb 2019 09:06:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYp84nmvK20JrI0OE9BgxQyAHJvS1yc1C++1FiXYV41vHIk/MkULBRAHhs2lDZKqPNhEfCG
X-Received: by 2002:a17:906:ee2:: with SMTP id x2mr2295550eji.202.1551287197082;
        Wed, 27 Feb 2019 09:06:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287197; cv=none;
        d=google.com; s=arc-20160816;
        b=hWf5DYGpbIqbpxQIbnNrfg3mUSHGj8A/LOWTMuO+p8KyJVlAkgXcvbUxT7jGuvOHuw
         zUWjQkY33xqBC0e751YcG1OZ6rt/7ghZ+Nm7JXOJ/m5yRnXpvfalOBY2w144jyy4rhO6
         4KxPMF+EHGwhWGmyKOZX8g5bIbCZjee7rPjwL16ZWCmO5x91ZpxDVkTuk8d3z0YzNsSt
         JFZ+PVdoh/xsnz89Sjmf/t4Ctf7BWMwEVYv7DxFv6OQZTLWsoL2vZtSXuhcoPACG8W4A
         BGe4ZxOZ1vfITLKGRsf0+wHt8RybW1vGZDDCI1hb27yqIDbrnBCsVE8c1WlS+42Sw9ln
         2vXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=64nlTJ5kHDNpXPvnMC77gIztv7iCOTrax7wYjYpzDA0=;
        b=ZK8/i8Mig7lvrpole9br8Aw1hkjEQmpcwbXBnPVZamk0zKIcqTcK1K1TudkEYd1BlH
         +rRYkQdx1CBkneKsF15FteWj2mOCsGd6Zt6Ae2sQibXqyctfJ+Fp6Kre1soTFBrx/jMR
         DUbY4WG0+w2pqgxD+xCZbHS/R0FuRBFIRD0HE9toXw+Z9gGTD2bl47M4btqT8Frgr8LA
         K+l7+SbOCXiae+g+Yt1m2zBny4I9nu9TzbP/h4r2mvcUt9g/LcArL2xX7yHSPzo+Vvfu
         DSdxMhjASATVFfyJGjIgv40ez9YvwPsmZKD2XCMAxZiufoPnoYiLWyTzGGbiLOzOeAPj
         racQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q33si1491179edd.299.2019.02.27.09.06.36
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:06:37 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EF507A78;
	Wed, 27 Feb 2019 09:06:35 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6E0723F738;
	Wed, 27 Feb 2019 09:06:32 -0800 (PST)
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
Subject: [PATCH v3 02/34] arc: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:36 +0000
Message-Id: <20190227170608.27963-3-steven.price@arm.com>
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
'leaf' entry in the page tables. This information will be provided by the
p?d_large() functions/macros.

For arc, we only have two levels, so only pmd_large() is needed.

CC: Vineet Gupta <vgupta@synopsys.com>
CC: linux-snps-arc@lists.infradead.org
Signed-off-by: Steven Price <steven.price@arm.com>
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

