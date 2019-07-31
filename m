Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FC6DC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E311208E3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E311208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C7DC98E000D; Wed, 31 Jul 2019 11:46:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C54048E0003; Wed, 31 Jul 2019 11:46:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B46B68E000D; Wed, 31 Jul 2019 11:46:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6760A8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:22 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id y3so42642885edm.21
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=eKl9NY7OTKmyYuPsGrRoNPFWZw8MxP6jB3gNXjnh+E8=;
        b=o+mQOInfbVX0JxzvXUVuYEwqOw7ecBshjBNLAsGUyxB3R+l08Qwk6CM9YyfLtcjO5Z
         TuAwaA4w1t6ige9nxYgCRI9IacsRE6a9zDV7Kwy0DAB7OI6xQ5+f4At/UuC02XMeipMG
         bwUUegEL8xYUPQyi/pOKFQWMhTNLSVQydsD8UmPY55WMpObkaMLhg8ny23elYQl7RK2x
         IahsZRAOM4pcivQDbgSmyHwn15UDWqoq1aWWc+GUnvko1v6AunEG343+TKbV2zUebaNz
         EcTubul6yjhXsFcoKzOaLOPyv7iuQwrxLfL4ZwVNf4AGBD12kYznu32Qw63r1cV2VrqJ
         Gk1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWeOkCg1pmx4r3bTbOYSGZb7WPFdDAfLU6KH+fRRd1t18uJnDuZ
	U/tgsEQrCzZnoKn/rZh1b+fpYXv+maNEmdp+IPCgb0oGdVQ5rxD3Gx5fsxftdL9ndl+/0SoUXAq
	uO1LnJvShGZ4HUMwJTeubRRdZ6cNOClqDg3YT4Q5irL6nYSmHMujwQGu/pvT2Ekvi6Q==
X-Received: by 2002:a50:886a:: with SMTP id c39mr40694800edc.214.1564587982018;
        Wed, 31 Jul 2019 08:46:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuHGqUDaic/05JahkVWTtRiAJzv2/cyA/0cQ4z45zwvQczSj0SqOh2XigZ8Uy8aQogrTuQ
X-Received: by 2002:a50:886a:: with SMTP id c39mr40694715edc.214.1564587981213;
        Wed, 31 Jul 2019 08:46:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564587981; cv=none;
        d=google.com; s=arc-20160816;
        b=DOgbJPHaAzttkTuGoTZTABcdOmpVOCMwjpA7V2b6ZF0gUZVEjamxd5nU7zklXnUDFt
         YEj7CzDJt7c+j3h/CavAQcNaAtaXgJOyEeVmw5xPGCojj5ZtbfLMf5sJZA58HxZUT3+j
         JpOu4NDxU6OWvZQ0ffTSLyEFciyOE2GwSKwvZGeQD8Bo37zWPQZlIwUu1ensWM1JOCgp
         91EzJOK+oO2gm5z0g9voIB8b1O0e8U1uaP1DuFcUsUgzYIBPNxMMXZXKXAeWF7Nirl5J
         iqRYUXKqVlYWURqDGMPhDt9P4PR2rjltRO1uE+nmHcJmtzH5LhmcAkzOpQfcGlM5RZBC
         9ilA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=eKl9NY7OTKmyYuPsGrRoNPFWZw8MxP6jB3gNXjnh+E8=;
        b=IcNlOyLIYrZ7qkfhDATs0mPIKOw2i7ZY7RK3IDPsgwbHmXV8JWmVN2HHizr0FyZY2t
         Xi6wJhS/bkSzFDCIyBFxpZiYkHXhgfnIYPvJ+910uYqmT6O3upwUZKi5ohlYQkV0DSWM
         LWwqehuFkCklpp4/rwhsGLMU64pUGLgQ2snW6w/EuWA5TAoRBemel1DgN3j8RZ1J7jwJ
         16y5F1up7JuOFF7nYs3KS6W1a9If5bQFXZO6JU3BeDw8GUcpmWlxb4LVWKYMTeLB1+Ue
         ZXss6X+bz7dikmnnwPNwh2QaWBwiNkbwrVFl9nb4YsD41XXjpVhPOIoPs6OGEKo4gC5R
         8QYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id fx2si18183992ejb.203.2019.07.31.08.46.20
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 668A21596;
	Wed, 31 Jul 2019 08:46:20 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B66633F694;
	Wed, 31 Jul 2019 08:46:17 -0700 (PDT)
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
	Russell King <linux@armlinux.org.uk>
Subject: [PATCH v10 03/22] arm: mm: Add p?d_leaf() definitions
Date: Wed, 31 Jul 2019 16:45:44 +0100
Message-Id: <20190731154603.41797-4-steven.price@arm.com>
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

For arm pmd_large() already exists and does what we want. So simply
provide the generic pmd_leaf() name.

CC: Russell King <linux@armlinux.org.uk>
CC: linux-arm-kernel@lists.infradead.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm/include/asm/pgtable-2level.h | 1 +
 arch/arm/include/asm/pgtable-3level.h | 1 +
 2 files changed, 2 insertions(+)

diff --git a/arch/arm/include/asm/pgtable-2level.h b/arch/arm/include/asm/pgtable-2level.h
index 51beec41d48c..0d3ea35c97fe 100644
--- a/arch/arm/include/asm/pgtable-2level.h
+++ b/arch/arm/include/asm/pgtable-2level.h
@@ -189,6 +189,7 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
 }
 
 #define pmd_large(pmd)		(pmd_val(pmd) & 2)
+#define pmd_leaf(pmd)		(pmd_val(pmd) & 2)
 #define pmd_bad(pmd)		(pmd_val(pmd) & 2)
 #define pmd_present(pmd)	(pmd_val(pmd))
 
diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index 5b18295021a0..ad55ab068dbf 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -134,6 +134,7 @@
 #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
 						 PMD_TYPE_SECT)
 #define pmd_large(pmd)		pmd_sect(pmd)
+#define pmd_leaf(pmd)		pmd_sect(pmd)
 
 #define pud_clear(pudp)			\
 	do {				\
-- 
2.20.1

