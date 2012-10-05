Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id A79976B005A
	for <linux-mm@kvack.org>; Fri,  5 Oct 2012 16:53:38 -0400 (EDT)
Date: Fri, 5 Oct 2012 13:53:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 2/2] mm: memcg: clean up mm_match_cgroup() signature
Message-Id: <20121005135336.1ee7082f.akpm@linux-foundation.org>
In-Reply-To: <1349374157-20604-3-git-send-email-hannes@cmpxchg.org>
References: <1349374157-20604-1-git-send-email-hannes@cmpxchg.org>
	<1349374157-20604-3-git-send-email-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu,  4 Oct 2012 14:09:17 -0400
Johannes Weiner <hannes@cmpxchg.org> wrote:

> It really should return a boolean for match/no match.  And since it
> takes a memcg, not a cgroup, fix that parameter name as well.
> 
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -84,14 +84,14 @@ extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
>  extern struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont);
>  
>  static inline
> -int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
> +bool mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *memcg)
>  {
> -	struct mem_cgroup *memcg;
> -	int match;
> +	struct mem_cgroup *task_memcg;
> +	bool match;
>  
>  	rcu_read_lock();
> -	memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
> -	match = memcg && __mem_cgroup_same_or_subtree(cgroup, memcg);
> +	task_memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
> +	match = task_memcg && __mem_cgroup_same_or_subtree(memcg, task_memcg);
>  	rcu_read_unlock();
>  	return match;
>  }

This needed massaging after droppage of your [1/2]:



From: Johannes Weiner <hannes@cmpxchg.org>
Subject: mm: memcg: clean up mm_match_cgroup() signature

It really should return a boolean for match/no match.  And since it
takes a memcg, not a cgroup, fix that parameter name as well.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Michal Hocko <mhocko@suse.cz>
---
 1 file changed, 7 insertions(+), 7 deletions(-)

index 8686294..7698182 100644
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/memcontrol.h |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff -puN include/linux/memcontrol.h~mm-memcg-clean-up-mm_match_cgroup-signature include/linux/memcontrol.h
--- a/include/linux/memcontrol.h~mm-memcg-clean-up-mm_match_cgroup-signature
+++ a/include/linux/memcontrol.h
@@ -84,13 +84,13 @@ extern struct mem_cgroup *parent_mem_cgr
 extern struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont);
 
 static inline
-int mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *cgroup)
+bool mm_match_cgroup(const struct mm_struct *mm, const struct mem_cgroup *memcg)
 {
-	struct mem_cgroup *memcg;
-	int match;
+	struct mem_cgroup *task_memcg;
+	bool match;
 
 	rcu_read_lock();
-	memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
+	task_memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
 	match = __mem_cgroup_same_or_subtree(cgroup, task_memcg);
 	rcu_read_unlock();
 	return match;
@@ -258,10 +258,10 @@ static inline struct mem_cgroup *try_get
 	return NULL;
 }
 
-static inline int mm_match_cgroup(struct mm_struct *mm,
+static inline bool mm_match_cgroup(struct mm_struct *mm,
 		struct mem_cgroup *memcg)
 {
-	return 1;
+	return true;
 }
 
 static inline int task_in_mem_cgroup(struct task_struct *task,
_


Also,


From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-memcg-clean-up-mm_match_cgroup-signature-fix

mm_match_cgroup is not a macro

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/memcontrol.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN include/linux/memcontrol.h~mm-memcg-clean-up-mm_match_cgroup-signature-fix include/linux/memcontrol.h
--- a/include/linux/memcontrol.h~mm-memcg-clean-up-mm_match_cgroup-signature-fix
+++ a/include/linux/memcontrol.h
@@ -90,7 +90,7 @@ bool mm_match_cgroup(const struct mm_str
 	bool match;
 
 	rcu_read_lock();
-	task_memcg = mem_cgroup_from_task(rcu_dereference((mm)->owner));
+	task_memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
 	match = __mem_cgroup_same_or_subtree(cgroup, task_memcg);
 	rcu_read_unlock();
 	return match;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
