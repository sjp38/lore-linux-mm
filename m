Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id DA8746B0267
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 10:36:18 -0500 (EST)
Received: by wmww144 with SMTP id w144so33598054wmw.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 07:36:18 -0800 (PST)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id m186si6235301wmd.46.2015.11.13.07.36.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Nov 2015 07:36:17 -0800 (PST)
Received: by wmec201 with SMTP id c201so35818251wme.1
        for <linux-mm@kvack.org>; Fri, 13 Nov 2015 07:36:17 -0800 (PST)
Date: Fri, 13 Nov 2015 16:36:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: change may_enter_fs check condition
Message-ID: <20151113153615.GE2632@dhcp22.suse.cz>
References: <1447415255-832-1-git-send-email-yalin.wang2010@gmail.com>
 <5645D10C.701@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5645D10C.701@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yalin wang <yalin.wang2010@gmail.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, akpm@linux-foundation.org, vdavydov@parallels.com, hannes@cmpxchg.org, mgorman@techsingularity.net, tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 13-11-15 13:01:16, Vlastimil Babka wrote:
> On 11/13/2015 12:47 PM, yalin wang wrote:
> >Add page_is_file_cache() for __GFP_FS check,
> >otherwise, a Pageswapcache() && PageDirty() page can always be write
> >back if the gfp flag is __GFP_FS, this is not the expected behavior.
> 
> I'm not sure I understand your point correctly *), but you seem to imply
> that there would be an allocation that has __GFP_FS but doesn't have
> __GFP_IO? Are there such allocations and does it make sense?

No it doesn't. There is a natural layering here and __GFP_FS allocations
should contain __GFP_IO.

The patch as is makes only little sense to me. Are you seeing any issue
which this is trying to fix?

> *) It helps to state which problem you actually observed and are trying to
> fix. Or was this found by code inspection? In that case describe the
> theoretical problem, as "expected behavior" isn't always understood by
> everyone the same.
> 
> >Signed-off-by: yalin wang <yalin.wang2010@gmail.com>
> >---
> >  mm/vmscan.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> >diff --git a/mm/vmscan.c b/mm/vmscan.c
> >index bd2918e..f8fc8c1 100644
> >--- a/mm/vmscan.c
> >+++ b/mm/vmscan.c
> >@@ -930,7 +930,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  		if (page_mapped(page) || PageSwapCache(page))
> >  			sc->nr_scanned++;
> >
> >-		may_enter_fs = (sc->gfp_mask & __GFP_FS) ||
> >+		may_enter_fs = (page_is_file_cache(page) && (sc->gfp_mask & __GFP_FS)) ||
> >  			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
> >
> >  		/*
> >

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
