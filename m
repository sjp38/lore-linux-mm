Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF2D6B0073
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 08:56:04 -0500 (EST)
Received: by pdev10 with SMTP id v10so27804621pde.10
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 05:56:03 -0800 (PST)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id ff2si6463006pab.111.2015.02.28.05.56.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 28 Feb 2015 05:56:03 -0800 (PST)
Received: by pablf10 with SMTP id lf10so30223792pab.6
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 05:56:03 -0800 (PST)
Date: Sat, 28 Feb 2015 22:55:55 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm: change mm_advise_free to clear page dirty
Message-ID: <20150228135555.GB25311@blaptop>
References: <1424765897-27377-1-git-send-email-minchan@kernel.org>
 <20150224154318.GA14939@dhcp22.suse.cz>
 <20150225000809.GA6468@blaptop>
 <35FD53F367049845BC99AC72306C23D10458D6173BDC@CNBJMBX05.corpusers.net>
 <20150227210233.GA29002@dhcp22.suse.cz>
 <35FD53F367049845BC99AC72306C23D10458D6173BE0@CNBJMBX05.corpusers.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <35FD53F367049845BC99AC72306C23D10458D6173BE0@CNBJMBX05.corpusers.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Cc: 'Michal Hocko' <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>

On Sat, Feb 28, 2015 at 10:11:13AM +0800, Wang, Yalin wrote:
> > -----Original Message-----
> > From: Michal Hocko [mailto:mstsxfx@gmail.com] On Behalf Of Michal Hocko
> > Sent: Saturday, February 28, 2015 5:03 AM
> > To: Wang, Yalin
> > Cc: 'Minchan Kim'; Andrew Morton; linux-kernel@vger.kernel.org; linux-
> > mm@kvack.org; Rik van Riel; Johannes Weiner; Mel Gorman; Shaohua Li
> > Subject: Re: [RFC] mm: change mm_advise_free to clear page dirty
> > 
> > On Fri 27-02-15 11:37:18, Wang, Yalin wrote:
> > > This patch add ClearPageDirty() to clear AnonPage dirty flag,
> > > the Anonpage mapcount must be 1, so that this page is only used by
> > > the current process, not shared by other process like fork().
> > > if not clear page dirty for this anon page, the page will never be
> > > treated as freeable.
> > 
> > Very well spotted! I haven't noticed that during the review.
> > 
> > > Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
> > > ---
> > >  mm/madvise.c | 15 +++++----------
> > >  1 file changed, 5 insertions(+), 10 deletions(-)
> > >
> > > diff --git a/mm/madvise.c b/mm/madvise.c
> > > index 6d0fcb8..257925a 100644
> > > --- a/mm/madvise.c
> > > +++ b/mm/madvise.c
> > > @@ -297,22 +297,17 @@ static int madvise_free_pte_range(pmd_t *pmd,
> > unsigned long addr,
> > >  			continue;
> > >
> > >  		page = vm_normal_page(vma, addr, ptent);
> > > -		if (!page)
> > > +		if (!page || !PageAnon(page) || !trylock_page(page))
> > >  			continue;
> > 
> > PageAnon check seems to be redundant because we are not allowing
> > MADV_FREE on any !anon private mappings AFAIR.
> I only see this check:
> /* MADV_FREE works for only anon vma at the moment */
> 	if (vma->vm_file)
> 		return -EINVAL;
> 
> but for file private map, there are also AnonPage sometimes, do we need change
> to like this:
> 	if (vma->vm_flags & VM_SHARED)
> 		return -EINVAL;

I couldn't understand your point. In this stage, we intentionally
disabled madvise_free on file mapped area(AFAIRC, some guys tried
it long time ago but it had many issues so dropped).
So, how can file-private mmaped can reach this code?
Could you elaborate it more about that why we need PageAnon check
in here?


> > >
> > >  		if (PageSwapCache(page)) {
> > > -			if (!trylock_page(page))
> > > +			if (!try_to_free_swap(page))
> > >  				continue;
> > 
> > You need to unlock the page here.
> Good spot.
> 
> > > -
> > > -			if (!try_to_free_swap(page)) {
> > > -				unlock_page(page);
> > > -				continue;
> > > -			}
> > > -
> > > -			ClearPageDirty(page);
> > > -			unlock_page(page);
> > >  		}
> > >
> > > +		if (page_mapcount(page) == 1)
> > > +			ClearPageDirty(page);
> > 
> > Please add a comment about why we need to ClearPageDirty even
> > !PageSwapCache. Anon pages are usually not marked dirty AFAIR. The
> > reason seem to be racing try_to_free_swap which sets the page that way
> > (although I do not seem to remember why are we doing that in the first
> > place...)
> > 
> Use page_mapcount to judge if a page can be clear dirty flag seems
> Not a very good solution, that is because we don't know how many
> ptes are share this page, I am thinking if there is some good solution
> For shared AnonPage.
> 

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
