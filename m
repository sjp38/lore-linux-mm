Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 700B56B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 18:59:03 -0500 (EST)
Date: Fri, 25 Jan 2013 15:59:01 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v4 3/6] memcg: fast hierarchy-aware child test.
Message-Id: <20130125155901.4d3fb00c.akpm@linux-foundation.org>
In-Reply-To: <1358862461-18046-4-git-send-email-glommer@parallels.com>
References: <1358862461-18046-1-git-send-email-glommer@parallels.com>
	<1358862461-18046-4-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On Tue, 22 Jan 2013 17:47:38 +0400
Glauber Costa <glommer@parallels.com> wrote:

> Currently, we use cgroups' provided list of children to verify if it is
> safe to proceed with any value change that is dependent on the cgroup
> being empty.
> 
> This is less than ideal, because it enforces a dependency over cgroup
> core that we would be better off without. The solution proposed here is
> to iterate over the child cgroups and if any is found that is already
> online, we bounce and return: we don't really care how many children we
> have, only if we have any.
> 
> This is also made to be hierarchy aware. IOW, cgroups with  hierarchy
> disabled, while they still exist, will be considered for the purpose of
> this interface as having no children.

The code comments are a bit unclear.  Did this improve them?

--- a/mm/memcontrol.c~memcg-fast-hierarchy-aware-child-test-fix
+++ a/mm/memcontrol.c
@@ -4761,8 +4761,9 @@ static void mem_cgroup_reparent_charges(
 }
 
 /*
- * this mainly exists for tests during set of use_hierarchy. Since this is
- * the very setting we are changing, the current hierarchy value is meaningless
+ * This mainly exists for tests during the setting of set of use_hierarchy.
+ * Since this is the very setting we are changing, the current hierarchy value
+ * is meaningless
  */
 static inline bool __memcg_has_children(struct mem_cgroup *memcg)
 {
@@ -4775,11 +4776,11 @@ static inline bool __memcg_has_children(
 }
 
 /*
- * must be called with cgroup_lock held, unless the cgroup is guaranteed to be
- * already dead (like in mem_cgroup_force_empty, for instance).  This is
- * different than mem_cgroup_count_children, in the sense that we don't really
- * care how many children we have, we only need to know if we have any. It is
- * also count any memcg without hierarchy as infertile for that matter.
+ * Must be called with cgroup_lock held, unless the cgroup is guaranteed to be
+ * already dead (in mem_cgroup_force_empty(), for instance).  This is different
+ * from mem_cgroup_count_children(), in the sense that we don't really care how
+ * many children we have; we only need to know if we have any.  It also counts
+ * any memcg without hierarchy as infertile.
  */
 static inline bool memcg_has_children(struct mem_cgroup *memcg)
 {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
