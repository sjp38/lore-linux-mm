Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 38E0B6B004A
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 06:09:28 -0400 (EDT)
Date: Tue, 26 Oct 2010 12:09:23 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: [GIT PULL] Please pull hwpoison updates for 2.6.37
Message-ID: <20101026100923.GA5118@basil.fritz.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: n-horiguchi@ah.jp.nec.com, x86@kernel.org
List-ID: <linux-mm.kvack.org>


Linus,

Here are the hwpoison updates for 2.6.37. The main new feature is 
soft offlining support for huge pages: support to predictively offline 
hugepages based on corrected memory error statistics.  
This can be a large win in memory reliability in some setups
and is transparent to applications.
We already supported that for small pages, but now have it for 
large pages too, because some large memory users like to use those.

Thanks to Naoya-san for spending a lot of time on that
and also cleaning up some code on the way.

This also is the basis for generic huge page migration (most of
the infrastructure is there, but not fully hooked up yet), which
will also give some NUMA tuning benefits.

Also various cleanups and improvements to hwpoison code.

There are some changes outside the usual hwpoison files,
which were needed to implement these features:

Signals:
- IA64 signal fix for _addr_lsb. Similar to the earlier MIPS change.
Acked by Tony.
- signalfd.h fix (from Seto-san): Same fix as for ia64 for signalfd.
This is all really just to report the _addr_lsb siginfo field out to
user space, so that it knows how much memory got corrupted. 
The code for siginfo is unfortunately scattered all over
the tree and I didn't find anyone who felt responsible for it.

- x86 hwpoison signal reporting fix. I tried to get an ack for that,
but wasn't able to motivate the x86 maintainers to reply to their emails.
Basically just pass around the address granuality from handle_mm_fault
to the hwpoison code in fault.c when an error happens.

MM:
- Some fixes to handle_memory_fault() to pass out the error
granuality in the return code. Does not affect any non hwpoison path.
- Migration changes for huge pages.
The migration code has been reviewed extensively by Christoph Lameter.
- hugetlb changes for migration. Have been reviewed by Mel.
- rmap changes for hugetlb migration, including the cleanups you requested 
in the last review cycle. Acked by Rik and others.

Please consider pulling,

Thanks,
-Andi

The following changes since commit 72e58063d63c5f0a7bf65312f1e3a5ed9bb5c2ff:

  Merge branch 'davinci-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/khilman/linux-davinci (2010-10-25 10:59:31 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/ak/linux-mce-2.6.git hwpoison

Andi Kleen (14):
      Clean up __page_set_anon_rmap
      hugepage: move is_hugepage_on_freelist inside ifdef to avoid warning
      Encode huge page size for VM_FAULT_HWPOISON errors
      x86: HWPOISON: Report correct address granuality for huge hwpoison faults
      HWPOISON: Improve comments in memory-failure.c
      HWPOISON: Convert pr_debugs to pr_info
      HWPOISON: Disable DEBUG by default
      HWPOISON: Turn addr_valid from bitfield into char
      HWPOISON: Remove retry loop for try_to_unmap
      Fix migration.c compilation on s390
      Add _addr_lsb field to ia64 siginfo
      Merge branch 'hwpoison-fixes-2.6.37' into hwpoison
      Merge branch 'hwpoison-cleanups' into hwpoison
      Merge branch 'hwpoison-hugepages' into hwpoison

Hidetoshi Seto (1):
      HWPOISON/signalfd: add support for addr_lsb

Naoya Horiguchi (10):
      hugetlb: fix metadata corruption in hugetlb_fault()
      hugetlb: add allocate function for hugepage migration
      hugetlb: redefine hugepage copy functions
      hugetlb: hugepage migration core
      HWPOISON, hugetlb: add free check to dequeue_hwpoison_huge_page()
      hugetlb: move refcounting in hugepage allocation inside hugetlb_lock
      HWPOSION, hugetlb: recover from free hugepage error when !MF_COUNT_INCREASED
      HWPOISON, hugetlb: soft offlining for hugepage
      HWPOISON, hugetlb: fix unpoison for hugepage
      Fix build error with !CONFIG_MIGRATION

 arch/ia64/include/asm/siginfo.h |    1 +
 arch/x86/mm/fault.c             |   19 ++-
 fs/hugetlbfs/inode.c            |   15 +++
 fs/signalfd.c                   |   10 ++
 include/linux/hugetlb.h         |   17 +++-
 include/linux/migrate.h         |   16 +++
 include/linux/mm.h              |   12 ++-
 include/linux/signalfd.h        |    3 +-
 mm/hugetlb.c                    |  233 +++++++++++++++++++++++++++------------
 mm/memory-failure.c             |  175 +++++++++++++++++++++--------
 mm/memory.c                     |    3 +-
 mm/migrate.c                    |  234 ++++++++++++++++++++++++++++++++++++---
 mm/rmap.c                       |   25 ++---
 13 files changed, 596 insertions(+), 167 deletions(-)
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
