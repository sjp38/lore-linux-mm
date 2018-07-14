Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4B5F36B0005
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 00:59:29 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id e93-v6so18794075plb.5
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 21:59:29 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id t16-v6si24232067pga.442.2018.07.13.21.59.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 21:59:27 -0700 (PDT)
Subject: [PATCH v6 00/13] mm: Teach memory_failure() about ZONE_DEVICE pages
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 13 Jul 2018 21:49:29 -0700
Message-ID: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-edac@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, stable@vger.kernel.org, Jan Kara <jack@suse.cz>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Changes since v5 [1]:
* Move put_page() before memory_failure() in madvise_inject_error()
  (Naoya)
* The previous change uncovered a latent bug / broken assumption in
  __put_devmap_managed_page(). We need to preserve page->mapping for
  dax pages when they go idle.
* Rename mapping_size() to dev_pagemap_mapping_size() (Naoya)
* Catch and fail attempts to soft-offline dax pages (Naoya)
* Collect Naoya's ack on "mm, memory_failure: Collect mapping size in
  collect_procs()"

[1]: https://lists.01.org/pipermail/linux-nvdimm/2018-July/016682.html

---

As it stands, memory_failure() gets thoroughly confused by dev_pagemap
backed mappings. The recovery code has specific enabling for several
possible page states and needs new enabling to handle poison in dax
mappings.

In order to support reliable reverse mapping of user space addresses:

1/ Add new locking in the memory_failure() rmap path to prevent races
that would typically be handled by the page lock.

2/ Since dev_pagemap pages are hidden from the page allocator and the
"compound page" accounting machinery, add a mechanism to determine the
size of the mapping that encompasses a given poisoned pfn.

3/ Given pmem errors can be repaired, change the speculatively accessed
poison protection, mce_unmap_kpfn(), to be reversible and otherwise
allow ongoing access from the kernel.

A side effect of this enabling is that MADV_HWPOISON becomes usable for
dax mappings, however the primary motivation is to allow the system to
survive userspace consumption of hardware-poison via dax. Specifically
the current behavior is:

    mce: Uncorrected hardware memory error in user-access at af34214200
    {1}[Hardware Error]: It has been corrected by h/w and requires no further action
    mce: [Hardware Error]: Machine check events logged
    {1}[Hardware Error]: event severity: corrected
    Memory failure: 0xaf34214: reserved kernel page still referenced by 1 users
    [..]
    Memory failure: 0xaf34214: recovery action for reserved kernel page: Failed
    mce: Memory error not recovered
    <reboot>

...and with these changes:

    Injecting memory failure for pfn 0x20cb00 at process virtual address 0x7f763dd00000
    Memory failure: 0x20cb00: Killing dax-pmd:5421 due to hardware memory corruption
    Memory failure: 0x20cb00: recovery action for dax page: Recovered

Given all the cross dependencies I propose taking this through
nvdimm.git with acks from Naoya, x86/core, x86/RAS, and of course dax
folks.

---

Dan Williams (13):
      device-dax: Convert to vmf_insert_mixed and vm_fault_t
      device-dax: Enable page_mapping()
      device-dax: Set page->index
      filesystem-dax: Set page->index
      mm, madvise_inject_error: Disable MADV_SOFT_OFFLINE for ZONE_DEVICE pages
      mm, dev_pagemap: Do not clear ->mapping on final put
      mm, madvise_inject_error: Let memory_failure() optionally take a page reference
      mm, memory_failure: Collect mapping size in collect_procs()
      filesystem-dax: Introduce dax_lock_mapping_entry()
      mm, memory_failure: Teach memory_failure() about dev_pagemap pages
      x86/mm/pat: Prepare {reserve,free}_memtype() for "decoy" addresses
      x86/memory_failure: Introduce {set,clear}_mce_nospec()
      libnvdimm, pmem: Restore page attributes when clearing errors


 arch/x86/include/asm/set_memory.h         |   42 ++++++
 arch/x86/kernel/cpu/mcheck/mce-internal.h |   15 --
 arch/x86/kernel/cpu/mcheck/mce.c          |   38 -----
 arch/x86/mm/pat.c                         |   16 ++
 drivers/dax/device.c                      |   75 +++++++---
 drivers/nvdimm/pmem.c                     |   26 ++++
 drivers/nvdimm/pmem.h                     |   13 ++
 fs/dax.c                                  |  125 ++++++++++++++++-
 include/linux/dax.h                       |   13 ++
 include/linux/huge_mm.h                   |    5 -
 include/linux/mm.h                        |    1 
 include/linux/set_memory.h                |   14 ++
 kernel/memremap.c                         |    1 
 mm/hmm.c                                  |    2 
 mm/huge_memory.c                          |    4 -
 mm/madvise.c                              |   16 ++
 mm/memory-failure.c                       |  210 +++++++++++++++++++++++------
 17 files changed, 481 insertions(+), 135 deletions(-)
