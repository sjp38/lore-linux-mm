Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 6ADDD6B0031
	for <linux-mm@kvack.org>; Wed, 18 Dec 2013 19:29:01 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so387110pbc.27
        for <linux-mm@kvack.org>; Wed, 18 Dec 2013 16:29:01 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id bc2si1214287pad.187.2013.12.18.16.28.59
        for <linux-mm@kvack.org>;
        Wed, 18 Dec 2013 16:28:59 -0800 (PST)
Date: Wed, 18 Dec 2013 16:28:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/rmap: fix BUG at rmap_walk
Message-Id: <20131218162858.6ec808c067baf4644532e110@linux-foundation.org>
In-Reply-To: <1387412195-26498-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1387412195-26498-1-git-send-email-liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 19 Dec 2013 08:16:35 +0800 Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:

> page_get_anon_vma() called in page_referenced_anon() will lock and 
> increase the refcount of anon_vma, page won't be locked for anonymous 
> page. This patch fix it by skip check anonymous page locked.
> 
> [  588.698828] kernel BUG at mm/rmap.c:1663!

Why is all this suddenly happening.  Did we change something, or did a
new test get added to trinity?

> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1660,7 +1660,8 @@ done:
>  
>  int rmap_walk(struct page *page, struct rmap_walk_control *rwc)
>  {
> -	VM_BUG_ON(!PageLocked(page));
> +	if (!PageAnon(page) || PageKsm(page))
> +		VM_BUG_ON(!PageLocked(page));
>  
>  	if (unlikely(PageKsm(page)))
>  		return rmap_walk_ksm(page, rwc);

Is there any reason why rmap_walk_ksm() and rmap_walk_file() *need*
PageLocked() whereas rmap_walk_anon() does not?  If so, let's implement
it like this:


--- a/mm/rmap.c~a
+++ a/mm/rmap.c
@@ -1716,6 +1716,10 @@ static int rmap_walk_file(struct page *p
 	struct vm_area_struct *vma;
 	int ret = SWAP_AGAIN;
 
+	/*
+	 * page must be locked because <reason goes here>
+	 */
+	VM_BUG_ON(!PageLocked(page));
 	if (!mapping)
 		return ret;
 	mutex_lock(&mapping->i_mmap_mutex);
@@ -1737,8 +1741,6 @@ static int rmap_walk_file(struct page *p
 int rmap_walk(struct page *page, int (*rmap_one)(struct page *,
 		struct vm_area_struct *, unsigned long, void *), void *arg)
 {
-	VM_BUG_ON(!PageLocked(page));
-
 	if (unlikely(PageKsm(page)))
 		return rmap_walk_ksm(page, rmap_one, arg);
 	else if (PageAnon(page))
--- a/mm/ksm.c~a
+++ a/mm/ksm.c
@@ -2006,6 +2006,9 @@ int rmap_walk_ksm(struct page *page, int
 	int search_new_forks = 0;
 
 	VM_BUG_ON(!PageKsm(page));
+	/*
+	 * page must be locked because <reason goes here>
+	 */
 	VM_BUG_ON(!PageLocked(page));
 
 	stable_node = page_stable_node(page);


Or if there is no reason why the page must be locked for
rmap_walk_ksm() and rmap_walk_file(), let's just remove rmap_walk()'s
VM_BUG_ON()?  And rmap_walk_ksm()'s as well - it's duplicative anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
