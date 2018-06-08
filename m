Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C49866B0005
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 20:00:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p189-v6so6971203pfp.2
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 17:00:23 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id k2-v6si12289533pgr.206.2018.06.08.17.00.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 17:00:20 -0700 (PDT)
Subject: [PATCH v4 00/12] mm: Teach memory_failure() about ZONE_DEVICE pages
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 08 Jun 2018 16:50:21 -0700
Message-ID: <152850182079.38390.8280340535691965744.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-edac@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.orgjack@suse.cz

Changes since v3 [1]:

* Introduce dax_lock_page(), using the radix exceptional entry lock, for
  pinning down page->mapping while memory_failure() interrogates the
  page. (Jan)

* Collect acks and reviews from Tony and Jan.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2018-June/016153.html

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

---

Dan Williams (12):
      device-dax: Convert to vmf_insert_mixed and vm_fault_t
      device-dax: Cleanup vm_fault de-reference chains
      device-dax: Enable page_mapping()
      device-dax: Set page->index
      filesystem-dax: Set page->index
      mm, madvise_inject_error: Let memory_failure() optionally take a page reference
      x86/mm/pat: Prepare {reserve,free}_memtype() for "decoy" addresses
      x86/memory_failure: Introduce {set,clear}_mce_nospec()
      mm, memory_failure: Pass page size to kill_proc()
      filesystem-dax: Introduce dax_lock_page()
      mm, memory_failure: Teach memory_failure() about dev_pagemap pages
      libnvdimm, pmem: Restore page attributes when clearing errors


 arch/x86/include/asm/set_memory.h         |   42 +++++++++
 arch/x86/kernel/cpu/mcheck/mce-internal.h |   15 ---
 arch/x86/kernel/cpu/mcheck/mce.c          |   38 +-------
 arch/x86/mm/pat.c                         |   16 +++
 drivers/dax/device.c                      |   97 ++++++++++++--------
 drivers/nvdimm/pmem.c                     |   26 +++++
 drivers/nvdimm/pmem.h                     |   13 +++
 fs/dax.c                                  |   92 ++++++++++++++++++-
 include/linux/dax.h                       |   15 +++
 include/linux/huge_mm.h                   |    5 +
 include/linux/mm.h                        |    1 
 include/linux/set_memory.h                |   14 +++
 mm/huge_memory.c                          |    4 -
 mm/madvise.c                              |   18 +++-
 mm/memory-failure.c                       |  143 +++++++++++++++++++++++++++--
 15 files changed, 434 insertions(+), 105 deletions(-)
