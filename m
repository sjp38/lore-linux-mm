Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 118C06B0010
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 08:40:36 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e26-v6so4358956wmh.7
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 05:40:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x4-v6si8826453edq.436.2018.06.04.05.40.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 04 Jun 2018 05:40:34 -0700 (PDT)
Date: Mon, 4 Jun 2018 14:40:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 00/11] mm: Teach memory_failure() about ZONE_DEVICE
 pages
Message-ID: <20180604124031.GP19202@dhcp22.suse.cz>
References: <152800336321.17112.3300876636370683279.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <152800336321.17112.3300876636370683279.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: linux-nvdimm@lists.01.org, linux-edac@vger.kernel.org, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, Ross Zwisler <ross.zwisler@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Ingo Molnar <mingo@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sat 02-06-18 22:22:43, Dan Williams wrote:
> Changes since v1 [1]:
> * Rework the locking to not use lock_page() instead use a combination of
>   rcu_read_lock(), xa_lock_irq(&mapping->pages), and igrab() to validate
>   that dax pages are still associated with the given mapping, and to
>   prevent the address_space from being freed while memory_failure() is
>   busy. (Jan)
> 
> * Fix use of MF_COUNT_INCREASED in madvise_inject_error() to account for
>   the case where the injected error is a dax mapping and the pinned
>   reference needs to be dropped. (Naoya)
> 
> * Clarify with a comment that VM_FAULT_NOPAGE may not always indicate a
>   mapping of the storage capacity, it could also indicate the zero page.
>   (Jan)
> 
> [1]: https://lists.01.org/pipermail/linux-nvdimm/2018-May/015932.html
> 
> ---
> 
> As it stands, memory_failure() gets thoroughly confused by dev_pagemap
> backed mappings. The recovery code has specific enabling for several
> possible page states and needs new enabling to handle poison in dax
> mappings.
> 
> In order to support reliable reverse mapping of user space addresses:
> 
> 1/ Add new locking in the memory_failure() rmap path to prevent races
> that would typically be handled by the page lock.
> 
> 2/ Since dev_pagemap pages are hidden from the page allocator and the
> "compound page" accounting machinery, add a mechanism to determine the
> size of the mapping that encompasses a given poisoned pfn.
> 
> 3/ Given pmem errors can be repaired, change the speculatively accessed
> poison protection, mce_unmap_kpfn(), to be reversible and otherwise
> allow ongoing access from the kernel.

This doesn't really describe the problem you are trying to solve and why
do you believe that HWPoison is the best way to handle it. As things
stand HWPoison is rather ad-hoc and I am not sure adding more to it is
really great without some deep reconsidering how the whole thing is done
right now IMHO. Are you actually trying to solve some real world problem
or you merely want to make soft offlining work properly?

> ---
> 
> Dan Williams (11):
>       device-dax: Convert to vmf_insert_mixed and vm_fault_t
>       device-dax: Cleanup vm_fault de-reference chains
>       device-dax: Enable page_mapping()
>       device-dax: Set page->index
>       filesystem-dax: Set page->index
>       mm, madvise_inject_error: Let memory_failure() optionally take a page reference
>       x86, memory_failure: Introduce {set,clear}_mce_nospec()
>       mm, memory_failure: Pass page size to kill_proc()
>       mm, memory_failure: Fix page->mapping assumptions relative to the page lock
>       mm, memory_failure: Teach memory_failure() about dev_pagemap pages
>       libnvdimm, pmem: Restore page attributes when clearing errors
> 
> 
>  arch/x86/include/asm/set_memory.h         |   29 ++++
>  arch/x86/kernel/cpu/mcheck/mce-internal.h |   15 --
>  arch/x86/kernel/cpu/mcheck/mce.c          |   38 -----
>  drivers/dax/device.c                      |   97 ++++++++-----
>  drivers/nvdimm/pmem.c                     |   26 ++++
>  drivers/nvdimm/pmem.h                     |   13 ++
>  fs/dax.c                                  |   16 ++
>  include/linux/huge_mm.h                   |    5 -
>  include/linux/mm.h                        |    1 
>  include/linux/set_memory.h                |   14 ++
>  mm/huge_memory.c                          |    4 -
>  mm/madvise.c                              |   18 ++
>  mm/memory-failure.c                       |  209 ++++++++++++++++++++++++++---
>  13 files changed, 366 insertions(+), 119 deletions(-)

-- 
Michal Hocko
SUSE Labs
