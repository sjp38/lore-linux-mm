Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 122CD6B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 08:19:40 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id q58so2101992wes.35
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 05:19:40 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cc6si15410774wib.63.2014.07.15.05.19.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 05:19:38 -0700 (PDT)
Date: Tue, 15 Jul 2014 14:19:35 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 13/13] mm: memcontrol: rewrite uncharge API
Message-ID: <20140715121935.GB9366@dhcp22.suse.cz>
References: <1403124045-24361-1-git-send-email-hannes@cmpxchg.org>
 <1403124045-24361-14-git-send-email-hannes@cmpxchg.org>
 <20140715082545.GA9366@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140715082545.GA9366@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

[...]
> +/**
> + * mem_cgroup_migrate - migrate a charge to another page
> + * @oldpage: currently charged page
> + * @newpage: page to transfer the charge to
> + * @lrucare: page might be on LRU already

which one? I guess the newpage?

> + *
> + * Migrate the charge from @oldpage to @newpage.
> + *
> + * Both pages must be locked, @newpage->mapping must be set up.
> + */
> +void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
> +			bool lrucare)
> +{
> +	unsigned int nr_pages = 1;
> +	struct page_cgroup *pc;
> +
> +	VM_BUG_ON_PAGE(!PageLocked(oldpage), oldpage);
> +	VM_BUG_ON_PAGE(!PageLocked(newpage), newpage);
> +	VM_BUG_ON_PAGE(PageLRU(oldpage), oldpage);
> +	VM_BUG_ON_PAGE(PageLRU(newpage), newpage);

	VM_BUG_ON_PAGE(PageLRU(newpage) && !lruvec, newpage);

> +	VM_BUG_ON_PAGE(PageAnon(oldpage) != PageAnon(newpage), newpage);
> +
> +	if (mem_cgroup_disabled())
> +		return;
> +
> +	pc = lookup_page_cgroup(oldpage);
> +	if (!PageCgroupUsed(pc))
> +		return;
> +
> +	/* Already migrated */
> +	if (!(pc->flags & PCG_MEM))
> +		return;
> +
> +	VM_BUG_ON_PAGE(do_swap_account && !(pc->flags & PCG_MEMSW), oldpage);
> +	pc->flags &= ~(PCG_MEM | PCG_MEMSW);

What about PCG_USED?
Wouldn't we uncharge the currently transfered charge when oldpage does
its last put_page when the migration is done?

On a not directly related note. I was quite surprised to see that
__unmap_and_move calls putback_lru_page on oldpage even when migration
succeeded. So it goes through mem_cgroup_page_lruvec which checks
PCG_USED and resets pc->mem_cgroup to root for !PCG_USED.

> +
> +	if (PageTransHuge(oldpage)) {
> +		nr_pages <<= compound_order(oldpage);
> +		VM_BUG_ON_PAGE(!PageTransHuge(oldpage), oldpage);
> +		VM_BUG_ON_PAGE(!PageTransHuge(newpage), newpage);
> +	}
> +
> +	commit_charge(newpage, pc->mem_cgroup, nr_pages, lrucare);
> +}
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
