Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id BE2016B005A
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 08:24:33 -0400 (EDT)
Date: Tue, 9 Jun 2009 14:00:58 +0100
From: Andy Whitcroft <apw@canonical.com>
Subject: Re: [BUGFIX][PATCH] fix wrong lru rotate back at lumpty reclaim
Message-ID: <20090609130058.GA25007@shadowen.org>
References: <20090609181505.4083a213.kamezawa.hiroyu@jp.fujitsu.com> <28c262360906090300s13f4ee09mcc9622c1e477eaad@mail.gmail.com> <e8f208a7c6bec1818947c24658dc1561.squirrel@webmail-b.css.fujitsu.com> <28c262360906090430p21125c51g10cfdc377a78d07b@mail.gmail.com> <7ca0521d9b798ef8b56212e5b17ea713.squirrel@webmail-b.css.fujitsu.com> <28c262360906090507u75f5b594o71906777a91efa1@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360906090507u75f5b594o71906777a91efa1@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, Jun 09, 2009 at 09:07:16PM +0900, Minchan Kim wrote:
> 2009/6/9 KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>:
> > Minchan Kim wrote:
> >
> >> I mean follow as
> >>  908         /*
> >>  909          * Attempt to take all pages in the order aligned region
> >>  910          * surrounding the tag page.  Only take those pages of
> >>  911          * the same active state as that tag page.  We may safely
> >>  912          * round the target page pfn down to the requested order
> >>  913          * as the mem_map is guarenteed valid out to MAX_ORDER,
> >>  914          * where that page is in a different zone we will detect
> >>  915          * it from its zone id and abort this block scan.
> >>  916          */
> >>  917         zone_id = page_zone_id(page);
> >>
> > But what this code really do is.
> > ==
> > 931                         /* Check that we have not crossed a zone
> > boundary. */
> >  932                         if (unlikely(page_zone_id(cursor_page) !=
> > zone_id))
> >  933                                 continue;
> > ==
> > continue. I think this should be "break"
> > I wonder what "This block scan" means is "scanning this aligned block".
> 
> It is to find first page in same zone with target page when we have
> crossed a zone.
> so it shouldn't stop due to that.
> 
> I think 'abort' means stopping only the page.
> If it is right, it would be better to change follow as.
> "and continue scanning next page"
> 
> Let's Cced Andy Whitcroft.
> 
> > But I think the whoe code is not written as commented.
> >
> >>
> >>>> If I understand it properly , don't we add goto phrase ?
> >>>>
> >>> No.
> >>
> >> If it is so, the break also is meaningless.
> >>
> > yes. I'll remove it. But need to add "exit from for loop" logic again.
> >
> > I'm sorry that the wrong logic of this loop was out of my sight.
> > I'll review and rewrite this part all, tomorrow.
> 
> Yes. I will review tomorrow, too. :)

The comment is not the best wording.  The point here is that we need to
round down in order to safely scan the free blocks as they are only
marked at the start.  In rounding down however we may move back into the
previous zone as zones are not necessarily MAX_ORDER aligned.  We want
to ignore the bit before our zone starts and that check moves us on to
the next page.  It should be noted that this occurs rarely, ie. only
when we touch the start of a zone and only then where the zone
boundaries are not MAX_ORDER aligned.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
