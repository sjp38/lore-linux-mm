Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA26991
	for <linux-mm@kvack.org>; Thu, 16 Jul 1998 18:03:39 -0400
Subject: Comments on shmfs-0.1.010
Reply-To: Zlatko.Calusic@CARNet.hr
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 17 Jul 1998 00:03:32 +0200
Message-ID: <87n2a9o3m3.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Eric Biederman <ebiederm+eric@npwt.net>
List-ID: <linux-mm.kvack.org>

Hi!

Today, I finally found some time to play with shmfs and I must admit
that I'm astonished with the results!

After some trouble with patching (lots of conflicts which had to be
resolved manually), to my complete surprise, shmfs proved to be quite
stable and reliable.

I found these messages in logs (after every boot):

swap_after_unlock_page: lock already cleared
Adding Swap: 128988k swap-space (priority 0)
swap_after_unlock_page: lock already cleared
Adding Swap: 128484k swap-space (priority 0)

and lots of these:

Jul 16 22:50:42 atlas kernel: write_page: called on a clean page! 
Jul 16 22:51:16 atlas last message repeated 612 times
Jul 16 22:51:29 atlas last message repeated 463 times
Jul 16 22:51:29 atlas kernel: kmalloc: Size (131076) too large 
Jul 16 22:51:30 atlas kernel: write_page: called on a clean page! 
Jul 16 22:51:30 atlas last message repeated 10 times
Jul 16 22:51:30 atlas kernel: kmalloc: Size (135172) too large 
Jul 16 22:51:30 atlas kernel: write_page: called on a clean page! 
Jul 16 22:51:30 atlas last message repeated 9 times
Jul 16 22:51:31 atlas kernel: kmalloc: Size (139268) too large 
etc...

But other than that, machine didn't crash, and shmfs is happily
running right now, while I'm writing this. :)

I decided to comment those "write_page..." messages, recompile kernel,
and finally do some benchmarking:

2.1.108 + shmfs:

              -------Sequential Output-------- ---Sequential Input-- --Random--
              -Per Char- --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
Machine    MB K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU
          100  2611 90.7  3924 86.2  3201 13.3  4763 61.4  6736 24.4 143.7  4.0

Then I decided to apply my patch, which removes page aging etc...
(already sent to this list):

              -------Sequential Output-------- ---Sequential Input-- --Random--
              -Per Char- --Block--- -Rewrite-- -Per Char- --Block--- --Seeks---
Machine    MB K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU K/sec %CPU  /sec %CPU
          100  3023 99.5  4343 99.1  6342 26.3  7819 98.4 17860 64.0 156.4  3.6
                                                          ^^^^^      ^^^^^
Final result is great (almost 18MB/s, never saw such a big number in
bonnie :)).

Last experiment I did was to put entry in /etc/fstab so that shmfs get
mounted on /tmp at boot time. That indeed worked, but unfortunately, X
(or maybe fvwm?) refused to work after that change, for unknown reason
(nothing in logs).

And that's it.

In the end, relevant info about my setup:

P166MMX, 64MB RAM
hda: WDC AC22000L, ATA DISK drive
sda: FUJITSU   Model: M2954ESP SUN4.2G  Rev: 2545 (aic7xxx)

shmfs                     /shm            shmfs   defaults   0       0
/dev/hda1                 none            swap    sw,pri=0   0       0
/dev/sda1                 none            swap    sw,pri=0   0       0

Really good work, Eric!
I hope your code gets into official kernel, as soon as possible.

Regards,
-- 
Posted by Zlatko Calusic           E-mail: <Zlatko.Calusic@CARNet.hr>
---------------------------------------------------------------------
  Any sufficiently advanced bug is indistinguishable from a feature.
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
