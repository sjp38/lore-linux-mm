Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id j267Aaqi015153
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <linux-mm@kvack.org>; Sat, 5 Mar 2005 23:10:36 -0800
Received: from bix (shell0.pdx.osdl.net [10.9.0.31])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with SMTP id j267AZso018133
	for <linux-mm@kvack.org>; Sat, 5 Mar 2005 23:10:35 -0800
Date: Sat, 5 Mar 2005 23:10:13 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [BK] flush_cache_page() pfn arg addition
Message-Id: <20050305231013.20f30a1d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Begin forwarded message:

Date: Sat, 5 Mar 2005 21:27:45 -0800
From: "David S. Miller" <davem@davemloft.net>
To: torvalds@osdl.org
Cc: akpm@osdl.org, linux-arch -at- vger
Subject: [BK] flush_cache_page() pfn arg addition



Linus, please pull from:

	bk://kernel.bkbits.net/davem/flush_cache_page-2.6

to get these changesets.

Like the set_pte() changes I just sent off, this stuff simplifies
ARM, SH, and SH64 ports significantly.

These three chips can have cache variants which require a physical
page frame number in order to flush the cache properly.  And like
the set_pte() case, this new argument is available in all the
call sites already.

What these people do right now is walk the page tables for the
given vma->vm_mm+addr combination and read out the pte, and that's
kind of silly and expensive.

Most platforms simply nop out the new arg or ignore it as is usual
practice with such interface changes.

This also has the necessary documentation updates as well.

It has been build and run tested on several platforms.

Thanks.

ChangeSet@1.2049.4.1, 2005-02-25 16:36:06-08:00, davem@nuts.davemloft.net
  [MM]: Add 'pfn' arg to flush_cache_page().
  
  Based almost entirely upon a patch by Russell King.
  
  Signed-off-by: David S. Miller <davem@davemloft.net>

 Documentation/cachetlb.txt          |   12 +++++++---
 arch/arm/mm/fault-armv.c            |    4 +--
 arch/arm/mm/flush.c                 |    2 -
 arch/mips/mm/c-r3k.c                |    3 --
 arch/mips/mm/c-r4k.c                |    3 --
 arch/mips/mm/c-sb1.c                |   11 +++++----
 arch/mips/mm/c-tx39.c               |    3 --
 arch/mips/mm/cache.c                |    2 -
 arch/sh/mm/cache-sh4.c              |   41 +++++++++---------------------------
 arch/sh/mm/cache-sh7705.c           |   20 +----------------
 arch/sh64/mm/cache.c                |   28 +++---------------------
 arch/sparc/mm/srmmu.c               |    3 --
 fs/binfmt_elf.c                     |    2 -
 include/asm-alpha/cacheflush.h      |    2 -
 include/asm-arm/cacheflush.h        |   16 +++++++-------
 include/asm-arm26/cacheflush.h      |    2 -
 include/asm-cris/cacheflush.h       |    2 -
 include/asm-frv/cacheflush.h        |    2 -
 include/asm-h8300/cacheflush.h      |    2 -
 include/asm-i386/cacheflush.h       |    2 -
 include/asm-ia64/cacheflush.h       |    2 -
 include/asm-m32r/cacheflush.h       |    6 ++---
 include/asm-m68k/cacheflush.h       |   15 ++++++-------
 include/asm-m68knommu/cacheflush.h  |    2 -
 include/asm-mips/cacheflush.h       |    5 +---
 include/asm-parisc/cacheflush.h     |    6 ++---
 include/asm-ppc/cacheflush.h        |    2 -
 include/asm-ppc64/cacheflush.h      |    2 -
 include/asm-s390/cacheflush.h       |    2 -
 include/asm-sh/cacheflush.h         |    4 +--
 include/asm-sh/cpu-sh2/cacheflush.h |    4 +--
 include/asm-sh/cpu-sh3/cacheflush.h |    6 ++---
 include/asm-sh/cpu-sh4/cacheflush.h |    2 -
 include/asm-sh64/cacheflush.h       |    6 ++---
 include/asm-sparc/cacheflush.h      |   14 ++++++------
 include/asm-sparc64/cacheflush.h    |   14 ++++++------
 include/asm-v850/cacheflush.h       |    2 -
 include/asm-x86_64/cacheflush.h     |    2 -
 mm/fremap.c                         |    2 -
 mm/memory.c                         |    4 +--
 mm/rmap.c                           |    4 +--
 41 files changed, 107 insertions(+), 161 deletions(-)


ChangeSet@1.2078, 2005-03-05 21:15:21-08:00, davem@picasso.davemloft.net
  Merge davem@nuts:/disk1/BK/flush_cache_page-2.6
  into picasso.davemloft.net:/home/davem/src/BK/flush_cache_page-2.6

 fs/binfmt_elf.c                 |    2 +-
 include/asm-arm/cacheflush.h    |   16 ++++++++--------
 include/asm-parisc/cacheflush.h |    6 +++---
 include/asm-ppc64/cacheflush.h  |    2 +-
 mm/memory.c                     |    4 ++--
 mm/rmap.c                       |    4 ++--
 6 files changed, 17 insertions(+), 17 deletions(-)


ChangeSet@1.2079, 2005-03-05 21:23:33-08:00, lethal@linux-sh.org
  [SH]: Cache flush simplifications after flush_cache_page() arg change.
  
  Signed-off-by: David S. Miller <davem@davemloft.net>

 arch/sh/mm/cache-sh4.c |    3 +--
 arch/sh64/mm/cache.c   |    7 +------
 2 files changed, 2 insertions(+), 8 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
