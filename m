Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k2F1KlHI013903
	for <linux-mm@kvack.org>; Tue, 14 Mar 2006 20:20:47 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k2F1Kl7X134884
	for <linux-mm@kvack.org>; Tue, 14 Mar 2006 20:20:48 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k2F1KlhA020027
	for <linux-mm@kvack.org>; Tue, 14 Mar 2006 20:20:47 -0500
Date: Tue, 14 Mar 2006 17:20:00 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: BUG in x86_64 hugepage support
Message-ID: <20060315012000.GC5526@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: agl@us.ibm.com, david@gibson.dropbear.id.au, ak@suse.de
Cc: linux-mm@kvack.org, discuss@x86-64.org
List-ID: <linux-mm.kvack.org>

Hello,

While doing some testing of libhugetlbfs, I ran into the following BUGs
on my x86_64 box when checking mprotect with hugepages (running make
func in libhugetlbfs is all it took here) (distro is Ubuntu Dapper, runs
32-bit userspace).

[  633.480724] ----------- [cut here ] --------- [please bite here ] ---------
[  633.480733] Kernel BUG at ...rc6-mm1/arch/x86_64/mm/../../i386/mm/hugetlbpage.c:31
[  633.480736] invalid opcode: 0000 [1] PREEMPT SMP 
[  633.480740] last sysfs file: /block/sdb/sdb1/stat
[  633.480743] CPU 1 
[  633.480745] Modules linked in:
[  633.480750] Pid: 7872, comm: mprotect Not tainted 2.6.16-rc6-mm1 #1
[  633.480753] RIP: 0010:[<ffffffff80188e46>] <ffffffff80188e46>{huge_pte_alloc+230}
[  633.480764] RSP: 0000:ffff81006675dd18  EFLAGS: 00010283
[  633.480767] RAX: 0000000000000001 RBX: ffff8100648ce008 RCX: 0000000000000000
[  633.480772] RDX: ffff81007c7aa560 RSI: 0000000055800000 RDI: ffff8100648e4480
[  633.480776] RBP: ffff81006675dd38 R08: 00000000556c19fc R09: 00000000ffffd178
[  633.480780] R10: ffff81006675c000 R11: 0000000000000246 R12: 0000000000000560
[  633.480784] R13: ffff8100648e4480 R14: ffff8100648e4480 R15: 0000000000000000
[  633.480788] FS:  00002ac688028e10(0000) GS:ffff81007f1b4740(0063) knlGS:00000000556c68e0
[  633.480792] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  633.480795] CR2: 0000000055800000 CR3: 000000006593d000 CR4: 00000000000006e0
[  633.480800] Process mprotect (pid: 7872, threadinfo ffff81006675c000, task ffff8100402fc750)
[  633.480803] Stack: 0000000055800000 0000000000000000 0000000000000000 0000000055800000 
[  633.480809]        ffff81006675dd88 ffffffff801c5383 ffff81006675de68 ffff8100734e3c60 
[  633.480817]        ffff81006675dda8 ffff8100734e3c60 
[  633.480821] Call Trace: <ffffffff801c5383>{hugetlb_fault+51} <ffffffff801085ea>{__handle_mm_fault+90}
[  633.480834]        <ffffffff8010a727>{ia32_setup_sigcontext+327} <ffffffff80173fdb>{notifier_call_chain+43}
[  633.480845]        <ffffffff80173b19>{do_page_fault+1241} <ffffffff80171275>{_spin_unlock_irq+21}
[  633.480854]        <ffffffff80134cc5>{sys_rt_sigprocmask+229} <ffffffff8016c741>{error_exit+0}
[  633.480868] 
[  633.480869] Code: 0f 0b 68 08 a6 4e 80 c2 1f 00 48 8b 5d e8 4c 8b 65 f0 48 89 
[  633.480881] RIP <ffffffff80188e46>{huge_pte_alloc+230} RSP <ffff81006675dd18>
[  633.480888]  ----------- [cut here ] --------- [please bite here ] ---------
[  633.492589] Kernel BUG at ...rc6-mm1/arch/x86_64/mm/../../i386/mm/hugetlbpage.c:31
[  633.492593] invalid opcode: 0000 [2] PREEMPT SMP 
[  633.492597] last sysfs file: /block/sdb/sdb1/stat
[  633.492600] CPU 1 
[  633.492602] Modules linked in:
[  633.492606] Pid: 7873, comm: mprotect Not tainted 2.6.16-rc6-mm1 #1
[  633.492610] RIP: 0010:[<ffffffff80188e46>] <ffffffff80188e46>{huge_pte_alloc+230}
[  633.492620] RSP: 0000:ffff81006675fd18  EFLAGS: 00010283
[  633.492624] RAX: 0000000000000001 RBX: ffff810066745550 RCX: 0000000000000000
[  633.492628] RDX: ffff81006596bab0 RSI: 00002aaaaac00000 RDI: ffff8100648e4480
[  633.492632] RBP: ffff81006675fd38 R08: 0000000000000000 R09: 0000000000000000
[  633.492635] R10: 0000000000000008 R11: 0000000000000246 R12: 0000000000000ab0
[  633.492639] R13: ffff8100648e4480 R14: ffff8100648e4480 R15: 0000000000000000
[  633.492644] FS:  00002b745df2ce10(0000) GS:ffff81007f1b4740(0000) knlGS:00000000556ac6c0
[  633.492647] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  633.492651] CR2: 00002aaaaac00000 CR3: 000000006670a000 CR4: 00000000000006e0
[  633.492655] Process mprotect (pid: 7873, threadinfo ffff81006675e000, task ffff8100402fd530)
[  633.492658] Stack: 00002aaaaac00000 0000000000000000 0000000000000003 00002aaaaac00000 
[  633.492665]        ffff81006675fd88 ffffffff801c5383 ffff81006675fe68 ffff8100734e3af0 
[  633.492673]        ffff81006675fd78 ffff8100734e3af0 
[  633.492677] Call Trace: <ffffffff801c5383>{hugetlb_fault+51} <ffffffff801085ea>{__handle_mm_fault+90}
[  633.492690]        <ffffffff80173fdb>{notifier_call_chain+43} <ffffffff80173b19>{do_page_fault+1241}
[  633.492701]        <ffffffff80123652>{sys_mprotect+1522} <ffffffff8016c741>{error_exit+0}
[  633.492715] 
[  633.492716] Code: 0f 0b 68 08 a6 4e 80 c2 1f 00 48 8b 5d e8 4c 8b 65 f0 48 89 
[  633.492728] RIP <ffffffff80188e46>{huge_pte_alloc+230} RSP <ffff81006675fd18>

The line in question (arch/i386/mm/hugetlbpage.c:31) in 2.6.16-rc6-mm1
is:

	BUG_ON(pte && !pte_none(*pte) && !pte_huge(*pte));

We are trying to verify that if the pte was succesfully allocated that
it is filled in and that it is a hugetlb pte.

After some discussion with Adam Litke, I added some debugging to see
what pte_val we were getting:

	huge_pte_alloc failed: pte == 800000003d800027

which indicates our flags = 0x27 or 00100111.

On x86_64, pte_huge is defined to be:

	#define __LARGE_PTE (_PAGE_PSE|_PAGE_PRESENT) // __LARGE_PTE = 10000001
	static inline int pte_huge(pte_t pte)           { return (pte_val(pte) & __LARGE_PTE) == __LARGE_PTE; }

Clearly, pte_huge() is going to return 0, as

	pte_val(pte) & __LARGE_PTE == 0x1 != __LARGE_PTE

in this case.

I believe the issue occurs due to the following code path:

	sys_mprotect() --> hugetlb_change_protection() --> pte_modify()

On x86_64, that last call is:

	#defined _PAGE_CHG_MASK	(PTE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY) // upper bits all 1, lower 11 bits = 00001100000
	unsigned long __supported_pte_mask __read_mostly = ~0UL;
	static inline pte_t pte_modify(pte_t pte, pgprot_t newprot)
	{
		pte_val(pte) &= _PAGE_CHG_MASK;
		pte_val(pte) |= pgprot_val(newprot);
		pte_val(pte) &= __supported_pte_mask;
		return pte;
	}

So, the first &= results in the lower 11 bits of pte_val(pte) being all
0s. By my analysis, this is the problem, pte_modify() on x86_64 is
clearing the bits we check to see if a pte is a hugetlb one. To see if
this might be an accurate analysis, I modified _PAGE_CHG_MASK as
follows:

	-#define _PAGE_CHG_MASK	(PTE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY)
	+#define _PAGE_CHG_MASK	(PTE_MASK | _PAGE_ACCESSED | _PAGE_DIRTY | _PAGE_PSE | _PAGE_PRESENT)

That is, forcing the bits we care about to get set in pte_modify(). This
removed the BUG()s I was seeing in our testing.

This obviously isn't a solution, though, but I don't know what is :) I
am hoping somebody with a bit more VM (or x86-64) experience can figure
out the right fix. I would appreciate any input, or corrections to my
analysis.

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
