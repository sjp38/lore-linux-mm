Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7932C6B004D
	for <linux-mm@kvack.org>; Sat, 15 Aug 2009 23:41:14 -0400 (EDT)
Date: Sun, 16 Aug 2009 11:28:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090816032822.GB6888@localhost>
References: <20090805024058.GA8886@localhost> <20090805155805.GC23385@random.random> <20090806100824.GO23385@random.random> <4A7AAE07.1010202@redhat.com> <20090806102057.GQ23385@random.random> <20090806105932.GA1569@localhost> <4A7AC201.4010202@redhat.com> <20090806130631.GB6162@localhost> <4A7AD79E.4020604@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A7AD79E.4020604@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 06, 2009 at 09:16:14PM +0800, Rik van Riel wrote:
> Wu Fengguang wrote:
> 
> > I guess both schemes have unacceptable flaws.
> > 
> > For JVM/BIGMEM workload, most pages would be found referenced _all the time_.
> > So the KEEP_MOST scheme could increase reclaim overheads by N=250 times;
> > while the DROP_CONTINUOUS scheme is effectively zero cost.
> 
> The higher overhead may not be an issue on smaller systems,
> or inside smaller cgroups inside large systems, when doing
> cgroup reclaim.

Right.

> > However, the DROP_CONTINUOUS scheme does bring more _indeterminacy_.
> > It can behave vastly different on single active task and multi ones.
> > It is short sighted and can be cheated by bursty activities.
> 
> The split LRU VM tries to avoid the bursty page aging as
> much as possible, by doing background deactivating of
> anonymous pages whenever we reclaim page cache pages and
> the number of anonymous pages in the zone (or cgroup) is
> low.

Right, but I meant busty page allocations and accesses on them, which
can make a large continuous segment of referenced pages in LRU list,
say 50MB.  They may or may not be valuable as a whole, however a local
algorithm may keep the first 4MB and drop the remaining 46MB.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
