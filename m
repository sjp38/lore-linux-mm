Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EC92C6B0038
	for <linux-mm@kvack.org>; Fri, 31 Mar 2017 10:49:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id y67so47244wmd.13
        for <linux-mm@kvack.org>; Fri, 31 Mar 2017 07:49:59 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id h3si8477866wrh.199.2017.03.31.07.49.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Mar 2017 07:49:58 -0700 (PDT)
Date: Fri, 31 Mar 2017 10:49:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v7 9/9] mm, THP, swap: Delay splitting THP during
 swap out
Message-ID: <20170331144948.GA6408@cmpxchg.org>
References: <20170328053209.25876-1-ying.huang@intel.com>
 <20170328053209.25876-10-ying.huang@intel.com>
 <20170329171654.GD31821@cmpxchg.org>
 <871stftn72.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871stftn72.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Mar 30, 2017 at 12:15:13PM +0800, Huang, Ying wrote:
> Johannes Weiner <hannes@cmpxchg.org> writes:
> > On Tue, Mar 28, 2017 at 01:32:09PM +0800, Huang, Ying wrote:
> >> @@ -198,6 +240,18 @@ int add_to_swap(struct page *page, struct list_head *list)
> >>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> >>  	VM_BUG_ON_PAGE(!PageUptodate(page), page);
> >>  
> >> +	if (unlikely(PageTransHuge(page))) {
> >> +		err = add_to_swap_trans_huge(page, list);
> >> +		switch (err) {
> >> +		case 1:
> >> +			return 1;
> >> +		case 0:
> >> +			/* fallback to split firstly if return 0 */
> >> +			break;
> >> +		default:
> >> +			return 0;
> >> +		}
> >> +	}
> >>  	entry = get_swap_page();
> >>  	if (!entry.val)
> >>  		return 0;
> >
> > add_to_swap_trans_huge() is too close a copy of add_to_swap(), which
> > makes the code error prone for future modifications to the swap slot
> > allocation protocol.
> >
> > This should read:
> >
> > retry:
> > 	entry = get_swap_page(page);
> > 	if (!entry.val) {
> > 		if (PageTransHuge(page)) {
> > 			split_huge_page_to_list(page, list);
> > 			goto retry;
> > 		}
> > 		return 0;
> > 	}
> 
> If the swap space is used up, that is, get_swap_page() cannot allocate
> even 1 swap entry for a normal page.  We will split THP unnecessarily
> with the change, but in the original code, we just skip the THP.  There
> may be a performance regression here.  Similar problem exists for
> mem_cgroup_try_charge_swap() too.  If the mem cgroup exceeds the swap
> limit, the THP will be split unnecessary with the change too.

If we skip the page, we're swapping out another page hotter than this
one. Giving THP preservation priority over LRU order is an issue best
kept for a separate patch set; this one is supposed to be a mechanical
implementation of THP swapping. Let's nail down the basics first.

Such a decision would need proof that splitting THPs on full swap
devices is a concern for real applications. I would assume that we're
pretty close to OOM anyway; it's much more likely that a single slot
frees up than a full cluster, at which point we'll be splitting THPs
anyway; etc. I have my doubts that this would be measurable.

But even if so, I don't think we'd have to duplicate the main code
flow to handle this corner case. You can extend get_swap_page() to
return an error code that tells add_to_swap() whether to split and
retry, or to fail and move on. So this way should be future proof.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
