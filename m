Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 85B016B004D
	for <linux-mm@kvack.org>; Sat,  1 Aug 2009 01:03:27 -0400 (EDT)
Date: Sat, 1 Aug 2009 13:03:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
Message-ID: <20090801050354.GA16648@localhost>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com> <20090730213956.GH12579@kernel.dk> <33307c790907301501v4c605ea8oe57762b21d414445@mail.gmail.com> <20090730221727.GI12579@kernel.dk> <33307c790907301534v64c08f59o66fbdfbd3174ff5f@mail.gmail.com> <20090730224308.GJ12579@kernel.dk> <33307c790907301548t2ef1bb72k4adbe81865d2bde9@mail.gmail.com> <20090801040313.GB13291@localhost> <20090801045345.GA16011@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090801045345.GA16011@localhost>
Sender: owner-linux-mm@kvack.org
To: Martin Bligh <mbligh@google.com>
Cc: Jens Axboe <jens.axboe@oracle.com>, Chad Talbott <ctalbott@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Rubin <mrubin@google.com>, sandeen@redhat.com, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Sat, Aug 01, 2009 at 12:53:46PM +0800, Wu Fengguang wrote:
> On Sat, Aug 01, 2009 at 12:03:13PM +0800, Wu Fengguang wrote:

> I can see the growth when I increased the dd size to 2GB,
> and the dd throughput decreased from 82.5MB/s to 60.9MB/s.

The raw disk write throughput seems to be 60MB/s:

        wfg ~% dd if=/dev/zero of=/opt/vm/200M bs=1M count=200 oflag=direct
        200+0 records in
        200+0 records out
        209715200 bytes (210 MB) copied, 3.48137 s, 60.2 MB/s

read throughput is a bit better:

        wfg ~% dd of=/dev/null if=/opt/vm/200M bs=1M count=200 iflag=direct
        200+0 records in
        200+0 records out
        209715200 bytes (210 MB) copied, 2.66606 s, 78.7 MB/s

        # hdparm -tT /dev/hda

        /dev/hda:
         Timing cached reads:   10370 MB in  1.99 seconds = 5213.70 MB/sec
         Timing buffered disk reads:  216 MB in  3.03 seconds =  71.22 MB/sec

And sync writes are pretty slow:

        wfg ~% dd if=/dev/zero of=/opt/vm/200M bs=1M count=200 oflag=sync
        200+0 records in
        200+0 records out
        209715200 bytes (210 MB) copied, 10.4741 s, 20.0 MB/s

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
