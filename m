Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F3F046B002D
	for <linux-mm@kvack.org>; Thu, 27 Oct 2011 14:52:31 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
Date: Thu, 27 Oct 2011 11:52:22 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: [GIT PULL] mm: frontswap (for 3.2 window)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, levinsasha928@gmail.com, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Neo Jia <cyclonusj@gmail.com>

Hi Linus --

Frontswap now has FOUR users: Two already merged in-tree (zcache
and Xen) and two still in development but in public git trees
(RAMster and KVM).  Frontswap is part 2 of 2 of the core kernel
changes required to support transcendent memory; part 1 was cleancache
which you merged at 3.0 (and which now has FIVE users).

Frontswap patches have been in linux-next since June 3 (with zero
changes since Sep 22).  First posted to lkml in June 2009, frontswap=20
is now at version 11 and has incorporated feedback from a wide range
of kernel developers.  For a good overview, see
   http://lwn.net/Articles/454795.
If further rationale is needed, please see the end of this email
for more info.

SO... Please pull:

git://oss.oracle.com/git/djm/tmem.git #tmem

since git commit b6fd41e29dea9c6753b1843a77e50433e6123bcb
Linus Torvalds (1):

=09Linux 3.1-rc6

(identical commits being pulled by sfr into linux-next since Sep22)

Note that in addition to frontswap, this commit series includes
some minor changes to cleancache necessary for consistency with
changes for frontswap required by Andrew Morton (e.g. flush->invalidate
name change; use debugfs instead of sysfs).  As a result, a handful
of cleancache-related VFS files incur only a very small change.

Dan Magenheimer (8):
      mm: frontswap: add frontswap header file
      mm: frontswap: core swap subsystem hooks and headers
      mm: frontswap: core frontswap functionality
      mm: frontswap: config and doc files
      mm: cleancache: s/flush/invalidate/
      mm: frontswap/cleancache: s/flush/invalidate/
      mm: cleancache: report statistics via debugfs instead of sysfs.
      mm: cleancache: Use __read_mostly as appropiate.

Diffstat:
 .../ABI/testing/sysfs-kernel-mm-cleancache         |   11 -
 Documentation/vm/cleancache.txt                    |   41 ++--
 Documentation/vm/frontswap.txt                     |  210 +++++++++++++++
 drivers/staging/zcache/zcache-main.c               |   10 +-
 drivers/xen/tmem.c                                 |   10 +-
 fs/buffer.c                                        |    2 +-
 fs/super.c                                         |    2 +-
 include/linux/cleancache.h                         |   24 +-
 include/linux/frontswap.h                          |    9 +-
 include/linux/swap.h                               |    4 +
 include/linux/swapfile.h                           |   13 +
 mm/Kconfig                                         |   17 ++
 mm/Makefile                                        |    1 +
 mm/cleancache.c                                    |   98 +++-----
 mm/filemap.c                                       |    2 +-
 mm/frontswap.c                                     |  273 ++++++++++++++++=
++++
 mm/page_io.c                                       |   12 +
 mm/swapfile.c                                      |   64 ++++-
 mm/truncate.c                                      |   10 +-
 19 files changed, 672 insertions(+), 141 deletions(-)

=3D=3D=3D=3D

FURTHER RATIONALE, INFORMATION, AND LINKS:

In-kernel users (grep for CONFIG_FRONTSWAP):
- drivers/staging/zcache (since 2.6.39)
- drivers/xen/tmem.c (since 3.1)
- drivers/xen/xen-selfballoon.c (since 3.1)

Users in development in public git trees:
- "RAMster" driver, see ramster branch of
    git://oss.oracle.com/git/djm/tmem.git
- KVM port now underway, see:
    https://github.com/sashalevin/kvm-tmem/commits/tmem=20

History of frontswap code:
- code first written in Dec 2008
- previously known as "hswap" and "preswap"
- first public posting in Feb 2009
- first LKML posting on June 19, 2009
- renamed frontswap, posted on May 28, 2010
- in linux-next since June 3, 2011
- incorporated feedback from: (partial list)
   Andrew Morton, Jan Beulich, Konrad Wilk,
    Jeremy Fitzhardinge, Kamezawa Hiroyuki,
    Seth Jennings (IBM)

Linux kernel distros incorporating frontswap:
- Oracle UEK 2.6.39 Beta:
   http://oss.oracle.com/git/?p=3Dlinux-2.6-unbreakable-beta.git;a=3Dsummar=
y=20
- OpenSuSE since 11.2 (2009) [see mm/tmem-xen.c]
   http://kernel.opensuse.org/cgit/kernel/=20
- a popular Gentoo distro
   http://forums.gentoo.org/viewtopic-t-862105.html=20

Xen distros supporting Linux guests with frontswap:
- Xen hypervisor backend since Xen 4.0 (2009)
   http://www.xen.org/files/Xen_4_0_Datasheet.pdf=20
- OracleVM since 2.2 (2009)
   http://twitter.com/#!/Djelibeybi/status/113876514688352256=20

Public visibility for frontswap (as part of transcendent memory):
- presented at OSDI'08, OLS'09, LCA'10, LPC'10, LinuxCon NA 11, Oracle
  Open World 2011, two LSF/MM Summits (2010,2011), and three
  Xen Summits (2009,2010,2011)
- http://lwn.net/Articles/454795 (current overview)
- http://lwn.net/Articles/386090 (2010)
- http://lwn.net/Articles/340080 (2009)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
