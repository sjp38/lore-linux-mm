Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 247556B007D
	for <linux-mm@kvack.org>; Mon, 11 Jan 2010 23:59:11 -0500 (EST)
Date: Tue, 12 Jan 2010 12:59:06 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 4/4] mm/page_alloc : relieve zone->lock's pressure for
	memory free
Message-ID: <20100112045906.GA30172@localhost>
References: <1263184634-15447-4-git-send-email-shijie8@gmail.com> <1263191277-30373-1-git-send-email-shijie8@gmail.com> <20100111153802.f3150117.minchan.kim@barrios-desktop> <20100112094708.d09b01ea.kamezawa.hiroyu@jp.fujitsu.com> <20100112022708.GA21621@localhost> <28c262361001112005s745e5ecj9fd6ae3d0d997477@mail.gmail.com> <20100112042116.GA26035@localhost> <20100112133223.005b81ed.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100112133223.005b81ed.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Huang Shijie <shijie8@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <clameter@sgi.com>, Andrea Arcangeli <andrea@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 12, 2010 at 12:32:23PM +0800, KAMEZAWA Hiroyuki wrote:
> On Tue, 12 Jan 2010 12:21:16 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> > > BTW,
> > > Hmm. It's not atomic as Kame pointed out.
> > > 
> > > Now, zone->flags have several bit.
> > >  * ZONE_ALL_UNRECLAIMALBE
> > >  * ZONE_RECLAIM_LOCKED
> > >  * ZONE_OOM_LOCKED.
> > > 
> > > I think this flags are likely to race when the memory pressure is high.
> > > If we don't prevent race, concurrent reclaim and killing could be happened.
> > > So I think reset zone->flags outside of zone->lock would make our efforts which
> > > prevent current reclaim and killing invalidate.
> > 
> > zone_set_flag()/zone_clear_flag() calls set_bit()/clear_bit() which is
> > atomic. Do you mean more high level exclusion?
> > 
> Ah, sorry, I missed that.
> In my memory, this wasn't atomic ;) ...maybe recent change.
> 
> I don't want to see atomic_ops here...So, how about making this back to be
> zone->all_unreclaimable word ?
> 
> Clearing this is not necessary to be atomic because this is cleard at every
> page freeing.

Yes the cost is a bit high. This was introduced by David Rientjes
in commit e815af95f, let's hear opinions from him :)

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
