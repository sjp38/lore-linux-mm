Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id F15FF6B0388
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 11:11:10 -0500 (EST)
Received: by mail-qk0-f197.google.com with SMTP id s186so138699130qkb.5
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 08:11:10 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k49si12141407qtc.21.2017.02.27.08.11.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 08:11:10 -0800 (PST)
Date: Mon, 27 Feb 2017 08:10:24 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V5 2/6] mm: don't assume anonymous pages have SwapBacked
 flag
Message-ID: <20170227161022.GA62304@shli-mbp.local>
References: <cover.1487965799.git.shli@fb.com>
 <3945232c0df3dd6c4ef001976f35a95f18dcb407.1487965799.git.shli@fb.com>
 <20170227143534.GE26504@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170227143534.GE26504@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Mon, Feb 27, 2017 at 03:35:34PM +0100, Michal Hocko wrote:
> On Fri 24-02-17 13:31:45, Shaohua Li wrote:
> > There are a few places the code assumes anonymous pages should have
> > SwapBacked flag set. MADV_FREE pages are anonymous pages but we are
> > going to add them to LRU_INACTIVE_FILE list and clear SwapBacked flag
> > for them. The assumption doesn't hold any more, so fix them.
> > 
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> 
> Looks good to me.
> [...]
> > index 96eb85c..c621088 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1416,7 +1416,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >  			 * Store the swap location in the pte.
> >  			 * See handle_pte_fault() ...
> >  			 */
> > -			VM_BUG_ON_PAGE(!PageSwapCache(page), page);
> > +			VM_BUG_ON_PAGE(!PageSwapCache(page) && PageSwapBacked(page),
> > +				page);
> 
> just this part makes me scratch my head. I really do not understand what
> kind of problem it tries to prevent from, maybe I am missing something
> obvoious...

Just check a page which isn't lazyfree but wrongly enters here without swap
entry. Or maybe you suggest we delete this statement?

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
