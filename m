Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1ADB66B0188
	for <linux-mm@kvack.org>; Thu, 14 May 2009 04:30:06 -0400 (EDT)
Subject: Re: kernel BUG at mm/slqb.c:1411!
From: Pekka Enberg <penberg@cs.helsinki.fi>
In-Reply-To: <20090513173758.2f3d2a50.minchan.kim@barrios-desktop>
References: <20090513163826.7232.A69D9226@jp.fujitsu.com>
	 <20090513173758.2f3d2a50.minchan.kim@barrios-desktop>
Date: Thu, 14 May 2009 11:30:30 +0300
Message-Id: <1242289830.21646.5.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-05-13 at 17:37 +0900, Minchan Kim wrote:
> On Wed, 13 May 2009 16:42:37 +0900 (JST)
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> Hmm. I don't know slqb well.
> So, It's just my guess. 
> 
> We surely increase l->nr_partial in  __slab_alloc_page.
> In between l->nr_partial++ and call __cache_list_get_page, Who is decrease l->nr_partial again.
> After all, __cache_list_get_page return NULL and hit the VM_BUG_ON.
> 
> Comment said :
> 
>         /* Protects nr_partial, nr_slabs, and partial */
>   spinlock_t    page_lock;
> 
> As comment is right, We have to hold the l->page_lock ?

Makes sense. Nick? Motohiro-san, can you try this patch please?

			Pekka

diff --git a/mm/slqb.c b/mm/slqb.c
index 5d0642f..29bb005 100644
--- a/mm/slqb.c
+++ b/mm/slqb.c
@@ -1399,12 +1399,14 @@ static noinline void *__slab_alloc_page(struct kmem_cache *s,
 		page->list = l;
 
 		spin_lock(&n->list_lock);
+		spin_lock(&l->page_lock);
 		l->nr_slabs++;
 		l->nr_partial++;
 		list_add(&page->lru, &l->partial);
 		slqb_stat_inc(l, ALLOC);
 		slqb_stat_inc(l, ALLOC_SLAB_NEW);
 		object = __cache_list_get_page(s, l);
+		spin_unlock(&l->page_lock);
 		spin_unlock(&n->list_lock);
 #endif
 	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
