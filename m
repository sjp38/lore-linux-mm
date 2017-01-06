Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E16666B0038
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 05:04:35 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id l2so2667805wml.5
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 02:04:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 38si586952wry.200.2017.01.06.02.04.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Jan 2017 02:04:34 -0800 (PST)
Date: Fri, 6 Jan 2017 11:04:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: weird allocation pattern in alloc_ila_locks
Message-ID: <20170106100433.GH5556@dhcp22.suse.cz>
References: <20170106095115.GG5556@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170106095115.GG5556@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Herbert <tom@herbertland.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 06-01-17 10:51:15, Michal Hocko wrote:
> Hi Tom,
> I am currently looking at kmalloc with vmalloc fallback users [1]
> and came across alloc_ila_locks which is using a pretty unusual
> allocation pattern - it seems to be a c&p alloc_bucket_locks which
> is doing a similar thing - except it has to support GFP_ATOMIC.
> 
> I am really wondering what is the point of 
> #ifdef CONFIG_NUMA
> 		if (size * sizeof(spinlock_t) > PAGE_SIZE)
> 			ilan->locks = vmalloc(size * sizeof(spinlock_t));
> 		else
> #endif
> 
> there doesn't seem to be any NUMA awareness in the ifdef code so I can
> only assume that the intention is to reflect that NUMA machines tend to
> have more CPUs. On the other hand nr_pcpus is limited to 32 so this
> doesn't seem to be the case here...
> Can we just get rid of this ugly and confusing code and do something as
> simple as
> diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
> index af8f52ee7180..1d86ceae61b3 100644
> --- a/net/ipv6/ila/ila_xlat.c
> +++ b/net/ipv6/ila/ila_xlat.c
> @@ -41,13 +41,11 @@ static int alloc_ila_locks(struct ila_net *ilan)
>  	size = roundup_pow_of_two(nr_pcpus * LOCKS_PER_CPU);
>  
>  	if (sizeof(spinlock_t) != 0) {
> -#ifdef CONFIG_NUMA
> -		if (size * sizeof(spinlock_t) > PAGE_SIZE)
> -			ilan->locks = vmalloc(size * sizeof(spinlock_t));
> -		else
> -#endif
>  		ilan->locks = kmalloc_array(size, sizeof(spinlock_t),
> -					    GFP_KERNEL);
> +					    GFP_KERNEL | __GFP_NORETRY | __GFP_NOWARN);
> +		if (!ilan->locks)
> +			ilan->locks = vmalloc(size * sizeof(spinlock_t));
> +
>  		if (!ilan->locks)
>  			return -ENOMEM;
>  		for (i = 0; i < size; i++)
> 
> which I would then simply turn into kvmalloc()?

The patch would look as follows:
---
