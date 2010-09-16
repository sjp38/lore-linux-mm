Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id B093E6B0088
	for <linux-mm@kvack.org>; Thu, 16 Sep 2010 13:06:39 -0400 (EDT)
Date: Thu, 16 Sep 2010 12:06:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad for
 file/email/web servers
In-Reply-To: <20100916184240.3BC9.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1009161153210.22849@router.home>
References: <1284349152.15254.1394658481@webmail.messagingengine.com> <20100916184240.3BC9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: robm@fastmail.fm, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Sep 2010, KOSAKI Motohiro wrote:

> > So over the last couple of weeks, I've noticed that our shiny new IMAP
> > servers (Dual Xeon E5520 + Intel S5520UR MB) with 48G of RAM haven't
> > been performing as well as expected, and there were some big oddities.
> > Namely two things stuck out:
> >
> > 1. There was free memory. There's 20T of data on these machines. The
> >    kernel should have used lots of memory for caching, but for some
> >    reason, it wasn't. cache ~ 2G, buffers ~ 25G, unused ~ 5G

This means that that the memory allocations did only occur on a single
processor? And with zone reclaim it only used one node since the page
cache was reclaimed?

> > Having very little knowledge of what this actually does, I'd just
> > like to point out that from a users point of view, it's really
> > annoying for your machine to be crippled by a default kernel setting
> > that's pretty obscure.

Thats an issue of the NUMA BIOS information. Kernel defaults to zone
reclaim if the cost of accessing remote memory vs local memory crosses
a certain threshhold which usually impacts performance.

> Yes, sadly intel motherboard turn on zone_reclaim_mode by default. and
> current zone_reclaim_mode doesn't fit file/web server usecase ;-)

Or one could also say that the web servers are not designed to properly
distribute the load on a complex NUMA based memory architecture of todays
Intel machines.

> So, I've created new proof concept patch. This doesn't disable zone_reclaim
> at all. Instead, distinguish for file cache and for anon allocation and
> only file cache doesn't use zone-reclaim.

zone reclaim was intended to only be applicable to unmapped file cache in
order to be low impact.  Now you just want to apply it to anonymous pages?

> That said, high-end hpc user often turn on cpuset.memory_spread_page and
> they avoid this issue. But, why don't we consider avoid it by default?

Well as you say setting memory spreading on would avoid the issue.

So would enabling memory interleave in the BIOS to get the machine to not
consider the memory distances but average out the NUMA effects.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
