Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 46B256B0258
	for <linux-mm@kvack.org>; Fri,  4 Dec 2015 03:46:16 -0500 (EST)
Received: by wmvv187 with SMTP id v187so63817969wmv.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 00:46:15 -0800 (PST)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id d3si17166704wja.39.2015.12.04.00.46.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Dec 2015 00:46:15 -0800 (PST)
Received: by wmvv187 with SMTP id v187so63817378wmv.1
        for <linux-mm@kvack.org>; Fri, 04 Dec 2015 00:46:14 -0800 (PST)
Date: Fri, 4 Dec 2015 09:46:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/memcontrol.c: use list_{first,next}_entry
Message-ID: <20151204084613.GA10021@dhcp22.suse.cz>
References: <9e62e3006561653fcbf0c49cf0b9c2b653a8ed0e.1449152124.git.geliangtang@163.com>
 <20151203162718.GK9264@dhcp22.suse.cz>
 <20151203192750.GA19242@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151203192750.GA19242@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Geliang Tang <geliangtang@163.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 03-12-15 14:27:50, Johannes Weiner wrote:
> On Thu, Dec 03, 2015 at 05:27:18PM +0100, Michal Hocko wrote:
> > On Thu 03-12-15 22:16:55, Geliang Tang wrote:
> > > To make the intention clearer, use list_{first,next}_entry instead
> > > of list_entry.
> > 
> > Does this really help readability? This function simply uncharges the
> > given list of pages. Why cannot we simply use list_for_each_entry
> > instead...
> 
> You asked the same thing when reviewing the patch for the first
> time. :-) I think it's time to add a comment.

Ohh, I completely forgot about mem_cgroup_uncharge doing
uncharge_list(&page->lru)

> >From e8ba3f31bb43ed4091b997b6ee8857dc8bbcd349 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Thu, 3 Dec 2015 14:21:45 -0500
> Subject: [PATCH] mm: memcontrol: clarify the uncharge_list() loop
> 
> uncharge_list() does an unusual list walk because the function can
> take regular lists with dedicated list_heads as well as singleton
> lists where a single page is passed via its page->lru list node.
> 
> This can sometimes lead to confusion, as well as suggestions to
> replace the loop with a list_for_each_entry(), which wouldn't work.

Yes, this is helpful.
 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9acfb16..f7ee1c0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5422,6 +5422,10 @@ static void uncharge_list(struct list_head *page_list)
>  	struct list_head *next;
>  	struct page *page;
>  
> +	/*
> +	 * Note that the list can be a single page->lru; hence the
> +	 * do-while loop instead of a simple list_for_each_entry().
> +	 */
>  	next = page_list->next;
>  	do {
>  		unsigned int nr_pages = 1;
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
