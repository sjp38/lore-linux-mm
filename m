Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 538066B0047
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 10:39:46 -0400 (EDT)
Date: Thu, 2 Sep 2010 16:39:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] Make is_mem_section_removable more conformable with
 offlining code
Message-ID: <20100902143939.GD10265@tiehlicka.suse.cz>
References: <20100831141942.GA30353@localhost>
 <20100901121951.GC6663@tiehlicka.suse.cz>
 <20100901124138.GD6663@tiehlicka.suse.cz>
 <20100902144500.a0d05b08.kamezawa.hiroyu@jp.fujitsu.com>
 <20100902082829.GA10265@tiehlicka.suse.cz>
 <20100902180343.f4232c6e.kamezawa.hiroyu@jp.fujitsu.com>
 <20100902092454.GA17971@tiehlicka.suse.cz>
 <AANLkTi=cLzRGPCc3gCubtU7Ggws7yyAK5c7tp4iocv6u@mail.gmail.com>
 <20100902131855.GC10265@tiehlicka.suse.cz>
 <AANLkTikYt3Hu_XeNuwAa9KjzfWgpC8cNen6q657ZKmm-@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTikYt3Hu_XeNuwAa9KjzfWgpC8cNen6q657ZKmm-@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Kleen, Andi" <andi.kleen@intel.com>, Haicheng Li <haicheng.li@linux.intel.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Mel Gorman <mel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu 02-09-10 23:19:18, Hiroyuki Kamezawa wrote:
[...]
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 6e6e626..0bd941b 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -669,6 +669,30 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
> > ?*/
> > ?#define zone_idx(zone) ? ? ? ? ((zone) - (zone)->zone_pgdat->node_zones)
> >
> > +#ifdef CONFIG_MEMORY_HOTREMOVE
> > +/*
> > + * A free or LRU pages block are removable
> > + * Do not use MIGRATE_MOVABLE because it can be insufficient and
> > + * other MIGRATE types are tricky.
> > + */
> > +static inline bool is_page_removable(struct page *page)
> > +{
> > + ? ? ? int page_block = 1 << pageblock_order;
> > + ? ? ? for (page_block > 0) {
> 
> for ?

Bahh. The old and half backed patch. See the up-to-date one bellow.

> > + ? ? ? ? ? ? ? if (PageBuddy(page)) {
> > + ? ? ? ? ? ? ? ? ? ? ? page_block -= page_order(page);
> > + ? ? ? ? ? ? ? }else if (PageLRU(page))
> > + ? ? ? ? ? ? ? ? ? ? ? page_block--;
> > + ? ? ? ? ? ? ? else
> > + ? ? ? ? ? ? ? ? ? ? ? return false;
> > + ? ? ? }
> > +
> > + ? ? ? return true;
> > +}
> 
> Hmm. above for is intending to check all pages in the block ?

Yes, by their orders.

> I'll look into details, tomorrow.

Thanks!

---
