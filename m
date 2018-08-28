Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 52BC96B4832
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 17:35:33 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q12-v6so1909287pgp.6
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 14:35:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n72-v6si1911969pfk.14.2018.08.28.14.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 14:35:32 -0700 (PDT)
Date: Tue, 28 Aug 2018 14:35:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/page_alloc: Clean up check_for_memory
Message-Id: <20180828143530.4b681bf9e0b3c03519fbe943@linux-foundation.org>
In-Reply-To: <20180828210158.4617-1-osalvador@techadventures.net>
References: <20180828210158.4617-1-osalvador@techadventures.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@techadventures.net>
Cc: mhocko@suse.com, vbabka@suse.cz, Pavel.Tatashin@microsoft.com, sfr@canb.auug.org.au, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>, Lai Jiangshan <laijs@cn.fujitsu.com>

On Tue, 28 Aug 2018 23:01:58 +0200 Oscar Salvador <osalvador@techadventures.net> wrote:

> From: Oscar Salvador <osalvador@suse.de>
> 
> check_for_memory looks a bit confusing.
> First of all, we have this:
> 
> if (N_MEMORY == N_NORMAL_MEMORY)
> 	return;
> 
> Checking the ENUM declaration, looks like N_MEMORY canot be equal to
> N_NORMAL_MEMORY.
> I could not find where N_MEMORY is set to N_NORMAL_MEMORY, or the other
> way around either, so unless I am missing something, this condition 
> will never evaluate to true.
> It makes sense to get rid of it.

Added by

commit 4b0ef1fe8a626f0ba7f649764f979d0dc9eab86b
Author:     Lai Jiangshan <laijs@cn.fujitsu.com>
AuthorDate: Wed Dec 12 13:51:46 2012 -0800
Commit:     Linus Torvalds <torvalds@linux-foundation.org>
CommitDate: Wed Dec 12 17:38:33 2012 -0800

    page_alloc: use N_MEMORY instead N_HIGH_MEMORY change the node_states initia
lization

Let's cc Lai Jiangshan, see if he can remmeber the reasoning.

But yes, it does look like im-not-sure-whats-going-on-here
defensiveness.

> Moving forward, the operations whithin the loop look a bit confusing
> as well.
> 
> We set N_HIGH_MEMORY unconditionally, and then we set N_NORMAL_MEMORY
> in case we have CONFIG_HIGHMEM (N_NORMAL_MEMORY != N_HIGH_MEMORY)
> and zone <= ZONE_NORMAL.
> (N_HIGH_MEMORY falls back to N_NORMAL_MEMORY on !CONFIG_HIGHMEM systems,
> and that is why we can just go ahead and set N_HIGH_MEMORY unconditionally)
> 
> Although this works, it is a bit subtle.
> 
> I think that this could be easier to follow:
> 
> First, we should only set N_HIGH_MEMORY in case we have
> CONFIG_HIGHMEM.

Why?  Just a teeny optimization?

> And then we should set N_NORMAL_MEMORY in case zone <= ZONE_NORMAL,
> without further checking whether we have CONFIG_HIGHMEM or not.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  mm/page_alloc.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 839e0cc17f2c..6aa947f9e614 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6819,15 +6819,12 @@ static void check_for_memory(pg_data_t *pgdat, int nid)
>  {
>  	enum zone_type zone_type;
>  
> -	if (N_MEMORY == N_NORMAL_MEMORY)
> -		return;
> -
>  	for (zone_type = 0; zone_type <= ZONE_MOVABLE - 1; zone_type++) {
>  		struct zone *zone = &pgdat->node_zones[zone_type];
>  		if (populated_zone(zone)) {
> -			node_set_state(nid, N_HIGH_MEMORY);
> -			if (N_NORMAL_MEMORY != N_HIGH_MEMORY &&
> -			    zone_type <= ZONE_NORMAL)
> +			if (IS_ENABLED(CONFIG_HIGHMEM))
> +				node_set_state(nid, N_HIGH_MEMORY);
> +			if (zone_type <= ZONE_NORMAL)
>  				node_set_state(nid, N_NORMAL_MEMORY);
>  			break;
>  		}
