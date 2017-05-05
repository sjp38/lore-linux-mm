Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6D36B0311
	for <linux-mm@kvack.org>; Fri,  5 May 2017 13:03:32 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id o15so13202719ito.14
        for <linux-mm@kvack.org>; Fri, 05 May 2017 10:03:32 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id j2si3279621itc.76.2017.05.05.10.03.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 May 2017 10:03:31 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v3 0/9] parallelized "struct page" zeroing
Date: Fri,  5 May 2017 13:03:07 -0400
Message-Id: <1494003796-748672-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net

Changelog:
	v2 - v3
	- Addressed David's comments about one change per patch:
		* Splited changes to platforms into 4 patches
		* Made "do not zero vmemmap_buf" as a separate patch
	v1 - v2
	- Per request, added s390 to deferred "struct page" zeroing
	- Collected performance data on x86 which proofs the importance to
	  keep memset() as prefetch (see below).

When deferred struct page initialization feature is enabled, we get a
performance gain of initializing vmemmap in parallel after other CPUs are
started. However, we still zero the memory for vmemmap using one boot CPU.
This patch-set fixes the memset-zeroing limitation by deferring it as well.

Performance gain on SPARC with 32T:
base:	https://hastebin.com/ozanelatat.go
fix:	https://hastebin.com/utonawukof.go

As you can see without the fix it takes: 97.89s to boot
With the fix it takes: 46.91 to boot.

Performance gain on x86 with 1T:
base:	https://hastebin.com/uvifasohon.pas
fix:	https://hastebin.com/anodiqaguj.pas

On Intel we save 10.66s/T while on SPARC we save 1.59s/T. Intel has
twice as many pages, and also fewer nodes than SPARC (sparc 32 nodes, vs.
intel 8 nodes).

It takes one thread 11.25s to zero vmemmap on Intel for 1T, so it should
take additional 11.25 / 8 = 1.4s  (this machine has 8 nodes) per node to
initialize the memory, but it takes only additional 0.456s per node, which
means on Intel we also benefit from having memset() and initializing all
other fields in one place.

Pavel Tatashin (9):
  sparc64: simplify vmemmap_populate
  mm: defining memblock_virt_alloc_try_nid_raw
  mm: add "zero" argument to vmemmap allocators
  mm: do not zero vmemmap_buf
  mm: zero struct pages during initialization
  sparc64: teach sparc not to zero struct pages memory
  x86: teach x86 not to zero struct pages memory
  powerpc: teach platforms not to zero struct pages memory
  s390: teach platforms not to zero struct pages memory

 arch/powerpc/mm/init_64.c |    4 +-
 arch/s390/mm/vmem.c       |    5 ++-
 arch/sparc/mm/init_64.c   |   26 +++++++----------------
 arch/x86/mm/init_64.c     |    3 +-
 include/linux/bootmem.h   |    3 ++
 include/linux/mm.h        |   15 +++++++++++--
 mm/memblock.c             |   46 ++++++++++++++++++++++++++++++++++++------
 mm/page_alloc.c           |    3 ++
 mm/sparse-vmemmap.c       |   48 +++++++++++++++++++++++++++++---------------
 9 files changed, 103 insertions(+), 50 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
