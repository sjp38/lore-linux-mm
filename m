Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3530A6B0333
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 18:55:23 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id 20so12011217iod.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 15:55:23 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id r79si402742ior.12.2017.03.23.15.55.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 15:55:22 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v1 0/5] parallelized "struct page" zeroing
Date: Thu, 23 Mar 2017 19:01:48 -0400
Message-Id: <1490310113-824438-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.or

When deferred struct page initialization feature is enabled, we get a
performance gain of initializing vmemmap in parallel after other CPUs are
started. However, we still zero the memory for vmemmap using one boot CPU.
This patch-set fixes the memset-zeroing limitation by deferring it as well.

Here is example performance gain on SPARC with 32T:
base
https://hastebin.com/ozanelatat.go

fix
https://hastebin.com/utonawukof.go

As you can see without the fix it takes: 97.89s to boot
With the fix it takes: 46.91 to boot.

On x86 time saving is going to be even greater (proportionally to memory size)
because there are twice as many "struct page"es for the same amount of memory,
as base pages are twice smaller.


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
