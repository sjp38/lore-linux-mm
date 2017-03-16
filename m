Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE706B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 07:31:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c23so79044262pfj.0
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 04:31:02 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id e3si5018012plb.171.2017.03.16.04.31.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 04:31:01 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id o126so5512451pfb.1
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 04:31:00 -0700 (PDT)
Date: Thu, 16 Mar 2017 20:30:56 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 1/3] mm: page_alloc: Reduce object size by neatening
 printks
Message-ID: <20170316113056.GG464@jagdpanzerIV.localdomain>
References: <cover.1489628459.git.joe@perches.com>
 <880b3172b67d806082284d80945e4a231a5574bb.1489628459.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <880b3172b67d806082284d80945e4a231a5574bb.1489628459.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (03/15/17 18:43), Joe Perches wrote:
[..]
> -	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
> -		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
> -		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
> -		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
> -		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
> -		" free:%lu free_pcp:%lu free_cma:%lu\n",
> -		global_node_page_state(NR_ACTIVE_ANON),
> -		global_node_page_state(NR_INACTIVE_ANON),
> -		global_node_page_state(NR_ISOLATED_ANON),
> -		global_node_page_state(NR_ACTIVE_FILE),
> -		global_node_page_state(NR_INACTIVE_FILE),
> -		global_node_page_state(NR_ISOLATED_FILE),
> -		global_node_page_state(NR_UNEVICTABLE),
> -		global_node_page_state(NR_FILE_DIRTY),
> -		global_node_page_state(NR_WRITEBACK),
> -		global_node_page_state(NR_UNSTABLE_NFS),
> -		global_page_state(NR_SLAB_RECLAIMABLE),
> -		global_page_state(NR_SLAB_UNRECLAIMABLE),
> -		global_node_page_state(NR_FILE_MAPPED),
> -		global_node_page_state(NR_SHMEM),
> -		global_page_state(NR_PAGETABLE),
> -		global_page_state(NR_BOUNCE),
> -		global_page_state(NR_FREE_PAGES),
> -		free_pcp,
> -		global_page_state(NR_FREE_CMA_PAGES));
> +	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n",
> +	       global_node_page_state(NR_ACTIVE_ANON),
> +	       global_node_page_state(NR_INACTIVE_ANON),
> +	       global_node_page_state(NR_ISOLATED_ANON));
> +	printk("active_file:%lu inactive_file:%lu isolated_file:%lu\n",
> +	       global_node_page_state(NR_ACTIVE_FILE),
> +	       global_node_page_state(NR_INACTIVE_FILE),
> +	       global_node_page_state(NR_ISOLATED_FILE));
> +	printk("unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n",
> +	       global_node_page_state(NR_UNEVICTABLE),
> +	       global_node_page_state(NR_FILE_DIRTY),
> +	       global_node_page_state(NR_WRITEBACK),
> +	       global_node_page_state(NR_UNSTABLE_NFS));
> +	printk("slab_reclaimable:%lu slab_unreclaimable:%lu\n",
> +	       global_page_state(NR_SLAB_RECLAIMABLE),
> +	       global_page_state(NR_SLAB_UNRECLAIMABLE));
> +	printk("mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n",
> +	       global_node_page_state(NR_FILE_MAPPED),
> +	       global_node_page_state(NR_SHMEM),
> +	       global_page_state(NR_PAGETABLE),
> +	       global_page_state(NR_BOUNCE));
> +	printk("free:%lu free_pcp:%lu free_cma:%lu\n",
> +	       global_page_state(NR_FREE_PAGES),
> +	       free_pcp,
> +	       global_page_state(NR_FREE_CMA_PAGES));

a side note:

this can make it harder to read, in _the worst case_. one printk()
guaranteed that we would see a single line in the serial log/etc.
the sort of a problem with multiple printks is that printks coming
from other CPUs will split that "previously single" line.

just a notice. up to MM people to decide.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
