Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2FA0B6B004A
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 10:22:59 -0400 (EDT)
Received: by eyd9 with SMTP id 9so414012eyd.14
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 07:22:56 -0700 (PDT)
Date: Thu, 2 Jun 2011 17:22:42 +0300
From: Maxin B John <maxin.john@gmail.com>
Subject: Re: [PATCH] mm: dmapool: fix possible use after free in
 dmam_pool_destroy()
Message-ID: <20110602142242.GA4115@maxin>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: eike-kernel@sf-tec.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dima@android.com, willy@linux.intel.com, segooon@gmail.com, tj@kernel.org, jkosina@suse.cz, tglx@linutronix.de

On Thu, Jun 2, 2011 at 12:47 PM, Rolf Eike Beer <eike-kernel@sf-tec.de> wrote:
> Maxin B John wrote:
>> "dma_pool_destroy(pool)" calls "kfree(pool)". The freed pointer
>> "pool" is again passed as an argument to the function "devres_destroy()".
>> This patch fixes the possible use after free.
>
> The pool itself is not used there, only the address where the pool
> has been.This will only lead to any trouble if something else is allocated to
> the same place and inserted into the devres list of the same device between
> the dma_pool_destroy() and devres_destroy().

Thank you very much for explaining it in detail. 

> But I agree that this is bad style. But if you are going to change
> this please also have a look at devm_iounmap() in lib/devres.c. Maybe also the
> devm_*irq* functions need the same changes.

As per your suggestion, I have made similar modifications for lib/devres.c and
kernel/irq/devres.c

CCed the maintainers of the respective files.
 
Signed-off-by: Maxin B. John <maxin.john@gmail.com>
---
diff --git a/kernel/irq/devres.c b/kernel/irq/devres.c
index 1ef4ffc..bd8e788 100644
--- a/kernel/irq/devres.c
+++ b/kernel/irq/devres.c
@@ -87,8 +87,8 @@ void devm_free_irq(struct device *dev, unsigned int irq, void *dev_id)
 {
 	struct irq_devres match_data = { irq, dev_id };
 
-	free_irq(irq, dev_id);
 	WARN_ON(devres_destroy(dev, devm_irq_release, devm_irq_match,
 			       &match_data));
+	free_irq(irq, dev_id);
 }
 EXPORT_SYMBOL(devm_free_irq);
diff --git a/lib/devres.c b/lib/devres.c
index 6efddf5..7c0e953 100644
--- a/lib/devres.c
+++ b/lib/devres.c
@@ -79,9 +79,9 @@ EXPORT_SYMBOL(devm_ioremap_nocache);
  */
 void devm_iounmap(struct device *dev, void __iomem *addr)
 {
-	iounmap(addr);
 	WARN_ON(devres_destroy(dev, devm_ioremap_release, devm_ioremap_match,
 			       (void *)addr));
+	iounmap(addr);
 }
 EXPORT_SYMBOL(devm_iounmap);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
