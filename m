Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 75AA76B0093
	for <linux-mm@kvack.org>; Thu, 17 Dec 2009 15:08:29 -0500 (EST)
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.DEB.2.00.0912171331300.3638@router.home>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091216101107.GA15031@basil.fritz.box>
	 <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091216102806.GC15031@basil.fritz.box>
	 <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com>
	 <1261004224.21028.500.camel@laptop> <20091217084046.GA9804@basil.fritz.box>
	 <alpine.DEB.2.00.0912171331300.3638@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 17 Dec 2009 21:07:50 +0100
Message-ID: <1261080470.27920.798.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 2009-12-17 at 13:33 -0600, Christoph Lameter wrote:
> On Thu, 17 Dec 2009, Andi Kleen wrote:
> 
> > > There are a few interesting cases like stack extention and hugetlbfs,
> > > but I think we could start by falling back to mmap_sem locked behaviour
> > > if the speculative thing fails.
> >
> > You mean fall back to mmap_sem if anything sleeps? Maybe. Would need
> > to check how many such points are really there.
> 
> You always need some reference on the mm_struct (mm_read_lock) if you are
> going to sleep to ensure that mm_struct still exists after waking up (page
> fault, page allocation). RCU and other spin locks are not helping there.

Depends what you go to sleep for, the page fault retry patches simply
retook the whole fault and there is no way the mm could have gone away
when userspace isn't executing.

Also pinning a page will pin the vma will pin the mm, and then you can
always take explicit mm_struct refs, but you really want to avoid that
since that's a global cacheline again.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
