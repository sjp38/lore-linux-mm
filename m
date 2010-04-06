Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 78FEC6B01EE
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 20:30:52 -0400 (EDT)
Date: Mon, 5 Apr 2010 17:26:15 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
In-Reply-To: <20100405232115.GM5825@random.random>
Message-ID: <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org>
References: <patchbomb.1270168887@v2.random> <20100405120906.0abe8e58.akpm@linux-foundation.org> <20100405193616.GA5125@elte.hu> <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com> <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org>
 <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com> <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org> <20100405232115.GM5825@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>



On Tue, 6 Apr 2010, Andrea Arcangeli wrote:
>
> Some performance result:

Quite frankly, these "performance results" seem to be basically dishonest.

Judging by your numbers, the big win is apparently pre-populating the page 
tables, the "tlb miss" you quote seem to be almost in the noise. IOW, we 
have 

	memset page fault 1566023

vs

	memset page fault 2182476

looking like a major performance advantage, but then the actual usage is 
much less noticeable.

IOW, how much of the performance advantage would we get from a _much_ 
simpler patch to just much more aggressively pre-populate the page tables 
(especially for just anonymous pages, I assume) or even just fault pages 
in several at a time when you have lots of memory?

In particular, when you quote 6% improvement for a kernel compile, your 
own numbers make seriously wonder how many percentage points you'd get 
from just faulting in 8 pages at a time when you have lots of memory free, 
and use a single 3-order allocation to get those eight pages?

Would that already shrink the difference between those "memset page 
faults" by a factor of eight?

See what I'm saying?  

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
