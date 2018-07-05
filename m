Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 464496B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 13:53:56 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id f5-v6so2554678plf.18
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 10:53:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k18-v6si6241136pll.404.2018.07.05.10.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Jul 2018 10:53:54 -0700 (PDT)
Date: Thu, 5 Jul 2018 10:53:52 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [BUG] Swap xarray workingset eviction warning.
Message-ID: <20180705175352.GA21635@bombadil.infradead.org>
References: <2920a634-0646-1500-7c4d-62c56932fe49@gmail.com>
 <20180702025059.GA9865@bombadil.infradead.org>
 <20180705170019.GA14929@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180705170019.GA14929@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Peter Geis <pgwipeout@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 05, 2018 at 01:00:19PM -0400, Johannes Weiner wrote:
> This could be a matter of uptime, but the warning triggers on a thing
> that is supposed to happen everywhere eventually. Let's fix it.

Ahh!  Thank you!

> xa_mk_value() doesn't understand that we're okay with it chopping off
> our upper-most bit. We shouldn't make this an API behavior, either, so
> let's fix the workingset code to always clear those bits before hand.

Makes sense.  I'll just fold this in, if that's OK with you?

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> 
> diff --git a/mm/workingset.c b/mm/workingset.c
> index a466e731231d..1da19c04b6f7 100644
> --- a/mm/workingset.c
> +++ b/mm/workingset.c
> @@ -173,6 +173,7 @@ static unsigned int bucket_order __read_mostly;
>  static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
>  {
>  	eviction >>= bucket_order;
> +	eviction &= EVICTION_MASK;
>  	eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
>  	eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
>  
