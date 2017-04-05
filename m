Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 378446B03B5
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 07:32:02 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k6so1203996wre.3
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 04:32:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g3si24006090wmc.150.2017.04.05.04.32.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 04:32:00 -0700 (PDT)
Date: Wed, 5 Apr 2017 13:31:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/4] mtd: nand: nandsim: convert to memalloc_noreclaim_*()
Message-ID: <20170405113157.GM6035@dhcp22.suse.cz>
References: <20170405074700.29871-1-vbabka@suse.cz>
 <20170405074700.29871-5-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170405074700.29871-5-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, linux-block@vger.kernel.org, nbd-general@lists.sourceforge.net, open-iscsi@googlegroups.com, linux-scsi@vger.kernel.org, netdev@vger.kernel.org, Boris Brezillon <boris.brezillon@free-electrons.com>, Richard Weinberger <richard@nod.at>

On Wed 05-04-17 09:47:00, Vlastimil Babka wrote:
> Nandsim has own functions set_memalloc() and clear_memalloc() for robust
> setting and clearing of PF_MEMALLOC. Replace them by the new generic helpers.
> No functional change.

This one smells like an abuser. Why the hell should read/write path
touch memory reserves at all!

> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Boris Brezillon <boris.brezillon@free-electrons.com>
> Cc: Richard Weinberger <richard@nod.at>
> ---
>  drivers/mtd/nand/nandsim.c | 29 +++++++++--------------------
>  1 file changed, 9 insertions(+), 20 deletions(-)
> 
> diff --git a/drivers/mtd/nand/nandsim.c b/drivers/mtd/nand/nandsim.c
> index cef818f535ed..03a0d057bf2f 100644
> --- a/drivers/mtd/nand/nandsim.c
> +++ b/drivers/mtd/nand/nandsim.c
> @@ -40,6 +40,7 @@
>  #include <linux/list.h>
>  #include <linux/random.h>
>  #include <linux/sched.h>
> +#include <linux/sched/mm.h>
>  #include <linux/fs.h>
>  #include <linux/pagemap.h>
>  #include <linux/seq_file.h>
> @@ -1368,31 +1369,18 @@ static int get_pages(struct nandsim *ns, struct file *file, size_t count, loff_t
>  	return 0;
>  }
>  
> -static int set_memalloc(void)
> -{
> -	if (current->flags & PF_MEMALLOC)
> -		return 0;
> -	current->flags |= PF_MEMALLOC;
> -	return 1;
> -}
> -
> -static void clear_memalloc(int memalloc)
> -{
> -	if (memalloc)
> -		current->flags &= ~PF_MEMALLOC;
> -}
> -
>  static ssize_t read_file(struct nandsim *ns, struct file *file, void *buf, size_t count, loff_t pos)
>  {
>  	ssize_t tx;
> -	int err, memalloc;
> +	int err;
> +	unsigned int noreclaim_flag;
>  
>  	err = get_pages(ns, file, count, pos);
>  	if (err)
>  		return err;
> -	memalloc = set_memalloc();
> +	noreclaim_flag = memalloc_noreclaim_save();
>  	tx = kernel_read(file, pos, buf, count);
> -	clear_memalloc(memalloc);
> +	memalloc_noreclaim_restore(noreclaim_flag);
>  	put_pages(ns);
>  	return tx;
>  }
> @@ -1400,14 +1388,15 @@ static ssize_t read_file(struct nandsim *ns, struct file *file, void *buf, size_
>  static ssize_t write_file(struct nandsim *ns, struct file *file, void *buf, size_t count, loff_t pos)
>  {
>  	ssize_t tx;
> -	int err, memalloc;
> +	int err;
> +	unsigned int noreclaim_flag;
>  
>  	err = get_pages(ns, file, count, pos);
>  	if (err)
>  		return err;
> -	memalloc = set_memalloc();
> +	noreclaim_flag = memalloc_noreclaim_save();
>  	tx = kernel_write(file, buf, count, pos);
> -	clear_memalloc(memalloc);
> +	memalloc_noreclaim_restore(noreclaim_flag);
>  	put_pages(ns);
>  	return tx;
>  }
> -- 
> 2.12.2

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
