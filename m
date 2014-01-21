Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id A88366B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 23:46:38 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id z6so622749yhz.13
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 20:46:38 -0800 (PST)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:7])
        by mx.google.com with ESMTP id v1si4087284yhg.149.2014.01.20.20.46.36
        for <linux-mm@kvack.org>;
        Mon, 20 Jan 2014 20:46:37 -0800 (PST)
Date: Tue, 21 Jan 2014 15:46:32 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Dirty deleted files cause pointless I/O storms (unless truncated
 first)
Message-ID: <20140121044632.GA25923@dastard>
References: <CALCETrVT29DULWg16_oKpGgSSBwZh-yWtygV1oYjH5iQH5jGyg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVT29DULWg16_oKpGgSSBwZh-yWtygV1oYjH5iQH5jGyg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>

On Mon, Jan 20, 2014 at 04:59:23PM -0800, Andy Lutomirski wrote:
> The code below runs quickly for a few iterations, and then it slows
> down and the whole system becomes laggy for far too long.
> 
> Removing the sync_file_range call results in no I/O being performed at
> all (which means that the kernel isn't totally screwing this up), and
> changing "4096" to SIZE causes lots of I/O but without
> the going-out-to-lunch bit (unsurprisingly).

More details please. hardware, storage, kernel version, etc.

I can't reproduce any slowdown with the code as posted on a VM
running 3.31-rc5 with 16GB RAM and an SSD w/ ext4 or XFS. The
workload is only generating about 80 IOPS on ext4 so even a slow
spindle should be able handle this without problems...

> Surprisingly, uncommenting the ftruncate call seems to fix the
> problem.  This suggests that all the necessary infrastructure to avoid
> wasting time writing to deleted files is there but that it's not
> getting used.

Not surprising at all - if it's stuck in a writeback loop somewhere,
truncating the file will terminate writeback because it end up being
past EOF and so stops immediately...

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
