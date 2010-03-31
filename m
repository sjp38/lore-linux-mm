Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id ACB816B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 11:34:41 -0400 (EDT)
Date: Wed, 31 Mar 2010 17:33:39 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #16
Message-ID: <20100331153339.GK5825@random.random>
References: <patchbomb.1269887833@v2.random>
 <20100331141035.523c9285.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100331141035.523c9285.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 31, 2010 at 02:10:35PM +0900, KAMEZAWA Hiroyuki wrote:
> Hmm, recently, I noticed that x86-64 has hugepage_size == pmd_size but we can't
> assume that in generic. I know your code depends on x86-64 by CONFIG.
> Can this implementation be enhanced for various hugepage in generic archs ?
> I doubt based-on-pmd approach will get sucess in generic archs..
> 
> I'm sorry if you answered someone already.

The generic archs without pmd approach can't mix hugepages and regular
pages in the same vma, so they can't provide graceful fallback and
never fail an allocation despite there is pleny of memory free which
is one critical fundamental point in the design (and later collapse
those with khugepaged which also can run memory compaction
asynchronously in the background and not synchronously during page
fault which would be entirely worthless for short lived allocations).

Until they can mix pages of different size in the same vma they should
stick to hugetlbfs anyway so it's futile to worry about those. If
there's some that can mix pages of different size in the same vma, and
that can't work with this model, I'd be interested to know (not that I
plan many changes but still it'd be interesting to evaluate it).

About the HPAGE_PMD_ prefix it's not only HPAGE_ like I did initially,
in case we later decide to split/collapse 1G pages too but frankly I
think by the time memory size doubles 512 times across the board (to
make 1G pages a not totally wasted effort to implement in the
transparent hugepage support) we'd better move the PAGE_SIZE to 2M and
stick to the HPAGE_PMD_ again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
