Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id C1F478E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 21:37:21 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s15-v6so9156303pgv.9
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 18:37:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u1-v6sor2059976pfl.132.2018.09.28.18.37.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 28 Sep 2018 18:37:20 -0700 (PDT)
Date: Sat, 29 Sep 2018 11:37:12 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH 01/11] nios2: update_mmu_cache clear the old entry
 from the TLB
Message-ID: <20180929113712.6dcfeeb3@roar.ozlabs.ibm.com>
In-Reply-To: <20180923150830.6096-2-npiggin@gmail.com>
References: <20180923150830.6096-1-npiggin@gmail.com>
	<20180923150830.6096-2-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ley Foon Tan <ley.foon.tan@intel.com>
Cc: Guenter Roeck <linux@roeck-us.net>, nios2-dev@lists.rocketboards.org, linux-mm@kvack.org

Hi,

Did you get a chance to look at these?

This first patch 1/11 solves the lockup problem that Guenter reported
with my changes to core mm code. So I plan to resubmit my patches
to Andrew's -mm tree with this patch to avoid nios2 breakage.

Thanks,
Nick

On Mon, 24 Sep 2018 01:08:20 +1000
Nicholas Piggin <npiggin@gmail.com> wrote:

> Fault paths like do_read_fault will install a Linux pte with the young
> bit clear. The CPU will fault again because the TLB has not been
> updated, this time a valid pte exists so handle_pte_fault will just
> set the young bit with ptep_set_access_flags, which flushes the TLB.
> 
> The TLB is flushed so the next attempt will go to the fast TLB handler
> which loads the TLB with the new Linux pte. The access then proceeds.
> 
> This design is fragile to depend on the young bit being clear after
> the initial Linux fault. A proposed core mm change to immediately set
> the young bit upon such a fault, results in ptep_set_access_flags not
> flushing the TLB because it finds no change to the pte. The spurious
> fault fix path only flushes the TLB if the access was a store. If it
> was a load, then this results in an infinite loop of page faults.
> 
> This change adds a TLB flush in update_mmu_cache, which removes that
> TLB entry upon the first fault. This will cause the fast TLB handler
> to load the new pte and avoid the Linux page fault entirely.
> 
> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> ---
>  arch/nios2/mm/cacheflush.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/arch/nios2/mm/cacheflush.c b/arch/nios2/mm/cacheflush.c
> index 506f6e1c86d5..d58e7e80dc0d 100644
> --- a/arch/nios2/mm/cacheflush.c
> +++ b/arch/nios2/mm/cacheflush.c
> @@ -204,6 +204,8 @@ void update_mmu_cache(struct vm_area_struct *vma,
>  	struct page *page;
>  	struct address_space *mapping;
>  
> +	flush_tlb_page(vma, address);
> +
>  	if (!pfn_valid(pfn))
>  		return;
>  
> -- 
> 2.18.0
> 
