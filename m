Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F2E56B0024
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 04:27:21 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j12so2284513pff.18
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 01:27:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k73si2489513pgc.707.2018.03.21.01.27.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 21 Mar 2018 01:27:19 -0700 (PDT)
Subject: Re: [PATCH 1/1] mm/page_owner: fix recursion bug after changing skip
 entries
References: <CGME20180321043818epcas5p176fe0e0bbfce685420df2bfb7a421acd@epcas5p1.samsung.com>
 <1521607043-34670-1-git-send-email-maninder1.s@samsung.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <40171c50-4466-6589-3968-024f936e5c7a@suse.cz>
Date: Wed, 21 Mar 2018 09:25:27 +0100
MIME-Version: 1.0
In-Reply-To: <1521607043-34670-1-git-send-email-maninder1.s@samsung.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Maninder Singh <maninder1.s@samsung.com>, akpm@linux-foundation.org, mhocko@suse.com, osalvador@techadventures.net, gregkh@linuxfoundation.org, ayush.m@samsung.com, guptap@codeaurora.org, vinmenon@codeaurora.org, gomonovych@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, a.sahrawat@samsung.com, pankaj.m@samsung.com, Vaneet Narang <v.narang@samsung.com>

On 03/21/2018 05:37 AM, Maninder Singh wrote:
> This patch fixes "5f48f0bd4e368425db4424b9afd1bd251d32367a".
> (mm, page_owner: skip unnecessary stack_trace entries)
> 
> Because if we skip first two entries then logic of checking count
> value as 2 for recursion is broken and code will go in one depth
> recursion.
> 
> so we need to check only one call of _RET_IP(__set_page_owner)
> while checking for recursion.
> 
> Current Backtrace while checking for recursion:-
> 
> (save_stack)             from (__set_page_owner)  // (But recursion returns true here)
> (__set_page_owner)       from (get_page_from_freelist)
> (get_page_from_freelist) from (__alloc_pages_nodemask)
> (__alloc_pages_nodemask) from (depot_save_stack)
> (depot_save_stack)       from (save_stack)       // recursion should return true here
> (save_stack)             from (__set_page_owner)
> (__set_page_owner)       from (get_page_from_freelist)
> (get_page_from_freelist) from (__alloc_pages_nodemask+)
> (__alloc_pages_nodemask) from (depot_save_stack)
> (depot_save_stack)       from (save_stack)
> (save_stack)             from (__set_page_owner)
> (__set_page_owner)       from (get_page_from_freelist)
> 
> Correct Backtrace with fix:
> 
> (save_stack)             from (__set_page_owner) // recursion returned true here
> (__set_page_owner)       from (get_page_from_freelist)
> (get_page_from_freelist) from (__alloc_pages_nodemask+)
> (__alloc_pages_nodemask) from (depot_save_stack)
> (depot_save_stack)       from (save_stack)
> (save_stack)             from (__set_page_owner)
> (__set_page_owner)       from (get_page_from_freelist)
> 
> Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
> Signed-off-by: Vaneet Narang <v.narang@samsung.com>
Fixes: 5f48f0bd4e36 ("mm, page_owner: skip unnecessary stack_trace entries")

Good catch.
Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/page_owner.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_owner.c b/mm/page_owner.c
> index 8592543..46ab1c4 100644
> --- a/mm/page_owner.c
> +++ b/mm/page_owner.c
> @@ -123,13 +123,13 @@ void __reset_page_owner(struct page *page, unsigned int order)
>  static inline bool check_recursive_alloc(struct stack_trace *trace,
>  					unsigned long ip)
>  {
> -	int i, count;
> +	int i;
>  
>  	if (!trace->nr_entries)
>  		return false;
>  
> -	for (i = 0, count = 0; i < trace->nr_entries; i++) {
> -		if (trace->entries[i] == ip && ++count == 2)
> +	for (i = 0; i < trace->nr_entries; i++) {
> +		if (trace->entries[i] == ip)
>  			return true;
>  	}
>  
> 
