Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id B76006B005A
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 22:09:03 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Sun, 22 Jul 2012 22:09:02 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 870876E8036
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 22:08:59 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6N28xvT38338670
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 22:08:59 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6N7dp4r026364
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 03:39:51 -0400
Date: Mon, 23 Jul 2012 10:08:56 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] memcg: add mem_cgroup_from_css() helper
Message-ID: <20120723020856.GA24965@shangw.(null)>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1343007863-18144-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1343007863-18144-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWAHiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Gavin Shan <shangw@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org


For this case, we usually fix the build error on top of linux-next.
It seems that you're changing the original patch and send again, which
isn't reasonable, man :-)

Thanks,
Gavin

>Changelog v2:
>* fix too many args to mem_cgroup_from_css() (spotted by Kirill A. Shutemov)
>* fix kernel build failed (spotted by Fengguang)
>
>Add a mem_cgroup_from_css() helper to replace open-coded invokations of
>container_of().  To clarify the code and to add a little more type safety.
>
>Acked-by: Michal Hocko <mhocko@suse.cz>
>Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>
>---
> mm/memcontrol.c |   19 +++++++++++--------
> 1 files changed, 11 insertions(+), 8 deletions(-)
>
>diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>index 883283d..f0c7639 100644
>--- a/mm/memcontrol.c
>+++ b/mm/memcontrol.c
>@@ -407,6 +407,12 @@ enum charge_type {
> static void mem_cgroup_get(struct mem_cgroup *memcg);
> static void mem_cgroup_put(struct mem_cgroup *memcg);
>
>+static inline 
>+struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
>+{
>+	return container_of(s, struct mem_cgroup, css);
>+}
>+
> /* Writing them here to avoid exposing memcg's inner layout */
> #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> #include <net/sock.h>
>@@ -864,9 +870,8 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
>
> struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
> {
>-	return container_of(cgroup_subsys_state(cont,
>-				mem_cgroup_subsys_id), struct mem_cgroup,
>-				css);
>+	return mem_cgroup_from_css(cgroup_subsys_state(cont,
>+				mem_cgroup_subsys_id));
> }
>
> struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>@@ -879,8 +884,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
> 	if (unlikely(!p))
> 		return NULL;
>
>-	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
>-				struct mem_cgroup, css);
>+	return mem_cgroup_from_css(task_subsys_state(p, mem_cgroup_subsys_id));
> }
>
> struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
>@@ -966,8 +970,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
> 		css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
> 		if (css) {
> 			if (css == &root->css || css_tryget(css))
>-				memcg = container_of(css,
>-						     struct mem_cgroup, css);
>+				memcg = mem_cgroup_from_css(css);
> 		} else
> 			id = 0;
> 		rcu_read_unlock();
>@@ -2429,7 +2432,7 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
> 	css = css_lookup(&mem_cgroup_subsys, id);
> 	if (!css)
> 		return NULL;
>-	return container_of(css, struct mem_cgroup, css);
>+	return mem_cgroup_from_css(css);
> }
>
> struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>-- 
>1.7.7.6
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
