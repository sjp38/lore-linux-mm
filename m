Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 099856B004D
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 22:22:38 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 82DD43EE0C0
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 12:22:36 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 66E7945DEEB
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 12:22:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 44FA845DEEF
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 12:22:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 398F8E18001
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 12:22:36 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DDC6E1DB8047
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 12:22:35 +0900 (JST)
Date: Thu, 12 Jan 2012 12:21:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memcg: add mlock statistic in memory.stat
Message-Id: <20120112122116.7547cb42.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CALWz4iyuT48FWuw52bcu3B9GvHbz3c3ODcsgPzOP80UOP1Q-bQ@mail.gmail.com>
References: <1326321668-5422-1-git-send-email-yinghan@google.com>
	<alpine.LSU.2.00.1201111512570.1846@eggly.anvils>
	<20120112085937.ae601869.kamezawa.hiroyu@jp.fujitsu.com>
	<CALWz4iyuT48FWuw52bcu3B9GvHbz3c3ODcsgPzOP80UOP1Q-bQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Wed, 11 Jan 2012 16:50:09 -0800
Ying Han <yinghan@google.com> wrote:

> On Wed, Jan 11, 2012 at 3:59 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Wed, 11 Jan 2012 15:17:42 -0800 (PST)
> > Hugh Dickins <hughd@google.com> wrote:
> >
> >> On Wed, 11 Jan 2012, Ying Han wrote:
> >>
> >> > We have the nr_mlock stat both in meminfo as well as vmstat system wide, this
> >> > patch adds the mlock field into per-memcg memory stat. The stat itself enhances
> >> > the metrics exported by memcg, especially is used together with "uneivctable"
> >> > lru stat.
> >> >
> >> > --- a/include/linux/page_cgroup.h
> >> > +++ b/include/linux/page_cgroup.h
> >> > @@ -10,6 +10,7 @@ enum {
> >> > A  A  /* flags for mem_cgroup and file and I/O status */
> >> > A  A  PCG_MOVE_LOCK, /* For race between move_account v.s. following bits */
> >> > A  A  PCG_FILE_MAPPED, /* page is accounted as "mapped" */
> >> > + A  PCG_MLOCK, /* page is accounted as "mlock" */
> >> > A  A  /* No lock in page_cgroup */
> >> > A  A  PCG_ACCT_LRU, /* page has been accounted for (under lru_lock) */
> >> > A  A  __NR_PCG_FLAGS,
> >>
> >> Is this really necessary? A KAMEZAWA-san is engaged in trying to reduce
> >> the number of PageCgroup flags, and I expect that in due course we shall
> >> want to merge them in with Page flags, so adding more is unwelcome.
> >> I'd A have thought that with memcg_ hooks in the right places,
> >> a separate flag would not be necessary?
> >>
> >
> > Please don't ;)
> >
> > NR_UNEIVCTABLE_LRU is not enough ?
> 
> Seems not.
> 
> The unevictable lru includes more than mlock()'d pages ( SHM_LOCK'd
> etc). There are use cases where we like to know the mlock-ed size
> per-cgroup. We used to archived that in fake-numa based container by
> reading the value from per-node meminfo, however we miss that
> information in memcg. What do you think?
> 

Hm. The # of mlocked pages can be got sum of /proc/<pid>/? ?

BTW, Roughly..

(inactive_anon + active_anon) - rss = # of unlocked shm.

cache - (inactive_file + active_file) = total # of shm

Then,

(cache -  (inactive_file + active_file)) - ((inactive_anon + active_anon) - rss)
= cache + rss - (sum of inactive/actige lru)
= locked shm.

Hm, but this works only when unmapped swapcache is  small ;)

Thanks,
-Kame


 








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
