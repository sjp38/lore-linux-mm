Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1AC6B0398
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 01:40:42 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 67so42781447pfg.0
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 22:40:42 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id m14si2314376pln.225.2017.03.07.22.40.40
        for <linux-mm@kvack.org>;
        Tue, 07 Mar 2017 22:40:41 -0800 (PST)
Date: Wed, 8 Mar 2017 15:40:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 04/11] mm: remove SWAP_MLOCK check for SWAP_SUCCESS in ttu
Message-ID: <20170308064038.GF11206@bbox>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-5-git-send-email-minchan@kernel.org>
 <20170307142643.GD2779@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307142643.GD2779@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On Tue, Mar 07, 2017 at 05:26:43PM +0300, Kirill A. Shutemov wrote:
> On Thu, Mar 02, 2017 at 03:39:18PM +0900, Minchan Kim wrote:
> > If the page is mapped and rescue in ttuo, page_mapcount(page) == 0 cannot
> > be true so page_mapcount check in ttu is enough to return SWAP_SUCCESS.
> > IOW, SWAP_MLOCK check is redundant so remove it.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/rmap.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 3a14013..0a48958 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1523,7 +1523,7 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
> >  	else
> >  		ret = rmap_walk(page, &rwc);
> >  
> > -	if (ret != SWAP_MLOCK && !page_mapcount(page))
> > +	if (!page_mapcount(page))
> 
> Hm. I think there's bug in current code.
> It should be !total_mapcount(page) otherwise it can be false-positive if
> there's THP mapped with PTEs.

Hmm, I lost THP thesedays totally so I can miss something easily.
When I look at that, it seems every pages passed try_to_unmap is already
splited by split split_huge_page_to_list which calls freeze_page which
split pmd. So I guess it's no problem. Right?

Anyway, it's out of scope in this patch so if it's really problem,
I'd like to handle it separately.

One asking:

When we should use total_mapcount instead of page_mapcount?
If total_mapcount has some lengthy description, it would be very helpful
for one who not is faimilar with that.

> 
> And in this case ret != SWAP_MLOCK is helpful to cut down some cost.
> Althouth it should be fine to remove it, I guess.

Sure but be hard to measure it, I think. As well, later patch removes
SWAP_MLOCK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
