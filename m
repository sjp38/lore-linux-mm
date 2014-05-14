Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id A2CD66B0036
	for <linux-mm@kvack.org>; Wed, 14 May 2014 12:12:52 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id c41so1531420eek.17
        for <linux-mm@kvack.org>; Wed, 14 May 2014 09:12:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id x44si2051504eeo.19.2014.05.14.09.12.49
        for <linux-mm@kvack.org>;
        Wed, 14 May 2014 09:12:51 -0700 (PDT)
Date: Wed, 14 May 2014 18:11:52 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
	waitqueue lookups in unlock_page fastpath
Message-ID: <20140514161152.GA2615@redhat.com>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de> <1399974350-11089-20-git-send-email-mgorman@suse.de> <20140513125313.GR23991@suse.de> <20140513141748.GD2485@laptop.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140513141748.GD2485@laptop.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

The subsequent discussion was "off-topic", and it seems that the patch
itself needs a bit more discussion,

On 05/13, Peter Zijlstra wrote:
>
> On Tue, May 13, 2014 at 01:53:13PM +0100, Mel Gorman wrote:
> > On Tue, May 13, 2014 at 10:45:50AM +0100, Mel Gorman wrote:
> > >  void unlock_page(struct page *page)
> > >  {
> > > +	wait_queue_head_t *wqh = clear_page_waiters(page);
> > > +
> > >  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> > > +
> > > +	/*
> > > +	 * No additional barrier needed due to clear_bit_unlock barriering all updates
> > > +	 * before waking waiters
> > > +	 */
> > >  	clear_bit_unlock(PG_locked, &page->flags);
> > > -	smp_mb__after_clear_bit();
> > > -	wake_up_page(page, PG_locked);
> >
> > This is wrong.

Yes,

> > The smp_mb__after_clear_bit() is still required to ensure
> > that the cleared bit is visible before the wakeup on all architectures.

But note that "the cleared bit is visible before the wakeup" is confusing.
I mean, we do not need mb() before __wake_up(). We need it only because
__wake_up_bit() checks waitqueue_active().


And at least

	fs/cachefiles/namei.c:cachefiles_delete_object()
	fs/block_dev.c:blkdev_get()
	kernel/signal.c:task_clear_jobctl_trapping()
	security/keys/gc.c:key_garbage_collector()

look obviously wrong.

I would be happy to send the fix, but do I need to split it per-file?
Given that it is trivial, perhaps I can send a single patch?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
