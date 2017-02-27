Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 01AB26B038B
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 11:33:46 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u63so40044231wmu.0
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 08:33:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e28si18645728wra.151.2017.02.27.08.28.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 08:28:06 -0800 (PST)
Date: Mon, 27 Feb 2017 17:28:03 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V5 2/6] mm: don't assume anonymous pages have SwapBacked
 flag
Message-ID: <20170227162803.GL26504@dhcp22.suse.cz>
References: <cover.1487965799.git.shli@fb.com>
 <3945232c0df3dd6c4ef001976f35a95f18dcb407.1487965799.git.shli@fb.com>
 <20170227143534.GE26504@dhcp22.suse.cz>
 <20170227161022.GA62304@shli-mbp.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170227161022.GA62304@shli-mbp.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Mon 27-02-17 08:10:24, Shaohua Li wrote:
> On Mon, Feb 27, 2017 at 03:35:34PM +0100, Michal Hocko wrote:
> > On Fri 24-02-17 13:31:45, Shaohua Li wrote:
> > > There are a few places the code assumes anonymous pages should have
> > > SwapBacked flag set. MADV_FREE pages are anonymous pages but we are
> > > going to add them to LRU_INACTIVE_FILE list and clear SwapBacked flag
> > > for them. The assumption doesn't hold any more, so fix them.
> > > 
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: Minchan Kim <minchan@kernel.org>
> > > Cc: Hugh Dickins <hughd@google.com>
> > > Cc: Rik van Riel <riel@redhat.com>
> > > Cc: Mel Gorman <mgorman@techsingularity.net>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > > Signed-off-by: Shaohua Li <shli@fb.com>

Anyway, feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

> > 
> > Looks good to me.
> > [...]
> > > index 96eb85c..c621088 100644
> > > --- a/mm/rmap.c
> > > +++ b/mm/rmap.c
> > > @@ -1416,7 +1416,8 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> > >  			 * Store the swap location in the pte.
> > >  			 * See handle_pte_fault() ...
> > >  			 */
> > > -			VM_BUG_ON_PAGE(!PageSwapCache(page), page);
> > > +			VM_BUG_ON_PAGE(!PageSwapCache(page) && PageSwapBacked(page),
> > > +				page);
> > 
> > just this part makes me scratch my head. I really do not understand what
> > kind of problem it tries to prevent from, maybe I am missing something
> > obvoious...
> 
> Just check a page which isn't lazyfree but wrongly enters here without swap
> entry. Or maybe you suggest we delete this statement?

Ohh, I figured out when seeing later patch in the series, I then wanted
to get back to this one but forgot... This on its own didn't really tell
me much. Maybe a comment would be helpful or even drop the VM_BUG_ON
altogether.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
