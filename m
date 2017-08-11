Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0712E6B0292
	for <linux-mm@kvack.org>; Fri, 11 Aug 2017 03:58:30 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z53so4001324wrz.10
        for <linux-mm@kvack.org>; Fri, 11 Aug 2017 00:58:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v10si372323wmb.71.2017.08.11.00.58.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Aug 2017 00:58:28 -0700 (PDT)
Date: Fri, 11 Aug 2017 09:58:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 00/15] complete deferred page initialization
Message-ID: <20170811075826.GB30811@dhcp22.suse.cz>
References: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1502138329-123460-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, ard.biesheuvel@linaro.org, will.deacon@arm.com, catalin.marinas@arm.com, sam@ravnborg.org

[I am sorry I didn't get to your previous versions]

On Mon 07-08-17 16:38:34, Pavel Tatashin wrote:
[...]
> SMP machines can benefit from the DEFERRED_STRUCT_PAGE_INIT config option,
> which defers initializing struct pages until all cpus have been started so
> it can be done in parallel.
> 
> However, this feature is sub-optimal, because the deferred page
> initialization code expects that the struct pages have already been zeroed,
> and the zeroing is done early in boot with a single thread only.  Also, we
> access that memory and set flags before struct pages are initialized. All
> of this is fixed in this patchset.
> 
> In this work we do the following:
> - Never read access struct page until it was initialized

How is this enforced? What about pfn walkers? E.g. page_ext
initialization code (page owner in particular)

> - Never set any fields in struct pages before they are initialized
> - Zero struct page at the beginning of struct page initialization

Please give us a more highlevel description of how your reimplementation
works and how is the patchset organized. I will go through those patches
but it is always good to give an overview in the cover letter to make
the review easier.

> Performance improvements on x86 machine with 8 nodes:
> Intel(R) Xeon(R) CPU E7-8895 v3 @ 2.60GHz
> 
> Single threaded struct page init: 7.6s/T improvement
> Deferred struct page init: 10.2s/T improvement

What are before and after numbers and how have you measured them.
> 
> Pavel Tatashin (15):
>   x86/mm: reserve only exiting low pages
>   x86/mm: setting fields in deferred pages
>   sparc64/mm: setting fields in deferred pages
>   mm: discard memblock data later
>   mm: don't accessed uninitialized struct pages
>   sparc64: simplify vmemmap_populate
>   mm: defining memblock_virt_alloc_try_nid_raw
>   mm: zero struct pages during initialization
>   sparc64: optimized struct page zeroing
>   x86/kasan: explicitly zero kasan shadow memory
>   arm64/kasan: explicitly zero kasan shadow memory
>   mm: explicitly zero pagetable memory
>   mm: stop zeroing memory during allocation in vmemmap
>   mm: optimize early system hash allocations
>   mm: debug for raw alloctor
> 
>  arch/arm64/mm/kasan_init.c          |  42 ++++++++++
>  arch/sparc/include/asm/pgtable_64.h |  30 +++++++
>  arch/sparc/mm/init_64.c             |  31 +++-----
>  arch/x86/kernel/setup.c             |   5 +-
>  arch/x86/mm/init_64.c               |   9 ++-
>  arch/x86/mm/kasan_init_64.c         |  67 ++++++++++++++++
>  include/linux/bootmem.h             |  27 +++++++
>  include/linux/memblock.h            |   9 ++-
>  include/linux/mm.h                  |   9 +++
>  mm/memblock.c                       | 152 ++++++++++++++++++++++++++++--------
>  mm/nobootmem.c                      |  16 ----
>  mm/page_alloc.c                     |  31 +++++---
>  mm/sparse-vmemmap.c                 |  10 ++-
>  mm/sparse.c                         |   6 +-
>  14 files changed, 356 insertions(+), 88 deletions(-)
> 
> -- 
> 2.14.0

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
