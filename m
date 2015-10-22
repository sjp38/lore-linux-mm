Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f47.google.com (mail-lf0-f47.google.com [209.85.215.47])
	by kanga.kvack.org (Postfix) with ESMTP id E488D6B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 14:48:12 -0400 (EDT)
Received: by lfaz124 with SMTP id z124so58879707lfa.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:48:12 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id xe5si10449102lbb.65.2015.10.22.11.48.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 11:48:11 -0700 (PDT)
Date: Thu, 22 Oct 2015 21:47:57 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151022184757.GO18351@esperanza>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 22, 2015 at 12:21:33AM -0400, Johannes Weiner wrote:
...
> @@ -5500,13 +5524,38 @@ void sock_release_memcg(struct sock *sk)
>   */
>  bool mem_cgroup_charge_skmem(struct mem_cgroup *memcg, unsigned int nr_pages)
>  {
> +	unsigned int batch = max(CHARGE_BATCH, nr_pages);
>  	struct page_counter *counter;
> +	bool force = false;
>  
> -	if (page_counter_try_charge(&memcg->skmem, nr_pages, &counter))
> +	if (!cgroup_subsys_on_dfl(memory_cgrp_subsys)) {
> +		if (page_counter_try_charge(&memcg->skmem, nr_pages, &counter))
> +			return true;
> +		page_counter_charge(&memcg->skmem, nr_pages);
> +		return false;
> +	}
> +
> +	if (consume_stock(memcg, nr_pages))
>  		return true;
> +retry:
> +	if (page_counter_try_charge(&memcg->memory, batch, &counter))
> +		goto done;

Currently, we use memcg->memory only for charging memory pages. Besides,
every page charged to this counter (including kmem) has ->mem_cgroup
field set appropriately. This looks consistent and nice. As an extra
benefit, we can track all pages charged to a memory cgroup via
/proc/kapgecgroup.

Now, you charge "window size" to it, which AFAIU isn't necessarily equal
to the amount of memory actually consumed by the cgroup for socket
buffers. I think this looks ugly and inconsistent with the existing
behavior. I agree that we need to charge socker buffers to ->memory, but
IMO we should do that per each skb page, using memcg_kmem_charge_kmem
somewhere in alloc_skb_with_frags invoking the reclaimer just as we do
for kmalloc, while tcp window size control should stay aside.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
