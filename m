Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8D0AB6B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 11:09:31 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 204so3531952wmy.1
        for <linux-mm@kvack.org>; Wed, 31 May 2017 08:09:31 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 136si31206223wmy.80.2017.05.31.08.09.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 08:09:30 -0700 (PDT)
Date: Wed, 31 May 2017 17:09:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: add NULL check to avoid potential NULL pointer
 dereference
Message-ID: <20170531150922.GA28694@dhcp22.suse.cz>
References: <20170530212436.GA6195@embeddedgus>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170530212436.GA6195@embeddedgus>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 30-05-17 16:24:36, Gustavo A. R. Silva wrote:
> NULL check at line 1226: if (!pgdat), implies that pointer pgdat
> might be NULL.
> Function rollback_node_hotadd() dereference this pointer.
> Add NULL check to avoid a potential NULL pointer dereference.

The changelog is quite cryptic to be honest. Well the code is as well
but what do you say about the following replacement.

"
If a new pgdat has to be allocated in add_memory_resource
and the initialization fails for some reason we have to
rollback_node_hotadd. This, however, assumes that pgdat allocation
itself is successful which cannot be assumed. Add a check for pgdat
to cover that case and skip rollback_node_hotadd altogether because
there is nothing to roll back.

This has been pointed out by coverity.
"
> 
> Addresses-Coverity-ID: 1369133
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory_hotplug.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 599c675..ea3bc3e 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1273,7 +1273,7 @@ int __ref add_memory_resource(int nid, struct resource *res, bool online)
>  
>  error:
>  	/* rollback pgdat allocation and others */
> -	if (new_pgdat)
> +	if (new_pgdat && pgdat)
>  		rollback_node_hotadd(nid, pgdat);
>  	memblock_remove(start, size);
>  
> -- 
> 2.5.0
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
