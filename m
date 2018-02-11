Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id AB2D46B0006
	for <linux-mm@kvack.org>; Sun, 11 Feb 2018 04:26:57 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x11so5603061pgr.9
        for <linux-mm@kvack.org>; Sun, 11 Feb 2018 01:26:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x20si4639876pfa.129.2018.02.11.01.26.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 11 Feb 2018 01:26:56 -0800 (PST)
Date: Sun, 11 Feb 2018 10:26:52 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Regression after commit 19809c2da28a ("mm, vmalloc: use
 __GFP_HIGHMEM implicitly")
Message-ID: <20180211092652.GV21609@dhcp22.suse.cz>
References: <627DA40A-D0F6-41C1-BB5A-55830FBC9800@canonical.com>
 <20180208130649.GA15846@bombadil.infradead.org>
 <20180208232004.GA21027@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180208232004.GA21027@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Kai Heng Feng <kai.heng.feng@canonical.com>, Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu 08-02-18 15:20:04, Matthew Wilcox wrote:
> On Thu, Feb 08, 2018 at 05:06:49AM -0800, Matthew Wilcox wrote:
> > On Thu, Feb 08, 2018 at 02:29:57PM +0800, Kai Heng Feng wrote:
> > > A user with i386 instead of AMD64 machine reports [1] that commit 19809c2da28a ("mm, vmalloc: use __GFP_HIGHMEM implicitlya??) causes a regression.
> > > BUG_ON(PageHighMem(pg)) in drivers/media/common/saa7146/saa7146_core.c always gets triggered after that commit.
> > 
> > Well, the BUG_ON is wrong.  You can absolutely have pages which are both
> > HighMem and under the 4GB boundary.  Only the first 896MB (iirc) are LowMem,
> > and the next 3GB of pages are available to vmalloc_32().
> 
> ... nevertheless, 19809c2da28a does in fact break vmalloc_32 on 32-bit.  Look:
> 
> #if defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA32)
> #define GFP_VMALLOC32 GFP_DMA32 | GFP_KERNEL
> #elif defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA)
> #define GFP_VMALLOC32 GFP_DMA | GFP_KERNEL
> #else
> #define GFP_VMALLOC32 GFP_KERNEL
> #endif
> 
> So we pass in GFP_KERNEL to __vmalloc_node, which calls __vmalloc_node_range
> which calls __vmalloc_area_node, which ORs in __GFP_HIGHMEM.

Dohh. I have missed this. I was convinced that we always add GFP_DMA32
when doing vmalloc_32. Sorry about that. The above definition looks
quite weird to be honest. First of all do we have any 64b system without
both DMA and DMA32 zones? If yes, what is the actual semantic of
vmalloc_32? Or is there any magic forcing GFP_KERNEL into low 32b?

Also I would expect that __GFP_DMA32 should do the right thing on 32b
systems. So something like the below should do the trick
---
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 673942094328..2eab5d1ef548 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1947,7 +1947,8 @@ void *vmalloc_exec(unsigned long size)
 #elif defined(CONFIG_64BIT) && defined(CONFIG_ZONE_DMA)
 #define GFP_VMALLOC32 GFP_DMA | GFP_KERNEL
 #else
-#define GFP_VMALLOC32 GFP_KERNEL
+/* This should be only 32b systems */
+#define GFP_VMALLOC32 GFP_DMA32 | GFP_KERNEL
 #endif
 
 /**

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
