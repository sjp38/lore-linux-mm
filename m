Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5693D6B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 18:42:36 -0400 (EDT)
Date: Mon, 22 Jun 2009 15:43:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Low overhead patches for the memory cgroup controller (v5)
Message-Id: <20090622154343.9cdbf23a.akpm@linux-foundation.org>
In-Reply-To: <20090615043900.GF23577@balbir.in.ibm.com>
References: <20090615043900.GF23577@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kamezawa.hiroyuki@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com, menage@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jun 2009 10:09:00 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

>
> ...
> 
> This patch changes the memory cgroup and removes the overhead associated
> with accounting all pages in the root cgroup. As a side-effect, we can
> no longer set a memory hard limit in the root cgroup.
> 
> A new flag to track whether the page has been accounted or not
> has been added as well. Flags are now set atomically for page_cgroup,
> pcg_default_flags is now obsolete and removed.
> 
> ...
>
> @@ -1114,9 +1121,22 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>  		css_put(&mem->css);
>  		return;
>  	}
> +
>  	pc->mem_cgroup = mem;
>  	smp_wmb();
> -	pc->flags = pcg_default_flags[ctype];
> +	switch (ctype) {
> +	case MEM_CGROUP_CHARGE_TYPE_CACHE:
> +	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
> +		SetPageCgroupCache(pc);
> +		SetPageCgroupUsed(pc);
> +		break;
> +	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
> +		ClearPageCgroupCache(pc);
> +		SetPageCgroupUsed(pc);
> +		break;
> +	default:
> +		break;
> +	}

Do we still need the smp_wmb()?

It's hard to say, because we forgot to document it :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
