Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9958E0001
	for <linux-mm@kvack.org>; Mon, 21 Jan 2019 12:42:49 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id r131so9935097oia.7
        for <linux-mm@kvack.org>; Mon, 21 Jan 2019 09:42:49 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id x79si2933700oif.183.2019.01.21.09.42.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jan 2019 09:42:48 -0800 (PST)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH v2 -next 0/6] mm: make pinned_vm atomic and simplify users
Date: Mon, 21 Jan 2019 09:42:14 -0800
Message-Id: <20190121174220.10583-1-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dledford@redhat.com, jgg@mellanox.com, jack@suse.de, ira.weiny@intel.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@stgolabs.net

Changes from v1 (https://patchwork.kernel.org/cover/10764923/):
 - Converted pinned_vm to atomic64 instead of atomic_long such that
   infiniband need not worry about overflows.

 - Rebased patch 1 and added Ira's reviews as well as Parvi's review
   for patch 5 (thanks!).
   
--------

Hi,

The following patches aim to provide cleanups to users that pin pages
(mostly infiniband) by converting the counter to atomic -- note that
Daniel Jordan also has patches[1] for the locked_vm counterpart and vfio.

Apart from removing a source of mmap_sem writer, we benefit in that
we can get rid of a lot of code that defers work when the lock cannot
be acquired, as well as drivers avoiding mmap_sem altogether by also
converting gup to gup_fast() and letting the mm handle it. Users
that do the gup_longterm() remain of course under at least reader mmap_sem.

Everything has been compile-tested _only_ so I hope I didn't do anything
too stupid. Please consider for v5.1.

On a similar topic and potential follow up, it would be nice to resurrect
Peter's VM_PINNED idea in that the broken semantics that occurred after
bc3e53f682 ("mm: distinguish between mlocked and pinned pages") are still
present. Also encapsulating internal mm logic via mm[un]pin() instead of
drivers having to know about internals and playing nice with compaction are
all wins.

Thanks!

[1] https://lkml.org/lkml/2018/11/5/854

Davidlohr Bueso (6):
  mm: make mm->pinned_vm an atomic64 counter
  mic/scif: do not use mmap_sem
  drivers/IB,qib: do not use mmap_sem
  drivers/IB,hfi1: do not se mmap_sem
  drivers/IB,usnic: reduce scope of mmap_sem
  drivers/IB,core: reduce scope of mmap_sem

 drivers/infiniband/core/umem.c              | 47 +++-----------------
 drivers/infiniband/hw/hfi1/user_pages.c     | 12 ++---
 drivers/infiniband/hw/qib/qib_user_pages.c  | 69 ++++++++++-------------------
 drivers/infiniband/hw/usnic/usnic_ib_main.c |  2 -
 drivers/infiniband/hw/usnic/usnic_uiom.c    | 56 +++--------------------
 drivers/infiniband/hw/usnic/usnic_uiom.h    |  1 -
 drivers/misc/mic/scif/scif_rma.c            | 38 +++++-----------
 fs/proc/task_mmu.c                          |  2 +-
 include/linux/mm_types.h                    |  2 +-
 kernel/events/core.c                        |  8 ++--
 kernel/fork.c                               |  2 +-
 mm/debug.c                                  |  3 +-
 12 files changed, 57 insertions(+), 185 deletions(-)

-- 
2.16.4
