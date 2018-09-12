Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 62A4F8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 16:10:15 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id e6-v6so5330329itc.7
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 13:10:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d74-v6sor1241615jac.140.2018.09.12.13.10.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Sep 2018 13:10:13 -0700 (PDT)
MIME-Version: 1.0
References: <20180911103403.38086-1-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180911103403.38086-1-kirill.shutemov@linux.intel.com>
From: Vegard Nossum <vegard.nossum@gmail.com>
Date: Wed, 12 Sep 2018 22:10:00 +0200
Message-ID: <CAOMGZ=F2RBqZT8sDR8pMi1OBefTEUKXA5_CsF7p0zQr4a39aaA@mail.gmail.com>
Subject: Re: [PATCH] mm, thp: Fix mlocking THP page with migration enabled
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>, zi.yan@cs.rutgers.edu, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, vbabka@suse.cz, aarcange@redhat.com

On Tue, 11 Sep 2018 at 12:34, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
>
> A transparent huge page is represented by a single entry on an LRU list.
> Therefore, we can only make unevictable an entire compound page, not
> individual subpages.
>
> If a user tries to mlock() part of a huge page, we want the rest of the
> page to be reclaimable.
>
> We handle this by keeping PTE-mapped huge pages on normal LRU lists: the
> PMD on border of VM_LOCKED VMA will be split into PTE table.
>
> Introduction of THP migration breaks the rules around mlocking THP
> pages. If we had a single PMD mapping of the page in mlocked VMA, the
> page will get mlocked, regardless of PTE mappings of the page.
>
> For tmpfs/shmem it's easy to fix by checking PageDoubleMap() in
> remove_migration_pmd().
>
> Anon THP pages can only be shared between processes via fork(). Mlocked
> page can only be shared if parent mlocked it before forking, otherwise
> CoW will be triggered on mlock().
>
> For Anon-THP, we can fix the issue by munlocking the page on removing PTE
> migration entry for the page. PTEs for the page will always come after
> mlocked PMD: rmap walks VMAs from oldest to newest.
>
> Test-case:
>
>         #include <unistd.h>
>         #include <sys/mman.h>
>         #include <sys/wait.h>
>         #include <linux/mempolicy.h>
>         #include <numaif.h>
>
>         int main(void)
>         {
>                 unsigned long nodemask = 4;
>                 void *addr;
>
>                 addr = mmap((void *)0x20000000UL, 2UL << 20, PROT_READ | PROT_WRITE,
>                         MAP_PRIVATE | MAP_ANONYMOUS | MAP_LOCKED, -1, 0);
>
>                 if (fork()) {
>                         wait(NULL);
>                         return 0;
>                 }
>
>                 mlock(addr, 4UL << 10);
>                 mbind(addr, 2UL << 20, MPOL_PREFERRED | MPOL_F_RELATIVE_NODES,
>                         &nodemask, 4, MPOL_MF_MOVE | MPOL_MF_MOVE_ALL);

MPOL_MF_MOVE_ALL is actually not required to trigger the bug.

>
>                 return 0;
>         }
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Vegard Nossum <vegard.nossum@gmail.com>

Would you mind putting vegard.nossum@oracle.com instead?

> Fixes: 616b8371539a ("mm: thp: enable thp migration in generic path")

The commit I bisected the problem to was actually a different one:

commit c8633798497ce894c22ab083eb884c8294c537b2
Author: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date:   Fri Sep 8 16:11:08 2017 -0700

    mm: mempolicy: mbind and migrate_pages support thp migration

But maybe you had a good reason to choose the other one instead. They
are close together in any case, so I guess it would be hard to find a
kernel with one commit and not the other.

> Cc: <stable@vger.kernel.org> [v4.14+]
> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Andrea Arcangeli <aarcange@redhat.com>

You could also add:

Link: https://lkml.org/lkml/2018/8/30/464

Thanks for debugging this.


Vegard
