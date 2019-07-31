Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74C6CC433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35221208E3
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35221208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF2E38E000C; Wed, 31 Jul 2019 11:46:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC97E8E0003; Wed, 31 Jul 2019 11:46:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BB8C48E000C; Wed, 31 Jul 2019 11:46:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 702ED8E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:19 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n3so42648233edr.8
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tw4JZILHpRw8yw2ivWns3JMulA885A2eTY+XMl6s8Qw=;
        b=UL6F4GEvIroQmKeM85vjotypHSGDwoH/nNn/ebPO3P9xH/k4hlZzHET/YamAK8Z+Md
         F6gNTca/lkU1/o6YAbNcA0WwPYsF1mNRC/00YrgHJyWXhx7SumBW36Zk7sjLyhuBNOTt
         zoYj3/csYpHyMMi5Gfl/r7s9Y9KmaHrSomIjjAnmWYnViT0wvaFgoISwyGVigW4kLFxQ
         Kwck9N3Ce/C4yTp9C9Fmlo2rIjbqyAKfurihfllNA/AdPQRHy+YZpOAVa4HERz1j+Tyj
         oyVGkB2AmrtB+k7ZJptEwcI4OrZxMw+GwHLoj4Y0L3LLzwN/tgr0flpO9cQ/qQ8eLd+U
         GHAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUB8yK3oqCYEcpWI7hN7sx189VzvW1+cGnLxhu5Lxs4RzQZCXX5
	r66Y9U8UgKcfHtNDpvOOtgcYoQkeRB7x1kOtCz/wkjlYAkr2krbBThTodaIc/nRZu9rzy2dPMYE
	VLReuqpzk9/vA8AOxOqIAOwPQUNYWZ1kgM8r4vuCmXXgZQTaUqMPWIpH0EOEHyQiGKA==
X-Received: by 2002:a05:6402:652:: with SMTP id u18mr107828099edx.85.1564587979062;
        Wed, 31 Jul 2019 08:46:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBetaK+Cj+QuxlfXhNCNjXbciRmw6tmTdX8bGUYWaGxWc3l6SfvOQ/KvWuuQwQRTltn1k9
X-Received: by 2002:a05:6402:652:: with SMTP id u18mr107828032edx.85.1564587978327;
        Wed, 31 Jul 2019 08:46:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564587978; cv=none;
        d=google.com; s=arc-20160816;
        b=AhycmE/PSxojOWmzhUN3UBeNs2kLL7dwPKZ2RzlLN6h64LxtqVQzv3bRMJQ1VBGDs9
         c1oUH11EZdHJLHKXeOvUh8CMNnbhibkXYyqrbX4zmd5gq2PdtONXXVY3W/YyHcT3944x
         4ugK9k3Becay9ycyjkUxbL6WVHLOMGKYpJs/NKMHmJWdFkxBD98pFDxSDdATknyVA6wK
         HRlA06mH2eq5wRqM+PU5LaPugetVWVZtVKP3eQj9azA6EoOyLG3mCri80XcTO7l/QCvg
         nf8921/F3E9NyGbAuG7FuN7FhWURLutRbDdb0noZ4y13wo3xFn4Ud+jLZN/hiuVMxpcg
         Paug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=tw4JZILHpRw8yw2ivWns3JMulA885A2eTY+XMl6s8Qw=;
        b=bdda7FKOvAUgj40SIHjyqfQ4HDBTpJFojipMzNtIfnAHpTJaYiU3gwo1nG+kDv5lXT
         3j/in68WZPX4srSRlXocUY9Ss2nSYr74XdqVFDhip9tDKmAa/XMq8KmGiYjaAP+inKvM
         n8c/e5fQUiiEWVEwU/ZjroqgH5yCTrA8ZO4H88JCGwmehR0tnr6Rng/7NgjJJfD72jMM
         svtHbtppolPZtGIkJRbmqiJ4b+8YpXDX38NgtgBPLSg6RaAlbqKaY+XBP6KZiP4PV3Og
         hrjIbYf2J+ziBFx10t2uZqZ9x/frNT4Ckg/8Zv6+UwqJALOHuxLUkLhTTgF2Hv6Gxqr4
         UvIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b10si19031589ejq.174.2019.07.31.08.46.18
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8040E1576;
	Wed, 31 Jul 2019 08:46:17 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B52053F694;
	Wed, 31 Jul 2019 08:46:14 -0700 (PDT)
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
	Vineet Gupta <vgupta@synopsys.com>,
	linux-snps-arc@lists.infradead.org
Subject: [PATCH v10 02/22] arc: mm: Add p?d_leaf() definitions
Date: Wed, 31 Jul 2019 16:45:43 +0100
Message-Id: <20190731154603.41797-3-steven.price@arm.com>
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
'leaf' entry in the page tables. This information will be provided by the
p?d_leaf() functions/macros.

For arc, we only have two levels, so only pmd_leaf() is needed.

CC: Vineet Gupta <vgupta@synopsys.com>
CC: linux-snps-arc@lists.infradead.org
Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arc/include/asm/pgtable.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtable.h
index 1d87c18a2976..8c425cf796db 100644
--- a/arch/arc/include/asm/pgtable.h
+++ b/arch/arc/include/asm/pgtable.h
@@ -274,6 +274,7 @@ static inline void pmd_set(pmd_t *pmdp, pte_t *ptep)
 #define pmd_none(x)			(!pmd_val(x))
 #define	pmd_bad(x)			((pmd_val(x) & ~PAGE_MASK))
 #define pmd_present(x)			(pmd_val(x))
+#define pmd_leaf(x)			(pmd_val(pmd) & _PAGE_HW_SZ)
 #define pmd_clear(xp)			do { pmd_val(*(xp)) = 0; } while (0)
 
 #define pte_page(pte)		pfn_to_page(pte_pfn(pte))
-- 
2.20.1

