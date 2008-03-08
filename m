Message-ID: <47D23B7E.3020505@tuxrocks.com>
Date: Sat, 08 Mar 2008 01:08:46 -0600
From: Frank Sorenson <frank@tuxrocks.com>
MIME-Version: 1.0
Subject: Re: 2.6.25-rc4 OOMs itself dead on bootup
References: <47D02940.1030707@tuxrocks.com> <20080306184954.GA15492@elte.hu> <47D1971A.7070500@tuxrocks.com>
In-Reply-To: <47D1971A.7070500@tuxrocks.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>, kay.sievers@vrfy.org, Matt_Domsch@dell.com
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Frank Sorenson wrote:
> I did some additional debugging, and I believe you're correct about it
> being specific to my system.  The system seems to run fine until some
> time during the boot.  I booted with "init=/bin/sh" (that's how the
> system stayed up for 9 minutes), then it died when I tried starting
> things up.  I've further narrowed the OOM down to udev (though it's not
> entirely udev's fault, since 2.6.24 runs fine).
> 
> I ran your debug info tool before killing the box by running
> /sbin/start_udev.  The output of the tool is at
> http://tuxrocks.com/tmp/cfs-debug-info-2008.03.06-14.11.24
> 
> Something is apparently happening between 2.6.24 and 2.6.25-rc[34] which
> causes udev (or something it calls) to behave very badly.

Found it.  The culprit is 8f47f0b688bba7642dac4e979896e4692177670b
    dcdbas: add DMI-based module autloading

    DMI autoload dcdbas on all Dell systems.

    This looks for BIOS Vendor or System Vendor == Dell, so this should
    work for systems both Dell-branded and those Dell builds but brands
    for others.  It causes udev to load the dcdbas module at startup,
    which is used by tools called by HAL for wireless control and
    backlight control, among other uses.

What actually happens is that when udev loads the dcdbas module at
startup, modprobe apparently calls "modprobe dcdbas" itself, repeating
until the system runs out of resources (in this case, it OOMs).

# ps axf
...
  506 ?        S      0:00 /bin/bash /sbin/start_udev
  590 ?        S      0:00  \_ /sbin/udevsettle
  533 ?        S<s    0:00 /sbin/udevd -d
  629 ?        S<     0:00  \_ /sbin/udevd -d
  630 ?        S<     0:00  |   \_ /sbin/modprobe
dmi:bvnDellInc.:bvrA08:bd04/02/2007:svnDellInc.:pnMP061:pvr:rvnDellInc.:rn0YD479:rvr:cvnDellInc.:ct8:cvr:
  949 ?        S<     0:00  |       \_ /sbin/modprobe dcdbas
  950 ?        S<     0:00  |           \_ /sbin/modprobe dcdbas
  951 ?        S<     0:00  |               \_ /sbin/modprobe dcdbas
  953 ?        S<     0:00  |                   \_ /sbin/modprobe dcdbas
  955 ?        S<     0:00  |                       \_ /sbin/modprobe dcdbas
  958 ?        S<     0:00  |                           \_
/sbin/modprobe dcdbas
...repeat...

When the system crashed, there were at least 11,600 instances of
"/sbin/modprobe dcdbas", each calling the next.

Reverting 8f47f0b lets the system boot up just fine again.  Note that a
manual "modprobe dcdbas" also causes this recursive behavior, it's just
not forced on the system by udev.

So dcdbas is a regression from 2.6.24, as well as being broken in other
ways.

Frank
- --
Frank Sorenson - KD7TZK
Linux Systems Engineer, DSS Engineering, UBS AG
frank@tuxrocks.com

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD8DBQFH0jt7aI0dwg4A47wRAuXtAJ9kAXuT3hRCw8KJqs1e4SIwzXDYFACgqR8Q
gwV6NcjPq5x6Nt16V7Z/eVc=
=0rIk
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
