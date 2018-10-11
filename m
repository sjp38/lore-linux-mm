Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 663976B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 21:48:35 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q143-v6so4946511pgq.12
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 18:48:35 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id 69-v6si32149751pfw.261.2018.10.10.18.48.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 18:48:34 -0700 (PDT)
Subject: [PATCH v4 0/3] Randomize free memory
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 10 Oct 2018 18:36:41 -0700
Message-ID: <153922180166.838512.8260339805733812034.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.orgkeescook@chromium.org

Changes since v3 [1]:
* Replace runtime 'shuffle_page_order' parameter with a compile-time
  CONFIG_SHUFFLE_PAGE_ALLOCATOR on/off switch and a
  CONFIG_SHUFFLE_PAGE_ORDER if a distro decides that the default 4MB
  shuffling boundary is not sufficient. Administrators will not be
  burdened with making this decision. (Michal)

* Move shuffle related code into a new mm/shuffle.c file.

[1]: https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1783262.html

---

Some data exfiltration and return-oriented-programming attacks rely on
the ability to infer the location of sensitive data objects. The kernel
page allocator, especially early in system boot, has predictable
first-in-first out behavior for physical pages. Pages are freed in
physical address order when first onlined.

Quoting Kees:
    "While we already have a base-address randomization
     (CONFIG_RANDOMIZE_MEMORY), attacks against the same hardware and
     memory layouts would certainly be using the predictability of
     allocation ordering (i.e. for attacks where the base address isn't
     important: only the relative positions between allocated memory).
     This is common in lots of heap-style attacks. They try to gain
     control over ordering by spraying allocations, etc.

     I'd really like to see this because it gives us something similar
     to CONFIG_SLAB_FREELIST_RANDOM but for the page allocator."

Another motivation for this change is performance in the presence of a
memory-side cache. In the future, memory-side-cache technology will be
available on generally available server platforms. The proposed
randomization approach has been measured to improve the cache conflict
rate by a factor of 2.5X on a well-known Java benchmark. It avoids
performance peaks and valleys to provide more predictable performance.

The initial randomization in patch1 can be undone over time so patch3 is
introduced to inject entropy on page free decisions. It is reasonable to
ask if the page free entropy is sufficient, but it is not enough due to
the in-order initial freeing of pages. At the start of that process
putting page1 in front or behind page0 still keeps them close together,
page2 is still near page1 and has a high chance of being adjacent. As
more pages are added ordering diversity improves, but there is still
high page locality for the low address pages and this leads to no
significant impact to the cache conflict rate.

More details in the patch1 commit message.

---

Dan Williams (3):
      mm: Shuffle initial free memory
      mm: Move buddy list manipulations into helpers
      mm: Maintain randomization of page free lists


 include/linux/list.h     |   17 ++++
 include/linux/mm.h       |   30 +++++++
 include/linux/mm_types.h |    3 +
 include/linux/mmzone.h   |   65 ++++++++++++++++
 init/Kconfig             |   32 ++++++++
 mm/Makefile              |    1 
 mm/compaction.c          |    4 -
 mm/memblock.c            |    9 ++
 mm/memory_hotplug.c      |    2 
 mm/page_alloc.c          |   81 +++++++++-----------
 mm/shuffle.c             |  186 ++++++++++++++++++++++++++++++++++++++++++++++
 11 files changed, 381 insertions(+), 49 deletions(-)
 create mode 100644 mm/shuffle.c
