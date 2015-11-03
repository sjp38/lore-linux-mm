Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C0D3E6B0253
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 19:54:33 -0500 (EST)
Received: by pasz6 with SMTP id z6so1670679pas.2
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 16:54:33 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id cn3si38811279pad.43.2015.11.02.16.54.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Nov 2015 16:54:33 -0800 (PST)
Date: Tue, 3 Nov 2015 09:53:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/8] mm: free swp_entry in madvise_free
Message-ID: <20151103005317.GE17906@bbox>
References: <1446188504-28023-1-git-send-email-minchan@kernel.org>
 <1446188504-28023-5-git-send-email-minchan@kernel.org>
 <20151030122814.GA23627@dhcp22.suse.cz>
MIME-Version: 1.0
In-Reply-To: <20151030122814.GA23627@dhcp22.suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, zhangyanfei@cn.fujitsu.com, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, Daniel Micay <danielmicay@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, yalin.wang2010@gmail.com, Shaohua Li <shli@kernel.org>

On Fri, Oct 30, 2015 at 01:28:14PM +0100, Michal Hocko wrote:
> On Fri 30-10-15 16:01:40, Minchan Kim wrote:
> > When I test below piece of code with 12 processes(ie, 512M * 12 = 6G
> > consume) on my (3G ram + 12 cpu + 8G swap, the madvise_free is siginficat
> > slower (ie, 2x times) than madvise_dontneed.
> > 
> > loop = 5;
> > mmap(512M);
> > while (loop--) {
> >         memset(512M);
> >         madvise(MADV_FREE or MADV_DONTNEED);
> > }
> > 
> > The reason is lots of swapin.
> > 
> > 1) dontneed: 1,612 swapin
> > 2) madvfree: 879,585 swapin
> > 
> > If we find hinted pages were already swapped out when syscall is called,
> > it's pointless to keep the swapped-out pages in pte.
> > Instead, let's free the cold page because swapin is more expensive
> > than (alloc page + zeroing).
> > 
> > With this patch, it reduced swapin from 879,585 to 1,878 so elapsed time
> > 
> > 1) dontneed: 6.10user 233.50system 0:50.44elapsed
> > 2) madvfree: 6.03user 401.17system 1:30.67elapsed
> > 2) madvfree + below patch: 6.70user 339.14system 1:04.45elapsed
> > 
> > Acked-by: Hugh Dickins <hughd@google.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Yes this makes a lot of sense.
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks!

> 
> One nit below.
> 
> > ---
> >  mm/madvise.c | 26 +++++++++++++++++++++++++-
> >  1 file changed, 25 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 640311704e31..663bd9fa0ae0 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -270,6 +270,8 @@ static int madvise_free_pte_range(pmd_t *pmd, unsigned long addr,
> >  	spinlock_t *ptl;
> >  	pte_t *pte, ptent;
> >  	struct page *page;
> > +	swp_entry_t entry;
> 
> This could go into !pte_present if block

Sure, I fixed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
