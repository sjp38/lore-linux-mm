Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4AE846B01E3
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 13:22:24 -0400 (EDT)
Date: Tue, 6 Apr 2010 18:43:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100406164319.GY5825@random.random>
References: <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com>
 <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org>
 <20100405232115.GM5825@random.random>
 <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
 <20100406011345.GT5825@random.random>
 <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org>
 <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org>
 <4BBB052D.8040307@redhat.com>
 <4BBB2134.9090301@redhat.com>
 <20100406131024.GA5288@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100406131024.GA5288@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Tue, Apr 06, 2010 at 11:10:24PM +1000, Nick Piggin wrote:
> most cases, quite possibly hardware improvements like asids will
> be more useful.

ASID already exists, they're not about preventing a vmexit for every
tlb flush or alternatively guest pagetable updates.

In short NPT/EPT is to ASID are what x86-64 is to PAE, not the other
way around. It simplifies things and speedup server workloads
tremendously. ASID if you want it, then you've to put it in OS guest
to manage or in regular linux on host regardless of virtualization on
or off.

Anyway hugetlbfs exists in linux way before virtualization ever
exited, so I guess we should keep the virtualization talk aside for
now to make everyone happy, I already once said in this thread this
whole work has been done in a way not specific to virtualization, and
let's focus on applications that have larger working set than
gcc/vi/make/git and somebody should explain why exactly hugetlbfs is
included in the 2.6.34 kernel if tlb miss cost doesn't matter, and why
so much work keeps going in the hugetlbfs direction including the 1g
page size and java runs on hugetlbfs, oracle runs on hugetlbfs,
etc... tons of apps are using libhugetlbfs and hugetlbfs is growing
like its own VM that eventually will be able to swap of its own.

> I don't really agree with how virtualization problem is characterised.
> Xen's way of doing memory virtualization maps directly to normal
> hardware page tables so there doesn't seem like a fundamental
> requirement for more memory accesses.

Xen also takes advantage of NPT/EPT, when it does it sure has the same
hardware runtime cost of KVM without hugepages, unless Xen or the
guest or both are using hugepages somewhere and trimming the pte level
from the shadow or guest pagetables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
