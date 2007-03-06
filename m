Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1HOWvi-0001WE-IN
	for linux-mm@kvack.org; Tue, 06 Mar 2007 11:30:02 +0100
Received: from cs181108174.pp.htv.fi ([82.181.108.174])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 06 Mar 2007 11:30:02 +0100
Received: from hurtta+gmane by cs181108174.pp.htv.fi with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Tue, 06 Mar 2007 11:30:02 +0100
From: Kari Hurtta <hurtta+gmane@siilo.fmi.fi>
Subject: Re: [PATCH 3/3][RFC] Containers: Pagecache controller reclaim
Date: 06 Mar 2007 12:24:33 +0200
Message-ID: <5d4poyvfdq.fsf@Hurtta06k.keh.iki.fi>
References: <45ED251C.2010400@linux.vnet.ibm.com> <45ED266E.7040107@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com> writes
in gmane.linux.kernel,gmane.linux.kernel.mm:

> --- linux-2.6.20.orig/mm/pagecache_acct.c
> +++ linux-2.6.20/mm/pagecache_acct.c
> @@ -29,6 +29,7 @@
>  #include <linux/uaccess.h>
>  #include <asm/div64.h>
>  #include <linux/pagecache_acct.h>
> +#include <linux/memcontrol.h>
> 
>  /*
>   * Convert unit from pages to kilobytes
> @@ -337,12 +338,20 @@ int pagecache_acct_cont_overlimit(struct
>  		return 0;
>  }
> 
> -extern unsigned long shrink_all_pagecache_memory(unsigned long nr_pages);
> +extern unsigned long shrink_container_memory(unsigned int memory_type,
> +				unsigned long nr_pages, void *container);
> 
>  int pagecache_acct_shrink_used(unsigned long nr_pages)
>  {
>  	unsigned long ret = 0;
>  	atomic_inc(&reclaim_count);
> +
> +	/* Don't call reclaim for each page above limit */
> +	if (nr_pages > NR_PAGES_RECLAIM_THRESHOLD) {
> +		ret += shrink_container_memory(
> +				RECLAIM_PAGECACHE_MEMORY, nr_pages, NULL);
> +	}
> +
>  	return 0;
>  }
> 

'ret' is not used ?

/ Kari Hurtta

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
