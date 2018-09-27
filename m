Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BCE28E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 03:43:49 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id k21-v6so1405629qtj.23
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 00:43:49 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n64-v6si1027624qkd.186.2018.09.27.00.43.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 00:43:47 -0700 (PDT)
Date: Thu, 27 Sep 2018 15:43:38 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH v2] mm: mprotect: check page dirty when change ptes
Message-ID: <20180927074338.GB8870@xz-x1>
References: <20180912064921.31015-1-peterx@redhat.com>
 <20180912130355.GA4009@redhat.com>
 <20180912132438.GB4009@redhat.com>
 <20180913073722.GF10763@xz-x1>
 <20180913142328.GA3576@redhat.com>
 <20180914004239.GA31077@redhat.com>
 <20180914071610.GL10763@xz-x1>
 <20180915004157.GA15678@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180915004157.GA15678@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Khalid Aziz <khalid.aziz@oracle.com>, Thomas Gleixner <tglx@linutronix.de>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andi Kleen <ak@linux.intel.com>, Henry Willard <henry.willard@oracle.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-mm@kvack.org

On Fri, Sep 14, 2018 at 08:41:57PM -0400, Jerome Glisse wrote:
> On Fri, Sep 14, 2018 at 03:16:11PM +0800, Peter Xu wrote:
> > On Thu, Sep 13, 2018 at 08:42:39PM -0400, Jerome Glisse wrote:
> > > On Thu, Sep 13, 2018 at 10:23:28AM -0400, Jerome Glisse wrote:
> > > > On Thu, Sep 13, 2018 at 03:37:22PM +0800, Peter Xu wrote:
> > > > > On Wed, Sep 12, 2018 at 09:24:39AM -0400, Jerome Glisse wrote:
> > > > > > On Wed, Sep 12, 2018 at 09:03:55AM -0400, Jerome Glisse wrote:
> > > > > > > On Wed, Sep 12, 2018 at 02:49:21PM +0800, Peter Xu wrote:
> > > > > > > > Add an extra check on page dirty bit in change_pte_range() since there
> > > > > > > > might be case where PTE dirty bit is unset but it's actually dirtied.
> > > > > > > > One example is when a huge PMD is splitted after written: the dirty bit
> > > > > > > > will be set on the compound page however we won't have the dirty bit set
> > > > > > > > on each of the small page PTEs.
> > > > > > > > 
> > > > > > > > I noticed this when debugging with a customized kernel that implemented
> > > > > > > > userfaultfd write-protect.  In that case, the dirty bit will be critical
> > > > > > > > since that's required for userspace to handle the write protect page
> > > > > > > > fault (otherwise it'll get a SIGBUS with a loop of page faults).
> > > > > > > > However it should still be good even for upstream Linux to cover more
> > > > > > > > scenarios where we shouldn't need to do extra page faults on the small
> > > > > > > > pages if the previous huge page is already written, so the dirty bit
> > > > > > > > optimization path underneath can cover more.
> > > > > > > > 
> > > > > > > 
> > > > > > > So as said by Kirill NAK you are not looking at the right place for
> > > > > > > your bug please first apply the below patch and read my analysis in
> > > > > > > my last reply.
> > > > > > 
> > > > > > Just to be clear you are trying to fix a userspace bug that is hidden
> > > > > > for non THP pages by a kernel space bug inside userfaultfd by making
> > > > > > the kernel space bug of userfaultfd buggy for THP too.
> > > > > > 
> > > > > > 
> > > > > > > 
> > > > > > > Below patch fix userfaultfd bug. I am not posting it as it is on a
> > > > > > > branch and i am not sure when Andrea plan to post. Andrea feel free
> > > > > > > to squash that fix.
> > > > > > > 
> > > > > > > 
> > > > > > > From 35cdb30afa86424c2b9f23c0982afa6731be961c Mon Sep 17 00:00:00 2001
> > > > > > > From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
> > > > > > > Date: Wed, 12 Sep 2018 08:58:33 -0400
> > > > > > > Subject: [PATCH] userfaultfd: do not set dirty accountable when changing
> > > > > > >  protection
> > > > > > > MIME-Version: 1.0
> > > > > > > Content-Type: text/plain; charset=UTF-8
> > > > > > > Content-Transfer-Encoding: 8bit
> > > > > > > 
> > > > > > > mwriteprotect_range() has nothing to do with the dirty accountable
> > > > > > > optimization so do not set it as it opens a door for userspace to
> > > > > > > unwrite protect pages in a range that is write protected ie the vma
> > > > > > > !(vm_flags & VM_WRITE).
> > > > > > > 
> > > > > > > Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> > > > > > > ---
> > > > > > >  mm/userfaultfd.c | 2 +-
> > > > > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > > > > 
> > > > > > > diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> > > > > > > index a0379c5ffa7c..59db1ce48fa0 100644
> > > > > > > --- a/mm/userfaultfd.c
> > > > > > > +++ b/mm/userfaultfd.c
> > > > > > > @@ -632,7 +632,7 @@ int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
> > > > > > >  		newprot = vm_get_page_prot(dst_vma->vm_flags);
> > > > > > >  
> > > > > > >  	change_protection(dst_vma, start, start + len, newprot,
> > > > > > > -				!enable_wp, 0);
> > > > > > > +				false, 0);
> > > > > > >  
> > > > > > >  	err = 0;
> > > > > > >  out_unlock:
> > > > > 
> > > > > Hi, Jerome,
> > > > > 
> > > > > I tried your patch, unluckily it didn't work just like when not
> > > > > applied:
> > > > > 
> > > > > Sep 13 15:16:52 px-ws kernel: FAULT_FLAG_ALLOW_RETRY missing 71
> > > > > Sep 13 15:16:52 px-ws kernel: CPU: 5 PID: 1625 Comm: qemu-system-x86 Not tainted 4.19.0-rc2+ #31                                                                            
> > > > > Sep 13 15:16:52 px-ws kernel: Hardware name: LENOVO ThinkCentre M8500t-N000/SHARKBAY, BIOS FBKTC6AUS 06/22/2016                                                             
> > > > > Sep 13 15:16:52 px-ws kernel: Call Trace:
> > > > > Sep 13 15:16:52 px-ws kernel:  dump_stack+0x5c/0x7b
> > > > > Sep 13 15:16:52 px-ws kernel:  handle_userfault+0x4b5/0x780
> > > > > Sep 13 15:16:52 px-ws kernel:  ? userfaultfd_ctx_put+0xb0/0xb0
> > > > > Sep 13 15:16:52 px-ws kernel:  do_wp_page+0x1bd/0x5a0
> > > > > Sep 13 15:16:52 px-ws kernel:  __handle_mm_fault+0x7f9/0x1250
> > > > > Sep 13 15:16:52 px-ws kernel:  handle_mm_fault+0xfc/0x1f0
> > > > > Sep 13 15:16:52 px-ws kernel:  __do_page_fault+0x255/0x520
> > > > > Sep 13 15:16:52 px-ws kernel:  do_page_fault+0x32/0x110
> > > > > Sep 13 15:16:52 px-ws kernel:  ? page_fault+0x8/0x30
> > > > > Sep 13 15:16:52 px-ws kernel:  page_fault+0x1e/0x30
> > > > > Sep 13 15:16:52 px-ws kernel: RIP: 0033:0x7f2a9d3254e0
> > > > > Sep 13 15:16:52 px-ws kernel: Code: 73 01 c1 ef 07 48 81 e6 00 f0 ff ff 81 e7 e0 1f 00 00 49 8d bc 3e 40 57 00 00 48 3b 37 48 8b f3 0f 85 a4 01 00 00 48 03 77 10 <66> 89 06f
> > > > > Sep 13 15:16:52 px-ws kernel: RSP: 002b:00007f2ab1aae390 EFLAGS: 00010202
> > > > > Sep 13 15:16:52 px-ws kernel: RAX: 0000000000000246 RBX: 0000000000001ff2 RCX: 0000000000000031                                                                             
> > > > > Sep 13 15:16:52 px-ws kernel: RDX: ffffffffffac9604 RSI: 00007f2a53e01ff2 RDI: 000055a98fa049c0                                                                             
> > > > > Sep 13 15:16:52 px-ws kernel: RBP: 0000000000001ff4 R08: 0000000000000000 R09: 0000000000000002                                                                             
> > > > > Sep 13 15:16:52 px-ws kernel: R10: 0000000000000000 R11: 00007f2a98201030 R12: 0000000000001ff2                                                                             
> > > > > Sep 13 15:16:52 px-ws kernel: R13: 0000000000000000 R14: 000055a98f9ff260 R15: 00007f2ab1aaf700                                                                             
> > > > > 
> > > > > In case you'd like to try, here's the QEMU binary I'm testing:
> > > > > 
> > > > > https://github.com/xzpeter/qemu/tree/peter-userfault-wp-test
> > > > > 
> > > > > It write protects the whole system when received HMP command "info
> > > > > status" (I hacked that command for simplicity; it's of course not used
> > > > > for that...).
> > > > > 
> > > > > Would you please help me understand how your patch could resolve the
> > > > > wp page fault from userspace if not with dirty_accountable set in the
> > > > > uffd-wp world (sorry for asking a question that is related to a custom
> > > > > tree, but finally it'll be targeted at upstream after all)? I asked
> > > > > this question in my previous reply to you in v1 but you didn't
> > > > > respond.  I'd be glad to test any of your further patches if you can
> > > > > help solve the problem, but I'd also appreciate if you could explain
> > > > > it a bit on how it work since again I didn't see why it could work:
> > > > > again, if without that dirty_accountable set then IMO we will never
> > > > > setup _PAGE_WRITE for page entries and IMHO that's needed for
> > > > > resolving the page fault for uffd-wp tree.
> > > > 
> > > > I missed that reply and forgot about PAGE_COPY ... So below is
> > > > what i believe a proper fix for your issue:
> > > > 
> > > 
> > > Below is a slightly better one to avoid mkwrite on COW page but it is
> > > still kind of ugly to do that in those function maybe adding a new helper
> > > would be a better way dunno. Anyway untested but it is better than trying
> > > to set pte dirty.
> > > 
> > > 
> 
> [...]
> 
> > 
> > Hi, Jerome,
> > 
> > The first version worked for me but the 2nd didn't.  Both will need to
> > be fixed up by myself to at least pass the compilation so I'm not sure
> > whether the 2nd patch didn't work because of my changes or your patch
> > is broken.  Didn't spend more time to dig.
> > 
> > Anyway, thanks for these attempts and your help.  Let me know if you
> > want me to test a 3rd version, or I'll just keep the 1st patch here in
> > my local tree together with the rest of the work (I'd say that's far
> > easier to understand than the previous oneliner) since it at least
> > fixes the thing up.
> > 
> > Regards,
> 
> I fixed the build issue below just in case but it is untested.
> 
> If the second version do not work then page are likely real COW page ie
> mapcount is elevated because of a fork() (thought maybe userfaultfd do
> something there too).
> 
> I am not familiar with how userfault works to determine if it is expected
> we should not allow write to anonymous page that have page mapping
> elevated, maybe you check the mapcount on the page.
> 
> 
> Cheers,
> JA(C)rA'me
> 
> 
> 
> From 83abd3f16950a0b5cb6870a04d89d4fcc06b8865 Mon Sep 17 00:00:00 2001
> From: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>
> Date: Thu, 13 Sep 2018 10:16:30 -0400
> Subject: [PATCH] mm/mprotect: add a mkwrite paramater to change_protection()
> MIME-Version: 1.0
> Content-Type: text/plain; charset=UTF-8
> Content-Transfer-Encoding: 8bit
> 
> The mkwrite parameter allow to change read only pte to write one which
> is needed by userfaultfd to un-write-protect after a fault have been
> handled.
> 
> Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
> ---
>  include/linux/huge_mm.h  |  2 +-
>  include/linux/mm.h       |  3 +-
>  mm/huge_memory.c         | 32 +++++++++++++++++++--
>  mm/mempolicy.c           |  2 +-
>  mm/mprotect.c            | 61 +++++++++++++++++++++++++++++-----------
>  mm/userfaultfd.c         |  2 +-
>  tools/lib/str_error_r.c  |  9 ++++--
>  tools/lib/subcmd/pager.c |  5 +++-
>  8 files changed, 90 insertions(+), 26 deletions(-)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index a8a126259bc4..b51ff7f8e65c 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -45,7 +45,7 @@ extern bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
>  			 pmd_t *old_pmd, pmd_t *new_pmd, bool *need_flush);
>  extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  			unsigned long addr, pgprot_t newprot,
> -			int prot_numa);
> +			int prot_numa, bool mkwrite);
>  int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>  			pmd_t *pmd, pfn_t pfn, bool write);
>  int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 5d5c7fd07dc0..2bbf3e33bf9e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1492,7 +1492,8 @@ extern unsigned long move_page_tables(struct vm_area_struct *vma,
>  		bool need_rmap_locks);
>  extern unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
>  			      unsigned long end, pgprot_t newprot,
> -			      int dirty_accountable, int prot_numa);
> +			      int dirty_accountable, int prot_numa,
> +			      bool mkwrite);
>  extern int mprotect_fixup(struct vm_area_struct *vma,
>  			  struct vm_area_struct **pprev, unsigned long start,
>  			  unsigned long end, unsigned long newflags);
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index abf621aba672..7b848b84d80c 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1842,12 +1842,13 @@ bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
>   *  - HPAGE_PMD_NR is protections changed and TLB flush necessary
>   */
>  int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> -		unsigned long addr, pgprot_t newprot, int prot_numa)
> +		unsigned long addr, pgprot_t newprot, int prot_numa,
> +		bool mkwrite)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	spinlock_t *ptl;
>  	pmd_t entry;
> -	bool preserve_write;
> +	bool preserve_write, do_mkwrite = false;
>  	int ret;
>  
>  	ptl = __pmd_trans_huge_lock(pmd, vma);
> @@ -1857,6 +1858,31 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	preserve_write = prot_numa && pmd_write(*pmd);
>  	ret = 1;
>  
> +	if (mkwrite && pmd_present(*pmd) && !pmd_write(*pmd)) {
> +		pmd_t orig_pmd = READ_ONCE(*pmd);
> +		struct page *page = pmd_page(orig_pmd);
> +
> +		VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
> +		/*
> +		 * We can only allow mkwrite if nobody else maps the huge page
> +		 * or it's part.
> +		 */
> +		if (!trylock_page(page)) {
> +			get_page(page);
> +			spin_unlock(ptl);
> +			lock_page(page);
> +
> +			ptl = __pmd_trans_huge_lock(pmd, vma);
> +			if (!ptl)
> +				return 0;
> +		}
> +		if (pmd_same(*pmd, orig_pmd) && reuse_swap_page(page, NULL)) {
> +			do_mkwrite = true;
> +		}
> +		unlock_page(page);
> +		put_page(page);
> +	}
> +
>  #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
>  	if (is_swap_pmd(*pmd)) {
>  		swp_entry_t entry = pmd_to_swp_entry(*pmd);
> @@ -1925,6 +1951,8 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  	entry = pmd_modify(entry, newprot);
>  	if (preserve_write)
>  		entry = pmd_mk_savedwrite(entry);
> +	if (do_mkwrite)
> +		entry = pmd_mkwrite(entry);
>  	ret = HPAGE_PMD_NR;
>  	set_pmd_at(mm, addr, pmd, entry);
>  	BUG_ON(vma_is_anonymous(vma) && !preserve_write && pmd_write(entry));
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 4ce44d3ff03d..2d0ee09e6b26 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -579,7 +579,7 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
>  {
>  	int nr_updated;
>  
> -	nr_updated = change_protection(vma, addr, end, PAGE_NONE, 0, 1);
> +	nr_updated = change_protection(vma, addr, end, PAGE_NONE, 0, 1, false);
>  	if (nr_updated)
>  		count_vm_numa_events(NUMA_PTE_UPDATES, nr_updated);
>  
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 58b629bb70de..2d0c7e39f075 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -36,7 +36,7 @@
>  
>  static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  		unsigned long addr, unsigned long end, pgprot_t newprot,
> -		int dirty_accountable, int prot_numa)
> +		int dirty_accountable, int prot_numa, bool mkwrite)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	pte_t *pte, oldpte;
> @@ -72,13 +72,15 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  		if (pte_present(oldpte)) {
>  			pte_t ptent;
>  			bool preserve_write = prot_numa && pte_write(oldpte);
> +			bool do_mkwrite = false;
>  
>  			/*
>  			 * Avoid trapping faults against the zero or KSM
>  			 * pages. See similar comment in change_huge_pmd.
>  			 */
> -			if (prot_numa) {
> +			if (prot_numa || mkwrite) {
>  				struct page *page;
> +				int tmp;
>  
>  				page = vm_normal_page(vma, addr, oldpte);
>  				if (!page || PageKsm(page))
> @@ -94,6 +96,26 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  				 */
>  				if (target_node == page_to_nid(page))
>  					continue;
> +
> +				if (mkwrite) {
> +					if (!trylock_page(page)) {
> +						pte_t orig_pte = READ_ONCE(*pte);
> +						get_page(page);
> +						pte_unmap_unlock(pte, ptl);
> +						lock_page(page);
> +						pte = pte_offset_map_lock(vma->vm_mm, pmd,
> +									  addr, &ptl);
> +						if (!pte_same(*pte, orig_pte)) {
> +							unlock_page(page);
> +							put_page(page);
> +							continue;
> +						}
> +					}
> +					if (reuse_swap_page(page, &tmp))
> +						do_mkwrite = true;
> +					unlock_page(page);
> +					put_page(page);
> +				}
>  			}
>  
>  			ptent = ptep_modify_prot_start(mm, addr, pte);
> @@ -102,9 +124,9 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  				ptent = pte_mk_savedwrite(ptent);
>  
>  			/* Avoid taking write faults for known dirty pages */
> -			if (dirty_accountable && pte_dirty(ptent) &&
> -					(pte_soft_dirty(ptent) ||
> -					 !(vma->vm_flags & VM_SOFTDIRTY))) {
> +			if (do_mkwrite || (dirty_accountable &&
> +			    pte_dirty(ptent) && (pte_soft_dirty(ptent) ||
> +			    !(vma->vm_flags & VM_SOFTDIRTY)))) {
>  				ptent = pte_mkwrite(ptent);
>  			}
>  			ptep_modify_prot_commit(mm, addr, pte, ptent);
> @@ -150,7 +172,8 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>  
>  static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  		pud_t *pud, unsigned long addr, unsigned long end,
> -		pgprot_t newprot, int dirty_accountable, int prot_numa)
> +		pgprot_t newprot, int dirty_accountable, int prot_numa,
> +		bool mkwrite)
>  {
>  	pmd_t *pmd;
>  	struct mm_struct *mm = vma->vm_mm;
> @@ -179,7 +202,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  				__split_huge_pmd(vma, pmd, addr, false, NULL);
>  			} else {
>  				int nr_ptes = change_huge_pmd(vma, pmd, addr,
> -						newprot, prot_numa);
> +						newprot, prot_numa, mkwrite);
>  
>  				if (nr_ptes) {
>  					if (nr_ptes == HPAGE_PMD_NR) {
> @@ -194,7 +217,7 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  			/* fall through, the trans huge pmd just split */
>  		}
>  		this_pages = change_pte_range(vma, pmd, addr, next, newprot,
> -				 dirty_accountable, prot_numa);
> +				 dirty_accountable, prot_numa, mkwrite);
>  		pages += this_pages;
>  next:
>  		cond_resched();
> @@ -210,7 +233,8 @@ static inline unsigned long change_pmd_range(struct vm_area_struct *vma,
>  
>  static inline unsigned long change_pud_range(struct vm_area_struct *vma,
>  		p4d_t *p4d, unsigned long addr, unsigned long end,
> -		pgprot_t newprot, int dirty_accountable, int prot_numa)
> +		pgprot_t newprot, int dirty_accountable, int prot_numa,
> +		bool mkwrite)
>  {
>  	pud_t *pud;
>  	unsigned long next;
> @@ -222,7 +246,7 @@ static inline unsigned long change_pud_range(struct vm_area_struct *vma,
>  		if (pud_none_or_clear_bad(pud))
>  			continue;
>  		pages += change_pmd_range(vma, pud, addr, next, newprot,
> -				 dirty_accountable, prot_numa);
> +				 dirty_accountable, prot_numa, mkwrite);
>  	} while (pud++, addr = next, addr != end);
>  
>  	return pages;
> @@ -230,7 +254,8 @@ static inline unsigned long change_pud_range(struct vm_area_struct *vma,
>  
>  static inline unsigned long change_p4d_range(struct vm_area_struct *vma,
>  		pgd_t *pgd, unsigned long addr, unsigned long end,
> -		pgprot_t newprot, int dirty_accountable, int prot_numa)
> +		pgprot_t newprot, int dirty_accountable, int prot_numa,
> +		bool mkwrite)
>  {
>  	p4d_t *p4d;
>  	unsigned long next;
> @@ -242,7 +267,7 @@ static inline unsigned long change_p4d_range(struct vm_area_struct *vma,
>  		if (p4d_none_or_clear_bad(p4d))
>  			continue;
>  		pages += change_pud_range(vma, p4d, addr, next, newprot,
> -				 dirty_accountable, prot_numa);
> +				 dirty_accountable, prot_numa, mkwrite);
>  	} while (p4d++, addr = next, addr != end);
>  
>  	return pages;
> @@ -250,7 +275,7 @@ static inline unsigned long change_p4d_range(struct vm_area_struct *vma,
>  
>  static unsigned long change_protection_range(struct vm_area_struct *vma,
>  		unsigned long addr, unsigned long end, pgprot_t newprot,
> -		int dirty_accountable, int prot_numa)
> +		int dirty_accountable, int prot_numa, bool mkwrite)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	pgd_t *pgd;
> @@ -267,7 +292,7 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
>  		if (pgd_none_or_clear_bad(pgd))
>  			continue;
>  		pages += change_p4d_range(vma, pgd, addr, next, newprot,
> -				 dirty_accountable, prot_numa);
> +				 dirty_accountable, prot_numa, mkwrite);
>  	} while (pgd++, addr = next, addr != end);
>  
>  	/* Only flush the TLB if we actually modified any entries: */
> @@ -280,14 +305,16 @@ static unsigned long change_protection_range(struct vm_area_struct *vma,
>  
>  unsigned long change_protection(struct vm_area_struct *vma, unsigned long start,
>  		       unsigned long end, pgprot_t newprot,
> -		       int dirty_accountable, int prot_numa)
> +		       int dirty_accountable, int prot_numa, bool mkwrite)
>  {
>  	unsigned long pages;
>  
>  	if (is_vm_hugetlb_page(vma))
>  		pages = hugetlb_change_protection(vma, start, end, newprot);
>  	else
> -		pages = change_protection_range(vma, start, end, newprot, dirty_accountable, prot_numa);
> +		pages = change_protection_range(vma, start, end, newprot,
> +						dirty_accountable,
> +						prot_numa, mkwrite);
>  
>  	return pages;
>  }
> @@ -366,7 +393,7 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
>  	vma_set_page_prot(vma);
>  
>  	change_protection(vma, start, end, vma->vm_page_prot,
> -			  dirty_accountable, 0);
> +			  dirty_accountable, 0, false);
>  
>  	/*
>  	 * Private VM_LOCKED VMA becoming writable: trigger COW to avoid major
> diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> index a0379c5ffa7c..c745c5d87523 100644
> --- a/mm/userfaultfd.c
> +++ b/mm/userfaultfd.c
> @@ -632,7 +632,7 @@ int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
>  		newprot = vm_get_page_prot(dst_vma->vm_flags);
>  
>  	change_protection(dst_vma, start, start + len, newprot,
> -				!enable_wp, 0);
> +			  0, 0, !enable_wp);
>  
>  	err = 0;
>  out_unlock:
> diff --git a/tools/lib/str_error_r.c b/tools/lib/str_error_r.c
> index d6d65537b0d9..11c3425f272b 100644
> --- a/tools/lib/str_error_r.c
> +++ b/tools/lib/str_error_r.c
> @@ -21,7 +21,12 @@
>  char *str_error_r(int errnum, char *buf, size_t buflen)
>  {
>  	int err = strerror_r(errnum, buf, buflen);
> -	if (err)
> -		snprintf(buf, buflen, "INTERNAL ERROR: strerror_r(%d, %p, %zd)=%d", errnum, buf, buflen, err);
> +	if (err) {
> +		char *err_buf = buf;
> +
> +		snprintf(err_buf, buflen,
> +			 "INTERNAL ERROR: strerror_r(%d, %p, %zd)=%d",
> +			 errnum, buf, buflen, err);
> +	}
>  	return buf;
>  }
> diff --git a/tools/lib/subcmd/pager.c b/tools/lib/subcmd/pager.c
> index 5ba754d17952..e1895568edaf 100644
> --- a/tools/lib/subcmd/pager.c
> +++ b/tools/lib/subcmd/pager.c
> @@ -25,6 +25,8 @@ void pager_init(const char *pager_env)
>  
>  static void pager_preexec(void)
>  {
> +	void *ptr;
> +
>  	/*
>  	 * Work around bug in "less" by not starting it until we
>  	 * have real input
> @@ -33,7 +35,8 @@ static void pager_preexec(void)
>  
>  	FD_ZERO(&in);
>  	FD_SET(0, &in);
> -	select(1, &in, NULL, &in, NULL);
> +	ptr = &in;
> +	select(1, &in, NULL, ptr, NULL);
>  
>  	setenv("LESS", "FRSX", 0);
>  }
> -- 
> 2.17.1
> 

Hello, Jerome,

Sorry for a very late response.  Actually I tried this patch many days
ago but it hanged my remote host when I started my uffd-wp userspace
test program (what I got was a ssh connection there)... so I found
another day to reach the system and reboot it. It's reproducable 100%.

I wanted to capture some panic trace or things alike for you but I
failed to do so.  I tried to install software watchdog plus kdump
services (so that when panic happened kdump will capture more
information) but unluckily the hang I encountered didn't really
trigger either of them (so not only kdump is not triggered and also
the software watchdog is not failing).  It just seems like a pure hang
without panic, though the system is totally not responding so I cannot
collect anything.

Let me know if you have any idea on how to debug this scenario.

(Btw, I'm not sure whether we'll need those reuse_swap_page() that you
 added - AFAIU currently Andrea's uffd-wp tree does not support shmem,
 so will any of the write protected page be shared by more than one
 PTE?)

Regards,

-- 
Peter Xu
