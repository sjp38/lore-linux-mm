Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5FE52C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2BD282086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2BD282086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A744D8E0072; Thu, 21 Feb 2019 06:35:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A23ED8E0002; Thu, 21 Feb 2019 06:35:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8ED3F8E0072; Thu, 21 Feb 2019 06:35:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3322C8E0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:35:19 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id x47so11200166eda.8
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:35:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=f2WGobCerBgAlzu36GkyM1BxiAebPg7OT9UORj51FJk=;
        b=Xo1AWh22I07l/QtzDDba9flTyUeFV0JRBrQSoq4/IceuggLxi4OcuinNsitYHLCWdo
         xxuGtUHLP6ONIJwB0UDx84kH5gk3ZgSI6vDuiM1xQxXD+5JqwWrtqRk+g9HvzRDibMX5
         Won1jzo5J9Jj0SAAJYH+Rt8lomMan3ZNkk4gsafoacCQ5mt/CfwNDKSbIKCqJeKroIz1
         ssbWdsv+kjhogT2hcBM1KOczibt9fxLYHLntjhDzThYzLApLADc0nRoH2iG+RZfTeJWi
         ylr6vMvFVT8Mup57mrFlcRhG7+YiWb1RRPTqvOf4/lqxf2stgbuo2Kez9qx4/MlF7gb/
         0xTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuZCZaKAESXie0JW68JXBxraD/wIvxAmB/0VOQtc/HDgjBqPVxC0
	AFDLNVwJYlmvZkpAZzDqfEO1/NNBdiWyNFJIxtjWjr3y0jhm/gg4fsQTHy6nVM5rzdNQq4Gkikf
	ghI6dWUljWeOUNMgbk8Xhlfw7HAPF8uAKA54P57gafoKbjn97GYvQhAqo+vJXVYrnWw==
X-Received: by 2002:a50:cac8:: with SMTP id f8mr31132004edi.212.1550748918660;
        Thu, 21 Feb 2019 03:35:18 -0800 (PST)
X-Google-Smtp-Source: AHgI3IasXw099u7f2BTWzXNk1Kd9NPdzQDICjFwozLQnYDjUPNucX6WYw0JKSqAYzIS0WVE99RCe
X-Received: by 2002:a50:cac8:: with SMTP id f8mr31131924edi.212.1550748917233;
        Thu, 21 Feb 2019 03:35:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550748917; cv=none;
        d=google.com; s=arc-20160816;
        b=oFufJLRC6LIoJH35LqWmHEeCC9tO9fnT4YEvpoVseRYYGoNz/w5x3WjVN2b3DD5XMZ
         Pc6g0klZmfvpM0jLfCvxr7azf7vT/tATO22QgVH0bMSCRc+cMCksGo9OAM+vH1cU1b52
         Xpa2nzLhxtag2kz6WBab9ogP6tPfei/OnEDzPB2FD+9aRJ1v+ypXDBRSqXB/8a/W6+QS
         uwPOjBXXlRyzMIbf5g9vkceYzYjcC0I7jTUF8AVmHXHZCOUOpCVwGeZC9+cyr2KC6PiL
         7j4pldNpibaR6zSIhyZ3nx49UVjq48zUv4i4JzPrkriR2M0AnAR48v+3v9CvikkBV2CI
         QIQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=f2WGobCerBgAlzu36GkyM1BxiAebPg7OT9UORj51FJk=;
        b=p4f7Yv9EesTf41ZfzAzJCdXQeyVLLiGDDI3QeWMcIPoL1AfabCWr9/xyICc5f8+oRR
         QLZ2KgMazuABP128YumqSLddBIZzRkBjMEEby/eOoN1wcwAG6vIjNSjY913mU7ptJmip
         3OmAu+wEpMB9Bj66IEhERbLjXJlUDFWwpOC6vNfHrSGGcf0nmbN/9BqXjVxKE283FZyB
         IPFqxy/CQVA4lKIOWxfxKKIbn/B6Ulzaz6bwU8kHASZqPhSVNkt48tqy9+2sfUVQ8RMp
         FU2Nhw6dPHZaw4Zl2Dt7WZ8DcZIQfgvrrUECZGT7c/kRCTVHtdvt9TEBw/FAe63pY+H1
         7jwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q28si1851507edc.426.2019.02.21.03.35.16
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 03:35:17 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 97F8180D;
	Thu, 21 Feb 2019 03:35:15 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 135B73F5C1;
	Thu, 21 Feb 2019 03:35:11 -0800 (PST)
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
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: [PATCH v2 00/13] Convert x86 & arm64 to use generic page walk
Date: Thu, 21 Feb 2019 11:34:49 +0000
Message-Id: <20190221113502.54153-1-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Most architectures current have a debugfs file for dumping the kernel
page tables. Currently each architecture has to implement custom
functions for walking the page tables because the generic
walk_page_range() function is unable to walk the page tables used by the
kernel.

This series extends the capabilities of walk_page_range() so that it can
deal with the page tables of the kernel (which have no VMAs and can
contain larger huge pages than exist for user space). x86 and arm64 are
then converted to make use of walk_page_range() removing the custom page
table walkers.

Potentially future changes could unify the implementations of the
debugfs walkers further, moving the common functionality into common
code. This would require a common way of handling the effective
permissions (currently implemented only for x86) along with a per-arch
way of formatting the page table information for debugfs. One
immediate benefit would be getting the KASAN speed up optimisation in
arm64 (and other arches) which is currently only implemented for x86.

Changes since v1:
 * Added p4d_large() macro
 * Comments to explain p?d_large() macro semantics
 * Expanded comment for pte_hole() callback to explain mapping between
   depth and P?D
 * Handle folded page tables at all levels, so depth from pte_hole()
   ignores folding at any level (see real_depth() function in
   mm/pagewalk.c)

James Morse (2):
  arm64: mm: Add p?d_large() definitions
  mm: Add generic p?d_large() macros

Steven Price (11):
  x86/mm: Add p?d_large() definitions
  mm: pagewalk: Add p4d_entry() and pgd_entry()
  mm: pagewalk: Allow walking without vma
  mm: pagewalk: Add 'depth' parameter to pte_hole
  mm: pagewalk: Add test_p?d callbacks
  arm64: mm: Convert mm/dump.c to use walk_page_range()
  x86/mm: Point to struct seq_file from struct pg_state
  x86/mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
  x86/mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
  x86/mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
  x86: mm: Convert dump_pagetables to use walk_page_range

 arch/arm64/include/asm/pgtable.h |   2 +
 arch/arm64/mm/dump.c             | 108 +++++-----
 arch/x86/include/asm/pgtable.h   |   8 +-
 arch/x86/mm/debug_pagetables.c   |   8 +-
 arch/x86/mm/dump_pagetables.c    | 342 ++++++++++++++++---------------
 arch/x86/platform/efi/efi_32.c   |   2 +-
 arch/x86/platform/efi/efi_64.c   |   4 +-
 fs/proc/task_mmu.c               |   4 +-
 include/asm-generic/pgtable.h    |  19 ++
 include/linux/mm.h               |  26 ++-
 mm/hmm.c                         |   2 +-
 mm/migrate.c                     |   1 +
 mm/mincore.c                     |   1 +
 mm/pagewalk.c                    | 107 +++++++---
 14 files changed, 375 insertions(+), 259 deletions(-)

-- 
2.20.1

