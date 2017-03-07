Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 37E916B0388
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 13:57:54 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id l66so17339273pfl.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 10:57:54 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id n64si820598pfj.43.2017.03.07.10.57.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 10:57:53 -0800 (PST)
Date: Tue, 7 Mar 2017 10:57:48 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm, vmalloc: use __GFP_HIGHMEM implicitly
Message-ID: <20170307185748.GU16328@bombadil.infradead.org>
References: <20170307141020.29107-1-mhocko@kernel.org>
 <20170307182841.GS16328@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170307182841.GS16328@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>, Cristopher Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Mar 07, 2017 at 10:28:41AM -0800, Matthew Wilcox wrote:
> On Tue, Mar 07, 2017 at 03:10:20PM +0100, Michal Hocko wrote:
> > This patch simply uses __GFP_HIGHMEM implicitly when allocating pages to
> > be mapped to the vmalloc space. Current users which add __GFP_HIGHMEM
> > are simplified and drop the flag.

btw, I had another idea for GFP_HIGHMEM -- remove it when CONFIG_HIGHMEM
isn't enabled.  Saves 26 bytes of .text and 64 bytes of .data on my
laptop's kernel build.  What do you think?

Also, I suspect the layout of bits is suboptimal from an assembly
language perspective.  I still mostly care about x86 which doesn't
benefit, so I'm not inclined to do the work, but certainly ARM, PA-RISC,
SPARC and Itanium would all benefit from having frequently-used bits
(ie those used in GFP_KERNEL and GFP_ATOMIC) placed in the low 8 bits.

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0fe0b6295ab5..d88cb532d7c8 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -16,7 +16,11 @@ struct vm_area_struct;
 
 /* Plain integer GFP bitmasks. Do not use this directly. */
 #define ___GFP_DMA		0x01u
+#ifdef CONFIG_HIGHMEM
 #define ___GFP_HIGHMEM		0x02u
+#else
+#define ___GFP_HIGHMEM		0x0u
+#endif
 #define ___GFP_DMA32		0x04u
 #define ___GFP_MOVABLE		0x08u
 #define ___GFP_RECLAIMABLE	0x10u

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
