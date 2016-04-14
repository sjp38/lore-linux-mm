Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 21CA66B0005
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 21:34:48 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u190so103445317pfb.0
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 18:34:48 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 79si4320376pfo.227.2016.04.13.18.34.46
        for <linux-mm@kvack.org>;
        Wed, 13 Apr 2016 18:34:47 -0700 (PDT)
Date: Thu, 14 Apr 2016 10:35:47 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: linux-next crash during very early boot
Message-ID: <20160414013546.GA9198@js1304-P5Q-DELUXE>
References: <3689.1460593786@turing-police.cc.vt.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3689.1460593786@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 13, 2016 at 08:29:46PM -0400, Valdis Kletnieks wrote:
> I'm seeing my laptop crash/wedge up/something during very early
> boot - before it can write anything to the console.  Nothing in pstore,
> need to hold down the power button for 6 seconds and reboot.
> 
> git bisect points at:
> 
> commit 7a6bacb133752beacb76775797fd550417e9d3a2
> Author: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Date:   Thu Apr 7 13:59:39 2016 +1000
> 
>     mm/slab: factor out kmem_cache_node initialization code
> 
>     It can be reused on other place, so factor out it.  Following patch will
>     use it.
> 
> 
> Not sure what the problem is - the logic *looks* ok at first read.  The
> patch *does* remove a spin_lock_irq() - but I find it difficult to
> believe that with it gone, my laptop is able to hit the race condition
> the spinlock protects against *every single boot*.
> 
> The only other thing I see is that n->free_limit used to be assigned
> every time, and now it's only assigned at initial creation.

Hello,

My fault. It should be assgined every time. Please test below patch.
I will send it with proper SOB after you confirm the problem disappear.
Thanks for report and analysis!

Thanks.

---------------->8-----------------
diff --git a/mm/slab.c b/mm/slab.c
index 13e74aa..59dd94a 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -856,8 +856,14 @@ static int init_cache_node(struct kmem_cache *cachep, int node, gfp_t gfp)
 	 * node has not already allocated this
 	 */
 	n = get_node(cachep, node);
-	if (n)
+	if (n) {
+		spin_lock_irq(&n->list_lock);
+		n->free_limit = (1 + nr_cpus_node(node)) * cachep->batchcount +
+				cachep->num;
+		spin_unlock_irq(&n->list_lock);
+
 		return 0;
+	}
 
 	n = kmalloc_node(sizeof(struct kmem_cache_node), gfp, node);
 	if (!n)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
