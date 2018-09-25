Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 205978E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 16:18:12 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e6-v6so3212469pge.5
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 13:18:12 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id o11-v6si3282044pls.76.2018.09.25.13.18.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 13:18:10 -0700 (PDT)
Subject: [PATCH v5 0/4] Address issues slowing persistent memory
 initialization
From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Date: Tue, 25 Sep 2018 13:18:08 -0700
Message-ID: <20180925200551.3576.18755.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org
Cc: pavel.tatashin@microsoft.com, mhocko@suse.com, dave.jiang@intel.com, dave.hansen@intel.com, jglisse@redhat.com, rppt@linux.vnet.ibm.com, dan.j.williams@intel.com, logang@deltatee.com, mingo@kernel.org, kirill.shutemov@linux.intel.com

This patch set is meant to be a v5 of my earlier submission with the same
title[1].

The main changes from the previous version are that I have added a new
patch to address an issue that had disabled deferred memory init on my
system due to recent config changes related to CONFIG_NO_BOOTMEM. In
addition I dropped the original patches 4 and 5 from the previous set as
that is going to need to be a separate set of patches.

The main thing this patch set achieves is that it allows us to initialize
each node worth of persistent memory independently. As a result we reduce
page init time by about 2 minutes because instead of taking 30 to 40 seconds
per node and going through each node one at a time, we process all 4 nodes
in parallel in the case of a 12TB persistent memory setup spread evenly over
4 nodes.

[1]: https://lkml.org/lkml/2018/9/21/4
---

Alexander Duyck (4):
      mm: Remove now defunct NO_BOOTMEM from depends list for deferred init
      mm: Provide kernel parameter to allow disabling page init poisoning
      mm: Create non-atomic version of SetPageReserved for init use
      mm: Defer ZONE_DEVICE page initialization to the point where we init pgmap


 Documentation/admin-guide/kernel-parameters.txt |   12 +++
 arch/csky/Kconfig                               |    1 
 include/linux/mm.h                              |    2 
 include/linux/page-flags.h                      |    9 ++
 kernel/memremap.c                               |   24 ++---
 mm/Kconfig                                      |    1 
 mm/debug.c                                      |   46 ++++++++++
 mm/hmm.c                                        |   12 ++-
 mm/memblock.c                                   |    5 -
 mm/page_alloc.c                                 |  101 ++++++++++++++++++++++-
 mm/sparse.c                                     |    4 -
 11 files changed, 184 insertions(+), 33 deletions(-)

--
