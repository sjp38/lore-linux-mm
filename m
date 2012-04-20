Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 8EC506B00ED
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 19:15:43 -0400 (EDT)
Date: Sat, 21 Apr 2012 01:15:01 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 1/2] memcg: softlimit reclaim rework
Message-ID: <20120420231501.GE2536@cmpxchg.org>
References: <1334680682-12430-1-git-send-email-yinghan@google.com>
 <20120420091731.GE4191@tiehlicka.suse.cz>
 <CALWz4iyTH8a77w2bOkSXiODiNEn+L7SFv8Njp1_fRwi8aFVZHw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4iyTH8a77w2bOkSXiODiNEn+L7SFv8Njp1_fRwi8aFVZHw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri, Apr 20, 2012 at 11:22:14AM -0700, Ying Han wrote:
> On Fri, Apr 20, 2012 at 2:17 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Tue 17-04-12 09:38:02, Ying Han wrote:
> >> This patch reverts all the existing softlimit reclaim implementations and
> >> instead integrates the softlimit reclaim into existing global reclaim logic.
> >>
> >> The new softlimit reclaim includes the following changes:
> >>
> >> 1. add function should_reclaim_mem_cgroup()
> >>
> >> Add the filter function should_reclaim_mem_cgroup() under the common function
> >> shrink_zone(). The later one is being called both from per-memcg reclaim as
> >> well as global reclaim.
> >>
> >> Today the softlimit takes effect only under global memory pressure. The memcgs
> >> get free run above their softlimit until there is a global memory contention.
> >> This patch doesn't change the semantics.
> >
> > I am not sure I understand but I think it does change the semantics.
> > Previously we looked at a group with the biggest excess and reclaim that
> > group _hierarchically_.
> 
> yes, we don't do _hierarchically_ reclaim reclaim in this patch. Hmm,
> that might be what Johannes insists to preserve on the other
> thread.... ?

Yes, that is exactly what I was talking about all along :-)

To reiterate, in the case of

A (soft = 10G)
  A1
  A2
  A3
  ...

global reclaim should go for A, A1, A2, A3, ... when their sum usage
goes above 10G.  Regardless of any setting in those subgroups, for
reasons I outlined in the other subthread (basically, allowing
children to override parental settings assumes you trust all children
and their settings to be 'cooperative', which is unprecedented cgroup
semantics, afaics, and we can already see this will make problems in
the future)

Meanwhile, if you don't want a hierarchical limit, don't set a
hierarchical limit.  It's possible to organize the tree such that you
don't need to, and it should not be an unreasonable amount of work to
do so).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
