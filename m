Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 394396B00F5
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 16:13:30 -0400 (EDT)
Date: Thu, 21 Jun 2012 13:13:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] memcg: clean up force_empty_list() return value
 check
Message-Id: <20120621131328.1e906266.akpm@linux-foundation.org>
In-Reply-To: <4FE2D87D.2090500@jp.fujitsu.com>
References: <4FDF17A3.9060202@jp.fujitsu.com>
	<4FDF1830.1000504@jp.fujitsu.com>
	<20120619165815.5ce24be7.akpm@linux-foundation.org>
	<4FE2D747.20506@jp.fujitsu.com>
	<4FE2D87D.2090500@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, 21 Jun 2012 17:17:01 +0900
Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> Now, mem_cgroup_force_empty_list() just returns 0 or -EBUSY and
> -EBUSY is just indicating 'you need to retry.'.
> This patch makes mem_cgroup_force_empty_list() as boolean function and
> make the logic simpler.
> 

For some reason I'm having trouble applying these patches - many
rejects, need to massage it in by hand.

> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3797,7 +3797,7 @@ unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>    * This routine traverse page_cgroup in given list and drop them all.
>    * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
>    */
> -static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
> +static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>   				int node, int zid, enum lru_list lru)

Let's document the return value.  The mem_cgroup_force_empty_list()
comment is a mess so I tried to help it a bit.  How does this look?

--- a/mm/memcontrol.c~memcg-make-mem_cgroup_force_empty_list-return-bool-fix
+++ a/mm/memcontrol.c
@@ -3609,8 +3609,10 @@ unsigned long mem_cgroup_soft_limit_recl
 }
 
 /*
- * This routine traverse page_cgroup in given list and drop them all.
- * *And* this routine doesn't reclaim page itself, just removes page_cgroup.
+ * Traverse a specified page_cgroup list and try to drop them all.  This doesn't
+ * reclaim the pages page themselves - it just removes the page_cgroups.
+ * Returns true if some page_cgroups were not freed, indicating that the caller
+ * must retry this operation.
  */
 static bool mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
 				int node, int zid, enum lru_list lru)
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
