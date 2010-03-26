Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 43D226B020D
	for <linux-mm@kvack.org>; Fri, 26 Mar 2010 15:55:43 -0400 (EDT)
Date: Fri, 26 Mar 2010 20:54:31 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 37 of 41] add x86 32bit support
Message-ID: <20100326195431.GG5825@random.random>
References: <patchbomb.1269622804@v2.random>
 <2a644b64b34162f323c5.1269622841@v2.random>
 <20100326175406.GA28898@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100326175406.GA28898@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 26, 2010 at 06:54:06PM +0100, Johannes Weiner wrote:
> Oh, shoot, the cast needs to be renamed to (union split_pmd *) as well.

I only verified x86 builds without PAE, I fixed that bit now and
verified it gets past it. However it still doesn't build because
PG_compound_lock exceeds the 32bit page->flags (with zone and other
stuff). I don't immediately see PG_ bits to reuse, but I think
PageBuddy can be converted to page->_count = -1. For now the only way
to build PAE on x86 with hugepages enabled, it is to set
PAT=n. Considering that the only way to disable transparent hugepages is to
enable the embedded settings in the config, it isn't such great but
again I'm optimistic we can drop PG_buddy. PG_reclaim is very dubious
too but as long as we want to retain that functionality of trying to
free pages after swapout I/O completion immediately, there's no way to
keep functionality removing PG_reclaim. Others are similar...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
