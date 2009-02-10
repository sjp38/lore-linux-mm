Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7A1FE6B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 01:12:30 -0500 (EST)
Received: from toip7.srvr.bell.ca ([209.226.175.124])
          by tomts13-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20090210061228.GYZQ1559.tomts13-srv.bellnexxia.net@toip7.srvr.bell.ca>
          for <linux-mm@kvack.org>; Tue, 10 Feb 2009 01:12:28 -0500
Date: Tue, 10 Feb 2009 01:12:27 -0500
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH] mm fix page writeback accounting to fix oom condition
	under heavy I/O
Message-ID: <20090210061226.GA1918@Krystal>
References: <20090120122855.GF30821@kernel.dk> <20090120232748.GA10605@Krystal> <20090123220009.34DF.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090210033652.GA28435@Krystal> <alpine.LFD.2.00.0902092120450.3048@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0902092120450.3048@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jens Axboe <jens.axboe@oracle.com>, akpm@linux-foundation.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, thomas.pi@arcor.dea, Yuriy Lalym <ylalym@gmail.com>, ltt-dev@lists.casi.polymtl.ca, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Linus Torvalds (torvalds@linux-foundation.org) wrote:
> 
> 
> On Mon, 9 Feb 2009, Mathieu Desnoyers wrote:
> > 
> > So this patch fixes this behavior by only decrementing the page accounting
> > _after_ the block I/O writepage has been done.
> 
> This makes no sense, really.
> 
> Or rather, I don't mind the notion of updating the counters only after IO 
> per se, and _that_ part of it probably makes sense. But why is it that you 
> only then fix up two of the call-sites. There's a lot more call-sites than 
> that for this function. 
> 
> So if this really makes a big difference, that's an interesting starting 
> point for discussion, but I don't see how this particular patch could 
> possibly be the right thing to do.
> 

Yes, you are right. Looking in more details at /proc/meminfo under the
workload, I notice this :

MemTotal:       16028812 kB
MemFree:        13651440 kB
Buffers:            8944 kB
Cached:          2209456 kB   <--- increments up to ~16GB

        cached = global_page_state(NR_FILE_PAGES) -
                        total_swapcache_pages - i.bufferram;

SwapCached:            0 kB
Active:            34668 kB
Inactive:        2200668 kB   <--- also

                K(pages[LRU_INACTIVE_ANON] + pages[LRU_INACTIVE_FILE]),

Active(anon):      17136 kB
Inactive(anon):        0 kB
Active(file):      17532 kB
Inactive(file):  2200668 kB   <--- also

                K(pages[LRU_INACTIVE_FILE]),

Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:      19535024 kB
SwapFree:       19535024 kB
Dirty:           1159036 kB
Writeback:             0 kB  <--- stays close to 0
AnonPages:         17060 kB
Mapped:             9476 kB
Slab:              96188 kB
SReclaimable:      79776 kB
SUnreclaim:        16412 kB
PageTables:         3364 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    27549428 kB
Committed_AS:      54292 kB
VmallocTotal:   34359738367 kB
VmallocUsed:        9960 kB
VmallocChunk:   34359727667 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:        7552 kB
DirectMap2M:    16769024 kB

So I think simply substracting K(pages[LRU_INACTIVE_FILE]) from
avail_dirty in clip_bdi_dirty_limit() and to consider it in
balance_dirty_pages() and throttle_vm_writeout() would probably make my
problem go away, but I would like to understand exactly why this is
needed and if I would need to consider other types of page counts that
would have been forgotten.

Mathieu

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
