Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id C49536B0005
	for <linux-mm@kvack.org>; Tue,  5 Jan 2016 04:44:24 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id f206so20201885wmf.0
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 01:44:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z187si4121397wmb.114.2016.01.05.01.44.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Jan 2016 01:44:23 -0800 (PST)
Subject: Re: [PATCH 1/4] thp: add debugfs handle to split all huge pages
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1450957883-96356-2-git-send-email-kirill.shutemov@linux.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <568B9076.2060405@suse.cz>
Date: Tue, 5 Jan 2016 10:44:22 +0100
MIME-Version: 1.0
In-Reply-To: <1450957883-96356-2-git-send-email-kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On 12/24/2015 12:51 PM, Kirill A. Shutemov wrote:
> Writing 1 into 'split_huge_pages' will try to find and split all huge
> pages in the system. This is useful for debuging.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

It's not very optimized pfn scanner, but that shouldn't matter. I have 
but one suggestion and one fix below.

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   mm/huge_memory.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>   1 file changed, 59 insertions(+)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index a880f9addba5..99f2a0ecb621 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -27,6 +27,7 @@
>   #include <linux/userfaultfd_k.h>
>   #include <linux/page_idle.h>
>   #include <linux/swapops.h>
> +#include <linux/debugfs.h>
>
>   #include <asm/tlb.h>
>   #include <asm/pgalloc.h>
> @@ -3535,3 +3536,61 @@ static struct shrinker deferred_split_shrinker = {
>   	.scan_objects = deferred_split_scan,
>   	.seeks = DEFAULT_SEEKS,
>   };
> +
> +#ifdef CONFIG_DEBUG_FS
> +static int split_huge_pages_set(void *data, u64 val)
> +{
> +	struct zone *zone;
> +	struct page *page;
> +	unsigned long pfn, max_zone_pfn;
> +	unsigned long total = 0, split = 0;
> +
> +	if (val != 1)
> +		return -EINVAL;
> +
> +	for_each_populated_zone(zone) {
> +		max_zone_pfn = zone_end_pfn(zone);
> +		for (pfn = zone->zone_start_pfn; pfn < max_zone_pfn; pfn++) {
> +			if (!pfn_valid(pfn))
> +				continue;
> +
> +			page = pfn_to_page(pfn);
> +			if (!get_page_unless_zero(page))
> +				continue;
> +
> +			if (zone != page_zone(page))
> +				goto next;

I would do this check before get_page(...). Doesn't matter much, but 
looks odd.

> +
> +			if (!PageHead(page) || !PageAnon(page) ||
> +					PageHuge(page))
> +				goto next;
> +
> +			total++;
> +			lock_page(page);
> +			if (!split_huge_page(page))
> +				split++;
> +			unlock_page(page);
> +next:
> +			put_page(page);
> +		}
> +	}
> +
> +	pr_info("%lu of %lu THP split", split, total);
> +
> +	return 0;
> +}
> +DEFINE_SIMPLE_ATTRIBUTE(split_huge_pages_fops, NULL, split_huge_pages_set,
> +		"%llu\n");
> +
> +static int __init split_huge_pages_debugfs(void)
> +{
> +	void *ret;
> +
> +	ret = debugfs_create_file("split_huge_pages", 0644, NULL, NULL,
> +			&split_huge_pages_fops);
> +	if (!ret)
> +		pr_warn("Failed to create fault_around_bytes in debugfs");

s/fault_around_bytes/split_huge_pages/

> +	return 0;
> +}
> +late_initcall(split_huge_pages_debugfs);
> +#endif
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
