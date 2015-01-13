Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id D62396B0074
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 11:38:58 -0500 (EST)
Received: by mail-qg0-f51.google.com with SMTP id i50so2942556qgf.10
        for <linux-mm@kvack.org>; Tue, 13 Jan 2015 08:38:58 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 5si21391430qcl.7.2015.01.13.08.38.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jan 2015 08:38:52 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/5] leverage FAULT_FOLL_ALLOW_RETRY in get_user_pages try#2
Date: Tue, 13 Jan 2015 17:37:49 +0100
Message-Id: <1421167074-9789-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Michel Lespinasse <walken@google.com>, Andrew Jones <drjones@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Andres Lagar-Cavilla <andreslc@google.com>, Minchan Kim <minchan@kernel.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Peter Feiner <pfeiner@google.com>, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, James Bottomley <James.Bottomley@HansenPartnership.com>, David Miller <davem@davemloft.net>, Steve Capper <steve.capper@linaro.org>, Johannes Weiner <jweiner@redhat.com>

Last submit didn't go into -mm/3.19-rc, no prob but here I retry
(possibly too early for 3.20-rc but I don't expect breakages in this
area post -rc4) after a rebase on upstream.

FAULT_FOLL_ALLOW_RETRY allows the page fault to drop the mmap_sem for
reading to reduce the mmap_sem contention (for writing), like while
waiting for I/O completion. The problem is that right now practically
no get_user_pages call uses FAULT_FOLL_ALLOW_RETRY, so we're not
leveraging that nifty feature.

Andres fixed it for the KVM page fault. However get_user_pages_fast
remains uncovered, and 99% of other get_user_pages aren't using it
either (the only exception being FOLL_NOWAIT in KVM which is really
nonblocking and in fact it doesn't even release the mmap_sem).

So this patchsets extends the optimization Andres did in the KVM page
fault to the whole kernel. It makes most important places (including
gup_fast) to use FAULT_FOLL_ALLOW_RETRY to reduce the mmap_sem hold
times during I/O.

The only few places that remains uncovered are drivers like v4l and
other exceptions that tends to work on their own memory and they're
not working on random user memory (for example like O_DIRECT that uses
gup_fast and is fully covered by this patch).

A follow up patch should probably also add a printk_once warning to
get_user_pages that should go obsolete and be phased out
eventually. The "vmas" parameter of get_user_pages makes it
fundamentally incompatible with FAULT_FOLL_ALLOW_RETRY (vmas array
becomes meaningless the moment the mmap_sem is released). 

While this is just an optimization, this becomes an absolute
requirement for the userfaultfd feature
http://lwn.net/Articles/615086/ .

The userfaultfd allows to block the page fault, and in order to do so
I need to drop the mmap_sem first. So this patch also ensures that all
memory where userfaultfd could be registered by KVM, the very first
fault (no matter if it is a regular page fault, or a get_user_pages)
always has FAULT_FOLL_ALLOW_RETRY set. Then the userfaultfd blocks and
it is waken only when the pagetable is already mapped. The second
fault attempt after the wakeup doesn't need FAULT_FOLL_ALLOW_RETRY, so
it's ok to retry without it.

Thanks,
Andrea

Andrea Arcangeli (5):
  mm: gup: add get_user_pages_locked and get_user_pages_unlocked
  mm: gup: add __get_user_pages_unlocked to customize gup_flags
  mm: gup: use get_user_pages_unlocked within get_user_pages_fast
  mm: gup: use get_user_pages_unlocked
  mm: gup: kvm use get_user_pages_unlocked

 arch/mips/mm/gup.c                 |   8 +-
 arch/s390/mm/gup.c                 |   6 +-
 arch/sh/mm/gup.c                   |   6 +-
 arch/sparc/mm/gup.c                |   6 +-
 arch/x86/mm/gup.c                  |   7 +-
 drivers/media/pci/ivtv/ivtv-udma.c |   6 +-
 drivers/scsi/st.c                  |   7 +-
 drivers/video/fbdev/pvr2fb.c       |   6 +-
 include/linux/kvm_host.h           |  11 --
 include/linux/mm.h                 |  11 ++
 mm/gup.c                           | 203 ++++++++++++++++++++++++++++++++++---
 mm/nommu.c                         |  33 ++++++
 mm/process_vm_access.c             |   7 +-
 mm/util.c                          |  10 +-
 net/ceph/pagevec.c                 |   6 +-
 virt/kvm/async_pf.c                |   2 +-
 virt/kvm/kvm_main.c                |  50 +--------
 17 files changed, 261 insertions(+), 124 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
