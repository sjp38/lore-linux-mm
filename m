Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2EEB6B3A1D
	for <linux-mm@kvack.org>; Sat, 24 Nov 2018 23:07:35 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id z6so12958052qtj.21
        for <linux-mm@kvack.org>; Sat, 24 Nov 2018 20:07:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r95si4301387qkh.131.2018.11.24.20.07.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 24 Nov 2018 20:07:34 -0800 (PST)
Date: Sat, 24 Nov 2018 23:07:29 -0500
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm: put_and_wait_on_page_locked() while page is migrated
Message-ID: <20181125040729.GF4932@redhat.com>
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, David Hildenbrand <david@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Herrmann <dh.herrmann@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Nicholas Piggin <npiggin@gmail.com>, pifang@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, Nov 24, 2018 at 07:21:07PM -0800, Hugh Dickins wrote:
> Waiting on a page migration entry has used wait_on_page_locked() all
> along since 2006: but you cannot safely wait_on_page_locked() without
> holding a reference to the page, and that extra reference is enough to
> make migrate_page_move_mapping() fail with -EAGAIN, when a racing task
> faults on the entry before migrate_page_move_mapping() gets there.
> 
> And that failure is retried nine times, amplifying the pain when
> trying to migrate a popular page.  With a single persistent faulter,
> migration sometimes succeeds; with two or three concurrent faulters,
> success becomes much less likely (and the more the page was mapped,
> the worse the overhead of unmapping and remapping it on each try).
> 
> This is especially a problem for memory offlining, where the outer
> level retries forever (or until terminated from userspace), because
> a heavy refault workload can trigger an endless loop of migration
> failures.  wait_on_page_locked() is the wrong tool for the job.
> 
> David Herrmann (but was he the first?) noticed this issue in 2014:
> https://marc.info/?l=linux-mm&m=140110465608116&w=2
> 
> Tim Chen started a thread in August 2017 which appears relevant:
> https://marc.info/?l=linux-mm&m=150275941014915&w=2
> where Kan Liang went on to implicate __migration_entry_wait():
> https://marc.info/?l=linux-mm&m=150300268411980&w=2
> and the thread ended up with the v4.14 commits:
> 2554db916586 ("sched/wait: Break up long wake list walk")
> 11a19c7b099f ("sched/wait: Introduce wakeup boomark in wake_up_page_bit")
> 
> Baoquan He reported "Memory hotplug softlock issue" 14 November 2018:
> https://marc.info/?l=linux-mm&m=154217936431300&w=2
> 
> We have all assumed that it is essential to hold a page reference while
> waiting on a page lock: partly to guarantee that there is still a struct
> page when MEMORY_HOTREMOVE is configured, but also to protect against
> reuse of the struct page going to someone who then holds the page locked
> indefinitely, when the waiter can reasonably expect timely unlocking.
> 
> But in fact, so long as wait_on_page_bit_common() does the put_page(),
> and is careful not to rely on struct page contents thereafter, there is
> no need to hold a reference to the page while waiting on it.  That does
> mean that this case cannot go back through the loop: but that's fine for
> the page migration case, and even if used more widely, is limited by the
> "Stop walking if it's locked" optimization in wake_page_function().
> 
> Add interface put_and_wait_on_page_locked() to do this, using negative
> value of the lock arg to wait_on_page_bit_common() to implement it.
> No interruptible or killable variant needed yet, but they might follow:
> I have a vague notion that reporting -EINTR should take precedence over
> return from wait_on_page_bit_common() without knowing the page state,
> so arrange it accordingly - but that may be nothing but pedantic.
> 
> __migration_entry_wait() still has to take a brief reference to the
> page, prior to calling put_and_wait_on_page_locked(): but now that it
> is dropped before waiting, the chance of impeding page migration is
> very much reduced.  Should we perhaps disable preemption across this?
> 
> shrink_page_list()'s __ClearPageLocked(): that was a surprise!  This
> survived a lot of testing before that showed up.  PageWaiters may have
> been set by wait_on_page_bit_common(), and the reference dropped, just
> before shrink_page_list() succeeds in freezing its last page reference:
> in such a case, unlock_page() must be used.  Follow the suggestion from
> Michal Hocko, just revert a978d6f52106 ("mm: unlockless reclaim") now:
> that optimization predates PageWaiters, and won't buy much these days;
> but we can reinstate it for the !PageWaiters case if anyone notices.
> 
> It does raise the question: should vmscan.c's is_page_cache_freeable()
> and __remove_mapping() now treat a PageWaiters page as if an extra
> reference were held?  Perhaps, but I don't think it matters much, since
> shrink_page_list() already had to win its trylock_page(), so waiters are
> not very common there: I noticed no difference when trying the bigger
> change, and it's surely not needed while put_and_wait_on_page_locked()
> is only used for page migration.
> 
> Reported-and-tested-by: Baoquan He <bhe@redhat.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
