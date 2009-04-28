Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5C2376B003D
	for <linux-mm@kvack.org>; Tue, 28 Apr 2009 03:36:01 -0400 (EDT)
Date: Tue, 28 Apr 2009 09:40:31 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 5/5] proc: export more page flags in /proc/kpageflags
Message-ID: <20090428074031.GK27382@one.firstfloor.org>
References: <20090428010907.912554629@intel.com> <20090428014920.769723618@intel.com> <20090428065507.GA2024@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090428065507.GA2024@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Steven Rostedt <rostedt@goodmis.org>, =?iso-8859-1?Q?Fr=E9d=E9ric?= Weisbecker <fweisbec@gmail.com>, Larry Woodman <lwoodman@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Matt Mackall <mpm@selenic.com>, Alexey Dobriyan <adobriyan@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> I think i have to NAK this kind of ad-hoc instrumentation of kernel 
> internals and statistics until we clear up why such instrumentation 

I think because it has zero fast path overhead and can be used
any time without enabling anything special.

> measures are being accepted into the MM while other, more dynamic 

While the dynamic instrumentation you're proposing 
has non zero fast path overhead, especially if you consider the
CPU time needed for the backend computation in user space too.

And it requires explicit tracing first and some backend 
that counts the events and maintains a shadow data structure
covering all of mem_map again.

So it's clear your alternative will be much more costly, plus
have additional drawbacks (needs enabling first, cannot
take a snapshot at arbitary time)

Also dynamic tracing tends to have trouble with full memory
observation. I experimented with systemtap tracing for my
memory usage paper I did a couple of years ago, but ended 
up with integrated counters (similar to those) because it was
impossible to do proper accounting for the pages set up
in early boot with the standard tracers.

I suspect both have their uses (that's indeed some things
that can only be done with dynamic tracing), but they're clearly
complementary and the static facility seems useful enough
on its own. 

I think Fengguang is demonstrating that clearly by the great
improvements he's doing for readahead which are enabled by these
patches.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
