Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1047F6B0253
	for <linux-mm@kvack.org>; Tue, 10 Jan 2017 19:55:42 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id f4so96536352qte.1
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 16:55:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g22si2558436qkh.329.2017.01.10.16.55.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jan 2017 16:55:40 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [RFC] userfaultfd: fix SIGBUS resulting from false rwsem wakeups
Date: Wed, 11 Jan 2017 01:55:34 +0100
Message-Id: <20170111005535.13832-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Hello everyone,

Mike noticed the userfaultfd selftest on 32-way SMP bare metal
triggers a SIGBUS and I could reproduce with KVM -smp 32 Fedora
guests. This never happened with fewer CPUs.

I grabbed the stack trace of the false wakeup. It looks like the rwsem
code can wake the task unexpectedly. We knew the scheduler didn't like
the idea of providing perfect wakeups, and the current way of relying
on the scheduler wakeups to be perfect has already been questioned,
but this seems a somewhat wider issue that affects part outside of the
scheduler too. I was undecided at the idea the scheduler could ignore
a __set_current_state(TASK_INTERRUPTIBLE); schedule(); and in fact it
never did, but the rwsem wakeup is external to the scheduler so we
need to fix this regardless.

The SMP race condition is so rare it doesn't even happen on fewer than
32 CPUs, and most certainly it won't happen on anything but the
selftest itself. If it happens the side effect is just the SIGBUS
killing the task gracefully, there's zero risk of memory corruption,
zero fs corruption, no memleaks and there are no security issues
associated with this race condition either. So it's not major concern
but it must still be fixed ASAP. For those usages where userfaultfd is
used for vma-less enforcement of no access over memory holes, it would
even a lesser concern.

This is very lightly tested so far, comments welcome.

Note: this is fully orthogonal issue with the new userfaultfd features
in -mm, so I'm posting this against upstream.

Note2: my userfault aa.git branch has the one-more-time VM_FAULT_RETRY
feature for the WP support which hides the problem 100% successfully
but it's just doing it by luck. That's needed for another reason and
it'll be still needed on top of this. The chances of hitting the race
twice in a row is zero, this is why it gets hidden, but in theory this
could happen twice in a row and the fix must handle twice in a row
too. So this patch has to be tested against current upstream only or
you can't reproduce any problem in the first place. Once we converge
on a reviewed solution I'll forward port it to -mm/userfault branch (I
doubt it applies clean).

Andrea Arcangeli (1):
  userfaultfd: fix SIGBUS resulting from false rwsem wakeups

 fs/userfaultfd.c | 37 +++++++++++++++++++++++++++++++++++--
 1 file changed, 35 insertions(+), 2 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
