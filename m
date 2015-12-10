Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1E182F7A
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 23:46:03 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id mv3so8285043igc.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 20:46:03 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTPS id s31si17512241ioe.98.2015.12.09.20.46.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 20:46:02 -0800 (PST)
Date: Thu, 10 Dec 2015 13:35:57 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC 0/3] reduce latency of direct async compaction
Message-ID: <20151210043556.GA19062@js1304-P5Q-DELUXE>
References: <20151203115255.GA24773@aaronlu.sh.intel.com>
 <56618841.2080808@suse.cz>
 <20151207073523.GA27292@js1304-P5Q-DELUXE>
 <20151207085956.GA16783@aaronlu.sh.intel.com>
 <20151208004118.GA4325@js1304-P5Q-DELUXE>
 <20151208051439.GA20797@aaronlu.sh.intel.com>
 <20151208065116.GA6902@js1304-P5Q-DELUXE>
 <20151208085242.GA6801@aaronlu.sh.intel.com>
 <20151209003353.GA12417@js1304-P5Q-DELUXE>
 <20151209054006.GA13682@aaronlu.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151209054006.GA13682@aaronlu.sh.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Lu <aaron.lu@intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

On Wed, Dec 09, 2015 at 01:40:06PM +0800, Aaron Lu wrote:
> On Wed, Dec 09, 2015 at 09:33:53AM +0900, Joonsoo Kim wrote:
> > On Tue, Dec 08, 2015 at 04:52:42PM +0800, Aaron Lu wrote:
> > > On Tue, Dec 08, 2015 at 03:51:16PM +0900, Joonsoo Kim wrote:
> > > > I add work-around for this problem at isolate_freepages(). Please test
> > > > following one.
> > > 
> > > Still no luck and the error is about the same:
> > 
> > There is a mistake... Could you insert () for
> > cc->free_pfn & ~(pageblock_nr_pages-1) like as following?
> > 
> > cc->free_pfn == (cc->free_pfn & ~(pageblock_nr_pages-1))
> 
> Oh right, of course.
> 
> Good news, the result is much better now:
> $ cat {0..8}/swap
> cmdline: /lkp/aaron/src/bin/usemem 100064603136
> 100064603136 transferred in 72 seconds, throughput: 1325 MB/s
> cmdline: /lkp/aaron/src/bin/usemem 100072049664
> 100072049664 transferred in 74 seconds, throughput: 1289 MB/s
> cmdline: /lkp/aaron/src/bin/usemem 100070246400
> 100070246400 transferred in 92 seconds, throughput: 1037 MB/s
> cmdline: /lkp/aaron/src/bin/usemem 100069545984
> 100069545984 transferred in 81 seconds, throughput: 1178 MB/s
> cmdline: /lkp/aaron/src/bin/usemem 100058895360
> 100058895360 transferred in 78 seconds, throughput: 1223 MB/s
> cmdline: /lkp/aaron/src/bin/usemem 100066074624
> 100066074624 transferred in 94 seconds, throughput: 1015 MB/s
> cmdline: /lkp/aaron/src/bin/usemem 100062855168
> 100062855168 transferred in 77 seconds, throughput: 1239 MB/s
> cmdline: /lkp/aaron/src/bin/usemem 100060990464
> 100060990464 transferred in 73 seconds, throughput: 1307 MB/s
> cmdline: /lkp/aaron/src/bin/usemem 100064996352
> 100064996352 transferred in 84 seconds, throughput: 1136 MB/s
> Max: 1325 MB/s
> Min: 1015 MB/s
> Avg: 1194 MB/s

Nice result! Thanks for testing.
I will make a proper formatted patch soon.

Then, your concern is solved? I think that performance of
always-always on this test case can't follow up performance of
always-never because migration cost to make hugepage is additionally
charged to always-always case. Instead, it will have more hugepage
mapping and it may result in better performance in some situation.
I guess that it is intention of that option.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
