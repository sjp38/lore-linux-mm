Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id B59806B00FE
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 10:47:55 -0400 (EDT)
Date: Mon, 8 Apr 2013 16:47:50 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/8] cgroup: implement cgroup_is_ancestor()
Message-ID: <20130408144750.GK17178@dhcp22.suse.cz>
References: <51627DA9.7020507@huawei.com>
 <51627DBB.5050005@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51627DBB.5050005@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

On Mon 08-04-13 16:20:11, Li Zefan wrote:
[...]
> @@ -5299,6 +5300,26 @@ struct cgroup_subsys_state *cgroup_css_from_dir(struct file *f, int id)
>  	return css ? css : ERR_PTR(-ENOENT);
>  }
>  
> +/**
> + * cgroup_is_ancestor - test "root" cgroup is an ancestor of "child"
> + * @child: the cgroup to be tested.
> + * @root: the cgroup supposed to be an ancestor of the child.
> + *
> + * Returns true if "root" is an ancestor of "child" in its hierarchy.
> + */
> +bool cgroup_is_ancestor(struct cgroup *child, struct cgroup *root)
> +{
> +	int depth = child->depth;

Is this functionality helpful for other controllers but memcg?
css_is_ancestor is currently used only by memcg code AFAICS and we can
get the same functionality easily by using something like:
	
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d195f40..37bbbff 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1472,11 +1472,13 @@ void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
 bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
 				  struct mem_cgroup *memcg)
 {
-	if (root_memcg == memcg)
-		return true;
-	if (!root_memcg->use_hierarchy || !memcg)
-		return false;
-	return css_is_ancestor(&memcg->css, &root_memcg->css);
+	struct mem_cgroup *parent = memcg;
+	do {
+		if (parent == root_memcg)
+			return true;
+	} while ((parent = parent_mem_cgroup(parent)));
+
+	return false;
 }
 
 static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,

In both cases we have to go up the hierarchy.

> +
> +	if (depth < root->depth)
> +		return false;
> +
> +	while (depth-- != root->depth)
> +		child = child->parent;
> +
> +	return (child == root);
> +}
> +
>  #ifdef CONFIG_CGROUP_DEBUG
>  static struct cgroup_subsys_state *debug_css_alloc(struct cgroup *cont)
>  {
> -- 
> 1.8.0.2
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
