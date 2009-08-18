Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 624A36B004D
	for <linux-mm@kvack.org>; Mon, 17 Aug 2009 22:26:05 -0400 (EDT)
Date: Tue, 18 Aug 2009 10:26:09 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090818022609.GA7958@localhost>
References: <4A843B72.6030204@redhat.com> <4A843EAE.6070200@redhat.com> <4A846581.2020304@redhat.com> <20090813211626.GA28274@cmpxchg.org> <4A850F4A.9020507@redhat.com> <20090814091055.GA29338@cmpxchg.org> <20090814095106.GA3345@localhost> <4A856467.6050102@redhat.com> <20090815054524.GB11387@localhost> <9EECC02A4CC333418C00A85D21E89326B6611E81@azsmsx502.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9EECC02A4CC333418C00A85D21E89326B6611E81@azsmsx502.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
To: "Dike, Jeffrey G" <jeffrey.g.dike@intel.com>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Avi Kivity <avi@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 18, 2009 at 02:04:46AM +0800, Dike, Jeffrey G wrote:
> > Jeff, can you confirm if the mem cgroup's inactive list is small?
> 
> Nope.  I have plenty on the inactive anon list, between 13K and 16K pages (i.e. 52M to 64M).
>
> The inactive mapped list is much smaller - 0 to ~700 pages.
> 
> The active lists are comparable in size, but larger - 16K - 19K pages for anon and 60 - 450 pages for mapped.

The anon inactive list is "over scanned".  Take 16k pages for example,
with DEF_PRIORITY=12, (16k >> 12) = 4.  So when shrink_zone() expects
to scan 4 pages in the active/inactive list, it will be scanned
SWAP_CLUSTER_MAX=32 pages in effect.

This triggers the background aging of active anon list because
inactive_anon_is_low() is found to be true, which keeps the
active:inactive ratio in balance.

So anon inactive list over scanned => anon active list over scanned =>
anon lists over scanned relative to file lists. (The inactive file list
may or may not be over scanned depending on its size <> (1<<prio) pages.)

Anyway this is not the expected way vmscan should work, and batching
up the cgroup vmscan could get rid of the mess.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
