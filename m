Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 48A886B0255
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 09:58:56 -0500 (EST)
Received: by wmec201 with SMTP id c201so73668874wme.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:58:55 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id fk13si20309592wjc.15.2015.11.25.06.58.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 06:58:55 -0800 (PST)
Received: by wmuu63 with SMTP id u63so141412759wmu.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:58:55 -0800 (PST)
Date: Wed, 25 Nov 2015 15:58:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 7/9] mm, page_owner: dump page owner info from
 dump_page()
Message-ID: <20151125145853.GM27283@dhcp22.suse.cz>
References: <1448368581-6923-1-git-send-email-vbabka@suse.cz>
 <1448368581-6923-8-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448368581-6923-8-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Tue 24-11-15 13:36:19, Vlastimil Babka wrote:
> The page_owner mechanism is useful for dealing with memory leaks. By reading
> /sys/kernel/debug/page_owner one can determine the stack traces leading to
> allocations of all pages, and find e.g. a buggy driver.
> 
> This information might be also potentially useful for debugging, such as the
> VM_BUG_ON_PAGE() calls to dump_page(). So let's print the stored info from
> dump_page().
> 
> Example output:
> 
> page:ffffea0002868a00 count:1 mapcount:0 mapping:ffff8800bba8e958 index:0x63a22c
> flags: 0x1fffff80000060(lru|active)
> page dumped because: VM_BUG_ON_PAGE(1)
> page->mem_cgroup:ffff880138efdc00
> page allocated via order 0, migratetype Movable, gfp_mask 0x2420848(GFP_NOFS|GFP_NOFAIL|GFP_HARDWALL|GFP_MOVABLE)
>  [<ffffffff81164e8a>] __alloc_pages_nodemask+0x15a/0xa30
>  [<ffffffff811ab808>] alloc_pages_current+0x88/0x120
>  [<ffffffff8115bc36>] __page_cache_alloc+0xe6/0x120
>  [<ffffffff8115c226>] pagecache_get_page+0x56/0x200
>  [<ffffffff812058c2>] __getblk_slow+0xd2/0x2b0
>  [<ffffffff81205ae0>] __getblk_gfp+0x40/0x50
>  [<ffffffffa0283abe>] jbd2_journal_get_descriptor_buffer+0x3e/0x90 [jbd2]
>  [<ffffffffa027c793>] jbd2_journal_commit_transaction+0x8e3/0x1870 [jbd2]
> page has been migrated, last migrate reason: compaction

Nice! This can be really helpful.

> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Appart from a typo below, looks good to me
Acked-by: Michal Hocko <mhocko@suse.com>

[...]

> +void __dump_page_owner(struct page *page)
> +{
> +	struct page_ext *page_ext = lookup_page_ext(page);
> +	struct stack_trace trace = {
> +		.nr_entries = page_ext->nr_entries,
> +		.entries = &page_ext->trace_entries[0],
> +	};
> +	gfp_t gfp_mask = page_ext->gfp_mask;
> +	int mt = gfpflags_to_migratetype(gfp_mask);
> +
> +	if (!test_bit(PAGE_EXT_OWNER, &page_ext->flags)) {
> +		pr_alert("page_owner info is not active (free page?)\n");
> +		return;
> +	}
> +			                        ;

Typo?

> +	pr_alert("page allocated via order %u, migratetype %s, gfp_mask 0x%x",
> +			page_ext->order, migratetype_names[mt], gfp_mask);
> +	dump_gfpflag_names(gfp_mask);
> +	print_stack_trace(&trace, 0);
> +
> +	if (page_ext->last_migrate_reason != -1)
> +		pr_alert("page has been migrated, last migrate reason: %s\n",
> +			migrate_reason_names[page_ext->last_migrate_reason]);
> +}
> +
>  static ssize_t
>  read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
>  {
> -- 
> 2.6.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
