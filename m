Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17FB2C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA3612171F
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA3612171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C62A8E0016; Wed, 31 Jul 2019 11:46:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 74BF68E0003; Wed, 31 Jul 2019 11:46:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 639FA8E0016; Wed, 31 Jul 2019 11:46:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 182FB8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:38 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c31so42717847ede.5
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=SeXVsMnk2ItLAq9xssoCnMjuOjZOxOqXJMYOSk/jj2w=;
        b=IdGeCEAqoAzNrLLLwYMFal1YUbYCxL8tcNpA4bn73NjByTOTaqpX1vfmJJO5YZAkHX
         Y2ogAmkHuUsHyinDyCPkGYIazixvdJZRXIEWp79oZf0/M6HMe5mme63w+FeAGQhpYySm
         wsr+u6+7iIgJ7ac2d+Ms6XDPaQ+YXDSf2FP5+zFIAKU+qvaPVqSmNfD7lrKUGfPwr72n
         P/CRGzDnRzD4ztYXgvhHjWkR372y6kgEbZPBnTT3dpyv4Myde81tE3rBlE8B229PnZtG
         RqJ7x/L5a4Dhj0Y3C5aW/Udlxw0ADeKkZCbYtN/TiUJceUBTQCT048cNvEpwNGAd7qMR
         Xpbw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXKtZLhT4tQ1pYC5ok16RjaC+SQ3HZvrS4BP/x3lrSMlbKAcYKS
	5zGASdLxHhWGi/ZEiz7yBAIo60WRL6eyau1adFzwBt1O77iVEY2uRwX8QWs0u0qVY9KTEycw9bV
	lapQUgoxEv0izujPXavNfezr2mzbphRw5n3dwBE3IQFg4cULLn6FRzdA0lHkvhMAcfg==
X-Received: by 2002:a17:906:698e:: with SMTP id i14mr78330219ejr.122.1564587997657;
        Wed, 31 Jul 2019 08:46:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXpZVBxiJHj5TWjOC8qBXtqm1Qcz7Ne41ua4kaWQu0vLIA0yEIOOTIduEy6u0mkVxURE0M
X-Received: by 2002:a17:906:698e:: with SMTP id i14mr78330165ejr.122.1564587996875;
        Wed, 31 Jul 2019 08:46:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564587996; cv=none;
        d=google.com; s=arc-20160816;
        b=M5nShT9Hprkencb8agB1TiHq9XtLN4hzO24VAe7vFi+25ZQYlwHOwCt0Al6eTtU+pe
         Sjb2XVIIVixSUB2uN0Zl6QKl/sMPBAo6QyvXKqojRaVSEfZo/WRnKiXNLW8JtWDVdUxD
         Wd+eKLGe7g9C/lKghl2gBN5/VUWuUp36LVcwfLgzJcH2bWxT2DokkBUhJiEX2SHg8Wz7
         5HnXM7wVYjewOMJuxdj8RZV6GEjAHC2Z+W3wOz1TRUlZ1I3E8j529Hkfts4gGF8kNqEL
         tW1XyAZhwBcX7JB1N6l4CTLgrPeRVV86ddW08D86EU7/wVK+VhxaEyOFCK6f7k3tfvLu
         yWOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=SeXVsMnk2ItLAq9xssoCnMjuOjZOxOqXJMYOSk/jj2w=;
        b=y/dkR07Lpwz+FQSbTIkU5qpEddrNdVwrdpUaESmAiEes9W9qbKJc4sr2qej5QTQf6o
         8r8iFLTSrnWMPu3iSurJr7GOalnNETLh9j6CA9IUokj/uoLmM121blfcPRCwMccMD2C4
         iNTis6C2PVZhzdQoAre9gDZolVe3RuD73MeQHRK0Ifm/rHdz7DiRtqZMBbECGwcV4OLw
         B55ZXLQgsUZT5T/ZTao/elXiLEMTA1reWZXOgy409HlzJTEecvHUrFZ8qstgZaZFcb31
         OIr3D+IhD0lsPR2sAoCQIiGTBnn5rL2l/TkkIGqPwJzl/biCPmIJpZPypiAsoqMugmGT
         wtzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id c28si22591513edb.158.2019.07.31.08.46.36
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 230CC1570;
	Wed, 31 Jul 2019 08:46:36 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 21C233F694;
	Wed, 31 Jul 2019 08:46:33 -0700 (PDT)
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
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	linux-s390@vger.kernel.org
Subject: [PATCH v10 08/22] s390: mm: Add p?d_leaf() definitions
Date: Wed, 31 Jul 2019 16:45:49 +0100
Message-Id: <20190731154603.41797-9-steven.price@arm.com>
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

For s390, pud_large() and pmd_large() are already implemented as static
inline functions. Add a macro to provide the p?d_leaf names for the
generic code to use.

CC: Heiko Carstens <heiko.carstens@de.ibm.com>
CC: Vasily Gorbik <gor@linux.ibm.com>
CC: Christian Borntraeger <borntraeger@de.ibm.com>
CC: linux-s390@vger.kernel.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/s390/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index 9b274fcaacb6..f99a5f546e5e 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -674,6 +674,7 @@ static inline int pud_none(pud_t pud)
 	return pud_val(pud) == _REGION3_ENTRY_EMPTY;
 }
 
+#define pud_leaf	pud_large
 static inline int pud_large(pud_t pud)
 {
 	if ((pud_val(pud) & _REGION_ENTRY_TYPE_MASK) != _REGION_ENTRY_TYPE_R3)
@@ -691,6 +692,7 @@ static inline unsigned long pud_pfn(pud_t pud)
 	return (pud_val(pud) & origin_mask) >> PAGE_SHIFT;
 }
 
+#define pmd_leaf	pmd_large
 static inline int pmd_large(pmd_t pmd)
 {
 	return (pmd_val(pmd) & _SEGMENT_ENTRY_LARGE) != 0;
-- 
2.20.1

