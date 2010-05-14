Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D97B96B0205
	for <linux-mm@kvack.org>; Fri, 14 May 2010 03:48:11 -0400 (EDT)
Date: Fri, 14 May 2010 16:46:41 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/7] hugetlb, rmap: add reverse mapping for hugepage
Message-ID: <20100514074641.GD10000@spritzerA.linux.bs1.fc.nec.co.jp>
References: <1273737326-21211-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1273737326-21211-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100513152737.GE27949@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100513152737.GE27949@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 04:27:37PM +0100, Mel Gorman wrote:
> On Thu, May 13, 2010 at 04:55:20PM +0900, Naoya Horiguchi wrote:
> > While hugepage is not currently swappable, rmapping can be useful
> > for memory error handler.
> > Using rmap, memory error handler can collect processes affected
> > by hugepage errors and unmap them to contain error's effect.
> > 
> 
> As a verification point, can you ensure that the libhugetlbfs "make
> func" tests complete successfully with this patch applied? It's also
> important that there is no oddness in the Hugepage-related counters in
> /proc/meminfo. I'm not in the position to test it now unfortunately as
> I'm on the road.

Yes. Thanks for the good test-set.

Hmm. I failed libhugetlbfs test with a oops in "private mapped" test :(

dm120ei2 login: [  693.471581] ------------[ cut here ]------------
[  693.472130] kernel BUG at mm/hugetlb.c:2305!
[  693.472130] invalid opcode: 0000 [#1] SMP 
[  693.472130] last sysfs file: /sys/devices/pci0000:00/0000:00:1c.0/0000:12:00.0/local_cpus
[  693.472130] CPU 2 
[  693.472130] Modules linked in: ipt_MASQUERADE iptable_nat nf_nat nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp llc autofs4 lockd sunrpc bonding ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr ipv6 iscsi_tcp libiscsi_tcp libiscsi scsi_transport_iscsi dm_multipath scsi_dh video output sbs sbshc battery acpi_memhotplug ac parport_pc lp parport kvm_intel kvm e1000e option usbserial sr_mod cdrom sg ioatdma i2c_i801 shpchp i2c_core serio_raw button dca rtc_cmos rtc_core rtc_lib pcspkr dm_snapshot dm_zero dm_mirror dm_region_hash dm_log dm_mod ata_piix ahci libata sd_mod scsi_mod crc_t10dif ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: microcode]
[  693.472130] 
[  693.472130] Pid: 4896, comm: private Not tainted 2.6.34-rc7-hwpoison-hugetlb #702 ******************
[  693.472130] RIP: 0010:[<ffffffff810f7812>]  [<ffffffff810f7812>] hugepage_add_anon_rmap+0x12/0x6f
[  693.472130] RSP: 0000:ffff8801d92c1b98  EFLAGS: 00010246
[  693.472130] RAX: ffff8801d92c1fd8 RBX: ffff8801d9a76de8 RCX: 0000000000000000
[  693.472130] RDX: 00000000f7a00000 RSI: ffff8801d98ee840 RDI: ffffea00069a1000
[  693.472130] RBP: ffff8801d92c1b98 R08: ffff880000000000 R09: 00003ffffffff000
[  693.472130] R10: 0000000000000246 R11: 0000000000000000 R12: ffffea000699a000
[  693.472130] R13: 00000000069a8000 R14: ffffea000699a000 R15: 0000000000000201
[  693.472130] FS:  0000000000000000(0000) GS:ffff880002a00000(0063) knlGS:00000000f77bb6c0
[  693.472130] CS:  0010 DS: 002b ES: 002b CR0: 000000008005003b
[  693.472130] CR2: 00000000f7a00000 CR3: 00000001d9208000 CR4: 00000000000006e0
[  693.472130] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  693.472130] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  693.472130] Process private (pid: 4896, threadinfo ffff8801d92c0000, task ffff8801e243a390)
[  693.472130] Stack:
[  693.472130]  ffff8801d92c1cb8 ffffffff810f9561 ffff8801e243a390 000000000000013f
[  693.472130] <0> ffff8801d92c1c28 ffffffff8107851b ffff8801d92c1be8 ffffea000699a000
[  693.472130] <0> 80000001e2c000a5 ffff8801d9a76de8 00000000f7a00000 ffff8801d98ee840
[  693.472130] Call Trace:
[  693.472130]  [<ffffffff810f9561>] hugetlb_cow+0x645/0x677
[  693.472130]  [<ffffffff8107851b>] ? __lock_acquire+0x7b1/0x808
[  693.472130]  [<ffffffff810f9b90>] ? hugetlb_fault+0x5fd/0x6ac
[  693.472130]  [<ffffffff810f9bbd>] hugetlb_fault+0x62a/0x6ac
[  693.472130]  [<ffffffff810746a9>] ? trace_hardirqs_off+0xd/0xf
[  693.472130]  [<ffffffff8106a0fe>] ? cpu_clock+0x41/0x5b
[  693.472130]  [<ffffffff8107461d>] ? trace_hardirqs_off_caller+0x1f/0x9e
[  693.472130]  [<ffffffff810e5b28>] handle_mm_fault+0x61/0x8b4
[  693.472130]  [<ffffffff81392b12>] ? do_page_fault+0x1ef/0x3da
[  693.472130]  [<ffffffff81392c02>] do_page_fault+0x2df/0x3da
[  693.472130]  [<ffffffff8106a0fe>] ? cpu_clock+0x41/0x5b
[  693.472130]  [<ffffffff81073eff>] ? lock_release_holdtime+0xa4/0xa9
[  693.472130]  [<ffffffff8138ea3e>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  693.472130]  [<ffffffff8138fdc6>] ? error_sti+0x5/0x6
[  693.472130]  [<ffffffff8138ea3e>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  693.472130]  [<ffffffff8138fbb5>] page_fault+0x25/0x30
[  693.472130] Code: 00 00 00 00 41 c7 40 08 01 00 00 00 8b 77 08 4c 89 c7 e8 7a aa fd ff c9 c3 55 48 89 e5 0f 1f 44 00 00 48 8b 4e 78 48 85 c9 75 04 <0f> 0b eb fe 48 3b 56 08 72 06 48 3b 56 10 72 04 0f 0b eb fe f0 
[  693.472130] RIP  [<ffffffff810f7812>] hugepage_add_anon_rmap+0x12/0x6f
[  693.472130]  RSP <ffff8801d92c1b98>
[  693.869837] ---[ end trace bd996c35d4583bca ]---

Someone seems to call hugetlb_fault() with anon_vma == NULL.
For more detail, I'm investigating it.

> > Current status of hugepage rmap differs depending on mapping mode:
> > - for shared hugepage:
> >   we can collect processes using a hugepage through pagecache,
> >   but can not unmap the hugepage because of the lack of mapcount.
> > - for privately mapped hugepage:
> >   we can neither collect processes nor unmap the hugepage.
> > 
> > To realize hugepage rmapping, this patch introduces mapcount for
> > shared/private-mapped hugepage and anon_vma for private-mapped hugepage.
> > 
> > This patch can be the replacement of the following bug fix.
> > 
> 
> Actually, you replace chunks but not all of that fix with this patch.
> After this patch HUGETLB_POISON is never assigned but the definition still
> exists in poison.h. You should also remove it if it is unnecessary.

OK. I'll remove HUGETLB_POISON in the next post.

> >   commit 23be7468e8802a2ac1de6ee3eecb3ec7f14dc703
> >   Author: Mel Gorman <mel@csn.ul.ie>
> >   Date:   Fri Apr 23 13:17:56 2010 -0400
> >   Subject: hugetlb: fix infinite loop in get_futex_key() when backed by huge pages
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Andi Kleen <andi@firstfloor.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Wu Fengguang <fengguang.wu@intel.com>
> > Cc: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  include/linux/hugetlb.h |    1 +
> >  mm/hugetlb.c            |   42 +++++++++++++++++++++++++++++++++++++++++-
> >  mm/rmap.c               |   16 ++++++++++++++++
> >  3 files changed, 58 insertions(+), 1 deletions(-)
> > 
> > diff --git v2.6.34-rc7/include/linux/hugetlb.h v2.6.34-rc7/include/linux/hugetlb.h
> > index 78b4bc6..1d0c2a4 100644
> > --- v2.6.34-rc7/include/linux/hugetlb.h
> > +++ v2.6.34-rc7/include/linux/hugetlb.h
> > @@ -108,6 +108,7 @@ static inline void hugetlb_report_meminfo(struct seq_file *m)
> >  #define is_hugepage_only_range(mm, addr, len)	0
> >  #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
> >  #define hugetlb_fault(mm, vma, addr, flags)	({ BUG(); 0; })
> > +#define huge_pte_offset(mm, address)	0
> >  
> >  #define hugetlb_change_protection(vma, address, end, newprot)
> >  
> > diff --git v2.6.34-rc7/mm/hugetlb.c v2.6.34-rc7/mm/hugetlb.c
> > index ffbdfc8..149eb12 100644
> > --- v2.6.34-rc7/mm/hugetlb.c
> > +++ v2.6.34-rc7/mm/hugetlb.c
> > @@ -18,6 +18,7 @@
> >  #include <linux/bootmem.h>
> >  #include <linux/sysfs.h>
> >  #include <linux/slab.h>
> > +#include <linux/rmap.h>
> >  
> >  #include <asm/page.h>
> >  #include <asm/pgtable.h>
> > @@ -2125,6 +2126,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
> >  			entry = huge_ptep_get(src_pte);
> >  			ptepage = pte_page(entry);
> >  			get_page(ptepage);
> > +			page_dup_rmap(ptepage);
> >  			set_huge_pte_at(dst, addr, dst_pte, entry);
> >  		}
> >  		spin_unlock(&src->page_table_lock);
> > @@ -2203,6 +2205,7 @@ void __unmap_hugepage_range(struct vm_area_struct *vma, unsigned long start,
> >  	flush_tlb_range(vma, start, end);
> >  	mmu_notifier_invalidate_range_end(mm, start, end);
> >  	list_for_each_entry_safe(page, tmp, &page_list, lru) {
> > +		page_remove_rmap(page);
> >  		list_del(&page->lru);
> >  		put_page(page);
> >  	}
> > @@ -2268,6 +2271,26 @@ static int unmap_ref_private(struct mm_struct *mm, struct vm_area_struct *vma,
> >  	return 1;
> >  }
> >  
> > +/*
> > + * This is a counterpart of page_add_anon_rmap() for hugepage.
> > + */
> > +static void hugepage_add_anon_rmap(struct page *page,
> > +			struct vm_area_struct *vma, unsigned long address)
> 
> So hugepage anon rmap is MAP_PRIVATE mappings.

Yes.

> > +{
> > +	struct anon_vma *anon_vma = vma->anon_vma;
> > +	int first;
> > +
> > +	BUG_ON(!anon_vma);
> > +	BUG_ON(address < vma->vm_start || address >= vma->vm_end);
> > +	first = atomic_inc_and_test(&page->_mapcount);
> > +	if (first) {
> > +		anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
> > +		page->mapping = (struct address_space *) anon_vma;
> > +		page->index = linear_page_index(vma, address)
> > +			>> compound_order(page);
> 
> What was wrong with vma_hugecache_offset()? You can lookup the necessary
> hstate with hstate_vma(). Even if they are similar functionally, the
> use of hstate would match better how other parts of hugetlbfs handle
> multiple page sizes.

I understand.

> > +	}
> > +}
> 
> Ok, so this is against 2.6.34-rc7, right?

Yes.

> For ordinary anon_vma's, there
> is a chain of related vma's chained together via the anon_vma's. It's so
> in the event of an unmapping, all the PTEs related to the page can be
> found. Where are we doing the same here?

Finding all processes using a hugepage is done by try_to_unmap() as usual.
Among callers of this function, only memory error handler calls it for
hugepage for now.
What this patch does is to enable try_to_unmap() to be called for hugepages
by setting up anon_vma in hugetlb code.

> I think what you're getting with this is the ability to unmap MAP_PRIVATE pages
> from one process but if there are multiple processes, the second process could
> still end up referencing the poisoned MAP_PRIVATE page. Is this accurate? Even
> if it is, I guess it's still an improvement over what currently happens.

Try_to_unmap_anon() runs for each vma belonging to the anon_vma associated
with the error hugepage. So it works for multiple processes.

> > +
> >  static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> >  			unsigned long address, pte_t *ptep, pte_t pte,
> >  			struct page *pagecache_page)
> > @@ -2348,6 +2371,12 @@ retry_avoidcopy:
> >  		huge_ptep_clear_flush(vma, address, ptep);
> >  		set_huge_pte_at(mm, address, ptep,
> >  				make_huge_pte(vma, new_page, 1));
> > +		page_remove_rmap(old_page);
> > +		/*
> > +		 * We need not call anon_vma_prepare() because anon_vma
> > +		 * is already prepared when the process fork()ed.
> > +		 */
> > +		hugepage_add_anon_rmap(new_page, vma, address);
> 
> This means that the anon_vma is shared between parent and child even
> after fork. Does this not mean that the behaviour of anon_vma differs
> between the core VM and hugetlb?

No. IIUC, anon_vma associated with (non-huge) anonymous page is also shared
between parent and child until COW.

> >  		/* Make the old page be freed below */
> >  		new_page = old_page;
> >  	}
> > @@ -2450,7 +2479,11 @@ retry:
> >  			spin_unlock(&inode->i_lock);
> >  		} else {
> >  			lock_page(page);
> > -			page->mapping = HUGETLB_POISON;
> > +			if (unlikely(anon_vma_prepare(vma))) {
> > +				ret = VM_FAULT_OOM;
> > +				goto backout_unlocked;
> > +			}
> > +			hugepage_add_anon_rmap(page, vma, address);
> 
> Seems ok for private pages at least.
> 
> >  		}
> >  	}
> >  
> > @@ -2479,6 +2512,13 @@ retry:
> >  				&& (vma->vm_flags & VM_SHARED)));
> >  	set_huge_pte_at(mm, address, ptep, new_pte);
> >  
> > +	/*
> > +	 * For privately mapped hugepage, _mapcount is incremented
> > +	 * in hugetlb_cow(), so only increment for shared hugepage here.
> > +	 */
> > +	if (vma->vm_flags & VM_MAYSHARE)
> > +		page_dup_rmap(page);
> > +
> 
> What happens when try_to_unmap_file is called on a hugetlb page?

Try_to_unmap_file() is called for shared hugepages, so it tracks all vmas
sharing one hugepage through pagecache pointed to by page->mapping,
and sets all ptes into hwpoison swap entries instead of flushing them.
Curiously file backed pte is changed to swap entry, but it's OK because
hwpoison hugepage should not be touched afterward.

> >  	if ((flags & FAULT_FLAG_WRITE) && !(vma->vm_flags & VM_SHARED)) {
> >  		/* Optimization, do the COW without a second fault */
> >  		ret = hugetlb_cow(mm, vma, address, ptep, new_pte, page);
> > diff --git v2.6.34-rc7/mm/rmap.c v2.6.34-rc7/mm/rmap.c
> > index 0feeef8..58cd2f9 100644
> > --- v2.6.34-rc7/mm/rmap.c
> > +++ v2.6.34-rc7/mm/rmap.c
> > @@ -56,6 +56,7 @@
> >  #include <linux/memcontrol.h>
> >  #include <linux/mmu_notifier.h>
> >  #include <linux/migrate.h>
> > +#include <linux/hugetlb.h>
> >  
> >  #include <asm/tlbflush.h>
> >  
> > @@ -326,6 +327,8 @@ vma_address(struct page *page, struct vm_area_struct *vma)
> >  	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> >  	unsigned long address;
> >  
> > +	if (unlikely(is_vm_hugetlb_page(vma)))
> > +		pgoff = page->index << compound_order(page);
> 
> Again, it would be nice to use hstate information if possible just so
> how the pagesize is discovered is consistent.

OK.

> >  	address = vma->vm_start + ((pgoff - vma->vm_pgoff) << PAGE_SHIFT);
> >  	if (unlikely(address < vma->vm_start || address >= vma->vm_end)) {
> >  		/* page should be within @vma mapping range */
> > @@ -369,6 +372,12 @@ pte_t *page_check_address(struct page *page, struct mm_struct *mm,
> >  	pte_t *pte;
> >  	spinlock_t *ptl;
> >  
> > +	if (unlikely(PageHuge(page))) {
> > +		pte = huge_pte_offset(mm, address);
> > +		ptl = &mm->page_table_lock;
> > +		goto check;
> > +	}
> > +
> >  	pgd = pgd_offset(mm, address);
> >  	if (!pgd_present(*pgd))
> >  		return NULL;
> > @@ -389,6 +398,7 @@ pte_t *page_check_address(struct page *page, struct mm_struct *mm,
> >  	}
> >  
> >  	ptl = pte_lockptr(mm, pmd);
> > +check:
> >  	spin_lock(ptl);
> >  	if (pte_present(*pte) && page_to_pfn(page) == pte_pfn(*pte)) {
> >  		*ptlp = ptl;
> > @@ -873,6 +883,12 @@ void page_remove_rmap(struct page *page)
> >  		page_clear_dirty(page);
> >  		set_page_dirty(page);
> >  	}
> > +	/*
> > +	 * Mapping for Hugepages are not counted in NR_ANON_PAGES nor
> > +	 * NR_FILE_MAPPED and no charged by memcg for now.
> > +	 */
> > +	if (unlikely(PageHuge(page)))
> > +		return;
> >  	if (PageAnon(page)) {
> >  		mem_cgroup_uncharge_page(page);
> >  		__dec_zone_page_state(page, NR_ANON_PAGES);
> 
> I don't see anything obviously wrong with this but it's a bit rushed and
> there are a few snarls that I pointed out above. I'd like to hear it passed
> the libhugetlbfs regression tests for different sizes without any oddness
> in the counters.

Since there exists regression as described above, I'll fix it first of all.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
