Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB1BA6B477A
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 05:56:20 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id v79so13761395pfd.20
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:56:20 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a68si3728969pla.267.2018.11.27.02.56.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Nov 2018 02:56:18 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wARArmBa076831
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 05:56:18 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p141r9m64-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 05:56:17 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Tue, 27 Nov 2018 10:56:14 -0000
Date: Tue, 27 Nov 2018 12:56:03 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCHi v2] mm: put_and_wait_on_page_locked() while page is
 migrated
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils>
 <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com>
 <alpine.LSU.2.11.1811251900300.1278@eggly.anvils>
 <alpine.LSU.2.11.1811261121330.1116@eggly.anvils>
 <20181126205351.GM3065@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181126205351.GM3065@bombadil.infradead.org>
Message-Id: <20181127105602.GC16502@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Herrmann <dh.herrmann@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Nov 26, 2018 at 12:53:51PM -0800, Matthew Wilcox wrote:
> On Mon, Nov 26, 2018 at 11:27:07AM -0800, Hugh Dickins wrote:
> > Waiting on a page migration entry has used wait_on_page_locked() all
> > along since 2006: but you cannot safely wait_on_page_locked() without
> > holding a reference to the page, and that extra reference is enough to
> > make migrate_page_move_mapping() fail with -EAGAIN, when a racing task
> > faults on the entry before migrate_page_move_mapping() gets there.
> > 
> > And that failure is retried nine times, amplifying the pain when
> > trying to migrate a popular page.  With a single persistent faulter,
> > migration sometimes succeeds; with two or three concurrent faulters,
> > success becomes much less likely (and the more the page was mapped,
> > the worse the overhead of unmapping and remapping it on each try).
> > 
> > This is especially a problem for memory offlining, where the outer
> > level retries forever (or until terminated from userspace), because
> > a heavy refault workload can trigger an endless loop of migration
> > failures.  wait_on_page_locked() is the wrong tool for the job.
> > 
> > David Herrmann (but was he the first?) noticed this issue in 2014:
> > https://marc.info/?l=linux-mm&m=140110465608116&w=2
> > 
> > Tim Chen started a thread in August 2017 which appears relevant:
> > https://marc.info/?l=linux-mm&m=150275941014915&w=2
> > where Kan Liang went on to implicate __migration_entry_wait():
> > https://marc.info/?l=linux-mm&m=150300268411980&w=2
> > and the thread ended up with the v4.14 commits:
> > 2554db916586 ("sched/wait: Break up long wake list walk")
> > 11a19c7b099f ("sched/wait: Introduce wakeup boomark in wake_up_page_bit")
> > 
> > Baoquan He reported "Memory hotplug softlock issue" 14 November 2018:
> > https://marc.info/?l=linux-mm&m=154217936431300&w=2
> > 
> > We have all assumed that it is essential to hold a page reference while
> > waiting on a page lock: partly to guarantee that there is still a struct
> > page when MEMORY_HOTREMOVE is configured, but also to protect against
> > reuse of the struct page going to someone who then holds the page locked
> > indefinitely, when the waiter can reasonably expect timely unlocking.
> > 
> > But in fact, so long as wait_on_page_bit_common() does the put_page(),
> > and is careful not to rely on struct page contents thereafter, there is
> > no need to hold a reference to the page while waiting on it.  That does
> > mean that this case cannot go back through the loop: but that's fine for
> > the page migration case, and even if used more widely, is limited by the
> > "Stop walking if it's locked" optimization in wake_page_function().
> > 
> > Add interface put_and_wait_on_page_locked() to do this, using "behavior"
> > enum in place of "lock" arg to wait_on_page_bit_common() to implement it.
> > No interruptible or killable variant needed yet, but they might follow:
> > I have a vague notion that reporting -EINTR should take precedence over
> > return from wait_on_page_bit_common() without knowing the page state,
> > so arrange it accordingly - but that may be nothing but pedantic.
> > 
> > __migration_entry_wait() still has to take a brief reference to the
> > page, prior to calling put_and_wait_on_page_locked(): but now that it
> > is dropped before waiting, the chance of impeding page migration is
> > very much reduced.  Should we perhaps disable preemption across this?
> > 
> > shrink_page_list()'s __ClearPageLocked(): that was a surprise!  This
> > survived a lot of testing before that showed up.  PageWaiters may have
> > been set by wait_on_page_bit_common(), and the reference dropped, just
> > before shrink_page_list() succeeds in freezing its last page reference:
> > in such a case, unlock_page() must be used.  Follow the suggestion from
> > Michal Hocko, just revert a978d6f52106 ("mm: unlockless reclaim") now:
> > that optimization predates PageWaiters, and won't buy much these days;
> > but we can reinstate it for the !PageWaiters case if anyone notices.
> > 
> > It does raise the question: should vmscan.c's is_page_cache_freeable()
> > and __remove_mapping() now treat a PageWaiters page as if an extra
> > reference were held?  Perhaps, but I don't think it matters much, since
> > shrink_page_list() already had to win its trylock_page(), so waiters are
> > not very common there: I noticed no difference when trying the bigger
> > change, and it's surely not needed while put_and_wait_on_page_locked()
> > is only used for page migration.
> > 
> > Reported-and-tested-by: Baoquan He <bhe@redhat.com>
> > Signed-off-by: Hugh Dickins <hughd@google.com>
> > Acked-by: Michal Hocko <mhocko@suse.com>
> > Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
> > ---
> >  include/linux/pagemap.h |  2 ++
> >  mm/filemap.c            | 77 ++++++++++++++++++++++++++++++++++-------
> >  mm/huge_memory.c        |  6 ++--
> >  mm/migrate.c            | 12 +++----
> >  mm/vmscan.c             | 10 ++----
> >  5 files changed, 74 insertions(+), 33 deletions(-)
> > 
> 
> /**
>  * put_and_wait_on_page_locked - Drop a reference and wait for it to be unlocked

                                                        wait for page ?

>  * @page: The page to wait for.
>  *
>  * The caller should hold a reference on @page.  They expect the page to
>  * become unlocked relatively soon, but do not wish to hold up migration
>  * (for example) by holding the reference while waiting for the page to
>  * come unlocked.  After this function returns, the caller should not
>  * dereference @page.
>  */

How about:
 
They expect the page to become unlocked relatively soon, but they can wait
for the page to come unlocked without holding the reference, to allow
other users of the @page (for example migration) to continue. 

> (improvements gratefully received)
> 
> > +void put_and_wait_on_page_locked(struct page *page)
> > +{
> > +	wait_queue_head_t *q;
> > +
> > +	page = compound_head(page);
> > +	q = page_waitqueue(page);
> > +	wait_on_page_bit_common(q, page, PG_locked, TASK_UNINTERRUPTIBLE, DROP);
> > +}
> > +
> >  /**
> >   * add_page_wait_queue - Add an arbitrary waiter to a page's wait queue
> >   * @page: Page defining the wait queue of interest
> 

-- 
Sincerely yours,
Mike.
