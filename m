Received: from flinx.npwt.net (eric@flinx.npwt.net [208.236.161.237])
	by kvack.org (8.8.7/8.8.7) with ESMTP id WAA02008
	for <linux-mm@kvack.org>; Fri, 17 Jul 1998 22:30:08 -0400
Subject: Re: Comments on shmfs-0.1.010
References: <87n2a9o3m3.fsf@atlas.CARNet.hr>
From: ebiederm+eric@npwt.net (Eric W. Biederman)
Date: 17 Jul 1998 19:50:32 -0500
In-Reply-To: Zlatko Calusic's message of 17 Jul 1998 00:03:32 +0200
Message-ID: <m167gwm17r.fsf@flinx.npwt.net>
Sender: owner-linux-mm@kvack.org
To: Zlatko.Calusic@CARNet.hr
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "ZC" == Zlatko Calusic <Zlatko.Calusic@CARNet.hr> writes:

ZC> Hi!
ZC> Today, I finally found some time to play with shmfs and I must admit
ZC> that I'm astonished with the results!

ZC> After some trouble with patching (lots of conflicts which had to be
ZC> resolved manually), to my complete surprise, shmfs proved to be quite
ZC> stable and reliable.

ZC> I found these messages in logs (after every boot):

ZC> swap_after_unlock_page: lock already cleared
ZC> Adding Swap: 128988k swap-space (priority 0)
ZC> swap_after_unlock_page: lock already cleared
ZC> Adding Swap: 128484k swap-space (priority 0)

This is a normal case with no harm.  
I think normal 2.1.101 should cause it too.
It's simply a result of swapping adding swap.

ZC> and lots of these:

ZC> Jul 16 22:50:42 atlas kernel: write_page: called on a clean page! 
ZC> Jul 16 22:51:16 atlas last message repeated 612 times
ZC> Jul 16 22:51:29 atlas last message repeated 463 times
ZC> Jul 16 22:51:29 atlas kernel: kmalloc: Size (131076) too large 
ZC> Jul 16 22:51:30 atlas kernel: write_page: called on a clean page! 
ZC> Jul 16 22:51:30 atlas last message repeated 10 times
ZC> Jul 16 22:51:30 atlas kernel: kmalloc: Size (135172) too large 
ZC> Jul 16 22:51:30 atlas kernel: write_page: called on a clean page! 
ZC> Jul 16 22:51:30 atlas last message repeated 9 times
ZC> Jul 16 22:51:31 atlas kernel: kmalloc: Size (139268) too large 
ZC> etc...

A debugging message for a case I didn't realize was common!
I haven't had a chance to update it yet.

The kmalloc is a little worrysome though.
Are you creating really large files in shmfs?

ZC> But other than that, machine didn't crash, and shmfs is happily
ZC> running right now, while I'm writing this. :)

ZC> I decided to comment those "write_page..." messages, recompile kernel,
ZC> and finally do some benchmarking:

ZC> 2.1.108 + shmfs:

ZC>               -------Sequential Output-------- ---Sequential Input-- --Random--
ZC>               -Per Char- --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
ZC> Machine    MB K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU
ZC>           100  2611 90.7  3924 86.2  3201 13.3  4763 61.4  6736 24.4 143.7  4.0

ZC> Then I decided to apply my patch, which removes page aging etc...
ZC> (already sent to this list):

ZC>               -------Sequential Output-------- ---Sequential Input-- --Random--
ZC>               -Per Char- --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
ZC> Machine    MB K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU
ZC>           100  3023 99.5  4343 99.1  6342 26.3  7819 98.4 17860 64.0 156.4  3.6
ZC>                                                           ^^^^^      ^^^^^
ZC> Final result is great (almost 18MB/s, never saw such a big number in
ZC> bonnie :)).

I'm a little worried by the slow output that uses huge chunks of cpu time.
But it looks like I wrote my block allocation algorithm properly.

I have a lot of tuning options that can influence things, primarily
because it is development code and I'm not sure what the best approach
is.  Did you change any of them from their default?

ZC> Last experiment I did was to put entry in /etc/fstab so that shmfs get
ZC> mounted on /tmp at boot time. That indeed worked, but unfortunately, X
ZC> (or maybe fvwm?) refused to work after that change, for unknown reason
ZC> (nothing in logs).

Look at the permissions on /tmp.  But default only root can write to shmfs...
I should probably implement uid gid options to set the permissions of
the root directory but I haven't done that yet.

ZC> P166MMX, 64MB RAM
ZC> hda: WDC AC22000L, ATA DISK drive
ZC> sda: FUJITSU   Model: M2954ESP SUN4.2G  Rev: 2545 (aic7xxx)

ZC> shmfs                     /shm            shmfs   defaults   0       0
ZC> /dev/hda1                 none            swap    sw,pri=0   0       0
ZC> /dev/sda1                 none            swap    sw,pri=0   0       0

Interesting.  If I read this correctly you might have been getting
parrallel raid type read performance off of your two disks, on the
block read test.

ZC> Really good work, Eric!
ZC> I hope your code gets into official kernel, as soon as possible.

Thanks for the encouragement, but until I equal or better ext2 in all
marks the works not done :)

Eric

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
