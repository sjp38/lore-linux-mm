Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9G616n1007037
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Oct 2008 15:01:06 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E2512AC027
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:01:06 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DAF1B12C046
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:01:05 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id C5EB01DB8037
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:01:05 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 865321DB803A
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:01:05 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
In-Reply-To: <20081016102752.9886.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081015162232.f673fa59.akpm@linux-foundation.org> <20081016102752.9886.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081016143830.582C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Oct 2008 15:01:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Johannes Weiner <hannes@saeurebad.de>
List-ID: <linux-mm.kvack.org>

> > I have a note here that this patch needs better justification.  But the
> > changelog looks good and there are pretty graphs, so maybe my note is stale.
> > 
> > Can people please check it?
> > 
> > Thanks.
> 
> maybe, I can run benchmark it.
> please wait few hour.

1. mesured various copy performance.
   using copybench -> http://code.google.com/p/copybench/

   my machine mem:   8GB
   target file size: 10GB (filesize > system mem)


                         2.6.27    mmotm-1010:
   ==============================================================
   rw_cp                 6:13      6:11
   rw_fadv_cp            6:09      6:06
   mm_sync_cp            5:51      5:55
   mm_sync_madv_cp       5:59      5:57
   mw_cp                 5:50      5:50
   mw_madv_cp            5:55      5:55


   So, no improvement, but no regression.


2. Latency degression ratio of Sequential copy v.s. Other I/O situation

	run following script (mm_sync_madv_cp is one of copybench program)

	$ dbench -D /disk2/ -c client.txt 100 &
	$ sleep 100
	$ time ./mm_sync_madv_cp src dst


                         2.6.27    mmotm-1010
   ==============================================================
   mm_sync_madv_cp       6:14      6:02         (min:sec)
   dbench throughput     12.1507   14.6273      (MB/s)
   dbench latency        33046     21779        (ms)


   So, throughput improvement is relativily a bit, but latency improvement is much.
   Then, I think the patch can improve "larege file copy (e.g. backup operation)
   attacks desktop latency" problem.

Any comments?


Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
