Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6440E6B004A
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 10:02:56 -0400 (EDT)
Date: Wed, 29 Sep 2010 23:02:52 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: Re: [BUGFIX][PATCH] memcg: fix thresholds with use_hierarchy == 1
Message-Id: <20100929230252.f593abb1.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <1285763245-19408-1-git-send-email-kirill@shutemov.name>
References: <1285763245-19408-1-git-send-email-kirill@shutemov.name>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutsemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Sep 2010 15:27:25 +0300
"Kirill A. Shutsemov" <kirill@shutemov.name> wrote:

> From: Kirill A. Shutemov <kirill@shutemov.name>
> 
> We need to check parent's thresholds if parent has use_hierarchy == 1 to
> be sure that parent's threshold events will be triggered even if parent
> itself is not active (no MEM_CGROUP_EVENTS).
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
> ---
>  mm/memcontrol.c |   17 ++++++++++++++---
>  1 files changed, 14 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3eed583..196f710 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3587,9 +3587,20 @@ unlock:
>  
>  static void mem_cgroup_threshold(struct mem_cgroup *memcg)
>  {
> -	__mem_cgroup_threshold(memcg, false);
> -	if (do_swap_account)
> -		__mem_cgroup_threshold(memcg, true);
> +	struct cgroup *parent;
> +
> +	while (1) {
> +		__mem_cgroup_threshold(memcg, false);
> +		if (do_swap_account)
> +			__mem_cgroup_threshold(memcg, true);
> +
> +		parent = memcg->css.cgroup->parent;
> +		if (!parent)
> +			break;
> +		memcg = mem_cgroup_from_cont(parent);
> +		if (!memcg->use_hierarchy)
> +			break;
> +	}
I think you can simplify this part by using parent_mem_cgroup() like:

	parent = parent_mem_cgroup(memcg);
	if (!memcg)
		break;

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
