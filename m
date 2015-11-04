Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCDA82F64
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 18:39:11 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so42627240pac.3
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 15:39:11 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id c5si2988366pas.41.2015.11.04.15.39.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 15:39:10 -0800 (PST)
Date: Thu, 5 Nov 2015 08:39:10 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
Message-ID: <20151104233910.GA7357@bbox>
References: <1446600367-7976-1-git-send-email-minchan@kernel.org>
 <1446600367-7976-2-git-send-email-minchan@kernel.org>
 <20151104021624.GA2476@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151104021624.GA2476@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin.wang2010@gmail.com

Hi Sergey,

On Wed, Nov 04, 2015 at 11:16:24AM +0900, Sergey Senozhatsky wrote:
> Hi Minchan,
> 
> On (11/04/15 10:25), Minchan Kim wrote:
> [..]
> >+static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
> >+                               unsigned long end, struct mm_walk *walk)
> >+
> ...
> > +	if (pmd_trans_unstable(pmd))
> > +		return 0;
> 
> I think it makes sense to update pmd_trans_unstable() and
> pmd_none_or_trans_huge_or_clear_bad() comments in asm-generic/pgtable.h
> Because they explicitly mention MADV_DONTNEED only. Just a thought.

Hmm, When I read comments(but actually I don't understand it 100%), it
says pmd disappearing from MADV_DONTNEED with mmap_sem read-side
lock. But MADV_FREE doesn't remove the pmd. So, I don't understand
what I should add comment. Please suggest if I am missing something.

> 
> 
> > @@ -379,6 +502,14 @@ madvise_vma(struct vm_area_struct *vma, struct vm_area_struct **prev,
> >  		return madvise_remove(vma, prev, start, end);
> >  	case MADV_WILLNEED:
> >  		return madvise_willneed(vma, prev, start, end);
> > +	case MADV_FREE:
> > +		/*
> > +		 * XXX: In this implementation, MADV_FREE works like
> 		  ^^^^
> 		XXX

What does it mean?

> 
> > +		 * MADV_DONTNEED on swapless system or full swap.
> > +		 */
> > +		if (get_nr_swap_pages() > 0)
> > +			return madvise_free(vma, prev, start, end);
> > +		/* passthrough */
> 
> 	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
