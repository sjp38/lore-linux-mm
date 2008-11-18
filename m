Date: Tue, 18 Nov 2008 16:40:32 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH mmotm] memcg: avoid using buggy kmap at swap_cgroup 
In-Reply-To: <6023.10.75.179.61.1227024730.squirrel@webmail-b.css.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0811181629070.417@blonde.site>
References: <20081118180721.cb2fe744.nishimura@mxp.nes.nec.co.jp><20081118182637.97ae0e48.kamezawa.hiroyu@jp.fujitsu.com><20081118192135.300803ec.nishimura@mxp.nes.nec.co.jp><20081118210838.c99887fd.nishimura@mxp.nes.nec.co.jp><Pine.LNX.4.64.0811181234430.9680@blonde.site>
    <20081119001756.0a31b11e.d-nishimura@mtf.biglobe.ne.jp>
 <6023.10.75.179.61.1227024730.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelianov <xemul@openvz.org>, LiZefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 19 Nov 2008, KAMEZAWA Hiroyuki wrote:
> Okay, how about this direction ?
>  1. at first, remove kmap_atomic from page_cgroup.c and use GFP_KERNEL
>     to allocate buffer.

Yes, that's sensible for now.

>  2. later, add kmap_atomic + HighMem buffer support in explicit style.
>     maybe KM_BOUNCE_READ...can be used.....

It's hardly appropriate (there's no bouncing here), and you could only
use it if you disable interrupts.  Oh, you do disable interrupts:
why's that?

> 
> patch for BUGFIX is attached.
> (Sorry, I have to use Web-Mail and can't make it inlined)

swap_cgroup's kmap logic conflicts shmem's kmap logic.
avoid to use HIGHMEM for now and revisit this later.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: Hugh Dickins <hugh@veritas.com>
---

 mm/page_cgroup.c |    8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

Index: temp/mm/page_cgroup.c
===================================================================
--- temp.orig/mm/page_cgroup.c
+++ temp/mm/page_cgroup.c
@@ -306,7 +306,7 @@ static int swap_cgroup_prepare(int type)
 	ctrl = &swap_cgroup_ctrl[type];
 
 	for (idx = 0; idx < ctrl->length; idx++) {
-		page = alloc_page(GFP_KERNEL | __GFP_HIGHMEM | __GFP_ZERO);
+		page = alloc_page(GFP_KERNEL | __GFP_ZERO);
 		if (!page)
 			goto not_enough_page;
 		ctrl->map[idx] = page;
@@ -347,11 +347,10 @@ struct mem_cgroup *swap_cgroup_record(sw
 
 	mappage = ctrl->map[idx];
 	spin_lock_irqsave(&ctrl->lock, flags);
-	sc = kmap_atomic(mappage, KM_USER0);
+	sc = page_address(mappage);
 	sc += pos;
 	old = sc->val;
 	sc->val = mem;
-	kunmap_atomic((void *)sc, KM_USER0);
 	spin_unlock_irqrestore(&ctrl->lock, flags);
 	return old;
 }
@@ -382,10 +381,9 @@ struct mem_cgroup *lookup_swap_cgroup(sw
 	mappage = ctrl->map[idx];
 
 	spin_lock_irqsave(&ctrl->lock, flags);
-	sc = kmap_atomic(mappage, KM_USER0);
+	sc = page_address(mappage);
 	sc += pos;
 	ret = sc->val;
-	kunmap_atomic((void *)sc, KM_USER0);
 	spin_unlock_irqrestore(&ctrl->lock, flags);
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
