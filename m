Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B2B8A6B0038
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 10:21:13 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r18so9568338wmd.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 07:21:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o97si16865908wrc.185.2017.01.30.07.21.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 30 Jan 2017 07:21:12 -0800 (PST)
Subject: Re: [PATCH 4/9] ila: simplify a strange allocation pattern
References: <20170130094940.13546-1-mhocko@kernel.org>
 <20170130094940.13546-5-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <7d8d27b2-2556-efb1-f319-666133014f2b@suse.cz>
Date: Mon, 30 Jan 2017 16:21:08 +0100
MIME-Version: 1.0
In-Reply-To: <20170130094940.13546-5-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Tom Herbert <tom@herbertland.com>, Eric Dumazet <eric.dumazet@gmail.com>

On 01/30/2017 10:49 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> alloc_ila_locks seemed to c&p from alloc_bucket_locks allocation
> pattern which is quite unusual. The default allocation size is 320 *
> sizeof(spinlock_t) which is sub page unless lockdep is enabled when the
> performance benefit is really questionable and not worth the subtle code
> IMHO. Also note that the context when we call ila_init_net (modprobe or
> a task creating a net namespace) has to be properly configured.
>
> Let's just simplify the code and use kvmalloc helper which is a
> transparent way to use kmalloc with vmalloc fallback.
>
> Cc: Tom Herbert <tom@herbertland.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  net/ipv6/ila/ila_xlat.c | 8 +-------
>  1 file changed, 1 insertion(+), 7 deletions(-)
>
> diff --git a/net/ipv6/ila/ila_xlat.c b/net/ipv6/ila/ila_xlat.c
> index af8f52ee7180..2fd5ca151dcf 100644
> --- a/net/ipv6/ila/ila_xlat.c
> +++ b/net/ipv6/ila/ila_xlat.c
> @@ -41,13 +41,7 @@ static int alloc_ila_locks(struct ila_net *ilan)
>  	size = roundup_pow_of_two(nr_pcpus * LOCKS_PER_CPU);
>
>  	if (sizeof(spinlock_t) != 0) {
> -#ifdef CONFIG_NUMA
> -		if (size * sizeof(spinlock_t) > PAGE_SIZE)
> -			ilan->locks = vmalloc(size * sizeof(spinlock_t));
> -		else
> -#endif
> -		ilan->locks = kmalloc_array(size, sizeof(spinlock_t),
> -					    GFP_KERNEL);
> +		ilan->locks = kvmalloc(size * sizeof(spinlock_t), GFP_KERNEL);
>  		if (!ilan->locks)
>  			return -ENOMEM;
>  		for (i = 0; i < size; i++)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
