Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id AC0336B0032
	for <linux-mm@kvack.org>; Thu, 25 Apr 2013 09:22:00 -0400 (EDT)
Date: Thu, 25 Apr 2013 15:21:57 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: Infiniband use of get_user_pages()
Message-ID: <20130425132157.GA32353@quack.suse.cz>
References: <20130424153810.GA25958@quack.suse.cz>
 <CAL1RGDXqtLPmM0kRofFwTv+jzr2cBGoe9X7oQLO_yoHGErJnxg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAL1RGDXqtLPmM0kRofFwTv+jzr2cBGoe9X7oQLO_yoHGErJnxg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roland Dreier <roland@kernel.org>
Cc: Jan Kara <jack@suse.cz>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, linux-mm@kvack.org

On Wed 24-04-13 15:25:25, Roland Dreier wrote:
> On Wed, Apr 24, 2013 at 8:38 AM, Jan Kara <jack@suse.cz> wrote:
> >   when checking users of get_user_pages() (I'm doing some cleanups in that
> > area to fix filesystem's issues with mmap_sem locking) I've noticed that
> > infiniband drivers add number of pages obtained from get_user_pages() to
> > mm->pinned_vm counter. Although this makes some sence, it doesn't match
> > with any other user of get_user_pages() (e.g. direct IO) so has infiniband
> > some special reason why it does so?
> 
> Direct IO mappings are in some sense ephemeral -- they only need to
> last while the IO is in flight.  In contrast the IB memory pinning is
> controlled by (possibly unprivileged) userspace and might last the
> whole lifetime of a long-lived application.  So we want some
> accounting and resource control.
  I see, thanks for explanation.

> >   Also that seems to be the only real reason why mmap_sem has to be grabbed
> > in exclusive mode, am I right?
> 
> Most likely that is true.
> 
> >   Another suspicious thing (at least in drivers/infiniband/core/umem.c:
> > ib_umem_get()) is that arguments of get_user_pages() are like:
> >                 ret = get_user_pages(current, current->mm, cur_base,
> >                                      min_t(unsigned long, npages,
> >                                            PAGE_SIZE / sizeof (struct page *)),
> >                                      1, !umem->writable, page_list, vma_list);
> > So we always have write argument set to 1 and force argument is set to
> > !umem->writable. Is that really intentional? My naive guess would be that
> > arguments should be switched... Although even in that case I fail to see
> > why 'force' argument should be set. Can someone please explain?
> 
> This confused even me recently.  We had a long discussion (read the
> whole thread starting here: https://lkml.org/lkml/2012/1/26/7) but in
> short the current parameters seem to be needed to trigger COW even
> when the kernel/hardware want to read the memory, to avoid problems
> where we get stale data if userspace triggers COW.
  Thanks for the pointer. That was an interesting read :).

> I think I better add a comment explaining this.
> 
> >   Finally (and here I may show my ignorance ;), I'd like to ask whether
> > there's any reason why ib_umem_get() checks for is_vm_hugetlb_page() and
> > not just whether a page is a huge page?
> 
> I'm not sure of the history here.  How would one check directly if a
> page is a huge page?
  PageHuge(page) should do it (see mm/hugetlb.c).

> get_user_pages() actually goes to some trouble to return all small pages,
> even when it has to split a single huge page into many entries in the
> page array.  (Which is actually a bit unfortunate for our use here)
  Does it? As far as I'm checking get_user_pages() and the fault path I
don't see where it would be happening...

								Honza  
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
