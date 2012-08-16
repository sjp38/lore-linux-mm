Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 838C26B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 03:06:54 -0400 (EDT)
Received: by lahd3 with SMTP id d3so1513355lah.14
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 00:06:52 -0700 (PDT)
Date: Thu, 16 Aug 2012 10:06:50 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 2/3] slub: reduce failure of this_cpu_cmpxchg in
 put_cpu_partial() after unfreezing
In-Reply-To: <1340389359-2407-2-git-send-email-js1304@gmail.com>
Message-ID: <alpine.LFD.2.02.1208161006430.2133@tux.localdomain>
References: <yes> <1340389359-2407-1-git-send-email-js1304@gmail.com> <1340389359-2407-2-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 23 Jun 2012, Joonsoo Kim wrote:
> In current implementation, after unfreezing, we doesn't touch oldpage,
> so it remain 'NOT NULL'. When we call this_cpu_cmpxchg()
> with this old oldpage, this_cpu_cmpxchg() is mostly be failed.
> 
> We can change value of oldpage to NULL after unfreezing,
> because unfreeze_partial() ensure that all the cpu partial slabs is removed
> from cpu partial list. In this time, we could expect that
> this_cpu_cmpxchg is mostly succeed.
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 92f1c0e..531d8ed 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -1968,6 +1968,7 @@ int put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
>  				local_irq_save(flags);
>  				unfreeze_partials(s);
>  				local_irq_restore(flags);
> +				oldpage = NULL;
>  				pobjects = 0;
>  				pages = 0;
>  				stat(s, CPU_PARTIAL_DRAIN);

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
