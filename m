Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id B2F026B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 10:49:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e16-v6so11337504pfn.5
        for <linux-mm@kvack.org>; Tue, 22 May 2018 07:49:30 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id a12-v6si13024616pgw.578.2018.05.22.07.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 07:49:29 -0700 (PDT)
Subject: [PATCH 00/11] mm: Teach memory_failure() about ZONE_DEVICE pages
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 22 May 2018 07:39:32 -0700
Message-ID: <152699997165.24093.12194490924829406111.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-edac@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, stable@vger.kernel.org, Jan Kara <jack@suse.cz>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ingo Molnar <mingo@redhat.com>, Michal Hocko <mhocko@suse.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.orgtony.luck@intel.com

As it stands, memory_failure() gets thoroughly confused by dev_pagemap
backed mappings. The recovery code has specific enabling for several
possible page states and needs new enabling to handle poison in dax
mappings.

In order to support reliable reverse mapping of user space addresses add
new locking in the fsdax implementation to prevent races between
page-address_space disassociation events and the rmap performed in the
memory_failure() path. Additionally, since dev_pagemap pages are hidden
from the page allocator, add a mechanism to determine the size of the
mapping that encompasses a given poisoned pfn. Lastly, since pmem errors
can be repaired, change the speculatively accessed poison protection,
mce_unmap_kpfn(), to be reversible and otherwise allow ongoing access
from the kernel.

---

Dan Williams (11):
      device-dax: convert to vmf_insert_mixed and vm_fault_t
      device-dax: cleanup vm_fault de-reference chains
      device-dax: enable page_mapping()
      device-dax: set page->index
      filesystem-dax: set page->index
      filesystem-dax: perform __dax_invalidate_mapping_entry() under the page lock
      mm, madvise_inject_error: fix page count leak
      x86, memory_failure: introduce {set,clear}_mce_nospec()
      mm, memory_failure: pass page size to kill_proc()
      mm, memory_failure: teach memory_failure() about dev_pagemap pages
      libnvdimm, pmem: restore page attributes when clearing errors


 arch/x86/include/asm/set_memory.h         |   29 ++++++
 arch/x86/kernel/cpu/mcheck/mce-internal.h |   15 ---
 arch/x86/kernel/cpu/mcheck/mce.c          |   38 +-------
 drivers/dax/device.c                      |   91 ++++++++++++--------
 drivers/nvdimm/pmem.c                     |   26 ++++++
 drivers/nvdimm/pmem.h                     |   13 +++
 fs/dax.c                                  |  102 ++++++++++++++++++++--
 include/linux/huge_mm.h                   |    5 +
 include/linux/set_memory.h                |   14 +++
 mm/huge_memory.c                          |    4 -
 mm/madvise.c                              |   11 ++
 mm/memory-failure.c                       |  133 +++++++++++++++++++++++++++--
 12 files changed, 370 insertions(+), 111 deletions(-)
