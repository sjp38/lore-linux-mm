Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 677AD8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 04:39:49 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id n50so23949819qtb.9
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 01:39:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b9si2498879qtq.169.2019.01.22.01.39.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 01:39:48 -0800 (PST)
Date: Tue, 22 Jan 2019 17:39:35 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH RFC 06/24] userfaultfd: wp: support write protection for
 userfault vma range
Message-ID: <20190122093935.GF14907@xz-x1>
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-7-peterx@redhat.com>
 <20190121140535.GD3344@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190121140535.GD3344@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>, Rik van Riel <riel@redhat.com>

On Mon, Jan 21, 2019 at 09:05:35AM -0500, Jerome Glisse wrote:

[...]

> > +	change_protection(dst_vma, start, start + len, newprot,
> > +				!enable_wp, 0);
> 
> So setting dirty_accountable bring us to that code in mprotect.c:
> 
>     if (dirty_accountable && pte_dirty(ptent) &&
>             (pte_soft_dirty(ptent) ||
>              !(vma->vm_flags & VM_SOFTDIRTY))) {
>         ptent = pte_mkwrite(ptent);
>     }
> 
> My understanding is that you want to set write flag when enable_wp
> is false and you want to set the write flag unconditionaly, right ?

Right.

> 
> If so then you should really move the change_protection() flags
> patch before this patch and add a flag for setting pte write flags.
> 
> Otherwise the above is broken at it will only set the write flag
> for pte that were dirty and i am guessing so far you always were
> lucky because pte were all dirty (change_protection will preserve
> dirtyness) when you write protected them.
> 
> So i believe the above is broken or at very least unclear if what
> you really want is to only set write flag to pte that have the
> dirty flag set.

You are right, if we build the tree until this patch it won't work for
all the cases.  It'll only work if the page was at least writable
before and also it's dirty (as you explained).  Sorry to be unclear
about this, maybe I should at least mention that in the commit message
but I totally forgot it.

All these problems are solved in later on patches, please feel free to
have a look at:

  mm: merge parameters for change_protection()
  userfaultfd: wp: apply _PAGE_UFFD_WP bit
  userfaultfd: wp: handle COW properly for uffd-wp

Note that even in the follow up patches IMHO we can't directly change
the write permission since the page can be shared by other processes
(e.g., the zero page or COW pages).  But the general idea is the same
as you explained.

I tried to avoid squashing these stuff altogether as explained
previously.  Also, this patch can be seen as a standalone patch to
introduce the new interface which seems to make sense too, and it is
indeed still working in many cases so I see the latter patches as
enhancement of this one.  Please let me know if you still want me to
have all these stuff squashed, or if you'd like me to squash some of
them.

Thanks!

-- 
Peter Xu
