Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 05CF46B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 00:38:39 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g186so336946835pgc.2
        for <linux-mm@kvack.org>; Sun, 27 Nov 2016 21:38:38 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id w31si25107958pla.3.2016.11.27.21.38.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Nov 2016 21:38:37 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id x23so12076799pgx.3
        for <linux-mm@kvack.org>; Sun, 27 Nov 2016 21:38:37 -0800 (PST)
Date: Mon, 28 Nov 2016 14:38:40 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v3 1/3] mm: support anonymous stable page
Message-ID: <20161128053840.GA547@jagdpanzerIV>
References: <1480062914-25556-1-git-send-email-minchan@kernel.org>
 <1480062914-25556-2-git-send-email-minchan@kernel.org>
 <20161127131910.GB4919@tigerII>
 <20161128004152.GA30427@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161128004152.GA30427@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Takashi Iwai <tiwai@suse.de>, Hyeoncheol Lee <cheol.lee@lge.com>, yjay.kim@lge.com, Sangseok Lee <sangseok.lee@lge.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, "Darrick J . Wong" <darrick.wong@oracle.com>, stable@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello,

On (11/28/16 09:41), Minchan Kim wrote:
> 
> I'm going on a long vacation so forgive if I respond slowly. :)

no prob. have a good one!


> On Sun, Nov 27, 2016 at 10:19:10PM +0900, Sergey Senozhatsky wrote:
[..]
> > wondering - how many pages can it hold? we are in low memory, that's why we
> > failed to zsmalloc in fast path, so how likely this to worsen memory pressure?
> 
> Actually, I don't have real number to say but a thing I can say surely is
> it's really hard to meet in normal stress test I have done until now.
> That's why it takes a long time to find(i.e., I could encounter the bug
> once two days). But once I understood the problem, I can reproduce the
> problem in 15 minutes.
> 
> About memory pressure, my testing was already severe memory pressure(i.e.,
> many memory failure and frequent OOM kill) so it doesn't make any
> meaningful difference before and after.
> 
> > just asking. in async zram the window between zram_rw_page() and actual
> > write of a page even bigger, isn't it?
> 
> Yes. That's why I found the problem with that feature enabled. Lucky. ;)

I see. just curious, the worst case is deflate compression (which
can be 8-9 slower than lz4) and sync zram. right? are we speaking
of megabytes here?

> > we *probably* and *may be* can try handle it in zram:
> > 
> > -- store the previous clen before re-compression
> > -- check if new clen > saved_clen and if it is - we can't use previously
> >    allocate handle and need to allocate a new one again. if it's less or
> >    equal than the saved one - store the object (wasting some space,
> >    yes. but we are in low mem).
> 
> It was my first attempt but changed mind.
> It can save against crash but broken data could go to the disk
> (i.e., zram). If someone want to read block directly(e.g.,
> open /dev/zram0; read /dev/zram or DIO), it cannot read the data
> forever until someone writes some stable data into that sectors.
> Instead, he will see many decompression failure message.
> It's weired.
>
> I believe stable page problem should be solved by generic layer,
> not driver itself.

yeah, I'm fine with this. at the same, there are chances, I suspect,
that may be we will see some 'regressions'. well, just may be.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
