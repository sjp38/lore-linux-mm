Received: from flinx.npwt.net (inetnebr@oma-pm1-002.inetnebr.com [206.222.220.46])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA20388
	for <linux-mm@kvack.org>; Fri, 28 Aug 1998 10:28:33 -0400
Subject: Re: [PATCH] 498+ days uptime
References: <199808262153.OAA13651@cesium.transmeta.com>
	<87ww7v73zg.fsf@atlas.CARNet.hr>
	<199808271207.OAA15842@hwal02.hyperwave.com>
	<87emu2zkc0.fsf@atlas.CARNet.hr>
	<199808271243.OAA28073@hwal02.hyperwave.com>
	<m1d89lex3t.fsf@flinx.npwt.net>
	<199808280909.LAA19060@hwal02.hyperwave.com>
From: ebiederm@inetnebr.com (Eric W. Biederman)
Date: 28 Aug 1998 08:14:57 -0500
In-Reply-To: Bernhard Heidegger's message of Fri, 28 Aug 1998 11:09:59 +0200 (MET DST)
Message-ID: <m1btp5dz8u.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Bernhard Heidegger <bheide@hyperwave.com>
Cc: "Eric W. Biederman" <ebiederm@inetnebr.com>, Zlatko.Calusic@CARNet.hr, "H. Peter Anvin" <hpa@transmeta.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> "BH" == Bernhard Heidegger <bheide@hyperwave.com> writes:

>>>>> ">" == Eric W Biederman <ebiederm@inetnebr.com> writes:

>>> bdflush lets buffers sit for 30 seconds and every 5 seconds it checks
>>> for buffers that are at least 30 seconds old and flushes them.

BH> Ahh, is this bh->b_flushtime?
yes.

>>> bdflush does most of the work.

BH> Yes, I know :-(

BH> Is it possible to reduce the sync_old_buffers() routine to soemthing like:

>>> No.  Major performance problem.

BH> Why?

BH> Imagine an application which has most of the (index) file pages in memory
BH> and many of the pages are dirty. bdflush will flush the pages regularly,
BH> but the pages will get dirty immediately again.
BH> If you can be sure, that the power cannot fail the performance should be
BH> much better without bdflush, because kflushd has to write pages only if
BH> the system is running low on memory...

The performance improvement comes when looking for free memory.  In
most cases bdflush's slow but steady writing of pages keeps buffers
clean.  When the application wants more memory with bdflush in the
background unsually the pages it needs will be clean (because the I/O
started before the application needed it), so they can just be dropped
out of memory.  Relying on kflushd means nothing is written until an
application needs the memory and then it must wait until something is
written to disk, which is much slower.

Further 
a) garanteeing no power failure is hard.
b) generally there is so much data on the disk you must write it
   sometime, because you can't hold it all in memory.
c) I have trouble imagining a case where a small file would be rewritten
   continually.

Eric 
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
