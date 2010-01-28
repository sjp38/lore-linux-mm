Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id D8C6C6B0047
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 19:15:13 -0500 (EST)
Date: Thu, 28 Jan 2010 00:16:36 +0000
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH v3] oom-kill: add lowmem usage aware oom kill handling
Message-ID: <20100128001636.2026a6bc@lxorguk.ukuu.org.uk>
In-Reply-To: <20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126151202.75bd9347.akpm@linux-foundation.org>
	<20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126161952.ee267d1c.akpm@linux-foundation.org>
	<20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, rientjes@google.com, minchan.kim@gmail.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

> Now, /proc/<pid>/oom_score and /proc/<pid>/oom_adj are used by servers.

And embedded, and some desktops (including some neat experimental hacks
where windows slowly get to be bigger bigger oom targes the longer
they've been non-focussed)

> For my customers, I don't like oom black magic. I'd like to recommend to
> use memcg, of course ;) But lowmem oom cannot be handled by memcg, well.
> So I started from this. 

I can't help feeling this is the wrong approach. IFF we are running out
of low memory pages then killing stuff for that reason is wrong to begin
with except in extreme cases and those extreme cases are probably also
cases the kill won't help.

If we have a movable user page (even an mlocked one) then if there is
space in other parts of memory (ie the OOM is due to a single zone
problem) we should *never* be killing in the first place, we should be
moving the page. The mlock case is a bit hairy but the non mlock case is
exactly the same sequence of operations as a page out and page in
somewhere else skipping the widdling on the disk bit in the middle.

There are cases we can't do that - eg if the kernel has it pinned for
DMA, but in that case OOM isn't going to recover the page either - at
least not until the DMA or whatever unpins it (at which point you could
just move it).

Am I missing something fundamental here ?

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
