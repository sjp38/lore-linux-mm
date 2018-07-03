Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9016B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 06:30:10 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z11-v6so755914edq.17
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 03:30:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i61-v6si878229edc.458.2018.07.03.03.30.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 03:30:08 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w63AP0oe080780
	for <linux-mm@kvack.org>; Tue, 3 Jul 2018 06:30:06 -0400
Received: from e06smtp03.uk.ibm.com (e06smtp03.uk.ibm.com [195.75.94.99])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2k04abg253-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 03 Jul 2018 06:30:06 -0400
Received: from localhost
	by e06smtp03.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 3 Jul 2018 11:30:03 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 0/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
Date: Tue,  3 Jul 2018 13:29:52 +0300
Message-Id: <1530613795-6956-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>
Cc: Michal Hocko <mhocko@kernel.org>, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Hi,

These patches switch m68k boot time memory allocators from bootmem to
memblock + no_bootmem.

The first two patches update __ffs() and __va() definitions to be inline
with other arches and asm-generic. This is required to avoid compilation
warnings in mm/memblock.c and mm/nobootmem.c.

The third patch performs the actual switch of the boot time mm. Its
changelog has detailed description of the changes.

I've tested the !MMU version with qemu-system-m68k -M mcf5208evb
and the MMU version with q800 using qemu from [1].

I've also build tested allyesconfig and *_defconfig.

[1] https://github.com/vivier/qemu-m68k.git

Mike Rapoport (3):
  m68k/bitops: convert __ffs to match generic declaration
  m68k/page_no.h: force __va argument to be unsigned long
  m68k: switch to MEMBLOCK + NO_BOOTMEM

 arch/m68k/Kconfig               |  3 +++
 arch/m68k/include/asm/bitops.h  |  8 ++++++--
 arch/m68k/include/asm/page_no.h |  2 +-
 arch/m68k/kernel/setup_mm.c     | 14 ++++----------
 arch/m68k/kernel/setup_no.c     | 20 ++++----------------
 arch/m68k/mm/init.c             |  1 -
 arch/m68k/mm/mcfmmu.c           | 11 +++++++----
 arch/m68k/mm/motorola.c         | 35 +++++++++++------------------------
 arch/m68k/sun3/config.c         |  4 ----
 9 files changed, 36 insertions(+), 62 deletions(-)

-- 
2.7.4
