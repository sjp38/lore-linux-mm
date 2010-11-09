Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6AC666B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 16:49:50 -0500 (EST)
Date: Tue, 9 Nov 2010 22:49:14 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 61 of 66] use compaction for GFP_ATOMIC order > 0
Message-ID: <20101109214914.GF6809@random.random>
References: <patchbomb.1288798055@v2.random>
 <b540c09bfe5160120952.1288798116@v2.random>
 <20101109151440.BC75.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101109151440.BC75.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 09, 2010 at 07:27:37PM +0900, KOSAKI Motohiro wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > This takes advantage of memory compaction to properly generate pages of order >
> > 0 if regular page reclaim fails and priority level becomes more severe and we
> > don't reach the proper watermarks.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> First, I don't think this patch is related to GFP_ATOMIC. So, I think the 
> patch title is a bit misleading.
> 
> Second, this patch has two changes. 1) remove PAGE_ALLOC_COSTLY_ORDER 
> threshold 2) implement background compaction. please separate them.

Well the subject isn't entirely misleading: background compaction in
kswapd is only for the GFP_ATOMIC so GFP_ATOMIC order >0 allocations
are definitely related to this patch.

Then I ended up then allowing compaction for all order of allocations
as it doesn't make sense to fail order 2 for the kernel stack and
succeed order 9 but it's true I can split that off, I will split it
for #33, thanks for allowing me to clean up the stuff better.

> Third, This patch makes a lot of PFN order page scan and churn LRU
> aggressively. I'm not sure this aggressive lru shuffling is safe and
> works effective. I hope you provide some demonstration and/or show 
> benchmark result.

The patch will increase the amount of compaction for GFP_ATOMIC order
>0, but it won't alter the amount of free pages in the system, but
it'll satisfy the in-function-of order watermarks that are right now
ignored. If user asked GFP_ATOMIC order > 0, this is what it asks,
it's up to the user not to ask for it if it's not worthwhile. If user
doesn't want this but it just wants to poll the LRU it should use
GFP_ATOMIC|__GFP_NO_KSWAPD.

The benchmark results I don't have at the moment but this has been
tested with tg3 with jumbo packets that trigger order 2 allocation and
no degradation was noticed. To be fair it didn't significantly improve
the amount of order 2 (9046 bytes large skb) allocated from irq
though, but I thought it was good idea to keep it in case there are
less aggressive/frequent users doing similar things.

Overall the more important part of the patch is the point 2) that I
can make it cleaner by splitting it off as you noticed and I will do
it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
