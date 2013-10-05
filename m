Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id B76E16B0031
	for <linux-mm@kvack.org>; Sat,  5 Oct 2013 03:48:26 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so4925160pdj.8
        for <linux-mm@kvack.org>; Sat, 05 Oct 2013 00:48:26 -0700 (PDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sat, 5 Oct 2013 17:48:21 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id 554FA3578052
	for <linux-mm@kvack.org>; Sat,  5 Oct 2013 17:48:20 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r957VMGn63766662
	for <linux-mm@kvack.org>; Sat, 5 Oct 2013 17:31:28 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id r957mD3u023981
	for <linux-mm@kvack.org>; Sat, 5 Oct 2013 17:48:13 +1000
Date: Sat, 5 Oct 2013 15:48:11 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH] slub: Fix calculation of cpu slabs
Message-ID: <524fc449.06a3420a.03dc.ffffb760SMTPIN_ADDED_BROKEN@mx.google.com>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <522E9569.9060104@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <522E9569.9060104@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Sep 10, 2013 at 11:43:37AM +0800, Li Zefan wrote:
>  /sys/kernel/slab/:t-0000048 # cat cpu_slabs
>  231 N0=16 N1=215
>  /sys/kernel/slab/:t-0000048 # cat slabs
>  145 N0=36 N1=109
>
>See, the number of slabs is smaller than that of cpu slabs.
>
>The bug was introduced by commit 49e2258586b423684f03c278149ab46d8f8b6700
>("slub: per cpu cache for partial pages").
>
>We should use page->pages instead of page->pobjects when calculating
>the number of cpu partial slabs. This also fixes the mapping of slabs
>and nodes.
>
>As there's no variable storing the number of total/active objects in
>cpu partial slabs, and we don't have user interfaces requiring those
>statistics, I just add WARN_ON for those cases.
>
>Cc: <stable@vger.kernel.org> # 3.2+
>Signed-off-by: Li Zefan <lizefan@huawei.com>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>---
> mm/slub.c | 8 +++++++-
> 1 file changed, 7 insertions(+), 1 deletion(-)
>
>diff --git a/mm/slub.c b/mm/slub.c
>index e3ba1f2..6ea461d 100644
>--- a/mm/slub.c
>+++ b/mm/slub.c
>@@ -4300,7 +4300,13 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
>
> 			page = ACCESS_ONCE(c->partial);
> 			if (page) {
>-				x = page->pobjects;
>+				node = page_to_nid(page);
>+				if (flags & SO_TOTAL)
>+					WARN_ON_ONCE(1);
>+				else if (flags & SO_OBJECTS)
>+					WARN_ON_ONCE(1);
>+				else
>+					x = page->pages;
> 				total += x;
> 				nodes[node] += x;
> 			}
>-- 
>1.8.0.2
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
