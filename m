Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j6R1VfkQ693530
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 21:31:41 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6R1VhuN188456
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 19:31:43 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j6R1Vfvt020784
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 19:31:41 -0600
Subject: Re: Memory pressure handling with iSCSI
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20050726173126.5368266b.akpm@osdl.org>
References: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726111110.6b9db241.akpm@osdl.org>
	 <1122403152.6433.39.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726114824.136d3dad.akpm@osdl.org>
	 <20050726121250.0ba7d744.akpm@osdl.org>
	 <1122412301.6433.54.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726142410.4ff2e56a.akpm@osdl.org>
	 <1122414300.6433.57.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726151003.6aa3aecb.akpm@osdl.org>
	 <1122418089.6433.62.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726160728.55245dae.akpm@osdl.org>
	 <1122420376.6433.68.camel@dyn9047017102.beaverton.ibm.com>
	 <20050726173126.5368266b.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 26 Jul 2005 18:31:28 -0700
Message-Id: <1122427889.6433.71.camel@dyn9047017102.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-07-26 at 17:31 -0700, Andrew Morton wrote:
> Badari Pulavarty <pbadari@us.ibm.com> wrote:
> >
> > On Tue, 2005-07-26 at 16:07 -0700, Andrew Morton wrote:
> >  > Badari Pulavarty <pbadari@us.ibm.com> wrote:
> >  > >
> >  > > Here is the data with 5 ext2 filesystems. I also collected /proc/meminfo
> >  > > every 5 seconds. As you can see, we seem to dirty 6GB of data in 20
> >  > > seconds of starting the test. I am not sure if its bad, since we have
> >  > > lots of free memory..
> >  > 
> >  > It's bad.  The logic in balance_dirty_pages() should block those write()
> >  > callers as soon as we hit 40% dirty memory or whatever is in
> >  > /proc/sys/vm/dirty_ratio.  So something is horridly busted.
> >  > 
> >  > Can you try reducing the number of filesystems even further?
> > 
> >  Single ext2 filesystem. We still dirty pretty quickly (data collected
> >  every 5 seconds).
> 
> It happens here, a bit.  My machine goes up to 60% dirty when it should be
> clamping at 40%.
> 
> The variable `total_pages' in page-writeback.c (from
> nr_free_pagecache_pages()) is too high.  I trace it back to here:
> 
> On node 0 totalpages: 1572864
>   DMA zone: 4096 pages, LIFO batch:1
>   Normal zone: 1568768 pages, LIFO batch:31
>   HighMem zone: 0 pages, LIFO batch:1
> 
> This machine only has 4G of memory, so the platform code is overestimating
> the number of pages by 50%.  Can you please check your dmesg, see if your
> system is also getting this wrong?



On node 0 totalpages: 1572863
  DMA zone: 4096 pages, LIFO batch:1
  Normal zone: 1568767 pages, LIFO batch:31
  HighMem zone: 0 pages, LIFO batch:1
On node 1 totalpages: 131071
  DMA zone: 0 pages, LIFO batch:1
  Normal zone: 131071 pages, LIFO batch:31
  HighMem zone: 0 pages, LIFO batch:1
On node 2 totalpages: 131071
  DMA zone: 0 pages, LIFO batch:1
  Normal zone: 131071 pages, LIFO batch:31
  HighMem zone: 0 pages, LIFO batch:1
On node 3 totalpages: 131071
  DMA zone: 0 pages, LIFO batch:1
  Normal zone: 131071 pages, LIFO batch:31
  HighMem zone: 0 pages, LIFO batch:1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
