Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A8628E0072
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 05:59:14 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id v14-v6so3317476edq.10
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 02:59:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g21-v6si8312571edr.396.2018.09.25.02.59.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Sep 2018 02:59:12 -0700 (PDT)
Subject: Re: [PATCH v2] memory_hotplug: Free pages as higher order
References: <1537854158-9766-1-git-send-email-arunks@codeaurora.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ccdbaf76-cbdd-759e-c6de-c5b738f156e9@suse.cz>
Date: Tue, 25 Sep 2018 11:59:09 +0200
MIME-Version: 1.0
In-Reply-To: <1537854158-9766-1-git-send-email-arunks@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>, kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, osalvador@suse.de, malat@debian.org, yasu.isimatu@gmail.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org
Cc: vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On 9/25/18 7:42 AM, Arun KS wrote:
> When free pages are done with higher order, time spend on
> coalescing pages by buddy allocator can be reduced. With
> section size of 256MB, hot add latency of a single section
> shows improvement from 50-60 ms to less than 1 ms, hence
> improving the hot add latency by 60%.
> 
> Modify external providers of online callback to align with
> the change.
> 
> Signed-off-by: Arun KS <arunks@codeaurora.org>

Hi,

> @@ -655,26 +655,53 @@ void __online_page_free(struct page *page)
>  }
>  EXPORT_SYMBOL_GPL(__online_page_free);
>  
> -static void generic_online_page(struct page *page)
> +static int generic_online_page(struct page *page, unsigned int order)
>  {
> -	__online_page_set_limits(page);
> -	__online_page_increment_counters(page);
> -	__online_page_free(page);
> +	unsigned long nr_pages = 1 << order;
> +	struct page *p = page;
> +	unsigned int loop;
> +
> +	for (loop = 0 ; loop < nr_pages ; loop++, p++) {
> +		__ClearPageReserved(p);
> +		set_page_count(p, 0);
> +	}
> +
> +	adjust_managed_page_count(page, nr_pages);
> +	set_page_refcounted(page);
> +	__free_pages(page, order);
> +
> +	return 0;

This seems like almost complete copy of __free_pages_boot_core(), could
you do some code reuse instead? I think Michal Hocko also suggested that.

Thanks,
Vlastimil
