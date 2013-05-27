Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 69F716B0032
	for <linux-mm@kvack.org>; Mon, 27 May 2013 13:13:35 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch v3 -mm 1/3] memcg: integrate soft reclaim tighter with zone shrinking code
Date: Mon, 27 May 2013 19:13:08 +0200
Message-Id: <1369674791-13861-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <20130517160247.GA10023@cmpxchg.org>
References: <20130517160247.GA10023@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Glauber Costa <glommer@parallels.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi,
it took me a bit longer than I wanted but I was closed in a conference
room in the end of the last week so I didn't have much time.

On Mon 20-05-13 16:44:38, Michal Hocko wrote:
> On Fri 17-05-13 12:02:47, Johannes Weiner wrote:
> > On Mon, May 13, 2013 at 09:46:10AM +0200, Michal Hocko wrote:
[...]
> > > After this patch shrink_zone is done in 2 passes. First it tries to do the
> > > soft reclaim if appropriate (only for global reclaim for now to keep
> > > compatible with the original state) and fall back to ignoring soft limit
> > > if no group is eligible to soft reclaim or nothing has been scanned
> > > during the first pass. Only groups which are over their soft limit or
> > > any of their parents up the hierarchy is over the limit are considered
> > > eligible during the first pass.
> > 
> > There are setups with thousands of groups that do not even use soft
> > limits.  Having them pointlessly iterate over all of them for every
> > couple of pages reclaimed is just not acceptable.
> 
> OK, that is a fair point. The soft reclaim pass should not be done if
> we know that every group is below the limit. This can be fixed easily.
> mem_cgroup_should_soft_reclaim could check a counter of over limit
> groups. This still doesn't solve the problem if there are relatively few
> groups over the limit wrt. those that are under the limit.
> 
> You are proposing a simple list in the follow up email. I have
> considered this approach as well but then I decided not to go that
> way because the list iteration doesn't respect per-node-zone-priority
> tree walk which makes it tricky to prevent from over-reclaim with many
> parallel reclaimers. I rather wanted to integrate the soft reclaim into
> the reclaim tree walk. There is also a problem when all groups are in
> excess then the whole tree collapses into a linked list which is not
> nice either (hmm, this could be mitigated if only a group in excess
> which is highest in the hierarchy would be in the list)
> 
[...]
> I think that the numbers can be improved even without introducing
> the list of groups in excess. One way to go could be introducing a
> conditional (callback) to the memcg iterator so the groups under the
> limit would be excluded during the walk without playing with css
> references and other things. My quick and dirty patch shows that
> 4k-0-limit System time was reduced by 40% wrt. this patchset. With a
> proper tagging we can make the walk close to free.

And the following patchset implements that. My first numbers shown an
improvement (I will post some numbers later after I collect them).

Nevertheless I have encountered an issue while testing the huge number
of groups scenario. And the issue is not limitted to only to this
scenario unfortunately. As memcg iterators use per node-zone-priority
cache to prevent from over reclaim it might quite easily happen that
the walk will not visit all groups and will terminate the loop either
prematurely or skip some groups. An example could be the direct reclaim
racing with kswapd. This might cause that the loop misses over limit
groups so no pages are scanned and so we will fall back to all groups
reclaim.

Not good! But also not easy to fix without risking an over reclaim or
potential stalls. I was thinking about introducing something like:

bool should_soft_limit_reclaim_continue(struct mem_cgroup *root, int groups_reclaimed)
{
	if (!groups_reclaimed)
		return false;

	if (mem_cgroup_soft_reclaim_eligible(root, root) == VISIT)
		return true;
}

and loop again few times in __shrink_zone. I am not entirely thrilled
about this as the effectiveness depends on the number of parallel
reclaimers at the same priority but it should work at least somehow. If
anybody has a better idea I am all for it.

I will think about it some more.

Anyway I will post 3 patches which should mitigate the "too many groups"
issue as a reply to this email. See patches for details.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
