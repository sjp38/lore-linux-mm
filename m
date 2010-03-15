Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D1ED06B0047
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 17:50:49 -0400 (EDT)
Date: Mon, 15 Mar 2010 14:50:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] memcg: oom wakeup filter
Message-Id: <20100315145013.ee5919fd.akpm@linux-foundation.org>
In-Reply-To: <20100312143137.f4cf0a04.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100312143137.f4cf0a04.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kirill@shutemov.name" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Mar 2010 14:31:37 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> +static int memcg_oom_wake_function(wait_queue_t *wait,
> +	unsigned mode, int sync, void *arg)
> +{
> +	struct mem_cgroup *wake_mem = (struct mem_cgroup *)arg;
> +	struct oom_wait_info *oom_wait_info;
> +
> +	/* both of oom_wait_info->mem and wake_mem are stable under us */
> +	oom_wait_info = container_of(wait, struct oom_wait_info, wait);
> +
> +	if (oom_wait_info->mem == wake_mem)
> +		goto wakeup;
> +	/* if no hierarchy, no match */
> +	if (!oom_wait_info->mem->use_hierarchy || !wake_mem->use_hierarchy)
> +		return 0;
> +	/* check hierarchy */
> +	if (!css_is_ancestor(&oom_wait_info->mem->css, &wake_mem->css) &&
> +	    !css_is_ancestor(&wake_mem->css, &oom_wait_info->mem->css))
> +		return 0;
> +
> +wakeup:
> +	return autoremove_wake_function(wait, mode, sync, arg);
> +}

What are the locking rules for calling css_is_ancestor()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
