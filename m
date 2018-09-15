Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A81AD8E0001
	for <linux-mm@kvack.org>; Sat, 15 Sep 2018 12:34:47 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x2-v6so5158768pgp.4
        for <linux-mm@kvack.org>; Sat, 15 Sep 2018 09:34:47 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id u10-v6si9862703plr.58.2018.09.15.09.34.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Sep 2018 09:34:46 -0700 (PDT)
Subject: [PATCH 0/3] mm: Randomize free memory
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 15 Sep 2018 09:23:02 -0700
Message-ID: <153702858249.1603922.12913911825267831671.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Data exfiltration attacks via speculative execution and
return-oriented-programming attacks rely on the ability to infer the
location of sensitive data objects. The kernel page allocator, has
predictable first-in-first-out behavior for physical pages. Pages are
freed in physical address order when first onlined. There are also
mechanisms like CMA that can free large contiguous areas at once
increasing the predictability of allocations in physical memory.

In addition to the security implications this randomization also
stabilizes the average performance of direct-mapped memory-side caches.
This includes memory-side caches like the one on the Knights Landing
processor and those generally described by the ACPI HMAT (Heterogeneous
Memory Attributes Table [1]). Cache conflicts are spread over a random
distribution rather than localized.

Given the performance sensitivity of the page allocator this
randomization is only performed for MAX_ORDER (4MB by default) pages. A
kernel parameter, page_alloc.shuffle_page_order, is included to change
the page size where randomization occurs.

[1]: See ACPI 6.2 Section 5.2.27.5 Memory Side Cache Information Structure 

---

Dan Williams (3):
      mm: Shuffle initial free memory
      mm: Move buddy list manipulations into helpers
      mm: Maintain randomization of page free lists


 include/linux/list.h     |   17 +++
 include/linux/mm.h       |    5 -
 include/linux/mm_types.h |    3 +
 include/linux/mmzone.h   |   57 ++++++++++
 mm/bootmem.c             |    9 +-
 mm/compaction.c          |    4 -
 mm/nobootmem.c           |    7 +
 mm/page_alloc.c          |  267 +++++++++++++++++++++++++++++++++++++++-------
 8 files changed, 317 insertions(+), 52 deletions(-)
