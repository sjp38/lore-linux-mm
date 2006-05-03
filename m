From: Andi Kleen <ak@suse.de>
Subject: Re: RFC: RCU protected page table walking
Date: Wed, 3 May 2006 18:46:51 +0200
References: <4458CCDC.5060607@bull.net>
In-Reply-To: <4458CCDC.5060607@bull.net>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200605031846.51657.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
Cc: linux-mm@kvack.org, Zoltan.Menyhart@free.fr
List-ID: <linux-mm.kvack.org>

s page table walking is not atomic, not even on an x86.
> 
> Let's consider the following scenario:
> 
> 
> CPU #1:                      CPU #2:                 CPU #3
> 
> Starts walking
> Got the ph. addr. of page Y
> in internal reg. X
>                              free_pgtables():
>                              sets free page Y

The page is not freed until all CPUs who had the mm mapped are flushed.
See mmu_gather in asm-generic/tlb.h


>                                                      Allocates page Y
> Accesses page Y via reg. X
> 
> 
> As CPU #1 is still keeping the same ph. address, it fetches an item
> from a page that is no more its page.
> 
> Even if this security window is small, it does exist.

It doesn't at least on architectures that use the generic tlbflush.h

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
