Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1A2BE6B01EF
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 22:53:18 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3L2rGTq031402
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 21 Apr 2010 11:53:16 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1BD0A45DE53
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 11:53:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E316B45DE50
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 11:53:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id CA0941DB803B
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 11:53:15 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E9591DB803E
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 11:53:15 +0900 (JST)
Date: Wed, 21 Apr 2010 11:49:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 01/14] mm,migration: Take a reference to the anon_vma
 before migrating
Message-Id: <20100421114920.ae4c45fd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1271797276-31358-2-git-send-email-mel@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
	<1271797276-31358-2-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 20 Apr 2010 22:01:03 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> rmap_walk_anon() does not use page_lock_anon_vma() for looking up and
> locking an anon_vma and it does not appear to have sufficient locking to
> ensure the anon_vma does not disappear from under it.
> 
> This patch copies an approach used by KSM to take a reference on the
> anon_vma while pages are being migrated.  This should prevent rmap_walk()
> running into nasty surprises later because anon_vma has been freed.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Acked-by: Rik van Riel <riel@redhat.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hmm, a nitpick..


>  static inline struct anon_vma *page_anon_vma(struct page *page)
>  {
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 5938db5..b768a1d 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -543,6 +543,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  	int rcu_locked = 0;
>  	int charge = 0;
>  	struct mem_cgroup *mem = NULL;
> +	struct anon_vma *anon_vma = NULL;
>  
>  	if (!newpage)
>  		return -ENOMEM;
> @@ -599,6 +600,8 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  	if (PageAnon(page)) {
>  		rcu_read_lock();
>  		rcu_locked = 1;
> +		anon_vma = page_anon_vma(page);
> +		atomic_inc(&anon_vma->migrate_refcount);
>  	}
>  
>  	/*
> @@ -638,6 +641,15 @@ skip_unmap:
>  	if (rc)
>  		remove_migration_ptes(page, page);
>  rcu_unlock:
> +
> +	/* Drop an anon_vma reference if we took one */
> +	if (anon_vma && atomic_dec_and_lock(&anon_vma->migrate_refcount, &anon_vma->lock)) {
> +		int empty = list_empty(&anon_vma->head);
> +		spin_unlock(&anon_vma->lock);
> +		if (empty)
> +			anon_vma_free(anon_vma);
> +	}
> +

Hmm. Can't we move this part to mm/rmap.c ?

	as
		anon_vma_drop_external_reference()
or some.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
