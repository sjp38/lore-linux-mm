Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 3952F6B0044
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 22:22:59 -0400 (EDT)
Date: Thu, 12 Apr 2012 04:22:33 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V2 3/5] memcg: set soft_limit_in_bytes to 0 by default
Message-ID: <20120412022233.GF1787@cmpxchg.org>
References: <1334181614-26836-1-git-send-email-yinghan@google.com>
 <4F8625AD.6000707@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F8625AD.6000707@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Ying Han <yinghan@google.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

On Wed, Apr 11, 2012 at 08:45:33PM -0400, Rik van Riel wrote:
> On 04/11/2012 06:00 PM, Ying Han wrote:
> >1. If soft_limit are all set to MAX, it wastes first three periority iterations
> >without scanning anything.
> >
> >2. By default every memcg is eligibal for softlimit reclaim, and we can also
> >set the value to MAX for special memcg which is immune to soft limit reclaim.
> >
> >This idea is based on discussion with Michal and Johannes from LSF.
> 
> Combined with patch 2/5, would this not result in always
> returning "reclaim from this memcg" for groups without a
> configured softlimit, while groups with a configured
> softlimit only get reclaimed from when they are over
> their limit?
> 
> Is that the desired behaviour when a system has some
> cgroups with a configured softlimit, and some without?

Yes, in general I think this new behaviour is welcome.

In the past, soft limits were only used to give excess memory a lower
priority and there was no particular meaning associated with "being
below your soft limit".  This change makes it so that soft limits are
actually a minimum guarantee, too, so you wouldn't get reclaimed if
you behaved (if possible):

		A-unconfigured		B-below-softlimit
old:		reclaim			reclaim
new:		reclaim			no reclaim (if possible)

The much less obvious change here, however, is that we no longer put
extra pressure on groups above their limit compared to unconfigured
groups:

		A-unconfigured		B-above-softlimit
old:		reclaim			reclaim twice
new:		reclaim			reclaim

I still think that it's a reasonable use case to put a soft limit on a
workload to "nice" it memory-wise, without looking at the machine as a
whole and configuring EVERY cgroup based on global knowledge and
static partitioning of the machine.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
