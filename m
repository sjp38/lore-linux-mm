Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 99F846B0055
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 09:36:25 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <84144f020908310308i48790f78g5a7d73a60ea854f8@mail.gmail.com>
References: <84144f020908310308i48790f78g5a7d73a60ea854f8@mail.gmail.com> <20090831074842.GA28091@linux-sh.org>
Subject: Re: page allocator regression on nommu
Date: Tue, 01 Sep 2009 14:35:47 +0100
Message-ID: <6126.1251812147@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: dhowells@redhat.com, Paul Mundt <lethal@linux-sh.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Hansen <dave@linux.vnet.ibm.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Pekka Enberg <penberg@cs.helsinki.fi> wrote:

> This looks to be a bug in nommu do_mmap_pgoff() error handling. I
> guess we shouldn't call __put_nommu_region() if add_nommu_region()
> hasn't been called?

We should to make sure the region gets cleaned up properly.  However, it will
go wrong if do_mmap_shared_file() or do_mmap_private() fail.  We should
perhaps call add_nommu_region() before doing the "set up the mapping" chunk -
we hold the region semaphore, so it shouldn't hurt anyone if we then have to
remove it again.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
