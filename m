Date: Wed, 15 Oct 2008 23:31:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
Message-Id: <20081015233126.27885bb9.akpm@linux-foundation.org>
In-Reply-To: <20081016151030.5832.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081016143830.582C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20081015230659.a717d0b6.akpm@linux-foundation.org>
	<20081016151030.5832.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@saeurebad.de>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Oct 2008 15:22:15 +0900 (JST) KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> > >                          2.6.27    mmotm-1010
> > >    ==============================================================
> > >    mm_sync_madv_cp       6:14      6:02         (min:sec)
> > >    dbench throughput     12.1507   14.6273      (MB/s)
> > >    dbench latency        33046     21779        (ms)
> > > 
> > > 
> > >    So, throughput improvement is relativily a bit, but latency improvement is much.
> > >    Then, I think the patch can improve "larege file copy (e.g. backup operation)
> > >    attacks desktop latency" problem.
> > > 
> > > Any comments?
> > > 
> > 
> > Sounds good.
> > 
> > But how do we know that it was this particular patch which improved the
> > latency performance?
> 
> In my concern,
> 
> dbench's pages are touched multiple times, but copy's pages are touched only twice.
> Then, on 2.6.27, copy's page transit to inactive -> active -> inactive -> free.
> it decrease latency meaninglessly.
> 
> IOW, 2.6.27 model
> 
> 1. shrink_inactive_lsit() promote copy's page to active (it touched twice (readahead + memcpy))
> 2. shrink_active_list() demote dbench's page
> 3. shrink_inactive_list() promote dbench's page (because it is touched multiple times)
> 4. shrink_active_list() demote copy's page
> 5. shrink_inactive_list() free copy's page
> 
> 
> mmotm mode,
> 
> 1, shrink_inactive_list() free copy's page.
> 2. end!

OK.  But my concern is that perhaps the above latency improvement was
caused by one of the many other MM patches in mmotm.

Reverting mm-more-likely-reclaim-madv_sequential-mappings.patch from
mmotm and rerunning the tests would be the way to determine this. 
(hint :) - thanks).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
