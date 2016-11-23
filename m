Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EA5946B0069
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 02:41:08 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y68so6678753pfb.6
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 23:41:08 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id n23si32516380pfj.268.2016.11.22.23.41.07
        for <linux-mm@kvack.org>;
        Tue, 22 Nov 2016 23:41:08 -0800 (PST)
Date: Wed, 23 Nov 2016 16:41:05 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm: support anonymous stable page
Message-ID: <20161123074105.GA24600@bbox>
References: <20161120233015.GA14113@bbox>
 <alpine.LSU.2.11.1611211932410.1085@eggly.anvils>
 <20161122044322.GA2864@bbox>
 <alpine.LSU.2.11.1611222031480.1871@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1611222031480.1871@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Darrick J . Wong" <darrick.wong@oracle.com>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hugh,

On Tue, Nov 22, 2016 at 08:43:54PM -0800, Hugh Dickins wrote:
> On Tue, 22 Nov 2016, Minchan Kim wrote:
> > On Mon, Nov 21, 2016 at 07:46:28PM -0800, Hugh Dickins wrote:
> > > 
> > > Andrew might ask if we should Cc stable (haha): I think we agree
> > > that it's a defect we've been aware of ever since stable pages were
> > > first proposed, but nobody has actually been troubled by it before
> > > your async zram development: so, you're right to be fixing it ahead
> > > of your zram changes, but we don't see a call for backporting.
> > 
> > I thought so until I see your comment. However, I checked again
> > and found it seems a ancient bug since zram birth.
> > swap_writepage unlock the page right before submitting bio while
> > it keeps the lock during rw_page operation during bdev_write_page.
> > So, if zram_rw_page fails(e.g, -ENOMEM) and then fallback to
> > submit_bio in __swap_writepage, the problem can occur.
> 
> It's not clear to me why that matters.  If it drives zram mad
> to the point of crashing the kernel, yes, that would matter.  But
> if it just places incomprehensible or mis-CRCed data on the device,
> who cares?  The reused swap page is marked dirty, and nobody should
> be reading the stale data back off swap.  If you do resend with a
> stable tag, please make clear why it matters.

Your comment makes me think again. For old zram, it would be not a
problem. Thanks for the hint, Hugh!
However, it makes 4.7 kernel crash with per-cpu stream feature
introduced in zram to increase cache hit ratio.

The problem is it tries to compress page and then get compressed size.
With that size, it allocates buffer via zsmalloc but it could be
failed easily due to limited gfp_flag in per-cpu context so zram
retry to allocate buffer out of per-cpu context with more soft gfp
flag. If it get successfully, it retry to compress the page again
and copy the compressed data to the buffer allocated in advance.
During the operations, if the content is changed, it means
compressed size could be different so that buffer size allocated
in first trial is not vaild any more. It ends up buffer-overrun
so that zsmalloc free object chaining will be broken and go crash.
So, if we want to fix it really, it should go stable for v4.7,
at least.

Unfortunately, zram has reset feature which means zram shrink
the disksize to zero and then it should revalidate disk where
it will reset BDI_CAP_STABLE_WRITES. now zRAM cannot do it atomically
so someone can miss BDI_CAP_STABLE_WRITES of /dev/zram0.

I need to redesign the locking before supporting stable page of
zram so now I realize it's hard to reach stable tree, maybe.
I will think over with more time.

Thanks for always the helpful comment!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
