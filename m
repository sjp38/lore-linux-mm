Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2516B0031
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 11:58:44 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id x13so7139668qcv.40
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 08:58:44 -0700 (PDT)
Received: from mail-qg0-x22f.google.com (mail-qg0-x22f.google.com [2607:f8b0:400d:c04::22f])
        by mx.google.com with ESMTPS id n9si5966442qcc.26.2014.06.30.08.58.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 08:58:43 -0700 (PDT)
Received: by mail-qg0-f47.google.com with SMTP id q108so2146167qgd.6
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 08:58:43 -0700 (PDT)
Date: Mon, 30 Jun 2014 11:58:39 -0400
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 2/6] mm: differentiate unmap for vmscan from other unmap.
Message-ID: <20140630155838.GD1956@gmail.com>
References: <1403920822-14488-1-git-send-email-j.glisse@gmail.com>
 <1403920822-14488-3-git-send-email-j.glisse@gmail.com>
 <alpine.DEB.2.10.1406292054080.21595@blueforge.nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.10.1406292054080.21595@blueforge.nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mgorman@suse.de, hpa@zytor.com, peterz@infraread.org, aarcange@redhat.com, riel@redhat.com, jweiner@redhat.com, torvalds@linux-foundation.org, Mark Hairgrove <mhairgrove@nvidia.com>, Jatin Kumar <jakumar@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Duncan Poole <dpoole@nvidia.com>, Oded Gabbay <Oded.Gabbay@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Andrew Lewycky <Andrew.Lewycky@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Sun, Jun 29, 2014 at 08:58:17PM -0700, John Hubbard wrote:
> On Fri, 27 Jun 2014, Jerome Glisse wrote:
> 
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > New code will need to be able to differentiate between a regular unmap and
> > an unmap trigger by vmscan in which case we want to be as quick as possible.
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > ---
> >  include/linux/rmap.h | 15 ++++++++-------
> >  mm/memory-failure.c  |  2 +-
> >  mm/vmscan.c          |  4 ++--
> >  3 files changed, 11 insertions(+), 10 deletions(-)
> > 
> > diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> > index be57450..eddbc07 100644
> > --- a/include/linux/rmap.h
> > +++ b/include/linux/rmap.h
> > @@ -72,13 +72,14 @@ struct anon_vma_chain {
> >  };
> >  
> >  enum ttu_flags {
> > -	TTU_UNMAP = 1,			/* unmap mode */
> > -	TTU_MIGRATION = 2,		/* migration mode */
> > -	TTU_MUNLOCK = 4,		/* munlock mode */
> > -
> > -	TTU_IGNORE_MLOCK = (1 << 8),	/* ignore mlock */
> > -	TTU_IGNORE_ACCESS = (1 << 9),	/* don't age */
> > -	TTU_IGNORE_HWPOISON = (1 << 10),/* corrupted page is recoverable */
> > +	TTU_VMSCAN = 1,			/* unmap for vmscan */
> > +	TTU_POISON = 2,			/* unmap for poison */
> > +	TTU_MIGRATION = 4,		/* migration mode */
> > +	TTU_MUNLOCK = 8,		/* munlock mode */
> > +
> > +	TTU_IGNORE_MLOCK = (1 << 9),	/* ignore mlock */
> > +	TTU_IGNORE_ACCESS = (1 << 10),	/* don't age */
> > +	TTU_IGNORE_HWPOISON = (1 << 11),/* corrupted page is recoverable */
> 
> Unless there is a deeper purpose that I am overlooking, I think it would 
> be better to leave the _MLOCK, _ACCESS, and _HWPOISON at their original 
> values. I just can't quite see why they would need to start at bit 9 
> instead of bit 8...

This code change to have various TTU_* be bitflag instead of value. I am
not sure what was the win in that, would need to dig up that patch that
did that. But in all the case i preserve that change here hence starting
at 9.
> 
> >  };
> >  
> >  #ifdef CONFIG_MMU
> > diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> > index a7a89eb..ba176c4 100644
> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -887,7 +887,7 @@ static int page_action(struct page_state *ps, struct page *p,
> >  static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
> >  				  int trapno, int flags, struct page **hpagep)
> >  {
> > -	enum ttu_flags ttu = TTU_UNMAP | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
> > +	enum ttu_flags ttu = TTU_POISON | TTU_IGNORE_MLOCK | TTU_IGNORE_ACCESS;
> >  	struct address_space *mapping;
> >  	LIST_HEAD(tokill);
> >  	int ret;
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 6d24fd6..5a7d286 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1163,7 +1163,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
> >  	}
> >  
> >  	ret = shrink_page_list(&clean_pages, zone, &sc,
> > -			TTU_UNMAP|TTU_IGNORE_ACCESS,
> > +			TTU_VMSCAN|TTU_IGNORE_ACCESS,
> >  			&dummy1, &dummy2, &dummy3, &dummy4, &dummy5, true);
> >  	list_splice(&clean_pages, page_list);
> >  	mod_zone_page_state(zone, NR_ISOLATED_FILE, -ret);
> > @@ -1518,7 +1518,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> >  	if (nr_taken == 0)
> >  		return 0;
> >  
> > -	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
> > +	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_VMSCAN,
> >  				&nr_dirty, &nr_unqueued_dirty, &nr_congested,
> >  				&nr_writeback, &nr_immediate,
> >  				false);
> > -- 
> > 1.9.0
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 
> 
> Other than that, looks good.
> 
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> 
> thanks,
> John H.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
