Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id CEE1C6B005C
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 21:28:13 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id a108so1293259qge.2
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 18:28:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id gq5si9891105qab.95.2014.04.16.18.28.12
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 18:28:13 -0700 (PDT)
Date: Thu, 17 Apr 2014 02:31:28 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: mm: kernel BUG at mm/huge_memory.c:1829!
Message-ID: <20140417003128.GG10119@redhat.com>
References: <53440991.9090001@oracle.com>
 <20140410102527.GA24111@node.dhcp.inet.fi>
 <20140410134436.GA25933@node.dhcp.inet.fi>
 <20140410162750.GD2749@redhat.com>
 <20140414144218.GA26515@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140414144218.GA26515@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Bob Liu <lliubbo@gmail.com>

Hi Kirill,

On Mon, Apr 14, 2014 at 05:42:18PM +0300, Kirill A. Shutemov wrote:
> I've spent few day trying to understand rmap code. And now I think my
> patch is wrong.
> 
> I actually don't see where walk order requirement comes from. It seems all
> operations (insert, remove, foreach) on anon_vma is serialized with
> anon_vma->root->rwsem. Andrea, could you explain this for me?

It's true the locking protects and freezes the view of all anon_vma
structures associated with the page, but that only guarantees you not
to miss the vma. Not missing the vma is not enough. You can still miss
a pte during the rmap_walk if the order is wrong, because the pte/pmds
are still moving freely under the vmas (absent of the PT lock and the
mmap_sem).

The problem are all MM operations that copies or move a page mapping
from a source to destination vma (fork and mremap). They take the
anon_vma lock, insert the destination vma with the proper anon_vma
chains and then they _drop_ the anon vma lock, and only later they
start moving ptes and pmds around (by taking the proper PT locks).

anon_vma -> src_vma -> dst_vma

If the order is like above (guaranteed before the interval tree was
introduced), if the rmap_walk of split_huge_page and migrate
encounters the source pte/pmd and split/unmap it before it gets
copied, then the copy or move will retain the processed state (regular
pte instead of trans_huge_pmd for split_huge_page or migration pte for
migrate). If instead the pmd/pte was already copied by the time the
src_vma is scanned, then it will encounter the copy to process in the
dst_vma too. The rmap_walk can't miss a pte/pmd if the anon_vma chain
is walked in insertion order (i.e. older vma first).

anon_vma -> dst_vma -> src_vma

If the anon_vma walk order is reversed vs the insertion order, things
falls apart because you will scan dst_vma in split_huge_page while it
still empty, find nothing, then the trans_huge_pmd is moved or copied
from src_vma to dst_vma by the MM code only holding PT lock and
mmap_sem for writing (we cannot hold those across the whole duration
of split_huge_page and migrate). So if the rmap_walk order is not
right, the rmap_walk can miss the contents of the dst_vma that was
still empty at the time it was processed.

If the interval tree walk order cannot be fixed without screwing with
the computation complexity of the structure, a more black and white
fix could be to add a anon_vma templist to scan in O(N) after the
interval tree has been scanned, where you add newly inserted vmas.
The templist shall then be flushed back to the interval tree only
after the pte/pmd mangling of the MM operation is completed. That
requires identifying the closure of the critical section for those
problematic MM operations. The main drawback is actually having to
take the anon_vma lock twice, the second time for the flush to the
interval tree.

Looping like in your previous patch would be much simpler if it could
be made reliable, but it looked like it wouldn't close the bug
entirely because any concurrent unmap operation could lead to false
negative hiding the pmd/pte walk miss (by decreasing page->mapcount
under us).

Comments?

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
