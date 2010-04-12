Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8429D6B01EE
	for <linux-mm@kvack.org>; Mon, 12 Apr 2010 05:40:51 -0400 (EDT)
Date: Mon, 12 Apr 2010 11:39:52 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100412093952.GR5656@random.random>
References: <20100411104608.GA12828@elte.hu>
 <4BC1B2CA.8050208@redhat.com>
 <20100411120800.GC10952@elte.hu>
 <20100412060931.GP5683@laptop>
 <4BC2BF67.80903@redhat.com>
 <20100412071525.GR5683@laptop>
 <4BC2CF8C.5090108@redhat.com>
 <20100412082844.GU5683@laptop>
 <4BC2E1D6.9040702@redhat.com>
 <20100412092615.GY5683@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100412092615.GY5683@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Avi Kivity <avi@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mike Galbraith <efault@gmx.de>, Jason Garrett-Glaser <darkshikari@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, Apr 12, 2010 at 07:26:15PM +1000, Nick Piggin wrote:
> But if it is possible for KVM to use libhugetlb with just a bit of
> support from the kernel, then it goes some way to reducing the
> need for transparent hugepages.

KVM has full hugetlbfs support for a long time. There's some people
using it, and it remains a must-have for 1G pages, but it's not
manageable that way in the cloud. It's ok for a special instance
only. Right now all my VM by default are running on hugepages now
without changing a single bit (with a few liner patch to qemu to add a
alignment because the gfn bits in the number range
HPAGE_PMD_SHIFT..PAGE_SHIFT have to be a match to the host pfn bits
for NPT shadows to go pmd_huge). For qemu to run on hugepages not even
the alignment is needed (but it's better to align there too, to be
sure the guest kernel that lives hugepages as it's usually mapped in
the first mbyte).

This is the single change I had to apply to KVM for it to take
advantage of transparent hugepages because it was already working fine
with hugetlbfs:

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=commit;h=d249c189870896b3f275987b70702d2b8c7705d4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
