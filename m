Date: Wed, 15 Oct 2008 23:06:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
Message-Id: <20081015230659.a717d0b6.akpm@linux-foundation.org>
In-Reply-To: <20081016143830.582C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081015162232.f673fa59.akpm@linux-foundation.org>
	<20081016102752.9886.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081016143830.582C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@saeurebad.de>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Oct 2008 15:01:01 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > > I have a note here that this patch needs better justification.  But the
> > > changelog looks good and there are pretty graphs, so maybe my note is stale.
> > > 
> > > Can people please check it?
> > > 
> > > Thanks.
> > 
> > maybe, I can run benchmark it.
> > please wait few hour.

Thanks, it really helps.

> 1. mesured various copy performance.
>    using copybench -> http://code.google.com/p/copybench/
> 
>    my machine mem:   8GB
>    target file size: 10GB (filesize > system mem)
> 
> 
>                          2.6.27    mmotm-1010:
>    ==============================================================
>    rw_cp                 6:13      6:11
>    rw_fadv_cp            6:09      6:06
>    mm_sync_cp            5:51      5:55
>    mm_sync_madv_cp       5:59      5:57
>    mw_cp                 5:50      5:50
>    mw_madv_cp            5:55      5:55
> 
> 
>    So, no improvement, but no regression.
> 
> 
> 2. Latency degression ratio of Sequential copy v.s. Other I/O situation
> 
> 	run following script (mm_sync_madv_cp is one of copybench program)
> 
> 	$ dbench -D /disk2/ -c client.txt 100 &
> 	$ sleep 100
> 	$ time ./mm_sync_madv_cp src dst
> 
> 
>                          2.6.27    mmotm-1010
>    ==============================================================
>    mm_sync_madv_cp       6:14      6:02         (min:sec)
>    dbench throughput     12.1507   14.6273      (MB/s)
>    dbench latency        33046     21779        (ms)
> 
> 
>    So, throughput improvement is relativily a bit, but latency improvement is much.
>    Then, I think the patch can improve "larege file copy (e.g. backup operation)
>    attacks desktop latency" problem.
> 
> Any comments?
> 

Sounds good.

But how do we know that it was this particular patch which improved the
latency performance?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
