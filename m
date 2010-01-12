Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 348BE6B006A
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 21:35:01 -0500 (EST)
Date: Tue, 12 Jan 2010 10:27:08 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
	memory free
Message-ID: <20100112022708.GA21621@localhost>
References: <1263184634-15447-4-git-send-email-shijie8@gmail.com> <1263191277-30373-1-git-send-email-shijie8@gmail.com> <20100111153802.f3150117.minchan.kim@barrios-desktop> <20100112094708.d09b01ea.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100112094708.d09b01ea.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, akpm@linux-foundation.org, mel@csn.ul.ie, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 12, 2010 at 09:47:08AM +0900, KAMEZAWA Hiroyuki wrote:
> > Thanks, Huang. 
> > 
> > Frankly speaking, I am not sure this ir right way.
> > This patch is adding to fine-grained locking overhead
> > 
> > As you know, this functions are one of hot pathes.
> > In addition, we didn't see the any problem, until now.
> > It means out of synchronization in ZONE_ALL_UNRECLAIMABLE 
> > and pages_scanned are all right?
> > 
> > If it is, we can move them out of zone->lock, too.
> > If it isn't, we need one more lock, then. 
> > 
> I don't want to see additional spin_lock, here. 
> 
> About ZONE_ALL_UNRECLAIMABLE, it's not necessary to be handled in atomic way.
> If you have concerns with other flags, please modify this with single word,
> instead of a bit field.

I'd second it. It's not a big problem to reset ZONE_ALL_UNRECLAIMABLE
and pages_scanned outside of zone->lru_lock.

Clear of ZONE_ALL_UNRECLAIMABLE is already atomic; if we lose one
pages_scanned=0 due to races, there are plenty of page free events
ahead to reset it, before pages_scanned hit the huge
zone_reclaimable_pages() * 6.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
