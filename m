Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id C6EE66B0038
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 00:40:09 -0500 (EST)
Received: by pfdd184 with SMTP id d184so24197837pfd.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 21:40:09 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id 73si10175782pfp.17.2015.12.08.21.40.08
        for <linux-mm@kvack.org>;
        Tue, 08 Dec 2015 21:40:08 -0800 (PST)
Date: Wed, 9 Dec 2015 13:40:06 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC 0/3] reduce latency of direct async compaction
Message-ID: <20151209054006.GA13682@aaronlu.sh.intel.com>
References: <20151203113508.GA23780@aaronlu.sh.intel.com>
 <20151203115255.GA24773@aaronlu.sh.intel.com>
 <56618841.2080808@suse.cz>
 <20151207073523.GA27292@js1304-P5Q-DELUXE>
 <20151207085956.GA16783@aaronlu.sh.intel.com>
 <20151208004118.GA4325@js1304-P5Q-DELUXE>
 <20151208051439.GA20797@aaronlu.sh.intel.com>
 <20151208065116.GA6902@js1304-P5Q-DELUXE>
 <20151208085242.GA6801@aaronlu.sh.intel.com>
 <20151209003353.GA12417@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151209003353.GA12417@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>

On Wed, Dec 09, 2015 at 09:33:53AM +0900, Joonsoo Kim wrote:
> On Tue, Dec 08, 2015 at 04:52:42PM +0800, Aaron Lu wrote:
> > On Tue, Dec 08, 2015 at 03:51:16PM +0900, Joonsoo Kim wrote:
> > > I add work-around for this problem at isolate_freepages(). Please test
> > > following one.
> > 
> > Still no luck and the error is about the same:
> 
> There is a mistake... Could you insert () for
> cc->free_pfn & ~(pageblock_nr_pages-1) like as following?
> 
> cc->free_pfn == (cc->free_pfn & ~(pageblock_nr_pages-1))

Oh right, of course.

Good news, the result is much better now:
$ cat {0..8}/swap
cmdline: /lkp/aaron/src/bin/usemem 100064603136
100064603136 transferred in 72 seconds, throughput: 1325 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100072049664
100072049664 transferred in 74 seconds, throughput: 1289 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100070246400
100070246400 transferred in 92 seconds, throughput: 1037 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100069545984
100069545984 transferred in 81 seconds, throughput: 1178 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100058895360
100058895360 transferred in 78 seconds, throughput: 1223 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100066074624
100066074624 transferred in 94 seconds, throughput: 1015 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100062855168
100062855168 transferred in 77 seconds, throughput: 1239 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100060990464
100060990464 transferred in 73 seconds, throughput: 1307 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100064996352
100064996352 transferred in 84 seconds, throughput: 1136 MB/s
Max: 1325 MB/s
Min: 1015 MB/s
Avg: 1194 MB/s

The base result for reference:
$ cat {0..8}/swap
cmdline: /lkp/aaron/src/bin/usemem 100000622592
100000622592 transferred in 103 seconds, throughput: 925 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99999559680
99999559680 transferred in 92 seconds, throughput: 1036 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99996171264
99996171264 transferred in 92 seconds, throughput: 1036 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100005663744
100005663744 transferred in 150 seconds, throughput: 635 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100002966528
100002966528 transferred in 87 seconds, throughput: 1096 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99995784192
99995784192 transferred in 131 seconds, throughput: 727 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100003731456
100003731456 transferred in 97 seconds, throughput: 983 MB/s
cmdline: /lkp/aaron/src/bin/usemem 100006440960
100006440960 transferred in 109 seconds, throughput: 874 MB/s
cmdline: /lkp/aaron/src/bin/usemem 99998813184
99998813184 transferred in 122 seconds, throughput: 781 MB/s
Max: 1096 MB/s
Min: 635 MB/s
Avg: 899 MB/s

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
