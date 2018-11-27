Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22A0D6B49CD
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 13:11:06 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id p4so10449578pgj.21
        for <linux-mm@kvack.org>; Tue, 27 Nov 2018 10:11:06 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h70si4107648pge.221.2018.11.27.10.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 27 Nov 2018 10:11:04 -0800 (PST)
Date: Tue, 27 Nov 2018 10:10:51 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCHi v2] mm: put_and_wait_on_page_locked() while page is
 migrated
Message-ID: <20181127181051.GD10377@bombadil.infradead.org>
References: <alpine.LSU.2.11.1811241858540.4415@eggly.anvils>
 <CAHk-=wjeqKYevxGnfCM4UkxX8k8xfArzM6gKkG3BZg1jBYThVQ@mail.gmail.com>
 <alpine.LSU.2.11.1811251900300.1278@eggly.anvils>
 <alpine.LSU.2.11.1811261121330.1116@eggly.anvils>
 <20181127105848.GD16502@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181127105848.GD16502@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Baoquan He <bhe@redhat.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, David Herrmann <dh.herrmann@gmail.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kan Liang <kan.liang@intel.com>, Andi Kleen <ak@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux.com>, Nick Piggin <npiggin@gmail.com>, pifang@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Nov 27, 2018 at 12:58:48PM +0200, Mike Rapoport wrote:
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index 81adec8ee02c..575e16c037ca 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -1049,25 +1056,44 @@ static void wake_up_page(struct page *page, int bit)
> >  	wake_up_page_bit(page, bit);
> >  }
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

The enum isn't used outside mm/filemap.c, so I'm not entirely sure that
including kernel-doc for it is a good idea.
