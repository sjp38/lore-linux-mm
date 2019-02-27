Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91562C00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4A86020842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:06:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4A86020842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EB3AD8E0004; Wed, 27 Feb 2019 12:06:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E88778E0001; Wed, 27 Feb 2019 12:06:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D504F8E0004; Wed, 27 Feb 2019 12:06:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 765908E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:06:31 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m25so3376890edd.6
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:06:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=2L5onIYhhiFDktlONdcZdravT2mZ96pNsto7cia4fvA=;
        b=hMPeKCMAxY66W0R+jyQ5c49OPpMQ3F7dIpSaYdJOAD0l07JdwhrpqJ9cKdP9Ly+5nR
         b4wAU+i+EytQhZKZ6lhlyhJN+EcDR7RovsA8xmu99qyW7Devi5VvG94UiA2amUc3AiFm
         eDM5M87GiAhq+eGHBrXFjbRrnAxM6mYu2OtWELsm43HStYb3zVa+/zouwd2M5zCCFn9F
         vgkcMjVJQVEl9AXWH99jAC1d2EEZQLD1ZBgi0n2HFT2784XV7GycXhZmHIp6lXHE7ViS
         b8VawZZ4W9iPLvT8aCmHed/DXZtJvV1bm2aIKVuews3/t+L52gzx1nGUxEw8ETbS1xjD
         bpQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuarKPyVUxzeyOKtqibkx22UNrWy2VhJDYxGB93KDVsHXHFTftuD
	wXBe48FdENiNt43F3Hi+EP5QDRX5Z70wrZz2GVvIvi2vD7qhqO4Q2qE9RmRViG1oxVfefsgu0eC
	n6R0PgtrCoBB5Cw63r4ejs0wsn8N/lBK3z4lgklJ1gSHSFuU4KmUX7i/etuMIqhPyWg==
X-Received: by 2002:a17:906:7b0d:: with SMTP id e13mr2178202ejo.165.1551287190924;
        Wed, 27 Feb 2019 09:06:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZGc61lIPh+FSTNTs2wJA4Onv4PfQ/GVg8K17g3y0CSTuaMSxsPG2t3QovddOMGo2XKpDOu
X-Received: by 2002:a17:906:7b0d:: with SMTP id e13mr2178119ejo.165.1551287189341;
        Wed, 27 Feb 2019 09:06:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287189; cv=none;
        d=google.com; s=arc-20160816;
        b=Tk9RB1YbHfVaymWXDVUXfXfTgoJey09kjjb9ZdlZ8nbDAkAhWd3SJmlRbFQnvjDpNE
         IDskBaR3qSivFDJA8MBLK6svoilYJUeeub7G+WvgSrmmxZd1lD5MZSzcScJkgiLS6MvQ
         zBlMyhtPyHpK2q2V43AkSEkLCIxIPzNW7u2LUBnvLoeScrJh6KlYrEykm+qp+SdrknlG
         dUX2CkCbabpFV2zL8fSSUtG7erPvjuxcWtRgDPjcYsQzfpu+yvVF3eci4CqQnNk0CRGh
         7xu/RL6Jw9XBIUodkmErKxn+s3cadNvwUNXCnIAuWiT1EGJpIPUWUBl/OGQY3Hdac4zL
         JBfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=2L5onIYhhiFDktlONdcZdravT2mZ96pNsto7cia4fvA=;
        b=gbrFt+kHDPDRjOQASWCHeysP0mEcNZq8kbMtJjfnOva/lwbUVgxcNAP5UuYxDukX6X
         fLRn3s/pj0S8pcMW3+R2JTYLJUzYK4r7NT2M7Qm3zjBE8LJGiibyO+1m6MPsVtcTCa+m
         b/sPNms1hCRuA5woUlPNqpgCLNFyI7X+apPMR2LI9mSJEoUfqaUksZwib+xfoEXoVs36
         2/IC1TW2N+VfzyIwTgwZtHf6ZRbd4aYazkc7ir56viebXVGcfP1pCArJ8HtrwNtHjq6X
         JXNXYtiP9AOYZshW1KnCj0whNVn+iDIpqKcRciEW+82HoX6WGlVFRBfL52a6ILU69GR7
         v6Vg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z8si3396349edd.397.2019.02.27.09.06.28
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:06:29 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1BEFFA78;
	Wed, 27 Feb 2019 09:06:28 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D3EBB3F738;
	Wed, 27 Feb 2019 09:06:24 -0800 (PST)
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
Subject: [PATCH v3 00/34] Convert x86 & arm64 to use generic page walk
Date: Wed, 27 Feb 2019 17:05:34 +0000
Message-Id: <20190227170608.27963-1-steven.price@arm.com>
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

To enable a generic page table walker to walk the unusual mappings of
the kernel we need to implement a set of functions which let us know
when the walker has reached the leaf entry. Since arm, powerpc, s390,
sparc and x86 all have p?d_large macros lets standardise on that and
implement those that are missing.

Potentially future changes could unify the implementations of the
debugfs walkers further, moving the common functionality into common
code. This would require a common way of handling the effective
permissions (currently implemented only for x86) along with a per-arch
way of formatting the page table information for debugfs. One
immediate benefit would be getting the KASAN speed up optimisation in
arm64 (and other arches) which is currently only implemented for x86.

Changes since v2:
 * Rather than attemping to provide generic macros, actually implement
   p?d_large() for each architecture.

Changes since v1:
 * Added p4d_large() macro
 * Comments to explain p?d_large() macro semantics
 * Expanded comment for pte_hole() callback to explain mapping between
   depth and P?D
 * Handle folded page tables at all levels, so depth from pte_hole()
   ignores folding at any level (see real_depth() function in
   mm/pagewalk.c)

Steven Price (34):
  alpha: mm: Add p?d_large() definitions
  arc: mm: Add p?d_large() definitions
  arm: mm: Add p?d_large() definitions
  arm64: mm: Add p?d_large() definitions
  c6x: mm: Add p?d_large() definitions
  csky: mm: Add p?d_large() definitions
  hexagon: mm: Add p?d_large() definitions
  ia64: mm: Add p?d_large() definitions
  m68k: mm: Add p?d_large() definitions
  microblaze: mm: Add p?d_large() definitions
  mips: mm: Add p?d_large() definitions
  nds32: mm: Add p?d_large() definitions
  nios2: mm: Add p?d_large() definitions
  openrisc: mm: Add p?d_large() definitions
  parisc: mm: Add p?d_large() definitions
  powerpc: mm: Add p?d_large() definitions
  riscv: mm: Add p?d_large() definitions
  s390: mm: Add p?d_large() definitions
  sh: mm: Add p?d_large() definitions
  sparc: mm: Add p?d_large() definitions
  um: mm: Add p?d_large() definitions
  unicore32: mm: Add p?d_large() definitions
  xtensa: mm: Add p?d_large() definitions
  mm: Add generic p?d_large() macros
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

 arch/alpha/include/asm/pgtable.h              |   2 +
 arch/arc/include/asm/pgtable.h                |   1 +
 arch/arm/include/asm/pgtable-2level.h         |   1 +
 arch/arm/include/asm/pgtable-3level.h         |   1 +
 arch/arm64/include/asm/pgtable.h              |   2 +
 arch/arm64/mm/dump.c                          | 108 +++---
 arch/c6x/include/asm/pgtable.h                |   2 +
 arch/csky/include/asm/pgtable.h               |   2 +
 arch/hexagon/include/asm/pgtable.h            |   5 +
 arch/ia64/include/asm/pgtable.h               |   3 +
 arch/m68k/include/asm/mcf_pgtable.h           |   2 +
 arch/m68k/include/asm/motorola_pgtable.h      |   2 +
 arch/m68k/include/asm/pgtable_no.h            |   1 +
 arch/m68k/include/asm/sun3_pgtable.h          |   2 +
 arch/microblaze/include/asm/pgtable.h         |   2 +
 arch/mips/include/asm/pgtable-32.h            |   5 +
 arch/mips/include/asm/pgtable-64.h            |  15 +
 arch/mips/include/asm/pgtable-bits.h          |   2 +-
 arch/nds32/include/asm/pgtable.h              |   2 +
 arch/nios2/include/asm/pgtable.h              |   5 +
 arch/openrisc/include/asm/pgtable.h           |   1 +
 arch/parisc/include/asm/pgtable.h             |   3 +
 arch/powerpc/include/asm/book3s/32/pgtable.h  |   1 +
 arch/powerpc/include/asm/book3s/64/pgtable.h  |  27 +-
 arch/powerpc/include/asm/nohash/32/pgtable.h  |   1 +
 .../include/asm/nohash/64/pgtable-4k.h        |   1 +
 arch/powerpc/kvm/book3s_64_mmu_radix.c        |  12 +-
 arch/riscv/include/asm/pgtable-64.h           |   6 +
 arch/riscv/include/asm/pgtable.h              |   6 +
 arch/s390/include/asm/pgtable.h               |  10 +
 arch/sh/include/asm/pgtable-3level.h          |   1 +
 arch/sh/include/asm/pgtable_32.h              |   1 +
 arch/sh/include/asm/pgtable_64.h              |   1 +
 arch/sparc/include/asm/pgtable_32.h           |  10 +
 arch/sparc/include/asm/pgtable_64.h           |   1 +
 arch/um/include/asm/pgtable-3level.h          |   1 +
 arch/um/include/asm/pgtable.h                 |   1 +
 arch/unicore32/include/asm/pgtable.h          |   1 +
 arch/x86/include/asm/pgtable.h                |  26 +-
 arch/x86/mm/debug_pagetables.c                |   8 +-
 arch/x86/mm/dump_pagetables.c                 | 342 +++++++++---------
 arch/x86/platform/efi/efi_32.c                |   2 +-
 arch/x86/platform/efi/efi_64.c                |   4 +-
 arch/xtensa/include/asm/pgtable.h             |   1 +
 fs/proc/task_mmu.c                            |   4 +-
 include/asm-generic/4level-fixup.h            |   1 +
 include/asm-generic/5level-fixup.h            |   1 +
 include/asm-generic/pgtable-nop4d-hack.h      |   1 +
 include/asm-generic/pgtable-nop4d.h           |   1 +
 include/asm-generic/pgtable-nopmd.h           |   1 +
 include/asm-generic/pgtable-nopud.h           |   1 +
 include/linux/mm.h                            |  26 +-
 mm/hmm.c                                      |   2 +-
 mm/migrate.c                                  |   1 +
 mm/mincore.c                                  |   1 +
 mm/pagewalk.c                                 | 107 ++++--
 56 files changed, 489 insertions(+), 291 deletions(-)

-- 
2.20.1

