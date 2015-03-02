Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id B21596B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 07:33:32 -0500 (EST)
Received: by wivr20 with SMTP id r20so14416012wiv.2
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 04:33:32 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h3si22002359wjw.176.2015.03.02.04.33.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Mar 2015 04:33:30 -0800 (PST)
Date: Mon, 2 Mar 2015 13:33:28 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] mm: change mm_advise_free to clear page dirty
Message-ID: <20150302123328.GB26334@dhcp22.suse.cz>
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
Cc: 'Minchan Kim' <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Shaohua Li <shli@kernel.org>

On Sat 28-02-15 10:11:13, Wang, Yalin wrote:
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
> but for file private map, there are also AnonPage sometimes,

AFAIR MADV_FREE was intended only for private anon mappings. What would
be the use case for MADV_FREE on file backed private mappings?

[...]

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
