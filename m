Received: from firewall.hyperwave.com (firewall.hyperwave.com [129.27.200.34])
	by kvack.org (8.8.7/8.8.7) with ESMTP id FAA18864
	for <linux-mm@kvack.org>; Fri, 28 Aug 1998 05:10:16 -0400
Date: Fri, 28 Aug 1998 11:09:59 +0200 (MET DST)
Message-Id: <199808280909.LAA19060@hwal02.hyperwave.com>
From: Bernhard Heidegger <bheide@hyperwave.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] 498+ days uptime
In-Reply-To: <m1d89lex3t.fsf@flinx.npwt.net>
References: <199808262153.OAA13651@cesium.transmeta.com>
	<87ww7v73zg.fsf@atlas.CARNet.hr>
	<199808271207.OAA15842@hwal02.hyperwave.com>
	<87emu2zkc0.fsf@atlas.CARNet.hr>
	<199808271243.OAA28073@hwal02.hyperwave.com>
	<m1d89lex3t.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@inetnebr.com>
Cc: Bernhard Heidegger <bheide@hyperwave.com>, Zlatko.Calusic@CARNet.hr, "H. Peter Anvin" <hpa@transmeta.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

>>>>> ">" == Eric W Biederman <ebiederm@inetnebr.com> writes:

>>>>> "BH" == Bernhard Heidegger <bheide@hyperwave.com> writes:
>>>>> ">" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:
>>>> Bernhard Heidegger <bheide@hyperwave.com> writes:
>>>> >>>>> ">" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:
>>>> 
>>>> >> "H. Peter Anvin" <hpa@transmeta.com> writes:
>>>> >> > 
>>>> >> > bdflush yes, but update is not obsolete.
>>>> >> > 
>>>> >> > It is still needed if you want to make sure data (and metadata)
>>>> >> > eventually gets written to disk.
>>>> >> > 
>>>> >> > Of course, you can run without update, but then don't bother if you
>>>> >> > lose file in system crash, even if you edited it and saved it few
>>>> >> > hours ago. :)
>>>> >> > 
>>>> >> > Update is very important if you have lots of RAM in your computer.
>>>> >> > 
>>>> >> 
>>>> >> Oh.  I guess my next question then is "why", as why can't this be done
>>>> >> by kflushd as well?
>>>> >> 
>>>> 
>>>> >> To tell you the truth, I'm not sure why, these days.
>>>> 
>>>> >> I thought it was done this way (update running in userspace) so to
>>>> >> have control how often buffers get flushed. But, I believe bdflush
>>>> >> program had this functionality, and it is long gone (as you correctly
>>>> >> noticed).
>>>> 
>>>> IMHO, update/bdflush (in user space) calls sys_bdflush regularly. This
>>>> function (fs/buffer.c) calls sync_old_buffers() which itself sync_supers
>>>> and sync_inodes before it goes through the dirty buffer lust (to write
>>>> some dirty buffers); the kflushd only writes some dirty buffers dependent
>>>> on the sysctl parameters.
>>>> If I'm wrong, please feel free to correct me!
>>>> 

>>>> You are not wrong.

>>>> Update flushes metadata blocks every 5 seconds, and data block every
>>>> 30 seconds.

BH> My version of update (something around Slakware 3.4) does the following:
BH> 1.) calls bdflush(1,0) (fs/buffer.c:sys_bdflush) which will call
BH> sync_old_buffers() and return
BH> 2.) only if the bdflush(1,0) fails (it returns < 0) it returns to the
BH> old behavior of sync()ing every 30 seconds

BH> But case 2) should only happen on really old kernels; on newer kernels
BH> (I'm using 2.0.34) the bdflush() should never fail.

BH> But as I told, sync_old_buffers() do:
BH> 1.) sync_supers(0)
BH> 2.) sync_inodes(0)
BH> 3.) go through dirty buffer list and may flush some buffers

BH> Conclusion: the meta data get synced every 5 seconds and some buffers may
BH> be flushed.

>>>> Questions is why can't this functionality be integrated in the kernel, 
>>>> so we don't have to run yet another daemon?

>> We can do this in kernel thread but I don't see the win.

I don't have a problem with the user level thing (so I can decide to not
start it ;-)

BH> Good question, but I've another one: IMHO sync_old_buffers (especially
BH> the for loop) do similar things as the kflushd. Why??

>> kflushd removes buffers only when we are low on memory, and unconditionally.

>> bdflush lets buffers sit for 30 seconds and every 5 seconds it checks
>> for buffers that are at least 30 seconds old and flushes them.

Ahh, is this bh->b_flushtime?

>> bdflush does most of the work.

Yes, I know :-(

BH> Is it possible to reduce the sync_old_buffers() routine to soemthing like:

>> No.  Major performance problem.

Why?

Imagine an application which has most of the (index) file pages in memory
and many of the pages are dirty. bdflush will flush the pages regularly,
but the pages will get dirty immediately again.
If you can be sure, that the power cannot fail the performance should be
much better without bdflush, because kflushd has to write pages only if
the system is running low on memory...

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
