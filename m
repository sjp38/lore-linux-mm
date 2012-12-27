Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id E98586B002B
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 17:25:14 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id bh2so5673262pad.5
        for <linux-mm@kvack.org>; Thu, 27 Dec 2012 14:25:14 -0800 (PST)
Date: Thu, 27 Dec 2012 14:25:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/3] mm, bootmem: panic in bootmem alloc functions even
 if slab is available
In-Reply-To: <1356293711-23864-2-git-send-email-sasha.levin@oracle.com>
Message-ID: <alpine.DEB.2.00.1212271423210.18214@chino.kir.corp.google.com>
References: <1356293711-23864-1-git-send-email-sasha.levin@oracle.com> <1356293711-23864-2-git-send-email-sasha.levin@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Yinghai Lu <yinghai@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 23 Dec 2012, Sasha Levin wrote:

> diff --git a/mm/bootmem.c b/mm/bootmem.c
> index 1324cd7..198a92f 100644
> --- a/mm/bootmem.c
> +++ b/mm/bootmem.c
> @@ -763,9 +763,6 @@ void * __init ___alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
>  void * __init __alloc_bootmem_node(pg_data_t *pgdat, unsigned long size,
>  				   unsigned long align, unsigned long goal)
>  {
> -	if (WARN_ON_ONCE(slab_is_available()))
> -		return kzalloc_node(size, GFP_NOWAIT, pgdat->node_id);
> -
>  	return  ___alloc_bootmem_node(pgdat, size, align, goal, 0);
>  }
>  

All you're doing is removing the fallback if this happens to be called 
with slab_is_available().  It's still possible that the slab allocator can 
successfully allocate the memory, though.  So it would be rather 
unfortunate to start panicking in a situation that used to only emit a 
warning.

Why can't you panic only kzalloc_node() returns NULL and otherwise just 
return the allocated memory?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
