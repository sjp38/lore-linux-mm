Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6C1286B0093
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 12:39:17 -0500 (EST)
Date: Tue, 14 Dec 2010 18:38:17 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 36 of 66] memcg compound
Message-ID: <20101214173817.GH5638@random.random>
References: <patchbomb.1288798055@v2.random>
 <495ffee2d60adab4d18b.1288798091@v2.random>
 <20101118152628.GY8135@csn.ul.ie>
 <20101119101041.ffe00712.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101119101041.ffe00712.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

Hello Kame,

On Fri, Nov 19, 2010 at 10:10:41AM +0900, KAMEZAWA Hiroyuki wrote:
> If there are requirements of big page > 4GB, unsigned long should be used.

There aren't, it's unthinkable at the moment even 1G (besides it seems
on some implementations the CPU lacks a real 1G tlb and just prefetch
the same 2M tlb so making the tlb miss read one less cacheline but in
practice 1G don't seem to provide any measurable runtime compared to
2M THP). Things will always be exponential, the benefit provided going
from 4k to 2M will always be an order of magnitude bigger than the
benefit from 2M to 1G, no matter how much the hardware is handling the
1G pages natively.

> > >  	int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> > >  	struct mem_cgroup *mem = NULL;
> > >  	int ret;
> > > -	int csize = CHARGE_SIZE;
> > > +	int csize = max(CHARGE_SIZE, (unsigned long) page_size);
> > >  
> 
> unsigned long here.

This is to shut off a warning because CHARGE_SIZE is calculated as
multiple of PAGE_SIZE which is unsigned long. csize was already int
but unsigned long is not required. Like you point out it's not worth
batching even pages as small as 2G, so no need of unsigned long.

> > > @@ -2491,14 +2503,14 @@ __do_uncharge(struct mem_cgroup *mem, co
> > >  	if (batch->memcg != mem)
> > >  		goto direct_uncharge;
> > >  	/* remember freed charge and uncharge it later */
> > > -	batch->bytes += PAGE_SIZE;
> > > +	batch->bytes += page_size;
> 
> Hmm, isn't it simpler to avoid batched-uncharge when page_size > PAGE_SIZE ?

As you wish, so I'm changing it like this.

archs where the pmd is implemented purely in software might actually
be able to use page sizes smaller than 2M that may make sense to
batch, but for now if you think this is simpler I'll go for it. We
need simple.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2503,6 +2503,9 @@ __do_uncharge(struct mem_cgroup *mem, co
 	if (!batch->do_batch || test_thread_flag(TIF_MEMDIE))
 		goto direct_uncharge;
 
+	if (page_size != PAGE_SIZE)
+		goto direct_uncharge;
+
 	/*
 	 * In typical case, batch->memcg == mem. This means we can
 	 * merge a series of uncharges to an uncharge of res_counter.
@@ -2511,9 +2514,9 @@ __do_uncharge(struct mem_cgroup *mem, co
 	if (batch->memcg != mem)
 		goto direct_uncharge;
 	/* remember freed charge and uncharge it later */
-	batch->bytes += page_size;
+	batch->bytes += PAGE_SIZE;
 	if (uncharge_memsw)
-		batch->memsw_bytes += page_size;
+		batch->memsw_bytes += PAGE_SIZE;
 	return;
 direct_uncharge:
 	res_counter_uncharge(&mem->res, page_size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
