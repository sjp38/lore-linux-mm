Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 04B5E6B0003
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 11:32:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b34-v6so3430499ede.5
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 08:32:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w25-v6si6543782edc.278.2018.10.10.08.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 08:32:55 -0700 (PDT)
Subject: Re: [PATCH v5 1/2] memory_hotplug: Free pages as higher order
References: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <72215e75-6c7e-0aef-c06e-e3aba47cf806@suse.cz>
Date: Wed, 10 Oct 2018 17:30:11 +0200
MIME-Version: 1.0
In-Reply-To: <1538727006-5727-1-git-send-email-arunks@codeaurora.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>, kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com, boris.ostrovsky@oracle.com, jgross@suse.com, akpm@linux-foundation.org, dan.j.williams@intel.com, mhocko@suse.com, iamjoonsoo.kim@lge.com, gregkh@linuxfoundation.org, osalvador@suse.de, malat@debian.org, kirill.shutemov@linux.intel.com, jrdr.linux@gmail.com, yasu.isimatu@gmail.com, mgorman@techsingularity.net, aaron.lu@intel.com, devel@linuxdriverproject.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xen-devel@lists.xenproject.org
Cc: vatsa@codeaurora.org, vinmenon@codeaurora.org, getarunks@gmail.com

On 10/5/18 10:10 AM, Arun KS wrote:
> When free pages are done with higher order, time spend on
> coalescing pages by buddy allocator can be reduced. With
> section size of 256MB, hot add latency of a single section
> shows improvement from 50-60 ms to less than 1 ms, hence
> improving the hot add latency by 60%. Modify external
> providers of online callback to align with the change.
> 
> Signed-off-by: Arun KS <arunks@codeaurora.org>

[...]

> @@ -655,26 +655,44 @@ void __online_page_free(struct page *page)
>  }
>  EXPORT_SYMBOL_GPL(__online_page_free);
>  
> -static void generic_online_page(struct page *page)
> +static int generic_online_page(struct page *page, unsigned int order)
>  {
> -	__online_page_set_limits(page);

This is now not called anymore, although the xen/hv variants still do
it. The function seems empty these days, maybe remove it as a followup
cleanup?

> -	__online_page_increment_counters(page);
> -	__online_page_free(page);
> +	__free_pages_core(page, order);
> +	totalram_pages += (1UL << order);
> +#ifdef CONFIG_HIGHMEM
> +	if (PageHighMem(page))
> +		totalhigh_pages += (1UL << order);
> +#endif

__online_page_increment_counters() would have used
adjust_managed_page_count() which would do the changes under
managed_page_count_lock. Are we safe without the lock? If yes, there
should perhaps be a comment explaining why.
