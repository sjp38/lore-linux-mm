Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 794436B0083
	for <linux-mm@kvack.org>; Mon, 14 May 2012 16:02:48 -0400 (EDT)
Received: by dakp5 with SMTP id p5so9197494dak.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 13:02:47 -0700 (PDT)
Date: Mon, 14 May 2012 13:02:18 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 3/3] mm/memcg: apply add/del_page to lruvec
In-Reply-To: <4FB0E985.9000107@openvz.org>
Message-ID: <alpine.LSU.2.00.1205141252060.1693@eggly.anvils>
References: <alpine.LSU.2.00.1205132152530.6148@eggly.anvils> <alpine.LSU.2.00.1205132201210.6148@eggly.anvils> <4FB0E985.9000107@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, 14 May 2012, Konstantin Khlebnikov wrote:
> Hugh Dickins wrote:
> > Take lruvec further: pass it instead of zone to add_page_to_lru_list()
> > and del_page_from_lru_list(); and pagevec_lru_move_fn() pass lruvec
> > down to its target functions.
> > 
> > This cleanup eliminates a swathe of cruft in memcontrol.c,
> > including mem_cgroup_lru_add_list(), mem_cgroup_lru_del_list() and
> > mem_cgroup_lru_move_lists() - which never actually touched the lists.
> > 
> > In their place, mem_cgroup_page_lruvec() to decide the lruvec,
> > previously a side-effect of add, and mem_cgroup_update_lru_size()
> > to maintain the lru_size stats.
> > 
> > Whilst these are simplifications in their own right, the goal is to
> > bring the evaluation of lruvec next to the spin_locking of the lrus,
> > in preparation for a future patch.
> > 
> > Signed-off-by: Hugh Dickins<hughd@google.com>
> > ---
> > The horror, the horror: I have three lines of 81 columns:
> > I do think they look better this way than split up.
> 
> This too huge and hard to review. =(

Hah, we have very different preferences: whereas I found your
split into twelve a hindrance to review rather than a help.

> I have the similar thing splitted into several patches.

I had been hoping to get this stage, where I think we're still in
agreement (except perhaps on the ordering of function arguments!),
into 3.5 as a basis for later discussion.

But I won't have time to split it into bite-sized pieces for
linux-next now before 3.4 goes out, so it sounds like we'll have
to drop it this time around.  Oh well.

Thanks (you and Kame and Michal) for the very quick review of
the other, even more trivial, patches.

> 
> Also I want to replace page_cgroup->mem_cgroup pointer with
> page_cgroup->lruvec
> and rework "surreptitious switching any uncharged page to root"
> In my set I have mem_cgroup_page_lruvec() without side-effects and
> mem_cgroup_page_lruvec_putback() with can switch page's lruvec, but it not
> always moves pages to root: in
> putback_inactive_pages()/move_active_pages_to_lru()
> we have better candidate for lruvec switching.

But those sound like later developments on top of this to me.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
