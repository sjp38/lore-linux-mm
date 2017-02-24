Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 897E46B0388
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 13:20:03 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id n127so26089597qkf.3
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 10:20:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s11si6177752qtg.168.2017.02.24.10.20.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 10:20:02 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/3] userfaultfd non-cooperative further update for 4.11 merge window
Date: Fri, 24 Feb 2017 19:19:54 +0100
Message-Id: <20170224181957.19736-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Hello,

unfortunately I noticed one relevant bug in userfaultfd_exit while
doing more testing. I've been doing testing before and this was also
tested by kbuild bot and exercised by the selftest, but this bug never
reproduced before.

I dropped userfaultfd_exit as result. I dropped it because of
implementation difficulty in receiving signals in __mmput and because
I think -ENOSPC as result from the background UFFDIO_COPY should be
enough already.

Before I decided to remove userfaultfd_exit, I noticed
userfaultfd_exit wasn't exercised by the selftest and when I tried to
exercise it, after moving it to a more correct place in __mmput where
it would make more sense and where the vma list is stable, it resulted
in the event_wait_completion in D state. So then I added the second
patch to be sure even if we call userfaultfd_event_wait_completion too
late during task exit(), we won't risk to generate tasks in D
state. The same check exists in handle_userfault() for the same
reason, except it makes a difference there, while here is just a
robustness check and it's run under WARN_ON_ONCE.

While looking at the userfaultfd_event_wait_completion() function I
looked back at its callers too while at it and I think it's not ok to
stop executing dup_fctx on the fcs list because we relay on
userfaultfd_event_wait_completion to execute
userfaultfd_ctx_put(fctx->orig) which is paired against
userfaultfd_ctx_get(fctx->orig) in dup_userfault just before
list_add(fcs). This change only takes care of fctx->orig but this area
also needs further review looking for similar problems in fctx->new.

The only patch that is urgent is the first because it's an use after
free during a SMP race condition that affects all processes if
CONFIG_USERFAULTFD=y. Very hard to reproduce though and probably
impossible without SLUB poisoning enabled.

Mike and Pavel please review, thanks!
Andrea

Andrea Arcangeli (3):
  userfaultfd: non-cooperative: rollback userfaultfd_exit
  userfaultfd: non-cooperative: robustness check
  userfaultfd: non-cooperative: release all ctx in
    dup_userfaultfd_complete

 fs/userfaultfd.c                 | 47 +++++++---------------------------------
 include/linux/userfaultfd_k.h    |  6 -----
 include/uapi/linux/userfaultfd.h |  5 +----
 kernel/exit.c                    |  1 -
 4 files changed, 9 insertions(+), 50 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
