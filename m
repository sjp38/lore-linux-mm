Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 277CD6B0035
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 22:33:14 -0400 (EDT)
Received: by mail-qg0-f52.google.com with SMTP id i50so100172qgf.11
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 19:33:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j4si4061486qgf.81.2014.09.11.19.33.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Sep 2014 19:33:13 -0700 (PDT)
Date: Thu, 11 Sep 2014 22:32:52 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] slab: implement kmalloc guard
In-Reply-To: <alpine.DEB.2.11.1409081108190.20388@gentwo.org>
Message-ID: <alpine.LRH.2.02.1409112211060.30537@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1409051833510.9790@file01.intranet.prod.int.rdu2.redhat.com> <alpine.DEB.2.11.1409080932490.20388@gentwo.org> <alpine.LRH.2.02.1409081041160.29432@file01.intranet.prod.int.rdu2.redhat.com>
 <alpine.DEB.2.11.1409081108190.20388@gentwo.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Alasdair G. Kergon" <agk@redhat.com>, Mike Snitzer <msnitzer@redhat.com>, Milan Broz <gmazyland@gmail.com>, kkolasa@winsoft.pl, dm-devel@redhat.com



On Mon, 8 Sep 2014, Christoph Lameter wrote:

> On Mon, 8 Sep 2014, Mikulas Patocka wrote:
> 
> > I don't know what you mean. If someone allocates 10000 objects with sizes
> > from 1 to 10000, you can't have 10000 slab caches - you can't have a slab
> > cache for each used size. Also - you can't create a slab cache in
> > interrupt context.
> 
> Oh you can create them up front on bootup. And I think only the small
> sizes matter. Allocations >=8K are pushed to the page allocator anyways.

Only for SLUB. For SLAB, large allocations are still use SLAB caches up to 
4M. But anyway - having 8K preallocated slab caches is too much.

If you want to integrate this patch into the slab/slub subsystem, a better 
solution would be to store the exact size requested with kmalloc along the 
slab/slub object itself (before the preceding redzone). But it would 
result in duplicating the work - you'd have to repeat the logic in this 
patch three times - once for slab, once for slub and once for 
kmalloc_large/kmalloc_large_node.

I don't know if it would be better than this patch.

> > > We already have a redzone structure to check for writes over the end of
> > > the object. Lets use that.
> >
> > So, change all three slab subsystems to use that.
> 
> SLOB has no debugging features and I think that was intentional. We are
> trying to unify the debug checks etc. Some work on that would be
> appreciated. I think the kmalloc creation is already in slab_common.c

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
