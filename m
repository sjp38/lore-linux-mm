Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 76DF06B0005
	for <linux-mm@kvack.org>; Sun, 17 Mar 2013 11:19:21 -0400 (EDT)
Date: Sun, 17 Mar 2013 15:19:17 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 07/10] mm: vmscan: Block kswapd if it is encountering
 pages under writeback
Message-ID: <20130317151917.GD2026@suse.de>
References: <1363525456-10448-1-git-send-email-mgorman@suse.de>
 <1363525456-10448-8-git-send-email-mgorman@suse.de>
 <m21ubejd2p.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <m21ubejd2p.fsf@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Linux-MM <linux-mm@kvack.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Sun, Mar 17, 2013 at 07:49:50AM -0700, Andi Kleen wrote:
> Mel Gorman <mgorman@suse.de> writes:
> 
> 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 493728b..7d5a932 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -725,6 +725,19 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  
> >  		if (PageWriteback(page)) {
> >  			/*
> > +			 * If reclaim is encountering an excessive number of
> > +			 * pages under writeback and this page is both under
> > +			 * writeback and PageReclaim then it indicates that
> > +			 * pages are being queued for IO but are being
> > +			 * recycled through the LRU before the IO can complete.
> > +			 * is useless CPU work so wait on the IO to complete.
> > +			 */
> > +			if (current_is_kswapd() &&
> > +			    zone_is_reclaim_writeback(zone)) {
> > +				wait_on_page_writeback(page);
> > +				zone_clear_flag(zone, ZONE_WRITEBACK);
> > +
> > +			/*
> 
> Something is wrong with the indentation here. Comment should be indented
> or is the code in the wrong block?
> 

I'll rearrange the comments.

> It's not fully clair to me how you decide here that the writeback
> situation has cleared. There must be some kind of threshold for it,
> but I don't see it. Or do you clear already when the first page
> finished? That would seem too early.
> 

I deliberately cleared it when the first page finished.  If kswapd blocks
waiting for IO of that page to complete then it cannot be certain that
there are still too many pages at the end of the LRU. By clearing the
flag, it's forced to recheck instead of potentially blocking on the next
page unnecessarily.

What I did get wrong is that I meant to check PageReclaim here as
described in the comment. It must have gotten lost during a rebase.

> BTW longer term the code would probably be a lot clearer with a
> real explicit state machine instead of all these custom state bits.
> 

I would expect so even though it'd be a major overhawl.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
