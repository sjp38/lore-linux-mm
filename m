Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 8FD3D6B00C8
	for <linux-mm@kvack.org>; Tue,  2 Oct 2012 05:34:37 -0400 (EDT)
Date: Tue, 2 Oct 2012 11:34:33 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 1/4] memcg: provide root figures from system totals
Message-ID: <20121002093433.GA1293@dhcp22.suse.cz>
References: <1348563173-8952-1-git-send-email-glommer@parallels.com>
 <1348563173-8952-2-git-send-email-glommer@parallels.com>
 <20121001170046.GC24860@dhcp22.suse.cz>
 <506AB0BF.9030400@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <506AB0BF.9030400@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

On Tue 02-10-12 13:15:43, Glauber Costa wrote:
> On 10/01/2012 09:00 PM, Michal Hocko wrote:
> > On Tue 25-09-12 12:52:50, Glauber Costa wrote:
> >> > For the root memcg, there is no need to rely on the res_counters.
> > This is true only if there are no children groups but once there is at
> > least one we have to move global statistics into root res_counter and
> > start using it since then. This is a tricky part because it has to be
> > done atomically so that we do not miss anything.
> > 
> Why can't we shortcut it all the time?

Because it has its own tasks and we are still not at use_hierarchy := 1

> It makes a lot of sense to use the root cgroup as the sum of everything,
> IOW, global counters. Otherwise you are left in a situation where you
> had global statistics, and all of a sudden, when a group is created, you
> start having just a subset of that, excluding the tasks in root.

Yes because if there are no other tasks then, well, global == root. Once
you have more groups (with tasks of course) then it depends on our
favorite use_hierarchy buddy.

> If we can always assume root will have the sum of *all* tasks, including
> the ones in root, we should never need to rely on root res_counters.

but we are not there yet.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
