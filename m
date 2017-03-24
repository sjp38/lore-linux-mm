Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 696A86B0351
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 15:20:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r89so13768919pfi.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:20:33 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id x4si3910681plm.10.2017.03.24.12.20.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 12:20:32 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v2 0/5] parallelized "struct page" zeroing
Date: Fri, 24 Mar 2017 15:19:47 -0400
Message-Id: <1490383192-981017-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org

Changelog:
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

Pavel Tatashin (5):
  sparc64: simplify vmemmap_populate
  mm: defining memblock_virt_alloc_try_nid_raw
  mm: add "zero" argument to vmemmap allocators
  mm: zero struct pages during initialization
  mm: teach platforms not to zero struct pages memory

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
