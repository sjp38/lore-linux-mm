Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C82ED8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 13:18:41 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i55so1420730ede.14
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 10:18:41 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g1si1541226edh.399.2019.01.15.10.18.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 10:18:40 -0800 (PST)
Date: Tue, 15 Jan 2019 10:18:31 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH -next 0/6] mm: make pinned_vm atomic and simplify users
Message-ID: <20190115181831.4zgrvyfjy2re7t43@linux-r8p5>
References: <20190115181300.27547-1-dave@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20190115181300.27547-1-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: dledford@redhat.com, jgg@mellanox.com, linux-rdma@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Also Ccing lkml, sorry.

On Tue, 15 Jan 2019, Davidlohr Bueso wrote:

>Hi,
>
>The following patches aim to provide cleanups to users that pin pages
>(mostly infiniband) by converting the counter to atomic -- note that
>Daniel Jordan also has patches[1] for the locked_vm counterpart and vfio.
>
>Apart from removing a source of mmap_sem writer, we benefit in that
>we can get rid of a lot of code that defers work when the lock cannot
>be acquired, as well as drivers avoiding mmap_sem altogether by also
>converting gup to gup_fast() and letting the mm handle it. Users
>that do the gup_longterm() remain of course under at least reader mmap_sem.
>
>Everything has been compile-tested _only_ so I hope I didn't do anything
>too stupid. Please consider for v5.1.
>
>On a similar topic and potential follow up, it would be nice to resurrect
>Peter's VM_PINNED idea in that the broken semantics that occurred after
>bc3e53f682 ("mm: distinguish between mlocked and pinned pages") are still
>present. Also encapsulating internal mm logic via mm[un]pin() instead of
>drivers having to know about internals and playing nice with compaction are
>all wins.
>
>Thanks!
>
>[1] https://lkml.org/lkml/2018/11/5/854
>
>Davidlohr Bueso (6):
>  mm: make mm->pinned_vm an atomic counter
>  mic/scif: do not use mmap_sem
>  drivers/IB,qib: do not use mmap_sem
>  drivers/IB,hfi1: do not se mmap_sem
>  drivers/IB,usnic: reduce scope of mmap_sem
>  drivers/IB,core: reduce scope of mmap_sem
>
> drivers/infiniband/core/umem.c              | 47 +++-----------------
> drivers/infiniband/hw/hfi1/user_pages.c     | 12 ++---
> drivers/infiniband/hw/qib/qib_user_pages.c  | 69 ++++++++++-------------------
> drivers/infiniband/hw/usnic/usnic_ib_main.c |  2 -
> drivers/infiniband/hw/usnic/usnic_uiom.c    | 56 +++--------------------
> drivers/infiniband/hw/usnic/usnic_uiom.h    |  1 -
> drivers/misc/mic/scif/scif_rma.c            | 38 +++++-----------
> fs/proc/task_mmu.c                          |  2 +-
> include/linux/mm_types.h                    |  2 +-
> kernel/events/core.c                        |  8 ++--
> kernel/fork.c                               |  2 +-
> mm/debug.c                                  |  3 +-
> 12 files changed, 57 insertions(+), 185 deletions(-)
>
>-- 
>2.16.4
>
