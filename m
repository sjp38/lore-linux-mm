Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BCECA6B0047
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 09:44:28 -0500 (EST)
Received: by bwz19 with SMTP id 19so3010297bwz.6
        for <linux-mm@kvack.org>; Tue, 23 Feb 2010 06:44:26 -0800 (PST)
Subject: Re: [patch 1/3] vmscan: factor out page reference checks
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100223142158.GA29762@cmpxchg.org>
References: <1266868150-25984-1-git-send-email-hannes@cmpxchg.org>
	 <1266868150-25984-2-git-send-email-hannes@cmpxchg.org>
	 <1266932303.2723.13.camel@barrios-desktop>
	 <20100223142158.GA29762@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 23 Feb 2010 23:44:14 +0900
Message-ID: <1266936254.2723.33.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2010-02-23 at 15:21 +0100, Johannes Weiner wrote:
> Hello Minchan,
> 
> On Tue, Feb 23, 2010 at 10:38:23PM +0900, Minchan Kim wrote:

<snip>

> > >  
> > >  		if (PageDirty(page)) {
> > > -			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
> > > +			if (references == PAGEREF_RECLAIM_CLEAN)
> > 
> > How equal PAGEREF_RECLAIM_CLEAN and sc->order <= PAGE_ALLOC_COSTLY_ORDER
> > && referenced by semantic?
> 
> It is encoded in page_check_references().  When
> 	sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced
> it returns PAGEREF_RECLAIM_CLEAN.
> 
> So
> 
> 	- PageDirty() && order < COSTLY && referenced
> 	+ PageDirty() && references == PAGEREF_RECLAIM_CLEAN
> 
> is an equivalent transformation.  Does this answer your question?

Hmm. I knew it. My point was PAGEREF_RECLAIM_CLEAN seems to be a little
awkward. I thought PAGEREF_RECLAIM_CLEAN means if the page was clean, it
can be reclaimed.

I think it would be better to rename it with represent "Although it's
referenced page recently, we can reclaim it if VM try to reclaim high
order page".


> 
> 	Hannes


-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
