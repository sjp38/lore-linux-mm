Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 00D8890010C
	for <linux-mm@kvack.org>; Sun,  1 May 2011 20:26:59 -0400 (EDT)
Subject: mmotm 2011-04-29 - wonky VmRSS and VmHWM values after swapping
In-Reply-To: Your message of "Fri, 29 Apr 2011 16:26:16 PDT."
             <201104300002.p3U02Ma2026266@imap1.linux-foundation.org>
From: Valdis.Kletnieks@vt.edu
References: <201104300002.p3U02Ma2026266@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1304296014_6647P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Sun, 01 May 2011 20:26:54 -0400
Message-ID: <49683.1304296014@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

--==_Exmh_1304296014_6647P
Content-Type: text/plain; charset=us-ascii

On Fri, 29 Apr 2011 16:26:16 PDT, akpm@linux-foundation.org said:
> The mm-of-the-moment snapshot 2011-04-29-16-25 has been uploaded to
> 
>    http://userweb.kernel.org/~akpm/mmotm/
 
Dell Latitude E6500 laptop, Core2 Due P8700, 4G RAM, 2G swap.Z86_64 kernel.

I was running a backup of the system to an external USB hard drive.  Source and
target filesystems were ext4 on LVM on a LUKS encrypted partition.  Same backup
script to same destination drive worked fine a few days ago on a -rc1-mmotm0331
kernel.

System ran out of RAM, and went about 50M into the 2G of swap. Not sure why *that*
happened, as previously the backup script didn't cause any swapping.  After that, the
VmRSS and VmHWM values were corrupted for some 20 processes, including systemd,
the X server, pidgin, firefox, rsyslogd

Nothing notable in dmesg output, Nothing noted by abrtd, no processes crashed
or misbehaving that I can tell.  Just wonky numbers.

top says:

Tasks: 186 total,   3 running, 183 sleeping,   0 stopped,   0 zombie
Cpu(s):  9.1%us,  9.1%sy,  0.0%ni, 74.8%id,  6.7%wa,  0.0%hi,  0.2%si,  0.0%st
Mem:   4028664k total,  3839128k used,   189536k free,  1728880k buffers
Swap:  2097148k total,    52492k used,  2044656k free,  1081528k cached

   PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND          
 47720 root      20   0     0    0    0 R 17.6  0.0   0:21.64 kworker/0:0       
 47453 root      20   0     0    0    0 D 13.7  0.0   0:36.10 kworker/1:3       
 26854 root      20   0     0    0    0 R  3.9  0.0   1:02.24 usb-storage       
 46917 root      20   0 18192    ?  208 D  3.9 457887369396224.0   4:18.50 dump 
 46918 root      20   0 18192    ?  208 S  3.9 457887369396224.0   4:18.38 dump 
 46919 root      20   0 18192    ?  208 D  3.9 457887369396224.0   4:18.48 dump 
     3 root      20   0     0    0    0 S  2.0  0.0   0:29.20 ksoftirqd/0       
    13 root      20   0     0    0    0 S  2.0  0.0   0:29.13 ksoftirqd/1       
  5467 root      20   0 12848  448  168 S  2.0  0.0  30:59.25 eTSrv             
  5655 root      20   0  178m    ?    ? S  2.0 457887369396224.0  89:18.03 Xorg 
  6079 valdis    20   0  347m 3936 5440 S  2.0  0.1  31:17.23 gkrellm           
  6479 valdis    20   0 1251m    ?    ? S  2.0 457887369396224.0  46:33.43 firef
 46916 root      20   0 22296 2708  328 S  2.0  0.1   0:39.38 dump              
 48406 root      20   0     0    0    0 S  2.0  0.0   0:00.06 kworker/1:1       
     1 root      20   0 72228    ?  924 S  0.0 457887369396224.0   0:06.69 syste

grep ^Vm /proc/5655/status (the X server)

VmPeak:   215788 kB
VmSize:   182440 kB
VmLck:         0 kB
VmHWM:  18446744073709544032 kB
VmRSS:  18446744073408330104 kB
VmData:    67688 kB
VmStk:       288 kB
VmExe:      1824 kB
VmLib:     37800 kB
VmPTE:       308 kB
VmSwap:        0 kB

Probably noteworth - the HWM in hex is FFFFFFFFFFFFE260,  and
similarly for VmRSS.  Looks like an underflow someplace?

It ended up hitting a bunch of processes:

grep 184467 /proc/*/status
/proc/1/status:VmHWM:   18446744073709551612 kB
/proc/1/status:VmRSS:   18446744073709550072 kB
/proc/26902/status:VmHWM:       18446744073709548820 kB
/proc/26902/status:VmRSS:       18446744073709547948 kB
/proc/27079/status:VmHWM:       18446744073709546764 kB
/proc/27079/status:VmRSS:       18446744073709382820 kB
/proc/28359/status:VmHWM:       18446744073709550700 kB
/proc/28359/status:VmRSS:       18446744073709510496 kB
/proc/42136/status:VmHWM:       18446744073709550528 kB
/proc/42136/status:VmRSS:       18446744073709549656 kB
/proc/46917/status:VmHWM:       18446744073709551568 kB
/proc/46917/status:VmRSS:       18446744073640042856 kB
/proc/46918/status:VmHWM:       18446744073709551568 kB
/proc/46918/status:VmRSS:       18446744073640042056 kB
/proc/46919/status:VmHWM:       18446744073709551568 kB
/proc/46919/status:VmRSS:       18446744073640037512 kB
/proc/4742/status:VmHWM:        18446744073709550144 kB
/proc/4742/status:VmRSS:        18446744073709549520 kB
/proc/4821/status:VmHWM:        18446744073709519576 kB
/proc/4821/status:VmRSS:        18446744073709519428 kB
/proc/5412/status:VmHWM:        18446744073709547064 kB
/proc/5412/status:VmRSS:        18446744073709546976 kB
/proc/5641/status:VmHWM:        18446744073709027168 kB
/proc/5641/status:VmRSS:        18446744073708532364 kB
/proc/5655/status:VmHWM:        18446744073709544032 kB
/proc/5655/status:VmRSS:        18446744073407790088 kB
/proc/5856/status:VmHWM:        18446744073709550760 kB
/proc/5856/status:VmRSS:        18446744073708844568 kB
/proc/5997/status:VmHWM:        18446744073709308884 kB
/proc/5997/status:VmRSS:        18446744073411781076 kB
/proc/6306/status:VmHWM:        18446744073709546960 kB
/proc/6306/status:VmRSS:        18446744073709425144 kB
/proc/6416/status:VmHWM:        18446744073709532884 kB
/proc/6416/status:VmRSS:        18446744073706032272 kB
/proc/6446/status:VmHWM:        18446744073709534900 kB
/proc/6446/status:VmRSS:        18446744073709527604 kB
/proc/6479/status:VmHWM:        18446744073709547196 kB
/proc/6479/status:VmRSS:        18446744073654889656 kB
/proc/6555/status:VmHWM:        18446744073709551612 kB
/proc/6555/status:VmRSS:        18446744073709526840 kB
/proc/6647/status:VmHWM:        18446744073709549680 kB
/proc/6647/status:VmRSS:        18446744073685279348 kB

Any ideas?  The backup has finished, but the corrupted values are hanging around.
Not sure if it's repeatable.

--==_Exmh_1304296014_6647P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNvfpOcC3lWbTT17ARAgaaAKDIc7ayhS+I6jnyxq5Fm6xexmrhQwCfQFcn
utWYwwI+yUGPPy1LqgNAoC0=
=RqjZ
-----END PGP SIGNATURE-----

--==_Exmh_1304296014_6647P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
