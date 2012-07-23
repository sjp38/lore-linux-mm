Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 8CDB36B005A
	for <linux-mm@kvack.org>; Sun, 22 Jul 2012 22:26:54 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 23 Jul 2012 07:56:51 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6N2QlVJ21364938
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 07:56:47 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6N2Qk6T001127
	for <linux-mm@kvack.org>; Mon, 23 Jul 2012 12:26:46 +1000
Date: Mon, 23 Jul 2012 10:26:45 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] memcg: add mem_cgroup_from_css() helper
Message-ID: <20120723022645.GA18871@kernel>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1343007863-18144-1-git-send-email-liwanp@linux.vnet.ibm.com>
 <20120723020856.GA24965@shangw.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120723020856.GA24965@shangw.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWAHiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org

On Mon, Jul 23, 2012 at 10:08:56AM +0800, Gavin Shan wrote:
>
>For this case, we usually fix the build error on top of linux-next.
>It seems that you're changing the original patch and send again, which
>isn't reasonable, man :-)

OK, I will send a patch just fix build error against linux-next.

Regards,
Wanpeng Li

>
>Thanks,
>Gavin
>
>>Changelog v2:
>>* fix too many args to mem_cgroup_from_css() (spotted by Kirill A. Shutemov)
>>* fix kernel build failed (spotted by Fengguang)
>>
>>Add a mem_cgroup_from_css() helper to replace open-coded invokations of
>>container_of().  To clarify the code and to add a little more type safety.
>>
>>Acked-by: Michal Hocko <mhocko@suse.cz>
>>Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
>>
>>---
>> mm/memcontrol.c |   19 +++++++++++--------
>> 1 files changed, 11 insertions(+), 8 deletions(-)
>>
>>diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>>index 883283d..f0c7639 100644
>>--- a/mm/memcontrol.c
>>+++ b/mm/memcontrol.c
>>@@ -407,6 +407,12 @@ enum charge_type {
>> static void mem_cgroup_get(struct mem_cgroup *memcg);
>> static void mem_cgroup_put(struct mem_cgroup *memcg);
>>
>>+static inline 
>>+struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *s)
>>+{
>>+	return container_of(s, struct mem_cgroup, css);
>>+}
>>+
>> /* Writing them here to avoid exposing memcg's inner layout */
>> #ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
>> #include <net/sock.h>
>>@@ -864,9 +870,8 @@ static void memcg_check_events(struct mem_cgroup *memcg, struct page *page)
>>
>> struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
>> {
>>-	return container_of(cgroup_subsys_state(cont,
>>-				mem_cgroup_subsys_id), struct mem_cgroup,
>>-				css);
>>+	return mem_cgroup_from_css(cgroup_subsys_state(cont,
>>+				mem_cgroup_subsys_id));
>> }
>>
>> struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>>@@ -879,8 +884,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>> 	if (unlikely(!p))
>> 		return NULL;
>>
>>-	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
>>-				struct mem_cgroup, css);
>>+	return mem_cgroup_from_css(task_subsys_state(p, mem_cgroup_subsys_id));
>> }
>>
>> struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
>>@@ -966,8 +970,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
>> 		css = css_get_next(&mem_cgroup_subsys, id + 1, &root->css, &id);
>> 		if (css) {
>> 			if (css == &root->css || css_tryget(css))
>>-				memcg = container_of(css,
>>-						     struct mem_cgroup, css);
>>+				memcg = mem_cgroup_from_css(css);
>> 		} else
>> 			id = 0;
>> 		rcu_read_unlock();
>>@@ -2429,7 +2432,7 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
>> 	css = css_lookup(&mem_cgroup_subsys, id);
>> 	if (!css)
>> 		return NULL;
>>-	return container_of(css, struct mem_cgroup, css);
>>+	return mem_cgroup_from_css(css);
>> }
>>
>> struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>>-- 
>>1.7.7.6
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
