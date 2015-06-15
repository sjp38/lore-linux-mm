Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 324BC6B0072
	for <linux-mm@kvack.org>; Mon, 15 Jun 2015 13:22:26 -0400 (EDT)
Received: by qkdm188 with SMTP id m188so36111917qkd.1
        for <linux-mm@kvack.org>; Mon, 15 Jun 2015 10:22:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i77si4134271qkh.107.2015.06.15.10.22.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jun 2015 10:22:17 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/7] userfault21 update
Date: Mon, 15 Jun 2015 19:22:04 +0200
Message-Id: <1434388931-24487-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

This is an incremental update to the userfaultfd code in -mm.

This fixes two bugs that could cause some malfunction (but nothing
that could cause memory corruption or kernel crashes of any sort,
neither in kernel nor userland).

This also introduces some enhancement: gdb now runs fine, signals can
interrupt userfaults (userfaults are retried when signal returns),
read blocking got wakeone behavior (with benchmark results in commit
header), the UFFDIO_API invocation is enforced before other ioctl can
run (to enforce future backwards compatibility just in case of API
bumps), one dependency on a scheduler change has been reverted.

Notably this introduces the testsuite as well. A good way to run the
testsuite is:

# it will use 10MiB-~6GiB 999 bounces, continue forever unless an error triggers
while ./userfaultfd $[RANDOM % 6000 + 10] 999; do true; done

What caused a significant amount of time wasted, had nothing to do
with userfaultfd. The testsuite exposed erratic memcmp/bcmp retvals if
part of the strings compared can change under memcmp/bcmp (while still
being different in other parts of the string that aren't actually
changing). I will provide a separate standalone testcase for this not
using userfaultfd (I already created it to be sure it isn't a bug in
userfaultfd, and nevertheless my my_bcmp works fine even with
userfaultfd). Insisting memcmp/bcmp would eventually lead to the
correct result that in kernel-speak to be initially (but erroneously)
translated to missing TLB flush (or cache flush but on x86 unlikely)
or a pagefault hitting on the zeropage somehow, or some other subtle
kernel bug. Eventually I had to consider the possibiltity memcmp or
bcmp core library functions were broken, despite how unlikely this
sounds. It might be possible that this only happens if the memory
changing is inside the "len" range being compared and that nothing
goes wrong if the data changing is beyond the end of the "len" even if
in the same cacheline. So it might be possible that it's perfectly
correct in C standard terms, but the total erratic result is
unacceptable to me and it makes memcmp/bcmp very risky to use in
multithreaded programs. I will ensure this gets fixed in my systems
with perhaps slower versions of memcpy/bcmp. If the two pages never
actually are the same at any given time (no matter if they're
changing) both bcmp and memcmp can't keep returning an erratic racy 0
here. If this is safe by C standard, this still wouldn't be safe
enough for me. It's unclear how this erratic result materializes at
this point and if SIMD instructions have special restrictions on
memory that is modified by other CPUs. CPU bugs in SIMD cannot be
ruled out either yet.

Andrea Arcangeli (7):
  userfaultfd: require UFFDIO_API before other ioctls
  userfaultfd: propagate the full address in THP faults
  userfaultfd: allow signals to interrupt a userfault
  userfaultfd: avoid missing wakeups during refile in userfaultfd_read
  userfaultfd: switch to exclusive wakeup for blocking reads
  userfaultfd: Revert "userfaultfd: waitqueue: add nr wake parameter to
    __wake_up_locked_key"
  userfaultfd: selftest

 fs/userfaultfd.c                         |  78 +++-
 include/linux/wait.h                     |   5 +-
 kernel/sched/wait.c                      |   7 +-
 mm/huge_memory.c                         |  10 +-
 net/sunrpc/sched.c                       |   2 +-
 tools/testing/selftests/vm/Makefile      |   4 +-
 tools/testing/selftests/vm/userfaultfd.c | 669 +++++++++++++++++++++++++++++++
 7 files changed, 752 insertions(+), 23 deletions(-)
 create mode 100644 tools/testing/selftests/vm/userfaultfd.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
