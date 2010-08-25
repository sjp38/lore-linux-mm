Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ADC566B02A9
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 19:32:33 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [172.25.149.7])
	by smtp-out.google.com with ESMTP id o7PNWWF7031980
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 16:32:32 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by hpaq7.eem.corp.google.com with ESMTP id o7PNWURu021511
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 16:32:31 -0700
Received: by pzk9 with SMTP id 9so386649pzk.5
        for <linux-mm@kvack.org>; Wed, 25 Aug 2010 16:32:30 -0700 (PDT)
Date: Wed, 25 Aug 2010 16:32:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: linux-next: Tree for August 25 (mm/slub)
In-Reply-To: <alpine.DEB.2.00.1008251447410.22117@router.home>
Message-ID: <alpine.DEB.2.00.1008251622500.31521@chino.kir.corp.google.com>
References: <20100825132057.c8416bef.sfr@canb.auug.org.au> <20100825094559.bc652afe.randy.dunlap@oracle.com> <alpine.DEB.2.00.1008251409260.22117@router.home> <20100825122134.2ac33360.randy.dunlap@oracle.com>
 <alpine.DEB.2.00.1008251447410.22117@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Aug 2010, Christoph Lameter wrote:

> > Certainly.  config file is attached.
> 
> Ah. Memory hotplug....
> 
> 
> 
> Subject: Slub: Fix up missing kmalloc_cache -> kmem_cache_node case for memoryhotplug
> 
> Memory hotplug allocates and frees per node structures. Use the correct name.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

But we also need to fixup SLUB_RESILIENCY_TEST.


slub: fix SLUB_RESILIENCY_TEST for dynamic kmalloc caches

Now that the kmalloc_caches array is dynamically allocated at boot, 
SLUB_RESILIENCY_TEST needs to be fixed to pass the correct type.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slub.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3486,6 +3486,8 @@ static void resiliency_test(void)
 {
 	u8 *p;
 
+	BUILD_BUG_ON(KMALLOC_MIN_SIZE > 16 || SLUB_PAGE_SHIFT < 10);
+
 	printk(KERN_ERR "SLUB resiliency testing\n");
 	printk(KERN_ERR "-----------------------\n");
 	printk(KERN_ERR "A. Corruption after allocation\n");
@@ -3495,7 +3497,7 @@ static void resiliency_test(void)
 	printk(KERN_ERR "\n1. kmalloc-16: Clobber Redzone/next pointer"
 			" 0x12->0x%p\n\n", p + 16);
 
-	validate_slab_cache(kmalloc_caches + 4);
+	validate_slab_cache(kmalloc_caches[4]);
 
 	/* Hmmm... The next two are dangerous */
 	p = kzalloc(32, GFP_KERNEL);
@@ -3505,7 +3507,7 @@ static void resiliency_test(void)
 	printk(KERN_ERR
 		"If allocated object is overwritten then not detectable\n\n");
 
-	validate_slab_cache(kmalloc_caches + 5);
+	validate_slab_cache(kmalloc_caches[5]);
 	p = kzalloc(64, GFP_KERNEL);
 	p += 64 + (get_cycles() & 0xff) * sizeof(void *);
 	*p = 0x56;
@@ -3513,27 +3515,27 @@ static void resiliency_test(void)
 									p);
 	printk(KERN_ERR
 		"If allocated object is overwritten then not detectable\n\n");
-	validate_slab_cache(kmalloc_caches + 6);
+	validate_slab_cache(kmalloc_caches[6]);
 
 	printk(KERN_ERR "\nB. Corruption after free\n");
 	p = kzalloc(128, GFP_KERNEL);
 	kfree(p);
 	*p = 0x78;
 	printk(KERN_ERR "1. kmalloc-128: Clobber first word 0x78->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches + 7);
+	validate_slab_cache(kmalloc_caches[7]);
 
 	p = kzalloc(256, GFP_KERNEL);
 	kfree(p);
 	p[50] = 0x9a;
 	printk(KERN_ERR "\n2. kmalloc-256: Clobber 50th byte 0x9a->0x%p\n\n",
 			p);
-	validate_slab_cache(kmalloc_caches + 8);
+	validate_slab_cache(kmalloc_caches[8]);
 
 	p = kzalloc(512, GFP_KERNEL);
 	kfree(p);
 	p[512] = 0xab;
 	printk(KERN_ERR "\n3. kmalloc-512: Clobber redzone 0xab->0x%p\n\n", p);
-	validate_slab_cache(kmalloc_caches + 9);
+	validate_slab_cache(kmalloc_caches[9]);
 }
 #else
 static void resiliency_test(void) {};

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
