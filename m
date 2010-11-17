Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 700AD8D0080
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 02:37:50 -0500 (EST)
Received: from hpaq6.eem.corp.google.com (hpaq6.eem.corp.google.com [172.25.149.6])
	by smtp-out.google.com with ESMTP id oAH7bkYn028753
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:37:46 -0800
Received: from iwn3 (iwn3.prod.google.com [10.241.68.67])
	by hpaq6.eem.corp.google.com with ESMTP id oAH7biPQ029140
	for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:37:45 -0800
Received: by iwn3 with SMTP id 3so2005935iwn.26
        for <linux-mm@kvack.org>; Tue, 16 Nov 2010 23:37:44 -0800 (PST)
Date: Tue, 16 Nov 2010 23:37:39 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
In-Reply-To: <ED9181FA-6B0E-4A7B-AA2D-7B976A876557@oracle.com>
Message-ID: <alpine.DEB.2.00.1011162329570.13242@chino.kir.corp.google.com>
References: <1289421759.11149.59.camel@oralap> <20101111120643.22dcda5b.akpm@linux-foundation.org> <1289512924.428.112.camel@oralap> <20101111142511.c98c3808.akpm@linux-foundation.org> <1289840500.13446.65.camel@oralap> <alpine.DEB.2.00.1011151303130.8167@chino.kir.corp.google.com>
 <20101116141130.b20a8a8d.akpm@linux-foundation.org> <ED9181FA-6B0E-4A7B-AA2D-7B976A876557@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andreas Dilger <andreas.dilger@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Ricardo M. Correia" <ricardo.correia@oracle.com>, linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>
List-ID: <linux-mm.kvack.org>

On Wed, 17 Nov 2010, Andreas Dilger wrote:

> >> - avoid doing anything other than GFP_KERNEL allocations for __vmalloc():
> >>   the only current users are gfs2, ntfs, and ceph (the page allocator
> >>   __vmalloc() can be discounted since it's done at boot and GFP_ATOMIC
> >>   here has almost no chance of failing since the size is determined based 
> >>   on what is available).
> > 
> > ^^ this
> > 
> > Using vmalloc anywhere is lame.
> 
> I agree.  What we really want is 1MB kmalloc() to work...  :-/
> 

Order-8 allocations are already have a higher liklihood of succeeding 
because of memory compaction, which was explicitly targeted to aid in 
order-9 hugepage allocations.  The problem is that it's useless for 
GFP_NOFS.

I think removing gfp_t arguments from all of the public vmalloc interface 
will inevitably be where we go with this and everything will assume 
GFP_KERNEL | __GFP_HIGHMEM.

If you _really_ need 1MB of physically contiguous memory, then you'll need 
to find a way to do it in a reclaimable context.  If we actually can 
remove the dependency that gfs2, ntfs, and ceph have in the kernel.org 
kernel, then this support may be pulled out from under you; the worst-case 
scenario for Lustre is that you'll have to modify the callchains like I 
suggested in my original email to pass the gfp mask all the way down to 
the pte allocators if you can't find a way to do it under GFP_KERNEL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
