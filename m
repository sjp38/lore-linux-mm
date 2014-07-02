Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3106B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 11:44:46 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id m15so11484903wgh.9
        for <linux-mm@kvack.org>; Wed, 02 Jul 2014 08:44:45 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id fr9si15530189wib.79.2014.07.02.08.44.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 02 Jul 2014 08:44:45 -0700 (PDT)
Date: Wed, 2 Jul 2014 11:44:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/5] Improve sequential read throughput v4r8
Message-ID: <20140702154439.GE1369@cmpxchg.org>
References: <1404146883-21414-1-git-send-email-mgorman@suse.de>
 <20140701171611.GB1369@cmpxchg.org>
 <20140701183915.GW10819@suse.de>
 <20140701212538.GD1369@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140701212538.GD1369@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, Jul 01, 2014 at 05:25:38PM -0400, Johannes Weiner wrote:
> These explanations make no sense.  If pages of a streaming writer have
> enough time in memory to not thrash with a single zone, the fair
> policy should make even MORE time in memory available to them and not
> thrash them.  The fair policy is a necessity for multi-zone aging to
> make any sense and having predictable reclaim and activation behavior.
> That's why it's obviously not meant to benefit streaming workloads,
> but it shouldn't harm them, either.  Certainly not 20%.  If streaming
> pages thrash, something is up, the solution isn't to just disable the
> second zone or otherwise work around the issue.

Hey, funny story.

I tried reproducing this with an isolated tester just to be sure,
stealing tiobench's do_read_test(), but I wouldn't get any results.

I compared the original fair policy commit with its parent, I compared
a current vanilla kernel to a crude #ifdef'd policy disabling, and I
compared vanilla to your patch series - every kernel yields 132MB/s.

Then I realized, 132MB/s is the disk limit anyway - how the hell did I
get 150MB/s peak speeds for sequential cold cache IO with seqreadv4?

So I looked at the tiobench source code and it turns out, it's not
cold cache at all: it first does the write test, then the read test on
the same file!

The file is bigger than memory, so you would expect the last X percent
of the file to be cached after the seq write and the subsequent seq
read to push the tail out before getting to it - standard working set
bigger than memory behavior.

But without fairness, a chunk from the beginning of the file gets
stuck in the DMA32 zone and never pushed out while writing, so when
the reader comes along, it gets random parts from cache!

All patches that showed "major improvements" ruined fairness and led
to non-linear caching of the test file during the write, and the read
speedups came from the file being partially served from cache.

Sequential IO is fine.  This benchmark needs a whack over the head.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
