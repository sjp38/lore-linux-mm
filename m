Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id CCD366B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:12:12 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id m67so9836892qkf.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 01:12:12 -0800 (PST)
Received: from mail-qk0-x22b.google.com (mail-qk0-x22b.google.com. [2607:f8b0:400d:c09::22b])
        by mx.google.com with ESMTPS id w37si29678595qtb.187.2016.12.14.01.12.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 01:12:12 -0800 (PST)
Received: by mail-qk0-x22b.google.com with SMTP id q130so12673958qke.1
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 01:12:11 -0800 (PST)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH 0/2] arm64: numa: fix spurious BUG() on NOMAP regions
Date: Wed, 14 Dec 2016 09:11:45 +0000
Message-Id: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: catalin.marinas@arm.com, akpm@linux-foundation.org, hanjun.guo@linaro.org, xieyisheng1@huawei.com, rrichter@cavium.com, james.morse@arm.com, Ard Biesheuvel <ard.biesheuvel@linaro.org>

This fixes the issue reported by Robert Richter where the fact that
the node id of struct pages covered by NOMAP regions is not initialized,
triggering a VM_BUG_ON() in the mm code.

I know that this approach is the least preferred option by Robert, but it
has been used successfully in the downstream Linaro Enterprise kernel,
running on HiSilicon D05, which suffered from the same issue as Cavium
ThunderX where it was originally reported.

Given that the other proposed solutions either fail to solve the issue
completely, or cause regressions in other code (hibernate), I think this
issue is appropriate for merging now, and backported to -stable. If there
are performance concerns, we can try to improve on this solution, which
could include reverting patch #2 altogether, for all I care.

Patch #1 fixes a bug in the generic mm code where a struct page is
dereferenced before pfn_valid() is called. This should probably go to
stable regardless of where the arm64 discussion goes.

Patch #2 enables CONFIG_HOLES_IN_ZONE for arm64 numa, causing the kernel
to no longer assume that all pages in a zone have valid struct pages
associated with them.

Ard Biesheuvel (2):
  mm: don't dereference struct page fields of invalid pages
  arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA

 arch/arm64/Kconfig | 4 ++++
 mm/page_alloc.c    | 6 +++---
 2 files changed, 7 insertions(+), 3 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
