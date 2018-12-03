Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE3416B69DB
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 10:47:45 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o21so6716381edq.4
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 07:47:45 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 91si982189eda.102.2018.12.03.07.47.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 07:47:43 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wB3FiFam064919
	for <linux-mm@kvack.org>; Mon, 3 Dec 2018 10:47:42 -0500
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2p56u7ta2c-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 03 Dec 2018 10:47:38 -0500
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 3 Dec 2018 15:47:29 -0000
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: [PATCH v2 0/6] memblock: simplify several early memory allocation
Date: Mon,  3 Dec 2018 17:47:09 +0200
Message-Id: <1543852035-26634-1-git-send-email-rppt@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Greentime Hu <green.hu@gmail.com>, Jonas Bonn <jonas@southpole.se>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Mark Salter <msalter@redhat.com>, Paul Mackerras <paulus@samba.org>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Stefan Kristiansson <stefan.kristiansson@saunalahti.fi>, Stafford Horne <shorne@gmail.com>, Vincent Chen <deanbo422@gmail.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, Mike Rapoport <rppt@linux.ibm.com>

Hi,

These patches simplify some of the early memory allocations by replacing
usage of older memblock APIs with newer and shinier ones.

Quite a few places in the arch/ code allocated memory using a memblock API
that returns a physical address of the allocated area, then converted this
physical address to a virtual one and then used memset(0) to clear the
allocated range.

More recent memblock APIs do all the three steps in one call and their
usage simplifies the code.

It's important to note that regardless of API used, the core allocation is
nearly identical for any set of memblock allocators: first it tries to find
a free memory with all the constraints specified by the caller and then
falls back to the allocation with some or all constraints disabled.

The first three patches perform the conversion of call sites that have
exact requirements for the node and the possible memory range.

The fourth patch is a bit one-off as it simplifies openrisc's
implementation of pte_alloc_one_kernel(), and not only the memblock usage.

The fifth patch takes care of simpler cases when the allocation can be
satisfied with a simple call to memblock_alloc().

The sixth patch removes one-liner wrappers for memblock_alloc on arm and
unicore32, as suggested by Christoph.

v2:
* added Ack from Stafford Horne for openrisc changes
* entirely drop early_alloc wrappers on arm and unicore32, as per Christoph
Hellwig

Mike Rapoport (6):
  powerpc: prefer memblock APIs returning virtual address
  microblaze: prefer memblock API returning virtual address
  sh: prefer memblock APIs returning virtual address
  openrisc: simplify pte_alloc_one_kernel()
  arch: simplify several early memory allocations
  arm, unicore32: remove early_alloc*() wrappers

 arch/arm/mm/mmu.c                      | 13 +++----------
 arch/c6x/mm/dma-coherent.c             |  9 ++-------
 arch/microblaze/mm/init.c              |  5 +++--
 arch/nds32/mm/init.c                   | 12 ++++--------
 arch/openrisc/mm/ioremap.c             | 11 ++++-------
 arch/powerpc/kernel/paca.c             | 14 ++++++--------
 arch/powerpc/kernel/setup-common.c     |  4 ++--
 arch/powerpc/kernel/setup_64.c         | 21 ++++++++++-----------
 arch/powerpc/mm/hash_utils_64.c        |  6 +++---
 arch/powerpc/mm/pgtable-book3e.c       |  8 ++------
 arch/powerpc/mm/pgtable-book3s64.c     |  5 +----
 arch/powerpc/mm/pgtable-radix.c        | 24 +++++++++---------------
 arch/powerpc/mm/pgtable_32.c           |  4 +---
 arch/powerpc/mm/ppc_mmu_32.c           |  3 +--
 arch/powerpc/platforms/pasemi/iommu.c  |  5 +++--
 arch/powerpc/platforms/powernv/opal.c  |  3 +--
 arch/powerpc/platforms/pseries/setup.c | 11 +++++++----
 arch/powerpc/sysdev/dart_iommu.c       |  5 +++--
 arch/sh/mm/init.c                      | 18 +++++-------------
 arch/sh/mm/numa.c                      |  5 ++---
 arch/sparc/kernel/prom_64.c            |  7 ++-----
 arch/sparc/mm/init_64.c                |  9 +++------
 arch/unicore32/mm/mmu.c                | 14 ++++----------
 23 files changed, 81 insertions(+), 135 deletions(-)
