Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id BA0236B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 11:43:32 -0500 (EST)
Date: Fri, 5 Mar 2010 09:31:37 -0700
Message-Id: <201003051631.o25GVbsD010752@alien.loup.net>
From: Mike Hayward <hayward@loup.net>
In-reply-to: <f875e2fe1003041823o507ecb36qfd7af7d27de7683d@mail.gmail.com>
	(message from s ponnusa on Thu, 4 Mar 2010 21:23:09 -0500)
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
	 <f875e2fe1003040458o3e13de97v3d839482939b687b@mail.gmail.com>
	 <201003041631.o24GVl51005720@alien.loup.net>
	 <f875e2fe1003041012m680ffc87i50099ed011526440@mail.gmail.com>
	 <201003050042.o250gsUC007947@alien.loup.net> <f875e2fe1003041823o507ecb36qfd7af7d27de7683d@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: foosaa@gmail.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 > The data written through linux cannot be read back by any other means.
 > Does that prove any data corruption? I wrote a signature on to a bad
 > drive. (With all the before mentioned permutation and combinations).
 > The program returned 0 (zero) errors and said the data was
 > successfully written to all the sectors of the drive and it had taken
 > 5 hrs (The sample size of the drive is 20 GB). And I tried to verify
 > it using another program on linux. It produced read errors across a
 > couple of million sectors after almost 13 hours of grinding the
 > hdd.

It is normal, although low probability, for what we call a 'stable'
storage device to lose data for numerous reasons.  It detects this by
returning io error if a checksum doesn't match.  An I/O error is not
data corruption, it is what we would call data loss or unavailability.

 > I can understand the slow remapping process during the write
 > operations. But what if the drive has used up all the available
 > sectors for mapping and is slowly dying. The SMART data displays
 > thousands of seek, read, crc errors and still linux does not notify
 > the program which has asked it to write some data. ????

SMART data is not really all that standardized, and it is quite normal
to see the drive correcting errors with rereads, reseeks, ecc, etc. so
determining drive health really is manufacturer and model specific.

If it remaps either from it's own retry or from the operating system
retrying, it should of course return a succesful write even if it
takes a minute or two.  Once it is out of blocks to remap with it must
return io error or timeout.

All that being said, if a drive returns success after writing, and you
read different data than you "successfully wrote", as opposed to an
error, this is data corruption.  My number 1 rule of storage is "thou
shalt not silently corrupt data".  It should be incredibly unlikely
due to sufficiently strong checksum that silent corruption should
occur.  If you are detecting it this frequently, clearly something is
not working as intended.  This means the storage system is not
sufficiently "stable" to rely upon it's own checksums and return codes
for correctness.

This is why some apps may resort to replication or to adding
additional checksums or ecc at a higher layer, but this should
generally be unnecessary.  I would use such techniques primarily to
prove corruption defects in kernels, drivers, or hardware, or if, as
Alan mentioned, I were storing an extremely large amount of data.  For
performance reasons, my software (which does store huge amounts of
data) relies primarily upon replication (to work around both
unavailability and corruption) as opposed to parity techniques and
this is effectively what you are doing to prove data corruption here.

Hopefully you haven't found high probability data corruption :-) Can
you reproduce the problem with different manufacturers or models of
drives?  If so, the problem is most likely not in the drive.  I'd say
that's job number one and it's easy to try.  Short of doing a white
box inspection of the kernel, you could narrow the problem down by
swapping out kernels (try another much older or newer linux kernel,
and try another os) and various pieces of hardware.

If everything points to the linux kernel, then you'll have to start
instrumenting the kernel to track down where, exactly, it returns
success after having logged ata errors.  If the write didn't
eventually succeed after retries, but returned success to your app,
you'll have your kernel bug and be famous :-)

Or you could start there if you are confident it isn't the hardware or
your program.  Thankfully you are using linux and have an open kernel
data path to work with.

If you prove the drive is lying, which manufacturer makes it?  You
could call up the manufacturer with your reproducible problem.  They
would probably like to know if their controller is corrupting.

- Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
