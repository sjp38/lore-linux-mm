Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9G6MH9P016062
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Oct 2008 15:22:17 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 265282AC027
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:22:17 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (s8.gw.fujitsu.co.jp [10.0.50.98])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id F040112C044
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:22:16 +0900 (JST)
Received: from s8.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id D4FBF1DB8041
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:22:16 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s8.gw.fujitsu.co.jp (Postfix) with ESMTP id 856471DB8037
	for <linux-mm@kvack.org>; Thu, 16 Oct 2008 15:22:16 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
In-Reply-To: <20081015230659.a717d0b6.akpm@linux-foundation.org>
References: <20081016143830.582C.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081015230659.a717d0b6.akpm@linux-foundation.org>
Message-Id: <20081016151030.5832.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Oct 2008 15:22:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Johannes Weiner <hannes@saeurebad.de>
List-ID: <linux-mm.kvack.org>

> >                          2.6.27    mmotm-1010
> >    ==============================================================
> >    mm_sync_madv_cp       6:14      6:02         (min:sec)
> >    dbench throughput     12.1507   14.6273      (MB/s)
> >    dbench latency        33046     21779        (ms)
> > 
> > 
> >    So, throughput improvement is relativily a bit, but latency improvement is much.
> >    Then, I think the patch can improve "larege file copy (e.g. backup operation)
> >    attacks desktop latency" problem.
> > 
> > Any comments?
> > 
> 
> Sounds good.
> 
> But how do we know that it was this particular patch which improved the
> latency performance?

In my concern,

dbench's pages are touched multiple times, but copy's pages are touched only twice.
Then, on 2.6.27, copy's page transit to inactive -> active -> inactive -> free.
it decrease latency meaninglessly.

IOW, 2.6.27 model

1. shrink_inactive_lsit() promote copy's page to active (it touched twice (readahead + memcpy))
2. shrink_active_list() demote dbench's page
3. shrink_inactive_list() promote dbench's page (because it is touched multiple times)
4. shrink_active_list() demote copy's page
5. shrink_inactive_list() free copy's page


mmotm mode,

1, shrink_inactive_list() free copy's page.
2. end!



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
