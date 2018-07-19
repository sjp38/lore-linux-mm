Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 799C96B0008
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 13:57:11 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g15-v6so5114388plo.11
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 10:57:11 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id d14-v6si5784578plr.244.2018.07.19.10.57.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jul 2018 10:57:10 -0700 (PDT)
Subject: Re: [PATCH v6 00/13] mm: Teach memory_failure() about ZONE_DEVICE
 pages
References: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
From: Dave Jiang <dave.jiang@intel.com>
Message-ID: <b9602b1b-97d3-b9c1-cc85-5b73b67e2e03@intel.com>
Date: Thu, 19 Jul 2018 10:57:08 -0700
MIME-Version: 1.0
In-Reply-To: <153154376846.34503.15480221419473501643.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-nvdimm@lists.01.org, Tony Luck <tony.luck@intel.com>, Jan Kara <jack@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, x86@kernel.org, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Borislav Petkov <bp@alien8.de>, Matthew Wilcox <willy@infradead.org>, "H. Peter Anvin" <hpa@zytor.com>, linux-fsdevel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Christoph Hellwig <hch@lst.de>, linux-edac@vger.kernel.org

Ingo,
Is it possible to ack the x86 bits in this patch series? I'm hoping to
get this pulled through the libnvdimm tree for 4.19. Thanks!

On 07/13/2018 09:49 PM, Dan Williams wrote:
> Changes since v5 [1]:
> * Move put_page() before memory_failure() in madvise_inject_error()
>   (Naoya)
> * The previous change uncovered a latent bug / broken assumption in
>   __put_devmap_managed_page(). We need to preserve page->mapping for
>   dax pages when they go idle.
> * Rename mapping_size() to dev_pagemap_mapping_size() (Naoya)
> * Catch and fail attempts to soft-offline dax pages (Naoya)
> * Collect Naoya's ack on "mm, memory_failure: Collect mapping size in
>   collect_procs()"
> 
> [1]: https://lists.01.org/pipermail/linux-nvdimm/2018-July/016682.html
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
> 
> A side effect of this enabling is that MADV_HWPOISON becomes usable for
> dax mappings, however the primary motivation is to allow the system to
> survive userspace consumption of hardware-poison via dax. Specifically
> the current behavior is:
> 
>     mce: Uncorrected hardware memory error in user-access at af34214200
>     {1}[Hardware Error]: It has been corrected by h/w and requires no further action
>     mce: [Hardware Error]: Machine check events logged
>     {1}[Hardware Error]: event severity: corrected
>     Memory failure: 0xaf34214: reserved kernel page still referenced by 1 users
>     [..]
>     Memory failure: 0xaf34214: recovery action for reserved kernel page: Failed
>     mce: Memory error not recovered
>     <reboot>
> 
> ...and with these changes:
> 
>     Injecting memory failure for pfn 0x20cb00 at process virtual address 0x7f763dd00000
>     Memory failure: 0x20cb00: Killing dax-pmd:5421 due to hardware memory corruption
>     Memory failure: 0x20cb00: recovery action for dax page: Recovered
> 
> Given all the cross dependencies I propose taking this through
> nvdimm.git with acks from Naoya, x86/core, x86/RAS, and of course dax
> folks.
> 
> ---
> 
> Dan Williams (13):
>       device-dax: Convert to vmf_insert_mixed and vm_fault_t
>       device-dax: Enable page_mapping()
>       device-dax: Set page->index
>       filesystem-dax: Set page->index
>       mm, madvise_inject_error: Disable MADV_SOFT_OFFLINE for ZONE_DEVICE pages
>       mm, dev_pagemap: Do not clear ->mapping on final put
>       mm, madvise_inject_error: Let memory_failure() optionally take a page reference
>       mm, memory_failure: Collect mapping size in collect_procs()
>       filesystem-dax: Introduce dax_lock_mapping_entry()
>       mm, memory_failure: Teach memory_failure() about dev_pagemap pages
>       x86/mm/pat: Prepare {reserve,free}_memtype() for "decoy" addresses
>       x86/memory_failure: Introduce {set,clear}_mce_nospec()
>       libnvdimm, pmem: Restore page attributes when clearing errors
> 
> 
>  arch/x86/include/asm/set_memory.h         |   42 ++++++
>  arch/x86/kernel/cpu/mcheck/mce-internal.h |   15 --
>  arch/x86/kernel/cpu/mcheck/mce.c          |   38 -----
>  arch/x86/mm/pat.c                         |   16 ++
>  drivers/dax/device.c                      |   75 +++++++---
>  drivers/nvdimm/pmem.c                     |   26 ++++
>  drivers/nvdimm/pmem.h                     |   13 ++
>  fs/dax.c                                  |  125 ++++++++++++++++-
>  include/linux/dax.h                       |   13 ++
>  include/linux/huge_mm.h                   |    5 -
>  include/linux/mm.h                        |    1 
>  include/linux/set_memory.h                |   14 ++
>  kernel/memremap.c                         |    1 
>  mm/hmm.c                                  |    2 
>  mm/huge_memory.c                          |    4 -
>  mm/madvise.c                              |   16 ++
>  mm/memory-failure.c                       |  210 +++++++++++++++++++++++------
>  17 files changed, 481 insertions(+), 135 deletions(-)
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm
> 
