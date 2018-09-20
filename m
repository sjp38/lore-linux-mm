Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id D19F78E0001
	for <linux-mm@kvack.org>; Thu, 20 Sep 2018 18:24:22 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r130-v6so4689268pgr.13
        for <linux-mm@kvack.org>; Thu, 20 Sep 2018 15:24:22 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id b23-v6si24995048pgj.571.2018.09.20.15.24.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Sep 2018 15:24:21 -0700 (PDT)
Subject: [PATCH v4 0/5] Address issues slowing persistent memory
 initialization
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Thu, 20 Sep 2018 15:24:09 -0700
Message-ID: <20180920215824.19464.8884.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, mingo@kernel.org, dave.hansen@intel.com, jglisse@redhat.com, akpm@linux-foundation.org, logang@deltatee.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com

This patch set is meant to be a v4 to my earlier patch set "Address issues
slowing memory init"[1], and a follow-up to my earlier patch set "Address
issues slowing persistent memory initialization"[2].

Excluding any gains seen from using the vm_debug option to disable page
init poisoning I see a total reduction in file-system init time of about
two and a half minutes, or 65%, for a system initializing btrfs on a 12TB
block of persistent memory split evenly over 4 NUMA nodes.

Since the last patch set I have reworked the first patch to provide a more
generic disable implementation that can be extended in the future.

I tweaked the commit message for the second patch slightly to reflect why
we might want to use a non-atomic __set_bit versus the atomic set_bit.

I have modified the third patch to make it so that it can merge onto either
the linux git tree or the linux-next git tree. The patch set that Dan
Williams has outstanding may end up conflicting with this patch depending
on the merge order. If his are merged first I believe the code I changed
in mm/hmm.c could be dropped entirely.

The fourth patch has been split into two and focused more on the async
scheduling portion of the nvdimm code. The result is much cleaner than the
original approach in that instead of having two threads running we are now
getting the thread running where we wanted it to be.

The last change for all patches is that I have updated my email address to
alexander.h.duyck@linux.intel.com to reflect the fact that I have changed
teams within Intel. I will be trying to use that for correspondence going
forward instead of my gmail account.

[1]: https://lkml.org/lkml/2018/9/5/924
[2]: https://lkml.org/lkml/2018/9/11/10
[3]: https://lkml.org/lkml/2018/9/13/104

---

Alexander Duyck (5):
      mm: Provide kernel parameter to allow disabling page init poisoning
      mm: Create non-atomic version of SetPageReserved for init use
      mm: Defer ZONE_DEVICE page initialization to the point where we init pgmap
      async: Add support for queueing on specific node
      nvdimm: Schedule device registration on node local to the device


 Documentation/admin-guide/kernel-parameters.txt |   12 +++
 drivers/nvdimm/bus.c                            |   19 ++++
 include/linux/async.h                           |   20 ++++-
 include/linux/mm.h                              |    2 
 include/linux/page-flags.h                      |    9 ++
 kernel/async.c                                  |   36 ++++++--
 kernel/memremap.c                               |   24 ++---
 mm/debug.c                                      |   46 ++++++++++
 mm/hmm.c                                        |   12 ++-
 mm/memblock.c                                   |    5 -
 mm/page_alloc.c                                 |  101 ++++++++++++++++++++++-
 mm/sparse.c                                     |    4 -
 12 files changed, 243 insertions(+), 47 deletions(-)

--
