Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 868596B004D
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 18:34:18 -0400 (EDT)
Received: from spaceape12.eur.corp.google.com (spaceape12.eur.corp.google.com [172.28.16.146])
	by smtp-out.google.com with ESMTP id n6UMYFxn022891
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 23:34:16 +0100
Received: from wf-out-1314.google.com (wff28.prod.google.com [10.142.6.28])
	by spaceape12.eur.corp.google.com with ESMTP id n6UMYDC8019467
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 15:34:13 -0700
Received: by wf-out-1314.google.com with SMTP id 28so481414wff.12
        for <linux-mm@kvack.org>; Thu, 30 Jul 2009 15:34:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090730221727.GI12579@kernel.dk>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
	 <20090730213956.GH12579@kernel.dk>
	 <33307c790907301501v4c605ea8oe57762b21d414445@mail.gmail.com>
	 <20090730221727.GI12579@kernel.dk>
Date: Thu, 30 Jul 2009 15:34:12 -0700
Message-ID: <33307c790907301534v64c08f59o66fbdfbd3174ff5f@mail.gmail.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
From: Martin Bligh <mbligh@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Chad Talbott <ctalbott@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wfg@mail.ustc.edu.cn, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, sandeen@redhat.com
List-ID: <linux-mm.kvack.org>

> The test case above on a 4G machine is only generating 1G of dirty data.
> I ran the same test case on the 16G, resulting in only background
> writeout. The relevant bit here being that the background writeout
> finished quickly, writing at disk speed.
>
> I re-ran the same test, but using 300 100MB files instead. While the
> dd's are running, we are going at ~80MB/sec (this is disk speed, it's an
> x25-m). When the dd's are done, it continues doing 80MB/sec for 10
> seconds or so. Then the remainder (about 2G) is written in bursts at
> disk speeds, but with some time in between.

OK, I think the test case is sensitive to how many files you have - if
we punt them to the back of the list, and yet we still have 299 other
ones, it may well be able to keep the disk spinning despite the bug
I outlined.Try using 30 1GB files?

Though it doesn't seem to happen with just one dd streamer, and
I don't see why the bug doesn't trigger in that case either.

I believe the bugfix is correct independent of any bdi changes?

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
