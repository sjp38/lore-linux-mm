Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 812656B0069
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 23:44:03 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so5026013pgq.7
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 20:44:03 -0800 (PST)
Received: from mail-pg0-x229.google.com (mail-pg0-x229.google.com. [2607:f8b0:400e:c05::229])
        by mx.google.com with ESMTPS id t61si3264732plb.276.2016.11.22.20.44.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 20:44:02 -0800 (PST)
Received: by mail-pg0-x229.google.com with SMTP id 3so1353792pgd.0
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 20:44:02 -0800 (PST)
Date: Tue, 22 Nov 2016 20:43:54 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2] mm: support anonymous stable page
In-Reply-To: <20161122044322.GA2864@bbox>
Message-ID: <alpine.LSU.2.11.1611222031480.1871@eggly.anvils>
References: <20161120233015.GA14113@bbox> <alpine.LSU.2.11.1611211932410.1085@eggly.anvils> <20161122044322.GA2864@bbox>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, "Darrick J . Wong" <darrick.wong@oracle.com>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 22 Nov 2016, Minchan Kim wrote:
> On Mon, Nov 21, 2016 at 07:46:28PM -0800, Hugh Dickins wrote:
> > 
> > Andrew might ask if we should Cc stable (haha): I think we agree
> > that it's a defect we've been aware of ever since stable pages were
> > first proposed, but nobody has actually been troubled by it before
> > your async zram development: so, you're right to be fixing it ahead
> > of your zram changes, but we don't see a call for backporting.
> 
> I thought so until I see your comment. However, I checked again
> and found it seems a ancient bug since zram birth.
> swap_writepage unlock the page right before submitting bio while
> it keeps the lock during rw_page operation during bdev_write_page.
> So, if zram_rw_page fails(e.g, -ENOMEM) and then fallback to
> submit_bio in __swap_writepage, the problem can occur.

It's not clear to me why that matters.  If it drives zram mad
to the point of crashing the kernel, yes, that would matter.  But
if it just places incomprehensible or mis-CRCed data on the device,
who cares?  The reused swap page is marked dirty, and nobody should
be reading the stale data back off swap.  If you do resend with a
stable tag, please make clear why it matters.

Hugh

> 
> Hmm, I will resend patchset with zram fix part with marking
> the stable.
> 
> Thanks, Hugh!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
