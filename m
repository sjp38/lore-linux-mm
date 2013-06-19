From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: do not put a slab to cpu partial list when
 cpu_partial is 0
Date: Wed, 19 Jun 2013 16:00:32 +0800
Message-ID: <15843.3700948537$1371628853@news.gmane.org>
References: <1371623635-26575-1-git-send-email-iamjoonsoo.kim@lge.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by plane.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1UpDJs-0003gt-8a
	for glkm-linux-mm-2@m.gmane.org; Wed, 19 Jun 2013 10:00:44 +0200
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 073A16B0033
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 04:00:41 -0400 (EDT)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 19 Jun 2013 17:51:55 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id BB4E32BB0050
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 18:00:36 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r5J80Qoh51642504
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 18:00:27 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r5J80Y4m004881
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 18:00:34 +1000
Content-Disposition: inline
In-Reply-To: <1371623635-26575-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jun 19, 2013 at 03:33:55PM +0900, Joonsoo Kim wrote:
>In free path, we don't check number of cpu_partial, so one slab can
>be linked in cpu partial list even if cpu_partial is 0. To prevent this,
>we should check number of cpu_partial in put_cpu_partial().
>

How about skip get_partial entirely? put_cpu_partial is called 
in two paths, one is during refill cpu partial lists in alloc 
slow path, the other is in free slow path. And cpu_partial is 0 
just in debug mode. 

- alloc slow path, there is unnecessary to call get_partial 
  since cpu partial lists won't be used in debug mode. 
- free slow patch, new.inuse won't be true in debug mode 
  which lead to put_cpu_partial won't be called.

Regards,
Wanpeng Li 

>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
>diff --git a/mm/slub.c b/mm/slub.c
>index 57707f0..7033b4f 100644
>--- a/mm/slub.c
>+++ b/mm/slub.c
>@@ -1955,6 +1955,9 @@ static void put_cpu_partial(struct kmem_cache *s, struct page *page, int drain)
> 	int pages;
> 	int pobjects;
>
>+	if (!s->cpu_partial)
>+		return;
>+
> 	do {
> 		pages = 0;
> 		pobjects = 0;
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
