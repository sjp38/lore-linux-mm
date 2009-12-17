Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0C1796B0062
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 03:40:56 -0500 (EST)
Date: Thu, 17 Dec 2009 09:40:46 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-ID: <20091217084046.GA9804@basil.fritz.box>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com> <20091216101107.GA15031@basil.fritz.box> <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com> <20091216102806.GC15031@basil.fritz.box> <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com> <1261004224.21028.500.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1261004224.21028.500.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, Dec 16, 2009 at 11:57:04PM +0100, Peter Zijlstra wrote:
> On Wed, 2009-12-16 at 19:31 +0900, KAMEZAWA Hiroyuki wrote:
> 
> > The problem of range locking is more than mmap_sem, anyway. I don't think
> > it's possible easily.
> 
> We already have a natural range lock in the form of the split pte lock.
> 
> If we make the vma lookup speculative using RCU, we can use the pte lock

One problem is here that mmap_sem currently contains sleeps
and RCU doesn't work for blocking operations until a custom
quiescent period is defined.

> to verify we got the right vma, because munmap requires the pte lock to
> complete the unmap.

Ok.

> 
> The fun bit is dealing with the fallout if we got it wrong, since we
> might then have instantiated page-tables not covered by a vma just to
> take the pte lock, it also requires we RCU free the page-tables iirc.

That makes sense.

> 
> There are a few interesting cases like stack extention and hugetlbfs,
> but I think we could start by falling back to mmap_sem locked behaviour
> if the speculative thing fails.

You mean fall back to mmap_sem if anything sleeps? Maybe. Would need
to check how many such points are really there.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
