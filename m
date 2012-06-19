Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id F3A7A6B005D
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 19:58:16 -0400 (EDT)
Date: Tue, 19 Jun 2012 16:58:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] memcg: clean up force_empty_list() return value
 check
Message-Id: <20120619165815.5ce24be7.akpm@linux-foundation.org>
In-Reply-To: <4FDF1830.1000504@jp.fujitsu.com>
References: <4FDF17A3.9060202@jp.fujitsu.com>
	<4FDF1830.1000504@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 18 Jun 2012 20:59:44 +0900
Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> 
> By commit "memcg: move charges to root cgroup if use_hierarchy=0"
> mem_cgroup_move_parent() only returns -EBUSY, -EINVAL.
> So, we can remove -ENOMEM and -EINTR checks.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    5 -----
>  1 files changed, 0 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index cf8a0f6..726b7c6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3847,8 +3847,6 @@ static int mem_cgroup_force_empty_list(struct mem_cgroup *memcg,
>  		pc = lookup_page_cgroup(page);
>  
>  		ret = mem_cgroup_move_parent(page, pc, memcg, GFP_KERNEL);
> -		if (ret == -ENOMEM || ret == -EINTR)
> -			break;
>  
>  		if (ret == -EBUSY || ret == -EINVAL) {

This looks a bit fragile - if mem_cgroup_move_parent() is later changed
(intentionally or otherwise!) to return -Esomethingelse then
mem_cgroup_force_empty_list() will subtly break.  Why not just do

		if (ret < 0)

here?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
