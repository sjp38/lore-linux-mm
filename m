Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 964F98E0047
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 00:45:51 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s70so4436992qks.4
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 21:45:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r17si1525979qvc.182.2019.01.23.21.45.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 21:45:50 -0800 (PST)
Date: Thu, 24 Jan 2019 13:45:33 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH RFC 03/24] mm: allow VM_FAULT_RETRY for multiple times
Message-ID: <20190124054508.GH18231@xz-x1>
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-4-peterx@redhat.com>
 <20190121155536.GB3711@redhat.com>
 <20190122082238.GC14907@xz-x1>
 <20190122165310.GB3188@redhat.com>
 <20190123021241.GA2970@xz-x1>
 <20190123023947.GA3652@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190123023947.GA3652@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

On Tue, Jan 22, 2019 at 09:39:47PM -0500, Jerome Glisse wrote:
> On Wed, Jan 23, 2019 at 10:12:41AM +0800, Peter Xu wrote:
> > On Tue, Jan 22, 2019 at 11:53:10AM -0500, Jerome Glisse wrote:
> > > On Tue, Jan 22, 2019 at 04:22:38PM +0800, Peter Xu wrote:
> > > > On Mon, Jan 21, 2019 at 10:55:36AM -0500, Jerome Glisse wrote:
> > > > > On Mon, Jan 21, 2019 at 03:57:01PM +0800, Peter Xu wrote:
> > > > > > The idea comes from a discussion between Linus and Andrea [1].
> > > > > > 
> > > > > > Before this patch we only allow a page fault to retry once.  We achieved
> > > > > > this by clearing the FAULT_FLAG_ALLOW_RETRY flag when doing
> > > > > > handle_mm_fault() the second time.  This was majorly used to avoid
> > > > > > unexpected starvation of the system by looping over forever to handle
> > > > > > the page fault on a single page.  However that should hardly happen, and
> > > > > > after all for each code path to return a VM_FAULT_RETRY we'll first wait
> > > > > > for a condition (during which time we should possibly yield the cpu) to
> > > > > > happen before VM_FAULT_RETRY is really returned.
> > > > > > 
> > > > > > This patch removes the restriction by keeping the FAULT_FLAG_ALLOW_RETRY
> > > > > > flag when we receive VM_FAULT_RETRY.  It means that the page fault
> > > > > > handler now can retry the page fault for multiple times if necessary
> > > > > > without the need to generate another page fault event. Meanwhile we
> > > > > > still keep the FAULT_FLAG_TRIED flag so page fault handler can still
> > > > > > identify whether a page fault is the first attempt or not.
> > > > > 
> > > > > So there is nothing protecting starvation after this patch ? AFAICT.
> > > > > Do we sufficient proof that we never have a scenario where one process
> > > > > might starve fault another ?
> > > > > 
> > > > > For instance some page locking could starve one process.
> > > > 
> > > > Hi, Jerome,
> > > > 
> > > > Do you mean lock_page()?
> > > > 
> > > > AFAIU lock_page() will only yield the process itself until the lock is
> > > > released, so IMHO it's not really starving the process but a natural
> > > > behavior.  After all the process may not continue without handling the
> > > > page fault correctly.
> > > > 
> > > > Or when you say "starvation" do you mean that we might return
> > > > VM_FAULT_RETRY from handle_mm_fault() continuously so we'll looping
> > > > over and over inside the page fault handler?
> > > 
> > > That one ie every time we retry someone else is holding the lock and
> > > thus lock_page_or_retry() will continuously retry. Some process just
> > > get unlucky ;)
> > > 
> > > With existing code because we remove the retry flag then on the second
> > > try we end up waiting for the page lock while holding the mmap_sem so
> > > we know that we are in line for the page lock and we will get it once
> > > it is our turn.
> > 
> > Ah I see. :)  It's indeed a valid questioning.
> > 
> > Firstly note that even after this patch we can still identify whether
> > we're at the first attempt or not by checking against FAULT_FLAG_TRIED
> > (it will be applied to the fault flag in all the retries but not in
> > the first atttempt). So IMHO this change might suite if we want to
> > keep the old behavior [1]:
> > 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 9f5e323e883e..44942c78bb92 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -1351,7 +1351,7 @@ EXPORT_SYMBOL_GPL(__lock_page_killable);
> >  int __lock_page_or_retry(struct page *page, struct mm_struct *mm,
> >                          unsigned int flags)
> >  {
> > -       if (flags & FAULT_FLAG_ALLOW_RETRY) {
> > +       if (!flags & FAULT_FLAG_TRIED) {
> >                 /*
> >                  * CAUTION! In this case, mmap_sem is not released
> >                  * even though return 0.
> 
> I need to check how FAULT_FLAG_TRIED have been use so far, but yes
> it looks like this would keep the existing behavior intact.
> 
> > 
> > But at the same time I'm stepping back trying to see the whole
> > picture... My understanding is that this is really a policy that we
> > can decide, and a trade off between "being polite or not on the
> > mmap_sem", that when taking the page lock in slow path we either:
> > 
> >   (1) release mmap_sem before waiting, polite enough but uncertain to
> >       finally have the lock, or,
> > 
> >   (2) keep mmap_sem before waiting, not polite enough but certain to
> >       take the lock.
> > 
> > We did (2) before on the reties because in existing code we only allow
> > to retry once, so we can't fail on the 2nd attempt.  That seems to be
> > a good reason to being "unpolite" - we took the mmap_sem without
> > considering others because we've been "polite" once.  I'm not that
> > experienced in mm development but AFAIU solution 2 is only reducing
> > our chance of starvation but adding that chance of starvation to other
> > processes that want the mmap_sem instead.  So IMHO the starvation
> > issue always existed even before this patch, and it looks natural and
> > sane to me so far...  And if with that in mind, I can't say that above
> > change at [1] would be better, and maybe, it'll be even more fair that
> > we should always release the mmap_sem first in this case (assuming
> > that we'll after all have that lock though we might pay more times of
> > retries)?
> 
> Existing code does not starves anyone, the mmap_sem is rw_semaphore
> so if there is no writter waiting then no ones wait, if there is a
> writter waiting then everyone wait in line so that it is fair to
> writter. So with existing code we have a "fair" behavior where every-
> ones wait in line their turn. After this patch we can end up in unfair
> situation were one thread might be continuously starve because it is
> only doing try_lock and thus it is never added to wait line.

I see the point.  Thanks for explaining it.

> 
> 
> > Or, is there a way to constantly starve the process that handles the
> > page fault that I've totally missed?
> 
> That's the discussion, with your change a process can constantly
> retry page fault because it never get a lock on a page, so it can
> end up in an infinite fault retry.
> 
> Yes it is unlikely to be infinite, but it can change how kernel
> behave to some workload and thus impact existing user.

Yes and even if anyone wants to change the behavior maybe it can be
changed after a proper justification, then it makes sense to me that I
squash above oneliner into this patch to keep the existing page
locking behavior.

Thanks again,

-- 
Peter Xu
