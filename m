Received: from ripspost.aist.go.jp (ripspost.aist.go.jp [150.29.9.2])
	by kvack.org (8.8.7/8.8.7) with ESMTP id BAA03119
	for <linux-mm@kvack.ORG>; Thu, 28 Jan 1999 01:29:51 -0500
Date: Thu, 28 Jan 1999 15:23:06 +0900 (JST)
From: Tom Holroyd <tomh@taz.ccs.fau.edu>
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses 
In-Reply-To: <Pine.LNX.3.96.990128023440.8338A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990128151028.326A-100000@bhalpha1.nibh.go.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.COM>, Linus Torvalds <torvalds@transmeta.com>, linux-kernel@vger.RUTGERS.edu, werner@suse.de, mlord@pobox.com, "David S. Miller" <davem@dm.COBALTMICRO.COM>, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jan 1999, Andrea Arcangeli wrote:

>If you see a race in this my new patch, please let me know and probably
>you'll give me a good reason to reinsert mm_lock ;) 

I spoke too soon.  :(

With that latest patch I was still able to get lots of procs stuck in D,
but it was harder. ^_^;

I was playing with modules, trying to get it to hang that way (very
successful there).  At the end of one experiment there was no crash but
rather a lot of D procs.  Details:

Alpha PC164 (LX).  128M, egcs-1.1.1.

MSDOS configured as a module.  Stick a floppy in the floppy drive.

# mount -o remount,ro /home		; be safe
# mount -o remount,ro /usr
# mformat a:
# mount -t msdos /dev/fd0 /tmp/mnt

now /proc/modules contains:

msdos                  11600   1 (autoclean)
fat                    33656   1 (autoclean) [msdos]

Run this script:
---
#! /bin/sh

while true; do
	cp -av /usr/src/linux/arch/ppc /tmp/mnt/ppc
	ls -lR /tmp/mnt
	rm -rf /tmp/mnt/ppc
done
---

In another window, make MAKE="make -j5" dep.  Now normally, with msdos
as a module, this causes the machine to hang (alt-sysrq unresponsive)
after a few minutes (often after it has started to swap stuff out, but I'm
having trouble narrowing it down more than that).

This last time, I got D procs.  Again, this is with Andrea's latest patch.
Without that patch, the make dep is guaranteed to fail almost right away,
but with it I was able to do this about 4 times before it occured.

 1188  1175 root      1496   664 end       D     0.0  0.5   0:00 make
 1213  1183 root      1208   664 end       D     0.0  0.4   0:00 make
 1224  1177 root      1320   664 end       D     0.0  0.5   0:00 make
 1226  1177 root      1256   664 end       D     0.0  0.4   0:00 make
 1247  1190 root      1272   664 end       D     0.0  0.4   0:00 make

I'll try again with the earlier patch.

Dr. Tom Holroyd
I would dance and be merry,
Life would be a ding-a-derry,
If I only had a brain.
	-- The Scarecrow

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
