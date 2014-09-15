Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id ACC136B0035
	for <linux-mm@kvack.org>; Sun, 14 Sep 2014 22:11:47 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lj1so5424093pab.27
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 19:11:47 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id j5si20096234pdk.197.2014.09.14.19.11.45
        for <linux-mm@kvack.org>;
        Sun, 14 Sep 2014 19:11:46 -0700 (PDT)
Date: Mon, 15 Sep 2014 11:11:34 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] slab: implement kmalloc guard
Message-ID: <20140915021133.GC2676@js1304-P5Q-DELUXE>
References: <alpine.LRH.2.02.1409051833510.9790@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.11.1409080932490.20388@gentwo.org>
 <alpine.LRH.2.02.1409081041160.29432@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.11.1409081108190.20388@gentwo.org>
 <alpine.LRH.2.02.1409112211060.30537@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1409112211060.30537@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Alasdair G. Kergon" <agk@redhat.com>, Mike Snitzer <msnitzer@redhat.com>, Milan Broz <gmazyland@gmail.com>, kkolasa@winsoft.pl, dm-devel@redhat.com

On Thu, Sep 11, 2014 at 10:32:52PM -0400, Mikulas Patocka wrote:
> 
> 
> On Mon, 8 Sep 2014, Christoph Lameter wrote:
> 
> > On Mon, 8 Sep 2014, Mikulas Patocka wrote:
> > 
> > > I don't know what you mean. If someone allocates 10000 objects with sizes
> > > from 1 to 10000, you can't have 10000 slab caches - you can't have a slab
> > > cache for each used size. Also - you can't create a slab cache in
> > > interrupt context.
> > 
> > Oh you can create them up front on bootup. And I think only the small
> > sizes matter. Allocations >=8K are pushed to the page allocator anyways.
> 
> Only for SLUB. For SLAB, large allocations are still use SLAB caches up to 
> 4M. But anyway - having 8K preallocated slab caches is too much.
> 
> If you want to integrate this patch into the slab/slub subsystem, a better 
> solution would be to store the exact size requested with kmalloc along the 
> slab/slub object itself (before the preceding redzone). But it would 
> result in duplicating the work - you'd have to repeat the logic in this 
> patch three times - once for slab, once for slub and once for 
> kmalloc_large/kmalloc_large_node.
> 
> I don't know if it would be better than this patch.

Hello,

Out of bound write could be detected by kernel address asanitizer(KASan).
See following link.

https://lkml.org/lkml/2014/9/10/441

Although this patch also looks good to me, I think that KASan is
better than this, because it could detect out of bound write and
has more features for debugging.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
