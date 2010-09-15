Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1186B6B004A
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 09:43:01 -0400 (EDT)
Date: Wed, 15 Sep 2010 15:42:00 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: Transparent Hugepage Support #30
Message-ID: <20100915134200.GD5981@random.random>
References: <20100901190859.GA20316@random.random>
 <20100909104630.GO4443@balbir.in.ibm.com>
 <20100909234008.GS8925@random.random>
 <20100913093409.GF17950@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100913093409.GF17950@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

Hello,

On Mon, Sep 13, 2010 at 03:04:09PM +0530, Balbir Singh wrote:
> OK, when the code is touched next and from now on, we'll stop making
> that assumption.

Great, thanks!

> Thanks, is there an overhead of the compound_lock that will show up?

The compound lock is a per-page bit spinlock, so it'll surely scale
well, but surely there is a locked op overhead associated to it, but
it will only cost for hugepages, not normal pages.

Hugepages can't be collapsed in place, and they can only be collapsed
under the mmap_sem write mode (so holding the mmap sem in read or
write mode is enough to protect against it). The same can't be said
for the split of an hugepage, hugepages can be splitted under the mmap
sem just fine (the only way to protect against it is the compound_lock
or the anon_vma_lock, or yet another way to avoid the page to be
splitted under us is to local_irq_disable and then call
__get_user_pages_fast like futex.c does, it can't be splitted until
local_irq_enable is called, same guarantee as in gup_fast, the
pmd_splitting_flush_notify will wait, the tlb flush for the splitting
is really useless, it's just there to send an IPI and wait for any
gup_fast to finish). It's not entirely clear right now, what kind of
protection we need in memcg.

> Please do look at it, most of the churn is not controllable since it
> is bug fixes and feature enhancements for newer subsystems and
> performance. We'll try not to break anything fundamental.

Looking at it right now!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
