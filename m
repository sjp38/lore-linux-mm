Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 612A76B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 03:22:46 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id hb3so68033784igb.0
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 00:22:46 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id o4si33358468igv.58.2016.02.16.00.22.44
        for <linux-mm@kvack.org>;
        Tue, 16 Feb 2016 00:22:45 -0800 (PST)
Date: Tue, 16 Feb 2016 19:22:41 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] kernel: fs: drop_caches: add dds drop_caches_count
Message-ID: <20160216082241.GY19486@dastard>
References: <1455308080-27238-1-git-send-email-danielwa@cisco.com>
 <20160214211856.GT19486@dastard>
 <56C216CA.7000703@cisco.com>
 <20160215230511.GU19486@dastard>
 <56C264BF.3090100@cisco.com>
 <20160216052852.GW19486@dastard>
 <alpine.LRH.2.00.1602152135280.29586@mcp-bld-lnx-277.cisco.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.00.1602152135280.29586@mcp-bld-lnx-277.cisco.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nag Avadhanam <nag@cisco.com>
Cc: Daniel Walker <danielwa@cisco.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Khalid Mughal <khalidm@cisco.com>, xe-kernel@external.cisco.com, dave.hansen@intel.com, hannes@cmpxchg.org, riel@redhat.com, Jonathan Corbet <corbet@lwn.net>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon, Feb 15, 2016 at 09:57:42PM -0800, Nag Avadhanam wrote:
> On Mon, 15 Feb 2016, Dave Chinner wrote:
> >So, to pick a random active server here:
> >
> >		before		after
> >Active(file):   12103200 kB	24060 kB
> >Inactive(file):  5976676 kB	 1380 kB
> >Mapped:            31308 kB	31308 kB
> >
> >How much was not reclaimed? Roughly the same number of pages as the
> >Mapped count, and that's exactly what we'd expect to see from the
> >above page walk counting code. Hence a slightly better approximation
> >of the pages that dropping caches will reclaim is:
> >
> >reclaimable pages = active + inactive - dirty - writeback - mapped
> 
> Thanks Dave. I considered that, but see this.
> 
> Mapped page count below is much higher than the (active(file) +
> inactive (file)).

Yes. it's all unreclaimable from drop caches, though.

> Mapped seems to include all page cache pages mapped into the process
> memory, including the shared memory pages, file pages and few other
> type
> mappings.
> 
> I suppose the above can be rewritten as (mapped is still high):
> 
> reclaimable pages = active + inactive + shmem - dirty - writeback - mapped
> 
> What about kernel pages mapped into user address space? Does "Mapped"
> include those pages as well? How do we exclude them? What about
> device mappings? Are these excluded in the "Mapped" pages
> calculation?

/me shrugs.

I have no idea - I really don't care about what pages are accounted
as mapped. I assumed that the patch proposed addressed your
requirements and so I suggested an alternative that provided almost
exactly the same information but erred on the side of
underestimation and hence solves your problem of drop_caches not
freeing as much memory as you expected....

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
