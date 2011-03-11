Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B773B8D003A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 15:35:51 -0500 (EST)
Received: by qwa26 with SMTP id 26so88316qwa.14
        for <linux-mm@kvack.org>; Fri, 11 Mar 2011 12:35:47 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 11 Mar 2011 20:35:47 +0000
Message-ID: <AANLkTimU2QGc_BVxSWCN8GEhr8hCOi1Zp+eaA20_pE-w@mail.gmail.com>
Subject: [RFC][PATCH 00/25]: Propagating GFP_NOFS inside __vmalloc()
From: Prasad Joshi <prasadjoshi124@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Anand Mitra <mitra@kqinfotech.com>

A filesystem might run into a problem while calling
__vmalloc(GFP_NOFS) inside a lock.

It is expected than __vmalloc when called with GFP_NOFS should not
callback the filesystem code even incase of the increased memory
pressure. But the problem is that even if we pass this flag, __vmalloc
itself allocates memory with GFP_KERNEL.

Using GFP_KERNEL allocations may go into the memory reclaim path and
try to free memory by calling file system clear_inode/evict_inode
function. Which might lead into deadlock.

For further details
https://bugzilla.kernel.org/show_bug.cgi?id=30702
http://marc.info/?l=linux-mm&m=128942194520631&w=4

The patch passes the gfp allocation flag all the way down to those
allocating functions.

 arch/alpha/include/asm/pgalloc.h         |   18 ++-------
 arch/arm/include/asm/pgalloc.h           |   12 +-----
 arch/avr32/include/asm/pgalloc.h         |    8 +----
 arch/cris/include/asm/pgalloc.h          |   10 +----
 arch/frv/include/asm/pgalloc.h           |    3 --
 arch/frv/include/asm/pgtable.h           |    1 -
 arch/frv/mm/pgalloc.c                    |    9 +----
 arch/ia64/include/asm/pgalloc.h          |   24 ++-----------
 arch/m32r/include/asm/pgalloc.h          |   11 ++----
 arch/m68k/include/asm/motorola_pgalloc.h |   19 ++--------
 arch/m68k/include/asm/sun3_pgalloc.h     |   14 ++------
 arch/m68k/mm/memory.c                    |    9 +----
 arch/microblaze/include/asm/pgalloc.h    |    3 --
 arch/microblaze/mm/pgtable.c             |   12 ++-----
 arch/mips/include/asm/pgalloc.h          |   22 ++++--------
 arch/mn10300/include/asm/pgalloc.h       |    2 -
 arch/mn10300/mm/pgtable.c                |   10 +----
 arch/parisc/include/asm/pgalloc.h        |   20 ++--------
 arch/powerpc/include/asm/pgalloc-32.h    |    2 -
 arch/powerpc/include/asm/pgalloc-64.h    |   29 +++------------
 arch/powerpc/mm/pgtable_32.c             |   10 +----
 arch/s390/include/asm/pgalloc.h          |   28 +++------------
 arch/s390/mm/pgtable.c                   |   22 +++---------
 arch/score/include/asm/pgalloc.h         |   14 +++----
 arch/sh/include/asm/pgalloc.h            |    8 +----
 arch/sh/mm/pgtable.c                     |    8 +----
 arch/sparc/include/asm/pgalloc_32.h      |    5 ---
 arch/sparc/include/asm/pgalloc_64.h      |   17 +--------
 arch/tile/include/asm/pgalloc.h          |   11 +-----
 arch/tile/mm/pgtable.c                   |   10 +----
 arch/um/include/asm/pgalloc.h            |    1 -
 arch/um/kernel/mem.c                     |   21 +++--------
 arch/x86/include/asm/pgalloc.h           |   17 +--------
 arch/x86/mm/pgtable.c                    |    9 +----
 arch/xtensa/include/asm/pgalloc.h        |    9 +----
 arch/xtensa/mm/pgtable.c                 |   10 +----
 include/asm-generic/4level-fixup.h       |    8 +---
 include/asm-generic/pgtable-nopmd.h      |    3 +-
 include/asm-generic/pgtable-nopud.h      |    1 -
 include/linux/mm.h                       |   40 +++++---------------
 mm/memory.c                              |   14 +++----
 mm/vmalloc.c                             |   58 ++++++++++--------------------
 42 files changed, 121 insertions(+), 441 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
