Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id B95456B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 10:11:13 -0400 (EDT)
Date: Fri, 20 Jul 2012 15:11:08 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: hugetlbfs: Close race during teardown of hugetlbfs
 shared page tables V2 (resend)
Message-ID: <20120720141108.GH9222@suse.de>
References: <20120720134937.GG9222@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120720134937.GG9222@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, David Gibson <david@gibson.dropbear.id.au>, Ken Chen <kenchen@google.com>, Cong Wang <xiyou.wangcong@gmail.com>, LKML <linux-kernel@vger.kernel.org>

Sorry for the resend, I did not properly refresh Cong Wang's suggested
fix. This V2 is still the mmap_sem approach that fixes a potential deadlock
problem pointed out by Michal.

Changelog since V1
 o Correct cut&paste error in race description			(hugh)
 o Handle potential deadlock during fork			(mhocko)
 o Reorder unlocking						(wangcong)

If a process creates a large hugetlbfs mapping that is eligible for page
table sharing and forks heavily with children some of whom fault and
others which destroy the mapping then it is possible for page tables to
get corrupted. Some teardowns of the mapping encounter a "bad pmd" and
output a message to the kernel log. The final teardown will trigger a
BUG_ON in mm/filemap.c.

This was reproduced in 3.4 but is known to have existed for a long time
and goes back at least as far as 2.6.37. It was probably was introduced in
2.6.20 by [39dde65c: shared page table for hugetlb page]. The messages
look like this;

[  ..........] Lots of bad pmd messages followed by this
[  127.164256] mm/memory.c:391: bad pmd ffff880412e04fe8(80000003de4000e7).
[  127.164257] mm/memory.c:391: bad pmd ffff880412e04ff0(80000003de6000e7).
[  127.164258] mm/memory.c:391: bad pmd ffff880412e04ff8(80000003de0000e7).
[  127.186778] ------------[ cut here ]------------
[  127.186781] kernel BUG at mm/filemap.c:134!
[  127.186782] invalid opcode: 0000 [#1] SMP
[  127.186783] CPU 7
[  127.186784] Modules linked in: af_packet cpufreq_conservative cpufreq_userspace cpufreq_powersave acpi_cpufreq mperf ext3 jbd dm_mod coretemp crc32c_intel usb_storage ghash_clmulni_intel aesni_intel i2c_i801 r8169 mii uas sr_mod cdrom sg iTCO_wdt iTCO_vendor_support shpchp serio_raw cryptd aes_x86_64 e1000e pci_hotplug dcdbas aes_generic container microcode ext4 mbcache jbd2 crc16 sd_mod crc_t10dif i915 drm_kms_helper drm i2c_algo_bit ehci_hcd ahci libahci usbcore rtc_cmos usb_common button i2c_core intel_agp video intel_gtt fan processor thermal thermal_sys hwmon ata_generic pata_atiixp libata scsi_mod
[  127.186801]
[  127.186802] Pid: 9017, comm: hugetlbfs-test Not tainted 3.4.0-autobuild #53 Dell Inc. OptiPlex 990/06D7TR
[  127.186804] RIP: 0010:[<ffffffff810ed6ce>]  [<ffffffff810ed6ce>] __delete_from_page_cache+0x15e/0x160
[  127.186809] RSP: 0000:ffff8804144b5c08  EFLAGS: 00010002
[  127.186810] RAX: 0000000000000001 RBX: ffffea000a5c9000 RCX: 00000000ffffffc0
[  127.186811] RDX: 0000000000000000 RSI: 0000000000000009 RDI: ffff88042dfdad00
[  127.186812] RBP: ffff8804144b5c18 R08: 0000000000000009 R09: 0000000000000003
[  127.186813] R10: 0000000000000000 R11: 000000000000002d R12: ffff880412ff83d8
[  127.186814] R13: ffff880412ff83d8 R14: 0000000000000000 R15: ffff880412ff83d8
[  127.186815] FS:  00007fe18ed2c700(0000) GS:ffff88042dce0000(0000) knlGS:0000000000000000
[  127.186816] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[  127.186817] CR2: 00007fe340000503 CR3: 0000000417a14000 CR4: 00000000000407e0
[  127.186818] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  127.186819] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  127.186820] Process hugetlbfs-test (pid: 9017, threadinfo ffff8804144b4000, task ffff880417f803c0)
[  127.186821] Stack:
[  127.186822]  ffffea000a5c9000 0000000000000000 ffff8804144b5c48 ffffffff810ed83b
[  127.186824]  ffff8804144b5c48 000000000000138a 0000000000001387 ffff8804144b5c98
[  127.186825]  ffff8804144b5d48 ffffffff811bc925 ffff8804144b5cb8 0000000000000000
[  127.186827] Call Trace:
[  127.186829]  [<ffffffff810ed83b>] delete_from_page_cache+0x3b/0x80
[  127.186832]  [<ffffffff811bc925>] truncate_hugepages+0x115/0x220
[  127.186834]  [<ffffffff811bca43>] hugetlbfs_evict_inode+0x13/0x30
[  127.186837]  [<ffffffff811655c7>] evict+0xa7/0x1b0
[  127.186839]  [<ffffffff811657a3>] iput_final+0xd3/0x1f0
[  127.186840]  [<ffffffff811658f9>] iput+0x39/0x50
[  127.186842]  [<ffffffff81162708>] d_kill+0xf8/0x130
[  127.186843]  [<ffffffff81162812>] dput+0xd2/0x1a0
[  127.186845]  [<ffffffff8114e2d0>] __fput+0x170/0x230
[  127.186848]  [<ffffffff81236e0e>] ? rb_erase+0xce/0x150
[  127.186849]  [<ffffffff8114e3ad>] fput+0x1d/0x30
[  127.186851]  [<ffffffff81117db7>] remove_vma+0x37/0x80
[  127.186853]  [<ffffffff81119182>] do_munmap+0x2d2/0x360
[  127.186855]  [<ffffffff811cc639>] sys_shmdt+0xc9/0x170
[  127.186857]  [<ffffffff81410a39>] system_call_fastpath+0x16/0x1b
[  127.186858] Code: 0f 1f 44 00 00 48 8b 43 08 48 8b 00 48 8b 40 28 8b b0 40 03 00 00 85 f6 0f 88 df fe ff ff 48 89 df e8 e7 cb 05 00 e9 d2 fe ff ff <0f> 0b 55 83 e2 fd 48 89 e5 48 83 ec 30 48 89 5d d8 4c 89 65 e0
[  127.186868] RIP  [<ffffffff810ed6ce>] __delete_from_page_cache+0x15e/0x160
[  127.186870]  RSP <ffff8804144b5c08>
[  127.186871] ---[ end trace 7cbac5d1db69f426 ]---

The bug is a race and not always easy to reproduce. To reproduce it I was
doing the following on a single socket I7-based machine with 16G of RAM.

$ hugeadm --pool-pages-max DEFAULT:13G
$ echo $((18*1048576*1024)) > /proc/sys/kernel/shmmax
$ echo $((18*1048576*1024)) > /proc/sys/kernel/shmall
$ for i in `seq 1 9000`; do ./hugetlbfs-test; done

On my particular machine, it usually triggers within 10 minutes but enabling
debug options can change the timing such that it never hits. Once the bug is
triggered, the machine is in trouble and needs to be rebooted. The machine
will respond but processes accessing proc like "ps aux" will hang due to
the BUG_ON. shutdown will also hang and needs a hard reset or a sysrq-b.

The test case was mostly written by Michal Hocko with a few minor changes
by me to reproduce this bug. Michal did a lot of heavy lifting eliminating
possible sources of the race and saved me the embarrassment of posting a
completely broken patch yesterday. He did not see this patch before
going to the lists so any critical flaws are all mine!

The basic problem is a race between page table sharing and teardown. For
the most part page table sharing depends on i_mmap_mutex. In some cases,
it is also taking the mm->page_table_lock for the PTE updates but with
shared page tables, it is the i_mmap_mutex that is more important.

Unfortunately it appears to be also insufficient. Consider the following
situation

Process A					Process B
---------					---------
hugetlb_fault					shmdt
  						LockWrite(mmap_sem)
    						  do_munmap
						    unmap_region
						      unmap_vmas
						        unmap_single_vma
						          unmap_hugepage_range
      						            Lock(i_mmap_mutex)
							    Lock(mm->page_table_lock)
							    huge_pmd_unshare/unmap tables <--- (1)
							    Unlock(mm->page_table_lock)
      						            Unlock(i_mmap_mutex)
  huge_pte_alloc				      ...
    Lock(i_mmap_mutex)				      ...
    vma_prio_walk, find svma, spte		      ...
    Lock(mm->page_table_lock)			      ...
    share spte					      ...
    Unlock(mm->page_table_lock)			      ...
    Unlock(i_mmap_mutex)			      ...
  hugetlb_no_page									  <--- (2)
						      free_pgtables
						        unlink_file_vma
							hugetlb_free_pgd_range
						    remove_vma_list

In this scenario, it is possible for Process A to share page tables with
Process B that is trying to tear them down.  The i_mmap_mutex on its own
does not prevent Process A walking Process B's page tables. At (1) above,
the page tables are not shared yet so it unmaps the PMDs. Process A sets
up page table sharing and at (2) faults a new entry. Process B then trips
up on it in free_pgtables.

This patch takes the mmap_sem for read and then the page_table_lock of
address spaces being considered for page table sharing. I verified that
page table sharing still occurs using the awesome technology of printk
to spit out a message when huge_pmd_share is successful. libhugetlbfs
regression test suite passed.

I strongly suggest this be treated as a -stable candidate if it is merged.

Test program is as follows.

==== CUT HERE ====

static size_t huge_page_size = (2UL << 20);
static size_t nr_huge_page_A = 512;
static size_t nr_huge_page_B = 5632;

unsigned int get_random(unsigned int max)
{
	struct timeval tv;

	gettimeofday(&tv, NULL);
	srandom(tv.tv_usec);
	return random() % max;
}

static void play(void *addr, size_t size)
{
	unsigned char *start = addr,
		      *end = start + size,
		      *a;
	start += get_random(size/2);

	/* we could itterate on huge pages but let's give it more time. */
	for (a = start; a < end; a += 4096)
		*a = 0;
}

int main(int argc, char **argv)
{
	key_t key = IPC_PRIVATE;
	size_t sizeA = nr_huge_page_A * huge_page_size;
	size_t sizeB = nr_huge_page_B * huge_page_size;
	int shmidA, shmidB;
	void *addrA = NULL, *addrB = NULL;
	int nr_children = 300, n = 0;

	if ((shmidA = shmget(key, sizeA, IPC_CREAT|SHM_HUGETLB|0660)) == -1) {
		perror("shmget:");
		return 1;
	}

	if ((addrA = shmat(shmidA, addrA, SHM_R|SHM_W)) == (void *)-1UL) {
		perror("shmat");
		return 1;
	}
	if ((shmidB = shmget(key, sizeB, IPC_CREAT|SHM_HUGETLB|0660)) == -1) {
		perror("shmget:");
		return 1;
	}

	if ((addrB = shmat(shmidB, addrB, SHM_R|SHM_W)) == (void *)-1UL) {
		perror("shmat");
		return 1;
	}

fork_child:
	switch(fork()) {
		case 0:
			switch (n%3) {
			case 0:
				play(addrA, sizeA);
				break;
			case 1:
				play(addrB, sizeB);
				break;
			case 2:
				break;
			}
			break;
		case -1:
			perror("fork:");
			break;
		default:
			if (++n < nr_children)
				goto fork_child;
			play(addrA, sizeA);
			break;
	}
	shmdt(addrA);
	shmdt(addrB);
	do {
		wait(NULL);
	} while (--n > 0);
	shmctl(shmidA, IPC_RMID, NULL);
	shmctl(shmidB, IPC_RMID, NULL);
	return 0;
}

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/ia64/mm/hugetlbpage.c    |    3 ++-
 arch/mips/mm/hugetlbpage.c    |    4 ++--
 arch/powerpc/mm/hugetlbpage.c |    3 ++-
 arch/s390/mm/hugetlbpage.c    |    2 +-
 arch/sh/mm/hugetlbpage.c      |    2 +-
 arch/sparc/mm/hugetlbpage.c   |    2 +-
 arch/tile/mm/hugetlbpage.c    |    2 +-
 arch/x86/mm/hugetlbpage.c     |   42 ++++++++++++++++++++++++++++++++++++++---
 include/linux/hugetlb.h       |    2 +-
 mm/hugetlb.c                  |    4 ++--
 10 files changed, 52 insertions(+), 14 deletions(-)

diff --git a/arch/ia64/mm/hugetlbpage.c b/arch/ia64/mm/hugetlbpage.c
index 5ca674b..2d4f574 100644
--- a/arch/ia64/mm/hugetlbpage.c
+++ b/arch/ia64/mm/hugetlbpage.c
@@ -25,7 +25,8 @@ unsigned int hpage_shift = HPAGE_SHIFT_DEFAULT;
 EXPORT_SYMBOL(hpage_shift);
 
 pte_t *
-huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
+huge_pte_alloc(struct mm_struct *mm, struct mm_struct *locked_mm,
+	       unsigned long addr, unsigned long sz)
 {
 	unsigned long taddr = htlbpage_to_page(addr);
 	pgd_t *pgd;
diff --git a/arch/mips/mm/hugetlbpage.c b/arch/mips/mm/hugetlbpage.c
index a7fee0d..8cfec7e 100644
--- a/arch/mips/mm/hugetlbpage.c
+++ b/arch/mips/mm/hugetlbpage.c
@@ -22,8 +22,8 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
-pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr,
-		      unsigned long sz)
+pte_t *huge_pte_alloc(struct mm_struct *mm, struct mm_struct *locked_mm,
+		      unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
 	pud_t *pud;
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index fb05b12..4884b97 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -175,7 +175,8 @@ static int __hugepte_alloc(struct mm_struct *mm, hugepd_t *hpdp,
 #define HUGEPD_PUD_SHIFT PMD_SHIFT
 #endif
 
-pte_t *huge_pte_alloc(struct mm_struct *mm, unsigned long addr, unsigned long sz)
+pte_t *huge_pte_alloc(struct mm_struct *mm, struct mm_struct *locked_mm,
+		      unsigned long addr, unsigned long sz)
 {
 	pgd_t *pg;
 	pud_t *pu;
diff --git a/arch/s390/mm/hugetlbpage.c b/arch/s390/mm/hugetlbpage.c
index 597bb2d..912647b 100644
--- a/arch/s390/mm/hugetlbpage.c
+++ b/arch/s390/mm/hugetlbpage.c
@@ -62,7 +62,7 @@ void arch_release_hugepage(struct page *page)
 	page[1].index = 0;
 }
 
-pte_t *huge_pte_alloc(struct mm_struct *mm,
+pte_t *huge_pte_alloc(struct mm_struct *mm, struct mm_struct *locked_mm,
 			unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgdp;
diff --git a/arch/sh/mm/hugetlbpage.c b/arch/sh/mm/hugetlbpage.c
index d776234..fb0a427 100644
--- a/arch/sh/mm/hugetlbpage.c
+++ b/arch/sh/mm/hugetlbpage.c
@@ -21,7 +21,7 @@
 #include <asm/tlbflush.h>
 #include <asm/cacheflush.h>
 
-pte_t *huge_pte_alloc(struct mm_struct *mm,
+pte_t *huge_pte_alloc(struct mm_struct *mm, struct mm_struct *locked_mm,
 			unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
diff --git a/arch/sparc/mm/hugetlbpage.c b/arch/sparc/mm/hugetlbpage.c
index 07e1453..04c063f 100644
--- a/arch/sparc/mm/hugetlbpage.c
+++ b/arch/sparc/mm/hugetlbpage.c
@@ -193,7 +193,7 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 				pgoff, flags);
 }
 
-pte_t *huge_pte_alloc(struct mm_struct *mm,
+pte_t *huge_pte_alloc(struct mm_struct *mm, struct mm_struct *locked_mm,
 			unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
diff --git a/arch/tile/mm/hugetlbpage.c b/arch/tile/mm/hugetlbpage.c
index 42cfcba..490d29b 100644
--- a/arch/tile/mm/hugetlbpage.c
+++ b/arch/tile/mm/hugetlbpage.c
@@ -28,7 +28,7 @@
 #include <asm/tlb.h>
 #include <asm/tlbflush.h>
 
-pte_t *huge_pte_alloc(struct mm_struct *mm,
+pte_t *huge_pte_alloc(struct mm_struct *mm, struct mm_struct *locked_mm,
 		      unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index f6679a7..944b2df 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -58,7 +58,8 @@ static int vma_shareable(struct vm_area_struct *vma, unsigned long addr)
 /*
  * search for a shareable pmd page for hugetlb.
  */
-static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
+static void huge_pmd_share(struct mm_struct *mm, struct mm_struct *locked_mm,
+			   unsigned long addr, pud_t *pud)
 {
 	struct vm_area_struct *vma = find_vma(mm, addr);
 	struct address_space *mapping = vma->vm_file->f_mapping;
@@ -68,14 +69,40 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	struct vm_area_struct *svma;
 	unsigned long saddr;
 	pte_t *spte = NULL;
+	spinlock_t *spage_table_lock = NULL;
+	struct rw_semaphore *smmap_sem = NULL;
 
 	if (!vma_shareable(vma, addr))
 		return;
 
+retry:
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_prio_tree_foreach(svma, &iter, &mapping->i_mmap, idx, idx) {
 		if (svma == vma)
 			continue;
+		if (svma->vm_mm == vma->vm_mm)
+			continue;
+
+		/*
+		 * The target mm could be in the process of tearing down
+		 * its page tables and the i_mmap_mutex on its own is
+		 * not sufficient. To prevent races against teardown and
+		 * pagetable updates, we acquire the mmap_sem and pagetable
+		 * lock of the remote address space. down_read_trylock()
+		 * is necessary as the other process could also be trying
+		 * to share pagetables with the current mm. In the fork
+		 * case, we are already both mm's so check for that
+		 */
+		if (locked_mm != svma->vm_mm) {
+			if (!down_read_trylock(&svma->vm_mm->mmap_sem)) {
+				mutex_unlock(&mapping->i_mmap_mutex);
+				goto retry;
+			}
+			smmap_sem = &svma->vm_mm->mmap_sem;
+		}
+
+		spage_table_lock = &svma->vm_mm->page_table_lock;
+		spin_lock_nested(spage_table_lock, SINGLE_DEPTH_NESTING);
 
 		saddr = page_table_shareable(svma, vma, addr, idx);
 		if (saddr) {
@@ -85,6 +112,12 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 				break;
 			}
 		}
+		spin_unlock(spage_table_lock);
+		spage_table_lock = NULL;
+		if (smmap_sem) {
+			up_read(smmap_sem);
+			smmap_sem = NULL;
+		}
 	}
 
 	if (!spte)
@@ -96,6 +129,9 @@ static void huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
 	else
 		put_page(virt_to_page(spte));
 	spin_unlock(&mm->page_table_lock);
+	spin_unlock(spage_table_lock);
+	if (smmap_sem)
+		up_read(smmap_sem);
 out:
 	mutex_unlock(&mapping->i_mmap_mutex);
 }
@@ -127,7 +163,7 @@ int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep)
 	return 1;
 }
 
-pte_t *huge_pte_alloc(struct mm_struct *mm,
+pte_t *huge_pte_alloc(struct mm_struct *mm, struct mm_struct *locked_mm,
 			unsigned long addr, unsigned long sz)
 {
 	pgd_t *pgd;
@@ -142,7 +178,7 @@ pte_t *huge_pte_alloc(struct mm_struct *mm,
 		} else {
 			BUG_ON(sz != PMD_SIZE);
 			if (pud_none(*pud))
-				huge_pmd_share(mm, addr, pud);
+				huge_pmd_share(mm, locked_mm, addr, pud);
 			pte = (pte_t *) pmd_alloc(mm, pud, addr);
 		}
 	}
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 000837e..bae0f7b 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -63,7 +63,7 @@ extern struct list_head huge_boot_pages;
 
 /* arch callbacks */
 
-pte_t *huge_pte_alloc(struct mm_struct *mm,
+pte_t *huge_pte_alloc(struct mm_struct *mm, struct mm_struct *locked_mm,
 			unsigned long addr, unsigned long sz);
 pte_t *huge_pte_offset(struct mm_struct *mm, unsigned long addr);
 int huge_pmd_unshare(struct mm_struct *mm, unsigned long *addr, pte_t *ptep);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ae8f708..4832277 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2244,7 +2244,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 		src_pte = huge_pte_offset(src, addr);
 		if (!src_pte)
 			continue;
-		dst_pte = huge_pte_alloc(dst, addr, sz);
+		dst_pte = huge_pte_alloc(dst, src, addr, sz);
 		if (!dst_pte)
 			goto nomem;
 
@@ -2745,7 +2745,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			       VM_FAULT_SET_HINDEX(h - hstates);
 	}
 
-	ptep = huge_pte_alloc(mm, address, huge_page_size(h));
+	ptep = huge_pte_alloc(mm, NULL, address, huge_page_size(h));
 	if (!ptep)
 		return VM_FAULT_OOM;
 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
