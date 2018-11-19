Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0B4506B17AF
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 07:13:10 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c18so1340861edt.23
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 04:13:09 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 6-v6si1674585edo.127.2018.11.19.04.13.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 04:13:08 -0800 (PST)
Date: Mon, 19 Nov 2018 13:13:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1 7/8] PM / Hibernate: use pfn_to_online_page()
Message-ID: <20181119121306.GI22247@dhcp22.suse.cz>
References: <20181119101616.8901-1-david@redhat.com>
 <20181119101616.8901-8-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181119101616.8901-8-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>

On Mon 19-11-18 11:16:15, David Hildenbrand wrote:
> Let's use pfn_to_online_page() instead of pfn_to_page() when checking
> for saveable pages to not save/restore offline memory sections.
> 
> Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
> Cc: Pavel Machek <pavel@ucw.cz>
> Cc: Len Brown <len.brown@intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>

I have only a very vague understanding of this specific code but I do
not really see any real reason for checking offlined ranges. Also
offline pfn ranges might have uninitialized struct pages so making
any decisions of the struct page is basically undefined behavior.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  kernel/power/snapshot.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
> index 640b2034edd6..87e6dd57819f 100644
> --- a/kernel/power/snapshot.c
> +++ b/kernel/power/snapshot.c
> @@ -1215,8 +1215,8 @@ static struct page *saveable_highmem_page(struct zone *zone, unsigned long pfn)
>  	if (!pfn_valid(pfn))
>  		return NULL;
>  
> -	page = pfn_to_page(pfn);
> -	if (page_zone(page) != zone)
> +	page = pfn_to_online_page(pfn);
> +	if (!page || page_zone(page) != zone)
>  		return NULL;
>  
>  	BUG_ON(!PageHighMem(page));
> @@ -1277,8 +1277,8 @@ static struct page *saveable_page(struct zone *zone, unsigned long pfn)
>  	if (!pfn_valid(pfn))
>  		return NULL;
>  
> -	page = pfn_to_page(pfn);
> -	if (page_zone(page) != zone)
> +	page = pfn_to_online_page(pfn);
> +	if (!page || page_zone(page) != zone)
>  		return NULL;
>  
>  	BUG_ON(PageHighMem(page));
> -- 
> 2.17.2

-- 
Michal Hocko
SUSE Labs
