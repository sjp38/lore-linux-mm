Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7CD348E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 03:55:37 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id a199so21153019qkb.23
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 00:55:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y20si5464109qvc.145.2019.01.22.00.55.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 00:55:36 -0800 (PST)
Date: Tue, 22 Jan 2019 16:55:22 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH RFC 06/24] userfaultfd: wp: support write protection for
 userfault vma range
Message-ID: <20190122085522.GE14907@xz-x1>
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-7-peterx@redhat.com>
 <20190121102035.GC19725@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190121102035.GC19725@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>, Rik van Riel <riel@redhat.com>

On Mon, Jan 21, 2019 at 12:20:35PM +0200, Mike Rapoport wrote:
> On Mon, Jan 21, 2019 at 03:57:04PM +0800, Peter Xu wrote:
> > From: Shaohua Li <shli@fb.com>
> > 
> > Add API to enable/disable writeprotect a vma range. Unlike mprotect,
> > this doesn't split/merge vmas.
> > 
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: Pavel Emelyanov <xemul@parallels.com>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Kirill A. Shutemov <kirill@shutemov.name>
> > Cc: Mel Gorman <mgorman@suse.de>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> > ---
> >  include/linux/userfaultfd_k.h |  2 ++
> >  mm/userfaultfd.c              | 52 +++++++++++++++++++++++++++++++++++
> >  2 files changed, 54 insertions(+)
> > 
> > diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
> > index 38f748e7186e..e82f3156f4e9 100644
> > --- a/include/linux/userfaultfd_k.h
> > +++ b/include/linux/userfaultfd_k.h
> > @@ -37,6 +37,8 @@ extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
> >  			      unsigned long dst_start,
> >  			      unsigned long len,
> >  			      bool *mmap_changing);
> > +extern int mwriteprotect_range(struct mm_struct *dst_mm,
> > +		unsigned long start, unsigned long len, bool enable_wp);
> > 
> >  /* mm helpers */
> >  static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
> > diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
> > index 458acda96f20..c38903f501c7 100644
> > --- a/mm/userfaultfd.c
> > +++ b/mm/userfaultfd.c
> > @@ -615,3 +615,55 @@ ssize_t mfill_zeropage(struct mm_struct *dst_mm, unsigned long start,
> >  {
> >  	return __mcopy_atomic(dst_mm, start, 0, len, true, mmap_changing);
> >  }
> > +
> > +int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
> > +	unsigned long len, bool enable_wp)
> > +{
> > +	struct vm_area_struct *dst_vma;
> > +	pgprot_t newprot;
> > +	int err;
> > +
> > +	/*
> > +	 * Sanitize the command parameters:
> > +	 */
> > +	BUG_ON(start & ~PAGE_MASK);
> > +	BUG_ON(len & ~PAGE_MASK);
> > +
> > +	/* Does the address range wrap, or is the span zero-sized? */
> > +	BUG_ON(start + len <= start);
> > +
> > +	down_read(&dst_mm->mmap_sem);
> > +
> > +	/*
> > +	 * Make sure the vma is not shared, that the dst range is
> > +	 * both valid and fully within a single existing vma.
> > +	 */
> > +	err = -EINVAL;
> 
> In non-cooperative mode, there can be a race between VM layout changes and
> mcopy_atomic [1]. I believe the same races are possible here, so can we
> please make err = -ENOENT for consistency with mcopy?

Sure.

> 
> > +	dst_vma = find_vma(dst_mm, start);
> > +	if (!dst_vma || (dst_vma->vm_flags & VM_SHARED))
> > +		goto out_unlock;
> > +	if (start < dst_vma->vm_start ||
> > +	    start + len > dst_vma->vm_end)
> > +		goto out_unlock;
> > +
> > +	if (!dst_vma->vm_userfaultfd_ctx.ctx)
> > +		goto out_unlock;
> > +	if (!userfaultfd_wp(dst_vma))
> > +		goto out_unlock;
> > +
> > +	if (!vma_is_anonymous(dst_vma))
> > +		goto out_unlock;
> 
> The sanity checks here seem to repeat those in mcopy_atomic(). I'd suggest
> splitting them out to a helper function.

It's a good suggestion.  Thanks!

> 
> > +	if (enable_wp)
> > +		newprot = vm_get_page_prot(dst_vma->vm_flags & ~(VM_WRITE));
> > +	else
> > +		newprot = vm_get_page_prot(dst_vma->vm_flags);
> > +
> > +	change_protection(dst_vma, start, start + len, newprot,
> > +				!enable_wp, 0);
> > +
> > +	err = 0;
> > +out_unlock:
> > +	up_read(&dst_mm->mmap_sem);
> > +	return err;
> > +}
> > -- 
> > 2.17.1
> 
> [1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=27d02568f529e908399514dfbee8ee43bdfd5299
> 
> -- 
> Sincerely yours,
> Mike.
> 

-- 
Peter Xu
