Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7CDA36B004D
	for <linux-mm@kvack.org>; Fri, 26 Jun 2009 05:15:32 -0400 (EDT)
Subject: Re: [RFC][PATCH] mm: stop balance_dirty_pages doing too much work
From: Richard Kennedy <richard@rsk.demon.co.uk>
In-Reply-To: <20090625091033.GF31415@kernel.dk>
References: <1245839904.3210.85.camel@localhost.localdomain>
	 <20090624152732.d6352f4f.akpm@linux-foundation.org>
	 <1245916833.31755.78.camel@twins>  <20090625091033.GF31415@kernel.dk>
Content-Type: text/plain
Date: Fri, 26 Jun 2009 10:15:55 +0100
Message-Id: <1246007755.2692.15.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jens Axboe <jens.axboe@oracle.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2009-06-25 at 11:10 +0200, Jens Axboe wrote:
> On Thu, Jun 25 2009, Peter Zijlstra wrote:
> > On Wed, 2009-06-24 at 15:27 -0700, Andrew Morton wrote:
> > > On Wed, 24 Jun 2009 11:38:24 +0100
> > > Richard Kennedy <richard@rsk.demon.co.uk> wrote:
> > > 
> > > > When writing to 2 (or more) devices at the same time, stop
> > > > balance_dirty_pages moving dirty pages to writeback when it has reached
> > > > the bdi threshold. This prevents balance_dirty_pages overshooting its
> > > > limits and moving all dirty pages to writeback.     
> > > > 
> > > >     
> > > > Signed-off-by: Richard Kennedy <richard@rsk.demon.co.uk>
> > > > ---
> > 
> > Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> 
> After doing some integration and update work on the writeback branch, I
> threw 2.6.31-rc1, 2.6.31-rc1+patch, 2.6.31-rc1+writeback into the test
> mix. The writeback series include this patch as a prep patch. Results
> for the mmap write test case:
> 
> Kernel          Throughput      usr     sys     ctx     util
> --------------------------------------------------------------
> vanilla         184MB/sec       19.51%  50.49%  12995   82.88%
> vanilla         184MB/sec       19.60%  50.77%  12846   83.47%
> vanilla         182MB/sec       19.25%  51.18%  14692   82.76%
> vanilla+patch   169MB/sec       18.08%  43.61%   9507   76.38%
> vanilla+patch   170MB/sec       18.37%  43.46%  10275   76.62%
> vanilla+patch   165MB/sec       17.59%  42.06%  10165   74.39%
> writeback       215MB/sec       22.69%  53.23%   4085   92.32%
> writeback       214MB/sec       24.31%  52.90%   4495   92.40%
> writeback       208MB/sec       23.14%  52.12%   4067   91.68%
> 
> To be perfectly clear:
> 
> vanilla         2.6.31-rc1 stock
> vanilla+patch   2.6.31-rc1 + bdi_thresh patch
> writeback       2.6.31-rc1 + bdi_thresh patch + writeback series
> 
> This is just a single spindle w/ext4, nothing fancy. I'll do a 3-series
> run with the writeback and this patch backed out, to see if it makes a
> difference here. I didn't do that initially, since the results were in
> the range that I expected.

Intriguing numbers. It would tell us a lot if we could find out why
vanilla + patch is slower than vanilla. I'll run some tests using mmap
and see if I can find anything.
What block size are you using ?

I see that the last test of each group is the slowest. I wonder if this
is showing a slowdown over time or just noise? Any chance you could run
more tests in each group?

regards
Richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
