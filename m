Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA22995
	for <linux-mm@kvack.org>; Fri, 28 Aug 1998 17:33:09 -0400
Subject: Re: [PATCH] 498+ days uptime
References: <199808262153.OAA13651@cesium.transmeta.com> 	<87ww7v73zg.fsf@atlas.CARNet.hr> 	<199808271207.OAA15842@hwal02.hyperwave.com> 	<87emu2zkc0.fsf@atlas.CARNet.hr> 	<199808271243.OAA28073@hwal02.hyperwave.com> <m1d89lex3t.fsf@flinx.npwt.net>
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 28 Aug 1998 23:32:50 +0200
In-Reply-To: ebiederm@inetnebr.com's message of "27 Aug 1998 20:03:34 -0500"
Message-ID: <87u32whjwd.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: "Eric W. Biederman" <ebiederm@inetnebr.com>
Cc: Bernhard Heidegger <bheide@hyperwave.com>, "H. Peter Anvin" <hpa@transmeta.com>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, Linux-MM List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

ebiederm@inetnebr.com (Eric W. Biederman) writes:

> >>>>> "BH" == Bernhard Heidegger <bheide@hyperwave.com> writes:
> 
> >>>>> ">" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:
> >>> Bernhard Heidegger <bheide@hyperwave.com> writes:
> >>> >>>>> ">" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:
> >>> 
> >>> >> "H. Peter Anvin" <hpa@transmeta.com> writes:
> >>> >> > 
> >>> >> > bdflush yes, but update is not obsolete.
> >>> >> > 
> >>> >> > It is still needed if you want to make sure data (and metadata)
> >>> >> > eventually gets written to disk.
> >>> >> > 
> >>> >> > Of course, you can run without update, but then don't bother if you
> >>> >> > lose file in system crash, even if you edited it and saved it few
> >>> >> > hours ago. :)
> >>> >> > 
> >>> >> > Update is very important if you have lots of RAM in your computer.
> >>> >> > 
> >>> >> 
> >>> >> Oh.  I guess my next question then is "why", as why can't this be done
> >>> >> by kflushd as well?
> >>> >> 
> >>> 
> >>> >> To tell you the truth, I'm not sure why, these days.
> >>> 
> >>> >> I thought it was done this way (update running in userspace) so to
> >>> >> have control how often buffers get flushed. But, I believe bdflush
> >>> >> program had this functionality, and it is long gone (as you correctly
> >>> >> noticed).
> >>> 
> >>> IMHO, update/bdflush (in user space) calls sys_bdflush regularly. This
> >>> function (fs/buffer.c) calls sync_old_buffers() which itself sync_supers
> >>> and sync_inodes before it goes through the dirty buffer lust (to write
> >>> some dirty buffers); the kflushd only writes some dirty buffers dependent
> >>> on the sysctl parameters.
> >>> If I'm wrong, please feel free to correct me!
> >>> 
> 
> >>> You are not wrong.
> 
> >>> Update flushes metadata blocks every 5 seconds, and data block every
> >>> 30 seconds.
> 
> BH> My version of update (something around Slakware 3.4) does the following:
> BH> 1.) calls bdflush(1,0) (fs/buffer.c:sys_bdflush) which will call
> BH>     sync_old_buffers() and return
> BH> 2.) only if the bdflush(1,0) fails (it returns < 0) it returns to the
> BH>     old behavior of sync()ing every 30 seconds
> 
> BH> But case 2) should only happen on really old kernels; on newer kernels
> BH> (I'm using 2.0.34) the bdflush() should never fail.
> 
> BH> But as I told, sync_old_buffers() do:
> BH> 1.) sync_supers(0)
> BH> 2.) sync_inodes(0)
> BH> 3.) go through dirty buffer list and may flush some buffers
> 
> BH> Conclusion: the meta data get synced every 5 seconds and some buffers may
> BH> be flushed.
> 
> >>> Questions is why can't this functionality be integrated in the kernel, 
> >>> so we don't have to run yet another daemon?
> 
> We can do this in kernel thread but I don't see the win.
> 

One daemon less to run.

This should be enough.

You have one less process running, you free some memory, and make
things slightly cleaner.

Not a big win, but small things make people happy. :)
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
       Linux, WinNT and MS-DOS. The Good, The Bad and The Ugly.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
