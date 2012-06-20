Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 564C96B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 04:53:31 -0400 (EDT)
Date: Wed, 20 Jun 2012 10:53:01 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V5 1/5] mm: memcg softlimit reclaim rework
Message-ID: <20120620085301.GF27816@cmpxchg.org>
References: <1340038051-29502-1-git-send-email-yinghan@google.com>
 <20120619112901.GC27816@cmpxchg.org>
 <CALWz4iyC2di8ueaHnCE-ENv5td4buK9DOWF5rLfN0bhR68bSAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CALWz4iyC2di8ueaHnCE-ENv5td4buK9DOWF5rLfN0bhR68bSAw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Jun 19, 2012 at 08:45:03PM -0700, Ying Han wrote:
> On Tue, Jun 19, 2012 at 4:29 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Mon, Jun 18, 2012 at 09:47:27AM -0700, Ying Han wrote:
> >> +{
> >> +     if (mem_cgroup_disabled())
> >> +             return true;
> >> +
> >> +     /*
> >> +      * We treat the root cgroup special here to always reclaim pages.
> >> +      * Now root cgroup has its own lru, and the only chance to reclaim
> >> +      * pages from it is through global reclaim. note, root cgroup does
> >> +      * not trigger targeted reclaim.
> >> +      */
> >> +     if (mem_cgroup_is_root(memcg))
> >> +             return true;
> >
> > With the soft limit at 0, the comment is no longer accurate because
> > this check turns into a simple optimization.  We could check the
> > res_counter soft limit, which would always result in the root group
> > being above the limit, but we take the short cut.
> 
> For root group, my intention here is always reclaim pages from it
> regardless of the softlimit setting. And the reason is exactly the one
> in the comment. If the softlimit is set to 0 as default, I agree this
> is then a short cut.
> 
> Anything you suggest that I need to change here?

Well, not in this patch as it stands.  But once you squash the '0 per
default', it may be good to note that this is a shortcut.

> >> +     for (; memcg; memcg = parent_mem_cgroup(memcg)) {
> >> +             /* This is global reclaim, stop at root cgroup */
> >> +             if (mem_cgroup_is_root(memcg))
> >> +                     break;
> >
> > I don't see why you add this check and the comment does not help.
> 
> The root cgroup would have softlimit set to 0 ( in most of the cases
> ), and not skipping root will make everyone reclaimable here.

Only if root_mem_cgroup->use_hierarchy is set.  At the same time, we
usually behave as if this was the case, in accounting and reclaim.

Right now we allow setting the soft limit in root_mem_cgroup but it
does not make any sense.  After your patch, even less so, because of
these shortcut checks that now actually change semantics.  Could we
make this more consistent to users and forbid setting as soft limit in
root_mem_cgroup?  Patch below.

The reason this behaves differently from hard limits is because the
soft limits now have double meaning; they are upper limit and minimum
guarantee at the same time.  The unchangeable defaults in the root
cgroup should be "no guarantee" and "unlimited soft limit" at the same
time, but that is obviously not possible if these are opposing range
ends of the same knob.  So we pick no guarantees, always up for
reclaim when looking top down but also behave as if the soft limit was
unlimited in the root cgroup when looking bottom up.

This is what the second check does.  But I think it needs a clearer
comment.

---
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: mm: memcg: forbid setting soft limit on root cgroup

Setting a soft limit in the root cgroup does not make sense, as soft
limits are enforced hierarchically and the root cgroup is the
hierarchical parent of every other cgroup.  It would not provide the
discrimination between groups that soft limits are usually used for.

With the current implementation of soft limits, it would only make
global reclaim more aggressive compared to target reclaim, but we
absolutely don't want anyone to rely on this behaviour.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ac35bcc..21c45a0 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3905,6 +3967,10 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
 			ret = mem_cgroup_resize_memsw_limit(memcg, val);
 		break;
 	case RES_SOFT_LIMIT:
+		if (mem_cgroup_is_root(memcg)) { /* Can't set limit on root */
+			ret = -EINVAL;
+			break;
+		}
 		ret = res_counter_memparse_write_strategy(buffer, &val);
 		if (ret)
 			break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
