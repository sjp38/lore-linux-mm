Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80ED36B0038
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 23:43:26 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j92so52653740ioi.2
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 20:43:26 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id x127si17291093iof.192.2016.11.21.20.43.25
        for <linux-mm@kvack.org>;
        Mon, 21 Nov 2016 20:43:25 -0800 (PST)
Date: Tue, 22 Nov 2016 13:43:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2] mm: support anonymous stable page
Message-ID: <20161122044322.GA2864@bbox>
References: <20161120233015.GA14113@bbox>
 <alpine.LSU.2.11.1611211932410.1085@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1611211932410.1085@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Darrick J . Wong" <darrick.wong@oracle.com>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Hugh,

On Mon, Nov 21, 2016 at 07:46:28PM -0800, Hugh Dickins wrote:
> On Mon, 21 Nov 2016, Minchan Kim wrote:
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Fri, 11 Nov 2016 15:02:57 +0900
> > Subject: [PATCH v2] mm: support anonymous stable page
> > 
> > For developemnt for zram-swap asynchronous writeback, I found
> > strange corruption of compressed page. With investigation, it
> > reveals currently stable page doesn't support anonymous page.
> > IOW, reuse_swap_page can reuse the page without waiting
> > writeback completion so that it can corrupt data during
> > zram compression. It can affect every swap device which supports
> > asynchronous writeback and CRC checking as well as zRAM.
> > 
> > Unfortunately, reuse_swap_page should be atomic so that we
> > cannot wait on writeback in there so the approach in this patch
> > is simply return false if we found it needs stable page.
> > Although it increases memory footprint temporarily, it happens
> > rarely and it should be reclaimed easily althoug it happened.
> > Also, It would be better than waiting of IO completion, which
> > is critial path for application latency.
> > 
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Darrick J. Wong <darrick.wong@oracle.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> Acked-by: Hugh Dickins <hughd@google.com>

Thanks!

> 
> Looks good, thanks: we can always optimize away that little overhead
> in the PageWriteback case, if it ever shows up in someone's testing.

Yeb.

> 
> Andrew might ask if we should Cc stable (haha): I think we agree
> that it's a defect we've been aware of ever since stable pages were
> first proposed, but nobody has actually been troubled by it before
> your async zram development: so, you're right to be fixing it ahead
> of your zram changes, but we don't see a call for backporting.

I thought so until I see your comment. However, I checked again
and found it seems a ancient bug since zram birth.
swap_writepage unlock the page right before submitting bio while
it keeps the lock during rw_page operation during bdev_write_page.
So, if zram_rw_page fails(e.g, -ENOMEM) and then fallback to
submit_bio in __swap_writepage, the problem can occur.

Hmm, I will resend patchset with zram fix part with marking
the stable.

Thanks, Hugh!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
