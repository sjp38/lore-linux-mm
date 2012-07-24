Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 16D086B004D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 15:24:44 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so8634809ghr.14
        for <linux-mm@kvack.org>; Tue, 24 Jul 2012 12:24:43 -0700 (PDT)
Date: Tue, 24 Jul 2012 12:23:58 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH -alternative] mm: hugetlbfs: Close race during teardown
 of hugetlbfs shared page tables V2 (resend)
In-Reply-To: <20120724093406.GO9222@suse.de>
Message-ID: <alpine.LSU.2.00.1207241108010.1749@eggly.anvils>
References: <20120720134937.GG9222@suse.de> <20120720141108.GH9222@suse.de> <20120720143635.GE12434@tiehlicka.suse.cz> <20120720145121.GJ9222@suse.de> <alpine.LSU.2.00.1207222033030.6810@eggly.anvils> <20120723114007.GU9222@suse.de>
 <alpine.LSU.2.00.1207231702440.1683@eggly.anvils> <20120724093406.GO9222@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Tue, 24 Jul 2012, Mel Gorman wrote:
> On Mon, Jul 23, 2012 at 06:08:05PM -0700, Hugh Dickins wrote:
> > 
> > So, after a bout of anxiety, I think my &= ~VM_MAYSHARE remains good.
> > 
> 
> I agree with you. When I was thinking about the potential problems, I was
> thinking of them in the general context of the core VM and what we normally
> take into account.
> 
> I confess that I really find this working-by-coincidence very icky and am
> uncomfortable with it but your patch is the only patch that contains the
> mess to hugetlbfs. I fixed exit_mmap() for my version but only by changing
> the core to introduce exit_vmas() to take mmap_sem for write if a hugetlb
> VMA is found so I also affected the core.

"icky" is not quite the word I'd use, but yes, it feels like you only
have to dislodge a stone somewhere at the other end of the kernel,
and the whole lot would come tumbling down.

If I could think of a suitable VM_BUG_ON to insert next to the ~VM_MAYSHARE,
I would: to warn us when assumptions change.  If we were prepared to waste
another vm_flag on it (and just because there's now a type which lets them
expand does not mean we can be profligate with them), then you can imagine
a VM_GOINGAWAY flag set in unmap_region() and exit_mmap(), and we key off
that instead; or something of that kind.

But I'm afraid I see that as TODO-list material: the one-liner is pretty
good for stable backporting, and I felt smiled-upon when it turned out to
be workable (and not even needing a change in arch/x86/mm, that really
surprised me).  It seems ungrateful not to seize the simple fix it offers,
which I found much easier to understand than the alternatives.

> 
> So, lets go with your patch but with all this documented! I stuck a
> changelog and an additional comment onto your patch and this is the end
> result.

Okay, thanks.  (I think you've copied rather more of my previous mail
into the commit description than it deserves, but it looks like you
like more words where I like less!)

> 
> Do you want to pick this up and send it to Andrew or will I?

Oh, please change your Reviewed-by to Signed-off-by: almost all of the
work and description comes from you and Michal; then please, you send it
in to Andrew - sorry, I really need to turn my attention to other things.

But I hadn't realized how messy it's going to be: I was concentrating on
3.5, not the mmotm tree, which as Michal points out is fairly different.
Yes, it definitely needs to revert to holding i_mmap_mutex when unsharing,
it was a mistake to have removed that (what stabilizes the page_count 1
check in huge_pmd_unshare? only i_mmap_mutex).

I guess this fix needs to go in to 3.6 early, and "someone" rejig the
hugetlb area of mmotm before that goes on to Linus.  Urggh.  AArgh64.
Sorry, I'm not volunteering.

But an interesting aspect of the hugetlb changes there, is that
mmu_gather is now being used by __unmap_hugepage_range: I did want that
for one of the solutions to this bug that I was toying with.  Although
earlier I had been afraid of "doing free_pgtables work" down in unshare,
it occurred to me later that already we do that (pud_clear) with no harm
observed, and free_pgtables does not depend on having entries still
present at the lower levels.  It may be that there's a less tricky
fix available once the dust has settled here.

> 
> Thanks Hugh!
> 
> ---8<---
> mm: hugetlbfs: Close race during teardown of hugetlbfs shared page tables
> 
> If a process creates a large hugetlbfs mapping that is eligible for page
> table sharing and forks heavily with children some of whom fault and
> others which destroy the mapping then it is possible for page tables to
> get corrupted. Some teardowns of the mapping encounter a "bad pmd" and
> output a message to the kernel log. The final teardown will trigger a
> BUG_ON in mm/filemap.c.
> 
> This was reproduced in 3.4 but is known to have existed for a long time
> and goes back at least as far as 2.6.37. It was probably was introduced in
> 2.6.20 by [39dde65c: shared page table for hugetlb page]. The messages
> look like this;
> 
> [  ..........] Lots of bad pmd messages followed by this
> [  127.164256] mm/memory.c:391: bad pmd ffff880412e04fe8(80000003de4000e7).
> [  127.164257] mm/memory.c:391: bad pmd ffff880412e04ff0(80000003de6000e7).
> [  127.164258] mm/memory.c:391: bad pmd ffff880412e04ff8(80000003de0000e7).
> [  127.186778] ------------[ cut here ]------------
> [  127.186781] kernel BUG at mm/filemap.c:134!
> [  127.186782] invalid opcode: 0000 [#1] SMP
> [  127.186783] CPU 7
> [  127.186784] Modules linked in: af_packet cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf ext3 jbd dm_mod coretemp crc32c_intel usb_storage ghash_clmulni_intel aesni_intel i2c_i801 r8169 mii uas sr_mod cdrom sg iTCO_wdt iTCO_vendor_support shpchp serio_raw cryptd aes_x86_64 e1000e pci_hotplug dcdbas aes_generic container microcode ext4 mbcache jbd2 crc16 sd_mod crc_t10dif i915 drm_kms_helper drm i2c_algo_bit ehci_hcd ahci libahci usbcore rtc_cmos usb_common button i2c_core intel_agp video intel_gtt fan processor thermal thermal_sys hwmon ata_generic pata_atiixp libata scsi_mod
> [  127.186801]
> [  127.186802] Pid: 9017, comm: hugetlbfs-test Not tainted 3.4.0-autobuild #53 Dell Inc. OptiPlex 990/06D7TR
> [  127.186804] RIP: 0010:[<ffffffff810ed6ce>]  [<ffffffff810ed6ce>] __delete_from_page_cache+0x15e/0x160
> [  127.186809] RSP: 0000:ffff8804144b5c08  EFLAGS: 00010002
> [  127.186810] RAX: 0000000000000001 RBX: ffffea000a5c9000 RCX: 00000000ffffffc0
> [  127.186811] RDX: 0000000000000000 RSI: 0000000000000009 RDI: ffff88042dfdad00
> [  127.186812] RBP: ffff8804144b5c18 R08: 0000000000000009 R09: 0000000000000003
> [  127.186813] R10: 0000000000000000 R11: 000000000000002d R12: ffff880412ff83d8
> [  127.186814] R13: ffff880412ff83d8 R14: 0000000000000000 R15: ffff880412ff83d8
> [  127.186815] FS:  00007fe18ed2c700(0000) GS:ffff88042dce0000(0000) knlGS:0000000000000000
> [  127.186816] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> [  127.186817] CR2: 00007fe340000503 CR3: 0000000417a14000 CR4: 00000000000407e0
> [  127.186818] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
> [  127.186819] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
> [  127.186820] Process hugetlbfs-test (pid: 9017, threadinfo ffff8804144b4000, task ffff880417f803c0)
> [  127.186821] Stack:
> [  127.186822]  ffffea000a5c9000 0000000000000000 ffff8804144b5c48 ffffffff810ed83b
> [  127.186824]  ffff8804144b5c48 000000000000138a 0000000000001387 ffff8804144b5c98
> [  127.186825]  ffff8804144b5d48 ffffffff811bc925 ffff8804144b5cb8 0000000000000000
> [  127.186827] Call Trace:
> [  127.186829]  [<ffffffff810ed83b>] delete_from_page_cache+0x3b/0x80
> [  127.186832]  [<ffffffff811bc925>] truncate_hugepages+0x115/0x220
> [  127.186834]  [<ffffffff811bca43>] hugetlbfs_evict_inode+0x13/0x30
> [  127.186837]  [<ffffffff811655c7>] evict+0xa7/0x1b0
> [  127.186839]  [<ffffffff811657a3>] iput_final+0xd3/0x1f0
> [  127.186840]  [<ffffffff811658f9>] iput+0x39/0x50
> [  127.186842]  [<ffffffff81162708>] d_kill+0xf8/0x130
> [  127.186843]  [<ffffffff81162812>] dput+0xd2/0x1a0
> [  127.186845]  [<ffffffff8114e2d0>] __fput+0x170/0x230
> [  127.186848]  [<ffffffff81236e0e>] ? rb_erase+0xce/0x150
> [  127.186849]  [<ffffffff8114e3ad>] fput+0x1d/0x30
> [  127.186851]  [<ffffffff81117db7>] remove_vma+0x37/0x80
> [  127.186853]  [<ffffffff81119182>] do_munmap+0x2d2/0x360
> [  127.186855]  [<ffffffff811cc639>] sys_shmdt+0xc9/0x170
> [  127.186857]  [<ffffffff81410a39>] system_call_fastpath+0x16/0x1b
> [  127.186858] Code: 0f 1f 44 00 00 48 8b 43 08 48 8b 00 48 8b 40 28 8b b0 40 03 00 00 85 f6 0f 88 df fe ff ff 48 89 df e8 e7 cb 05 00 e9 d2 fe ff ff <0f> 0b 55 83 e2 fd 48 89 e5 48 83 ec 30 48 89 5d d8 4c 89 65 e0
> [  127.186868] RIP  [<ffffffff810ed6ce>] __delete_from_page_cache+0x15e/0x160
> [  127.186870]  RSP <ffff8804144b5c08>
> [  127.186871] ---[ end trace 7cbac5d1db69f426 ]---
> 
> The bug is a race and not always easy to reproduce. To reproduce it I was
> doing the following on a single socket I7-based machine with 16G of RAM.
> 
> $ hugeadm --pool-pages-max DEFAULT:13G
> $ echo $((18*1048576*1024)) > /proc/sys/kernel/shmmax
> $ echo $((18*1048576*1024)) > /proc/sys/kernel/shmall
> $ for i in `seq 1 9000`; do ./hugetlbfs-test; done
> 
> On my particular machine, it usually triggers within 10 minutes but enabling
> debug options can change the timing such that it never hits. Once the bug is
> triggered, the machine is in trouble and needs to be rebooted. The machine
> will respond but processes accessing proc like "ps aux" will hang due to
> the BUG_ON. shutdown will also hang and needs a hard reset or a sysrq-b.
> 
> The basic problem is a race between page table sharing and teardown. For
> the most part page table sharing depends on i_mmap_mutex. In some cases,
> it is also taking the mm->page_table_lock for the PTE updates but with
> shared page tables, it is the i_mmap_mutex that is more important.
> 
> Unfortunately it appears to be also insufficient. Consider the following
> situation
> 
> Process A					Process B
> ---------					---------
> hugetlb_fault					shmdt
>   						LockWrite(mmap_sem)
>     						  do_munmap
> 						    unmap_region
> 						      unmap_vmas
> 						        unmap_single_vma
> 						          unmap_hugepage_range
>       						            Lock(i_mmap_mutex)
> 							    Lock(mm->page_table_lock)
> 							    huge_pmd_unshare/unmap tables <--- (1)
> 							    Unlock(mm->page_table_lock)
>       						            Unlock(i_mmap_mutex)
>   huge_pte_alloc				      ...
>     Lock(i_mmap_mutex)				      ...
>     vma_prio_walk, find svma, spte		      ...
>     Lock(mm->page_table_lock)			      ...
>     share spte					      ...
>     Unlock(mm->page_table_lock)			      ...
>     Unlock(i_mmap_mutex)			      ...
>   hugetlb_no_page									  <--- (2)
> 						      free_pgtables
> 						        unlink_file_vma
> 							hugetlb_free_pgd_range
> 						    remove_vma_list
> 
> In this scenario, it is possible for Process A to share page tables with
> Process B that is trying to tear them down.  The i_mmap_mutex on its own
> does not prevent Process A walking Process B's page tables. At (1) above,
> the page tables are not shared yet so it unmaps the PMDs. Process A sets
> up page table sharing and at (2) faults a new entry. Process B then trips
> up on it in free_pgtables.
> 
> This patch fixes the problem by clearing VM_MAYSHARE during
> unmap_hugepage_range() under the i_mmap_mutex. This makes the VMA
> ineligible for sharing and avoids the race. Superficially this looks
> like it would then be vunerable to truncate and madvise problems but
> this is avoided by the limitations of hugetlbfs.
> 
> madvise and trunctate would be problems if removing VM_MAYSHARE in
> __unmap_hugepage_range() but it is removed in unmap_hugepage_range().
> This is only called by unmap_single_vma(): which is called via unmap_vmas()
> by unmap_region() or exit_mmap() just before free_pgtables() (the problem
> cases); or by madvise_dontneed() via zap_page_range(), which is disallowed
> on VM_HUGETLB; or by zap_page_range_single().
> 
> zap_page_range_single() is called by zap_vma_ptes(), which is only allowed
> on VM_PFNMAP; or by unmap_mapping_range_vma(), which looked like it was
> going to deadlock on i_mmap_mutex (with or without my patch) but does
> not as hugetlbfs has its own hugetlbfs_setattr() and hugetlb_vmtruncate()
> which don't use unmap_mapping_range() at all.
> 
> invalidate_inode_pages2() (and _range()) do use unmap_mapping_range(),
> but hugetlbfs doesn't support direct_IO, and otherwise they're called by a
> filesystem directly on its own inodes, which hugetlbfs does not.  If there's
> a deadlock on i_mmap_mutex somewhere in there, it's not introduced by the
> proposed patch.
> 
> This should be treated as a -stable candidate if it is merged.
> 
> Test program is as follows. The test case was mostly written by Michal
> Hocko with a few minor changes to reproduce this bug.
> 
> ==== CUT HERE ====
> 
> static size_t huge_page_size = (2UL << 20);
> static size_t nr_huge_page_A = 512;
> static size_t nr_huge_page_B = 5632;
> 
> unsigned int get_random(unsigned int max)
> {
> 	struct timeval tv;
> 
> 	gettimeofday(&tv, NULL);
> 	srandom(tv.tv_usec);
> 	return random() % max;
> }
> 
> static void play(void *addr, size_t size)
> {
> 	unsigned char *start = addr,
> 		      *end = start + size,
> 		      *a;
> 	start += get_random(size/2);
> 
> 	/* we could itterate on huge pages but let's give it more time. */
> 	for (a = start; a < end; a += 4096)
> 		*a = 0;
> }
> 
> int main(int argc, char **argv)
> {
> 	key_t key = IPC_PRIVATE;
> 	size_t sizeA = nr_huge_page_A * huge_page_size;
> 	size_t sizeB = nr_huge_page_B * huge_page_size;
> 	int shmidA, shmidB;
> 	void *addrA = NULL, *addrB = NULL;
> 	int nr_children = 300, n = 0;
> 
> 	if ((shmidA = shmget(key, sizeA, IPC_CREAT|SHM_HUGETLB|0660)) == -1) {
> 		perror("shmget:");
> 		return 1;
> 	}
> 
> 	if ((addrA = shmat(shmidA, addrA, SHM_R|SHM_W)) == (void *)-1UL) {
> 		perror("shmat");
> 		return 1;
> 	}
> 	if ((shmidB = shmget(key, sizeB, IPC_CREAT|SHM_HUGETLB|0660)) == -1) {
> 		perror("shmget:");
> 		return 1;
> 	}
> 
> 	if ((addrB = shmat(shmidB, addrB, SHM_R|SHM_W)) == (void *)-1UL) {
> 		perror("shmat");
> 		return 1;
> 	}
> 
> fork_child:
> 	switch(fork()) {
> 		case 0:
> 			switch (n%3) {
> 			case 0:
> 				play(addrA, sizeA);
> 				break;
> 			case 1:
> 				play(addrB, sizeB);
> 				break;
> 			case 2:
> 				break;
> 			}
> 			break;
> 		case -1:
> 			perror("fork:");
> 			break;
> 		default:
> 			if (++n < nr_children)
> 				goto fork_child;
> 			play(addrA, sizeA);
> 			break;
> 	}
> 	shmdt(addrA);
> 	shmdt(addrB);
> 	do {
> 		wait(NULL);
> 	} while (--n > 0);
> 	shmctl(shmidA, IPC_RMID, NULL);
> 	shmctl(shmidB, IPC_RMID, NULL);
> 	return 0;
> }
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> Reviewed-by: Mel Gorman <mgorman@suse.de>
> ---
>  mm/hugetlb.c |   25 +++++++++++++++++++++++--
>  1 file changed, 23 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index ae8f708..d488476 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2383,6 +2383,22 @@ void unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
>  {
>  	mutex_lock(&vma->vm_file->f_mapping->i_mmap_mutex);
>  	__unmap_hugepage_range(vma, start, end, ref_page);
> +	/*
> +	 * Clear this flag so that x86's huge_pmd_share page_table_shareable
> +	 * test will fail on a vma being torn down, and not grab a page table
> +	 * on its way out.  We're lucky that the flag has such an appropriate
> +	 * name, and can in fact be safely cleared here. We could clear it
> +	 * before the __unmap_hugepage_range above, but all that's necessary
> +	 * is to clear it before releasing the i_mmap_mutex below.
> +	 *
> +	 * This works because in the contexts this is called, the VMA is
> +	 * going to be destroyed. It is not vunerable to madvise(DONTNEED)
> +	 * because madvise is not supported on hugetlbfs. The same applies
> +	 * for direct IO. unmap_hugepage_range() is only being called just
> +	 * before free_pgtables() so clearing VM_MAYSHARE will not cause
> +	 * surprises later.
> +	 */
> +	vma->vm_flags &= ~VM_MAYSHARE;
>  	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
>  }
>  
> @@ -2949,9 +2965,14 @@ void hugetlb_change_protection(struct vm_area_struct *vma,
>  		}
>  	}
>  	spin_unlock(&mm->page_table_lock);
> -	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
> -
> +	/*
> +	 * Must flush TLB before releasing i_mmap_mutex: x86's huge_pmd_unshare
> +	 * may have cleared our pud entry and done put_page on the page table:
> +	 * once we release i_mmap_mutex, another task can do the final put_page
> +	 * and that page table be reused and filled with junk.
> +	 */
>  	flush_tlb_range(vma, start, end);
> +	mutex_unlock(&vma->vm_file->f_mapping->i_mmap_mutex);
>  }
>  
>  int hugetlb_reserve_pages(struct inode *inode,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
