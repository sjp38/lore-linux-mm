Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0866B0105
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 16:25:00 -0500 (EST)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id oAHLOv4M023560
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 13:24:57 -0800
Received: from qwd7 (qwd7.prod.google.com [10.241.193.199])
	by hpaq6.eem.corp.google.com with ESMTP id oAHLMuet016571
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 13:24:56 -0800
Received: by qwd7 with SMTP id 7so1142075qwd.24
        for <linux-mm@kvack.org>; Wed, 17 Nov 2010 13:24:42 -0800 (PST)
Date: Wed, 17 Nov 2010 13:24:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
In-Reply-To: <20101117090457.GA30543@infradead.org>
Message-ID: <alpine.DEB.2.00.1011171320190.10254@chino.kir.corp.google.com>
References: <1289421759.11149.59.camel@oralap> <20101111120643.22dcda5b.akpm@linux-foundation.org> <1289512924.428.112.camel@oralap> <20101111142511.c98c3808.akpm@linux-foundation.org> <1289840500.13446.65.camel@oralap> <alpine.DEB.2.00.1011151303130.8167@chino.kir.corp.google.com>
 <20101116141130.b20a8a8d.akpm@linux-foundation.org> <ED9181FA-6B0E-4A7B-AA2D-7B976A876557@oracle.com> <alpine.DEB.2.00.1011162329570.13242@chino.kir.corp.google.com> <20101117090457.GA30543@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Andreas Dilger <andreas.dilger@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "Ricardo M. Correia" <ricardo.correia@oracle.com>, linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>, Dave Chinner <david@fromorbit.com>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010, Christoph Hellwig wrote:

> As Dave mentioned XFS also needs GFP_NOFS allocations in the low-level
> vmap machinery, which is shared with vmalloc.
> 

Ok, so vm_map_ram() probably needs to be modified to allow gfp_t to be 
passed in after the pte wrappers are in place that can be used to avoid 
the hard-wired GFP_KERNEL in arch code (Ricardo is working on that, I 
believe?); once that's done, it's trivial to pass the gfp_t for xfs to 
lower-level vmalloc code to allocate the necessary vmap_block, vmap_area, 
and radix tree data structures from the slab allocator (they are all 
order-0, at least).

I think the ultimate solution will be able to allow GFP_NOFS to be passed 
into things like vm_map_ram() and __vmalloc() and then try to avoid new 
additions and fix up the callers later, if possible, for the eventual 
removal of all gfp_t formals from the vmalloc layer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
