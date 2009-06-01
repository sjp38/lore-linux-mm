Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A2A686B005A
	for <linux-mm@kvack.org>; Sun, 31 May 2009 22:37:47 -0400 (EDT)
Date: Mon, 1 Jun 2009 10:37:58 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] readahead:add blk_run_backing_dev
Message-ID: <20090601023758.GA8795@localhost>
References: <6.0.0.20.2.20090522102551.0705aea0@172.19.0.2> <20090522023323.GA10864@localhost> <20090526164252.0741b392.akpm@linux-foundation.org> <6.0.0.20.2.20090527092105.076be238@172.19.0.2> <20090527020909.GB17658@localhost> <6.0.0.20.2.20090527110937.0770c420@172.19.0.2> <20090527023638.GA27079@localhost> <6.0.0.20.2.20090527114200.076aab00@172.19.0.2> <20090527025721.GA11153@localhost> <6.0.0.20.2.20090527120248.076abe38@172.19.0.2>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <6.0.0.20.2.20090527120248.076abe38@172.19.0.2>
Sender: owner-linux-mm@kvack.org
To: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jens.axboe@oracle.com" <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 27, 2009 at 11:06:37AM +0800, Hisashi Hifumi wrote:
> 
> At 11:57 09/05/27, Wu Fengguang wrote:
> >On Wed, May 27, 2009 at 10:47:47AM +0800, Hisashi Hifumi wrote:
> >> 
> >> At 11:36 09/05/27, Wu Fengguang wrote:
> >> >On Wed, May 27, 2009 at 10:21:53AM +0800, Hisashi Hifumi wrote:
> >> >>
> >> >> At 11:09 09/05/27, Wu Fengguang wrote:
> >> >> >On Wed, May 27, 2009 at 08:25:04AM +0800, Hisashi Hifumi wrote:
> >> >> >>
> >> >> >> At 08:42 09/05/27, Andrew Morton wrote:
> >> >> >> >On Fri, 22 May 2009 10:33:23 +0800
> >> >> >> >Wu Fengguang <fengguang.wu@intel.com> wrote:
> >> >> >> >
> >> >> >> >> > I tested above patch, and I got same performance number.
> >> >> >> >> > I wonder why if (PageUptodate(page)) check is there...
> >> >> >> >>
> >> >> >> >> Thanks!  This is an interesting micro timing behavior that
> >> >> >> >> demands some research work.  The above check is to confirm if it's
> >> >> >> >> the PageUptodate() case that makes the difference. So why that case
> >> >> >> >> happens so frequently so as to impact the performance? Will it also
> >> >> >> >> happen in NFS?
> >> >> >> >>
> >> >> >> >> The problem is readahead IO pipeline is not running smoothly, which is
> >> >> >> >> undesirable and not well understood for now.
> >> >> >> >
> >> >> >> >The patch causes a remarkably large performance increase.  A 9%
> >> >> >> >reduction in time for a linear read? I'd be surprised if the workload
> >> >> >>
> >> >> >> Hi Andrew.
> >> >> >> Yes, I tested this with dd.
> >> >> >>
> >> >> >> >even consumed 9% of a CPU, so where on earth has the kernel gone to?
> >> >> >> >
> >> >> >> >Have you been able to reproduce this in your testing?
> >> >> >>
> >> >> >> Yes, this test on my environment is reproducible.
> >> >> >
> >> >> >Hisashi, does your environment have some special configurations?
> >> >>
> >> >> Hi.
> >> >> My testing environment is as follows:
> >> >> Hardware: HP DL580
> >> >> CPU:Xeon 3.2GHz *4 HT enabled
> >> >> Memory:8GB
> >> >> Storage: Dothill SANNet2 FC (7Disks RAID-0 Array)
> >> >
> >> >This is a big hardware RAID. What's the readahead size?
> >> >
> >> >The numbers look too small for a 7 disk RAID:
> >> >
> >> >        > #dd if=testdir/testfile of=/dev/null bs=16384
> >> >        >
> >> >        > -2.6.30-rc6
> >> >        > 1048576+0 records in
> >> >        > 1048576+0 records out
> >> >        > 17179869184 bytes (17 GB) copied, 224.182 seconds, 76.6 MB/s
> >> >        >
> >> >        > -2.6.30-rc6-patched
> >> >        > 1048576+0 records in
> >> >        > 1048576+0 records out
> >> >        > 17179869184 bytes (17 GB) copied, 206.465 seconds, 83.2 MB/s
> >> >
> >> >I'd suggest you to configure the array properly before coming back to
> >> >measuring the impact of this patch.
> >> 
> >> 
> >> I created 16GB file to this disk array, and mounted to testdir, dd to 
> >this directory.
> >
> >I mean, you should get >300MB/s throughput with 7 disks, and you
> >should seek ways to achieve that before testing out this patch :-)
> 
> Throughput number of storage array is very from one product to another.
> On my hardware environment I think this number is valid and
> my patch is effective.

What's your readahead size? Is it large enough to cover the stripe width?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
