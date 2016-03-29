Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id B5CFE6B0260
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 21:13:16 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id n5so1094217pfn.2
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 18:13:16 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 24si19135727pfn.204.2016.03.28.18.13.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 18:13:14 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [RFC PATCH 0/2] hugetlb: If PMD sharing is possible, align to PUD_SIZE
Date: Mon, 28 Mar 2016 18:12:48 -0700
Message-Id: <1459213970-17957-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org
Cc: Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steve Capper <steve.capper@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

PMD sharing for hugetlb mappings has been present for quite some time.  
However, specific conditions must be met for mappings to be shared.  
One of those conditions is that the mapping must include all pages that 
can be mapped by a PUD.  To help facilitate this, the mapping should be
PUD_SIZE aligned.  The only way for a user to get PUD_SIZE alignment is
to pass an address to mmap() or shmat().  If the user does not pass an 
address the mapping will be huge page size aligned.

To better utilize huge PMD sharing, attempt to PUD_SIZE align mappings
if the following conditions are met:
- Address passed to mmap or shmat is NULL
- The mapping is flaged as shared
- The mapping is at least PUD_SIZE in length
If a PUD_SIZE aligned mapping can not be created, then fall back to a
huge page size mapping.

Currently, only arm64 and x86 support PMD sharing.  x86 has 
HAVE_ARCH_HUGETLB_UNMAPPED_AREA (where code changes are made).  arm64
uses the architecture independent code.

Mike Kravetz (2):
  mm/hugetlbfs: Attempt PUD_SIZE mapping alignment if PMD sharing
    enabled
  x86/hugetlb: Attempt PUD_SIZE mapping alignment if PMD sharing enabled

 arch/x86/mm/hugetlbpage.c | 64 ++++++++++++++++++++++++++++++++++++++++++++---
 fs/hugetlbfs/inode.c      | 29 +++++++++++++++++++--
 2 files changed, 88 insertions(+), 5 deletions(-)

-- 
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
