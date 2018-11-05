Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3A4EA6B0005
	for <linux-mm@kvack.org>; Sun,  4 Nov 2018 19:57:09 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 134-v6so7210364pga.1
        for <linux-mm@kvack.org>; Sun, 04 Nov 2018 16:57:09 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id i66-v6si42572032pfc.173.2018.11.04.16.57.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Nov 2018 16:57:08 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH 2/2] mm: avoid unnecessary swap_info_struct allocation
References: <a24bf353-8715-2bee-d0fa-96ca06c5b69f@virtuozzo.com>
Date: Mon, 05 Nov 2018 08:57:05 +0800
In-Reply-To: <a24bf353-8715-2bee-d0fa-96ca06c5b69f@virtuozzo.com> (Vasily
	Averin's message of "Mon, 5 Nov 2018 01:13:12 +0300")
Message-ID: <87sh0gbau6.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasily Averin <vvs@virtuozzo.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Aaron Lu <aaron.lu@intel.com>

Vasily Averin <vvs@virtuozzo.com> writes:

> Currently newly allocated swap_info_struct can be quickly freed.
> This patch avoid uneccessary high-order page allocation and helps
> to decrease the memory pressure.

I think swapon/swapoff are rare operations, so it will not increase the
memory pressure much.  

Best Regards,
Huang, Ying

> Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> ---
>  mm/swapfile.c | 18 +++++++++++++-----
>  1 file changed, 13 insertions(+), 5 deletions(-)
>
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 8688ae65ef58..53ec2f0cdf26 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -2809,14 +2809,17 @@ late_initcall(max_swapfiles_check);
>  
>  static struct swap_info_struct *alloc_swap_info(void)
>  {
> -	struct swap_info_struct *p;
> +	struct swap_info_struct *p = NULL;
>  	unsigned int type;
>  	int i;
> +	bool force_alloc = false;
>  
> -	p = kvzalloc(sizeof(*p), GFP_KERNEL);
> -	if (!p)
> -		return ERR_PTR(-ENOMEM);
> -
> +retry:
> +	if (force_alloc) {
> +		p = kvzalloc(sizeof(*p), GFP_KERNEL);
> +		if (!p)
> +			return ERR_PTR(-ENOMEM);
> +	}
>  	spin_lock(&swap_lock);
>  	for (type = 0; type < nr_swapfiles; type++) {
>  		if (!(swap_info[type]->flags & SWP_USED))
> @@ -2828,6 +2831,11 @@ static struct swap_info_struct *alloc_swap_info(void)
>  		return ERR_PTR(-EPERM);
>  	}
>  	if (type >= nr_swapfiles) {
> +		if (!force_alloc) {
> +			force_alloc = true;
> +			spin_unlock(&swap_lock);
> +			goto retry;
> +		}
>  		p->type = type;
>  		swap_info[type] = p;
>  		/*
