Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id BDDC46B78F9
	for <linux-mm@kvack.org>; Thu,  6 Sep 2018 10:17:17 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id w126-v6so7838997qka.11
        for <linux-mm@kvack.org>; Thu, 06 Sep 2018 07:17:17 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id y27-v6si427069qtc.394.2018.09.06.07.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Sep 2018 07:17:14 -0700 (PDT)
Date: Thu, 6 Sep 2018 10:17:09 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm: hugepage: mark splitted page dirty when needed
Message-ID: <20180906141708.GB3830@redhat.com>
References: <20180904075510.22338-1-peterx@redhat.com>
 <20180904080115.o2zj4mlo7yzjdqfl@kshutemo-mobl1>
 <D3B32B41-61D5-47B3-B1FC-77B0F71ADA47@cs.rutgers.edu>
 <20180905073037.GA23021@xz-x1>
 <20180905125522.x2puwfn5sr2zo3go@kshutemo-mobl1>
 <20180906113933.GG16937@xz-x1>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180906113933.GG16937@xz-x1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Xu <peterx@redhat.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Zi Yan <zi.yan@cs.rutgers.edu>, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org

On Thu, Sep 06, 2018 at 07:39:33PM +0800, Peter Xu wrote:
> On Wed, Sep 05, 2018 at 03:55:22PM +0300, Kirill A. Shutemov wrote:
> > On Wed, Sep 05, 2018 at 03:30:37PM +0800, Peter Xu wrote:
> > > On Tue, Sep 04, 2018 at 10:00:28AM -0400, Zi Yan wrote:
> > > > On 4 Sep 2018, at 4:01, Kirill A. Shutemov wrote:
> > > > 
> > > > > On Tue, Sep 04, 2018 at 03:55:10PM +0800, Peter Xu wrote:
> > > > >> When splitting a huge page, we should set all small pages as dirty if
> > > > >> the original huge page has the dirty bit set before.  Otherwise we'll
> > > > >> lose the original dirty bit.
> > > > >
> > > > > We don't lose it. It got transfered to struct page flag:
> > > > >
> > > > > 	if (pmd_dirty(old_pmd))
> > > > > 		SetPageDirty(page);
> > > > >
> > > > 
> > > > Plus, when split_huge_page_to_list() splits a THP, its subroutine __split_huge_page()
> > > > propagates the dirty bit in the head page flag to all subpages in __split_huge_page_tail().
> > > 
> > > Hi, Kirill, Zi,
> > > 
> > > Thanks for your responses!
> > > 
> > > Though in my test the huge page seems to be splitted not by
> > > split_huge_page_to_list() but by explicit calls to
> > > change_protection().  The stack looks like this (again, this is a
> > > customized kernel, and I added an explicit dump_stack() there):
> > > 
> > >   kernel:  dump_stack+0x5c/0x7b
> > >   kernel:  __split_huge_pmd+0x192/0xdc0
> > >   kernel:  ? update_load_avg+0x8b/0x550
> > >   kernel:  ? update_load_avg+0x8b/0x550
> > >   kernel:  ? account_entity_enqueue+0xc5/0xf0
> > >   kernel:  ? enqueue_entity+0x112/0x650
> > >   kernel:  change_protection+0x3a2/0xab0
> > >   kernel:  mwriteprotect_range+0xdd/0x110
> > >   kernel:  userfaultfd_ioctl+0x50b/0x1210
> > >   kernel:  ? do_futex+0x2cf/0xb20
> > >   kernel:  ? tty_write+0x1d2/0x2f0
> > >   kernel:  ? do_vfs_ioctl+0x9f/0x610
> > >   kernel:  do_vfs_ioctl+0x9f/0x610
> > >   kernel:  ? __x64_sys_futex+0x88/0x180
> > >   kernel:  ksys_ioctl+0x70/0x80
> > >   kernel:  __x64_sys_ioctl+0x16/0x20
> > >   kernel:  do_syscall_64+0x55/0x150
> > >   kernel:  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> > > 
> > > At the very time the userspace is sending an UFFDIO_WRITEPROTECT ioctl
> > > to kernel space, which is handled by mwriteprotect_range().  In case
> > > you'd like to refer to the kernel, it's basically this one from
> > > Andrea's (with very trivial changes):
> > > 
> > >   https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git userfault
> > > 
> > > So... do we have two paths to split the huge pages separately?
> > 
> > We have two entiries that can be split: page table enties and underlying
> > compound page.
> > 
> > split_huge_pmd() (and variants of it) split the PMD entry into a PTE page
> > table. It doens't touch underlying compound page. The page still can be
> > mapped in other place as huge.
> > 
> > split_huge_page() (and ivariants of it) split compound page into a number
> > of 4k (or whatever PAGE_SIZE is). The operation requires splitting all
> > PMD, but not other way around.
> > 
> > > 
> > > Another (possibly very naive) question is: could any of you hint me
> > > how the page dirty bit is finally applied to the PTEs?  These two
> > > dirty flags confused me for a few days already (the SetPageDirty() one
> > > which sets the page dirty flag, and the pte_mkdirty() which sets that
> > > onto the real PTEs).
> > 
> > Dirty bit from page table entries transferes to sturct page flug and used
> > for decision making in reclaim path.
> 
> Thanks for explaining.  It's much clearer for me.
> 
> Though for the issue I have encountered, I am still confused on why
> that dirty bit can be ignored for the splitted PTEs.  Indeed we have:
> 
> 	if (pmd_dirty(old_pmd))
> 		SetPageDirty(page);
> 
> However to me this only transfers (as you explained above) the dirty
> bit (AFAIU it's possibly set by the hardware when the page is written)
> to the page struct of the compound page.  It did not really apply to
> every small page of the splitted huge page.  As you also explained,
> this __split_huge_pmd() only splits the PMD entry but it keeps the
> compound huge page there, then IMHO it should also apply the dirty
> bits from the huge page to all the small page entries, no?
> 
> These dirty bits are really important to my scenario since AFAIU the
> change_protection() call is using these dirty bits to decide whether
> it should append the WRITE bit - it finally corresponds to the lines
> in change_pte_range():
> 
>         /* Avoid taking write faults for known dirty pages */
>         if (dirty_accountable && pte_dirty(ptent) &&
>                         (pte_soft_dirty(ptent) ||
>                                 !(vma->vm_flags & VM_SOFTDIRTY))) {
>                 ptent = pte_mkwrite(ptent);
>         }
> 
> So when mprotect() with that range (my case is UFFDIO_WRITEPROTECT,
> which is similar) although we pass in the new protocol with VM_WRITE
> here it'll still mask it since the dirty bit is not set, then the
> userspace program (in my case, the QEMU thread that handles write
> protect failures) can never fixup the write-protected page fault.
> 
> Am I missing anything important here?
> 

For reference mwriteprotect_range code:
https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git/commit/?id=b16cb9fcb76bec59cbe1427e73246dc81a4942e2

mwriteprotect_range usage:
https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git/commit/?id=aa97daa6e54f2cfed1a6f1f38f9629608b8aadcc

Maybe you can describe the issues you are having because i admit
not seing what is wrong here. When mwriteprotect_range is call
with UFFDIO_WRITEPROTECT_MODE_WP then dirty_accountable is false
and thus above if is not taken and pte is properly write protected
and thus UFFDIO_WRITEPROTECT_MODE_WP do what its name suggest no
matter what is the pte dirty state.

I am not sure what UFFDIO_WRITEPROTECT_MODE_DONTWAKE means as this
is the one that might depends on the pte dirty state. So without
knowing what UFFDIO_WRITEPROTECT_MODE_DONTWAKE do, i am not sure
i see any bug here.

Cheers,
Jerome
