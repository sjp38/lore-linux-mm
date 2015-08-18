Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B4CDC6B0253
	for <linux-mm@kvack.org>; Mon, 17 Aug 2015 20:31:43 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so119117051pac.2
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:31:43 -0700 (PDT)
Received: from mail-pa0-x232.google.com (mail-pa0-x232.google.com. [2607:f8b0:400e:c03::232])
        by mx.google.com with ESMTPS id nw2si27054065pbb.40.2015.08.17.17.31.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Aug 2015 17:31:43 -0700 (PDT)
Received: by paccq16 with SMTP id cq16so75494731pac.1
        for <linux-mm@kvack.org>; Mon, 17 Aug 2015 17:31:42 -0700 (PDT)
Date: Mon, 17 Aug 2015 17:31:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Patch V3 2/9] kernel/profile.c: Replace cpu_to_mem() with
 cpu_to_node()
In-Reply-To: <1439781546-7217-3-git-send-email-jiang.liu@linux.intel.com>
Message-ID: <alpine.DEB.2.10.1508171730260.5527@chino.kir.corp.google.com>
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com> <1439781546-7217-3-git-send-email-jiang.liu@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tang Chen <tangchen@cn.fujitsu.com>, Tejun Heo <tj@kernel.org>, Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org

On Mon, 17 Aug 2015, Jiang Liu wrote:

> Function profile_cpu_callback() allocates memory without specifying
> __GFP_THISNODE flag, so replace cpu_to_mem() with cpu_to_node()
> because cpu_to_mem() may cause suboptimal memory allocation if
> there's no free memory on the node returned by cpu_to_mem().
> 

Why is cpu_to_node() better with regard to free memory and NUMA locality?

> It's safe to use cpu_to_mem() because build_all_zonelists() also
> builds suitable fallback zonelist for memoryless node.
> 

Why reference that cpu_to_mem() is safe if you're changing away from it?

> Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
> ---
>  kernel/profile.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/kernel/profile.c b/kernel/profile.c
> index a7bcd28d6e9f..d14805bdcc4c 100644
> --- a/kernel/profile.c
> +++ b/kernel/profile.c
> @@ -336,7 +336,7 @@ static int profile_cpu_callback(struct notifier_block *info,
>  	switch (action) {
>  	case CPU_UP_PREPARE:
>  	case CPU_UP_PREPARE_FROZEN:
> -		node = cpu_to_mem(cpu);
> +		node = cpu_to_node(cpu);
>  		per_cpu(cpu_profile_flip, cpu) = 0;
>  		if (!per_cpu(cpu_profile_hits, cpu)[1]) {
>  			page = alloc_pages_exact_node(node,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
