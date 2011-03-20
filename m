Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EE2A08D0039
	for <linux-mm@kvack.org>; Sun, 20 Mar 2011 15:16:00 -0400 (EDT)
Received: by fxm18 with SMTP id 18so6435296fxm.14
        for <linux-mm@kvack.org>; Sun, 20 Mar 2011 12:15:56 -0700 (PDT)
Date: Mon, 21 Mar 2011 00:15:47 +0500
From: Mike Kazantsev <mk.fraggod@gmail.com>
Subject: kswapd0 thread 100% cpu usage with recent kernels
Message-ID: <20110321001547.5038fe7f@sacrilege>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/mdSeYNtB4rk4cWcUeP2yOum"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--Sig_/mdSeYNtB4rk4cWcUeP2yOum
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Good day,

I have a strange situation with "kswapd0" thread using 100% of one
cpu core, reproducable with (maybe specific) combination of CPU and I/O
load.

Recently I've updated OS (from old gentoo linux to exherbo linux) on
fairly low-spec mini-ITX machine and noticed a strange problem.

Machine was showing higher load averages than before and the top
process with highest cpu usage seem to be quite often kswapd0 kernel
thread.

Judging from atop and top utils' output, it seem to have 100% (one core,
or close to that) cpu usage and very high disk write activity.

atop:
  PID RUID     EUID      THR   SYSCPU  USRCPU  VGROW   RGROW  RDDSK  WRDSK =
 ST EXC S  CPUNR  CPU CMD
   38 root     root        1    9.49s   0.00s     0K      0K     0K 83280K =
 --   - R      2  95% kswapd0

top:
  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
   38 root      20   0     0    0    0 R   92  0.0 291:20.79 kswapd0

iotop:
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND
   38 be/4 root        0.00 B/s    5.06 M/s  0.00 %  0.00 % [kswapd0]


Activity doesn't seem to be swapping-out though, as swap is empty and
there's still enough RAM to go around:

  MEM | tot     1.9G | free   77.6M  | cache 462.1M | dirty   0.1M | buff  =
 10.3M |  slab  286.3M |
  SWP | tot     4.0G | free    4.0G  | vmcom   1.5G | vmlim   5.0G |

  ~# free
               total       used       free     shared    buffers     cached
  Mem:       2040412    1941784      98628          0      10580     454048
  -/+ buffers/cache:    1477156     563256
  Swap:      4194300        536    4193764

  ~# swapon -s
  Filename                                Type            Size    Used    P=
riority
  /dev/mapper/prime-swap                  partition       4194300 572     -1

Furthermore, these "disk writes" seem to be purely virtual, as neither
iostat nor atop show any writes to disks at the time kswapd0 works like
that.

Also, I've noticed that kswapd0 reproducibly acts like that when read
I/O activity is high (not 100% disk utilization, but about 60-70) in
the system along with some significant CPU load (about 100% of one
core), although I tend to think that latter is probably irrelevant.

And that's actually what drew my attention to it: trying to checksum a
lot of data from distributed fs (moosefs) with local chunkserver
resulted invariably in kswapd0 getting the first place in "top" output.

As I've mentioned, system in question is quite low-spec mini-ITX
platform featuring dualcore atom cpu with hyper threading and 2G of RAM
plus fairly slow sata (WD Green) disks, so "high I/O activity" here
means no more than 10 MBytes/s.

I'm observing this behavior now with 2.6.38 kernel (from kernel.org,
arch is x86_64), but I'm fairly sure I've seen this before with 2.6.37
and 2.6.37.3 releases.
Kernel .config file: http://goo.gl/Msk8I

To do something about it, I've tried to disable swap (swapoff), set
vm.swappiness to 0 (otherwise it's set to 20), lower
vm.vfs_cache_pressure to 20, raise vm.vfs_cache_pressure to 200.
None of these actions seemed to have any effect within a few minutes.
Checksumming processes I ran spanned for hours with kswapd0 being there
the whole time, while not consuming any resources before that and
becoming dormant again right after they were finished.

What can possibly result in such behavior of kswapd0?
Is there anything else I can tweak to lessen cpu usage of this thread?

I've found similar reports from much older kernels and indications that
the problem has been fixed since, but not much details to make sure if
it's the really the same problem or not.

Is there anything I can do to provide more info on the issue?

I'm afraid I'm not familiar with kernel debugging, but if anyone is
interested in finding out what's going on there and will point me to
the right tools, I'll be happy to provide any information I can get.

Will appreciate any advice or insight on that.
Thank you for your attention.


--=20
Mike Kazantsev // fraggod.net

--Sig_/mdSeYNtB4rk4cWcUeP2yOum
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEARECAAYFAk2GUmYACgkQASbOZpzyXnEZ/ACfduixiRGZeTjPPjTJW2MWe4hN
/lUAoMdlqWsm7EoV3ywH8KKBPy/yPLYu
=I6NA
-----END PGP SIGNATURE-----

--Sig_/mdSeYNtB4rk4cWcUeP2yOum--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
