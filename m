Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DAD9F900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 14:48:46 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p3DImh7g031060
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:48:43 -0700
Received: from pxi17 (pxi17.prod.google.com [10.243.27.17])
	by wpaz21.hot.corp.google.com with ESMTP id p3DImfHA018870
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:48:42 -0700
Received: by pxi17 with SMTP id 17so570255pxi.6
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 11:48:41 -0700 (PDT)
Date: Wed, 13 Apr 2011 11:48:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] vmscan: all_unreclaimable() use zone->all_unreclaimable
 as a name
In-Reply-To: <20110411143128.0070.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1104131148030.5563@chino.kir.corp.google.com>
References: <20110411142949.006C.A69D9226@jp.fujitsu.com> <20110411143128.0070.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrey Vagin <avagin@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, 11 Apr 2011, KOSAKI Motohiro wrote:

> all_unreclaimable check in direct reclaim has been introduced at 2.6.19
> by following commit.
> 
> 	2006 Sep 25; commit 408d8544; oom: use unreclaimable info
> 
> And it went through strange history. firstly, following commit broke
> the logic unintentionally.
> 
> 	2008 Apr 29; commit a41f24ea; page allocator: smarter retry of
> 				      costly-order allocations
> 
> Two years later, I've found obvious meaningless code fragment and
> restored original intention by following commit.
> 
> 	2010 Jun 04; commit bb21c7ce; vmscan: fix do_try_to_free_pages()
> 				      return value when priority==0
> 
> But, the logic didn't works when 32bit highmem system goes hibernation
> and Minchan slightly changed the algorithm and fixed it .
> 
> 	2010 Sep 22: commit d1908362: vmscan: check all_unreclaimable
> 				      in direct reclaim path
> 
> But, recently, Andrey Vagin found the new corner case. Look,
> 
> 	struct zone {
> 	  ..
> 	        int                     all_unreclaimable;
> 	  ..
> 	        unsigned long           pages_scanned;
> 	  ..
> 	}
> 
> zone->all_unreclaimable and zone->pages_scanned are neigher atomic
> variables nor protected by lock. Therefore zones can become a state
> of zone->page_scanned=0 and zone->all_unreclaimable=1. In this case,
> current all_unreclaimable() return false even though
> zone->all_unreclaimabe=1.
> 
> Is this ignorable minor issue? No. Unfortunatelly, x86 has very
> small dma zone and it become zone->all_unreclamble=1 easily. and
> if it become all_unreclaimable=1, it never restore all_unreclaimable=0.
> Why? if all_unreclaimable=1, vmscan only try DEF_PRIORITY reclaim and
> a-few-lru-pages>>DEF_PRIORITY always makes 0. that mean no page scan
> at all!
> 
> Eventually, oom-killer never works on such systems. That said, we
> can't use zone->pages_scanned for this purpose. This patch restore
> all_unreclaimable() use zone->all_unreclaimable as old. and in addition,
> to add oom_killer_disabled check to avoid reintroduce the issue of
> commit d1908362.
> 
> Reported-by: Andrey Vagin <avagin@openvz.org>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

Seems like it should be a candidate for stable inclusion as well, nice 
catch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
