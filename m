Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86DCC6B2483
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 01:21:21 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id x125so5639221qka.17
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 22:21:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v1si835080qtc.391.2018.11.20.22.21.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 22:21:20 -0800 (PST)
From: Peter Xu <peterx@redhat.com>
Subject: [PATCH RFC v3 0/4] mm: some enhancements to the page fault mechanism
Date: Wed, 21 Nov 2018 14:20:59 +0800
Message-Id: <20181121062103.18835-1-peterx@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Keith Busch <keith.busch@intel.com>, Jerome Glisse <jglisse@redhat.com>, peterx@redhat.com, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, Matthew Wilcox <willy@infradead.org>, Al Viro <viro@zeniv.linux.org.uk>, Andrea Arcangeli <aarcange@redhat.com>, Huang Ying <ying.huang@intel.com>, Mike Kravetz <mike.kravetz@oracle.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, "Michael S. Tsirkin" <mst@redhat.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Pavel Tatashin <pavel.tatashin@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>

v3:
- fix up issues that krobot reported, rebase

This is an RFC series as cleanup and enhancements to current page
fault logic.  The whole idea comes from the discussion between Andrea
and Linus on the bug reported by syzbot here:

  https://lkml.org/lkml/2017/11/2/833

Basically it does two things:

  (a) Allows the page fault logic to be more interactive on not only
      SIGKILL, but also the rest of userspace signals, and,

  (b) Allows the page fault retry (VM_FAULT_RETRY) to happen for more
      than once.

For (a): with the changes we should be able to react faster when page
faults are working in parallel with userspace signals like SIGSTOP and
SIGCONT (and more), and with that we can remove the buggy part in
userfaultfd and benefit the whole page fault mechanism on faster
signal processing to reach the userspace.

For (b), we should be able to allow the page fault handler to loop for
even more than twice.  Some context: for now since we have
FAULT_FLAG_ALLOW_RETRY we can allow to retry the page fault once with
the same interrupt context, however never more than twice.  This can
be not only a potential cleanup to remove this assumption since AFAIU
the code itself doesn't really have this twice-only limitation (though
that should be a protective approach in the past), at the same time
it'll greatly simplify future works like userfaultfd write-protect
where it's possible to retry for more than twice (please have a look
at [1] below for a possible user that might require the page fault to
be handled for a third time; if we can remove the retry limitation we
can simply drop that patch and those complexity).

Some more details on each of the patch (even more in commit messages):

Patch 1: A cleanup of existing GUP code to rename the confusing
         "nonblocking" parameter to "locked" which seems suite more.

Patch 2: Complete the page fault faster for non-sigkill signals

Patch 3: Remove the limitation to only allow to retry page fault for
         twice (page fault part)

Patch 4: Similar work of patch 3, but for GUP.

The series is only lightly tested.  Before running more tests, I'd be
really glad to see whether there's any feedback first.

Looking forward to your comments.  Thanks,

[1] https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git/commit/?h=userfault&id=b245ecf6cf59156966f3da6e6b674f6695a5ffa5

Peter Xu (4):
  mm: gup: rename "nonblocking" to "locked" where proper
  mm: userfault: return VM_FAULT_RETRY on signals
  mm: allow VM_FAULT_RETRY for multiple times
  mm: gup: allow VM_FAULT_RETRY for multiple times

 arch/alpha/mm/fault.c      |  4 +--
 arch/arc/mm/fault.c        | 12 ++++----
 arch/arm/mm/fault.c        | 17 ++++++-----
 arch/arm64/mm/fault.c      | 11 ++-----
 arch/hexagon/mm/vm_fault.c |  3 +-
 arch/ia64/mm/fault.c       |  3 +-
 arch/m68k/mm/fault.c       |  5 +---
 arch/microblaze/mm/fault.c |  3 +-
 arch/mips/mm/fault.c       |  3 +-
 arch/nds32/mm/fault.c      |  7 ++---
 arch/nios2/mm/fault.c      |  5 +---
 arch/openrisc/mm/fault.c   |  3 +-
 arch/parisc/mm/fault.c     |  4 +--
 arch/powerpc/mm/fault.c    |  9 ++----
 arch/riscv/mm/fault.c      |  9 ++----
 arch/s390/mm/fault.c       | 14 ++++-----
 arch/sh/mm/fault.c         |  5 +++-
 arch/sparc/mm/fault_32.c   |  4 ++-
 arch/sparc/mm/fault_64.c   |  4 ++-
 arch/um/kernel/trap.c      |  6 ++--
 arch/unicore32/mm/fault.c  | 10 ++-----
 arch/x86/mm/fault.c        | 13 ++++++--
 arch/xtensa/mm/fault.c     |  4 ++-
 fs/userfaultfd.c           | 24 ---------------
 mm/gup.c                   | 61 +++++++++++++++++++++-----------------
 mm/hugetlb.c               |  8 ++---
 26 files changed, 114 insertions(+), 137 deletions(-)

-- 
2.17.1
