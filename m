Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 73E4B6B004D
	for <linux-mm@kvack.org>; Fri, 23 Oct 2009 17:50:14 -0400 (EDT)
Date: Fri, 23 Oct 2009 15:12:04 -0700 (PDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: Re: [PATCH 3/5] vmscan: Force kswapd to take notice faster when
 high-order watermarks are being hit
In-Reply-To: <alpine.DEB.1.00.0910231042090.22373@mail.selltech.ca>
Message-ID: <alpine.DEB.1.00.0910231507090.22860@mail.selltech.ca>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-4-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.00.0910231042090.22373@mail.selltech.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: "linux-mm@kvack.org\"" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Fri, 23 Oct 2009, Vincent Li wrote:

> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > ---
> >  mm/vmscan.c |    9 +++++++++
> >  1 files changed, 9 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 64e4388..cd68109 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2016,6 +2016,15 @@ loop_again:
> >  					priority != DEF_PRIORITY)
> >  				continue;
> >  
> > +			/*
> > +			 * Exit quickly to restart if it has been indicated
>                            ^^^^^^^^^^^^^^^^^^^^^^^ meaning exit to 
> lable loop_again in balance_pgdat ?

I took a second look, it seems you are refering to restart: in 
__alloc_pages_slowpath in page_alloc.c

> 
> > +			 * that higher orders are required
> > +			 */
> > +			if (pgdat->kswapd_max_order > order) {
> > +				all_zones_ok = 1;
> > +				goto out;
> > +			}
> 
> If exit quickly to loop_again, shouldn't all_zones_ok be 0 instead of 1?

all_zones_ok should be 1. Sorry for the noise.

Vincent

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
