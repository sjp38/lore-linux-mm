Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A87136B01F5
	for <linux-mm@kvack.org>; Fri, 16 Apr 2010 13:52:01 -0400 (EDT)
Date: Fri, 16 Apr 2010 19:51:26 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Interleave policy on 2M pages (was Re: [RFC][BUGFIX][PATCH
 1/2] memcg: fix charge bypass route of migration)
Message-ID: <20100416175126.GP32034@random.random>
References: <20100413134207.f12cdc9c.nishimura@mxp.nes.nec.co.jp>
 <20100415120516.3891ce46.kamezawa.hiroyu@jp.fujitsu.com>
 <20100415154324.834dace9.nishimura@mxp.nes.nec.co.jp>
 <20100415155611.da707913.kamezawa.hiroyu@jp.fujitsu.com>
 <20100415081743.GP32034@random.random>
 <alpine.DEB.2.00.1004161111380.7710@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1004161111380.7710@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2010 at 11:13:10AM -0500, Christoph Lameter wrote:
> On Thu, 15 Apr 2010, Andrea Arcangeli wrote:
> 
> > 2) add alloc_pages_vma for numa awareness in the huge page faults
> 
> How do interleave policies work with alloc_pages_vma? So far the semantics
> is to spread 4k pages over different nodes. With 2M pages this can no
> longer work the way is was.

static struct page *alloc_page_interleave(gfp_t gfp, unsigned order,
       	      	   				     unsigned nid)

See the order parameter, so I hope it's already solved. I assume the
idea would be to interleave 2M pages to avoid the CPU the memory
overhead of the pte layer and to decrease the tlb misses, but still
maxing out the bandwidth of the system when multiple threads accesses
memory that is stored in different nodes with random access. It should
be ideal for hugetlbfs too for the large shared memory pools of the
DB. Surely it'll be better than having all hugepages from the same
node despite MPOL_INTERLEAVE is set.

Said that, it'd also be possible to disable hugepages if the vma has
MPOL_INTERLEAVE set, but I doubt we want to do that by default. Maybe
we can add a sysfs control later for that which can be further tweaked
at boot time by per-arch quirks, dunno... It's really up to you, you
know numa better, but I've no doubt that MPOL_INTERLEAVE also can make
sense with hugepages (both hugetlbfs and transparent hugepage
support).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
