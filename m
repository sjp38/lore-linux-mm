From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] mm, vmalloc: use well-defined find_last_bit() func
Date: Fri, 2 Aug 2013 16:28:28 +0800
Message-ID: <28866.8905072429$1375432130@news.gmane.org>
References: <1375408621-16563-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375408621-16563-2-git-send-email-iamjoonsoo.kim@lge.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1V5Aj3-0007L6-NO
	for glkm-linux-mm-2@m.gmane.org; Fri, 02 Aug 2013 10:28:41 +0200
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 2E2076B0031
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 04:28:39 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Fri, 2 Aug 2013 18:15:47 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 191F92BB0053
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 18:28:31 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r728CuAr4456820
	for <linux-mm@kvack.org>; Fri, 2 Aug 2013 18:12:56 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r728SUws005550
	for <linux-mm@kvack.org>; Fri, 2 Aug 2013 18:28:30 +1000
Content-Disposition: inline
In-Reply-To: <1375408621-16563-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, Aug 02, 2013 at 10:57:01AM +0900, Joonsoo Kim wrote:
>Our intention in here is to find last_bit within the region to flush.
>There is well-defined function, find_last_bit() for this purpose and
>it's performance may be slightly better than current implementation.
>So change it.
>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>
>diff --git a/mm/vmalloc.c b/mm/vmalloc.c
>index d23c432..93d3182 100644
>--- a/mm/vmalloc.c
>+++ b/mm/vmalloc.c
>@@ -1016,15 +1016,16 @@ void vm_unmap_aliases(void)
>
> 		rcu_read_lock();
> 		list_for_each_entry_rcu(vb, &vbq->free, free_list) {
>-			int i;
>+			int i, j;
>
> 			spin_lock(&vb->lock);
> 			i = find_first_bit(vb->dirty_map, VMAP_BBMAP_BITS);
>-			while (i < VMAP_BBMAP_BITS) {
>+			if (i < VMAP_BBMAP_BITS) {
> 				unsigned long s, e;
>-				int j;
>-				j = find_next_zero_bit(vb->dirty_map,
>-					VMAP_BBMAP_BITS, i);
>+
>+				j = find_last_bit(vb->dirty_map,
>+							VMAP_BBMAP_BITS);
>+				j = j + 1; /* need exclusive index */
>
> 				s = vb->va->va_start + (i << PAGE_SHIFT);
> 				e = vb->va->va_start + (j << PAGE_SHIFT);
>@@ -1034,10 +1035,6 @@ void vm_unmap_aliases(void)
> 					start = s;
> 				if (e > end)
> 					end = e;
>-
>-				i = j;
>-				i = find_next_bit(vb->dirty_map,
>-							VMAP_BBMAP_BITS, i);
> 			}
> 			spin_unlock(&vb->lock);
> 		}
>-- 
>1.7.9.5
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
