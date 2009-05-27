Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9773A6B0055
	for <linux-mm@kvack.org>; Tue, 26 May 2009 22:42:11 -0400 (EDT)
Message-Id: <6.0.0.20.2.20090527113743.076aac48@172.19.0.2>
Date: Wed, 27 May 2009 11:38:08 +0900
From: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
Subject: Re: [PATCH] readahead:add blk_run_backing_dev
In-Reply-To: <20090526193601.b825af5f.akpm@linux-foundation.org>
References: <6.0.0.20.2.20090518183752.0581fdc0@172.19.0.2>
 <20090518175259.GL4140@kernel.dk>
 <20090520025123.GB8186@localhost>
 <6.0.0.20.2.20090521145005.06f81fe0@172.19.0.2>
 <20090522010538.GB6010@localhost>
 <6.0.0.20.2.20090522102551.0705aea0@172.19.0.2>
 <20090522023323.GA10864@localhost>
 <20090526164252.0741b392.akpm@linux-foundation.org>
 <6.0.0.20.2.20090527092105.076be238@172.19.0.2>
 <20090527020909.GB17658@localhost>
 <6.0.0.20.2.20090527110937.0770c420@172.19.0.2>
 <20090526193601.b825af5f.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "jens.axboe@oracle.com" <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>


At 11:36 09/05/27, Andrew Morton wrote:
>On Wed, 27 May 2009 11:21:53 +0900 Hisashi Hifumi 
><hifumi.hisashi@oss.ntt.co.jp> wrote:
>
>> 
>> At 11:09 09/05/27, Wu Fengguang wrote:
>> >On Wed, May 27, 2009 at 08:25:04AM +0800, Hisashi Hifumi wrote:
>> >> 
>> >> At 08:42 09/05/27, Andrew Morton wrote:
>> >> >On Fri, 22 May 2009 10:33:23 +0800
>> >> >Wu Fengguang <fengguang.wu@intel.com> wrote:
>> >> >
>> >> >> > I tested above patch, and I got same performance number.
>> >> >> > I wonder why if (PageUptodate(page)) check is there...
>> >> >> 
>> >> >> Thanks!  This is an interesting micro timing behavior that
>> >> >> demands some research work.  The above check is to confirm if it's
>> >> >> the PageUptodate() case that makes the difference. So why that case
>> >> >> happens so frequently so as to impact the performance? Will it also
>> >> >> happen in NFS?
>> >> >> 
>> >> >> The problem is readahead IO pipeline is not running smoothly, which is
>> >> >> undesirable and not well understood for now.
>> >> >
>> >> >The patch causes a remarkably large performance increase.  A 9%
>> >> >reduction in time for a linear read? I'd be surprised if the workload
>> >> 
>> >> Hi Andrew.
>> >> Yes, I tested this with dd.
>> >> 
>> >> >even consumed 9% of a CPU, so where on earth has the kernel gone to?
>> >> >
>> >> >Have you been able to reproduce this in your testing?
>> >> 
>> >> Yes, this test on my environment is reproducible.
>> >
>> >Hisashi, does your environment have some special configurations?
>> 
>> Hi.
>> My testing environment is as follows:
>> Hardware: HP DL580 
>> CPU:Xeon 3.2GHz *4 HT enabled
>> Memory:8GB
>> Storage: Dothill SANNet2 FC (7Disks RAID-0 Array)
>> 
>> I did dd to this disk-array and got improved performance number.
>> 
>> I noticed that when a disk is just one HDD, performance improvement
>> is very small.
>> 
>
>Ah.  So it's likely to be some strange interaction with the RAID setup.
>
>I assume that you're using the SANNet 2's "hardware raid"?  Or is the
>array set up as jbod and you're using kernel raid0?

I used SANNet 2's "hardware raid".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
