Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 9CF896B0069
	for <linux-mm@kvack.org>; Wed, 17 Oct 2012 18:11:56 -0400 (EDT)
Date: Wed, 17 Oct 2012 15:11:55 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v5 01/14] memcg: Make it possible to use the stock for
 more than one page.
Message-Id: <20121017151155.d417bd13.akpm@linux-foundation.org>
In-Reply-To: <1350382611-20579-2-git-send-email-glommer@parallels.com>
References: <1350382611-20579-1-git-send-email-glommer@parallels.com>
	<1350382611-20579-2-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Suleiman Souhlal <suleiman@google.com>

On Tue, 16 Oct 2012 14:16:38 +0400
Glauber Costa <glommer@parallels.com> wrote:

> From: Suleiman Souhlal <ssouhlal@FreeBSD.org>
> 
> We currently have a percpu stock cache scheme that charges one page at a
> time from memcg->res, the user counter. When the kernel memory
> controller comes into play, we'll need to charge more than that.
> 
> This is because kernel memory allocations will also draw from the user
> counter, and can be bigger than a single page, as it is the case with
> the stack (usually 2 pages) or some higher order slabs.
> 
> ...
>
> -/*
> - * Try to consume stocked charge on this cpu. If success, one page is consumed
> - * from local stock and true is returned. If the stock is 0 or charges from a
> - * cgroup which is not current target, returns false. This stock will be
> - * refilled.
> +/**
> + * consume_stock: Try to consume stocked charge on this cpu.
> + * @memcg: memcg to consume from.
> + * @nr_pages: how many pages to charge.
> + *
> + * The charges will only happen if @memcg matches the current cpu's memcg
> + * stock, and at least @nr_pages are available in that stock.  Failure to
> + * service an allocation will refill the stock.
> + *
> + * returns true if succesfull, false otherwise.

spello.

>   */
> -static bool consume_stock(struct mem_cgroup *memcg)
> +static bool consume_stock(struct mem_cgroup *memcg, int nr_pages)

I don't believe there is a case for nr_pages < 0 here?  If not then I
suggest that it would be clearer to use an unsigned type, like
memcg_stock_pcp.stock.

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
