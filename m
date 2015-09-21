Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id EF8AC6B0253
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 00:17:10 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so104449426pad.3
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 21:17:10 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id al4si34737823pbd.110.2015.09.20.21.17.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Sep 2015 21:17:10 -0700 (PDT)
Received: by pacex6 with SMTP id ex6so104734815pac.0
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 21:17:09 -0700 (PDT)
Date: Mon, 21 Sep 2015 13:18:37 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/2] prepare zbud to be used by zram as underlying
 allocator
Message-ID: <20150921041837.GF27729@bbox>
References: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
 <20150917013007.GB421@swordfish>
 <CAMJBoFP5LfoKwzDbSJMmOVOfq=8-7AaoAOV5TVPNt-JcUvZ0eA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMJBoFP5LfoKwzDbSJMmOVOfq=8-7AaoAOV5TVPNt-JcUvZ0eA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hello Vitaly,

On Thu, Sep 17, 2015 at 12:26:12PM +0200, Vitaly Wool wrote:
> On Thu, Sep 17, 2015 at 1:30 AM, Sergey Senozhatsky
> <sergey.senozhatsky.work@gmail.com> wrote:
> 
> >
> > just a side note,
> > I'm afraid this is not how it works. numbers go first, to justify
> > the patch set.

I totally agree Sergey's opinion.

> >
> 
> These patches are extension/alignment patches, why would anyone need
> to justify that?

Sorry, because you wrote up "zram" in the title.
As I said earlier, we need several numbers to investigate.

First of all, what is culprit of your latency?
It seems you are thinking about compaction. so compaction what?
Frequent scanning? lock collision? or frequent sleeping in compaction
code somewhere? And then why does zbud solve it? If we use zbud for zram,
we lose memory efficiency so there is something to justify it.

The reason I am asking is I have investigated similar problems
in android and other plaforms and the reason of latency was not zsmalloc
but agressive high-order allocations from subsystems, watermark check
race, deferring of compaction, LMK not working and too much swapout so
it causes to reclaim lots of page cache pages which was main culprit
in my cases. When I checks with perf, compaction stall count is increased,
the time spent in there is not huge so it was not main factor of latency.

Your problem might be differnt with me so convincing us, you should
give us real data and investigation story.

Thanks.


> 
> But just to help you understand where I am coming from, here are some numbers:
>                                zsmalloc   zbud
> kswapd_low_wmark_hit_quickly   4513       5696
> kswapd_high_wmark_hit_quickly  861        902
> allocstall                     2236       1122
> pgmigrate_success              78229      31244
> compact_stall                  1172       634
> compact_fail                   194        95
> compact_success                464        210
> 
> These are results from an Android device having run 3 'monkey' tests
> each 20 minutes, with user switch to guest and back in between.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
