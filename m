Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 99C688E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 19:43:38 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id bh1-v6so10644215plb.15
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 16:43:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i5-v6sor2564805pgl.368.2018.09.10.16.43.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Sep 2018 16:43:37 -0700 (PDT)
Subject: [PATCH 0/4] Address issues slowing persistent memory initialization
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Mon, 10 Sep 2018 16:43:35 -0700
Message-ID: <20180910232615.4068.29155.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, mingo@kernel.org, dave.hansen@intel.com, jglisse@redhat.com, akpm@linux-foundation.org, logang@deltatee.com, dan.j.williams@intel.com, kirill.shutemov@linux.intel.com

This patch set is meant to be a v3 to my earlier patch set "Address issues
slowing memory init"[1]. However I have added 2 additional patches to
address issues seen in which NVDIMM memory was slow to initialize
especially on systems with multiple NUMA nodes.

Since v2 of the patch set I have replaced the config option to work around
the page init poisoning with a kernel parameter. I also updated one comment
based on input from Michal.

The third patch in this set is new and is meant to address the need to
defer some page initialization to outside of the hot-plug lock. It is
loosely based on the original patch set by Dan Williams to perform
asynchronous page init for ZONE_DEVICE pages[2]. However, it is  based
more around the deferred page init model where memory init is deferred to a
fixed point, which in this case is to just outside of the hot-plug lock.

The fourth patch allows nvdimm init to be more node specific where
possible. I basically just copy/pasted the approach used in
pci_call_probe to allow for us to get the initialization code on the node
as close to the memory as possible. Doing so allows us to save considerably
on init time.

[1]: https://lkml.org/lkml/2018/9/5/924
[2]: https://lkml.org/lkml/2018/7/16/828

---

Alexander Duyck (4):
      mm: Provide kernel parameter to allow disabling page init poisoning
      mm: Create non-atomic version of SetPageReserved for init use
      mm: Defer ZONE_DEVICE page initialization to the point where we init pgmap
      nvdimm: Trigger the device probe on a cpu local to the device


 Documentation/admin-guide/kernel-parameters.txt |    8 ++
 drivers/nvdimm/bus.c                            |   45 ++++++++++
 include/linux/mm.h                              |    2 
 include/linux/page-flags.h                      |    9 ++
 kernel/memremap.c                               |   24 ++---
 mm/debug.c                                      |   16 +++
 mm/hmm.c                                        |   12 ++-
 mm/memblock.c                                   |    5 -
 mm/page_alloc.c                                 |  106 ++++++++++++++++++++++-
 mm/sparse.c                                     |    4 -
 10 files changed, 200 insertions(+), 31 deletions(-)

--
