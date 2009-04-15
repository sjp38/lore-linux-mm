Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A30A25F0001
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 03:50:41 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3F7pRTW021545
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 15 Apr 2009 16:51:27 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F345F45DE61
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 16:51:26 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CA82445DE5F
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 16:51:26 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 539A31DB8063
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 16:51:26 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AEB7B1DB805E
	for <linux-mm@kvack.org>; Wed, 15 Apr 2009 16:51:25 +0900 (JST)
Date: Wed, 15 Apr 2009 16:49:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] migration: only migrate_prep() once per move_pages()
Message-Id: <20090415164955.41746866.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <49E58D7A.4010708@ens-lyon.org>
References: <49E58D7A.4010708@ens-lyon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Brice Goglin <Brice.Goglin@ens-lyon.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 15 Apr 2009 09:32:10 +0200
Brice Goglin <Brice.Goglin@ens-lyon.org> wrote:

> migrate_prep() is fairly expensive (72us on 16-core barcelona 1.9GHz).
> Commit 3140a2273009c01c27d316f35ab76a37e105fdd8 improved move_pages()
> throughput by breaking it into chunks, but it also made migrate_prep()
> be called once per chunk (every 128pages or so) instead of once per
> move_pages().
> 
> This patch reverts to calling migrate_prep() only once per chunk
> as we did before 2.6.29.
> It is also a followup to commit 0aedadf91a70a11c4a3e7c7d99b21e5528af8d5d
>     mm: move migrate_prep out from under mmap_sem
> 
> This improves migration throughput on the above machine from 600MB/s
> to 750MB/s.
> 
> Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
> 
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

I think this patch is good. page migration is best-effort syscall ;)

BTW, current users of sys_move_pages() does retry when it gets -EBUSY ?

Thanks,
-Kame


> diff --git a/mm/migrate.c b/mm/migrate.c
> index 068655d..a2d3e83 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -820,7 +820,6 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
>  	struct page_to_node *pp;
>  	LIST_HEAD(pagelist);
>  
> -	migrate_prep();
>  	down_read(&mm->mmap_sem);
>  
>  	/*
> @@ -907,6 +906,9 @@ static int do_pages_move(struct mm_struct *mm, struct task_struct *task,
>  	pm = (struct page_to_node *)__get_free_page(GFP_KERNEL);
>  	if (!pm)
>  		goto out;
> +
> +	migrate_prep();
> +
>  	/*
>  	 * Store a chunk of page_to_node array in a page,
>  	 * but keep the last one as a marker
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
