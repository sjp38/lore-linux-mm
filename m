Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id B5F236B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 21:15:41 -0400 (EDT)
Received: by pacwi10 with SMTP id wi10so13336891pac.3
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 18:15:41 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id uf1si32714308pab.210.2015.09.01.18.15.39
        for <linux-mm@kvack.org>;
        Tue, 01 Sep 2015 18:15:40 -0700 (PDT)
Date: Wed, 2 Sep 2015 11:15:24 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] mm/slab_common: add SLAB_NO_MERGE flag for use when
 creating slabs
Message-ID: <20150902011524.GM26895@dastard>
References: <1441129890-25585-1-git-send-email-snitzer@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1441129890-25585-1-git-send-email-snitzer@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Snitzer <snitzer@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com, axboe@kernel.dk, dm-devel@redhat.com, anderson@redhat.com

On Tue, Sep 01, 2015 at 01:51:29PM -0400, Mike Snitzer wrote:
> The slab aliasing/merging by default transition went unnoticed (at least
> to the DM subsystem).  Add a new SLAB_NO_MERGE flag that allows
> individual slabs to be created without slab merging.  This beats forcing
> all slabs to be created in this fashion by specifying sl[au]b_nomerge on
> the kernel commandline.

I didn't realise that this merging had also been applied to SLAB - I
thought it was just SLUB that did this.  Indeed, one of the prime
reasons for using SLAB over SLUB was that it didn't merge caches and
so still gave excellent visibility of runtime slab memory usage on
production systems.

I had no idea that commit 12220de ("mm/slab: support slab merge")
had made SLAB do this as well as it was not cc'd to any of the
people/subsystems that maintain code that uses slab caches.  IMNSHO
the commit message gives pretty flimsy justification for such a
change, especially considering we need to deal with slab caches that
individually grow to contain hundreds of millions of objects.

> DM has historically taken care to have separate named slabs that each
> devices' mempool_t are backed by.  These separate slabs are useful --
> even if only to aid inspection of DM's memory use (via /proc/slabinfo)
> on production systems.

Yup, that's one of the reasons XFS has 17 separate slab caches. The
other main reason is that slab separation also helps keep memory
corruption and use-after free issues contained; if you have a
problem with the objects from one slab cache, the isolation of the
slab makes it less likely that the problem propagates to other
subsystems. Hence failures also tend to be isolated to the code that
has the leak/corruption problem, making them easier to triage and
debug on production systems...

> I stumbled onto slab merging as a side-effect of a leak in dm-cache
> being attributed to 'kmalloc-96' rather than the expected
> 'dm_bio_prison_cell' named slab.  Moving forward DM will disable slab
> merging for all of DM's slabs by using SLAB_NO_MERGE.

Seems like a fine idea to me. I can apply it to various slabs in XFS
once it's merged....

Acked-by: Dave Chinner <dchinner@redhat.com>

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
