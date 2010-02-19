Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D0E016B0047
	for <linux-mm@kvack.org>; Thu, 18 Feb 2010 19:16:17 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1J0GHAN028890
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 19 Feb 2010 09:16:17 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id AAADB45DE4E
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 09:16:16 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6374045DE56
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 09:16:16 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B1B2DE08004
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 09:16:15 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 21DEBE7800C
	for <linux-mm@kvack.org>; Fri, 19 Feb 2010 09:16:15 +0900 (JST)
Date: Fri, 19 Feb 2010 09:12:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 01/12] mm,migration: Take a reference to the anon_vma
 before migrating
Message-Id: <20100219091244.2116db73.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1266516162-14154-2-git-send-email-mel@csn.ul.ie>
References: <1266516162-14154-1-git-send-email-mel@csn.ul.ie>
	<1266516162-14154-2-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Feb 2010 18:02:31 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> rmap_walk_anon() does not use page_lock_anon_vma() for looking up and
> locking an anon_vma and it does not appear to have sufficient locking to
> ensure the anon_vma does not disappear from under it.
> 
> This patch copies an approach used by KSM to take a reference on the
> anon_vma while pages are being migrated. This should prevent rmap_walk()
> running into nasty surprises later because anon_vma has been freed.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

I have no objection to this direction. But after this patch, you can remove
rcu_read_lock()/unlock() in unmap_and_move().
ruc_read_lock() is for guarding against anon_vma replacement.

Thanks,
-Kame



> ---
>  include/linux/rmap.h |   23 +++++++++++++++++++++++
>  mm/migrate.c         |   12 ++++++++++++
>  mm/rmap.c            |   10 +++++-----
>  3 files changed, 40 insertions(+), 5 deletions(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index b019ae6..6b5a1a9 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -29,6 +29,9 @@ struct anon_vma {
>  #ifdef CONFIG_KSM
>  	atomic_t ksm_refcount;
>  #endif
> +#ifdef CONFIG_MIGRATION
> +	atomic_t migrate_refcount;
> +#endif
>  	/*
>  	 * NOTE: the LSB of the head.next is set by
>  	 * mm_take_all_locks() _after_ taking the above lock. So the
> @@ -61,6 +64,26 @@ static inline int ksm_refcount(struct anon_vma *anon_vma)
>  	return 0;
>  }
>  #endif /* CONFIG_KSM */
> +#ifdef CONFIG_MIGRATION
> +static inline void migrate_refcount_init(struct anon_vma *anon_vma)
> +{
> +	atomic_set(&anon_vma->migrate_refcount, 0);
> +}
> +
> +static inline int migrate_refcount(struct anon_vma *anon_vma)
> +{
> +	return atomic_read(&anon_vma->migrate_refcount);
> +}
> +#else
> +static inline void migrate_refcount_init(struct anon_vma *anon_vma)
> +{
> +}
> +
> +static inline int migrate_refcount(struct anon_vma *anon_vma)
> +{
> +	return 0;
> +}
> +#endif /* CONFIG_MIGRATE */
>  
>  static inline struct anon_vma *page_anon_vma(struct page *page)
>  {
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 9a0db5b..63addfa 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -551,6 +551,7 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  	int rcu_locked = 0;
>  	int charge = 0;
>  	struct mem_cgroup *mem = NULL;
> +	struct anon_vma *anon_vma = NULL;
>  
>  	if (!newpage)
>  		return -ENOMEM;
> @@ -607,6 +608,8 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  	if (PageAnon(page)) {
>  		rcu_read_lock();
>  		rcu_locked = 1;
> +		anon_vma = page_anon_vma(page);
> +		atomic_inc(&anon_vma->migrate_refcount);
>  	}
>  
>  	/*
> @@ -646,6 +649,15 @@ skip_unmap:
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
>  	if (rcu_locked)
>  		rcu_read_unlock();
>  uncharge:
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 278cd27..11ba74a 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -172,7 +172,8 @@ void anon_vma_unlink(struct vm_area_struct *vma)
>  	list_del(&vma->anon_vma_node);
>  
>  	/* We must garbage collect the anon_vma if it's empty */
> -	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma);
> +	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma) &&
> +					!migrate_refcount(anon_vma);
>  	spin_unlock(&anon_vma->lock);
>  
>  	if (empty)
> @@ -185,6 +186,7 @@ static void anon_vma_ctor(void *data)
>  
>  	spin_lock_init(&anon_vma->lock);
>  	ksm_refcount_init(anon_vma);
> +	migrate_refcount_init(anon_vma);
>  	INIT_LIST_HEAD(&anon_vma->head);
>  }
>  
> @@ -1228,10 +1230,8 @@ static int rmap_walk_anon(struct page *page, int (*rmap_one)(struct page *,
>  	/*
>  	 * Note: remove_migration_ptes() cannot use page_lock_anon_vma()
>  	 * because that depends on page_mapped(); but not all its usages
> -	 * are holding mmap_sem, which also gave the necessary guarantee
> -	 * (that this anon_vma's slab has not already been destroyed).
> -	 * This needs to be reviewed later: avoiding page_lock_anon_vma()
> -	 * is risky, and currently limits the usefulness of rmap_walk().
> +	 * are holding mmap_sem. Users without mmap_sem are required to
> +	 * take a reference count to prevent the anon_vma disappearing
>  	 */
>  	anon_vma = page_anon_vma(page);
>  	if (!anon_vma)
> -- 
> 1.6.5
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
