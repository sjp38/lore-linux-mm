Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f51.google.com (mail-bk0-f51.google.com [209.85.214.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1457A6B0080
	for <linux-mm@kvack.org>; Mon, 24 Mar 2014 12:30:41 -0400 (EDT)
Received: by mail-bk0-f51.google.com with SMTP id 6so560365bkj.24
        for <linux-mm@kvack.org>; Mon, 24 Mar 2014 09:30:41 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id qr7si940554bkb.78.2014.03.24.09.30.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 24 Mar 2014 09:30:40 -0700 (PDT)
Date: Mon, 24 Mar 2014 12:30:35 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [next:master 191/463] mm/memcontrol.c:1074:19: sparse: symbol
 'get_mem_cgroup_from_mm' was not declared. Should it be static?
Message-ID: <20140324163035.GL4407@cmpxchg.org>
References: <532df757.AkU5AH07Cpb86z5c%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <532df757.AkU5AH07Cpb86z5c%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kbuild-all@01.org

On Sun, Mar 23, 2014 at 04:49:27AM +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
> head:   06ed26d1de59ce7cbbe68378b7e470be169750e5
> commit: 83ab64d4c75418a019166519d2f95015868f79a4 [191/463] memcg: get_mem_cgroup_from_mm()
> reproduce: make C=1 CF=-D__CHECK_ENDIAN__
> 
> 
> sparse warnings: (new ones prefixed by >>)
> 
> >> mm/memcontrol.c:1074:19: sparse: symbol 'get_mem_cgroup_from_mm' was not declared. Should it be static?
>    mm/slab.h:182:18: sparse: incompatible types in comparison expression (different address spaces)
>    mm/slab.h:182:18: sparse: incompatible types in comparison expression (different address spaces)
>    mm/slab.h:182:18: sparse: incompatible types in comparison expression (different address spaces)
>    mm/memcontrol.c:5562:21: sparse: incompatible types in comparison expression (different address spaces)
>    mm/memcontrol.c:5564:21: sparse: incompatible types in comparison expression (different address spaces)
>    mm/memcontrol.c:7015:31: sparse: incompatible types in comparison expression (different address spaces)
> 
> Please consider folding the attached diff :-)

Yeah, there are no external users.

> From: Fengguang Wu <fengguang.wu@intel.com>
> Subject: [PATCH next] memcg: get_mem_cgroup_from_mm() can be static
> TO: Johannes Weiner <hannes@cmpxchg.org>
> CC: cgroups@vger.kernel.org 
> CC: linux-mm@kvack.org 
> CC: linux-kernel@vger.kernel.org 
> 
> CC: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
> ---
>  memcontrol.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 28fd509..bdb62eb 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1071,7 +1071,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>  	return mem_cgroup_from_css(task_css(p, mem_cgroup_subsys_id));
>  }
>  
> -struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
> +static struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
>  {
>  	struct mem_cgroup *memcg = NULL;
>  

Yes, but also update the headers:

---
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH] memcg-get_mem_cgroup_from_mm-fix.patch

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index e9dfcdad24c5..b569b8be5c5a 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -94,7 +94,6 @@ bool task_in_mem_cgroup(struct task_struct *task,
 
 extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
 extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
-extern struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm);
 
 extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
 extern struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css);
@@ -294,11 +293,6 @@ static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 	return NULL;
 }
 
-static inline struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
-{
-	return NULL;
-}
-
 static inline bool mm_match_cgroup(struct mm_struct *mm,
 		struct mem_cgroup *memcg)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b4b6aef562fa..92b48c0a8cfd 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1071,7 +1071,7 @@ struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
 	return mem_cgroup_from_css(task_css(p, memory_cgrp_id));
 }
 
-struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
+static struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 {
 	struct mem_cgroup *memcg = NULL;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
