Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id EEE0F8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 00:07:47 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c22-v6so16436410qkb.18
        for <linux-mm@kvack.org>; Sun, 09 Sep 2018 21:07:47 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id e2-v6si1271019qtd.359.2018.09.09.21.07.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Sep 2018 21:07:46 -0700 (PDT)
Date: Mon, 10 Sep 2018 12:07:32 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH] mm: hugepage: mark splitted page dirty when needed
Message-ID: <20180910040732.GN16937@xz-x1>
References: <20180904075510.22338-1-peterx@redhat.com>
 <20180904080115.o2zj4mlo7yzjdqfl@kshutemo-mobl1>
 <D3B32B41-61D5-47B3-B1FC-77B0F71ADA47@cs.rutgers.edu>
 <20180905073037.GA23021@xz-x1>
 <20180905125522.x2puwfn5sr2zo3go@kshutemo-mobl1>
 <20180906113933.GG16937@xz-x1>
 <20180906140842.jzf7tluzocb5nv3f@kshutemo-mobl1>
 <20180907043524.GM16937@xz-x1>
 <20180907175434.GB3519@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20180907175434.GB3519@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org

On Fri, Sep 07, 2018 at 01:54:35PM -0400, Jerome Glisse wrote:
> On Fri, Sep 07, 2018 at 12:35:24PM +0800, Peter Xu wrote:
> > On Thu, Sep 06, 2018 at 05:08:42PM +0300, Kirill A. Shutemov wrote:
> > > On Thu, Sep 06, 2018 at 07:39:33PM +0800, Peter Xu wrote:
> > > > On Wed, Sep 05, 2018 at 03:55:22PM +0300, Kirill A. Shutemov wrote:
> > > > > On Wed, Sep 05, 2018 at 03:30:37PM +0800, Peter Xu wrote:
> > > > > > On Tue, Sep 04, 2018 at 10:00:28AM -0400, Zi Yan wrote:
> > > > > > > On 4 Sep 2018, at 4:01, Kirill A. Shutemov wrote:
> > > > > > > 
> > > > > > > > On Tue, Sep 04, 2018 at 03:55:10PM +0800, Peter Xu wrote:
> > > > > > > >> When splitting a huge page, we should set all small pages as dirty if
> > > > > > > >> the original huge page has the dirty bit set before.  Otherwise we'll
> > > > > > > >> lose the original dirty bit.
> > > > > > > >
> > > > > > > > We don't lose it. It got transfered to struct page flag:
> > > > > > > >
> > > > > > > > 	if (pmd_dirty(old_pmd))
> > > > > > > > 		SetPageDirty(page);
> > > > > > > >
> > > > > > > 
> > > > > > > Plus, when split_huge_page_to_list() splits a THP, its subroutine __split_huge_page()
> > > > > > > propagates the dirty bit in the head page flag to all subpages in __split_huge_page_tail().
> > > > > > 
> > > > > > Hi, Kirill, Zi,
> > > > > > 
> > > > > > Thanks for your responses!
> > > > > > 
> > > > > > Though in my test the huge page seems to be splitted not by
> > > > > > split_huge_page_to_list() but by explicit calls to
> > > > > > change_protection().  The stack looks like this (again, this is a
> > > > > > customized kernel, and I added an explicit dump_stack() there):
> > > > > > 
> > > > > >   kernel:  dump_stack+0x5c/0x7b
> > > > > >   kernel:  __split_huge_pmd+0x192/0xdc0
> > > > > >   kernel:  ? update_load_avg+0x8b/0x550
> > > > > >   kernel:  ? update_load_avg+0x8b/0x550
> > > > > >   kernel:  ? account_entity_enqueue+0xc5/0xf0
> > > > > >   kernel:  ? enqueue_entity+0x112/0x650
> > > > > >   kernel:  change_protection+0x3a2/0xab0
> > > > > >   kernel:  mwriteprotect_range+0xdd/0x110
> > > > > >   kernel:  userfaultfd_ioctl+0x50b/0x1210
> > > > > >   kernel:  ? do_futex+0x2cf/0xb20
> > > > > >   kernel:  ? tty_write+0x1d2/0x2f0
> > > > > >   kernel:  ? do_vfs_ioctl+0x9f/0x610
> > > > > >   kernel:  do_vfs_ioctl+0x9f/0x610
> > > > > >   kernel:  ? __x64_sys_futex+0x88/0x180
> > > > > >   kernel:  ksys_ioctl+0x70/0x80
> > > > > >   kernel:  __x64_sys_ioctl+0x16/0x20
> > > > > >   kernel:  do_syscall_64+0x55/0x150
> > > > > >   kernel:  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> > > > > > 
> > > > > > At the very time the userspace is sending an UFFDIO_WRITEPROTECT ioctl
> > > > > > to kernel space, which is handled by mwriteprotect_range().  In case
> > > > > > you'd like to refer to the kernel, it's basically this one from
> > > > > > Andrea's (with very trivial changes):
> > > > > > 
> > > > > >   https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git userfault
> > > > > > 
> > > > > > So... do we have two paths to split the huge pages separately?
> > > > > 
> > > > > We have two entiries that can be split: page table enties and underlying
> > > > > compound page.
> > > > > 
> > > > > split_huge_pmd() (and variants of it) split the PMD entry into a PTE page
> > > > > table. It doens't touch underlying compound page. The page still can be
> > > > > mapped in other place as huge.
> > > > > 
> > > > > split_huge_page() (and ivariants of it) split compound page into a number
> > > > > of 4k (or whatever PAGE_SIZE is). The operation requires splitting all
> > > > > PMD, but not other way around.
> > > > > 
> > > > > > 
> > > > > > Another (possibly very naive) question is: could any of you hint me
> > > > > > how the page dirty bit is finally applied to the PTEs?  These two
> > > > > > dirty flags confused me for a few days already (the SetPageDirty() one
> > > > > > which sets the page dirty flag, and the pte_mkdirty() which sets that
> > > > > > onto the real PTEs).
> > > > > 
> > > > > Dirty bit from page table entries transferes to sturct page flug and used
> > > > > for decision making in reclaim path.
> > > > 
> > > > Thanks for explaining.  It's much clearer for me.
> > > > 
> > > > Though for the issue I have encountered, I am still confused on why
> > > > that dirty bit can be ignored for the splitted PTEs.  Indeed we have:
> > > > 
> > > > 	if (pmd_dirty(old_pmd))
> > > > 		SetPageDirty(page);
> > > > 
> > > > However to me this only transfers (as you explained above) the dirty
> > > > bit (AFAIU it's possibly set by the hardware when the page is written)
> > > > to the page struct of the compound page.  It did not really apply to
> > > > every small page of the splitted huge page.  As you also explained,
> > > > this __split_huge_pmd() only splits the PMD entry but it keeps the
> > > > compound huge page there, then IMHO it should also apply the dirty
> > > > bits from the huge page to all the small page entries, no?
> > > 
> > > The bit on compound page represents all small subpages. PageDirty() on any
> > > subpage will return you true if the compound page is dirty.
> > 
> > Ah I didn't notice this before (since PageDirty is defined with
> > PF_HEAD), thanks for pointing out.
> > 
> > > 
> > > > These dirty bits are really important to my scenario since AFAIU the
> > > > change_protection() call is using these dirty bits to decide whether
> > > > it should append the WRITE bit - it finally corresponds to the lines
> > > > in change_pte_range():
> > > > 
> > > >         /* Avoid taking write faults for known dirty pages */
> > > >         if (dirty_accountable && pte_dirty(ptent) &&
> > > >                         (pte_soft_dirty(ptent) ||
> > > >                                 !(vma->vm_flags & VM_SOFTDIRTY))) {
> > > >                 ptent = pte_mkwrite(ptent);
> > > >         }
> > > > 
> > > > So when mprotect() with that range (my case is UFFDIO_WRITEPROTECT,
> > > > which is similar) although we pass in the new protocol with VM_WRITE
> > > > here it'll still mask it since the dirty bit is not set, then the
> > > > userspace program (in my case, the QEMU thread that handles write
> > > > protect failures) can never fixup the write-protected page fault.
> > > 
> > > I don't follow here.
> > > 
> > > The code you quoting above is an apportunistic optimization and should not
> > > be mission-critical. The dirty and writable bits can go away as soon as
> > > you drop page table lock for the page.
> > 
> > Indeed it's an optimization, IIUC it tries to avoid an extra but
> > possibly useless write-protect page fault when the dirty bits are
> > already set after all.  However that's a bit trickly here - in my use
> > case the write-protect page faults will be handled by one of the QEMU
> > thread that reads the userfaultfd handle, so the fault must be handled
> > there instead of inside kernel otherwise there'll be nested page
> > faults forever (and userfaultfd will detect that then send a SIGBUS
> > instead).
> > 
> > I'll try to explain with some more details on how I understand what
> > happened.  This should also answer Zi's question so I'll avoid
> > replying twice there.  Please feel free to correct me.
> > 
> > Firstly, below should be the correct steps to handle a userspace write
> > protect page fault using Andrea's userfault-wp tree (I only mentioned
> > the page fault steps and ignored most of the irrelevant setup
> > procedures):
> > 
> > 1. QEMU write-protects page P using UFFDIO_WRITEPROTECT ioctl, then
> >    the write bit removed from PTE, so QEMU can capture any further
> >    writes to the page
> > 
> >    ... (time passes)...
> 
> UFFDIO_WRITEPROTECT with UFFDIO_WRITEPROTECT_MODE_WP
> 
> > 
> > 2. [vCPU thread] Guest writes to the page P, trigger wp page fault
> > 
> > 3. [vCPU thread] Since the page (and the whole vma) is tracked by
> >    userfault-wp, it goes into handle_userfault() to notify userspace
> >    about the page fault and waits...
> > 
> > 4. [userfault thread] Gets the message about the page fault, do
> >    anything it like with the page P (mostly copy it somewhere), and
> >    fixup the page fault by another UFFDIO_WRITEPROTECT ioctl, this
> >    time to reset the write bit.  After that, it'll wake up the vCPU
> >    thread
> 
> UFFDIO_WRITEPROTECT with !UFFDIO_WRITEPROTECT_MODE_WP
> 
> It confused me when looking at code:
> https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git/commit/?id=aa97daa6e54f2cfed1a6f1f38f9629608b8aadcc
> 
> > 
> > 5. [vCPU thread] Got waked up, retry the page fault by returning a
> >    VM_FAULT_RETRY in handle_userfault().  Then this time we'll see the
> >    PTE with write bit set correctly.  vCPU continues execution.
> > 
> > Then let's consider THP here, where we might miss the dirty page for
> > the PTE of the small page P.  In that case at step (4) when we want to
> > recover the write bit we'll fail since the dirty bit is missing in the
> > small PTE, so the write bit will still be cleared (expecting that the
> > next page fault will fill it up).  However in step (5) we can't really
> > fill in the write bit since we'll fault again into the
> > handle_userfault() before that happens and then it goes back to step
> > (3) then it can actualy loop forever if without the loop detection
> > code in handle_userfault().
> > 
> > So I think now I understand that setting up the dirty bit in the
> > compound page should be enough, then would below change acceptable
> > instead?
> > 
> > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > index 6d331620b9e5..0d4a8129a5e7 100644
> > --- a/mm/mprotect.c
> > +++ b/mm/mprotect.c
> > @@ -73,6 +73,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,                                                                             
> >                 if (pte_present(oldpte)) {
> >                         pte_t ptent;
> >                         bool preserve_write = prot_numa && pte_write(oldpte);
> > +                       bool dirty;
> > 
> >                         /*
> >                          * Avoid trapping faults against the zero or KSM
> > @@ -115,8 +116,18 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,                                                                          
> >                         if (preserve_write)
> >                                 ptent = pte_mk_savedwrite(ptent);
> > 
> > +                       /*
> > +                        * The extra PageDirty() check will make sure
> > +                        * we'll capture the dirty page even if the
> > +                        * PTE dirty bit unset.  One case is when the
> > +                        * PTE is splitted from a huge PMD, in that
> > +                        * case the dirty flag might only be set on
> > +                        * the compound page instead of this PTE.
> > +                        */
> > +                       dirty = pte_dirty(ptent) || PageDirty(pte_page(ptent));
> > +
> >                         /* Avoid taking write faults for known dirty pages */
> > -                       if (dirty_accountable && pte_dirty(ptent) &&
> > +                       if (dirty_accountable && dirty &&
> >                                         (pte_soft_dirty(ptent) ||
> >                                          !(vma->vm_flags & VM_SOFTDIRTY))) {
> >                                 ptent = pte_mkwrite(ptent);
> > 
> > I tested that this change can also fix my problem (QEMU will not get
> > SIGBUS after write protection starts).
> 
> This is wrong mwriteprotect_range() should already properly set pte
> entry to non write protect:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git/commit/?id=b16cb9fcb76bec59cbe1427e73246dc81a4942e2
> 
> 	if (enable_wp)
> 		newprot = vm_get_page_prot(dst_vma->vm_flags & ~(VM_WRITE));
> 	else
> 		newprot = vm_get_page_prot(dst_vma->vm_flags);
> 
> So it seems that the vm_flags do not have VM_WRITE set.

Hi, Jerome,

I think the vma has correct VM_WRITE flag there.  I added some prints
into mwriteprotect_range() to trap more information when coredump
happens:

diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index d3d0a13a636f..ebdcd76887df 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -606,6 +606,7 @@ int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
        struct vm_area_struct *dst_vma;
        pgprot_t newprot;
        int err;
+       unsigned long pages;
 
        /*
         * Sanitize the command parameters:
@@ -638,13 +639,17 @@ int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
        if (!vma_is_anonymous(dst_vma))
                goto out_unlock;
 
+       pr_info("%s: vm_flags: 0x%lx\n", __func__, dst_vma->vm_flags);
+
        if (enable_wp)
                newprot = vm_get_page_prot(dst_vma->vm_flags & ~(VM_WRITE));
        else
                newprot = vm_get_page_prot(dst_vma->vm_flags);
 
-       change_protection(dst_vma, start, start + len, newprot,
-                               !enable_wp, 0);
+       pages = change_protection(dst_vma, start, start + len, newprot,
+                                 !enable_wp, 0);
+       pr_info("%s: 0x%lx-0x%lx changed %ld pages (newprot=%lx, wp=%d)\n",
+               __func__, start, start + len, pages, newprot.pgprot, enable_wp);
 
        err = 0;
 out_unlock:

Here's what I got starting from when QEMU starts until QEMU coredumps:

Sep 10 11:40:24 px-ws kernel: mwriteprotect_range: vm_flags: 0xa0121073
Sep 10 11:40:24 px-ws kernel: mwriteprotect_range: 0x7f205fe00000-0x7f209fe00000 changed 1024 pages (newprot=8000000000000025, wp=1)                                        
Sep 10 11:40:24 px-ws kernel: mwriteprotect_range: vm_flags: 0xa0121073
Sep 10 11:40:24 px-ws kernel: mwriteprotect_range: 0x7f20aa000000-0x7f20ab000000 changed 512 pages (newprot=8000000000000025, wp=1)                                         
Sep 10 11:40:24 px-ws kernel: mwriteprotect_range: vm_flags: 0xa0121073   <----------------------------------- [1]
Sep 10 11:40:24 px-ws kernel: mwriteprotect_range: 0x7f205fe7f000-0x7f205fe80000 changed 1 pages (newprot=8000000000000025, wp=0)                                           
Sep 10 11:40:24 px-ws kernel: FAULT_FLAG_ALLOW_RETRY missing 71
Sep 10 11:40:24 px-ws kernel: CPU: 7 PID: 1637 Comm: qemu-system-x86 Not tainted 4.19.0-rc2+ #27                                                                            
Sep 10 11:40:24 px-ws kernel: Hardware name: LENOVO ThinkCentre M8500t-N000/SHARKBAY, BIOS FBKTC6AUS 06/22/2016                                                             
Sep 10 11:40:24 px-ws kernel: Call Trace:
Sep 10 11:40:24 px-ws kernel:  dump_stack+0x5c/0x7b
Sep 10 11:40:24 px-ws kernel:  handle_userfault+0x4b5/0x780
Sep 10 11:40:24 px-ws kernel:  ? schedule+0x32/0x80
Sep 10 11:40:24 px-ws kernel:  ? handle_userfault+0x47e/0x780
Sep 10 11:40:24 px-ws kernel:  do_wp_page+0x1bd/0x5a0
Sep 10 11:40:24 px-ws kernel:  __handle_mm_fault+0x7f9/0x1250
Sep 10 11:40:24 px-ws kernel:  handle_mm_fault+0xfc/0x1f0
Sep 10 11:40:24 px-ws kernel:  __do_page_fault+0x255/0x520
Sep 10 11:40:24 px-ws kernel:  do_page_fault+0x32/0x110
Sep 10 11:40:24 px-ws kernel:  ? page_fault+0x8/0x30
Sep 10 11:40:24 px-ws kernel:  page_fault+0x1e/0x30
Sep 10 11:40:24 px-ws kernel: RIP: 0033:0x7f20ac9108c9
Sep 10 11:40:24 px-ws kernel: Code: 75 03 c1 ef 07 48 81 e6 00 f0 ff ff 81 e7 e0 1f 00 00 49 8d bc 3e 40 57 00 00 48 3b 37 48 8b f5 0f 85 32 00 00 00 48 03 77 10 <89> 1e 49f
Sep 10 11:40:24 px-ws kernel: RSP: 002b:00007f20abdda390 EFLAGS: 00010202
Sep 10 11:40:24 px-ws kernel: RAX: 00007f20ac915b80 RBX: 000000003fec3baa RCX: 0000000000007318                                                                             
Sep 10 11:40:24 px-ws kernel: RDX: 0000000000000000 RSI: 00007f205fe7fed0 RDI: 000055cc4efef980                                                                             
Sep 10 11:40:24 px-ws kernel: RBP: 000000000007fed0 R08: 0000000000000000 R09: 0000000000000007                                                                             
Sep 10 11:40:24 px-ws kernel: R10: 0000000000000030 R11: 0000000000000000 R12: 0000000000000242                                                                             
Sep 10 11:40:24 px-ws kernel: R13: 0000000000000000 R14: 000055cc4efe9260 R15: 00007f20abddb700                                                                             

The first four lines of mwriteprotect_range() are trying to set things
up (they have wp=1) which seems fine.  Note that lines 5-6 of
mwriteprotect_range() entry (marked with [1]) is the wp=0 one where
QEMU tries to recover a write protect page fault for a 4K page.  We
can see that the vm_flags has VM_WRITE properly set (bit 2 of
0xa0121073) rather than missing.

Though we can see the newprot didn't really have that VM_WRITE set but
it's expected since in vm_get_page_prot (further, which is actually
protection_map) we'll drop that write bit due to the protect mapping
(READ+WRITE will map to PAGE_COPY, which does not have VM_WRITE set).

> 
> To me this all points out so a bug somewhere in userspace or a miss use
> of userfaultfd. Here is what i believe to be the chain of event:
> 
>   1 QEMU or vCPU write to the affected ufaultfd range and this set the pte
>     dirty bit on all the entry in the affected range
> 
>   ...
> 
>   2 QEMU write protect the affected range with UFFDIO_WRITEPROTECT and
>     UFFDIO_WRITEPROTECT_MODE_WP flag set. This clear the pte write bit
>     and thus write protect the range. Because it is anonymous memory and
>     soft dirty is likely disabled, the dirty bit set in 1 is still there
>     and is preserved.
> 
>   3 vCPU tries to write to the affected range. This trigger a userfaultfd
>     and QEMU handle it and call UFFDIO_WRITEPROTECT but this time without
>     UFFDIO_WRITEPROTECT_MODE_WP flag (ie to unprotect).
> 
>     For some reasons the affected vma do not have the VM_WRITE flags set
>     anymore probably through mprotect() syscall by QEMU. So that the new
>     prot for the pte do not have the write bit set.

Please refers to [1] above.  The crash happens stably every time if
without my fix patch applied.

> 
>     But because of the change_pte_range() optimization and because the
>     pte dirty bit is set from 1 then the pte write bit set which is wrong
>     as the VM_WRITE have been clear.

I actually have dumped the dirty flag there too and it's missing, and
that's why I think we should have the bit.  It's indeed a bit awkward
at least to me since when running with the userfault-wp tree the dirty
bit optimization becomes more like a correctness issue rather than a
performance issue.

> 
> 
> So hence there is a bug in QEMU somewhere is my best guess.
> 
> Note that this means that the:
>   https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git/commit/?id=b16cb9fcb76bec59cbe1427e73246dc81a4942e2
> 
> Needs to be updated with:
> -change_protection(dst_vma, start, start + len, newprot, !enable_wp, 0);
> +change_protection(dst_vma, start, start + len, newprot, 0, 0);

I'm not sure about this suggestion as well - if we keep the
change_pte_range() with dirty_accountable=false, then how could we
further apply the WM_WRITE flag at all with current implementation
(note that with the dirty bit optimization, we'll just ignore the
VM_WRITE bit if dirty_accountable is false...)?  If without VM_WRITE,
how could we fix a write-protect page fault after all from userspace?

Please correct me if I missed anything important.

Thanks!

-- 
Peter Xu
