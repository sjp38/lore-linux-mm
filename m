Message-ID: <4459E663.10008@bull.net>
Date: Thu, 04 May 2006 13:32:51 +0200
From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
MIME-Version: 1.0
Subject: Re: RFC: RCU protected page table walking
References: <4458CCDC.5060607@bull.net> <Pine.LNX.4.64.0605031847190.15463@blonde.wat.veritas.com> <4459C8D0.7090609@bull.net> <200605041131.46254.ak@suse.de>
In-Reply-To: <200605041131.46254.ak@suse.de>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, Zoltan.Menyhart@free.fr
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:

> We don't free the pages until the other CPUs have been flushed synchronously.

Do you mean the TLB entries mapping the leaf pages?
If yes, then I agree with you about them.
Yet I speak about the directory pages. Let's take an example:

Assume:
- A process with 2 threads, bound to their respective CPUs
- One of them mapped a file and
  this mapping requires a new PMD and a new PTE page
- They read in some data pages
- Time goes by without ever touching any of these pages again
- The swapped removes the data pages (data flush, TLB purge)
- (on IA64: due to the TLB pressure, the TLB entry mapping the PTE page
  gets killed)

There is no valid TLB entry concerning this mapped zone any more => the TLB
purges around "free_pgtables()" can be considered as NO-OP-s.
(In addition, walking the page tables in physical mode is insensitive to any
TLB purges.)

CPU #1 faults on attempting to touch this mapped zone.
CPU #1 starts to walk the page tables in physical mode.
Assume it has got the address of the PMD page, it is about to fetch "pmd[j]".

CPU #2 executes "free_pgtables()" in the mean time: it sets free the PTE and
the PGD pages (without knowing that CPU #1 has already got a PMD pointer).

Someone else allocates these two pages and fills them in with some data.

CPU #1 now fetches "pmd[j]" from a page of someone else. Without noticing
anything, CPU #1 uses the illegal value to continue to access the PTE page.

> After the flush the other CPUs don't walk pages anymore.

Can you explain please why they do not?
There is a possibility that walking has already been started, but it has
not been completed yet, when "free_pgtables()" runs.

> The whole thing is
> batched because the synchronous flush can be pretty expensive.

Walking the page tables in physical mode is insensitive to any TLB purges,
therefore these purges do not make sure that there is no other CPU just
in the middle of page table walking.

I do a similar batching of the pages to be set free.
The RCU mechanism makes sure that these pages will not be freed before
the already started page table walkers finish their job.

Thanks,

Zoltan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
