Received: from firewall.hyperwave.com (firewall.hyperwave.com [129.27.200.34])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA20987
	for <linux-mm@kvack.org>; Fri, 28 Aug 1998 12:04:35 -0400
Date: Fri, 28 Aug 1998 18:03:17 +0200 (MET DST)
Message-Id: <199808281603.SAA05389@hwal02.hyperwave.com>
From: Bernhard Heidegger <bheide@hyperwave.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] 498+ days uptime
In-Reply-To: <m1btp5dz8u.fsf@flinx.npwt.net>
References: <199808262153.OAA13651@cesium.transmeta.com>
	<87ww7v73zg.fsf@atlas.CARNet.hr>
	<199808271207.OAA15842@hwal02.hyperwave.com>
	<87emu2zkc0.fsf@atlas.CARNet.hr>
	<199808271243.OAA28073@hwal02.hyperwave.com>
	<m1d89lex3t.fsf@flinx.npwt.net>
	<199808280909.LAA19060@hwal02.hyperwave.com>
	<m1btp5dz8u.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@inetnebr.com>
Cc: Bernhard Heidegger <bheide@hyperwave.com>, Zlatko.Calusic@CARNet.hr, "H. Peter Anvin" <hpa@transmeta.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> ">" == Eric W Biederman <ebiederm@inetnebr.com> writes:

>>>> No.  Major performance problem.

BH> Why?

BH> Imagine an application which has most of the (index) file pages in memory
BH> and many of the pages are dirty. bdflush will flush the pages regularly,
BH> but the pages will get dirty immediately again.
BH> If you can be sure, that the power cannot fail the performance should be
BH> much better without bdflush, because kflushd has to write pages only if
BH> the system is running low on memory...

>> The performance improvement comes when looking for free memory.  In
>> most cases bdflush's slow but steady writing of pages keeps buffers
>> clean.  When the application wants more memory with bdflush in the
>> background unsually the pages it needs will be clean (because the I/O
>> started before the application needed it), so they can just be dropped
>> out of memory.  Relying on kflushd means nothing is written until an
>> application needs the memory and then it must wait until something is
>> written to disk, which is much slower.

>> Further 
>> a) garanteeing no power failure is hard.

Use and UPS and regularly flush/sync the primary data to disk from
the application

>> b) generally there is so much data on the disk you must write it
>>    sometime, because you can't hold it all in memory.

only a question of how much RAM you can put in your PC

>> c) I have trouble imagining a case where a small file would be rewritten
>>    continually.

Not really small, but a database application may use btree based indexes,
where many blocks will get dirty when inserting/deleting data. If you flush
the dirty buffers and the next insertion dirty the same buffer(s) you have
lost performance (Note: the btree based indexes are secondary data; you
can rebuild it from scratch if the system fails)

Bernhard

get my pgp key from a public keyserver (keyID=0x62446355)
-----------------------------------------------------------------------------
Bernhard Heidegger                                       bheide@hyperwave.com
                  Hyperwave Software Research & Development
                       Schloegelgasse 9/1, A-8010 Graz
Voice: ++43/316/820918-25                             Fax: ++43/316/820918-99
-----------------------------------------------------------------------------
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
