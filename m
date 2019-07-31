Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A617C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 38FF820C01
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 38FF820C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D67798E0012; Wed, 31 Jul 2019 11:46:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3E3F8E0003; Wed, 31 Jul 2019 11:46:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C5E098E0012; Wed, 31 Jul 2019 11:46:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 72BF48E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:28 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f19so42681301edv.16
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ELwmRF22LLX0tCygT2lvRbCbwdd+dUVbxYOXSRLI/y4=;
        b=QZnyZo9UFbXgsZUuYJu96Ctv6r+i94QcsAr3Z/SpXd0H/R8mRgLJbxWFyziOt+8Gux
         ucSA3AiKKWrK83B8Z1m/UjGpIEUeOXeGlLkW51tKgwAXZZSbzuXw8T6EcO2VO827zVkV
         aMQ+COUKmzCiQP+nURttY4IIYVGjno2wipYuB36orQaNE7Dn3Tod8QJbj0j2P64FeRbo
         svPUyAKq781GKvG6XAEOgrmE+UhXGZRoG1N0OI1Lhg5pxH5um3WZ5K7NIK19Ifj4L5p7
         5IxPEDpbElYUUeGTIcA1FzAr5/zogAzh8SjSRawT9ctz1tb3lrMEie1Bteqm9TLpCZ8j
         YqRA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUGOoATd0oC/q6/OcqU849ixxzA+3xCSslllfdMQr4WH4RQEXYs
	2l8vUY0kGAczC8Q18zvn8AAi5J5jhN+/ljdEjGCzFOnZ7QzygeaFXBrljUxbrn5HnpS6g9neSLn
	nkCNwc6VpWKG1ULK/mtFv6ftIF7UaKVfJqe1qG6ZLjuQdr/idEl08fiFKNXfkxzEqsg==
X-Received: by 2002:a17:906:8053:: with SMTP id x19mr94874367ejw.306.1564587988039;
        Wed, 31 Jul 2019 08:46:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxztl0K40e034+kZnO+87+ks4qsR5prlDwtwjS4jS410y421hBotEVMofbcA8ivyE4RrlNL
X-Received: by 2002:a17:906:8053:: with SMTP id x19mr94874315ejw.306.1564587987267;
        Wed, 31 Jul 2019 08:46:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564587987; cv=none;
        d=google.com; s=arc-20160816;
        b=wVMlyz4ukYOxp+mHZRFwWorFDkznTqnqNBIgDE9sHRurM/NWv1o1mMfk47s946Ia+q
         238bMYorI7MIsLluMDxzeEWzon2+49ud9waI019TfxQBN/Lc+qWyciPWzybtDH7cbBIB
         j5/eE/MkI+AXmbUGg4Kk7SBmiJ+v0ofIbZBU2QI++AcTpIsx/DE75H1WJEWP6IHQ+Y/a
         znNT1RWEpZQ4S4zZs+tE/cejJLCZr9j5Q1gofu2R3IMiG/xtHii7re4fmjhE+oF7Pniu
         lVYWaAHdM/pLTwNL3Ho2Y+0uzQHI3AYkDFr7QKsWPNV3/aB5g5RwYMFbV65srvjCP4JG
         8BDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ELwmRF22LLX0tCygT2lvRbCbwdd+dUVbxYOXSRLI/y4=;
        b=K5PMObdGKC38OuqoLIdNAJgKaaXNEdI+6HMcbZZ0hSkbDaNrQBVdJFaewyVrsJivT1
         d9ct5eRJ+2m3HTtutsnP4PreGb5rp2s4ogPGTsJi6v4a+N0IoJRnmlFScu+TD+7MlP9i
         ePtFMn208MJKSMfuNMtgO6ankJmXxiurkWeLhGPZRsQDhiFVIE1QPILv1E47viu47M5i
         kG1+Obd9mNayCuDqVMHOt37Avi2vT8kmvcrLBI+3+XJHQwuTykLx51hRqDDrX+H7vQ9B
         2OgEvPDpMwLv1waQpKsthgiPX8clgEnxD2ger8VhDE7Brn4MHv6c0V7eLH6QW3/dAhEy
         d6UA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id l50si21106871edc.212.2019.07.31.08.46.27
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6D1621570;
	Wed, 31 Jul 2019 08:46:26 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6B6463F694;
	Wed, 31 Jul 2019 08:46:23 -0700 (PDT)
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
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	linux-mips@vger.kernel.org
Subject: [PATCH v10 05/22] mips: mm: Add p?d_leaf() definitions
Date: Wed, 31 Jul 2019 16:45:46 +0100
Message-Id: <20190731154603.41797-6-steven.price@arm.com>
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

If _PAGE_HUGE is defined we can simply look for it. When not defined we
can be confident that there are no leaf pages in existence and fall back
on the generic implementation (added in a later patch) which returns 0.

CC: Ralf Baechle <ralf@linux-mips.org>
CC: Paul Burton <paul.burton@mips.com>
CC: James Hogan <jhogan@kernel.org>
CC: linux-mips@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/mips/include/asm/pgtable.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgtable.h
index 7d27194e3b45..238ca243ad31 100644
--- a/arch/mips/include/asm/pgtable.h
+++ b/arch/mips/include/asm/pgtable.h
@@ -627,6 +627,11 @@ static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
 
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+#ifdef _PAGE_HUGE
+#define pmd_leaf(pmd)	((pmd_val(pmd) & _PAGE_HUGE) != 0)
+#define pud_leaf(pud)	((pud_val(pud) & _PAGE_HUGE) != 0)
+#endif
+
 #define gup_fast_permitted(start, end)	(!cpu_has_dc_aliases)
 
 #include <asm-generic/pgtable.h>
-- 
2.20.1

