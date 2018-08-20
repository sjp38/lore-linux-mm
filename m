Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7228C6B1B48
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 17:53:27 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e15-v6so8507028pfi.5
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 14:53:27 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id r28-v6si10427533pgk.458.2018.08.20.14.53.25
        for <linux-mm@kvack.org>;
        Mon, 20 Aug 2018 14:53:26 -0700 (PDT)
Date: Tue, 21 Aug 2018 07:53:22 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: introduce kvvirt_to_page() helper
Message-ID: <20180820215322.GF31495@dastard>
References: <1534596541-31393-1-git-send-email-lirongqing@baidu.com>
 <20180820144116.GO29735@dhcp22.suse.cz>
 <20180820144923.GA25153@bombadil.infradead.org>
 <20180820162406.GQ29735@dhcp22.suse.cz>
 <20180820170744.GD25153@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180820170744.GD25153@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>, Li RongQing <lirongqing@baidu.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-xfs@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <mawilcox@microsoft.com>, Souptick Joarder <jrdr.linux@gmail.com>, darrick.wong@oracle.com

On Mon, Aug 20, 2018 at 10:07:44AM -0700, Matthew Wilcox wrote:
> On Mon, Aug 20, 2018 at 06:24:06PM +0200, Michal Hocko wrote:
> > On Mon 20-08-18 07:49:23, Matthew Wilcox wrote:
> > > On Mon, Aug 20, 2018 at 04:41:16PM +0200, Michal Hocko wrote:
> > > > On Sat 18-08-18 20:49:01, Li RongQing wrote:
> > > > > The new helper returns address mapping page, which has several users
> > > > > in individual subsystem, like mem_to_page in xfs_buf.c and pgv_to_page
> > > > > in af_packet.c, unify them
> > > > 
> > > > kvvirt_to_page is a weird name. I guess you wanted it to fit into
> > > > kv*alloc, kvfree naming, right? If yes then I guess kvmem_to_page
> > > > would be slightly better.
> > > > 
> > > > Other than that the patch makes sense to me. It would be great to add
> > > > some documentation and be explicit that the call is only safe on
> > > > directly mapped kernel address and vmalloc areas.
> > > 
> > > ... and not safe if the length crosses a page boundary.  I don't want to
> > > see new code emerge that does kvmalloc(PAGE_SIZE * 2, ...); kvmem_to_page()
> > > and have it randomly crash when kvmalloc happens to fall back to vmalloc()
> > > under heavy memory pressure.
> > > 
> > > Also, people are going to start using this for stack addresses.  Perhaps
> > > we should have a debug option to guard against them doing that.
> > 
> > I do agree that such an interface is quite dangerous. That's why I was
> > stressing out the proper documentation. I would be much happier if we
> > could do without it altogether. Maybe the existing users can be rewoked
> > to not rely on the addr2page functionality. If that is not the case then
> > we should probably offer a helper. With some WARN_ONs to catch misuse
> > would be really nice. I am not really sure how many abuses can we catch
> > actually though.
> 
> I certainly understand the enthusiasm for sharing this code rather than
> having dozens of places outside the VM implement their own version of it.
> But I think most of these users are using code that's working at the wrong
> level.  Most of them seem to have an address range which may-or-may-not-be
> virtually mapped and they want to get an array-of-pages for that.
> 
> Perhaps we should offer -that- API instead.  vmalloc/vmap already has
> an array-of-pages, and the various users could be given a pointer to
> that array.  If the memory isn't vmapped, maybe the caller could pass
> an array pointer like XFS does, or we could require them to pass GFP flags
> to allocate a new array.

We have code in XFS to avoid allocating the array for the common
case - it ends up embedded in the struct xfs_buf instead and so we
avoid needing and extra alloc/free for every single buffer in the
fast path. Hence I'd prefer the interface lets the caller to supply
the result array, similar to the way callers provide their own
pagevecs for bulk page lookup functions...

Cheers,

Dave.

-- 
Dave Chinner
david@fromorbit.com
