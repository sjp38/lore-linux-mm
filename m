Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3FAEC60021B
	for <linux-mm@kvack.org>; Mon, 28 Dec 2009 03:56:15 -0500 (EST)
Subject: Re: [RFC PATCH] asynchronous page fault.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20091228093606.9f2e666c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
	 <1261915391.15854.31.camel@laptop>
	 <20091228093606.9f2e666c.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 28 Dec 2009 09:55:33 +0100
Message-ID: <1261990533.7135.34.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Mon, 2009-12-28 at 09:36 +0900, KAMEZAWA Hiroyuki wrote:
> Hmm ? for single-thread apps ? This patch's purpose is not for lockless
> lookup, it's just a part of work. My purpose is avoiding false-sharing.

False sharing in the sense of the mmap_sem cacheline containing other
variables? How could that ever be a problem for a single threaded
application?

For multi-threaded apps the contention on that cacheline is the largest
issue, and moving it to a vma cacheline doesn't seem like a big
improvement.

You want something much finer grained than vmas, there's lots of apps
working on a single (or very few) vma(s). Leaving you with pretty much
the same cacheline contention. Only now its a different cacheline.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
