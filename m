Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA23146
	for <linux-mm@kvack.org>; Fri, 28 Aug 1998 17:47:49 -0400
Subject: Re: [PATCH] 498+ days uptime
References: <199808262153.OAA13651@cesium.transmeta.com> 	<87ww7v73zg.fsf@atlas.CARNet.hr> 	<199808271207.OAA15842@hwal02.hyperwave.com> 	<87emu2zkc0.fsf@atlas.CARNet.hr> 	<199808271243.OAA28073@hwal02.hyperwave.com> 	<m1d89lex3t.fsf@flinx.npwt.net> 	<199808280909.LAA19060@hwal02.hyperwave.com> <m1btp5dz8u.fsf@flinx.npwt.net>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 28 Aug 1998 23:47:37 +0200
In-Reply-To: ebiederm@inetnebr.com's message of "28 Aug 1998 08:14:57 -0500"
Message-ID: <87r9y0hj7q.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@inetnebr.com>
Cc: Bernhard Heidegger <bheide@hyperwave.com>, "H. Peter Anvin" <hpa@transmeta.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

ebiederm@inetnebr.com (Eric W. Biederman) writes:

> >>>>> "BH" == Bernhard Heidegger <bheide@hyperwave.com> writes:
> BH> Imagine an application which has most of the (index) file pages in memory
> BH> and many of the pages are dirty. bdflush will flush the pages regularly,
> BH> but the pages will get dirty immediately again.
> BH> If you can be sure, that the power cannot fail the performance should be
> BH> much better without bdflush, because kflushd has to write pages only if
> BH> the system is running low on memory...
> 
> The performance improvement comes when looking for free memory.  In
> most cases bdflush's slow but steady writing of pages keeps buffers
> clean.  When the application wants more memory with bdflush in the
> background unsually the pages it needs will be clean (because the I/O
> started before the application needed it), so they can just be dropped
> out of memory.  Relying on kflushd means nothing is written until an
> application needs the memory and then it must wait until something is
> written to disk, which is much slower.

Not absolutely true. kflushd flushes dirty buffers not when they're
all dirty, but when percentage of dirty buffers goes above the
threshold. And that threshold is tunable, default value as of recent
kernels is 40%.

So even if kflushd didn't run in time, that only means you have *up*
to 40% of dirty buffers. Other 60% or more are clean.

We're here speaking of first parameter in /proc/sys/vm/bdflush. It was
60 initially, but lowered recently (few months ago, half a year?) due
to problems with buffers at that time.

> 
> Further 
> a) garanteeing no power failure is hard.

Here I entirely agree. UPS' cost much more than update/bdflush. :)

> b) generally there is so much data on the disk you must write it
>    sometime, because you can't hold it all in memory.

Right.

> c) I have trouble imagining a case where a small file would be rewritten
>    continually.
> 

It happens. Otherwise we wouldn't need buffers at all. :)
Maybe only to achieve asynchrony.

Think of metadata, and operations of creating/deleting lots of files
in the directory, and similar. Imagine a busy news/proxy server.
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
		   Recursive, adj.; see Recursive.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
