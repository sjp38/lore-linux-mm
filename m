Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A40186B004A
	for <linux-mm@kvack.org>; Tue,  7 Sep 2010 10:51:36 -0400 (EDT)
Received: by pxi5 with SMTP id 5so1602410pxi.14
        for <linux-mm@kvack.org>; Tue, 07 Sep 2010 07:51:36 -0700 (PDT)
Date: Tue, 7 Sep 2010 23:51:26 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC][PATCH] big continuous memory allocator v2
Message-ID: <20100907145126.GA4620@barrios-desktop>
References: <20100907114505.fc40ea3d.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTintQqzx50Jp_zyKQMaAfhSEFah3HhseNmNfNMjB@mail.gmail.com>
 <20100907174743.2efa34bd.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100907174743.2efa34bd.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 07, 2010 at 05:47:43PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 7 Sep 2010 01:37:27 -0700
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > Nice cleanup.
> > There are some comments in below.
> > 
> > On Mon, Sep 6, 2010 at 7:45 PM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > >
> > > This is a page allcoator based on memory migration/hotplug code.
> > > passed some small tests, and maybe easier to read than previous one.
> > >
> > > ==
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > >
> > > This patch as a memory allocator for contiguous memory larger than MAX_ORDER.
> > >
> > > ??alloc_contig_pages(hint, size, node);
> > 
> > I have thought this patch is to be good for dumb device drivers which
> > want big contiguous
> > memory. So if some device driver want big memory and they can tolerate
> > latency or fail,
> > this is good solution, I think.
> > And some device driver can't tolerate fail, they have to use MOVABLE zone.
> > 
> > For it, I hope we have a option like ALLOC_FIXED(like MAP_FIXED).
> > That's because embedded people wanted to aware BANK of memory.
> > So if they get free page which they don't want, it can be pointless.
> > 
> Okay.
> 
> 
> > In addition, I hope it can support CROSS_ZONE migration mode.
> > Most of small system can't support swap system. So if we can't migrate
> > anon pages into other zones, external fragment problem still happens.
> > 
> Now, this code migrates pages to somewhere, including crossing zone, node etc..
> (because it just use GFP_HIGHUSER_MOVABLE)
> 
> > I think reclaim(ex, discard file-backed pages) can become one option to prevent
> > the problem. But it's more cost so we can support it by calling mode.
> > (But it could be trivial since caller should know this function is very cost)
> > 
> 
> > ex) alloc_contig_pages(hint, size, node, ALLOC_FIXED|ALLOC_RECLAIM);
> > 
> 
> This migration's page allocation code will cause memory reclaim and
> kswapd wakeup if memory is in short. But hmm, there are no codes as

Yes. But it's useless. That's because it's not a zone/node we want to reclaim.
The zone we want to reclaim is not alloc failed zone but the zone which include 
alloc_contig_pages's hint address. 

> 
>  reclaim_memory_within(start, end).
> 
> But I guess if there are LRU pages within the range which cannot be migrated,
> they can't be dropped. In another consideration, 
> 
>   shrink_slab_within(start, end)
> will be able to make success-rate better. (and this is good for memory hotplug, too)

And it can help normal external memory fragement, too. 

> 
> I'll start from adding ALLOC_FIXED.

I am looking forward to seeing your next version. :)
Thanks, Kame. 
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
