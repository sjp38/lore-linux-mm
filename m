Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2F3316B0035
	for <linux-mm@kvack.org>; Fri, 27 Dec 2013 20:51:04 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id p10so9542279pdj.32
        for <linux-mm@kvack.org>; Fri, 27 Dec 2013 17:51:03 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id qh6si25947539pbb.244.2013.12.27.17.51.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 27 Dec 2013 17:51:02 -0800 (PST)
Message-ID: <52BE2E74.1070107@huawei.com>
Date: Sat, 28 Dec 2013 09:50:44 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/slub: fix accumulate per cpu partial cache objects
References: <1388137619-14741-1-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1388137619-14741-1-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Type: text/plain; charset="GB2312"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2013/12/27 17:46, Wanpeng Li wrote:
> SLUB per cpu partial cache is a list of slab caches to accelerate objects 
> allocation. However, current codes just accumulate the objects number of 
> the first slab cache of per cpu partial cache instead of traverse the whole 
> list.
> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/slub.c |   32 +++++++++++++++++++++++---------
>  1 files changed, 23 insertions(+), 9 deletions(-)
> 
> diff --git a/mm/slub.c b/mm/slub.c
> index 545a170..799bfdc 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -4280,7 +4280,7 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
>  			struct kmem_cache_cpu *c = per_cpu_ptr(s->cpu_slab,
>  							       cpu);
>  			int node;
> -			struct page *page;
> +			struct page *page, *p;
>  
>  			page = ACCESS_ONCE(c->page);
>  			if (!page)
> @@ -4298,8 +4298,9 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
>  			nodes[node] += x;
>  
>  			page = ACCESS_ONCE(c->partial);
> -			if (page) {
> -				x = page->pobjects;
> +			while ((p = page)) {
> +				page = p->next;
> +				x = p->pobjects;
>  				total += x;
>  				nodes[node] += x;
>  			}

Can we apply this patch first? It was sent month ago, but Pekka was not responsive.

=============================

[PATCH] slub: Fix calculation of cpu slabs

  /sys/kernel/slab/:t-0000048 # cat cpu_slabs
  231 N0=16 N1=215
  /sys/kernel/slab/:t-0000048 # cat slabs
  145 N0=36 N1=109

See, the number of slabs is smaller than that of cpu slabs.

The bug was introduced by commit 49e2258586b423684f03c278149ab46d8f8b6700
("slub: per cpu cache for partial pages").

We should use page->pages instead of page->pobjects when calculating
the number of cpu partial slabs. This also fixes the mapping of slabs
and nodes.

As there's no variable storing the number of total/active objects in
cpu partial slabs, and we don't have user interfaces requiring those
statistics, I just add WARN_ON for those cases.

Cc: <stable@vger.kernel.org> # 3.2+
Signed-off-by: Li Zefan <lizefan@huawei.com>
Acked-by: Christoph Lameter <cl@linux.com>
Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/slub.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index e3ba1f2..6ea461d 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4300,7 +4300,13 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 
 			page = ACCESS_ONCE(c->partial);
 			if (page) {
-				x = page->pobjects;
+				node = page_to_nid(page);
+				if (flags & SO_TOTAL)
+					WARN_ON_ONCE(1);
+				else if (flags & SO_OBJECTS)
+					WARN_ON_ONCE(1);
+				else
+					x = page->pages;
 				total += x;
 				nodes[node] += x;
 			}
-- 1.8.0.2 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
