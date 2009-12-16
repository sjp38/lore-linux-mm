Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C1AA16B0044
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 17:57:40 -0500 (EST)
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091216101107.GA15031@basil.fritz.box>
	 <20091216191312.f4655dac.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091216102806.GC15031@basil.fritz.box>
	 <20091216193109.778b881b.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 16 Dec 2009 23:57:04 +0100
Message-ID: <1261004224.21028.500.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, 2009-12-16 at 19:31 +0900, KAMEZAWA Hiroyuki wrote:

> The problem of range locking is more than mmap_sem, anyway. I don't think
> it's possible easily.

We already have a natural range lock in the form of the split pte lock.

If we make the vma lookup speculative using RCU, we can use the pte lock
to verify we got the right vma, because munmap requires the pte lock to
complete the unmap.

The fun bit is dealing with the fallout if we got it wrong, since we
might then have instantiated page-tables not covered by a vma just to
take the pte lock, it also requires we RCU free the page-tables iirc.

There are a few interesting cases like stack extention and hugetlbfs,
but I think we could start by falling back to mmap_sem locked behaviour
if the speculative thing fails.

As to the proposed patches, I tend to agree that simply wrapping the
mmap_sem semantics in different accessors is pointless, expressing the
same semantics in different ways really doesn't help.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
