Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id B09FD6B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 20:31:01 -0400 (EDT)
Received: by pdrg1 with SMTP id g1so100578857pdr.2
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 17:31:01 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id br13si1892050pdb.19.2015.07.13.17.31.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jul 2015 17:31:00 -0700 (PDT)
Received: by pdbqm3 with SMTP id qm3so88679399pdb.0
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 17:31:00 -0700 (PDT)
Date: Tue, 14 Jul 2015 09:31:32 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 0/3] zsmalloc: small compaction improvements
Message-ID: <20150714003132.GA2463@swordfish>
References: <1436607932-7116-1-git-send-email-sergey.senozhatsky@gmail.com>
 <20150713233602.GA31822@blaptop.AC68U>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150713233602.GA31822@blaptop.AC68U>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

Hello Minchan,

On (07/14/15 08:36), Minchan Kim wrote:
[..]
> >       if [ `cat /sys/block/zram<id>/compact` -gt 10 ]; then
> >           echo 1 > /sys/block/zram<id>/compact;
> >       fi
> > 
> > Up until now user space could not tell whether compaction
> > will result in any gain.
> 
> First of all, thanks for the looking this.
> 
> Question:
> 
> What is motivation?
> IOW, did you see big overhead by user-triggered compaction? so,
> do you want to throttle it by userspace?

It depends on 'big overhead' definition, of course. We don't care
that much when compaction is issued by the shrinker, because things
are getting bad and we can sacrifice performance. But user triggered
compaction on a I/O pressured device can needlessly slow things down,
especially now, when we drain ALMOST_FULL classes.

/sys/block/zram<id>/compact is a black box. We provide it, we don't
throttle it in the kernel, and user space is absolutely clueless when
it invokes compaction. From some remote (or alternative) point of
view compaction can be seen as "zsmalloc's cache flush" (unused objects
make write path quicker - no zspage allocation needed) and it won't
hurt to give user space some numbers so it can decide if the whole
thing is worth it (that decision is, once again, I/O pattern and
setup specific -- some users may be interested in compaction only
if it will reduce zsmalloc's memory consumption by, say, 15%).

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
