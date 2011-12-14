Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 894CE6B0310
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 19:00:40 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B02B53EE0BB
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 09:00:38 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9050945DF58
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 09:00:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BE0A45DF56
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 09:00:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CD2A1DB8042
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 09:00:38 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0FFB61DB803C
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 09:00:38 +0900 (JST)
Date: Thu, 15 Dec 2011 08:59:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2] memcg: Use gfp_mask __GFP_NORETRY in try charge
Message-Id: <20111215085900.52871f87.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20111214104658.GB11786@tiehlicka.suse.cz>
References: <1323742587-9084-1-git-send-email-yinghan@google.com>
	<20111213162126.GE30440@tiehlicka.suse.cz>
	<CALWz4iwHVMK_k5bxP_m1E8Ugq_FE5XTzHDNi7A8CRhkWHG_Z9A@mail.gmail.com>
	<20111214104658.GB11786@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Ying Han <yinghan@google.com>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, Fengguang Wu <fengguang.wu@intel.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org

On Wed, 14 Dec 2011 11:46:58 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> On Tue 13-12-11 10:43:16, Ying Han wrote:
> > On Tue, Dec 13, 2011 at 8:21 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > > On Mon 12-12-11 18:16:27, Ying Han wrote:
> > >> In __mem_cgroup_try_charge() function, the parameter "oom" is passed from the
> > >> caller indicating whether or not the charge should enter memcg oom kill. In
> > >> fact, we should be able to eliminate that by using the existing gfp_mask and
> > >> __GFP_NORETRY flag.
> > >>
> > >> This patch removed the "oom" parameter, and add the __GFP_NORETRY flag into
> > >> gfp_mask for those doesn't want to enter memcg oom. There is no functional
> > >> change for those setting false to "oom" like mem_cgroup_move_parent(), but
> > >> __GFP_NORETRY now is checked for those even setting true to "oom".
> > >>
> > >> The __GFP_NORETRY is used in page allocator to bypass retry and oom kill. I
> > >> believe there is a reason for callers to use that flag, and in memcg charge
> > >> we need to respect it as well.
> > >
> > > What is the reason for this change?
> > > To be honest it makes the oom condition more obscure. __GFP_NORETRY
> > > documentation doesn't say anything about OOM and one would have to know
> > > details about allocator internals to follow this.
> > > So I am not saying the patch is bad but I would need some strong reason
> > > to like it ;)
> > 
> > Thank you for looking into this :)
> > 
> > This patch was made as part of the effort solving the livelock issue.
> > Then it becomes a separate question by itself.
> > 
> > I don't quite understand the mismatch on gfp_mask = __GFP_NORETRY &&
> > oom_check == true. 
> 
> __GFP_NORETRY is a global thingy (because page allocator is global)
> while oom_check is internal memcg and it says that we do not want to go
> into oom because we cannot charge, consider THP for example. We do not
> want to OOM because we would go over hard limit and we rather want to
> fallback into a single page allocation.
> 

The first reason that 'oom' was added as argument was to handle 'decreasing limit'. 

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
