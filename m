Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E892660021B
	for <linux-mm@kvack.org>; Sat,  2 Jan 2010 16:45:55 -0500 (EST)
Subject: Re: [RFC PATCH] asynchronous page fault.
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 03 Jan 2010 08:45:33 +1100
Message-ID: <1262468733.2173.251.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-12-25 at 10:51 +0900, KAMEZAWA Hiroyuki wrote:
> Speculative page fault v3.
> 
> This version is much simpler than old versions and doesn't use mm_accessor
> but use RCU. This is based on linux-2.6.33-rc2.
> 
> This patch is just my toy but shows...
>  - Once RB-tree is RCU-aware and no-lock in readside, we can avoid mmap_sem
>    in page fault. 
> So, what we need is not mm_accessor, but RCU-aware RB-tree, I think.
> 
> But yes, I may miss something critical ;)
> 
> After patch, statistics perf show is following. Test progam is attached.

One concern I have with this, not that it can't be addressed but we'll
have to be extra careful, is that the mmap_sem in the page fault path
tend to protect more than just the VMA tree.

One example on powerpc is the slice map used to keep track of page
sizes. I would also need some time to convince myself that I don't have
some bits of the MMU hash code that doesn't assume that holding the
mmap_sem for writing prevents a PTE from being changed from !present to
present.

I wouldn't be surprised if there were more around fancy users of
->fault(), things like spufs, the DRM, etc...

Cheers,
Ben.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
