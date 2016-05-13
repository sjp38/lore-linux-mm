Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1736B025E
	for <linux-mm@kvack.org>; Fri, 13 May 2016 03:39:34 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 77so190902619pfz.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 00:39:34 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id p90si22984561pfa.74.2016.05.13.00.39.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 May 2016 00:39:33 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id g132so8715386pfb.3
        for <linux-mm@kvack.org>; Fri, 13 May 2016 00:39:33 -0700 (PDT)
Date: Fri, 13 May 2016 16:41:05 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: introduce per-device debug_stat sysfs node
Message-ID: <20160513074105.GD615@swordfish>
References: <20160511134553.12655-1-sergey.senozhatsky@gmail.com>
 <20160512234143.GA27204@bbox>
 <20160513010929.GA615@swordfish>
 <20160513062303.GA21204@bbox>
 <20160513065805.GB615@swordfish>
 <20160513070553.GC615@swordfish>
 <20160513072006.GA21484@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160513072006.GA21484@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (05/13/16 16:20), Minchan Kim wrote:
[..]
> > here I assume that the biggest contributor to re-compress latency is
> > enabled preemption after zcomp_strm_release() and this second zs_malloc().
> > the compression itself of a PAGE_SIZE buffer should be fast enough. so IOW
> > we would pass down the slow path, but would not account it.
> 
> biggest contributors are 1. direct reclaim by second zsmalloc call +
>                          2. recompression overhead.

			   3. enabled preemption after zcomp_strm_release()
			      we can be scheduled out for a long time.

> If zram start to support high comp ratio but slow speed algorithm like zlib
> 2 might be higher than 1 in the future so let's not ignore 2 overhead.

hm, yes, good point. not arguing, just for notice -- 2) has an upper limit
on its complexity, because we basically just do a number of arithmetical
operations on a buffer that has upper size limit -- PAGE_SIZE; while reclaim
in zsmalloc() can last an arbitrary amount of time. that's why I tend to
think of a PAGE_SIZE compression contribution as of constant, that can be
ignored.


> Although 2 is smaller, your patch just accounts only direct reclaim but my
> suggestion can count both 1 and 2 so isn't it better?
> 
> I don't know why it's arguable here. :)

no objections to put it next to goto. just making sure that we have
considered all the possibilities and cases.

will resend shortly, thanks!

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
