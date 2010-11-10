Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 32A436B0087
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 11:04:47 -0500 (EST)
Date: Wed, 10 Nov 2010 17:03:52 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 01 of 66] disable lumpy when compaction is enabled
Message-ID: <20101110160352.GJ6809@random.random>
References: <patchbomb.1288798055@v2.random>
 <ca2fea6527833aad8adc.1288798056@v2.random>
 <20101109121318.BC51.A69D9226@jp.fujitsu.com>
 <20101109213049.GC6809@random.random>
 <20101109213855.GM32723@csn.ul.ie>
 <20101109222240.GH6809@random.random>
 <20101110142704.GA19679@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101110142704.GA19679@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2010 at 02:27:04PM +0000, Mel Gorman wrote:
> Agreed. Any performance increase from THP is not likely to offset the
> cost of lumpy reclaim.

Exactly. Furthermore the improvement will still happen later by
polling compaction once every 10 sec with khugepaged (this is also
required in case some other guest or application quit releasing tons
of ram maybe natively order 9 in the buddy without requiring any
further compaction invocation).

What the default should be I don't know, but I like a default that
fails without causing swap storms. If you want the swap storms and to
drop all ptes regardless of their young bits, you should ask
explicitly for it I think. Anybody asking for high order allocation
and pretending to succeed despite the anti-frag and movable pageblocks
migrated with compaction aren't enough to succeed should be able to
handle a full graceful failure like THP does by design (or worst case
to return error to userland). As far as I can tell tg3 atomic order 2
allocation also provides for a graceful fallback for the same reason
(however in new mainline it floods the dmesg with tons of printk,
which it didn't used to with older kernels but it's not an actual
regression).

> Again agreed, I have no problem with lumpy reclaim being pushed aside.
> I'm just less keen on it being disabled altogether. I have high hopes
> for the series I'm working on that it can be extended slightly to suit
> the needs of THP.

Great. Well this is also why I disabled it with the smallest possible
modification, to avoid stepping on your toes.

> Nah, the first thing I did was eliminate being "my fault" :). It would
> have surprised me because the patches in isolation worked fine. It
> thought the inode changes might have had something to do with it so I
> was chasing blind alleys for a while. Hopefully d065bd81 will prove to
> be the real problem.

Well I wasn't sure if you tested it already on that very workload, the
patches weren't from you (even if you were in the signoffs). I
mentioned it just in case, glad it's not related :).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
