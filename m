Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 591C76B68EA
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 06:54:56 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id x15so6403473edd.2
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 03:54:56 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fy4-v6si1950547ejb.223.2018.12.03.03.54.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 03:54:54 -0800 (PST)
Date: Mon, 3 Dec 2018 12:54:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm/memcg: Fix min/low usage in
 propagate_protected_usage()
Message-ID: <20181203115453.GO31738@dhcp22.suse.cz>
References: <20181203080119.18989-1-xlpang@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181203080119.18989-1-xlpang@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xunlei Pang <xlpang@linux.alibaba.com>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 03-12-18 16:01:17, Xunlei Pang wrote:
> When usage exceeds min, min usage should be min other than 0.
> Apply the same for low.

Why? What is the actual problem.

> Signed-off-by: Xunlei Pang <xlpang@linux.alibaba.com>
> ---
>  mm/page_counter.c | 12 ++----------
>  1 file changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/page_counter.c b/mm/page_counter.c
> index de31470655f6..75d53f15f040 100644
> --- a/mm/page_counter.c
> +++ b/mm/page_counter.c
> @@ -23,11 +23,7 @@ static void propagate_protected_usage(struct page_counter *c,
>  		return;
>  
>  	if (c->min || atomic_long_read(&c->min_usage)) {
> -		if (usage <= c->min)
> -			protected = usage;
> -		else
> -			protected = 0;
> -
> +		protected = min(usage, c->min);
>  		old_protected = atomic_long_xchg(&c->min_usage, protected);
>  		delta = protected - old_protected;
>  		if (delta)
> @@ -35,11 +31,7 @@ static void propagate_protected_usage(struct page_counter *c,
>  	}
>  
>  	if (c->low || atomic_long_read(&c->low_usage)) {
> -		if (usage <= c->low)
> -			protected = usage;
> -		else
> -			protected = 0;
> -
> +		protected = min(usage, c->low);
>  		old_protected = atomic_long_xchg(&c->low_usage, protected);
>  		delta = protected - old_protected;
>  		if (delta)
> -- 
> 2.13.5 (Apple Git-94)
> 

-- 
Michal Hocko
SUSE Labs
