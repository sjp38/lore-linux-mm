Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A18E5C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6ADEE20842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6ADEE20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00B9A8E001A; Wed, 27 Feb 2019 12:08:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED9C68E0001; Wed, 27 Feb 2019 12:07:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9DB98E001A; Wed, 27 Feb 2019 12:07:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1AE8E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:07:59 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id h16so7211992edq.16
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:07:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=x+mImCKjHMivjMCtyHQ8sHzcBk8CcZE99nWra+GnYCo=;
        b=pF+dLW1MtiSNgSjQJ+Go8iIWZATFMEuVtJWlR5FxGXXx61a2QLQzUKC2FR0VuO/P3y
         ooRODo0ahH+q417lA4Yk16Tpx54PPdpWeLIWeUxdVz+HMG3oV/E6XP0w9Zz4DHt8mIn1
         mG4Uxo+Dcx11SEtyZnqp65z9HgKkYjgG5k3yYDgzRcC6+4G3u3G31Fr3VUkh6w5RNCx3
         jxgDzlkMPQh9yDXTKp6HkPCt7lH7knYnv3iLiWCryPYivA7f30tz3orNNbaPahLFAVJH
         q5FWDX5XprzSFTZTPTPp6sFonHzO/MkUFFeuX+Vyu8tyNeYrEVZu6Ba3Co9Z6hLNHgLJ
         Z+YQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuYMEZcGYh2F8ZlhGueZBVYtxgA0SONbvjkG0NEYXwzvHVRfn8hD
	tswZ8741JPcwDtmizMPLSSEZCOUKHUOf19FA1jl7OwkSkZxtQXLdQ30XM0L18yZ6aDgbPjSxOz/
	34G0avSinhXx7yJDEs7aoX6O1l8id8o/xKS+eyZ4c/mmJzLu4yPiiT40vD5Epk4NnLw==
X-Received: by 2002:a05:6402:6d7:: with SMTP id n23mr3170371edy.233.1551287278985;
        Wed, 27 Feb 2019 09:07:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IavP+mxnwfhAYmqjsRPF9yTabQRcIEaKt+oyjH6j1n21cgu5STjkg0gle6Is9WAKpFI+HYJ
X-Received: by 2002:a05:6402:6d7:: with SMTP id n23mr3170315edy.233.1551287278040;
        Wed, 27 Feb 2019 09:07:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287278; cv=none;
        d=google.com; s=arc-20160816;
        b=QC/7TGBdv+ma0rdw2SJbQgydYxmzemwr6Hmcg6tqcOTIB/DxzSJ7TTYCY5M/lo5wL8
         YpopFB/C9E1ioVaAU6qAGSjMmh3cjUH/APikIpFoeSz5YY4HSDivJpgFvfQ4ZJ8Xg/6l
         J+CP4GYmH5yzb8FP6IjqeA6b9dKCtnkuNYzlU4p+jqCL3SeQuuDHyhCM7KVw+XJSUkW5
         XrKhSigJgMGfDCczvV3ncvISeY5XEC9nUo6msFJVu22oYjZfmyOk+thQG3aZjWHjq9QK
         BTmC7dn4yT8rjyCCrjPsQg4KtrIx+m79tP7h5ptVx6pYSB98NX0krVrViKk0Sqskdzpz
         1WFg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=x+mImCKjHMivjMCtyHQ8sHzcBk8CcZE99nWra+GnYCo=;
        b=as3IMsCvtwK55viWIHU3WHT/y+Fr6angBjdjeczZAN1OsQwpwjsOJYQkR34C4vf8Rn
         TyaNZHiZ2NPbfUi2O4qSzj8YBKzByWbKSJ/aUR4OxdRtEfI7FPotfVRrX+uPYOOylScu
         HuPN48XIHbk3OYRWjNPjBAQYibB16/DaVEj6SbPlJZXF8TqxG5/7Li7WjdV5ijbp53Ck
         M8YvV4tlieDEQjVcyAsinA9RBpuClVfSq33DbjgZSamy3LhMMYp7YKGt4yMNaiv4oakZ
         M9a4VwKozg6/gXO16Zets6qLFDPX9A/17nWiwTJfkOOsZBfjphfG0KwY6brkr2+PnfUw
         ap5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k56si622336edb.378.2019.02.27.09.07.57
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:07:58 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1C63A19BF;
	Wed, 27 Feb 2019 09:07:57 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6AFCE3F738;
	Wed, 27 Feb 2019 09:07:53 -0800 (PST)
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
	Chris Zankel <chris@zankel.net>,
	Max Filippov <jcmvbkbc@gmail.com>,
	linux-xtensa@linux-xtensa.org
Subject: [PATCH v3 23/34] xtensa: mm: Add p?d_large() definitions
Date: Wed, 27 Feb 2019 17:05:57 +0000
Message-Id: <20190227170608.27963-24-steven.price@arm.com>
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

For xtensa, we don't support large pages, so add a stub returning 0.

CC: Chris Zankel <chris@zankel.net>
CC: Max Filippov <jcmvbkbc@gmail.com>
CC: linux-xtensa@linux-xtensa.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/xtensa/include/asm/pgtable.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/xtensa/include/asm/pgtable.h b/arch/xtensa/include/asm/pgtable.h
index 29cfe421cf41..60c3e86b9782 100644
--- a/arch/xtensa/include/asm/pgtable.h
+++ b/arch/xtensa/include/asm/pgtable.h
@@ -266,6 +266,7 @@ static inline void pgtable_cache_init(void) { }
 #define pmd_none(pmd)	 (!pmd_val(pmd))
 #define pmd_present(pmd) (pmd_val(pmd) & PAGE_MASK)
 #define pmd_bad(pmd)	 (pmd_val(pmd) & ~PAGE_MASK)
+#define pmd_large(pmd)	 (0)
 #define pmd_clear(pmdp)	 do { set_pmd(pmdp, __pmd(0)); } while (0)
 
 static inline int pte_write(pte_t pte) { return pte_val(pte) & _PAGE_WRITABLE; }
-- 
2.20.1

