Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07FC4C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C6DBC20C01
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:07:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6DBC20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 674558E0011; Wed, 27 Feb 2019 12:07:20 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5D9358E0001; Wed, 27 Feb 2019 12:07:20 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4778B8E0011; Wed, 27 Feb 2019 12:07:20 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E46918E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:19 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id u25so7229048edd.15
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8hX07yhBmDg+UJCmPXqdceXMzT4L50HzWM5i97rNZtY=;
        b=PatxfNIrUr+1/tFiS9nbKL91w8mBQuhgot0dqRsvXR5dFWCGtBL8tY4a3LB3szFOYJ
         Nq7tjbnzpK4GNKXAUFWdEaGg3A9pLmA7xVW4tx05CTycUF0z7SuZ7Pmp7X237RCpz1+W
         DCSOXgWyvwLNq8q8xKK19vqhsQhjB0dEYr/j+DjQqO6zX9+Au4mat7PWnpL1xjosn5WE
         kiaDEBUitDLulQVNbP1kTk6YnN4vTjmjveMmIRwKB1WHoaX92b58QdIPMys4djUL5wyL
         SRxSAHAwrGVEo/BlQoDb/PpOXGMvv7o2Hj299KdSsPcLdHAXANNei84Xktdc9W0pipTF
         55qg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuZ97LN2jTCQZ3cts0UnWqshwVuByOTg88xGyay3MUcbiJjJqjlZ
	fvmRVC/PCK30ObYgawkEKP1Ab+Jg966qj5JFXTjXjirEQm4PWCosffUNAEJFzdyG2lkKm/sHB5+
	pb4bVX2tfx4sQ2jZA0PFHq1nhAThSNGGuYB6HYSmx50I8tOadbU1TtiennF54/NIeOA==
X-Received: by 2002:a50:b574:: with SMTP id z49mr3136984edd.283.1551287239452;
        Wed, 27 Feb 2019 09:07:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYK5IADUlSvEffssp5Q0q8t3pLvzl2z17gt5m9FvwW1jvTCA2hmBIREr4x2jejSM6aCqx+P
X-Received: by 2002:a50:b574:: with SMTP id z49mr3136926edd.283.1551287238557;
        Wed, 27 Feb 2019 09:07:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287238; cv=none;
        d=google.com; s=arc-20160816;
        b=sjo/+EZ7ewEfNs4G1bQEFHcfKM5H5eeJqiYLBEUQzkvdmyoo49yhUby+SbJ8C4DJAl
         oXE+vmQ47HRd0oiBHE2xsaLTcdEdtUh/6hk+6SNKaqFuMMtdMXYXFeennB5tHRttY5Ro
         W+gcEgxgNtRbXDktt8YxLxOTK9CReWAXsIJsZEfGUrR/9T13ZU+vVrBkeyOi4Jn2GWk3
         JFw7O7nOc1DxUC/qwhDi1IOBq/KLyOx36BHngXwiz5RHheCjjYwIKWxcnr2LcjfFIrWU
         lQAtiyNCBY1gzNguqCpcPQk2WC3pqoWbUc1jYka1Ok0tQnBr3J2Mfnb8YRx8OkuDWdJv
         UEKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=8hX07yhBmDg+UJCmPXqdceXMzT4L50HzWM5i97rNZtY=;
        b=aIOtqdNyBhbJxb/euwa+BdSr1opjeTjlkE6IpeSuEIKgNapOcnOqjMSHEg/u4FMIcY
         oDNbwAegxedNL2KKcIqSSbTTgxETRUpTpFPHdAcM5wUgQlUCJn4wJ9/oa89wZEHQ/rRF
         37BdbN+9ksAmnBWxd3WyCxjnVl5hqekkdseEWPpt1y50EfUzE/U44e3pqtgZpxX2jKn0
         fg7r2mcXU2AHspnWkqqiLM1bFtzDTqbHBib+ac/tWKnZH6XhE9YmnHOfrgyoXUi1F2gk
         nTkDGDwmTF6W9nw7aNI/QqjiD2ZVGOAO72gVPjAZ6MhRXuzkjvhcspgwEUdJKiVerifO
         IoLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h43si2531142edb.278.2019.02.27.09.07.18
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:18 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8AA0B1715;
	Wed, 27 Feb 2019 09:07:17 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0842D3F738;
	Wed, 27 Feb 2019 09:07:13 -0800 (PST)
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
	Ley Foon Tan <lftan@altera.com>,
	nios2-dev@lists.rocketboards.org
Subject: [PATCH v3 13/34] nios2: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:47 +0000
Message-Id: <20190227170608.27963-14-steven.price@arm.com>
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

For nios2, we don't support large pages, so add a stub returning 0.

CC: Ley Foon Tan <lftan@altera.com>
CC: nios2-dev@lists.rocketboards.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/nios2/include/asm/pgtable.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/nios2/include/asm/pgtable.h b/arch/nios2/include/asm/pgtable.h
index db4f7d179220..b6ee0c205279 100644
--- a/arch/nios2/include/asm/pgtable.h
+++ b/arch/nios2/include/asm/pgtable.h
@@ -190,6 +190,11 @@ static inline int pmd_present(pmd_t pmd)
 			&& (pmd_val(pmd) != 0UL);
 }
 
+static inline int pmd_large(pmd_t pmd)
+{
+	return 0;
+}
+
 static inline void pmd_clear(pmd_t *pmdp)
 {
 	pmd_val(*pmdp) = (unsigned long) invalid_pte_table;
-- 
2.20.1

