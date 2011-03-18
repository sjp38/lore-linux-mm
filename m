Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DFFDB8D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 15:41:03 -0400 (EDT)
Received: by wyf19 with SMTP id 19so5197568wyf.14
        for <linux-mm@kvack.org>; Fri, 18 Mar 2011 12:40:58 -0700 (PDT)
Date: Fri, 18 Mar 2011 19:41:35 +0000
From: Prasad Joshi <prasadjoshi124@gmail.com>
Subject: [RFC][PATCH v3 00/22] __vmalloc: Propagating GFP allocation flag
 inside __vmalloc()
Message-ID: <20110318194135.GA4746@prasad-kvm>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, prasadjoshi124@gmail.com, mitra@kqinfotech.com
Cc: chris@zankel.net, x86@kernel.org, jdike@addtoit.com, tj@kernel.org, cmetcalf@tilera.com, linux-sh@vger.kernel.org, liqin.chen@sunplusct.com, lennox.wu@gmail.com, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, linux390@de.ibm.com, benh@kernel.crashing.org, paulus@samba.org, linuxppc-dev@lists.ozlabs.org, kyle@mcmartin.ca, deller@gmx.de, jejb@parisc-linux.org, linux-parisc@vger.kernel.org, dhowells@redhat.com, yasutake.koichi@jp.panasonic.com, linux-am33-list@redhat.com, ralf@linux-mips.org, linux-mips@linux-mips.org, monstr@monstr.eu, microblaze-uclinux@itee.uq.edu.au, geert@linux-m68k.org, zippel@linux-m68k.org, sammy@sammy.net, linux-m68k@lists.linux-m68k.org, takata@linux-m32r.org, linux-m32r@ml.linux-m32r.org, tony.luck@intel.com, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, starvik@axis.com, jesper.nilsson@axis.com, linux-cris-kernel@axis.com, hans-christian.egtvedt@atmel.com, linux@arm.linux.org.uk, rth@twiddle.net, linux-alpha@vger.kernel.org

A filesystem might run into a problem while calling __vmalloc(GFP_NOFS)
inside a lock.

It is expected than __vmalloc when called with GFP_NOFS should not
callback the filesystem code even incase of the increased memory
pressure. But the problem is that even if we pass this flag, __vmalloc
itself allocates memory with GFP_KERNEL.

Using GFP_KERNEL allocations may go into the memory reclaim path and try
to free memory by calling file system evict_inode function. Which might
lead into deadlock.

For further details
http://marc.info/?l=linux-mm&m=128942194520631&w=4
https://bugzilla.kernel.org/show_bug.cgi?id=30702

The patch passes the gfp allocation flag all the way down to those
allocating functions.

 arch/arm/include/asm/pgalloc.h           |   11 +++++-
 arch/avr32/include/asm/pgalloc.h         |    8 ++++-
 arch/cris/include/asm/pgalloc.h          |   10 ++++-
 arch/frv/include/asm/pgalloc.h           |    3 ++
 arch/frv/include/asm/pgtable.h           |    1 +
 arch/frv/mm/pgalloc.c                    |    9 ++++-
 arch/ia64/include/asm/pgalloc.h          |   24 +++++++++++--
 arch/m32r/include/asm/pgalloc.h          |   11 ++++--
 arch/m68k/include/asm/motorola_pgalloc.h |   20 +++++++++--
 arch/m68k/include/asm/sun3_pgalloc.h     |   14 ++++++--
 arch/m68k/mm/memory.c                    |    9 ++++-
 arch/microblaze/include/asm/pgalloc.h    |    3 ++
 arch/microblaze/mm/pgtable.c             |   13 +++++--
 arch/mips/include/asm/pgalloc.h          |   22 ++++++++----
 arch/mn10300/include/asm/pgalloc.h       |    2 +
 arch/mn10300/mm/pgtable.c                |   10 ++++-
 arch/parisc/include/asm/pgalloc.h        |   21 ++++++++---
 arch/powerpc/include/asm/pgalloc-32.h    |    2 +
 arch/powerpc/include/asm/pgalloc-64.h    |   27 +++++++++++---
 arch/powerpc/mm/pgtable_32.c             |   10 ++++-
 arch/s390/include/asm/pgalloc.h          |   30 +++++++++++++---
 arch/s390/mm/pgtable.c                   |   22 +++++++++---
 arch/score/include/asm/pgalloc.h         |   13 ++++---
 arch/sh/include/asm/pgalloc.h            |    8 ++++-
 arch/sh/mm/pgtable.c                     |    8 ++++-
 arch/sparc/include/asm/pgalloc_32.h      |    5 +++
 arch/sparc/include/asm/pgalloc_64.h      |   17 ++++++++-
 arch/tile/include/asm/pgalloc.h          |   13 ++++++-
 arch/tile/mm/pgtable.c                   |   10 ++++-
 arch/um/include/asm/pgalloc.h            |    1 +
 arch/um/kernel/mem.c                     |   21 ++++++++---
 arch/x86/include/asm/pgalloc.h           |   17 ++++++++-
 arch/x86/mm/pgtable.c                    |    8 ++++-
 arch/xtensa/include/asm/pgalloc.h        |    9 ++++-
 arch/xtensa/mm/pgtable.c                 |   11 +++++-
 include/asm-generic/4level-fixup.h       |    8 +++-
 include/asm-generic/pgtable-nopmd.h      |    3 +-
 include/asm-generic/pgtable-nopud.h      |    1 +
 include/linux/mm.h                       |   40 ++++++++++++++++-----
 mm/memory.c                              |   14 ++++---
 mm/vmalloc.c                             |   57 ++++++++++++++++++++----------
 41 files changed, 427 insertions(+), 119 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
