Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0A09F6B0005
	for <linux-mm@kvack.org>; Sun,  4 Nov 2018 19:50:08 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id t10-v6so8524349plh.14
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 16:50:07 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id d24-v6si8131688plr.127.2018.11.04.16.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Nov 2018 16:50:06 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH 1/2] mm: use kvzalloc for swap_info_struct allocation
References: <37b60523-d085-71e9-fef9-80b90bfcef18@virtuozzo.com>
Date: Mon, 05 Nov 2018 08:50:04 +0800
In-Reply-To: <37b60523-d085-71e9-fef9-80b90bfcef18@virtuozzo.com> (Vasily
	Averin's message of "Mon, 5 Nov 2018 01:13:04 +0300")
Message-ID: <87wopsbb5v.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasily Averin <vvs@virtuozzo.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Aaron Lu <aaron.lu@intel.com>

Vasily Averin <vvs@virtuozzo.com> writes:

> commit a2468cc9bfdf ("swap: choose swap device according to numa node")
> increased size of swap_info_struct up to 44 Kbytes, now it requires
> 4th order page.

Why swap_info_struct could be so large?  Because MAX_NUMNODES could be
thousands so that 'avail_lists' field could be tens KB?  If so, I think
it's fair to use kvzalloc().  Can you add one line comment?  Because
struct swap_info_struct is quite small in default configuration.

Best Regards,
Huang, Ying

> Switch to kvzmalloc allows to avoid unexpected allocation failures.
>
> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> ---
>  mm/swapfile.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 644f746e167a..8688ae65ef58 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -2813,7 +2813,7 @@ static struct swap_info_struct *alloc_swap_info(void)
>  	unsigned int type;
>  	int i;
>  
> -	p = kzalloc(sizeof(*p), GFP_KERNEL);
> +	p = kvzalloc(sizeof(*p), GFP_KERNEL);
>  	if (!p)
>  		return ERR_PTR(-ENOMEM);
>  
> @@ -2824,7 +2824,7 @@ static struct swap_info_struct *alloc_swap_info(void)
>  	}
>  	if (type >= MAX_SWAPFILES) {
>  		spin_unlock(&swap_lock);
> -		kfree(p);
> +		kvfree(p);
>  		return ERR_PTR(-EPERM);
>  	}
>  	if (type >= nr_swapfiles) {
> @@ -2838,7 +2838,7 @@ static struct swap_info_struct *alloc_swap_info(void)
>  		smp_wmb();
>  		nr_swapfiles++;
>  	} else {
> -		kfree(p);
> +		kvfree(p);
>  		p = swap_info[type];
>  		/*
>  		 * Do not memset this entry: a racing procfs swap_next()
