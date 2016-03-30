Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 54FD76B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 04:23:17 -0400 (EDT)
Received: by mail-ig0-f175.google.com with SMTP id l20so35160775igf.0
        for <linux-mm@kvack.org>; Wed, 30 Mar 2016 01:23:17 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id t37si3769878ioi.205.2016.03.30.01.23.15
        for <linux-mm@kvack.org>;
        Wed, 30 Mar 2016 01:23:16 -0700 (PDT)
Date: Wed, 30 Mar 2016 17:25:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 06/11] mm/slab: don't keep free slabs if free_objects
 exceeds free_limit
Message-ID: <20160330082514.GE1678@js1304-P5Q-DELUXE>
References: <1459142821-20303-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1459142821-20303-7-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.20.1603282000270.31323@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1603282000270.31323@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Jesper Dangaard Brouer <brouer@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 28, 2016 at 08:03:16PM -0500, Christoph Lameter wrote:
> On Mon, 28 Mar 2016, js1304@gmail.com wrote:
> 
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> > Currently, determination to free a slab is done whenever free object is
> > put into the slab. This has a problem that free slabs are not freed
> > even if we have free slabs and have more free_objects than free_limit
> 
> There needs to be a better explanation here since I do not get why there
> is an issue with checking after free if a slab is actually free.

Okay. Consider following 3 objects free situation.

free_limt = 10
nr_free = 9

free(free slab) free(free slab) free(not free slab)

If we check it one by one, when nr_free > free_limit (at last free),
we cannot free the slab because current slab isn't a free slab.

But, if we check it lastly, we can free 1 free slab.

I will add more explanation on the next version.

> 
> > when processed slab isn't a free slab. This would cause to keep
> > too much memory in the slab subsystem. This patch try to fix it
> > by checking number of free object after all free work is done. If there
> > is free slab at that time, we can free it so we keep free slab as minimal
> > as possible.
> 
> Ok if we check after free work is done then the number of free slabs may
> be higher than the limit set and then we free the additional slabs to get
> down to the limit that was set?

Yes.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
