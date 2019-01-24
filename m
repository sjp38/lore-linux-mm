Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 806158E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 23:56:26 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id f2so5279599qtg.14
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 20:56:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l91si9268255qva.115.2019.01.23.20.56.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 20:56:25 -0800 (PST)
Date: Thu, 24 Jan 2019 12:56:15 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH RFC 07/24] userfaultfd: wp: add the writeprotect API to
 userfaultfd ioctl
Message-ID: <20190124045551.GD18231@xz-x1>
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-8-peterx@redhat.com>
 <20190121104232.GA26461@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190121104232.GA26461@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

On Mon, Jan 21, 2019 at 12:42:33PM +0200, Mike Rapoport wrote:

[...]

> > @@ -1343,7 +1344,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> > 
> >  		/* check not compatible vmas */
> >  		ret = -EINVAL;
> > -		if (!vma_can_userfault(cur))
> > +		if (!vma_can_userfault(cur, vm_flags))
> >  			goto out_unlock;
> > 
> >  		/*
> > @@ -1371,6 +1372,8 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> >  			if (end & (vma_hpagesize - 1))
> >  				goto out_unlock;
> >  		}
> > +		if ((vm_flags & VM_UFFD_WP) && !(cur->vm_flags & VM_WRITE))
> > +			goto out_unlock;
> 
> This is problematic for the non-cooperative use-case. Way may still want to
> monitor a read-only area because it may eventually become writable, e.g. if
> the monitored process runs mprotect().

Firstly I think I should be able to change it to VM_MAYWRITE which
seems to suite more.

Meanwhile, frankly speaking I didn't think a lot about how to nest the
usages of uffd-wp and mprotect(), so far I was only considering it as
a replacement of mprotect().  But indeed it can happen that the
monitored process calls mprotect().  Is there an existing scenario of
such usage?

The problem is I'm uncertain about whether this scenario can work
after all.  Say, the monitor process A write protected process B's
page P, so logically A will definitely receive a message before B
writes to page P.  However here if we allow process B to do
mprotect(PROT_WRITE) upon page P and grant write permission to it on
its own, then A will not be able to capture the write operation at
all?  Then I don't know how it can work here... or whether we should
fail the mprotect() at least upon uffd-wp ranges?

> Particularity, for using uffd-wp as a replacement for soft-dirty would
> require it.
> 
> > 
> >  		/*
> >  		 * Check that this vma isn't already owned by a
> > @@ -1400,7 +1403,7 @@ static int userfaultfd_register(struct userfaultfd_ctx *ctx,
> >  	do {
> >  		cond_resched();
> > 
> > -		BUG_ON(!vma_can_userfault(vma));
> > +		BUG_ON(!vma_can_userfault(vma, vm_flags));
> >  		BUG_ON(vma->vm_userfaultfd_ctx.ctx &&
> >  		       vma->vm_userfaultfd_ctx.ctx != ctx);
> >  		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
> > @@ -1535,7 +1538,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
> >  		 * provides for more strict behavior to notice
> >  		 * unregistration errors.
> >  		 */
> > -		if (!vma_can_userfault(cur))
> > +		if (!vma_can_userfault(cur, cur->vm_flags))
> >  			goto out_unlock;
> > 
> >  		found = true;
> > @@ -1549,7 +1552,7 @@ static int userfaultfd_unregister(struct userfaultfd_ctx *ctx,
> >  	do {
> >  		cond_resched();
> > 
> > -		BUG_ON(!vma_can_userfault(vma));
> > +		BUG_ON(!vma_can_userfault(vma, vma->vm_flags));
> >  		WARN_ON(!(vma->vm_flags & VM_MAYWRITE));
> > 
> >  		/*
> > @@ -1760,6 +1763,46 @@ static int userfaultfd_zeropage(struct userfaultfd_ctx *ctx,
> >  	return ret;
> >  }
> > 
> > +static int userfaultfd_writeprotect(struct userfaultfd_ctx *ctx,
> > +				    unsigned long arg)
> > +{
> > +	int ret;
> > +	struct uffdio_writeprotect uffdio_wp;
> > +	struct uffdio_writeprotect __user *user_uffdio_wp;
> > +	struct userfaultfd_wake_range range;
> > +
> 
> In the non-cooperative mode the userfaultfd_writeprotect() may race with VM
> layout changes, pretty much as uffdio_copy() [1]. My solution for uffdio_copy()
> was to return -EAGAIN if such race is encountered. I think the same would
> apply here.

I tried to understand the problem at [1] but failed... could you help
to clarify it a bit more?

I'm quoting some of the discussions from [1] here directly between you
and Pavel:

  > Since the monitor cannot assume that the process will access all its memory
  > it has to copy some pages "in the background". A simple monitor may look
  > like:
  > 
  > 	for (;;) {
  > 		wait_for_uffd_events(timeout);
  > 		handle_uffd_events();
  > 		uffd_copy(some not faulted pages);
  > 	}
  > 
  > Then, if the "background" uffd_copy() races with fork, the pages we've
  > copied may be already present in parent's mappings before the call to
  > copy_page_range() and may be not.
  > 
  > If the pages were not present, uffd_copy'ing them again to the child's
  > memory would be ok.
  >
  > But if uffd_copy() was first to catch mmap_sem, and we would uffd_copy them
  > again, child process will get memory corruption.

Here I don't understand why the child process will get memory
corruption if uffd_copy() caught the mmap_sem first.

If it did it, then IMHO when uffd_copy() copies the page again it'll
simply get a -EEXIST showing that the page has already been copied.
Could you explain on why there will be a data corruption?

Thanks in advance,

>  
> [1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=df2cc96e77011cf7989208b206da9817e0321028
>

-- 
Peter Xu
