Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 401CFC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEF8B214DA
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:46:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEF8B214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 773F08E0009; Wed, 31 Jul 2019 11:46:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 723B68E0003; Wed, 31 Jul 2019 11:46:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5EC338E0009; Wed, 31 Jul 2019 11:46:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F5818E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:46:14 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e9so31541268edv.18
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:46:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=5EMRGxHMwDlaNpG9vkGFjI4/ReWhISH2O22zorNe8OY=;
        b=i8dJBwDPmq7shklN9MjQeC9PO1Xp7CBZ6cbUjghHDSJmtDoavB+Sd0iWMKutMpxl/g
         T3YbLsTMqp+5ExbCkVMxMKArVRJTr32XrF5hSx3/BWrDVxwDe2vvqEZasA+g44L5RHNW
         g3iMCkZpLE5OraP8ESpM5frW5wow+h3GwHB6tCST5VVcS9s+Gh7Nbo2Mi5c800ZAHZKJ
         SiM+i0K+gnwYjQVnr3R8bhh/a1/CZpvFr0d56B5a45LYNPf6xrzRH1L2Fxhoj29INjpd
         yvMnYcw1Kh+bShxhhV6UmvtTdnPCj1tnT1jQwhksqvNC3wg3Mh9Eq/oa2J7rz5iNaeSm
         PiWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAW4HWcL9xBpcZ/Lviq7+A3eBVnsk56F3aiN4NBOmU4F1F6W439Q
	t8I0ujI8Au8ACy6uQb5yNPZ7XoxzmFaQ2GVRLEej/VqAZoYCd8KRDQFnqP2Bjt5vTwfR/4q8W0D
	plDO/ThxMra6AjZSr7xMNCnSN0w81aQW7NgAEmyCI5HJZPsL2gRvndoUYf1qaf0XWHQ==
X-Received: by 2002:a50:9468:: with SMTP id q37mr106685184eda.163.1564587973562;
        Wed, 31 Jul 2019 08:46:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxzvJr+FicGom0R/EKMWGEeuPnSbYsrdmdiB81qGw8uj3CB5TeO/MlwBxlPbqEKD0OG3ZIP
X-Received: by 2002:a50:9468:: with SMTP id q37mr106685094eda.163.1564587972521;
        Wed, 31 Jul 2019 08:46:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564587972; cv=none;
        d=google.com; s=arc-20160816;
        b=KSRUI7sPkqE/u0fxg0WWetOHqX95ZL/7falRQMuKqOtMJ69VNZsbL7o6BGSbdAWZZ/
         hFjjRiSFcX3fV2uoLyP3boiXnewyTFO4R9d7paJGpW087G8PvbdL5f1B07gQiK3ntrAW
         GsgpLEiVGW2EsbTdPVrtQuRmqwmLUOWCkfCmu9C78eJxlZoxJZyCk722EK34aB2l96kr
         JuFb5BjH9Wpn6AzhMFHWzAoPjzoyAX5jZ7IZGwCFplnH2c22JHLpmDodJ3Ro7R24mFn4
         npfG/YRrVp3LFFnZCrs3ebrYivo8uoHM/FAgAw1tFZUPaGzmGFTqqySsTkIeAPLOsjXl
         CPBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=5EMRGxHMwDlaNpG9vkGFjI4/ReWhISH2O22zorNe8OY=;
        b=QyYuBLK+Qoz9Fn+lO4BbcV553ldCOEYmQvbnv4wwSAmJSwX30dd9c+0oM5yVl0HbTO
         ahhSXZ0fsZCgcQp73+J+zYOFdmHkdDmVvWWVTMFC7flGIROo1hmY81SFBi0eYIHWPMKK
         iglz5Wr0Z1lq1lOaNk4Maq8jq6ghGZY91EO4OP9wG2Ws1eVaX7LuRvxQkN/2N22+jN+D
         Gwt2+PHXnXrde4WhOp3Afm72Qcx1EmKA23IGDZDrE7FK8mVhRTPgsmIg7IHAD95eTV+f
         r/15qJKXrxzebfFfj9uNDTu0219LDFPxvUGopcbi60LzDnEJGwzOa/cph/GSgCfjY8NO
         ggXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id d33si22027436edb.194.2019.07.31.08.46.12
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 96268344;
	Wed, 31 Jul 2019 08:46:11 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0A2D43F694;
	Wed, 31 Jul 2019 08:46:08 -0700 (PDT)
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
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v10 00/22] Generic page walk and ptdump
Date: Wed, 31 Jul 2019 16:45:41 +0100
Message-Id: <20190731154603.41797-1-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a slight reworking and extension of my previous patch set
(Convert x86 & arm64 to use generic page walk), but I've continued the
version numbering as most of the changes are the same. In particular
this series ends with a generic PTDUMP implemention for arm64 and x86.

Many architectures current have a debugfs file for dumping the kernel
page tables. Currently each architecture has to implement custom
functions for this because the details of walking the page tables used
by the kernel are different between architectures.

This series extends the capabilities of walk_page_range() so that it can
deal with the page tables of the kernel (which have no VMAs and can
contain larger huge pages than exist for user space). A generic PTDUMP
implementation is the implemented making use of the new functionality of
walk_page_range() and finally arm64 and x86 are switch to using it,
removing the custom table walkers.

To enable a generic page table walker to walk the unusual mappings of
the kernel we need to implement a set of functions which let us know
when the walker has reached the leaf entry. After a suggestion from Will
Deacon I've chosen the name p?d_leaf() as this (hopefully) describes
the purpose (and is a new name so has no historic baggage). Some
architectures have p?d_large macros but this is easily confused with
"large pages".

Mostly this is a clean up and there should be very little functional
change. The exceptions are:

* x86 PTDUMP debugfs output no longer display pages which aren't
  present (patch 14).

* arm64 has the ability to efficiently process KASAN pages (which
  previously only x86 implemented). This means that the combination of
  KASAN and DEBUG_WX is now useable.

Also available as a git tree:
git://linux-arm.org/linux-sp.git walk_page_range/v10

Changes since v9:
https://lore.kernel.org/lkml/20190722154210.42799-1-steven.price@arm.com/
 * Moved generic macros to first page in the series and explained the
   macro naming in the commit message.
 * mips: Moved macros to pgtable.h as they are now valid for both 32 and 64
   bit
 * x86: Dropped patch which changed the debugfs output for x86, instead
   we have...
 * new patch adding 'depth' parameter to pte_hole. This is used to
   provide the necessary information to output lines for 'holes' in the
   debugfs files
 * new patch changing arm64 debugfs output to include holes to match x86
 * generic ptdump KASAN handling has been simplified and now works with
   CONFIG_DEBUG_VIRTUAL.

Changes since v8:
https://lore.kernel.org/lkml/20190403141627.11664-1-steven.price@arm.com/
 * Rename from p?d_large() to p?d_leaf()
 * Dropped patches migrating arm64/x86 custom walkers to
   walk_page_range() in favour of adding a generic PTDUMP implementation
   and migrating arm64/x86 to that instead.
 * Rebased to v5.3-rc1

Steven Price (22):
  mm: Add generic p?d_leaf() macros
  arc: mm: Add p?d_leaf() definitions
  arm: mm: Add p?d_leaf() definitions
  arm64: mm: Add p?d_leaf() definitions
  mips: mm: Add p?d_leaf() definitions
  powerpc: mm: Add p?d_leaf() definitions
  riscv: mm: Add p?d_leaf() definitions
  s390: mm: Add p?d_leaf() definitions
  sparc: mm: Add p?d_leaf() definitions
  x86: mm: Add p?d_leaf() definitions
  mm: pagewalk: Add p4d_entry() and pgd_entry()
  mm: pagewalk: Allow walking without vma
  mm: pagewalk: Add test_p?d callbacks
  mm: pagewalk: Add 'depth' parameter to pte_hole
  x86: mm: Point to struct seq_file from struct pg_state
  x86: mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
  x86: mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
  x86: mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
  mm: Add generic ptdump
  x86: mm: Convert dump_pagetables to use walk_page_range
  arm64: mm: Convert mm/dump.c to use walk_page_range()
  arm64: mm: Display non-present entries in ptdump

 arch/arc/include/asm/pgtable.h               |   1 +
 arch/arm/include/asm/pgtable-2level.h        |   1 +
 arch/arm/include/asm/pgtable-3level.h        |   1 +
 arch/arm64/Kconfig                           |   1 +
 arch/arm64/Kconfig.debug                     |  19 +-
 arch/arm64/include/asm/pgtable.h             |   2 +
 arch/arm64/include/asm/ptdump.h              |   8 +-
 arch/arm64/mm/Makefile                       |   4 +-
 arch/arm64/mm/dump.c                         | 144 +++-----
 arch/arm64/mm/mmu.c                          |   4 +-
 arch/arm64/mm/ptdump_debugfs.c               |   2 +-
 arch/mips/include/asm/pgtable.h              |   5 +
 arch/powerpc/include/asm/book3s/64/pgtable.h |  30 +-
 arch/riscv/include/asm/pgtable-64.h          |   7 +
 arch/riscv/include/asm/pgtable.h             |   7 +
 arch/s390/include/asm/pgtable.h              |   2 +
 arch/sparc/include/asm/pgtable_64.h          |   2 +
 arch/x86/Kconfig                             |   1 +
 arch/x86/Kconfig.debug                       |  20 +-
 arch/x86/include/asm/pgtable.h               |  10 +-
 arch/x86/mm/Makefile                         |   4 +-
 arch/x86/mm/debug_pagetables.c               |   8 +-
 arch/x86/mm/dump_pagetables.c                | 332 +++++--------------
 arch/x86/platform/efi/efi_32.c               |   2 +-
 arch/x86/platform/efi/efi_64.c               |   4 +-
 drivers/firmware/efi/arm-runtime.c           |   2 +-
 fs/proc/task_mmu.c                           |   4 +-
 include/asm-generic/pgtable.h                |  20 ++
 include/linux/mm.h                           |  35 +-
 include/linux/ptdump.h                       |  19 ++
 mm/Kconfig.debug                             |  21 ++
 mm/Makefile                                  |   1 +
 mm/hmm.c                                     |   2 +-
 mm/migrate.c                                 |   1 +
 mm/mincore.c                                 |   1 +
 mm/pagewalk.c                                | 107 ++++--
 mm/ptdump.c                                  | 151 +++++++++
 37 files changed, 544 insertions(+), 441 deletions(-)
 create mode 100644 include/linux/ptdump.h
 create mode 100644 mm/ptdump.c

-- 
2.20.1

