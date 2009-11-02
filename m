Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C3FED6B0078
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 14:03:12 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCHv2 2/5] vmscan: Kill hibernation specific reclaim logic and unify it
Date: Mon, 2 Nov 2009 20:05:04 +0100
References: <20091102000855.F404.A69D9226@jp.fujitsu.com> <4AEE0536.6020605@crca.org.au> <20091103002520.886C.A69D9226@jp.fujitsu.com>
In-Reply-To: <20091103002520.886C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200911022005.04076.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nigel Cunningham <ncunningham@crca.org.au>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Monday 02 November 2009, KOSAKI Motohiro wrote:
> Hi
> 
> Thank you for the reviewing :)
> 
> > > 2) shrink_all_zone() try to shrink all pages at a time. but it doesn't works
> > >   fine on numa system.
> > >   example)
> > >     System has 4GB memory and each node have 2GB. and hibernate need 1GB.
> > > 
> > >     optimal)
> > >        steal 500MB from each node.
> > >     shrink_all_zones)
> > >        steal 1GB from node-0.
> > 
> > I haven't given much thought to numa awareness in hibernate code, but I
> > can say that the shrink_all_memory interface is woefully inadequate as
> > far as zone awareness goes. Since lowmem needs to be atomically restored
> > before we can restore highmem, we really need to be able to ask for a
> > particular number of pages of a particular zone type to be freed.
> 
> Honestly, I am not suspend/hibernation expert. Can I ask why caller need to know
> per-zone number of freed pages information? if hibernation don't need highmem.

It does need highmem.  At least the mainline version does.

> following incremental patch prevent highmem reclaim perfectly. Is it enough?

Thanks,
Rafael

 
> ---
>  mm/vmscan.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index e6ea011..7fb3435 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2265,7 +2265,7 @@ unsigned long shrink_all_memory(unsigned long nr_to_reclaim)
>  {
>  	struct reclaim_state reclaim_state;
>  	struct scan_control sc = {
> -		.gfp_mask = GFP_HIGHUSER_MOVABLE,
> +		.gfp_mask = GFP_KERNEL,
>  		.may_swap = 1,
>  		.may_unmap = 1,
>  		.may_writepage = 1,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
