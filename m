Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5A69D6B0071
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 23:35:50 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0C4ZlHH017875
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 Jan 2010 13:35:47 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 033DE45DE50
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 13:35:47 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DC06445DE4F
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 13:35:46 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C55E71DB803A
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 13:35:46 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 380C91DB8043
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 13:35:46 +0900 (JST)
Date: Tue, 12 Jan 2010 13:32:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
 memory free
Message-Id: <20100112133223.005b81ed.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100112042116.GA26035@localhost>
References: <1263184634-15447-4-git-send-email-shijie8@gmail.com>
	<1263191277-30373-1-git-send-email-shijie8@gmail.com>
	<20100111153802.f3150117.minchan.kim@barrios-desktop>
	<20100112094708.d09b01ea.kamezawa.hiroyu@jp.fujitsu.com>
	<20100112022708.GA21621@localhost>
	<28c262361001112005s745e5ecj9fd6ae3d0d997477@mail.gmail.com>
	<20100112042116.GA26035@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jan 2010 12:21:16 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:
> > BTW,
> > Hmm. It's not atomic as Kame pointed out.
> > 
> > Now, zone->flags have several bit.
> >  * ZONE_ALL_UNRECLAIMALBE
> >  * ZONE_RECLAIM_LOCKED
> >  * ZONE_OOM_LOCKED.
> > 
> > I think this flags are likely to race when the memory pressure is high.
> > If we don't prevent race, concurrent reclaim and killing could be happened.
> > So I think reset zone->flags outside of zone->lock would make our efforts which
> > prevent current reclaim and killing invalidate.
> 
> zone_set_flag()/zone_clear_flag() calls set_bit()/clear_bit() which is
> atomic. Do you mean more high level exclusion?
> 
Ah, sorry, I missed that.
In my memory, this wasn't atomic ;) ...maybe recent change.

I don't want to see atomic_ops here...So, how about making this back to be
zone->all_unreclaimable word ?

Clearing this is not necessary to be atomic because this is cleard at every
page freeing.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
