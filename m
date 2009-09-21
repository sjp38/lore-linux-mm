Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3A0D56B0165
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 09:46:17 -0400 (EDT)
Message-ID: <4AB78385.6020900@kernel.org>
Date: Mon, 21 Sep 2009 22:45:41 +0900
From: Tejun Heo <tj@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] slqb: Do not use DEFINE_PER_CPU for per-node data
References: <1253302451-27740-1-git-send-email-mel@csn.ul.ie> <1253302451-27740-2-git-send-email-mel@csn.ul.ie> <84144f020909200145w74037ab9vb66dae65d3b8a048@mail.gmail.com> <4AB5FD4D.3070005@kernel.org> <4AB5FFF8.7000602@cs.helsinki.fi> <4AB6508C.4070602@kernel.org> <4AB739A6.5060807@in.ibm.com> <20090921084248.GC12726@csn.ul.ie> <20090921130440.GN12726@csn.ul.ie>
In-Reply-To: <20090921130440.GN12726@csn.ul.ie>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Sachin Sant <sachinp@in.ibm.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Hello,

Mel Gorman wrote:
> This latter guess was close to the mark but not for the reasons I was
> guessing. There isn't magic per-cpu-area-freeing going on. Once I examined
> the implementation of per-cpu data, it was clear that the per-cpu areas for
> the node IDs were never being allocated in the first place on PowerPC. It's
> probable that this never worked but that it took a long time before SLQB
> was run on a memoryless configuration.

Ah... okay, so node id was being used to access percpu memory but the
id wasn't in cpu_possible_map.  Yeah, that will access weird places in
between proper percpu areas.  I never thought about that.  I'll add
debug version of percpu access macros which check that the offset and
cpu make sense so that things like this can be caught easier.

As Pekka suggested, using MAX_NUMNODES seems more appropriate tho
although it's suboptimal in that it would waste memory and more
importantly not use node-local memory. :-(

Sachin, does the hang you're seeing also disappear with Mel's patches?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
