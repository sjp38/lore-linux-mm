Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id DFABA6B003D
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 19:49:09 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Mon, 15 Jul 2013 05:10:56 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 3DAF9E004F
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:18:55 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6ENnlRU12189830
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 05:19:47 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6ENn2lw003647
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 09:49:03 +1000
Date: Mon, 15 Jul 2013 07:49:01 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [v5][PATCH 3/6] mm: vmscan: break up __remove_mapping()
Message-ID: <20130714234901.GC23628@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <20130603200202.7F5FDE07@viggo.jf.intel.com>
 <20130603200206.644A9EC3@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130603200206.644A9EC3@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com, minchan@kernel.org

On Mon, Jun 03, 2013 at 01:02:06PM -0700, Dave Hansen wrote:
>
>From: Dave Hansen <dave.hansen@linux.intel.com>
>
>Our goal here is to eventually reduce the number of repetitive
>acquire/release operations on mapping->tree_lock.
>
>Logically, this patch has two steps:
>1. rename __remove_mapping() to lock_remove_mapping() since
>   "__" usually means "this us the unlocked version.
>2. Recreate __remove_mapping() to _be_ the lock_remove_mapping()
>   but without the locks.
>
>I think this actually makes the code flow around the locking
>_much_ more straighforward since the locking just becomes:
>
>	spin_lock_irq(&mapping->tree_lock);
>	ret = __remove_mapping(mapping, page);
>	spin_unlock_irq(&mapping->tree_lock);
>
>One non-obvious part of this patch: the
>
>	freepage = mapping->a_ops->freepage;
>
>used to happen under the mapping->tree_lock, but this patch
>moves it to outside of the lock.  All of the other
>a_ops->freepage users do it outside the lock, and we only
>assign it when we create inodes, so that makes it safe.
>
>Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>Acked-by: Mel Gorman <mgorman@suse.de>
>Reviewed-by: Minchan Kin <minchan@kernel.org>
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
>
> linux.git-davehans/mm/vmscan.c |   40 ++++++++++++++++++++++++----------------
> 1 file changed, 24 insertions(+), 16 deletions(-)
>
>diff -puN mm/vmscan.c~make-remove-mapping-without-locks mm/vmscan.c
>--- linux.git/mm/vmscan.c~make-remove-mapping-without-locks	2013-06-03 12:41:30.903728970 -0700
>+++ linux.git-davehans/mm/vmscan.c	2013-06-03 12:41:30.907729146 -0700
>@@ -455,7 +455,6 @@ static int __remove_mapping(struct addre
> 	BUG_ON(!PageLocked(page));
> 	BUG_ON(mapping != page_mapping(page));
>
>-	spin_lock_irq(&mapping->tree_lock);
> 	/*
> 	 * The non racy check for a busy page.
> 	 *
>@@ -482,35 +481,44 @@ static int __remove_mapping(struct addre
> 	 * and thus under tree_lock, then this ordering is not required.
> 	 */
> 	if (!page_freeze_refs(page, 2))
>-		goto cannot_free;
>+		return 0;
> 	/* note: atomic_cmpxchg in page_freeze_refs provides the smp_rmb */
> 	if (unlikely(PageDirty(page))) {
> 		page_unfreeze_refs(page, 2);
>-		goto cannot_free;
>+		return 0;
> 	}
>
> 	if (PageSwapCache(page)) {
> 		__delete_from_swap_cache(page);
>-		spin_unlock_irq(&mapping->tree_lock);
>+	} else {
>+		__delete_from_page_cache(page);
>+	}
>+	return 1;
>+}
>+
>+static int lock_remove_mapping(struct address_space *mapping, struct page *page)
>+{
>+	int ret;
>+	BUG_ON(!PageLocked(page));
>+
>+	spin_lock_irq(&mapping->tree_lock);
>+	ret = __remove_mapping(mapping, page);
>+	spin_unlock_irq(&mapping->tree_lock);
>+
>+	/* unable to free */
>+	if (!ret)
>+		return 0;
>+
>+	if (PageSwapCache(page)) {
> 		swapcache_free_page_entry(page);
> 	} else {
> 		void (*freepage)(struct page *);
>-
> 		freepage = mapping->a_ops->freepage;
>-
>-		__delete_from_page_cache(page);
>-		spin_unlock_irq(&mapping->tree_lock);
> 		mem_cgroup_uncharge_cache_page(page);
>-
> 		if (freepage != NULL)
> 			freepage(page);
> 	}
>-
>-	return 1;
>-
>-cannot_free:
>-	spin_unlock_irq(&mapping->tree_lock);
>-	return 0;
>+	return ret;
> }
>
> /*
>@@ -521,7 +529,7 @@ cannot_free:
>  */
> int remove_mapping(struct address_space *mapping, struct page *page)
> {
>-	if (__remove_mapping(mapping, page)) {
>+	if (lock_remove_mapping(mapping, page)) {
> 		/*
> 		 * Unfreezing the refcount with 1 rather than 2 effectively
> 		 * drops the pagecache ref for us without requiring another
>_
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
