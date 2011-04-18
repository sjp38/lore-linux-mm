Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 43652900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 14:42:50 -0400 (EDT)
Date: Mon, 18 Apr 2011 20:42:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4 00/10] memcg: per cgroup background reclaim
Message-ID: <20110418184240.GA11653@tiehlicka.suse.cz>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
 <20110415094040.GC8828@tiehlicka.suse.cz>
 <BANLkTimJ2hhuP-Rph+2DtHG-F_gHXg4CWg@mail.gmail.com>
 <20110418091351.GC8925@tiehlicka.suse.cz>
 <BANLkTimkPasX8AA=HCOgVeSyPBSivz8pMg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTimkPasX8AA=HCOgVeSyPBSivz8pMg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Mon 18-04-11 10:01:20, Ying Han wrote:
> On Mon, Apr 18, 2011 at 2:13 AM, Michal Hocko <mhocko@suse.cz> wrote:
[...]
> > I see. I am just concerned whether 3rd level of reclaim is a good idea.
> > We would need to do background reclaim anyway (and to preserve the
> > original semantic it has to be somehow watermark controlled). I am just
> > wondering why we have to implement it separately from kswapd. Cannot we
> > just simply trigger global kswapd which would reclaim all cgroups that
> > are under watermarks? [I am sorry for my ignorance if that is what is
> > implemented in the series - I haven't got to the patches yes]
> >
> 
> They are different on per-zone reclaim vs per-memcg reclaim. The first
> one is triggered if the zone is under memory pressure and we need
> to free pages to serve further page allocations.  The second one is
> triggered if the memcg is under memory pressure and we need to free
> pages to leave room (limit - usage) for the memcg to grow.

OK, I see.


> 
> Both of them are needed and that is how it is implemented on the direct
> reclaim path. The kswapd batches only try to
> smooth out the system and memcg performance by reclaiming pages proactively.
> It doesn't affecting the functionality.

I am still wondering, isn't this just a nice to have feature rather than
must to have in order to get rid of the global LRU? Doesn't it make
transition more complicated. I have noticed many if-else in kswapd path to
distinguish per-cgroup from the traditional global background reclaim.

[...]

> > > > > Step1: Create a cgroup with 500M memory_limit.
> > > > > $ mkdir /dev/cgroup/memory/A
> > > > > $ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
> > > > > $ echo $$ >/dev/cgroup/memory/A/tasks
> > > > >
> > > > > Step2: Test and set the wmarks.
> > > > > $ cat /dev/cgroup/memory/A/memory.low_wmark_distance
> > > > > 0
> > > > > $ cat /dev/cgroup/memory/A/memory.high_wmark_distance
> > > > > 0
> > > >
> > > >
> > > They are used to tune the high/low_marks based on the hard_limit. We
> > might
> > > need to export that configuration to user admin especially on machines
> > where
> > > they over-commit by hard_limit.
> >
> > I remember there was some resistance against tuning watermarks
> > separately.
> >
> 
> This API is based on KAMEZAWA's request. :)

This was just as FYI. Watermarks were considered internal thing. So I
wouldn't be surprised if this got somehow controversial.

> 
> >
> > > > > $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> > > > > low_wmark 524288000
> > > > > high_wmark 524288000
> > > > >
> > > > > $ echo 50m >/dev/cgroup/memory/A/memory.high_wmark_distance
> > > > > $ echo 40m >/dev/cgroup/memory/A/memory.low_wmark_distance
> > > > >
> > > > > $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> > > > > low_wmark  482344960
> > > > > high_wmark 471859200
> > > >
> > > > low_wmark is higher than high_wmark?
> > > >
> > >
> > > hah, it is confusing. I have them documented. Basically, low_wmark
> > > triggers reclaim and high_wmark stop the reclaim. And we have
> > >
> > > high_wmark < usage < low_wmark.

OK, I see how you calculate those watermarks now but it is really
confusing for those who are used to traditional watermark semantic.
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
