Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id E81CA6B000A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 21:31:25 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f8-v6so462406qth.9
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 18:31:25 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id n32-v6si1705092qta.356.2018.06.26.18.31.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 18:31:25 -0700 (PDT)
From: Baoquan He <bhe@redhat.com>
Subject: [PATCH v5 0/4] mm/sparse: Optimize memmap allocation during sparse_init()
Date: Wed, 27 Jun 2018 09:31:12 +0800
Message-Id: <20180627013116.12411-1-bhe@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dave.hansen@intel.com, pagupta@redhat.com
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Baoquan He <bhe@redhat.com>

This is v4 post. V3 can be found here:
https://lkml.org/lkml/2018/2/27/928

V1 can be found here:
https://www.spinics.net/lists/linux-mm/msg144486.html

In sparse_init(), two temporary pointer arrays, usemap_map and map_map
are allocated with the size of NR_MEM_SECTIONS. They are used to store
each memory section's usemap and mem map if marked as present. In
5-level paging mode, this will cost 512M memory though they will be
released at the end of sparse_init(). System with few memory, like
kdump kernel which usually only has about 256M, will fail to boot
because of allocation failure if CONFIG_X86_5LEVEL=y.

In this patchset, optimize the memmap allocation code to only use
usemap_map and map_map with the size of nr_present_sections. This
makes kdump kernel boot up with normal crashkernel='' setting when
CONFIG_X86_5LEVEL=y.

Change log:
v4->v5:
  Improve patch 3/4 log according to Dave's suggestion.

  Correct the wrong copy&paste of making 'nr_consumed_maps' to
  'alloc_usemap_and_memmap' mistakenly which is pointed out by
  Dave in patch 4/4 code comment.

  Otherwise, no code change in this version.
v3->v4:
  Improve according to Dave's three concerns which are in patch 0004:

  Rename variable 'idx_present' to 'nr_consumed_maps' which used to
  index the memmap and usemap of present sections.

  Add a check if 'nr_consumed_maps' goes beyond nr_present_sections.

  Add code comment above the final for_each_present_section_nr() to
  tell why 'nr_consumed_maps' need be increased in each iteration
  whether the 'ms->section_mem_map' need cleared or out.

v2->v3:
  Change nr_present_sections as __initdata and add code comment
  according to Andrew's suggestion.

  Change the local variable 'i' as idx_present which loops over the
  present sections, and improve the code. These are suggested by
  Dave and Pankaj.

  Add a new patch 0003 which adds a new parameter 'data_unit_size'
  to function alloc_usemap_and_memmap() in which we will update 'data'
  to make it point at new position. However its type 'void *' can't give
  us needed info to do that. Need pass the unit size in. So change code
  in patch 0004 accordingly. This is a code bug fix found when tested
  the memory deployed on multiple nodes.

v1-v2:
  Split out the nr_present_sections adding as a single patch for easier
  reviewing.

  Rewrite patch log according to Dave's suggestion.

  Fix code bug in patch 0002 reported by test robot.

Baoquan He (4):
  mm/sparse: Add a static variable nr_present_sections
  mm/sparsemem: Defer the ms->section_mem_map clearing
  mm/sparse: Add a new parameter 'data_unit_size' for
    alloc_usemap_and_memmap
  mm/sparse: Optimize memmap allocation during sparse_init()

 mm/sparse-vmemmap.c |  6 ++---
 mm/sparse.c         | 72 +++++++++++++++++++++++++++++++++++++++++------------
 2 files changed, 59 insertions(+), 19 deletions(-)

-- 
2.13.6
