Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0C4D46B004D
	for <linux-mm@kvack.org>; Thu,  6 Aug 2009 07:38:56 -0400 (EDT)
Message-ID: <4A7AC201.4010202@redhat.com>
Date: Thu, 06 Aug 2009 14:44:01 +0300
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
References: <20090805024058.GA8886@localhost> <20090805155805.GC23385@random.random> <20090806100824.GO23385@random.random> <4A7AAE07.1010202@redhat.com> <20090806102057.GQ23385@random.random> <20090806105932.GA1569@localhost>
In-Reply-To: <20090806105932.GA1569@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 08/06/2009 01:59 PM, Wu Fengguang wrote:
>
> This is a quick hack to materialize the idea. It remembers roughly
> the last 32*SWAP_CLUSTER_MAX=1024 active (mapped) pages scanned,
> and if _all of them_ are referenced, then the referenced bit is
> probably meaningless and should not be taken seriously.
>
>    

I don't think we should ignore the referenced bit. There could still be 
a large batch of unreferenced pages later on that we should 
preferentially swap. If we swap at least 1 page for every 250 scanned, 
after 4K swaps we will have traversed 1M pages, enough to find them.

> As a refinement, the static variable 'recent_all_referenced' could be
> moved to struct zone or made a per-cpu variable.
>
>    

Definitely this should be made part of the zone structure, consider the 
original report where the problem occurs in a 128MB zone (where we can 
expect many pages to have their referenced bit set).

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
