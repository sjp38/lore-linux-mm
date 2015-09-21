Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0816A6B0038
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 17:11:02 -0400 (EDT)
Received: by wicgb1 with SMTP id gb1so133013434wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 14:11:01 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id n4si19940780wia.64.2015.09.21.14.11.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 14:11:00 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so165797556wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 14:11:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150921041837.GF27729@bbox>
References: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
	<20150917013007.GB421@swordfish>
	<CAMJBoFP5LfoKwzDbSJMmOVOfq=8-7AaoAOV5TVPNt-JcUvZ0eA@mail.gmail.com>
	<20150921041837.GF27729@bbox>
Date: Mon, 21 Sep 2015 23:11:00 +0200
Message-ID: <CAMJBoFN0KocBQLSMJkxYS2JS+jSPR3Y5gGdceoKTYJWbm06t1g@mail.gmail.com>
Subject: Re: [PATCH 0/2] prepare zbud to be used by zram as underlying allocator
From: Vitaly Wool <vitalywool@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Hello Minchan,

> Sorry, because you wrote up "zram" in the title.
> As I said earlier, we need several numbers to investigate.
>
> First of all, what is culprit of your latency?
> It seems you are thinking about compaction. so compaction what?
> Frequent scanning? lock collision? or frequent sleeping in compaction
> code somewhere? And then why does zbud solve it? If we use zbud for zram,
> we lose memory efficiency so there is something to justify it.

The data I've got so far strongly suggests that in some use cases (see
below) with zsmalloc
* there are more allocstalls
* memory compaction is triggered more frequently
* allocstalls happen more often
* page migrations are way more frequent, too.

Please also keep in mind that I do not advise you or anyone to use
zbud instead of zsmalloc. The point I'm trying to make is that zbud
fits my particular case better and I want to be able to choose it in
the kernel without hacking it with my private patches.
FWIW, given that I am not an author of either, I don't see why anyone
would consider me biased. :-)

As of the memory efficiency, you seem to be quite comfortable with
storing uncompressed pages when they compress to more than 3/4 of a
page. I observed ~13% reported ratio increase (3.8x to 4.3x) when I
increased max_zpage_size to PAGE_SIZE / 32 * 31. Doesn't look like a
fight for every byte to me.

> The reason I am asking is I have investigated similar problems
> in android and other plaforms and the reason of latency was not zsmalloc
> but agressive high-order allocations from subsystems, watermark check
> race, deferring of compaction, LMK not working and too much swapout so
> it causes to reclaim lots of page cache pages which was main culprit
> in my cases. When I checks with perf, compaction stall count is increased,
> the time spent in there is not huge so it was not main factor of latency.

The main use case where the difference is seen is switching between
users on an Android device. It does cause a lot of reclaim, too, as
you say, but this is in the nature of zbud that reclaim happens in a
more deterministic way and worst-case looks substantially nicer. That
said, the standard deviation calculated over 20 iterations of a
change-user-multiple-times-test is 2x less for zbud than the one of
zsmalloc.

I'll post some numbers in the next patch respin so they won't get lost :)

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
