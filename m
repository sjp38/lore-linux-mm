Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 073CC6B0038
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 06:42:21 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m22so45023775pgc.4
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 03:42:20 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id t5si14053979pfb.146.2017.04.18.03.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 03:42:20 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id c198so29835951pfc.0
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 03:42:20 -0700 (PDT)
Date: Tue, 18 Apr 2017 19:42:22 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: copy_page() on a kmalloc-ed page with DEBUG_SLAB enabled (was
 "zram: do not use copy_page with non-page alinged address")
Message-ID: <20170418104222.GB558@jagdpanzerIV.localdomain>
References: <20170417014803.GC518@jagdpanzerIV.localdomain>
 <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1704171016550.28407@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>


On (04/17/17 10:20), Christoph Lameter wrote:
> On Mon, 17 Apr 2017, Sergey Senozhatsky wrote:
> > Minchan reported that doing copy_page() on a kmalloc(PAGE_SIZE) page
> > with DEBUG_SLAB enabled can cause a memory corruption (See below or
> > lkml.kernel.org/r/1492042622-12074-2-git-send-email-minchan@kernel.org )
> 
> Yes the alignment guarantees do not require alignment on a page boundary.
> 
> The alignment for kmalloc allocations is controlled by KMALLOC_MIN_ALIGN.
> Usually this is either double word aligned or cache line aligned.
> 
> > that's an interesting problem. arm64 copy_page(), for instance, wants src
> > and dst to be page aligned, which is reasonable, while generic copy_page(),
> > on the contrary, simply does memcpy(). there are, probably, other callpaths
> > that do copy_page() on kmalloc-ed pages and I'm wondering if there is some
> > sort of a generic fix to the problem.
> 
> Simple solution is to not allocate pages via the slab allocator but use
> the page allocator for this. The page allocator provides proper alignment.

sure, but at the same time it's not completely uncommon and unseen thing

~/_next$ git grep kmalloc | grep PAGE_SIZE | wc -l
75

not all, if any, of those pages get into copy_page(), of course. may be... hopefully.
so may be a warning would make sense and save time some day. but up to MM
people to decide.


p.s. Christoph, FYI, gmail automatically marked your message
     as a spam message, for some reason.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
