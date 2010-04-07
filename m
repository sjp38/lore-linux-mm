Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BBC236B01F0
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 20:06:03 -0400 (EDT)
Date: Tue, 6 Apr 2010 17:05:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 03/14] mm: Share the anon_vma ref counts between KSM and
 page migration
Message-Id: <20100406170528.ecb30941.akpm@linux-foundation.org>
In-Reply-To: <1270224168-14775-4-git-send-email-mel@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie>
	<1270224168-14775-4-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri,  2 Apr 2010 17:02:37 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> For clarity of review, KSM and page migration have separate refcounts on
> the anon_vma. While clear, this is a waste of memory. This patch gets
> KSM and page migration to share their toys in a spirit of harmony.
> 
> ...
>
> @@ -26,11 +26,17 @@
>   */
>  struct anon_vma {
>  	spinlock_t lock;	/* Serialize access to vma list */
> -#ifdef CONFIG_KSM
> -	atomic_t ksm_refcount;
> -#endif
> -#ifdef CONFIG_MIGRATION
> -	atomic_t migrate_refcount;
> +#if defined(CONFIG_KSM) || defined(CONFIG_MIGRATION)
> +
> +	/*
> +	 * The external_refcount is taken by either KSM or page migration
> +	 * to take a reference to an anon_vma when there is no
> +	 * guarantee that the vma of page tables will exist for
> +	 * the duration of the operation. A caller that takes
> +	 * the reference is responsible for clearing up the
> +	 * anon_vma if they are the last user on release
> +	 */
> +	atomic_t external_refcount;
>  #endif

hah.

> @@ -653,7 +653,7 @@ skip_unmap:
>  rcu_unlock:
>  
>  	/* Drop an anon_vma reference if we took one */
> -	if (anon_vma && atomic_dec_and_lock(&anon_vma->migrate_refcount, &anon_vma->lock)) {
> +	if (anon_vma && atomic_dec_and_lock(&anon_vma->external_refcount, &anon_vma->lock)) {
>  		int empty = list_empty(&anon_vma->head);
>  		spin_unlock(&anon_vma->lock);
>  		if (empty)

So we now _do_ test ksm_refcount.  Perhaps that fixed a bug added in [1/14]

> diff --git a/mm/rmap.c b/mm/rmap.c
> index 578d0fe..af35b75 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -248,8 +248,7 @@ static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain)
>  	list_del(&anon_vma_chain->same_anon_vma);
>  
>  	/* We must garbage collect the anon_vma if it's empty */
> -	empty = list_empty(&anon_vma->head) && !ksm_refcount(anon_vma) &&
> -					!migrate_refcount(anon_vma);
> +	empty = list_empty(&anon_vma->head) && !anonvma_external_refcount(anon_vma);
>  	spin_unlock(&anon_vma->lock);
>  
>  	if (empty)
> @@ -273,8 +272,7 @@ static void anon_vma_ctor(void *data)
>  	struct anon_vma *anon_vma = data;
>  
>  	spin_lock_init(&anon_vma->lock);
> -	ksm_refcount_init(anon_vma);
> -	migrate_refcount_init(anon_vma);
> +	anonvma_external_refcount_init(anon_vma);

What a mouthful.  Can we do s/external_//g?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
