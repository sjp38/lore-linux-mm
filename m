Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 866326B00C2
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 09:54:08 -0500 (EST)
Date: Tue, 17 Jan 2012 15:53:48 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/2] mm: memcg: hierarchical soft limit reclaim
Message-ID: <20120117145348.GA3144@cmpxchg.org>
References: <1326207772-16762-1-git-send-email-hannes@cmpxchg.org>
 <1326207772-16762-3-git-send-email-hannes@cmpxchg.org>
 <CALWz4izwNBN_qcSsqg-qYw-Esc9vBL3=4cv3Wsg1jf6001_fWQ@mail.gmail.com>
 <20120112085904.GG24386@cmpxchg.org>
 <CALWz4iz3sQX+pCr19rE3_SwV+pRFhDJ7Lq-uJuYBq6u3mRU3AQ@mail.gmail.com>
 <20120113224424.GC1653@cmpxchg.org>
 <4F158418.2090509@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F158418.2090509@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha <handai.szj@gmail.com>
Cc: Ying Han <yinghan@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jan 17, 2012 at 10:22:16PM +0800, Sha wrote:
> On 01/14/2012 06:44 AM, Johannes Weiner wrote:
> >On Fri, Jan 13, 2012 at 01:31:16PM -0800, Ying Han wrote:
> >>On Thu, Jan 12, 2012 at 12:59 AM, Johannes Weiner<hannes@cmpxchg.org>  wrote:
> >>>On Wed, Jan 11, 2012 at 01:42:31PM -0800, Ying Han wrote:
> >>>>On Tue, Jan 10, 2012 at 7:02 AM, Johannes Weiner<hannes@cmpxchg.org>  wrote:
> >>>>>@@ -1318,6 +1123,36 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
> >>>>>        return margin>>  PAGE_SHIFT;
> >>>>>  }
> >>>>>
> >>>>>+/**
> >>>>>+ * mem_cgroup_over_softlimit
> >>>>>+ * @root: hierarchy root
> >>>>>+ * @memcg: child of @root to test
> >>>>>+ *
> >>>>>+ * Returns %true if @memcg exceeds its own soft limit or contributes
> >>>>>+ * to the soft limit excess of one of its parents up to and including
> >>>>>+ * @root.
> >>>>>+ */
> >>>>>+bool mem_cgroup_over_softlimit(struct mem_cgroup *root,
> >>>>>+                              struct mem_cgroup *memcg)
> >>>>>+{
> >>>>>+       if (mem_cgroup_disabled())
> >>>>>+               return false;
> >>>>>+
> >>>>>+       if (!root)
> >>>>>+               root = root_mem_cgroup;
> >>>>>+
> >>>>>+       for (; memcg; memcg = parent_mem_cgroup(memcg)) {
> >>>>>+               /* root_mem_cgroup does not have a soft limit */
> >>>>>+               if (memcg == root_mem_cgroup)
> >>>>>+                       break;
> >>>>>+               if (res_counter_soft_limit_excess(&memcg->res))
> >>>>>+                       return true;
> >>>>>+               if (memcg == root)
> >>>>>+                       break;
> >>>>>+       }
> >>>>Here it adds pressure on a cgroup if one of its parents exceeds soft
> >>>>limit, although the cgroup itself is under soft limit. It does change
> >>>>my understanding of soft limit, and might introduce regression of our
> >>>>existing use cases.
> >>>>
> >>>>Here is an example:
> >>>>
> >>>>Machine capacity 32G and we over-commit by 8G.
> >>>>
> >>>>root
> >>>>   ->  A (hard limit 20G, soft limit 15G, usage 16G)
> >>>>        ->  A1 (soft limit 5G, usage 4G)
> >>>>        ->  A2 (soft limit 10G, usage 12G)
> >>>>   ->  B (hard limit 20G, soft limit 10G, usage 16G)
> >>>>
> >>>>under global reclaim, we don't want to add pressure on A1 although its
> >>>>parent A exceeds its soft limit. Assume that if we set the soft limit
> >>>>corresponding to each cgroup's working set size (hot memory), and it
> >>>>will introduce regression to A1 in that case.
> >>>>
> >>>>In my existing implementation, i am checking the cgroup's soft limit
> >>>>standalone w/o looking its ancestors.
> >>>Why do you set the soft limit of A in the first place if you don't
> >>>want it to be enforced?
> >>The soft limit should be enforced under certain condition, not always.
> >>The soft limit of A is set to be enforced when the parent of A and B
> >>is under memory pressure. For example:
> >>
> >>Machine capacity 32G and we over-commit by 8G
> >>
> >>root
> >>->  A (hard limit 20G, soft limit 12G, usage 20G)
> >>        ->  A1 (soft limit 2G, usage 1G)
> >>        ->  A2 (soft limit 10G, usage 19G)
> >>->  B (hard limit 20G, soft limit 10G, usage 0G)
> >>
> >>Now, A is under memory pressure since the total usage is hitting its
> >>hard limit. Then we start hierarchical reclaim under A, and each
> >>cgroup under A also takes consideration of soft limit. In this case,
> >>we should only set priority = 0 to A2 since it contributes to A's
> >>charge as well as exceeding its own soft limit. Why punishing A1 (set
> >>priority = 0) also which has usage under its soft limit ? I can
> >>imagine it will introduce regression to existing environment which the
> >>soft limit is set based on the working set size of the cgroup.
> >>
> >>To answer the question why we set soft limit to A, it is used to
> >>over-commit the host while sharing the resource with its sibling (B in
> >>this case). If the machine is under memory contention, we would like
> >>to push down memory to A or B depends on their usage and soft limit.
> >D'oh, I think the problem is just that we walk up the hierarchy one
> >too many when checking whether a group exceeds a soft limit.  The soft
> >limit is a signal to distribute pressure that comes from above, it's
> >meaningless and should indeed be ignored on the level the pressure
> >originates from.
> >
> >Say mem_cgroup_over_soft_limit(root, memcg) would check everyone up to
> >but not including root, wouldn't that do exactly what we both want?
> >
> >Example:
> >
> >1. If global memory is short, we reclaim with root=root_mem_cgroup.
> >    A1 and A2 get soft limit reclaimed because of A's soft limit
> >    excess, just like the current kernel would do.
> >
> >2. If A hits its hard limit, we reclaim with root=A, so we only mind
> >    the soft limits of A1 and A2.  A1 is below its soft limit, all
> >    good.  A2 is above its soft limit, gets treated accordingly.  This
> >    is new behaviour, the current kernel would just reclaim them
> >    equally.
> >
> >Code:
> >
> >bool mem_cgroup_over_soft_limit(struct mem_cgroup *root,
> >			        struct mem_cgroup *memcg)
> >{
> >	if (mem_cgroup_disabled())
> >		return false;
> >
> >	if (!root)
> >		root = root_mem_cgroup;
> >
> >	for (; memcg; memcg = parent_mem_cgroup(memcg)) {
> >		if (memcg == root)
> >			break;
> >		if (res_counter_soft_limit_excess(&memcg->res))
> >			return true;
> >	}
> >	return false;
> >}
> Hi Johannes,
> 
> I don't think it solve the root of the problem, example:
> root
> -> A (hard limit 20G, soft limit 12G, usage 20G)
>     -> A1 ( soft limit 2G,   usage 1G)
>     -> A2 ( soft limit 10G, usage 19G)
>            ->B1 (soft limit 5G, usage 4G)
>            ->B2 (soft limit 5G, usage 15G)
> 
> Now A is hitting its hard limit and start hierarchical reclaim under A.
> If we choose B1 to go through mem_cgroup_over_soft_limit, it will
> return true because its parent A2 has a large usage and will lead to
> priority=0 reclaiming. But in fact it should be B2 to be punished.

Because A2 is over its soft limit, the whole hierarchy below it should
be preferred over A1, so both B1 and B2 should be soft limit reclaimed
to be consistent with behaviour at the root level.

> IMHO, it may checking the cgroup's soft limit standalone without
> looking up its ancestors just as Ying said.

Again, this would be a regression as soft limits have been applied
hierarchically forever.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
