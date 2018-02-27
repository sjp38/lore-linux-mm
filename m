Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF416B0005
	for <linux-mm@kvack.org>; Tue, 27 Feb 2018 01:59:28 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id p2so7262969wre.19
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 22:59:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 32sor4684052wrm.64.2018.02.26.22.59.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Feb 2018 22:59:26 -0800 (PST)
Date: Tue, 27 Feb 2018 07:59:22 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [v2 1/1] xen, mm: Allow deferred page initialization for xen pv
 domains
Message-ID: <20180227065922.u6y7bcx3pwyags2u@gmail.com>
References: <20180226160112.24724-1-pasha.tatashin@oracle.com>
 <20180226160112.24724-2-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180226160112.24724-2-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, jgross@suse.com, akataria@vmware.com, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, boris.ostrovsky@oracle.com, akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz, luto@kernel.org, labbott@redhat.com, kirill.shutemov@linux.intel.com, bp@suse.de, minipli@googlemail.com, jinb.park7@gmail.com, dan.j.williams@intel.com, bhe@redhat.com, zhang.jia@linux.alibaba.com, mgorman@techsingularity.net, hannes@cmpxchg.org, virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org


* Pavel Tatashin <pasha.tatashin@oracle.com> wrote:

> Juergen Gross noticed that commit
> f7f99100d8d ("mm: stop zeroing memory during allocation in vmemmap")
> broke XEN PV domains when deferred struct page initialization is enabled.
> 
> This is because the xen's PagePinned() flag is getting erased from struct
> pages when they are initialized later in boot.
> 
> Juergen fixed this problem by disabling deferred pages on xen pv domains.
> It is desirable, however, to have this feature available as it reduces boot
> time. This fix re-enables the feature for pv-dmains, and fixes the problem
> the following way:
> 
> The fix is to delay setting PagePinned flag until struct pages for all
> allocated memory are initialized, i.e. until after free_all_bootmem().
> 
> A new x86_init.hyper op init_after_bootmem() is called to let xen know
> that boot allocator is done, and hence struct pages for all the allocated
> memory are now initialized. If deferred page initialization is enabled, the
> rest of struct pages are going to be initialized later in boot once
> page_alloc_init_late() is called.
> 
> xen_after_bootmem() walks page table's pages and marks them pinned.
> 
> Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
> ---
>  arch/x86/include/asm/x86_init.h |  2 ++
>  arch/x86/kernel/x86_init.c      |  1 +
>  arch/x86/mm/init_32.c           |  1 +
>  arch/x86/mm/init_64.c           |  1 +
>  arch/x86/xen/mmu_pv.c           | 38 ++++++++++++++++++++++++++------------
>  mm/page_alloc.c                 |  4 ----
>  6 files changed, 31 insertions(+), 16 deletions(-)

Acked-by: Ingo Molnar <mingo@kernel.org>

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
