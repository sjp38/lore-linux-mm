Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 225C36B025E
	for <linux-mm@kvack.org>; Mon, 16 Jan 2017 13:04:13 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id g49so101685272qta.0
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 10:04:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k84si8883276qkh.199.2017.01.16.10.04.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 10:04:12 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/1] userfaultfd: shmem: avoid a lockup resulting from corrupted page->flags
Date: Mon, 16 Jan 2017 19:04:07 +0100
Message-Id: <20170116180408.12184-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Hello,

The userfaultfd_shmem selftest is currently locking up in D state
pretty quickly on current -mm and on the aa.git userfault branch based
on upstream.

Nothing changed on the userfault side of things and I surely let it
run the shmem stress test a while without noticing issues. I initially
thought some other recent change in shmem broke something. After
finishing reviewing all lock/unlock_page I figured it had to be
something else as nobody was holding the lock and surprisingly lockdep
never complained about locking errors.

Something must have changed that gives the lookup more concurrency and
exposed this problem in the page->flags non atomic update that
corrupts the PG_lock bit.

Good thing the userfault selftest is very aggressive at reproducing
any sort of SMP race conditions by starting 3 threads per CPU.

This fix solves the lockup for me. Mike can you verify on your setup
that reproduced this originally?

On a side note: the fix for the false positive SIGBUS is already
included in -mm and it happened to apply clean at the end. I would
suggest to apply that at the top of the userfault queue as it's the
only "fix" in queue for the upstream userfault code (even if not
particularly concerning and unnoticeable in real workloads). This new
fix is not relevant for upstream, but for -mm only.

Thanks.

Andrea Arcangeli (1):
  userfaultfd: shmem: avoid a lockup resulting from corrupted
    page->flags

 mm/shmem.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
