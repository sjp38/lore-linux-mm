Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9D93B6B0279
	for <linux-mm@kvack.org>; Wed, 19 Jul 2017 03:41:34 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id k69so1161876wmc.14
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 00:41:34 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b137si4536723wmf.61.2017.07.19.00.41.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Jul 2017 00:41:32 -0700 (PDT)
Date: Wed, 19 Jul 2017 08:41:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170719074131.75wexoal3fiyoxw5@suse.de>
References: <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <20170711200923.gyaxfjzz3tpvreuq@suse.de>
 <20170711215240.tdpmwmgwcuerjj3o@suse.de>
 <9ECCACFE-6006-4C19-8FC0-C387EB5F3BEE@gmail.com>
 <20170712082733.ouf7yx2bnvwwcfms@suse.de>
 <591A2865-13B8-4B3A-B094-8B83A7F9814B@gmail.com>
 <20170713060706.o2cuko5y6irxwnww@suse.de>
 <A9CB595E-7C6D-438F-9835-A9EB8DA90892@gmail.com>
 <20170715155518.ok2q62efc2vurqk5@suse.de>
 <F7E154AB-5C1D-477F-A6BF-EFCAE5381B2D@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <F7E154AB-5C1D-477F-A6BF-EFCAE5381B2D@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>
Cc: Andy Lutomirski <luto@kernel.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>

On Tue, Jul 18, 2017 at 02:28:27PM -0700, Nadav Amit wrote:
> > If there are separate address spaces using a shared mapping then the
> > same race does not occur.
> 
> I missed the fact you reverted the two operations since the previous version
> of the patch. This specific scenario should be solved with this patch.
> 
> But in general, I think there is a need for a simple locking scheme.

Such as?

> Otherwise, people (like me) would be afraid to make any changes to the code,
> and additional missing TLB flushes would exist. For example, I suspect that
> a user may trigger insert_pfn() or insert_page(), and rely on their output.

That API is for device drivers to insert pages (which may not be RAM)
directly into userspace and the pages are not on the LRU so not subject
to the same races.

> While it makes little sense, the user can try to insert the page on the same
> address of another page.

Even if a drivers was dumb enough to do so, the second insert should fail
on a !pte_none() test.

> If the other page was already reclaimed the
> operation should succeed and otherwise fail. But it may succeed while the
> other page is going through reclamation, resulting in:
>  

It doesn't go through reclaim as the page isn't on the LRU until the last
mmap or the driver frees the page.

> CPU0					CPU1
> ----					----				
> 					ptep_clear_flush_notify()
> - access memory using a PTE
> [ PTE cached in TLB ]
> 					try_to_unmap_one()
> 					==> ptep_get_and_clear() == false
> insert_page()
> ==> pte_none() = true
>     [retval = 0]
> 
> - access memory using a stale PTE

That race assumes that the page was on the LRU and the VMAs in question
are VM_MIXEDMAP or VM_PFNMAP. If the region is unmapped and a new mapping
put in place, the last patch ensures the region is flushed.

> Additional potential situations can be caused, IIUC, by mcopy_atomic_pte(),
> mfill_zeropage_pte(), shmem_mcopy_atomic_pte().
> 

I didn't dig into the exact locking for userfaultfd because largely it
doesn't matter. The operations are copy operations which means that any
stale TLB is being used to read data only. If the page is reclaimed then a
fault is raised. If data is read for a short duration before the TLB flush
then it still doesn't matter because there is no data integrity issue. The
TLB will be flushed if an operation occurs that could leak the wrong data.

> Even more importantly, I suspect there is an additional similar but
> unrelated problem. clear_refs_write() can be used with CLEAR_REFS_SOFT_DIRTY
> to write-protect PTEs. However, it batches TLB flushes, while only holding
> mmap_sem for read, and without any indication in mm that TLB flushes are
> pending.
> 

Again, consider whether there is a data integrity issue. A TLB entry existing
after an unmap is not in itself dangerous. There is always some degree of
race between when a PTE is unmapped and the IPIs for the flush are delivered.

> As a result, concurrent operation such as KSM???s write_protect_page() or

write_protect_page operates under the page lock and cannot race with reclaim.

> page_mkclean_one() can consider the page write-protected while in fact it is
> still accessible - since the TLB flush was deferred.

As long as it's flushed before any IO occurs that would lose a data update,
it's not a data integrity issue.

> As a result, they may
> mishandle the PTE without flushing the page. In the case of
> page_mkclean_one(), I suspect it may even lead to memory corruption. I admit
> that in x86 there are some mitigating factors that would make such ???attack???
> complicated, but it still seems wrong to me, no?
> 

I worry that you're beginning to see races everywhere. I admit that the
rules and protections here are varied and complex but it's worth keeping
in mind that data integrity is the key concern (no false reads to wrong
data, no lost writes) and the first race you identified found some problems
here. However, with or without batching, there is always a delay between
when a PTE is cleared and when the TLB entries are removed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
