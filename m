Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3B1236B02D4
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 22:55:31 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7Q2tQ3J009507
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Aug 2010 11:55:26 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2217B45DE54
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 11:55:26 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E02AD45DE4E
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 11:55:25 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B864C1DB8053
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 11:55:25 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E0E41DB804D
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 11:55:25 +0900 (JST)
Date: Thu, 26 Aug 2010 11:50:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
Message-Id: <20100826115017.04f6f707.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <op.vh0wektv7p4s8u@localhost>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
	<1282310110.2605.976.camel@laptop>
	<20100825155814.25c783c7.akpm@linux-foundation.org>
	<20100826095857.5b821d7f.kamezawa.hiroyu@jp.fujitsu.com>
	<op.vh0wektv7p4s8u@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: =?UTF-8?B?TWljaGHFgg==?= Nazarewicz <m.nazarewicz@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hans Verkuil <hverkuil@xs4all.nl>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Aug 2010 04:12:10 +0200
MichaA? Nazarewicz <m.nazarewicz@samsung.com> wrote:

> On Thu, 26 Aug 2010 02:58:57 +0200, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Hmm, you may not like this..but how about following kind of interface ?
> >
> > Now, memoyr hotplug supports following operation to free and _isolate_
> > memory region.
> > 	# echo offline > /sys/devices/system/memory/memoryX/state
> >
> > Then, a region of memory will be isolated. (This succeeds if there are free
> > memory.)
> >
> > Add a new interface.
> >
> > 	% echo offline > /sys/devices/system/memory/memoryX/state
> > 	# extract memory from System RAM and make them invisible from buddy allocator.
> >
> > 	% echo cma > /sys/devices/system/memory/memoryX/state
> > 	# move invisible memory to cma.
> 
> At this point I need to say that I have no experience with hotplug memory but
> I think that for this to make sense the regions of memory would have to be
> smaller.  Unless I'm misunderstanding something, the above would convert
> a region of sizes in order of GiBs to use for CMA.
> 

Now, x86's section size is 
==
#ifdef CONFIG_X86_32
# ifdef CONFIG_X86_PAE
#  define SECTION_SIZE_BITS     29
#  define MAX_PHYSADDR_BITS     36
#  define MAX_PHYSMEM_BITS      36
# else
#  define SECTION_SIZE_BITS     26
#  define MAX_PHYSADDR_BITS     32
#  define MAX_PHYSMEM_BITS      32
# endif
#else /* CONFIG_X86_32 */
# define SECTION_SIZE_BITS      27 /* matt - 128 is convenient right now */
# define MAX_PHYSADDR_BITS      44
# define MAX_PHYSMEM_BITS       46
#endif
==

128MB...too big ? But it's depend on config.

IBM's ppc guys used 16MB section, and recently, a new interface to shrink
the number of /sys files are added, maybe usable.

Something good with this approach will be you can create "cma" memory
before installing driver.

But yes, complicated and need some works.

Bye,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
