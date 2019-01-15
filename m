Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5BE668E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 12:02:16 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c34so1323241edb.8
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 09:02:16 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25si1767596edr.258.2019.01.15.09.02.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 09:02:14 -0800 (PST)
Date: Tue, 15 Jan 2019 18:02:13 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm, memory_hotplug: __offline_pages fix wrong locking
Message-ID: <20190115170213.GA26069@quack2.suse.cz>
References: <20190115120307.22768-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190115120307.22768-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Oscar Salvador <OSalvador@suse.com>, Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue 15-01-19 13:03:07, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Jan has noticed that we do double unlock on some failure paths when
> offlining a page range. This is indeed the case when test_pages_in_a_zone
> respp. start_isolate_page_range fail. This was an omission when forward
> porting the debugging patch from an older kernel.
> 
> Fix the issue by dropping mem_hotplug_done from the failure condition
> and keeping the single unlock in the catch all failure path.
> 
> Reported-by: Jan Kara <jack@suse.cz>
> Fixes: 7960509329c2 ("mm, memory_hotplug: print reason for the offlining failure")
> Signed-off-by: Michal Hocko <mhocko@suse.com>

The patch looks good to me so feel free to add:

Reviewed-by: Jan Kara <jack@suse.cz>

Also it fixes the test that previously crashed for me so you can add:

Tested-by: Jan Kara <jack@suse.cz>

								Honza


> ---
>  mm/memory_hotplug.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index b9a667d36c55..faeeaccc5fae 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1576,7 +1576,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	   we assume this for now. .*/
>  	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start,
>  				  &valid_end)) {
> -		mem_hotplug_done();
>  		ret = -EINVAL;
>  		reason = "multizone range";
>  		goto failed_removal;
> @@ -1591,7 +1590,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  				       MIGRATE_MOVABLE,
>  				       SKIP_HWPOISON | REPORT_FAILURE);
>  	if (ret) {
> -		mem_hotplug_done();
>  		reason = "failure to isolate range";
>  		goto failed_removal;
>  	}
> -- 
> 2.20.1
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
