Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6B1E86B005D
	for <linux-mm@kvack.org>; Tue, 19 May 2009 22:50:51 -0400 (EDT)
Date: Wed, 20 May 2009 10:51:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] readahead:add blk_run_backing_dev
Message-ID: <20090520025123.GB8186@localhost>
References: <6.0.0.20.2.20090518183752.0581fdc0@172.19.0.2> <20090518175259.GL4140@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090518175259.GL4140@kernel.dk>
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 18, 2009 at 07:53:00PM +0200, Jens Axboe wrote:
> On Mon, May 18 2009, Hisashi Hifumi wrote:
> > Hi.
> > 
> > I wrote a patch that adds blk_run_backing_dev on page_cache_async_readahead
> > so readahead I/O is unpluged to improve throughput.
> > 
> > Following is the test result with dd.
> > 
> > #dd if=testdir/testfile of=/dev/null bs=16384
> > 
> > -2.6.30-rc6
> > 1048576+0 records in
> > 1048576+0 records out
> > 17179869184 bytes (17 GB) copied, 224.182 seconds, 76.6 MB/s
> > 
> > -2.6.30-rc6-patched
> > 1048576+0 records in
> > 1048576+0 records out
> > 17179869184 bytes (17 GB) copied, 206.465 seconds, 83.2 MB/s
> > 
> > Sequential read performance on a big file was improved.
> > Please merge my patch.
> > 
> > Thanks.
> > 
> > Signed-off-by: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
> > 
> > diff -Nrup linux-2.6.30-rc6.org/mm/readahead.c linux-2.6.30-rc6.unplug/mm/readahead.c
> > --- linux-2.6.30-rc6.org/mm/readahead.c	2009-05-18 10:46:15.000000000 +0900
> > +++ linux-2.6.30-rc6.unplug/mm/readahead.c	2009-05-18 13:00:42.000000000 +0900
> > @@ -490,5 +490,7 @@ page_cache_async_readahead(struct addres
> >  
> >  	/* do read-ahead */
> >  	ondemand_readahead(mapping, ra, filp, true, offset, req_size);
> > +
> > +	blk_run_backing_dev(mapping->backing_dev_info, NULL);
> >  }
> >  EXPORT_SYMBOL_GPL(page_cache_async_readahead);
> 
> I'm surprised this makes much of a difference. It seems correct to me to
> NOT unplug the device, since it will get unplugged when someone ends up
> actually waiting for a page. And that will then kick off the remaining
> IO as well. For this dd case, you'll be hitting lock_page() for the
> readahead page really soon, definitely not long enough to warrant such a
> big difference in speed.

The possible timing change of this patch is (assuming readahead size=100):

T0   read(100), which triggers readahead(200, 100)
T1   read(101)
T2   read(102)
...
T100 read(200), find_get_page(200) => readahead(300, 100)
                lock_page(200) => implicit unplug

The readahead(200, 100) submitted at time T0 *might* be delayed to the
unplug time of T100.

But that is only a possibility. In normal cases, the read(200) would
be blocking and there will be a lock_page(200) that will immediately
unplug device for readahead(300, 100).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
