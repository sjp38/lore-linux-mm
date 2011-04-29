Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 58601900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 06:30:45 -0400 (EDT)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp03.au.ibm.com (8.14.4/8.13.1) with ESMTP id p3TAPp66024678
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 20:25:51 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3TAUfAP2265256
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 20:30:41 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3TAUeQn028140
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 20:30:41 +1000
Date: Fri, 29 Apr 2011 16:00:38 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] Add stats to monitor soft_limit reclaim
Message-ID: <20110429103038.GL6547@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1304030226-19332-1-git-send-email-yinghan@google.com>
 <1304030226-19332-3-git-send-email-yinghan@google.com>
 <BANLkTimP_0-ErmnGUnJPVjYRG=fcRN8eOA@mail.gmail.com>
 <BANLkTimum+TkOxGcqQYfaYEVN+U5oLQqhA@mail.gmail.com>
 <BANLkTik-kyPO_UFoMu=WcjRoBvA0NiCikg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTik-kyPO_UFoMu=WcjRoBvA0NiCikg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

* Ying Han <yinghan@google.com> [2011-04-28 20:28:54]:

> On Thu, Apr 28, 2011 at 4:51 PM, Hiroyuki Kamezawa
> <kamezawa.hiroyuki@gmail.com> wrote:
> > 2011/4/29 Ying Han <yinghan@google.com>:
> >> On Thu, Apr 28, 2011 at 3:37 PM, Ying Han <yinghan@google.com> wrote:
> >>> This patch extend the soft_limit reclaim stats to both global background
> >>> reclaim and global direct reclaim.
> >>>
> >>> We have a thread discussing the naming of some of the stats. Both
> >>> KAMEZAWA and Johannes posted the proposals. The following stats are based
> >>> on what i had before that thread. I will make the corresponding change on
> >>> the next post when we make decision.
> >>>
> >>> $cat /dev/cgroup/memory/A/memory.stat
> >>> kswapd_soft_steal 1053626
> >>> kswapd_soft_scan 1053693
> >>> direct_soft_steal 1481810
> >>> direct_soft_scan 1481996
> >>>
> >>> Signed-off-by: Ying Han <yinghan@google.com>
> >>> ---
> >>>  Documentation/cgroups/memory.txt |   10 ++++-
> >>>  mm/memcontrol.c                  |   68 ++++++++++++++++++++++++++++----------
> >>>  2 files changed, 58 insertions(+), 20 deletions(-)
> >>>
> >>> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> >>> index 0c40dab..fedc107 100644
> >>> --- a/Documentation/cgroups/memory.txt
> >>> +++ b/Documentation/cgroups/memory.txt
> >>> @@ -387,8 +387,14 @@ pgpgout            - # of pages paged out (equivalent to # of uncharging events).
> >>>  swap           - # of bytes of swap usage
> >>>  pgfault                - # of page faults.
> >>>  pgmajfault     - # of major page faults.
> >>> -soft_steal     - # of pages reclaimed from global hierarchical reclaim
> >>> -soft_scan      - # of pages scanned from global hierarchical reclaim
> >>> +soft_kswapd_steal- # of pages reclaimed in global hierarchical reclaim from
> >>> +               background reclaim
> >>> +soft_kswapd_scan - # of pages scanned in global hierarchical reclaim from
> >>> +               background reclaim
> >>> +soft_direct_steal- # of pages reclaimed in global hierarchical reclaim from
> >>> +               direct reclaim
> >>> +soft_direct_scan- # of pages scanned in global hierarchical reclaim from
> >>> +               direct reclaim
> >
> > Thank you for CC.
> >
> > I don't have strong opinion but once we add interfaces to mainline,
> > it's hard to rename them. So, it's better to make a list of what name
> > we'll need in future.
> >
> > Now, your naming has a format as [Reason]-[Who reclaim]-[What count?]
> > soft_kswapd_steal
> > soft_kswapd_scan
> > soft_direct_steal
> > soft_direct_scan
> >
> > Ok, we can make a name for wmark and limit reclaim as
> >
> > limit_direct_steal/scan
> > wmark_bg_steal/scan
> >
> > Then, assume we finally do round-robin scan of memcg regardless of softlimit by
> > removing global LRU, what name do we have ? Hmm,
> >
> > kernel_kswapd_scan/steal
> > kernel_direct_scan/steal
> >
> > ?
> 
> Johannes has the proposal to separate out reclaims on the memcg
> internally and externally. And then apply the format
> [Reason]-[Who reclaim]-[What count?], also i added the 4th item .
> 
> 1. when the memcg hits its hard_limit
> > limit_direct_steal
> > limit_direct_scan
> 
> 2. when the memcg hits its wmark
> > wmark_kswapd_steal
> > wmark_kswapd_scan
> 
> 3. the global direct reclaim triggers soft_limit pushback
> > soft_direct_steal
> > soft_direct_scan
> 
> 4. hierarchy-triggered direct reclaim
> > limit_hierarchy_steal
> > limit_hierarchy_scan
> 
> 5. the global bg reclaim triggers soft_limit pushback
> > soft_kswapd_steal
> > soft_kswapd_scan
>

I like these names, but these are more developer friendly than end
user friendly.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
