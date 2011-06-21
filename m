Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 81E726B00F8
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 20:03:36 -0400 (EDT)
Date: Mon, 20 Jun 2011 17:02:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Q] mm/memblock.c: cast truncates bits from RED_INACTIVE
Message-Id: <20110620170249.d5cd98b1.akpm@linux-foundation.org>
In-Reply-To: <ADE657CA350FB648AAC2C43247A983F001F382220E0F@AUSP01VMBX24.collaborationhost.net>
References: <ADE657CA350FB648AAC2C43247A983F001F382220E0F@AUSP01VMBX24.collaborationhost.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: H Hartley Sweeten <hartleys@visionengravers.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "benh@kernel.crashing.org" <benh@kernel.crashing.org>, "yinghai@kernel.org" <yinghai@kernel.org>, "hpa@linux.intel.com" <hpa@linux.intel.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 14 Jun 2011 19:47:19 -0500
H Hartley Sweeten <hartleys@visionengravers.com> wrote:

> Hello all,
> 
> Sparse is reporting a couple warnings in mm/memblock.c:
> 
> 	warning: cast truncates bits from constant value (9f911029d74e35b becomes 9d74e35b)
> 
> The warnings are due to the cast of RED_INACTIVE in memblock_analyze():
> 
> 	/* Check marker in the unused last array entry */
> 	WARN_ON(memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS].base
> 		!= (phys_addr_t)RED_INACTIVE);
> 	WARN_ON(memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS].base
> 		!= (phys_addr_t)RED_INACTIVE);
> 
> And in memblock_init():
> 
> 	/* Write a marker in the unused last array entry */
> 	memblock.memory.regions[INIT_MEMBLOCK_REGIONS].base = (phys_addr_t)RED_INACTIVE;
> 	memblock.reserved.regions[INIT_MEMBLOCK_REGIONS].base = (phys_addr_t)RED_INACTIVE;
> 
> Could this cause any problems?  If not, is there anyway to quiet the sparse noise?
> 

It's all just a debugging check and that check will continue to work OK
despite this bug.

But yes, it's ugly and should be fixed.

I don't think that mm/memblock.c should have reused RED_INACTIVE. 
That's a slab thing and wedging it into a phys_addr_t was
inappropriate.

In fact I don't think RED_INACTIVE should exist.  It's just inviting
other subsystems to (ab)use it.  It should be replaced by a
slab-specific SLAB_RED_INACTIVE, as slub did with SLUB_RED_INACTIVE.


I'd suggest something like the below, which I didn't test.  Feel free to
send it back at me, or ignore it ;)


diff -puN include/linux/poison.h~a include/linux/poison.h
--- a/include/linux/poison.h~a
+++ a/include/linux/poison.h
@@ -40,6 +40,12 @@
 #define	RED_INACTIVE	0x09F911029D74E35BULL	/* when obj is inactive */
 #define	RED_ACTIVE	0xD84156C5635688C0ULL	/* when obj is active */
 
+#ifdef CONFIG_PHYS_ADDR_T_64BIT
+#define MEMBLOCK_INACTIVE	0x3a84fb0144c9e71bULL
+#else
+#define MEMBLOCK_INACTIVE	0x44c9e71bUL
+#endif
+
 #define SLUB_RED_INACTIVE	0xbb
 #define SLUB_RED_ACTIVE		0xcc
 
diff -puN mm/memblock.c~a mm/memblock.c
--- a/mm/memblock.c~a
+++ a/mm/memblock.c
@@ -758,9 +758,9 @@ void __init memblock_analyze(void)
 
 	/* Check marker in the unused last array entry */
 	WARN_ON(memblock_memory_init_regions[INIT_MEMBLOCK_REGIONS].base
-		!= (phys_addr_t)RED_INACTIVE);
+		!= MEMBLOCK_INACTIVE);
 	WARN_ON(memblock_reserved_init_regions[INIT_MEMBLOCK_REGIONS].base
-		!= (phys_addr_t)RED_INACTIVE);
+		!= MEMBLOCK_INACTIVE);
 
 	memblock.memory_size = 0;
 
@@ -786,8 +786,8 @@ void __init memblock_init(void)
 	memblock.reserved.max	= INIT_MEMBLOCK_REGIONS;
 
 	/* Write a marker in the unused last array entry */
-	memblock.memory.regions[INIT_MEMBLOCK_REGIONS].base = (phys_addr_t)RED_INACTIVE;
-	memblock.reserved.regions[INIT_MEMBLOCK_REGIONS].base = (phys_addr_t)RED_INACTIVE;
+	memblock.memory.regions[INIT_MEMBLOCK_REGIONS].base = MEMBLOCK_INACTIVE;
+	memblock.reserved.regions[INIT_MEMBLOCK_REGIONS].base = MEMBLOCK_INACTIVE;
 
 	/* Create a dummy zero size MEMBLOCK which will get coalesced away later.
 	 * This simplifies the memblock_add() code below...
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
