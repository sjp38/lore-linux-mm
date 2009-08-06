Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 02C3E6B005A
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 09:06:48 -0400 (EDT)
Date: Thu, 6 Aug 2009 21:06:31 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090806130631.GB6162@localhost>
References: <20090805024058.GA8886@localhost> <20090805155805.GC23385@random.random> <20090806100824.GO23385@random.random> <4A7AAE07.1010202@redhat.com> <20090806102057.GQ23385@random.random> <20090806105932.GA1569@localhost> <4A7AC201.4010202@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A7AC201.4010202@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 06, 2009 at 07:44:01PM +0800, Avi Kivity wrote:
> On 08/06/2009 01:59 PM, Wu Fengguang wrote:

scheme KEEP_MOST:

>> How about, for every N pages that you scan, evict at least 1 page,
>> regardless of young bit status?  That limits overscanning to a N:1
>> ratio.  With N=250 we'll spend at most 25 usec in order to locate one
>> page to evict.

scheme DROP_CONTINUOUS:

> > This is a quick hack to materialize the idea. It remembers roughly
> > the last 32*SWAP_CLUSTER_MAX=1024 active (mapped) pages scanned,
> > and if _all of them_ are referenced, then the referenced bit is
> > probably meaningless and should not be taken seriously.

> I don't think we should ignore the referenced bit. There could still be 
> a large batch of unreferenced pages later on that we should 
> preferentially swap. If we swap at least 1 page for every 250 scanned, 
> after 4K swaps we will have traversed 1M pages, enough to find them.

I guess both schemes have unacceptable flaws.

For JVM/BIGMEM workload, most pages would be found referenced _all the time_.
So the KEEP_MOST scheme could increase reclaim overheads by N=250 times;
while the DROP_CONTINUOUS scheme is effectively zero cost.

However, the DROP_CONTINUOUS scheme does bring more _indeterminacy_.
It can behave vastly different on single active task and multi ones.
It is short sighted and can be cheated by bursty activities.

> > As a refinement, the static variable 'recent_all_referenced' could be
> > moved to struct zone or made a per-cpu variable.
> 
> Definitely this should be made part of the zone structure, consider the 
> original report where the problem occurs in a 128MB zone (where we can 
> expect many pages to have their referenced bit set).

Good point. Here the cgroup list is highly stressed, while the global
zones are idling.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
