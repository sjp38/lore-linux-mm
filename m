Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 19D156B0CCF
	for <linux-mm@kvack.org>; Fri, 16 Nov 2018 21:51:36 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so3496306ede.14
        for <linux-mm@kvack.org>; Fri, 16 Nov 2018 18:51:36 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p2-v6sor17533744edh.17.2018.11.16.18.51.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Nov 2018 18:51:34 -0800 (PST)
Date: Sat, 17 Nov 2018 02:51:33 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: use this_cpu_cmpxchg_double in put_cpu_partial
Message-ID: <20181117025133.czjubpjqm4b6kqin@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181117013335.32220-1-wen.gang.wang@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181117013335.32220-1-wen.gang.wang@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wengang Wang <wen.gang.wang@oracle.com>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Nov 16, 2018 at 05:33:35PM -0800, Wengang Wang wrote:
>The this_cpu_cmpxchg makes the do-while loop pass as long as the
>s->cpu_slab->partial as the same value. It doesn't care what happened to
>that slab. Interrupt is not disabled, and new alloc/free can happen in the
>interrupt handlers. Theoretically, after we have a reference to the it,
>stored in _oldpage_, the first slab on the partial list on this CPU can be
>moved to kmem_cache_node and then moved to different kmem_cache_cpu and
>then somehow can be added back as head to partial list of current
>kmem_cache_cpu, though that is a very rare case. If that rare case really

I didn't fully catch up with this case.

When put_cpu_partial() is called, this means we are trying to freeze an
frozen page and this pages is fully occupied. Since page->freelist is
NULL.

A full page is supposed to be on no where when has_cpu_partial() is
true.

So I don't understand when it will be moved to different kmem_cache_cpu.

>happened, the reading of oldpage->pobjects may get a 0xdead0000
>unexpectedly, stored in _pobjects_, if the reading happens just after
>another CPU removed the slab from kmem_cache_node, setting lru.prev to
>LIST_POISON2 (0xdead000000000200). The wrong _pobjects_(negative) then
>prevents slabs from being moved to kmem_cache_node and being finally freed.

Looks this page is removed from some list. This happens in which case? I
mean the page is previouly on which list?

>
>We see in a vmcore, there are 375210 slabs kept in the partial list of one
>kmem_cache_cpu, but only 305 in-use objects in the same list for
>kmalloc-2048 cache. We see negative values for page.pobjects, the last page
>with negative _pobjects_ has the value of 0xdead0004, the next page looks
>good (_pobjects is 1).
>
>For the fix, I wanted to call this_cpu_cmpxchg_double with
>oldpage->pobjects, but failed due to size difference between
>oldpage->pobjects and cpu_slab->partial. So I changed to call
>this_cpu_cmpxchg_double with _tid_. I don't really want no alloc/free
>happen in between, but just want to make sure the first slab did expereince
>a remove and re-add. This patch is more to call for ideas.
>
>Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
>---
> mm/slub.c | 20 +++++++++++++++++---
> 1 file changed, 17 insertions(+), 3 deletions(-)
>
>diff --git a/mm/slub.c b/mm/slub.c
>index e3629cd..26539e6 100644
>--- a/mm/slub.c
>+++ b/mm/slub.c
>@@ -2248,6 +2248,7 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> {
> #ifdef CONFIG_SLUB_CPU_PARTIAL
> 	struct page *oldpage;
>+	unsigned long tid;
> 	int pages;
> 	int pobjects;
> 
>@@ -2255,8 +2256,12 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> 	do {
> 		pages = 0;
> 		pobjects = 0;
>-		oldpage = this_cpu_read(s->cpu_slab->partial);
> 
>+		tid = this_cpu_read(s->cpu_slab->tid);
>+		/* read tid before reading oldpage */
>+		barrier();
>+
>+		oldpage = this_cpu_read(s->cpu_slab->partial);
> 		if (oldpage) {
> 			pobjects = oldpage->pobjects;
> 			pages = oldpage->pages;
>@@ -2283,8 +2288,17 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> 		page->pobjects = pobjects;
> 		page->next = oldpage;
> 
>-	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page)
>-								!= oldpage);
>+		/* we dont' change tid, but want to make sure it didn't change
>+		 * in between. We don't really hope alloc/free not happen on
>+		 * this CPU, but don't want the first slab be removed from and
>+		 * then re-added as head to this partial list. If that case
>+		 * happened, pobjects may read 0xdead0000 when this slab is just
>+		 * removed from kmem_cache_node by other CPU setting lru.prev
>+		 * to LIST_POISON2.
>+		 */
>+	} while (this_cpu_cmpxchg_double(s->cpu_slab->partial, s->cpu_slab->tid,
>+					 oldpage, tid, page, tid) == 0);
>+
> 	if (unlikely(!s->cpu_partial)) {
> 		unsigned long flags;
> 
>-- 
>2.9.5

-- 
Wei Yang
Help you, Help me
