Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id CFA836B0038
	for <linux-mm@kvack.org>; Wed, 14 May 2014 16:53:57 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id e51so79118eek.37
        for <linux-mm@kvack.org>; Wed, 14 May 2014 13:53:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v47si1085916een.27.2014.05.14.13.53.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 14 May 2014 13:53:56 -0700 (PDT)
Date: Wed, 14 May 2014 21:53:51 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 19/19] mm: filemap: Avoid unnecessary barries and
 waitqueue lookups in unlock_page fastpath
Message-ID: <20140514205351.GC23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140514161152.GA2615@redhat.com>
 <20140514192945.GA10830@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140514192945.GA10830@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>

On Wed, May 14, 2014 at 09:29:45PM +0200, Oleg Nesterov wrote:
> On 05/14, Oleg Nesterov wrote:
> >
> > The subsequent discussion was "off-topic", and it seems that the patch
> > itself needs a bit more discussion,
> >
> > On 05/13, Peter Zijlstra wrote:
> > >
> > > On Tue, May 13, 2014 at 01:53:13PM +0100, Mel Gorman wrote:
> > > > On Tue, May 13, 2014 at 10:45:50AM +0100, Mel Gorman wrote:
> > > > >  void unlock_page(struct page *page)
> > > > >  {
> > > > > +	wait_queue_head_t *wqh = clear_page_waiters(page);
> > > > > +
> > > > >  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> > > > > +
> > > > > +	/*
> > > > > +	 * No additional barrier needed due to clear_bit_unlock barriering all updates
> > > > > +	 * before waking waiters
> > > > > +	 */
> > > > >  	clear_bit_unlock(PG_locked, &page->flags);
> > > > > -	smp_mb__after_clear_bit();
> > > > > -	wake_up_page(page, PG_locked);
> > > >
> > > > This is wrong.
> >
> > Yes,
> >
> > > > The smp_mb__after_clear_bit() is still required to ensure
> > > > that the cleared bit is visible before the wakeup on all architectures.
> >
> > But note that "the cleared bit is visible before the wakeup" is confusing.
> > I mean, we do not need mb() before __wake_up(). We need it only because
> > __wake_up_bit() checks waitqueue_active().
> 
> OOPS. Sorry Mel, I wrote this looking at the chunk above.  But when I found
> the whole patch http://marc.info/?l=linux-mm&m=139997442008267 I see that
> it removes waitqueue_active(), so this can be correct. I do not really know,
> so far I can't say I fully understand this PageWaiters() trick.
> 

The intent is to use a page bit to determine if looking up the waitqueue is
worthwhile. However, it is currently race-prone and while barriers can be
used to reduce the race, I did not see how it could be eliminated without
using a lock which would defeat the purpose.

> Hmm. But at least prepare_to_wait_exclusive() doesn't look right ;)
> 
> If nothing else, this needs abort_exclusive_wait() if killed.

Yes, I'll fix that.

> And while
> "exclusive" is probably fine for __lock_page.*(), I am not sure that
> __wait_on_page_locked_*() should be exclusive.
> 

Indeed it shouldn't. Exclusive waits should only be if the lock is being
acquired. Thanks for pointing that out.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
