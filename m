Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 630726B71F1
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 03:30:56 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id q26-v6so7037945qtj.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 00:30:56 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id v8-v6si809811qtp.169.2018.09.05.00.30.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 00:30:55 -0700 (PDT)
Date: Wed, 5 Sep 2018 15:30:37 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH] mm: hugepage: mark splitted page dirty when needed
Message-ID: <20180905073037.GA23021@xz-x1>
References: <20180904075510.22338-1-peterx@redhat.com>
 <20180904080115.o2zj4mlo7yzjdqfl@kshutemo-mobl1>
 <D3B32B41-61D5-47B3-B1FC-77B0F71ADA47@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <D3B32B41-61D5-47B3-B1FC-77B0F71ADA47@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org

On Tue, Sep 04, 2018 at 10:00:28AM -0400, Zi Yan wrote:
> On 4 Sep 2018, at 4:01, Kirill A. Shutemov wrote:
> 
> > On Tue, Sep 04, 2018 at 03:55:10PM +0800, Peter Xu wrote:
> >> When splitting a huge page, we should set all small pages as dirty if
> >> the original huge page has the dirty bit set before.  Otherwise we'll
> >> lose the original dirty bit.
> >
> > We don't lose it. It got transfered to struct page flag:
> >
> > 	if (pmd_dirty(old_pmd))
> > 		SetPageDirty(page);
> >
> 
> Plus, when split_huge_page_to_list() splits a THP, its subroutine __split_huge_page()
> propagates the dirty bit in the head page flag to all subpages in __split_huge_page_tail().

Hi, Kirill, Zi,

Thanks for your responses!

Though in my test the huge page seems to be splitted not by
split_huge_page_to_list() but by explicit calls to
change_protection().  The stack looks like this (again, this is a
customized kernel, and I added an explicit dump_stack() there):

  kernel:  dump_stack+0x5c/0x7b
  kernel:  __split_huge_pmd+0x192/0xdc0
  kernel:  ? update_load_avg+0x8b/0x550
  kernel:  ? update_load_avg+0x8b/0x550
  kernel:  ? account_entity_enqueue+0xc5/0xf0
  kernel:  ? enqueue_entity+0x112/0x650
  kernel:  change_protection+0x3a2/0xab0
  kernel:  mwriteprotect_range+0xdd/0x110
  kernel:  userfaultfd_ioctl+0x50b/0x1210
  kernel:  ? do_futex+0x2cf/0xb20
  kernel:  ? tty_write+0x1d2/0x2f0
  kernel:  ? do_vfs_ioctl+0x9f/0x610
  kernel:  do_vfs_ioctl+0x9f/0x610
  kernel:  ? __x64_sys_futex+0x88/0x180
  kernel:  ksys_ioctl+0x70/0x80
  kernel:  __x64_sys_ioctl+0x16/0x20
  kernel:  do_syscall_64+0x55/0x150
  kernel:  entry_SYSCALL_64_after_hwframe+0x44/0xa9

At the very time the userspace is sending an UFFDIO_WRITEPROTECT ioctl
to kernel space, which is handled by mwriteprotect_range().  In case
you'd like to refer to the kernel, it's basically this one from
Andrea's (with very trivial changes):

  https://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git userfault

So... do we have two paths to split the huge pages separately?

Another (possibly very naive) question is: could any of you hint me
how the page dirty bit is finally applied to the PTEs?  These two
dirty flags confused me for a few days already (the SetPageDirty() one
which sets the page dirty flag, and the pte_mkdirty() which sets that
onto the real PTEs).

Regards,

-- 
Peter Xu
