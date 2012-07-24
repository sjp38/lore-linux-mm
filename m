Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 56BE36B004D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 01:13:12 -0400 (EDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nikunj@linux.vnet.ibm.com>;
	Tue, 24 Jul 2012 10:43:09 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6O5D5Eh28639364
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 10:43:05 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6O5D3xd008070
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 15:13:04 +1000
From: Nikunj A Dadhania <nikunj@linux.vnet.ibm.com>
Subject: Re: [PATCH 02/20] mm: Add optional TLB flush to generic RCU page-table freeing
In-Reply-To: <1340838106.10063.85.camel@twins>
References: <20120627211540.459910855@chello.nl> <20120627212830.693232452@chello.nl> <CA+55aFwa41fzvx8EZG_gODvw7hSpr+iP+w5fXp6jUcQh-4nFgQ@mail.gmail.com> <1340838106.10063.85.camel@twins>
Date: Tue, 24 Jul 2012 10:42:27 +0530
Message-ID: <87vchd68uc.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Alex Shi <alex.shi@intel.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Russell King <rmk@arm.linux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Chris Metcalf <cmetcalf@tilera.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Tony Luck <tony.luck@intel.com>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Ralf Baechle <ralf@linux-mips.org>, Kyle McMartin <kyle@mcmartin.ca>, James Bottomley <jejb@parisc-linux.org>, Chris Zankel <chris@zankel.net>

On Thu, 28 Jun 2012 01:01:46 +0200, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
  
> +#ifdef CONFIG_STRICT_TLB_FILL
> +/*
> + * Some archictures (sparc64, ppc) cannot refill TLBs after the they've removed
> + * the PTE entries from their hash-table. Their hardware never looks at the
> + * linux page-table structures, so they don't need a hardware TLB invalidate
> + * when tearing down the page-table structure itself.
> + */
> +static inline void tlb_table_flush_mmu(struct mmu_gather *tlb) { }
> +#else
> +static inline void tlb_table_flush_mmu(struct mmu_gather *tlb)
> +{
> +	tlb_flush_mmu(tlb);
> +}
> +#endif
> +
>  void tlb_table_flush(struct mmu_gather *tlb)
>  {
>  	struct mmu_table_batch **batch = &tlb->batch;
>  
>  	if (*batch) {
> +		tlb_table_flush_mmu(tlb);
>  		call_rcu_sched(&(*batch)->rcu, tlb_remove_table_rcu);
>  		*batch = NULL;
>  	}

Hi Peter,

When running munmap(https://lkml.org/lkml/2012/5/17/59) test with KVM
and pvflush patches I got a crash. I have verified that the crash
happens on the base(non virt) as well when I have
CONFIG_HAVE_RCU_TABLE_FREE defined. Here is the crash details and my
analysis below:

-----------------------------------------------------------------------

BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
IP: [<ffffffff810d31d9>] __call_rcu+0x29/0x1c0
PGD 0 
Oops: 0002 [#1] SMP 
CPU 24 
Modules linked in: kvm_intel kvm [last unloaded: scsi_wait_scan]


Pid: 32643, comm: munmap Not tainted 3.5.0-rc7+ #46 IBM System x3850 X5 -[7042CR6]-[root@mx3850x5 ~/Node 1, Processor Card]# 
RIP: 0010:[<ffffffff810d31d9>]  [<ffffffff810d31d9>] __call_rcu+0x29/0x1c0
RSP: 0018:ffff88203164fc28  EFLAGS: 00010246
RAX: ffff88203164fba8 RBX: 0000000000000000 RCX: 0000000000000000
RDX: ffffffff81e34280 RSI: ffffffff81130330 RDI: 0000000000000000
RBP: ffff88203164fc58 R08: ffffea00d2680340 R09: 0000000000000000
R10: ffff883c7fbd4ef8 R11: 0000000000000078 R12: ffffffff81130330
R13: 00007f09ee803000 R14: ffff883c2fa5bab0 R15: ffff88203164fe08
FS:  00007f09ee7ee700(0000) GS:ffff883c7fc00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000008 CR3: 0000000001e0b000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process munmap (pid: 32643, threadinfo ffff88203164e000, task ffff882030458a70)
Stack:
 ffff883c2fa5bab0 ffff88203164fe08 ffff88203164fc68 ffff88203164fe08
 ffff88203164fe08 00007f09ee803000 ffff88203164fc68 ffffffff810d33c7
 ffff88203164fc88 ffffffff81130e0d ffff88203164fc88 ffffea00d28e54f8
Call Trace:
 [<ffffffff810d33c7>] call_rcu_sched+0x17/0x20
 [<ffffffff81130e0d>] tlb_table_flush+0x2d/0x40
 [<ffffffff81130e80>] tlb_remove_table+0x60/0xc0
 [<ffffffff8103a5e3>] ___pte_free_tlb+0x63/0x70
 [<ffffffff81131b38>] free_pgd_range+0x298/0x4b0
 [<ffffffff81131e1e>] free_pgtables+0xce/0x120
 [<ffffffff81137247>] exit_mmap+0xa7/0x160
 [<ffffffff81043fdf>] mmput+0x6f/0xf0
 [<ffffffff8104c3f5>] exit_mm+0x105/0x130
 [<ffffffff810d6c7d>] ? taskstats_exit+0x17d/0x240
 [<ffffffff8104c596>] do_exit+0x176/0x480
 [<ffffffff8104c8f5>] do_group_exit+0x55/0xd0
 [<ffffffff8104c987>] sys_exit_group+0x17/0x20
 [<ffffffff818a3829>] system_call_fastpath+0x16/0x1b
Code: ff ff 55 48 89 e5 48 83 ec 30 48 89 5d e8 4c 89 65 f0 4c 89 6d f8 66 66 66 66 90 40 f6 c7 03 48 89 fb 49 89 f4 0f 85 19 01 00 00 <4c> 89 63 08 48 c7 03 00 00 00 00 0f ae f0 9c 58 66 66 90 66 90 
RIP  [<ffffffff810d31d9>] __call_rcu+0x29/0x1c0
 RSP <ffff88203164fc28>
CR2: 0000000000000008
---[ end trace 3ed30a91ea7cb375 ]---

----------------------------------------------------------------------------

I think this is what is happening:

___pte_free_tlb
   tlb_remove_table
      tlb_table_flush
         tlb_table_flush_mmu
            tlb_flush_mmu
                Sets need_flush = 0
                tlb_table_flush (if CONFIG_HAVE_RCU_TABLE_FREE)
                    [Gets called twice with same *tlb!]

                    tlb_table_flush_mmu
                        tlb_flush_mmu(nop as need_flush is 0)
                    call_rcu_sched(&(*batch)->rcu,...);
                    *batch = NULL;
         call_rcu_sched(&(*batch)->rcu,...); <---- *batch would be NULL

I verified this by putting following fix and do not see the crash
anymore:

diff --git a/mm/memory.c b/mm/memory.c
index 1797bc1..329fcb9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -367,7 +367,8 @@ void tlb_table_flush(struct mmu_gather *tlb)
 
 	if (*batch) {
 		tlb_table_flush_mmu(tlb);
-		call_rcu_sched(&(*batch)->rcu, tlb_remove_table_rcu);
+		if(*batch)
+			call_rcu_sched(&(*batch)->rcu, tlb_remove_table_rcu);
 		*batch = NULL;
 	}
 }

Thanks
Nikunj

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
