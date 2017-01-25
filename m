Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 78F946B0260
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 12:53:09 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id gt1so34494686wjc.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 09:53:09 -0800 (PST)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id z39si27766847wrz.96.2017.01.25.09.53.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 09:53:08 -0800 (PST)
Received: by mail-wm0-x243.google.com with SMTP id c85so44011493wmi.1
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 09:53:08 -0800 (PST)
Date: Wed, 25 Jan 2017 20:53:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 02/12] mm: introduce page_check_walk()
Message-ID: <20170125175305.GB4157@node>
References: <20170124162824.91275-1-kirill.shutemov@linux.intel.com>
 <20170124162824.91275-3-kirill.shutemov@linux.intel.com>
 <20170124134122.5560b55ca13c2c2cc09c2a4e@linux-foundation.org>
 <20170124225030.GC19920@node.shutemov.name>
 <20170124145513.1c0687179eceaac43523da56@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170124145513.1c0687179eceaac43523da56@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 24, 2017 at 02:55:13PM -0800, Andrew Morton wrote:
> On Wed, 25 Jan 2017 01:50:30 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > > > + * @pcw->ptl is unlocked and @pcw->pte is unmapped.
> > > > + *
> > > > + * If you need to stop the walk before page_check_walk() returned false, use
> > > > + * page_check_walk_done(). It will do the housekeeping.
> > > > + */
> > > > +static inline bool page_check_walk(struct page_check_walk *pcw)
> > > > +{
> > > > +	/* The only possible pmd mapping has been handled on last iteration */
> > > > +	if (pcw->pmd && !pcw->pte) {
> > > > +		page_check_walk_done(pcw);
> > > > +		return false;
> > > > +	}
> > > > +
> > > > +	/* Only for THP, seek to next pte entry makes sense */
> > > > +	if (pcw->pte) {
> > > > +		if (!PageTransHuge(pcw->page) || PageHuge(pcw->page)) {
> > > > +			page_check_walk_done(pcw);
> > > > +			return false;
> > > > +		}
> > > > +	}
> > > > +
> > > > +	return __page_check_walk(pcw);
> > > > +}
> > > 
> > > Was the decision to inline this a correct one?
> > 
> > Well, my logic was that in most cases we would have exactly one iteration.
> > The only case when we need more than one iteration is PTE-mapped THP which
> > is rare.
> > I hoped to avoid additional function call. Not sure if it worth it.
> > 
> > Should I move it inside the function?
> 
> I suggest building a kernel with it uninlined, take a look at the bloat
> factor then make a seat-of-the pants decision about "is it worth it". 
> With quite a few callsites the saving from uninlining may be
> significant.

add/remove: 1/2 grow/shrink: 8/0 up/down: 5089/-2954 (2135)
function                                     old     new   delta
__page_vma_mapped_walk                         -    2928   +2928
try_to_unmap_one                            2916    3218    +302
page_mkclean_one                             513     802    +289
__replace_page                              1439    1719    +280
page_referenced_one                          753    1030    +277
page_mapped_in_vma                           799    1059    +260
remove_migration_pte                        1129    1388    +259
page_idle_clear_pte_refs_one                 197     456    +259
write_protect_page                          1210    1445    +235
page_idle_clear_pte_refs_one.part             26       -     -26
page_vma_mapped_walk                        2928       -   -2928
Total: Before=37784555, After=37786690, chg +0.01%

I'll drop inlining. It would save ~2k.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
