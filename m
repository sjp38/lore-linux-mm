Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 171846B015E
	for <linux-mm@kvack.org>; Thu, 21 May 2015 09:09:45 -0400 (EDT)
Received: by wichy4 with SMTP id hy4so13331966wic.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 06:09:44 -0700 (PDT)
Received: from mail2.tiolive.com (mail2.tiolive.com. [94.23.229.207])
        by mx.google.com with ESMTP id ej3si3003025wib.116.2015.05.21.06.09.42
        for <linux-mm@kvack.org>;
        Thu, 21 May 2015 06:09:43 -0700 (PDT)
Date: Thu, 21 May 2015 16:11:11 +0300
From: Kirill Smelkov <kirr@nexedi.com>
Subject: Re: [PATCH 00/23] userfaultfd v4
Message-ID: <20150521131111.GA8932@teco.navytux.spb.ru>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

Hello up there,

On Thu, May 14, 2015 at 07:30:57PM +0200, Andrea Arcangeli wrote:
> Hello everyone,
> 
> This is the latest userfaultfd patchset against mm-v4.1-rc3
> 2015-05-14-10:04.
> 
> The postcopy live migration feature on the qemu side is mostly ready
> to be merged and it entirely depends on the userfaultfd syscall to be
> merged as well. So it'd be great if this patchset could be reviewed
> for merging in -mm.
> 
> Userfaults allow to implement on demand paging from userland and more
> generally they allow userland to more efficiently take control of the
> behavior of page faults than what was available before
> (PROT_NONE + SIGSEGV trap).
> 
> The use cases are:

[...]

> Even though there wasn't a real use case requesting it yet, it also
> allows to implement distributed shared memory in a way that readonly
> shared mappings can exist simultaneously in different hosts and they
> can be become exclusive at the first wrprotect fault.

Sorry for maybe speaking up too late, but here is additional real
potential use-case which in my view is overlapping with the above:

Recently we needed to implement persistency for NumPy arrays - that is
to track made changes to array memory and transactionally either abandon
the changes on transaction abort, or store them back to storage on
transaction commit.

Since arrays can be large, it would be slow and thus not practical to
have original data copy and compare memory to original to find what
array parts have been changed.

So I've implemented a scheme where array data is initially PROT_READ
protected, then we catch SIGSEGV, if it is write and area belongs to array
data - we mark that page as PROT_WRITE and continue. On commit time we
know which parts were modified.

Also, since arrays could be large - bigger than RAM, and only sparse
parts of it could be needed to get needed information, for reading it
also makes sense to lazily load data in SIGSEGV handler with initial
PROT_NONE protection.

This is very similar to how memory mapped files work, but adds
transactionality which, as far as I know, is not provided by any
currently in-kernel filesystem on Linux.

The system is done as files, and arrays are then build on top of
this-way memory-mapped files. So from now on we can forget about NumPy
arrays and only talk about files, their mapping, lazy loading and
transactionally storing in-memory changes back to file storage.

To get this working, a custom user-space virtual memory manager is
unrolled, which manages RAM memory "pages", file mappings into virtual
address-space, tracks pages protection and does SIGSEGV handling
appropriately.


The gist of virtual memory-manager is this:

    https://lab.nexedi.cn/kirr/wendelin.core/blob/master/include/wendelin/bigfile/virtmem.h
    https://lab.nexedi.cn/kirr/wendelin.core/blob/master/bigfile/virtmem.c  (vma_on_pagefault)


For operations it currently needs

    - establishing virtual memory areas and connecting to tracking it

    - changing pages protection

        PROT_NONE or absent                             - initially
        PROT_NONE       -> PROT_READ                    - after read
        PROT_READ       -> PROT_READWRITE               - after write
        PROT_READWRITE  -> PROT_READ                    - after commit
        PROT_READWRITE  -> PROT_NONE or absent (again)  - after abort
        PROT_READ       -> PROT_NONE or absent (again)  - on reclaim

    - working with aliasable memory (thus taken from tmpfs)

        there could be two overlapping-in-file mapping for file (array)
        requested at different time, and changes from one mapping should
        propagate to another one -> for common parts only 1 page should
        be memory-mapped into 2 places in address-space.

so what is currently lacking on userfaultfd side is:

    - ability to remove / make PROT_NONE already mapped pages
      (UFFDIO_REMAP was recently dropped)

    - ability to arbitrarily change pages protection (e.g. RW -> R)

    - inject aliasable memory from tmpfs (or better hugetlbfs) and into
      several places (UFFDIO_REMAP + some mapping copy semantic).


The code is ugly because it is only a prototype. You can clone/read it
all from here:

    https://lab.nexedi.cn/kirr/wendelin.core

Virtual memory-manager even has tests, and from them it could be seen
how the system is supposed to work (after each access - what pages and
where are mapped and how):

    https://lab.nexedi.cn/kirr/wendelin.core/blob/master/bigfile/tests/test_virtmem.c

The performance currently is not great, partly because of page clearing
when getting ram from tmpfs, and partly because of mprotect/SIGSEGV/vmas
overhead and other dumb things on my side.

I still wanted to show the case, as userfaultd here has potential to
remove overhead related to kernel.

Thanks beforehand for feedback,

Kirill


P.S. some context

http://www.wendelin.io/NXD-Wendelin.Core.Non.Secret/asEntireHTML

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
