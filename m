Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id B4D986B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 19:09:54 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id k14so1477133wgh.26
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 16:09:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t5si22581272wja.153.2014.07.01.16.09.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 16:09:53 -0700 (PDT)
Date: Wed, 2 Jul 2014 00:09:49 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/5] Improve sequential read throughput v4r8
Message-ID: <20140701230949.GZ10819@suse.de>
References: <1404146883-21414-1-git-send-email-mgorman@suse.de>
 <20140701171611.GB1369@cmpxchg.org>
 <20140701183915.GW10819@suse.de>
 <20140701223817.GI4453@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140701223817.GI4453@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Wed, Jul 02, 2014 at 08:38:17AM +1000, Dave Chinner wrote:
> On Tue, Jul 01, 2014 at 07:39:15PM +0100, Mel Gorman wrote:
> > On Tue, Jul 01, 2014 at 01:16:11PM -0400, Johannes Weiner wrote:
> > > On Mon, Jun 30, 2014 at 05:47:59PM +0100, Mel Gorman wrote:
> > > Seqread throughput is up, randread takes a small hit.  But allocation
> > > latency is badly screwed at higher concurrency levels:
> > 
> > So the results are roughly similar. You don't state which filesystem it is
> > but FWIW if it's the ext3 filesystem using the ext4 driver then throughput
> > at higher levels is also affected by filesystem fragmentation. The problem
> > was outside the scope of the series.
> 
> I'd suggest you're both going wrong that the "using ext3" point.
> 
> Use ext4 or XFS for your performance measurements because that's
> what everyone is using for the systems these days. iNot to mention
> they don'thave all the crappy allocation artifacts that ext3 has,
> nor the throughput limitations caused by the ext3 journal, and so
> on.
> 
> Fundamentally, ext3 performance is simply not a relevant performance
> metric anymore - it's a legacy filesystem in maintenance mode and
> has been for a few years now...
> 

The problem crosses filesystems. ext3 is simply the first in the queue
because by and large it behaved the worst.  Covering the rest of them
simply takes more time and with different results as you may expect. Here
are the xfs results for the smaller of the machines as it was able to get
that far before it got reset

                                      3.16.0-rc2                 3.0.0            3.16.0-rc2
                                         vanilla               vanilla           fairzone-v4
Min    SeqRead-MB/sec-1          92.69 (  0.00%)       99.68 (  7.54%)      104.47 ( 12.71%)
Min    SeqRead-MB/sec-2         106.81 (  0.00%)      123.43 ( 15.56%)      123.24 ( 15.38%)
Min    SeqRead-MB/sec-4         101.89 (  0.00%)      113.78 ( 11.67%)      116.85 ( 14.68%)
Min    SeqRead-MB/sec-8          95.31 (  0.00%)       91.40 ( -4.10%)      101.68 (  6.68%)
Min    SeqRead-MB/sec-16         81.84 (  0.00%)       88.53 (  8.17%)       86.63 (  5.85%)

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
