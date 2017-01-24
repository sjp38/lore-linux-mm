Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A75906B026F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 17:55:16 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 204so254236816pge.5
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 14:55:16 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 188si21009943pgd.181.2017.01.24.14.55.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 14:55:14 -0800 (PST)
Date: Tue, 24 Jan 2017 14:55:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 02/12] mm: introduce page_check_walk()
Message-Id: <20170124145513.1c0687179eceaac43523da56@linux-foundation.org>
In-Reply-To: <20170124225030.GC19920@node.shutemov.name>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
	<20170124162824.91275-3-kirill.shutemov@linux.intel.com>
	<20170124134122.5560b55ca13c2c2cc09c2a4e@linux-foundation.org>
	<20170124225030.GC19920@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 25 Jan 2017 01:50:30 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> > > + * @pcw->ptl is unlocked and @pcw->pte is unmapped.
> > > + *
> > > + * If you need to stop the walk before page_check_walk() returned false, use
> > > + * page_check_walk_done(). It will do the housekeeping.
> > > + */
> > > +static inline bool page_check_walk(struct page_check_walk *pcw)
> > > +{
> > > +	/* The only possible pmd mapping has been handled on last iteration */
> > > +	if (pcw->pmd && !pcw->pte) {
> > > +		page_check_walk_done(pcw);
> > > +		return false;
> > > +	}
> > > +
> > > +	/* Only for THP, seek to next pte entry makes sense */
> > > +	if (pcw->pte) {
> > > +		if (!PageTransHuge(pcw->page) || PageHuge(pcw->page)) {
> > > +			page_check_walk_done(pcw);
> > > +			return false;
> > > +		}
> > > +	}
> > > +
> > > +	return __page_check_walk(pcw);
> > > +}
> > 
> > Was the decision to inline this a correct one?
> 
> Well, my logic was that in most cases we would have exactly one iteration.
> The only case when we need more than one iteration is PTE-mapped THP which
> is rare.
> I hoped to avoid additional function call. Not sure if it worth it.
> 
> Should I move it inside the function?

I suggest building a kernel with it uninlined, take a look at the bloat
factor then make a seat-of-the pants decision about "is it worth it". 
With quite a few callsites the saving from uninlining may be
significant.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
