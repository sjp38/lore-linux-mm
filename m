Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA23294
	for <linux-mm@kvack.org>; Fri, 28 Aug 1998 18:04:14 -0400
Subject: Re: [PATCH] 498+ days uptime
References: <199808262153.OAA13651@cesium.transmeta.com> 	<87ww7v73zg.fsf@atlas.CARNet.hr> 	<199808271207.OAA15842@hwal02.hyperwave.com> 	<87emu2zkc0.fsf@atlas.CARNet.hr> 	<199808271243.OAA28073@hwal02.hyperwave.com> 	<m1d89lex3t.fsf@flinx.npwt.net> 	<199808280909.LAA19060@hwal02.hyperwave.com> 	<m1btp5dz8u.fsf@flinx.npwt.net> <199808281603.SAA05389@hwal02.hyperwave.com>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 29 Aug 1998 00:03:09 +0200
In-Reply-To: Bernhard Heidegger's message of "Fri, 28 Aug 1998 18:03:17 +0200 (MET DST)"
Message-ID: <87pvdkhihu.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Bernhard Heidegger <bheide@hyperwave.com>
Cc: "Eric W. Biederman" <ebiederm@inetnebr.com>, "H. Peter Anvin" <hpa@transmeta.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Bernhard Heidegger <bheide@hyperwave.com> writes:

> >>>>> ">" == Eric W Biederman <ebiederm@inetnebr.com> writes:
> 
> >>>> No.  Major performance problem.
> 
> BH> Why?
> 
> BH> Imagine an application which has most of the (index) file pages in memory
> BH> and many of the pages are dirty. bdflush will flush the pages regularly,
> BH> but the pages will get dirty immediately again.
> BH> If you can be sure, that the power cannot fail the performance should be
> BH> much better without bdflush, because kflushd has to write pages only if
> BH> the system is running low on memory...
> 
> >> The performance improvement comes when looking for free memory.  In
> >> most cases bdflush's slow but steady writing of pages keeps buffers
> >> clean.  When the application wants more memory with bdflush in the
> >> background unsually the pages it needs will be clean (because the I/O
> >> started before the application needed it), so they can just be dropped
> >> out of memory.  Relying on kflushd means nothing is written until an
> >> application needs the memory and then it must wait until something is
> >> written to disk, which is much slower.
> 
> >> Further 
> >> a) garanteeing no power failure is hard.
> 
> Use and UPS and regularly flush/sync the primary data to disk from
> the application

Update/bdflush costs you nothing. UPS costs you lots of money. Big
difference.

Also, flushing/syncing data to disk doesn't always mean data really
got to media. Check your favorite sync(2) manpage. :)

Using completely synchronous API in applications would consideraly cut
performances down. Why would your application wait for disk to commit
buffers, when your CPU can do other useful things in the meantime.
Also, don't forget that disk latency times are measured in
milliseconds, where modern CPU's run in units of (almost) nanoseconds.

> 
> >> b) generally there is so much data on the disk you must write it
> >>    sometime, because you can't hold it all in memory.
> 
> only a question of how much RAM you can put in your PC

Still requires money. :)

> 
> >> c) I have trouble imagining a case where a small file would be rewritten
> >>    continually.
> 
> Not really small, but a database application may use btree based indexes,
> where many blocks will get dirty when inserting/deleting data. If you flush
> the dirty buffers and the next insertion dirty the same buffer(s) you have
> lost performance (Note: the btree based indexes are secondary data; you
> can rebuild it from scratch if the system fails)
> 

Right, we agree. But performance doesn't go down if you write buffers
every few tens of seconds. That is a LOT of time, if you ask your
application. Some of them never get so old. :)

And (big) databases mostly like to have their own memory management,
because "they know better".
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
	Vi is the God of editors. Emacs is the editor of Gods.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
