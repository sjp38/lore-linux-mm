Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE496B02F3
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 10:53:04 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w12so13295281pfk.1
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 07:53:04 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 29si244030pfq.324.2017.06.15.07.53.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 07:53:03 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [HELP-NEEDED, PATCHv2 0/3] Do not loose dirty bit on THP pages
Date: Thu, 15 Jun 2017 17:52:21 +0300
Message-Id: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi,

Vlastimil noted that pmdp_invalidate() is not atomic and we can loose
dirty and access bits if CPU sets them after pmdp dereference, but
before set_pmd_at().

The bug doesn't lead to user-visible misbehaviour in current kernel, but
fixing this would be critical for future work on THP: both huge-ext4 and THP
swap out rely on proper dirty tracking.

Unfortunately, there's no way to address the issue in a generic way. We need to
fix all architectures that support THP one-by-one.

All architectures that have THP supported have to provide atomic
pmdp_invalidate() that returns previous value.

If generic implementation of pmdp_invalidate() is used, architecture needs to
provide atomic pmdp_estabish().

pmdp_estabish() is not used out-side generic implementation of
pmdp_invalidate() so far, but I think this can change in the future.

I've fixed the issue for x86, but I need help with the rest.

So far THP is supported on 7 architectures, beyond x86:

 - arc;
 - arm;
 - arm64;
 - mips;
 - power;
 - s390;
 - sparc;

Please, help me with them.

v2:
 - Introduce pmdp_estabish(), instead of pmdp_mknonpresent();
 - Change pmdp_invalidate() to return previous value of the pmd;

 arch/x86/include/asm/pgtable-3level.h | 18 ++++++++++++++++++
 arch/x86/include/asm/pgtable.h        | 14 ++++++++++++++
 fs/proc/task_mmu.c                    |  8 ++++----
 include/asm-generic/pgtable.h         |  2 +-
 mm/huge_memory.c                      | 29 ++++++++++++-----------------
 mm/pgtable-generic.c                  |  9 +++++----
 6 files changed, 54 insertions(+), 26 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
