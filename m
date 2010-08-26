Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6D7C96B01F0
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 00:45:09 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7Q4j7lH004139
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Aug 2010 13:45:08 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D90C45DE56
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 13:45:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B7DC45DE4E
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 13:45:07 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id E5A881DB801B
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 13:45:06 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 880871DB8015
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 13:45:06 +0900 (JST)
Date: Thu, 26 Aug 2010 13:39:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
Message-Id: <20100826133954.4433fdf2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <op.vh01hi2m7p4s8u@localhost>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
	<1282310110.2605.976.camel@laptop>
	<20100825155814.25c783c7.akpm@linux-foundation.org>
	<20100826095857.5b821d7f.kamezawa.hiroyu@jp.fujitsu.com>
	<op.vh0wektv7p4s8u@localhost>
	<20100826115017.04f6f707.kamezawa.hiroyu@jp.fujitsu.com>
	<20100826124434.6089630d.kamezawa.hiroyu@jp.fujitsu.com>
	<op.vh01hi2m7p4s8u@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?B?TWljaGHFgg==?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Hans Verkuil <hverkuil@xs4all.nl>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Aug 2010 06:01:56 +0200
MichaA? Nazarewicz <m.nazarewicz@samsung.com> wrote:

> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 128MB...too big ? But it's depend on config.
> 
> On embedded systems it may be like half of the RAM.  Or a quarter.  So bigger
> granularity could be desired on some platforms.
> 
> > IBM's ppc guys used 16MB section, and recently, a new interface to shrink
> > the number of /sys files are added, maybe usable.
> >
> > Something good with this approach will be you can create "cma" memory
> > before installing driver.
> 
> That's how CMA works at the moment.  But if I understand you correctly, what
> you are proposing would allow to reserve memory *at* *runtime* long after system
> has booted.  This would be a nice feature as well though.
> 
Yes, my proposal is that. 

> > But yes, complicated and need some works.
> 
> > Ah, I need to clarify what I want to say.
> >
> > With compaction, it's helpful, but you can't get contiguous memory larger
> > than MAX_ORDER, I think. To get memory larger than MAX_ORDER on demand,
> > memory hot-plug code has almost all necessary things.
> 
> I'll try to look at it then.
> 

mm/memory_hotplug.c::offline_pages() does

	1. disallow new allocation of memory in [start_pfn...end_pfn)
	2. move all LRU pages to other regions than [start_pfn...end_pfn)
	3. finally, mark all pages as PG_reserved (see __offline_isolated_pages())

What's required for cma will be
	a. remove _section_ limitation, which is done as BUG_ON().
	b. replace 'step 3' with cma code.

Maybe you can do similar just using compaction logic. The biggest difference will
be 'step 1'.

> > BTW, just curious...the memory for cma need not to be saved at
> > hibernation ? Or drivers has to write its own hibernation ops by driver suspend
> > udev or some ?
> 
> Hibernation was not considered as of yet but I think it's device driver's
> responsibility more then CMA's especially since it may make little sense to save
> some of the buffers -- ie. no need to keep a frame from camera since it'll be
> overwritten just after system wakes up from hibernation.  It may also be better
> to stop playback and resume it later on rather than trying to save decoder's
> state.  Again though, I haven't thought about hibernation as of yet.
> 

Hmm, ok, use-case dependent and it's a job of a driver.

Thanks,
-Kame


 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
