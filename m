Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id j265Huqi008846
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <linux-mm@kvack.org>; Sat, 5 Mar 2005 21:17:57 -0800
Received: from bix (shell0.pdx.osdl.net [10.9.0.31])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with SMTP id j265Hutt015614
	for <linux-mm@kvack.org>; Sat, 5 Mar 2005 21:17:56 -0800
Date: Sat, 5 Mar 2005 21:17:33 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [BK] set_pte() mm/addr arg addition
Message-Id: <20050305211733.115cce4f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Begin forwarded message:

Date: Sat, 5 Mar 2005 21:09:09 -0800
From: "David S. Miller" <davem@davemloft.net>
To: torvalds@osdl.org
Cc: akpm@osdl.org, linux-arch -at- vger
Subject: [BK] set_pte() mm/addr arg addition



Linus, please pull from:

	bk://kernel.bkbits.net/davem/set_pte-2.6

to get these changesets.

One pain ppc/ppc64/sparc64 have is that we do batched
TLB flushing, and we batch up the flushes at set_pte()
time based upon whether the PTE bit changes would require
a flush or not.

One unnecessary complication is that set_pte() doesn't
give the process address space (so we can't figure out
the MMU context) nor the virtual address (so we can't
figure out what to flush from the TLB) so we "remember"
this information by storing cookes in the page struct
that backs the pte tables.  Gross.

Instead, we now add mm and addr args to set_pte().

Many platforms implement this in assembler, so in order
to ease transition I created a new function "set_pte_at()"
that takes the mm and addr new arguments, and left the
set_pte() thing alone.  All the generic code uses set_pte_at(),
but some platform code still uses the older set_pte().
Some platforms are fully converted, especially the ones that
benefit the most from these changes.

Technically, set_pte() only exists in platform specific code
at this point.  Someone with some kernel janitor inklings
can convert them all over to pure set_pte_at() if they wished.

Adding the mm and addr args was quite trivial in the
generic code, the information was pretty much there
already.  Although for a few cases, the top bits of the
virtual address were being masked off (with ~PMD_MASK)
at the pte level iterators.  Ben and I found this while
stress testing the changes, and the bug fix for that is
in here too.

This has been build and run tested on many platforms.
x86, s390, ppc, ppc64, sparc64, sh, and sh64 at a minimum.
On ppc/ppc64/sparc64 is has been pretty well stress tested
using LTP and similar suites.

I'd like to thank Ben H. for making me get off my butt and
revive these changes.  They significantly simplify the ppc,
ppc64 and sparc64 ports.

Thanks.

ChangeSet@1.2035.23.1, 2005-02-23 15:42:56-08:00, davem@nuts.davemloft.net
  [MM]: Add set_pte_at() which takes 'mm' and 'addr' args.
  
  I'm taking a slightly different approach this time around so things
  are easier to integrate.  Here is the first patch which builds the
  infrastructure.  Basically:
  
  1) Add set_pte_at() which is set_pte() with 'mm' and 'addr' arguments
     added.  All generic code uses set_pte_at().
  
     Most platforms simply get this define:
  	#define set_pte_at(mm,addr,ptep,pteval) set_pte(ptep,pteval)
  
     I chose this method over simply changing all set_pte() call sites
     because many platforms implement this in assembler and it would
     take forever to preserve the build and stabilize things if modifying
     that was necessary.
  
     Soon, with platform maintainer's help, we can kill of set_pte() entirely.
     To be honest, there are only a handful of set_pte() call sites in the
     arch specific code.
  
     Actually, in this patch ppc64 is completely set_pte() free and does not
     define it.
  
  2) pte_clear() gets 'mm' and 'addr' arguments now.
     This had a cascading effect on many ptep_test_and_*() routines.  Specifically:
     a) ptep_test_and_clear_{young,dirty}() now take 'vma' and 'address' args.
     b) ptep_get_and_clear now take 'mm' and 'address' args.
     c) ptep_mkdirty was deleted, unused by any code.
     d) ptep_set_wrprotect now takes 'mm' and 'address' args.
  
  I've tested this patch as follows:
  
  1) compile and run tested on sparc64/SMP
  2) compile tested on:
     a) ppc64/SMP
     b) i386 both with and without PAE enabled
  
  Signed-off-by: David S. Miller <davem@davemloft.net>

 arch/arm/mm/consistent.c            |    6 +-
 arch/i386/mm/highmem.c              |    2 
 arch/i386/mm/hugetlbpage.c          |    2 
 arch/ia64/mm/hugetlbpage.c          |    2 
 arch/mips/mm/highmem.c              |    2 
 arch/parisc/kernel/pci-dma.c        |    2 
 arch/parisc/mm/kmap.c               |    4 -
 arch/ppc/kernel/dma-mapping.c       |    6 +-
 arch/ppc64/mm/hugetlbpage.c         |   11 ++---
 arch/ppc64/mm/init.c                |    4 -
 arch/s390/mm/init.c                 |    4 -
 arch/sh/mm/hugetlbpage.c            |    2 
 arch/sh/mm/pg-sh4.c                 |    8 +--
 arch/sh/mm/pg-sh7705.c              |    4 -
 arch/sh64/mm/hugetlbpage.c          |    2 
 arch/sh64/mm/ioremap.c              |    2 
 arch/sparc/mm/generic.c             |   12 ++---
 arch/sparc/mm/highmem.c             |    2 
 arch/sparc64/mm/hugetlbpage.c       |    2 
 fs/exec.c                           |    2 
 include/asm-alpha/pgtable.h         |    6 ++
 include/asm-arm/pgtable.h           |    3 -
 include/asm-arm26/pgtable.h         |    3 -
 include/asm-cris/pgtable.h          |    4 +
 include/asm-frv/pgtable.h           |   18 ++------
 include/asm-generic/pgtable.h       |   75 ++++++++++++++++++------------------
 include/asm-i386/pgtable-2level.h   |    3 -
 include/asm-i386/pgtable-3level.h   |    4 +
 include/asm-i386/pgtable.h          |   13 +++---
 include/asm-ia64/pgtable.h          |   31 ++++----------
 include/asm-m32r/pgtable-2level.h   |    3 -
 include/asm-m32r/pgtable.h          |   14 +-----
 include/asm-m68k/motorola_pgtable.h |    2 
 include/asm-m68k/pgtable.h          |    1 
 include/asm-m68k/sun3_pgtable.h     |    5 +-
 include/asm-mips/pgtable.h          |   14 +++---
 include/asm-parisc/pgtable.h        |   30 ++++----------
 include/asm-ppc/highmem.h           |    2 
 include/asm-ppc/pgtable.h           |   17 ++------
 include/asm-ppc64/pgtable.h         |   21 +++++-----
 include/asm-s390/pgalloc.h          |    6 +-
 include/asm-s390/pgtable.h          |   27 +++++-------
 include/asm-sh/pgtable-2level.h     |    2 
 include/asm-sh/pgtable.h            |    4 -
 include/asm-sh64/pgtable.h          |    3 -
 include/asm-sparc/pgtable.h         |    3 -
 include/asm-sparc64/pgtable.h       |    4 +
 include/asm-um/pgtable-2level.h     |    1 
 include/asm-um/pgtable-3level.h     |    1 
 include/asm-um/pgtable.h            |    2 
 include/asm-x86_64/pgtable.h        |   16 ++++---
 mm/fremap.c                         |    6 +-
 mm/highmem.c                        |    6 +-
 mm/memory.c                         |   39 ++++++++++--------
 mm/mprotect.c                       |   20 ++++-----
 mm/mremap.c                         |    2 
 mm/rmap.c                           |    4 -
 mm/swapfile.c                       |    3 -
 mm/vmalloc.c                        |    4 -
 59 files changed, 253 insertions(+), 250 deletions(-)


ChangeSet@1.2035.23.2, 2005-02-23 17:46:43-08:00, davem@nuts.davemloft.net
  [SPARC64]: Pass mm/addr directly to tlb_batch_add()
  
  No longer need to store this information in the pte table
  page struct.
  
  Signed-off-by: David S. Miller <davem@davemloft.net>

 arch/sparc64/mm/generic.c     |   25 ++++++++++++++-----------
 arch/sparc64/mm/hugetlbpage.c |   10 ++++++----
 arch/sparc64/mm/init.c        |    3 ++-
 arch/sparc64/mm/tlb.c         |   17 +++++++----------
 include/asm-sparc64/pgalloc.h |   20 +++++---------------
 include/asm-sparc64/pgtable.h |   11 ++++++-----
 6 files changed, 40 insertions(+), 46 deletions(-)


ChangeSet@1.2035.23.3, 2005-02-23 19:27:50-08:00, davem@nuts.davemloft.net
  [PPC]: Use new set_pte_at() w/mm+address args.
  
  Based almost entirely upon an earlier patch by
  Benjamin Herrenschmidt.
  
  Signed-off-by: David S. Miller <davem@davemloft.net>

 arch/ppc/kernel/dma-mapping.c |    7 +++-
 arch/ppc/mm/init.c            |   12 --------
 arch/ppc/mm/pgtable.c         |   14 +--------
 arch/ppc/mm/tlb.c             |   20 -------------
 arch/ppc64/mm/tlb.c           |   11 +------
 include/asm-ppc/highmem.h     |    2 -
 include/asm-ppc/pgtable.h     |   61 ++++++++++++++++++++++--------------------
 include/asm-ppc64/pgalloc.h   |   28 ++++---------------
 include/asm-ppc64/pgtable.h   |   52 ++++++++++++++++++++++-------------
 9 files changed, 81 insertions(+), 126 deletions(-)


ChangeSet@1.2035.23.4, 2005-02-26 20:51:23-08:00, davem@nuts.davemloft.net
  [MM]: Pass correct address down to bottom of page table iterators.
  
  Some routines, namely zeromap_pte_range, remap_pte_range,
  change_pte_range, unmap_area_pte, and map_area_pte, were
  using a chopped off address.  This causes bogus addresses
  to be passed into set_pte_at() and friends, resulting
  in missed TLB flushes and other nasties.
  
  Signed-off-by: David S. Miller <davem@davemloft.net>

 mm/memory.c   |   12 +++++++-----
 mm/mprotect.c |   17 ++++++++++-------
 mm/vmalloc.c  |   22 +++++++++++++---------
 3 files changed, 30 insertions(+), 21 deletions(-)


ChangeSet@1.2035.23.5, 2005-02-27 11:34:35-08:00, davem@nuts.davemloft.net
  [SPARC64]: Do the init_mm check inline in set_pte_at().
  
  Signed-off-by: David S. Miller <davem@davemloft.net>

 arch/sparc64/mm/tlb.c         |   13 ++-----------
 include/asm-sparc64/pgtable.h |   13 ++++++++-----
 2 files changed, 10 insertions(+), 16 deletions(-)


ChangeSet@1.2035.23.6, 2005-03-01 15:00:34-08:00, davem@nuts.davemloft.net
  [S390]: Fix build after set_pte_at() changes.
  
  Signed-off-by: David S. Miller <davem@davemloft.net>

 include/asm-s390/pgtable.h |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)


ChangeSet@1.2074, 2005-03-01 15:33:45-08:00, davem@nuts.davemloft.net
  Resolve conflicts.

 arch/arm/mm/consistent.c |    6 ++++--
 mm/highmem.c             |    6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)


ChangeSet@1.2075, 2005-03-01 15:38:13-08:00, davem@nuts.davemloft.net
  Resolve conflicts.

 arch/ppc64/mm/tlb.c |   15 ++-------------
 1 files changed, 2 insertions(+), 13 deletions(-)


ChangeSet@1.2076, 2005-03-05 20:48:01-08:00, davem@picasso.davemloft.net
  Merge davem@nuts:/disk1/BK/set_pte-2.6
  into picasso.davemloft.net:/home/davem/src/BK/set_pte-2.6

 arch/ppc64/mm/hugetlbpage.c |   11 +++++-----
 arch/ppc64/mm/init.c        |    4 +--
 fs/exec.c                   |    2 -
 include/asm-arm/pgtable.h   |    3 +-
 mm/memory.c                 |   47 ++++++++++++++++++++++++--------------------
 mm/mremap.c                 |    2 -
 mm/rmap.c                   |    4 +--
 mm/swapfile.c               |    3 +-
 8 files changed, 42 insertions(+), 34 deletions(-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
