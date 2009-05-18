Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C6D116B005C
	for <linux-mm@kvack.org>; Sun, 17 May 2009 23:52:50 -0400 (EDT)
Date: Mon, 18 May 2009 11:53:19 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/4] vmscan: change the number of the unmapped files in
	zone reclaim
Message-ID: <20090518035319.GA7940@localhost>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120606.587C.A69D9226@jp.fujitsu.com> <20090518031536.GC5869@localhost> <2f11576a0905172035k3f26b8d6r84af555a94b1d70e@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2f11576a0905172035k3f26b8d6r84af555a94b1d70e@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, May 18, 2009 at 11:35:31AM +0800, KOSAKI Motohiro wrote:
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -2397,6 +2397,7 @@ static int __zone_reclaim(struct zone *z
> >> A  A  A  A  A  A  A  .isolate_pages = isolate_pages_global,
> >> A  A  A  };
> >> A  A  A  unsigned long slab_reclaimable;
> >> + A  A  long nr_unmapped_file_pages;
> >>
> >> A  A  A  disable_swap_token();
> >> A  A  A  cond_resched();
> >> @@ -2409,9 +2410,11 @@ static int __zone_reclaim(struct zone *z
> >> A  A  A  reclaim_state.reclaimed_slab = 0;
> >> A  A  A  p->reclaim_state = &reclaim_state;
> >>
> >> - A  A  if (zone_page_state(zone, NR_FILE_PAGES) -
> >> - A  A  A  A  A  A  zone_page_state(zone, NR_FILE_MAPPED) >
> >> - A  A  A  A  A  A  zone->min_unmapped_pages) {
> >> + A  A  nr_unmapped_file_pages = zone_page_state(zone, NR_INACTIVE_FILE) +
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A zone_page_state(zone, NR_ACTIVE_FILE) -
> >> + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A zone_page_state(zone, NR_FILE_MAPPED);
> >
> > This can possibly go negative.
> 
> Is this a problem?
> negative value mean almost pages are mapped. Thus
> 
>   (nr_unmapped_file_pages > zone->min_unmapped_pages)  => 0
> 
> is ok, I think.

I wonder why you didn't get a gcc warning, because zone->min_unmapped_pages
is a "unsigned long".

Anyway, add a simple note to the code if it works *implicitly*?

Thanks,
Fengguang

> >
> >> + A  A  if (nr_unmapped_file_pages > zone->min_unmapped_pages) {
> >> A  A  A  A  A  A  A  /*
> >> A  A  A  A  A  A  A  A * Free memory by calling shrink zone with increasing
> >> A  A  A  A  A  A  A  A * priorities until we have enough memory freed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
