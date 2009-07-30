Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 55F156B005A
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 18:48:05 -0400 (EDT)
Received: from zps36.corp.google.com (zps36.corp.google.com [172.25.146.36])
	by smtp-out.google.com with ESMTP id n6UMm53U002390
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 23:48:06 +0100
Received: from wf-out-1314.google.com (wfc28.prod.google.com [10.142.3.28])
	by zps36.corp.google.com with ESMTP id n6UMm2Tn022691
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 15:48:02 -0700
Received: by wf-out-1314.google.com with SMTP id 28so461459wfc.18
        for <linux-mm@kvack.org>; Thu, 30 Jul 2009 15:48:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090730224308.GJ12579@kernel.dk>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
	 <20090730213956.GH12579@kernel.dk>
	 <33307c790907301501v4c605ea8oe57762b21d414445@mail.gmail.com>
	 <20090730221727.GI12579@kernel.dk>
	 <33307c790907301534v64c08f59o66fbdfbd3174ff5f@mail.gmail.com>
	 <20090730224308.GJ12579@kernel.dk>
Date: Thu, 30 Jul 2009 15:48:02 -0700
Message-ID: <33307c790907301548t2ef1bb72k4adbe81865d2bde9@mail.gmail.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
From: Martin Bligh <mbligh@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Chad Talbott <ctalbott@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wfg@mail.ustc.edu.cn, Michael Rubin <mrubin@google.com>, sandeen@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 30, 2009 at 3:43 PM, Jens Axboe<jens.axboe@oracle.com> wrote:
> On Thu, Jul 30 2009, Martin Bligh wrote:
>> > The test case above on a 4G machine is only generating 1G of dirty data.
>> > I ran the same test case on the 16G, resulting in only background
>> > writeout. The relevant bit here being that the background writeout
>> > finished quickly, writing at disk speed.
>> >
>> > I re-ran the same test, but using 300 100MB files instead. While the
>> > dd's are running, we are going at ~80MB/sec (this is disk speed, it's an
>> > x25-m). When the dd's are done, it continues doing 80MB/sec for 10
>> > seconds or so. Then the remainder (about 2G) is written in bursts at
>> > disk speeds, but with some time in between.
>>
>> OK, I think the test case is sensitive to how many files you have - if
>> we punt them to the back of the list, and yet we still have 299 other
>> ones, it may well be able to keep the disk spinning despite the bug
>> I outlined.Try using 30 1GB files?
>
> If this disk starts spinning, then we have bigger bugs :-)
>>
>> Though it doesn't seem to happen with just one dd streamer, and
>> I don't see why the bug doesn't trigger in that case either.
>>
>> I believe the bugfix is correct independent of any bdi changes?
>
> Yeah I think so too, I'll run some more tests on this tomorrow and
> verify it there as well.

There's another issue I was discussing with Peter Z. earlier that the
bdi changes might help with - if you look at where the dirty pages
get to, they are capped hard at the average of the dirty and
background thresholds, meaning we can only dirty about half the
pages we should be able to. That does very slowly go away when
the bdi limit catches up, but it seems to start at 0, and it's progess
seems glacially slow (at least if you're impatient ;-))

This seems to affect some of our workloads badly when they have
a sharp spike in dirty data to one device, they get throttled heavily
when they wouldn't have before the per-bdi dirty limits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
