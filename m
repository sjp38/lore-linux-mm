Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 4578C6B0035
	for <linux-mm@kvack.org>; Mon, 12 May 2014 17:01:19 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kq14so5165278pab.33
        for <linux-mm@kvack.org>; Mon, 12 May 2014 14:01:18 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id dh1si6903492pbc.112.2014.05.12.14.01.17
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 14:01:18 -0700 (PDT)
Date: Mon, 12 May 2014 14:01:07 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] HWPOSION, hugetlb: lock_page/unlock_page does not match
 for handling a free hugepage
Message-ID: <20140512210107.GX19657@tassilo.jf.intel.com>
References: <1399691674.29028.1.camel@cyc>
 <1399926246-nyqrlpg9@n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399926246-nyqrlpg9@n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: slaoub@gmail.com, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, May 12, 2014 at 04:24:07PM -0400, Naoya Horiguchi wrote:
> (Cced: Andrew)
> 
> On Sat, May 10, 2014 at 11:14:34AM +0800, Chen Yucong wrote:
> > For handling a free hugepage in memory failure, the race will happen if
> > another thread hwpoisoned this hugepage concurrently. So we need to
> > check PageHWPoison instead of !PageHWPoison.
> > 
> > If hwpoison_filter(p) returns true or a race happens, then we need to
> > unlock_page(hpage).
> > 
> > Signed-off-by: Chen Yucong <slaoub@gmail.com>
> > Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> I tested this patch on latest linux-next, and confirmed that memory error
> on a tail page of a free hugepage is properly handled.

Patch looks good to me too.

Reviewed-by: Andi Kleen <ak@linux.intel.com> 

-Andi
> 
> Tested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> And I think this patch should go into all recent stable trees, since this
> bug exists since 2.6.36 (because of my patch, sorry.)
> 
> > ---
> > mm/memory-failure.c |   15 ++++++++-------
> > 1 file changed, 8 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> > index 35ef28a..dbf8922 100644
> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -1081,15 +1081,16 @@ int memory_failure(unsigned long pfn, int
> > trapno, int flags)
> 
> This linebreak breaks patch format. I guess it's done by your email
> client or copy and paste. If it's true, git-send-email might be helpful
> to avoid such errors.
> 
> Thanks,
> Naoya
> 
> 
> >  			return 0;
> >  		} else if (PageHuge(hpage)) {
> >  			/*
> > -			 * Check "just unpoisoned", "filter hit", and
> > -			 * "race with other subpage."
> > +			 * Check "filter hit" and "race with other subpage."
> >  			 */
> >  			lock_page(hpage);
> > -			if (!PageHWPoison(hpage)
> > -			    || (hwpoison_filter(p) && TestClearPageHWPoison(p))
> > -			    || (p != hpage && TestSetPageHWPoison(hpage))) {
> > -				atomic_long_sub(nr_pages, &num_poisoned_pages);
> > -				return 0;
> > +			if (PageHWPoison(hpage)) {
> > +				if ((hwpoison_filter(p) && TestClearPageHWPoison(p))
> > +				    || (p != hpage && TestSetPageHWPoison(hpage))) {
> > +					atomic_long_sub(nr_pages, &num_poisoned_pages);
> > +					unlock_page(hpage);
> > +					return 0;
> > +				}
> >  			}
> >  			set_page_hwpoison_huge_page(hpage);
> >  			res = dequeue_hwpoisoned_huge_page(hpage);
> > -- 
> > 1.7.10.4
> > 
> > 
> > 
> > 
> > 
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
