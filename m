Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id C0EC26B0031
	for <linux-mm@kvack.org>; Tue,  4 Jun 2013 09:59:05 -0400 (EDT)
Date: Tue, 4 Jun 2013 09:58:40 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/3] memcg: fix subtle memory barrier bug in
 mem_cgroup_iter()
Message-ID: <20130604135840.GN15576@cmpxchg.org>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-2-git-send-email-tj@kernel.org>
 <20130604130336.GE31242@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130604130336.GE31242@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Tue, Jun 04, 2013 at 03:03:36PM +0200, Michal Hocko wrote:
> On Mon 03-06-13 17:44:37, Tejun Heo wrote:
> [...]
> > @@ -1218,9 +1218,18 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> >  			 * is alive.
> >  			 */
> >  			dead_count = atomic_read(&root->dead_count);
> > -			smp_rmb();
> > +
> >  			last_visited = iter->last_visited;
> >  			if (last_visited) {
> > +				/*
> > +				 * Paired with smp_wmb() below in this
> > +				 * function.  The pair guarantee that
> > +				 * last_visited is more current than
> > +				 * last_dead_count, which may lead to
> > +				 * spurious iteration resets but guarantees
> > +				 * reliable detection of dead condition.
> > +				 */
> > +				smp_rmb();
> >  				if ((dead_count != iter->last_dead_count) ||
> >  					!css_tryget(&last_visited->css)) {
> >  					last_visited = NULL;
> 
> I originally had the barrier this way but Johannes pointed out it is not
> correct https://lkml.org/lkml/2013/2/11/411
> "
> !> +			/*
> !> +			 * last_visited might be invalid if some of the group
> !> +			 * downwards was removed. As we do not know which one
> !> +			 * disappeared we have to start all over again from the
> !> +			 * root.
> !> +			 * css ref count then makes sure that css won't
> !> +			 * disappear while we iterate to the next memcg
> !> +			 */
> !> +			last_visited = iter->last_visited;
> !> +			dead_count = atomic_read(&root->dead_count);
> !> +			smp_rmb();
> !
> !Confused about this barrier, see below.
> !
> !As per above, if you remove the iter lock, those lines are mixed up.
> !You need to read the dead count first because the writer updates the
> !dead count after it sets the new position.  That way, if the dead
> !count gives the go-ahead, you KNOW that the position cache is valid,
> !because it has been updated first.  If either the two reads or the two
> !writes get reordered, you risk seeing a matching dead count while the
> !position cache is stale.
> "

The original prototype code I sent looked like this:

mem_cgroup_iter:
rcu_read_lock()
if atomic_read(&root->dead_count) == iter->dead_count:
  smp_rmb()
  if tryget(iter->position):
    position = iter->position
memcg = find_next(postion)
css_put(position)
iter->position = memcg
smp_wmb() /* Write position cache BEFORE marking it uptodate */
iter->dead_count = atomic_read(&root->dead_count)
rcu_read_unlock()

iter->last_position is written, THEN iter->last_dead_count is written.

So, yes, you "need to read the dead count" first to be sure
iter->last_position is uptodate.  But iter->last_dead_count, not
root->dead_count.  I should have caught this in the final submission
of your patch :(

Tejun's patch is not correct, either.  Something like this?

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 010d6c1..92830fa 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1199,7 +1199,6 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 
 			mz = mem_cgroup_zoneinfo(root, nid, zid);
 			iter = &mz->reclaim_iter[reclaim->priority];
-			last_visited = iter->last_visited;
 			if (prev && reclaim->generation != iter->generation) {
 				iter->last_visited = NULL;
 				goto out_unlock;
@@ -1217,14 +1216,20 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 			 * css_tryget() verifies the cgroup pointed to
 			 * is alive.
 			 */
+			last_visited = NULL;
 			dead_count = atomic_read(&root->dead_count);
-			smp_rmb();
-			last_visited = iter->last_visited;
-			if (last_visited) {
-				if ((dead_count != iter->last_dead_count) ||
-					!css_tryget(&last_visited->css)) {
+			if (dead_count == iter->last_dead_count) {
+				/*
+				 * The writer below sets the position
+				 * pointer, then the dead count.
+				 * Ensure we read the updated position
+				 * when the dead count matches.
+				 */
+				smp_rmb();
+				last_visited = iter->last_visited;
+				if (last_visited &&
+				    !css_tryget(&last_visited->css))
 					last_visited = NULL;
-				}
 			}
 		}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
