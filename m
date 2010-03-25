Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 396086B021D
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 21:23:31 -0400 (EDT)
Date: Thu, 25 Mar 2010 02:23:16 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [rfc 5/5] mincore: transparent huge page support
Message-ID: <20100325012316.GB27304@cmpxchg.org>
References: <1269354902-18975-1-git-send-email-hannes@cmpxchg.org> <1269354902-18975-6-git-send-email-hannes@cmpxchg.org> <20100324224858.GP10659@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100324224858.GP10659@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 24, 2010 at 11:48:58PM +0100, Andrea Arcangeli wrote:
> On Tue, Mar 23, 2010 at 03:35:02PM +0100, Johannes Weiner wrote:
> > +static int mincore_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
> > +			unsigned long addr, unsigned long end,
> > +			unsigned char *vec)
> > +{
> > +	int huge = 0;
> > +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> > +	spin_lock(&vma->vm_mm->page_table_lock);
> > +	if (likely(pmd_trans_huge(*pmd))) {
> > +		huge = !pmd_trans_splitting(*pmd);
> 
> Under mmap_sem (read or write) a hugepage can't materialize under
> us. So here the pmd_trans_huge can be lockless and run _before_ taking
> the page_table_lock. That's the invariant I used to keep identical
> performance for all fast paths.

Wait, there _is_ an unlocked fast-path pmd_trans_huge()
in mincore_pmd_range(), maybe you missed it?

This function is never called if the pmd is not huge.

So the above is the _second check_ under lock to get a stable
read on the entry that could be splitting or already have been
split while we checked locklessly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
