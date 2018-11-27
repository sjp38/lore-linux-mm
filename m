Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 99ABF6B4A89
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 16:09:06 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id o9so10729166pgv.19
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 13:09:06 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y2sor6553924pgp.16.2018.11.27.13.09.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Nov 2018 13:09:05 -0800 (PST)
Date: Tue, 27 Nov 2018 13:08:50 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHi v2] mm: put_and_wait_on_page_locked() while page is
 migrated
In-Reply-To: <20181127105848.GD16502@rapoport-lnx>
Message-ID: <alpine.LSU.2.11.1811271258070.4506@eggly.anvils>
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils> <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com> <alpine.LSU.2.11.1811251900300.1278@eggly.anvils> <alpine.LSU.2.11.1811261121330.1116@eggly.anvils>
 <20181127105848.GD16502@rapoport-lnx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Matthew Wilcox <willy@infradead.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Herrmann <dh.herrmann@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 27 Nov 2018, Mike Rapoport wrote:
> On Mon, Nov 26, 2018 at 11:27:07AM -0800, Hugh Dickins wrote:
> > 
> > +/*
> > + * A choice of three behaviors for wait_on_page_bit_common():
> > + */
> > +enum behavior {
> > +	EXCLUSIVE,	/* Hold ref to page and take the bit when woken, like
> > +			 * __lock_page() waiting on then setting PG_locked.
> > +			 */
> > +	SHARED,		/* Hold ref to page and check the bit when woken, like
> > +			 * wait_on_page_writeback() waiting on PG_writeback.
> > +			 */
> > +	DROP,		/* Drop ref to page before wait, no check when woken,
> > +			 * like put_and_wait_on_page_locked() on PG_locked.
> > +			 */
> > +};
> 
> Can we please make it:
> 
> /**
>  * enum behavior - a choice of three behaviors for wait_on_page_bit_common()
>  */
> enum behavior {
> 	/**
> 	 * @EXCLUSIVE: Hold ref to page and take the bit when woken,
> 	 * like __lock_page() waiting on then setting %PG_locked.
> 	 */
> 	EXCLUSIVE,
> 	/**
> 	 * @SHARED: Hold ref to page and check the bit when woken,
> 	 * like wait_on_page_writeback() waiting on %PG_writeback.
> 	 */
> 	SHARED,
> 	/**
> 	 * @DROP: Drop ref to page before wait, no check when woken,
> 	 * like put_and_wait_on_page_locked() on %PG_locked.
> 	 */
> 	DROP,
> };

I'm with Matthew, I'd prefer not: the first looks a more readable,
less cluttered comment to me than the second: this is just an arg
to an internal helper in mm/filemap.c, itself not kernel-doc'ed.

But the comment is not there for me: if consensus is that the
second is preferable, then sure, we can change it over.

Hugh
