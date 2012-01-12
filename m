Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 6E9DA6B004D
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 04:34:39 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id EB49F3EE0BD
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 18:34:37 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D01D445DEF3
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 18:34:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AA69845DEED
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 18:34:37 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9B4C41DB8041
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 18:34:37 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DDAF1DB8038
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 18:34:37 +0900 (JST)
Date: Thu, 12 Jan 2012 18:33:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: Fix NULL ptr dereference in __count_immobile_pages
Message-Id: <20120112183323.1bb62f4d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120112092314.GC1042@tiehlicka.suse.cz>
References: <1326213022-11761-1-git-send-email-mhocko@suse.cz>
	<alpine.DEB.2.00.1201101326080.10821@chino.kir.corp.google.com>
	<20120111084802.GA16466@tiehlicka.suse.cz>
	<20120112111702.3b7f2fa2.kamezawa.hiroyu@jp.fujitsu.com>
	<20120112082722.GB1042@tiehlicka.suse.cz>
	<20120112173536.db529713.kamezawa.hiroyu@jp.fujitsu.com>
	<20120112092314.GC1042@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, 12 Jan 2012 10:23:14 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Thu 12-01-12 17:35:36, KAMEZAWA Hiroyuki wrote:
> > On Thu, 12 Jan 2012 09:27:22 +0100
> > Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > On Thu 12-01-12 11:17:02, KAMEZAWA Hiroyuki wrote:
> > > > On Wed, 11 Jan 2012 09:48:02 +0100
> > > > Michal Hocko <mhocko@suse.cz> wrote:
> > > > 
> > > > > On Tue 10-01-12 13:31:08, David Rientjes wrote:
> > > > > > On Tue, 10 Jan 2012, Michal Hocko wrote:
> > > > > [...]
> > > > > > >  mm/page_alloc.c |   11 +++++++++++
> > > > > > >  1 files changed, 11 insertions(+), 0 deletions(-)
> > > > > > > 
> > > > > > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > > > > > index 2b8ba3a..485be89 100644
> > > > > > > --- a/mm/page_alloc.c
> > > > > > > +++ b/mm/page_alloc.c
> > > > > > > @@ -5608,6 +5608,17 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
> > > > > > >  bool is_pageblock_removable_nolock(struct page *page)
> > > > > > >  {
> > > > > > >  	struct zone *zone = page_zone(page);
> > > > > > > +	unsigned long pfn = page_to_pfn(page);
> > > > > > > +
> > > > 
> > > > Hmm, I don't like to use page_zone() when we know the page may not be initialized.
> > > > Shouldn't we add
> > > > 
> > > > 	if (!node_online(page_to_nid(page))
> > > > 		return false;
> > > > ?
> > > 
> > > How is this different? The node won't be initialized in page flags as
> > > well.
> > > 
> > 
> > page_zone(page) is
> > ==
> > static inline struct zone *page_zone(const struct page *page)
> > {
> >         return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
> > }
> > ==
> > 
> > Then, if the page is unitialized, 
> > 
> >    &(NODE_DATA(0)->node_zones[0])
> > 
> > If NODE_DATA(0) is NULL, node_zones[0] is NULL just because zone array is placed
> > on the top of struct pglist_data.
> > 
> > I never think someone may change the layout but...Hmm, just a nitpick.
> > please do as you like.
> 
> Yes, fair point. See the follow up patch bellow.
> 
> > > > But...hmm. I think we should return 'true' here for removing a section with a hole
> > > > finally....(Now, false will be safe.)
> > > 
> > > Those pages are reserved (for BIOS I guess) in this particular case so I
> > > do not think it is safe to claim that the block is removable. Or am I
> > > missing something?
> > > 
> > 
> > We can't know it's reserved by BIOS or it's just a memory hole by the fact
> > the page wasn't initialized.
> 
> OK, so then we should return false to mark to block non removable,
> right?

Ok.

> --- 
> From 04f74e6f0ebf28f61650d63f8884e8855fb21b55 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 12 Jan 2012 10:19:04 +0100
> Subject: [PATCH] mm: __count_immobile_pages make sure the node is online
> 
> page_zone requires to have an online node otherwise we are accessing
> NULL NODE_DATA. This is not an issue at the moment because node_zones
> are located at the structure beginning but this might change in the
> future so better be careful about that.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/page_alloc.c |   11 +++++++++--
>  1 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 485be89..c6fb8ea 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -5607,14 +5607,21 @@ __count_immobile_pages(struct zone *zone, struct page *page, int count)
>  
>  bool is_pageblock_removable_nolock(struct page *page)
>  {
> -	struct zone *zone = page_zone(page);
> -	unsigned long pfn = page_to_pfn(page);
> +	struct zone *zone;
> +	unsigned long pfn;
>  
>  	/*
>  	 * We have to be careful here because we are iterating over memory
>  	 * sections which are not zone aware so we might end up outside of
>  	 * the zone but still within the section.
> +	 * We have to take care about the node as well. If the node is offline
> +	 * its NODE_DATA will be NULL - see page_zone.
>  	 */
> +	if (!node_online(page_to_nid(page)))
> +		return false;
> +
> +	zone = page_zone(page);
> +	pfn = page_to_pfn(page);
>  	if (!zone || zone->zone_start_pfn > pfn ||
>  			zone->zone_start_pfn + zone->spanned_pages <= pfn)
>  		return false;

!zone check can be removed because of node_online() check.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
