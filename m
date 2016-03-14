Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1836B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 03:40:38 -0400 (EDT)
Received: by mail-pf0-f169.google.com with SMTP id x3so37043580pfb.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:40:38 -0700 (PDT)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id 22si10040573pfq.57.2016.03.14.00.40.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 00:40:37 -0700 (PDT)
Received: by mail-pa0-x243.google.com with SMTP id fl4so14032608pad.2
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 00:40:37 -0700 (PDT)
Date: Mon, 14 Mar 2016 16:41:59 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH v3 1/5] mm/zsmalloc: introduce class auto-compaction
Message-ID: <20160314074159.GA542@swordfish>
References: <1457016363-11339-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1457016363-11339-2-git-send-email-sergey.senozhatsky@gmail.com>
 <20160314061759.GC10675@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160314061759.GC10675@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello Minchan,

On (03/14/16 15:17), Minchan Kim wrote:
[..]
> > demonstrates that class-896 has 12/26=46% of unused pages, class-2336 has
> > 1648/4932=33% of unused pages, etc. And the more classes we will have as
> > 'normal' classes (more than one object per-zspage) the bigger this problem
> > will grow. The existing compaction relies on a user space (user can trigger
> > compaction via `compact' zram's sysfs attr) or a shrinker; it does not
> > happen automatically.
> > 
> > This patch introduces a 'watermark' value of unused pages and schedules a
> > compaction work on a per-class basis once class's fragmentation becomes
> > too big. So compaction is not performed in current I/O operation context,
> > but in workqueue workers later.
> > 
> > The current watermark is set to 40% -- if class has 40+% of `freeable'
> > pages then compaction work will be scheduled.
> 
> Could you explain why you select per-class watermark?

yes,

we do less work this way - scan and compact only one class, instead
of locking and compacting all of them; which sounds reasonable.


> Because my plan was we kick background work based on total fragmented memory
> (i.e., considering used_pages/allocated_pages < some threshold).

if we know that a particular class B is fragmented and the rest of them
are just fine, then we can compact only that class B, skipping extra job.

> IOW, if used_pages/allocated_pages is less than some ratio,
> we kick background job with marking index of size class just freed
> and then the job scans size_class from the index circulary.
>
> As well, we should put a upper bound to scan zspages to make it
> deterministic.

you mean that __zs_compact() instead of just checking per-class
zs_can_compact() should check global pool ratio and bail out if
compaction of class Z has dropped the overall fragmentation ratio
below some watermark?

my logic was that
 -- suppose we have class A with fragmentation ratio 49% and class B
 with 8% of wasted pages, so the overall pool fragmentation is
 (50 + 10)/ 2 < 30%, while we still have almost 50% fragmented class.
 if the aim is to reduce the memory wastage then per-class watermarks
 seem to be more flexible.

> What do you think about it?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
