Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 619856B006E
	for <linux-mm@kvack.org>; Wed,  2 Oct 2013 11:28:16 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr4so1027088pbb.34
        for <linux-mm@kvack.org>; Wed, 02 Oct 2013 08:28:16 -0700 (PDT)
Date: Wed, 2 Oct 2013 17:28:11 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 23/26] ib: Convert qib_get_user_pages() to
 get_user_pages_unlocked()
Message-ID: <20131002152811.GC32181@quack.suse.cz>
References: <1380724087-13927-1-git-send-email-jack@suse.cz>
 <1380724087-13927-24-git-send-email-jack@suse.cz>
 <32E1700B9017364D9B60AED9960492BC211AEF75@FMSMSX107.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <32E1700B9017364D9B60AED9960492BC211AEF75@FMSMSX107.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Marciniszyn, Mike" <mike.marciniszyn@intel.com>
Cc: Jan Kara <jack@suse.cz>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, infinipath <infinipath@intel.com>, Roland Dreier <roland@kernel.org>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>

On Wed 02-10-13 14:54:59, Marciniszyn, Mike wrote:
> Thanks!!
> 
> I would like to test these two patches and also do the stable work for
> the deadlock as well.  Do you have these patches in a repo somewhere to
> save me a bit of work?
  I've pushed the patches to:
git://git.kernel.org/pub/scm/linux/kernel/git/jack/linux-fs.git
into the branch 'get_user_pages'.

> We had been working on an internal version of the deadlock portion of
> this patch that uses get_user_pages_fast() vs. the new
> get_user_pages_unlocked().
> 
> The risk of GUP fast is the loss of the "force" arg on GUP fast, which I
> don't see as significant give our use case.
  Yes. I was discussing with Roland some time ago whether the force
argument is needed and he said it is. So I kept the arguments of
get_user_pages() intact and just simplified the locking...

BTW: Infiniband still needs mmap_sem for modification of mm->pinned_vm. It
might be worthwhile to actually change that to atomic_long_t (only
kernel/events/core.c would need update besides infiniband) and avoid taking
mmap_sem in infiniband code altogether.

> Some nits on the subject and commit message:
> 1. use IB/qib, IB/ipath vs. ib
> 2. use the correct ipath vs. qib in the commit message text
  Sure will do. Thanks the quick reply and for comments.

								Honza
> > -----Original Message-----
> > From: Jan Kara [mailto:jack@suse.cz]
> > Sent: Wednesday, October 02, 2013 10:28 AM
> > To: LKML
> > Cc: linux-mm@kvack.org; Jan Kara; infinipath; Roland Dreier; linux-
> > rdma@vger.kernel.org
> > Subject: [PATCH 23/26] ib: Convert qib_get_user_pages() to
> > get_user_pages_unlocked()
> > 
> > Convert qib_get_user_pages() to use get_user_pages_unlocked().  This
> > shortens the section where we hold mmap_sem for writing and also removes
> > the knowledge about get_user_pages() locking from ipath driver. We also fix
> > a bug in testing pinned number of pages when changing the code.
> > 
> > CC: Mike Marciniszyn <infinipath@intel.com>
> > CC: Roland Dreier <roland@kernel.org>
> > CC: linux-rdma@vger.kernel.org
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  drivers/infiniband/hw/qib/qib_user_pages.c | 62 +++++++++++++----------------
> > -
> >  1 file changed, 26 insertions(+), 36 deletions(-)
> > 
> > diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c
> > b/drivers/infiniband/hw/qib/qib_user_pages.c
> > index 2bc1d2b96298..57ce83c2d1d9 100644
> > --- a/drivers/infiniband/hw/qib/qib_user_pages.c
> > +++ b/drivers/infiniband/hw/qib/qib_user_pages.c
> > @@ -48,39 +48,55 @@ static void __qib_release_user_pages(struct page
> > **p, size_t num_pages,
> >  	}
> >  }
> > 
> > -/*
> > - * Call with current->mm->mmap_sem held.
> > +/**
> > + * qib_get_user_pages - lock user pages into memory
> > + * @start_page: the start page
> > + * @num_pages: the number of pages
> > + * @p: the output page structures
> > + *
> > + * This function takes a given start page (page aligned user virtual
> > + * address) and pins it and the following specified number of pages.
> > +For
> > + * now, num_pages is always 1, but that will probably change at some
> > +point
> > + * (because caller is doing expected sends on a single virtually
> > +contiguous
> > + * buffer, so we can do all pages at once).
> >   */
> > -static int __qib_get_user_pages(unsigned long start_page, size_t
> > num_pages,
> > -				struct page **p, struct vm_area_struct
> > **vma)
> > +int qib_get_user_pages(unsigned long start_page, size_t num_pages,
> > +		       struct page **p)
> >  {
> >  	unsigned long lock_limit;
> >  	size_t got;
> >  	int ret;
> > +	struct mm_struct *mm = current->mm;
> > 
> > +	down_write(&mm->mmap_sem);
> >  	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
> > 
> > -	if (num_pages > lock_limit && !capable(CAP_IPC_LOCK)) {
> > +	if (mm->pinned_vm + num_pages > lock_limit &&
> > !capable(CAP_IPC_LOCK)) {
> > +		up_write(&mm->mmap_sem);
> >  		ret = -ENOMEM;
> >  		goto bail;
> >  	}
> > +	mm->pinned_vm += num_pages;
> > +	up_write(&mm->mmap_sem);
> > 
> >  	for (got = 0; got < num_pages; got += ret) {
> > -		ret = get_user_pages(current, current->mm,
> > -				     start_page + got * PAGE_SIZE,
> > -				     num_pages - got, 1, 1,
> > -				     p + got, vma);
> > +		ret = get_user_pages_unlocked(current, mm,
> > +					      start_page + got * PAGE_SIZE,
> > +					      num_pages - got, 1, 1,
> > +					      p + got);
> >  		if (ret < 0)
> >  			goto bail_release;
> >  	}
> > 
> > -	current->mm->pinned_vm += num_pages;
> > 
> >  	ret = 0;
> >  	goto bail;
> > 
> >  bail_release:
> >  	__qib_release_user_pages(p, got, 0);
> > +	down_write(&mm->mmap_sem);
> > +	mm->pinned_vm -= num_pages;
> > +	up_write(&mm->mmap_sem);
> >  bail:
> >  	return ret;
> >  }
> > @@ -117,32 +133,6 @@ dma_addr_t qib_map_page(struct pci_dev *hwdev,
> > struct page *page,
> >  	return phys;
> >  }
> > 
> > -/**
> > - * qib_get_user_pages - lock user pages into memory
> > - * @start_page: the start page
> > - * @num_pages: the number of pages
> > - * @p: the output page structures
> > - *
> > - * This function takes a given start page (page aligned user virtual
> > - * address) and pins it and the following specified number of pages.  For
> > - * now, num_pages is always 1, but that will probably change at some point
> > - * (because caller is doing expected sends on a single virtually contiguous
> > - * buffer, so we can do all pages at once).
> > - */
> > -int qib_get_user_pages(unsigned long start_page, size_t num_pages,
> > -		       struct page **p)
> > -{
> > -	int ret;
> > -
> > -	down_write(&current->mm->mmap_sem);
> > -
> > -	ret = __qib_get_user_pages(start_page, num_pages, p, NULL);
> > -
> > -	up_write(&current->mm->mmap_sem);
> > -
> > -	return ret;
> > -}
> > -
> >  void qib_release_user_pages(struct page **p, size_t num_pages)  {
> >  	if (current->mm) /* during close after signal, mm can be NULL */
> > --
> > 1.8.1.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
