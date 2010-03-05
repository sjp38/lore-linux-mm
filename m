Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 20FE06B009B
	for <linux-mm@kvack.org>; Thu,  4 Mar 2010 19:54:39 -0500 (EST)
Date: Thu, 4 Mar 2010 17:42:54 -0700
Message-Id: <201003050042.o250gsUC007947@alien.loup.net>
From: Mike Hayward <hayward@loup.net>
In-reply-to: <f875e2fe1003041012m680ffc87i50099ed011526440@mail.gmail.com>
	(message from s ponnusa on Thu, 4 Mar 2010 13:12:59 -0500)
Subject: Re: Linux kernel - Libata bad block error handling to user mode
	program
References: <f875e2fe1003032052p944f32ayfe9fe8cfbed056d4@mail.gmail.com>
	 <20100303224245.ae8d1f7a.akpm@linux-foundation.org>
	 <f875e2fe1003040458o3e13de97v3d839482939b687b@mail.gmail.com>
	 <201003041631.o24GVl51005720@alien.loup.net> <f875e2fe1003041012m680ffc87i50099ed011526440@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: foosaa@gmail.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org, jens.axboe@oracle.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 > The write cache is turned off at the hdd level. I am using O_DIRECT
 > mode with aligned buffers of the 4k page size. I have turned off the
 > page cache and read ahead during read as well using the fadvise
 > function.
 > 
 > As you have mentioned, the program grinds the hdd when it hits the bad
 > sector patch. It retries to remap / write again until it (hdd) fails.
 > It then finds the hdd does not respond and finally resets the device.
 > (This goes on and the program eventually moves on the next sector
 > because write call returned success. No errno value was set. Is this
 > how a write will function in linux? It does not propagate the error to
 > the user mode program for any reasons related to the disk failures
 > during a write process even with the O_DIRECT flag.

If O_DIRECT and no write cache, either the sector finally was
remapped, or the successful return is very disturbing.  Doesn't matter
what operating system, it should not silently corrupt with write cache
off.  Test by writing nonzero random data on one of these 'retry'
sectors.  Reread to see if data returned after successful write.  If
so, you'll know it's just slow to remap.

Because timeouts can take awhile, if you have many bad blocks I
imagine this could be a very painful process :-) It's one thing to
wipe a functioning drive, another to wipe a failed one.  If drive
doesn't have a low level function to do it more quickly (cut out the
long retries), after a couple of hours I'd give up on that, literally
disassemble and destroy the platters.  It is probably faster and
cheaper than spending a week trying to chew through the bad section.
Keep in mind, zeroing the drive is not going to erase the data all
that well anyway.  Might as well skip regions when finding a bad
sequence and scrub as much of the rest as you can without getting hung
up on 5% of the data, then mash it to bits or take a nasty magnet or
some equally destructive thing to it!

If it definitely isn't storing the data you write after it returns
success (reread it to check), I'd definitely call that a write-read
corruption, either in the kernel or in the drive.  If in kernel it
should be fixed as that is seriously broken to silently ignore data
corruption and I think we'd all like to trust the kernel if not the
drive :-)

Please let me know if you can prove data corruption.  I'm writing a
sophisticated storage app and would like to know if kernel has such a
defect.  My bet is it's just a drive that is slowly remapping.

- Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
