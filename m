Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 224996B0010
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 22:27:38 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id bh1-v6so7346290plb.15
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 19:27:38 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id f65-v6si3313810pgc.20.2018.10.03.19.27.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 19:27:37 -0700 (PDT)
Subject: [PATCH v2 0/3] Randomize free memory
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 03 Oct 2018 19:15:18 -0700
Message-ID: <153861931865.2863953.11185006931458762795.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kees Cook <keescook@chromium.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.orgkeescook@chromium.org

Changes since v1:
* Add support for shuffling hot-added memory (Andrew)
* Update cover letter and commit message to clarify the performance impact
  and relevance to future platforms

[1]: https://lkml.org/lkml/2018/9/15/366

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

More details in the patch1 commit message.

---

Dan Williams (3):
      mm: Shuffle initial free memory
      mm: Move buddy list manipulations into helpers
      mm: Maintain randomization of page free lists


 include/linux/list.h     |   17 +++
 include/linux/mm.h       |    8 +
 include/linux/mm_types.h |    3 +
 include/linux/mmzone.h   |   57 ++++++++++
 mm/bootmem.c             |    9 +-
 mm/compaction.c          |    4 -
 mm/memory_hotplug.c      |    2 
 mm/nobootmem.c           |    7 +
 mm/page_alloc.c          |  267 +++++++++++++++++++++++++++++++++++++++-------
 9 files changed, 321 insertions(+), 53 deletions(-)
