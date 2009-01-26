Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C0C9F6B0044
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:26:07 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 14B3982C25C
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:27:47 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NZOuEV3KQ7Ln for <linux-mm@kvack.org>;
	Mon, 26 Jan 2009 12:27:47 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2CACD82C25D
	for <linux-mm@kvack.org>; Mon, 26 Jan 2009 12:27:40 -0500 (EST)
Date: Mon, 26 Jan 2009 12:22:28 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch] SLQB slab allocator (try 2)
In-Reply-To: <1232960840.4863.7.camel@laptop>
Message-ID: <alpine.DEB.1.10.0901261219350.32192@qirst.com>
References: <20090123154653.GA14517@wotan.suse.de>  <1232959706.21504.7.camel@penberg-laptop> <1232960840.4863.7.camel@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 26 Jan 2009, Peter Zijlstra wrote:

> Then again, anything that does allocation is per definition not bounded
> and not something we can have on latency critical paths -- so on that
> respect its not interesting.

Well there is the problem in SLAB and SLQB that they *continue* to do
processing after an allocation. They defer queue cleaning. So your latency
critical paths are interrupted by the deferred queue processing. SLAB has
the awful habit of gradually pushing objects out of its queued (tried to
approximate the loss of cpu cache hotness over time). So for awhile you
get hit every 2 seconds with some free operations to the page allocator on
each cpu. If you have a lot of cpus then this may become an ongoing
operation. The slab pages end up in the page allocator queues which is
then occasionally pushed back to the buddy lists. Another relatively high
spike there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
