Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8D7826B0047
	for <linux-mm@kvack.org>; Fri,  1 Oct 2010 05:22:48 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o919HYWt028536
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 03:17:34 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o919MjFX207144
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 03:22:45 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o919Mi5P015207
	for <linux-mm@kvack.org>; Fri, 1 Oct 2010 03:22:44 -0600
Date: Fri, 1 Oct 2010 14:52:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH v2] memcg: fix thresholds with use_hierarchy == 1
Message-ID: <20101001092239.GG4261@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1285841792-23664-1-git-send-email-kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1285841792-23664-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutsemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Kirill A. Shutsemov <kirill@shutemov.name> [2010-09-30 13:16:32]:

> From: Kirill A. Shutemov <kirill@shutemov.name>
> 
> We need to check parent's thresholds if parent has use_hierarchy == 1 to
> be sure that parent's threshold events will be triggered even if parent
> itself is not active (no MEM_CGROUP_EVENTS).
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> ---
>  mm/memcontrol.c |   10 +++++++---
>  1 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3eed583..df40eaf 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3587,9 +3587,13 @@ unlock:
> 
>  static void mem_cgroup_threshold(struct mem_cgroup *memcg)
>  {
> -	__mem_cgroup_threshold(memcg, false);
> -	if (do_swap_account)
> -		__mem_cgroup_threshold(memcg, true);
> +	while (memcg) {
> +		__mem_cgroup_threshold(memcg, false);
> +		if (do_swap_account)
> +			__mem_cgroup_threshold(memcg, true);
> +
> +		memcg =  parent_mem_cgroup(memcg);
> +	}
>  }
>

Good catch!

 
Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
