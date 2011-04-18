Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CA4F3900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 05:14:01 -0400 (EDT)
Date: Mon, 18 Apr 2011 11:13:51 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V4 00/10] memcg: per cgroup background reclaim
Message-ID: <20110418091351.GC8925@tiehlicka.suse.cz>
References: <1302821669-29862-1-git-send-email-yinghan@google.com>
 <20110415094040.GC8828@tiehlicka.suse.cz>
 <BANLkTimJ2hhuP-Rph+2DtHG-F_gHXg4CWg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTimJ2hhuP-Rph+2DtHG-F_gHXg4CWg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Fri 15-04-11 09:40:54, Ying Han wrote:
> On Fri, Apr 15, 2011 at 2:40 AM, Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Hi Ying,
> > sorry that I am jumping into game that late but I was quite busy after
> > returning back from LSF and LFCS.
> >
> 
> Sure. Nice meeting you guys there and thank you for looking into this patch
> :)

Yes, nice meeting.

> 
> >
> > On Thu 14-04-11 15:54:19, Ying Han wrote:
> > > The current implementation of memcg supports targeting reclaim when the
> > > cgroup is reaching its hard_limit and we do direct reclaim per cgroup.
> > > Per cgroup background reclaim is needed which helps to spread out memory
> > > pressure over longer period of time and smoothes out the cgroup
> > performance.
> > >
> > > If the cgroup is configured to use per cgroup background reclaim, a
> > kswapd
> > > thread is created which only scans the per-memcg LRU list.
> >
> > Hmm, I am wondering if this fits into the get-rid-of-the-global-LRU
> > strategy. If we make the background reclaim per-cgroup how do we balance
> > from the global/zone POV? We can end up with all groups over the high
> > limit while a memory zone is under this watermark. Or am I missing
> > something?
> > I thought that plans for the background reclaim were same as for direct
> > reclaim so that kswapd would just evict pages from groups in the
> > round-robin fashion (in first round just those that are under limit and
> > proportionally when it cannot reach high watermark after it got through
> > all groups).
> >
> 
> I think you are talking about the soft_limit reclaim which I am gonna look
> at next. 

I see. I am just concerned whether 3rd level of reclaim is a good idea.
We would need to do background reclaim anyway (and to preserve the
original semantic it has to be somehow watermark controlled). I am just
wondering why we have to implement it separately from kswapd. Cannot we
just simply trigger global kswapd which would reclaim all cgroups that
are under watermarks? [I am sorry for my ignorance if that is what is
implemented in the series - I haven't got to the patches yes]

> The soft_limit reclaim
> is triggered under global memory pressure and doing round-robin across
> memcgs. I will also cover the
> zone-balancing by having second list of memgs under their soft_limit.
> 
> Here is the summary of our LSF discussion :)
> http://permalink.gmane.org/gmane.linux.kernel.mm/60966

Yes, I have read it and thanks for putting it together.

> > > Two watermarks ("high_wmark", "low_wmark") are added to trigger the
> > > background reclaim and stop it. The watermarks are calculated based on
> > > the cgroup's limit_in_bytes.
> >
> > I didn't have time to look at the patch how does the calculation work
> > yet but we should be careful to match the zone's watermark expectations.
> >
> 
> I have API on the following patch which provide high/low_wmark_distance to
> tune wmarks individually individually.  By default, they are set to 0 which
> turn off the per-memcg kswapd. For now, we are ok since the global kswapd is
> still doing per-zone scanning and reclaiming :)
> 
> >
> > > By default, the per-memcg kswapd threads are running under root cgroup.
> > There
> > > is a per-memcg API which exports the pid of each kswapd thread, and
> > userspace
> > > can configure cpu cgroup seperately.
> > >
> > > I run through dd test on large file and then cat the file. Then I
> > compared
> > > the reclaim related stats in memory.stat.
> > >
> > > Step1: Create a cgroup with 500M memory_limit.
> > > $ mkdir /dev/cgroup/memory/A
> > > $ echo 500m >/dev/cgroup/memory/A/memory.limit_in_bytes
> > > $ echo $$ >/dev/cgroup/memory/A/tasks
> > >
> > > Step2: Test and set the wmarks.
> > > $ cat /dev/cgroup/memory/A/memory.low_wmark_distance
> > > 0
> > > $ cat /dev/cgroup/memory/A/memory.high_wmark_distance
> > > 0
> >
> >
> They are used to tune the high/low_marks based on the hard_limit. We might
> need to export that configuration to user admin especially on machines where
> they over-commit by hard_limit.

I remember there was some resistance against tuning watermarks
separately.

> > > $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> > > low_wmark 524288000
> > > high_wmark 524288000
> > >
> > > $ echo 50m >/dev/cgroup/memory/A/memory.high_wmark_distance
> > > $ echo 40m >/dev/cgroup/memory/A/memory.low_wmark_distance
> > >
> > > $ cat /dev/cgroup/memory/A/memory.reclaim_wmarks
> > > low_wmark  482344960
> > > high_wmark 471859200
> >
> > low_wmark is higher than high_wmark?
> >
> 
> hah, it is confusing. I have them documented. Basically, low_wmark triggers
> reclaim and high_wmark stop the reclaim. And we have
> 
> high_wmark < usage < low_wmark.

OK, I will look at it.

[...]

> > I am not sure how much orthogonal per-cgroup-per-thread vs. zone
> > approaches are, though.  Maybe it makes some sense to do both per-cgroup
> > and zone background reclaim.  Anyway I think that we should start with
> > the zone reclaim first.
> >
> 
> I missed the point here. Can you clarify the zone reclaim here?

kswapd does the background zone reclaim and you are trying to do
per-cgroup reclaim, right? I am concerned about those two fighting with
slightly different goal. 

I am still thinking whether backgroup reclaim would be sufficient,
though. We would get rid of per-cgroup thread and wouldn't create a new
reclaim interface.
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
