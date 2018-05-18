Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0F16B05DE
	for <linux-mm@kvack.org>; Fri, 18 May 2018 10:37:53 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id 65-v6so4739102qkl.11
        for <linux-mm@kvack.org>; Fri, 18 May 2018 07:37:53 -0700 (PDT)
Received: from a9-114.smtp-out.amazonses.com (a9-114.smtp-out.amazonses.com. [54.240.9.114])
        by mx.google.com with ESMTPS id a7-v6si3381248qvm.21.2018.05.18.07.37.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 18 May 2018 07:37:52 -0700 (PDT)
Date: Fri, 18 May 2018 14:37:52 +0000
From: Christopher Lameter <cl@linux.com>
Subject: [LSFMM] RDMA data corruption potential during FS writeback
Message-ID: <0100016373af827b-e6164b8d-f12e-4938-bf1f-2f85ec830bc0-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-rdma@vger.kernel.org
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Jason Gunthorpe <jgg@ziepe.ca>

There was a session at the Linux Filesystem and Memory Management summit
on issues that are caused by devices using get_user_pages() or elevated
refcounts to pin pages and then do I/O on them.

See https://lwn.net/Articles/753027/

Basically filesystems need to mark the pages readonly during writeback.
Concurrent DMA into the page while it is written by a filesystem can cause
corrupted data being written to the disk, cause incorrect checksums etc
etc.

The solution that was proposed at the meeting was that mmu notifiers can
remedy that situation by allowing callbacks to the RDMA device to ensure
that the RDMA device and the filesystem do not do concurrent writeback.

This issue has been around for a long time and so far not caused too much
grief it seems. Doing I/O to two devices from the same memory location is
naturally a bit inconsistent in itself.

But could we do more to prevent issues here? I think what may be useful is
to not allow the memory registrations of file back writable mappings
unless the device driver provides mmu callbacks or something like that.

There is also the longstanding issue of the refcounts that are held over
long time periods. If we require mmu notifier callbacks then we may as
well go to on demand paging mode for RDMA memory registrations. This
avoids increasing the refcounts long term and allows easy access control /
page removal for memory management.

There may even be more issues if DAX is being used but the FS writeback
has the potential of biting anyone at this point it seems.

I think we need to put some thought into these issues and we need some
coordination between the RDMA developers and memory management. RDMA seems
to be more and more important and thus its likely that issues like this
will become more important.
