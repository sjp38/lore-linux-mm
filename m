Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 037DC8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 17:10:35 -0400 (EDT)
Date: Mon, 25 Apr 2011 23:10:16 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110425231016.34b4293e@neptune.home>
In-Reply-To: <20110425191607.GL2468@linux.vnet.ibm.com>
References: <20110424235928.71af51e0@neptune.home>
	<20110425114429.266A.A69D9226@jp.fujitsu.com>
	<BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
	<20110425111705.786ef0c5@neptune.home>
	<BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
	<20110425180450.1ede0845@neptune.home>
	<BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
	<20110425190032.7904c95d@neptune.home>
	<BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com>
	<20110425203606.4e78246c@neptune.home>
	<20110425191607.GL2468@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/V_HaME=lljP0azEEVHMWr2P"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

--MP_/V_HaME=lljP0azEEVHMWr2P
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Mon, 25 April 2011 "Paul E. McKenney" wrote:
> On Mon, Apr 25, 2011 at 08:36:06PM +0200, Bruno Pr=C3=A9mont wrote:
> > On Mon, 25 April 2011 Linus Torvalds wrote:
> > > On Mon, Apr 25, 2011 at 10:00 AM, Bruno Pr=C3=A9mont wrote:
> > > >
> > > > I hope tiny-rcu is not that broken... as it would mean driving any
> > > > PREEMPT_NONE or PREEMPT_VOLUNTARY system out of memory when compili=
ng
> > > > packages (and probably also just unpacking larger tarballs or runni=
ng
> > > > things like du).
> > >=20
> > > I'm sure that TINYRCU can be fixed if it really is the problem.
> > >=20
> > > So I just want to make sure that we know what the root cause of your
> > > problem is. It's quite possible that it _is_ a real leak of filp or
> > > something, but before possibly wasting time trying to figure that out,
> > > let's see if your config is to blame.
> >=20
> > With changed config (PREEMPT=3Dy, TREE_PREEMPT_RCU=3Dy) I haven't repro=
duced
> > yet.
> >=20
> > When I was reproducing with TINYRCU things went normally for some time
> > until suddenly slabs stopped being freed.
>=20
> Hmmm... If the system is responsive during this time, could you please
> do the following after the slabs stop being freed?
>=20
> ps -eo pid,class,sched,rtprio,stat,state,sgi_p,cpu_time,cmd | grep '\[rcu'

Looks like tinyrcu is not innocent (or at least it makes bug appear much
more easily)

With + + TREE_PREMPT_RCU system was stable compiling for over 2 hours,
switching to TINY_RCU, filp count started increasing pretty early after beg=
inning
compiling.

All the relevant information attached (PREEMPT+TINY_RCU):
  config.gz
  ps auxf     |
  slabinfo    |  twice, once early (1-*), the second 30 minutes later (2-*)
  meminfo     |

ls -l proc/*/fd produces 658 lines for the 1-* series of numbers, 300 for 2=
-*.

In both cases=20
   ps -eo pid,class,sched,rtprio,stat,state,sgi_p,cputime,cmd | grep '\[rcu'
returns the same information:
      6 FF    1      1 R    R 0 00:00:00 [rcu_kthread]


according to slabtop filp count is increasing permanentally, (about +1000
every 3 seconds) probably because of top (1s refresh rate) and collectd (10s
rate) scanning /proc (without top, increasing by about 300 every 10s).

Running something like `for ((X=3D0; X < 200; X++)); do /bin/true; done` ca=
uses
count of pid, task_struct, signal_cache slab count to increase by about 200,
but no zombies are being left behind.

1-*  Taken a few minutes after starting compile process, but after having
     SIGSTOPed the compiling process tree
2-*  about 30 minutes later, killed compile process tree, run above for loop
     multiple times, close most terminal sessions (including top)

Between 1-slabinfo and 2-slabinfo some values increased (a lot) while a few
ones did decrease. Don't know which ones are RCU-affected and which ones are
not.

Bruno

--MP_/V_HaME=lljP0azEEVHMWr2P
Content-Type: application/x-gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=config.gz

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

--MP_/V_HaME=lljP0azEEVHMWr2P
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename=1-meminfo

MemTotal:         480420 kB
MemFree:          175180 kB
Buffers:           37604 kB
Cached:            30436 kB
SwapCached:          128 kB
Active:            97532 kB
Inactive:          77776 kB
Active(anon):      51012 kB
Inactive(anon):    55480 kB
Active(file):      46520 kB
Inactive(file):    22296 kB
Unevictable:          32 kB
Mlocked:              32 kB
SwapTotal:        524284 kB
SwapFree:         524156 kB
Dirty:                16 kB
Writeback:             0 kB
AnonPages:        106300 kB
Mapped:            12732 kB
Shmem:               112 kB
Slab:              67580 kB
SReclaimable:      18596 kB
SUnreclaim:        48984 kB
KernelStack:       56352 kB
PageTables:         1344 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:      764492 kB
Committed_AS:     173588 kB
VmallocTotal:     548548 kB
VmallocUsed:        8392 kB
VmallocChunk:     534328 kB
AnonHugePages:         0 kB
DirectMap4k:       16320 kB
DirectMap4M:      475136 kB

--MP_/V_HaME=lljP0azEEVHMWr2P
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename=1-ps_auxf

USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         2  0.0  0.0      0     0 ?        S    22:14   0:00 [kthreadd]
root         3  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [ksoftirqd/0]
root         6  0.1  0.0      0     0 ?        R    22:14   0:00  \_ [rcu_kthread]
root         7  0.0  0.0      0     0 ?        R    22:14   0:00  \_ [watchdog/0]
root         8  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [khelper]
root       138  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [sync_supers]
root       140  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [bdi-default]
root       142  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [kblockd]
root       230  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [ata_sff]
root       237  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [khubd]
root       365  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [kswapd0]
root       464  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [fsnotify_mark]
root       486  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfs_mru_cache]
root       489  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfslogd]
root       490  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfsdatad]
root       491  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfsconvertd]
root       554  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scsi_eh_0]
root       559  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scsi_eh_1]
root       573  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scsi_eh_2]
root       576  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scsi_eh_3]
root       579  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [kworker/u:4]
root       580  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [kworker/u:5]
root       589  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scsi_eh_4]
root       592  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scsi_eh_5]
root       655  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [kpsmoused]
root       706  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [reiserfs]
root      1485  0.1  0.0      0     0 ?        S    22:14   0:01  \_ [kworker/0:3]
root      1486  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [flush-8:0]
root      1692  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [rpciod]
root      1693  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [nfsiod]
root      1697  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [lockd]
root     26248  0.0  0.0      0     0 ?        S    22:21   0:00  \_ [kworker/0:2]
root     26445  0.0  0.0      0     0 ?        S    22:21   0:00  \_ [kworker/0:4]
root         1  0.3  0.1   1740   588 ?        Ss   22:14   0:02 init [3]  
root       823  0.0  0.1   2132   824 ?        S<s  22:14   0:00 /sbin/udevd --daemon
root      1778  0.0  0.1   2128   696 ?        S<   22:15   0:00  \_ /sbin/udevd --daemon
root      1377  0.0  0.3   4876  1780 tty2     Ss   22:14   0:00 -bash
root      3692  0.1  0.2   2276   988 tty2     S+   22:18   0:00  \_ slabtop
root      1378  0.0  0.3   4876  1768 tty3     Ss+  22:14   0:00 -bash
root      1781  1.4  6.1  34372 29736 tty3     TN   22:16   0:08  \_ /usr/bin/python2.7 /usr/bin/emerge --oneshot gimp
portage  15556  0.0  0.5   5924  2696 tty3     TN   22:19   0:00      \_ /bin/bash /usr/lib/portage/bin/ebuild.sh compile
portage  15655  0.0  0.4   6060  2200 tty3     TN   22:19   0:00          \_ /bin/bash /usr/lib/portage/bin/ebuild.sh compile
portage  15662  0.0  0.3   4880  1560 tty3     TN   22:19   0:00              \_ /bin/bash /usr/lib/portage/bin/ebuild-helpers/emake
portage  15667  0.0  0.1   3860   960 tty3     TN   22:19   0:00                  \_ make -j2
portage  15668  0.0  0.2   3864   992 tty3     TN   22:19   0:00                      \_ make all-recursive
portage  15669  0.0  0.2   4752  1420 tty3     TN   22:19   0:00                          \_ /bin/sh -c fail= failcom='exit 1'; \?for f in x $MAKEFLAGS; do \?  case $f in \?    *=* | --[!k]*);; \?    *k*) failcom='fail=yes';; \?  esac; \?done; \?dot_seen=no; \?target=`echo all-recursive | sed s/-recursive//`; \?list='m4macros tools cursors themes po po-libgimp po-plug-ins po-python po-script-fu po-tips data desktop menus libgimpbase libgimpcolor libgimpmath libgimpconfig libgimpmodule libgimpthumb libgimpwidgets libgimp app modules plug-ins etc devel-docs docs'; for subdir in $list; do \?  echo "Making $target in $subdir"; \?  if test "$subdir" = "."; then \?    dot_seen=yes; \?    local_target="$target-am"; \?  else \?    local_target="$target"; \?  fi; \?  (CDPATH="${ZSH_VERSION+.}:" && cd $subdir && make  $local_target) \?  || eval $failcom; \?done; \?if test "$dot_seen" = "no"; then \?  make  "$target-am" || exit 1; \?fi; test -z "$fail"
portage  31137  0.0  0.1   4752   740 tty3     TN   22:22   0:00                              \_ /bin/sh -c fail= failcom='exit 1'; \?for f in x $MAKEFLAGS; do \?  case $f in \?    *=* | --[!k]*);; \?    *k*) failcom='fail=yes';; \?  esac; \?done; \?dot_seen=no; \?target=`echo all-recursive | sed s/-recursive//`; \?list='m4macros tools cursors themes po po-libgimp po-plug-ins po-python po-script-fu po-tips data desktop menus libgimpbase libgimpcolor libgimpmath libgimpconfig libgimpmodule libgimpthumb libgimpwidgets libgimp app modules plug-ins etc devel-docs docs'; for subdir in $list; do \?  echo "Making $target in $subdir"; \?  if test "$subdir" = "."; then \?    dot_seen=yes; \?    local_target="$target-am"; \?  else \?    local_target="$target"; \?  fi; \?  (CDPATH="${ZSH_VERSION+.}:" && cd $subdir && make  $local_target) \?  || eval $failcom; \?done; \?if test "$dot_seen" = "no"; then \?  make  "$target-am" || exit 1; \?fi; test -z "$fail"
portage  31138  0.0  0.2   3992  1164 tty3     TN   22:22   0:00                                  \_ make all
portage    601  0.0  0.3   5012  1676 tty3     TN   22:22   0:00                                      \_ /bin/sh ../libtool --tag=CC --mode=compile i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I.. -I.. -pthread -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng14 -I/usr/include/libdrm -I/usr/include -DG_LOG_DOMAIN="LibGimpWidgets" -DGIMP_DISABLE_DEPRECATED -DGDK_MULTIHEAD_SAFE -DGTK_MULTIHEAD_SAFE -O2 -march=athlon-xp -pipe -Wall -Wdeclaration-after-statement -Wmissing-prototypes -Wmissing-declarations -Winit-self -Wpointer-arith -Wold-style-definition -MT gimpcolordisplaystack.lo -MD -MP -MF .deps/gimpcolordisplaystack.Tpo -c -o gimpcolordisplaystack.lo gimpcolordisplaystack.c
portage    616  0.0  0.1   1924   536 tty3     TN   22:22   0:00                                      |   \_ /usr/i686-pc-linux-gnu/gcc-bin/4.4.5/i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I.. -I.. -pthread -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng14 -I/usr/include/libdrm -I/usr/include -DG_LOG_DOMAIN="LibGimpWidgets" -DGIMP_DISABLE_DEPRECATED -DGDK_MULTIHEAD_SAFE -DGTK_MULTIHEAD_SAFE -O2 -march=athlon-xp -pipe -Wall -Wdeclaration-after-statement -Wmissing-prototypes -Wmissing-declarations -Winit-self -Wpointer-arith -Wold-style-definition -MT gimpcolordisplaystack.lo -MD -MP -MF .deps/gimpcolordisplaystack.Tpo -c gimpcolordisplaystack.c -fPIC -DPIC -o .libs/gimpcolordisplaystack.o
portage    617  0.4  4.5  27296 21728 tty3     TN   22:22   0:00                                      |       \_ /usr/libexec/gcc/i686-pc-linux-gnu/4.4.5/cc1 -quiet -I. -I.. -I.. -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng14 -I/usr/include/libdrm -I/usr/include -MD .libs/gimpcolordisplaystack.d -MF .deps/gimpcolordisplaystack.Tpo -MP -MT gimpcolordisplaystack.lo -D_REENTRANT -DHAVE_CONFIG_H -DG_LOG_DOMAIN="LibGimpWidgets" -DGIMP_DISABLE_DEPRECATED -DGDK_MULTIHEAD_SAFE -DGTK_MULTIHEAD_SAFE -DPIC gimpcolordisplaystack.c -D_FORTIFY_SOURCE=2 -quiet -dumpbase gimpcolordisplaystack.c -march=athlon-xp -auxbase-strip .libs/gimpcolordisplaystack.o -O2 -Wall -Wdeclaration-after-statement -Wmissing-prototypes -Wmissing-declarations -Winit-self -Wpointer-arith -Wo
 ld-style-definition -fPIC -o -
portage    619  0.0  0.6   5284  3128 tty3     TN   22:22   0:00                                      |       \_ /usr/lib/gcc/i686-pc-linux-gnu/4.4.5/../../../../i686-pc-linux-gnu/bin/as -Qy -o .libs/gimpcolordisplaystack.o -
portage    632  0.0  0.3   5012  1672 tty3     TN   22:22   0:00                                      \_ /bin/sh ../libtool --tag=CC --mode=compile i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I.. -I.. -pthread -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng14 -I/usr/include/libdrm -I/usr/include -DG_LOG_DOMAIN="LibGimpWidgets" -DGIMP_DISABLE_DEPRECATED -DGDK_MULTIHEAD_SAFE -DGTK_MULTIHEAD_SAFE -O2 -march=athlon-xp -pipe -Wall -Wdeclaration-after-statement -Wmissing-prototypes -Wmissing-declarations -Winit-self -Wpointer-arith -Wold-style-definition -MT gimpenumwidgets.lo -MD -MP -MF .deps/gimpenumwidgets.Tpo -c -o gimpenumwidgets.lo gimpenumwidgets.c
portage    647  0.0  0.1   1924   536 tty3     TN   22:22   0:00                                          \_ /usr/i686-pc-linux-gnu/gcc-bin/4.4.5/i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I.. -I.. -pthread -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng14 -I/usr/include/libdrm -I/usr/include -DG_LOG_DOMAIN="LibGimpWidgets" -DGIMP_DISABLE_DEPRECATED -DGDK_MULTIHEAD_SAFE -DGTK_MULTIHEAD_SAFE -O2 -march=athlon-xp -pipe -Wall -Wdeclaration-after-statement -Wmissing-prototypes -Wmissing-declarations -Winit-self -Wpointer-arith -Wold-style-definition -MT gimpenumwidgets.lo -MD -MP -MF .deps/gimpenumwidgets.Tpo -c gimpenumwidgets.c -fPIC -DPIC -o .libs/gimpenumwidgets.o
portage    648  0.1  2.3  19448 11284 tty3     TN   22:22   0:00                                              \_ /usr/libexec/gcc/i686-pc-linux-gnu/4.4.5/cc1 -quiet -I. -I.. -I.. -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libpng14 -I/usr/include/libdrm -I/usr/include -MD .libs/gimpenumwidgets.d -MF .deps/gimpenumwidgets.Tpo -MP -MT gimpenumwidgets.lo -D_REENTRANT -DHAVE_CONFIG_H -DG_LOG_DOMAIN="LibGimpWidgets" -DGIMP_DISABLE_DEPRECATED -DGDK_MULTIHEAD_SAFE -DGTK_MULTIHEAD_SAFE -DPIC gimpenumwidgets.c -D_FORTIFY_SOURCE=2 -quiet -dumpbase gimpenumwidgets.c -march=athlon-xp -auxbase-strip .libs/gimpenumwidgets.o -O2 -Wall -Wdeclaration-after-statement -Wmissing-prototypes -Wmissing-declarations -Winit-self -Wpointer-arith -Wold-style-definition -fPIC -o -
portage    649  0.0  0.6   5284  3116 tty3     TN   22:22   0:00                                              \_ /usr/lib/gcc/i686-pc-linux-gnu/4.4.5/../../../../i686-pc-linux-gnu/bin/as -Qy -o .libs/gimpenumwidgets.o -
root      1379  0.0  0.3   4876  1728 tty4     Ss+  22:14   0:00 -bash
root      4015  1.2  6.1  34176 29364 tty4     TN   22:18   0:06  \_ /usr/bin/python2.7 /usr/bin/emerge --oneshot libetpan
portage   7306  0.0  0.3   5136  1864 tty4     TN   22:18   0:00      \_ /bin/bash /usr/lib/portage/bin/ebuild.sh compile
portage   7463  0.0  0.5   6132  2460 tty4     TN   22:18   0:00          \_ /bin/bash /usr/lib/portage/bin/ebuild.sh compile
portage  19334  0.0  0.3   4876  1556 tty4     TN   22:19   0:00              \_ /bin/bash /usr/lib/portage/bin/ebuild-helpers/emake
portage  19339  0.0  0.2   3848  1032 tty4     TN   22:19   0:00                  \_ make -j2
portage  19736  0.0  0.2   3860   972 tty4     TN   22:19   0:00                      \_ make all-recursive
portage  19737  0.0  0.2   4748  1404 tty4     TN   22:19   0:00                          \_ /bin/sh -c failcom='exit 1'; \?for f in x $MAKEFLAGS; do \?  case $f in \?    *=* | --[!k]*);; \?    *k*) failcom='fail=yes';; \?  esac; \?done; \?dot_seen=no; \?target=`echo all-recursive | sed s/-recursive//`; \?list='build-windows include src tests doc'; for subdir in $list; do \?  echo "Making $target in $subdir"; \?  if test "$subdir" = "."; then \?    dot_seen=yes; \?    local_target="$target-am"; \?  else \?    local_target="$target"; \?  fi; \?  (cd $subdir && make  $local_target) \?  || eval $failcom; \?done; \?if test "$dot_seen" = "no"; then \?  make  "$target-am" || exit 1; \?fi; test -z "$fail"
portage  19747  0.0  0.1   4748   696 tty4     TN   22:19   0:00                              \_ /bin/sh -c failcom='exit 1'; \?for f in x $MAKEFLAGS; do \?  case $f in \?    *=* | --[!k]*);; \?    *k*) failcom='fail=yes';; \?  esac; \?done; \?dot_seen=no; \?target=`echo all-recursive | sed s/-recursive//`; \?list='build-windows include src tests doc'; for subdir in $list; do \?  echo "Making $target in $subdir"; \?  if test "$subdir" = "."; then \?    dot_seen=yes; \?    local_target="$target-am"; \?  else \?    local_target="$target"; \?  fi; \?  (cd $subdir && make  $local_target) \?  || eval $failcom; \?done; \?if test "$dot_seen" = "no"; then \?  make  "$target-am" || exit 1; \?fi; test -z "$fail"
portage  19748  0.0  0.2   3848  1052 tty4     TN   22:19   0:00                                  \_ make all
portage  19749  0.0  0.2   3848   980 tty4     TN   22:19   0:00                                      \_ make all-recursive
portage  19750  0.0  0.2   4748  1404 tty4     TN   22:19   0:00                                          \_ /bin/sh -c failcom='exit 1'; \?for f in x $MAKEFLAGS; do \?  case $f in \?    *=* | --[!k]*);; \?    *k*) failcom='fail=yes';; \?  esac; \?done; \?dot_seen=no; \?target=`echo all-recursive | sed s/-recursive//`; \?list='bsd  data-types low-level driver main engine'; for subdir in $list; do \?  echo "Making $target in $subdir"; \?  if test "$subdir" = "."; then \?    dot_seen=yes; \?    local_target="$target-am"; \?  else \?    local_target="$target"; \?  fi; \?  (cd $subdir && make  $local_target) \?  || eval $failcom; \?done; \?if test "$dot_seen" = "no"; then \?  make  "$target-am" || exit 1; \?fi; test -z "$fail"
portage  23219  0.0  0.1   4748   696 tty4     TN   22:20   0:00                                              \_ /bin/sh -c failcom='exit 1'; \?for f in x $MAKEFLAGS; do \?  case $f in \?    *=* | --[!k]*);; \?    *k*) failcom='fail=yes';; \?  esac; \?done; \?dot_seen=no; \?target=`echo all-recursive | sed s/-recursive//`; \?list='bsd  data-types low-level driver main engine'; for subdir in $list; do \?  echo "Making $target in $subdir"; \?  if test "$subdir" = "."; then \?    dot_seen=yes; \?    local_target="$target-am"; \?  else \?    local_target="$target"; \?  fi; \?  (cd $subdir && make  $local_target) \?  || eval $failcom; \?done; \?if test "$dot_seen" = "no"; then \?  make  "$target-am" || exit 1; \?fi; test -z "$fail"
portage  23220  0.0  0.2   3840  1040 tty4     TN   22:20   0:00                                                  \_ make all
portage  23225  0.0  0.2   3860   968 tty4     TN   22:20   0:00                                                      \_ make all-recursive
portage  23227  0.0  0.2   4748  1404 tty4     TN   22:20   0:00                                                          \_ /bin/sh -c failcom='exit 1'; \?for f in x $MAKEFLAGS; do \?  case $f in \?    *=* | --[!k]*);; \?    *k*) failcom='fail=yes';; \?  esac; \?done; \?dot_seen=no; \?target=`echo all-recursive | sed s/-recursive//`; \?list='imap imf maildir mbox mh mime nntp pop3 smtp feed'; for subdir in $list; do \?  echo "Making $target in $subdir"; \?  if test "$subdir" = "."; then \?    dot_seen=yes; \?    local_target="$target-am"; \?  else \?    local_target="$target"; \?  fi; \?  (cd $subdir && make  $local_target) \?  || eval $failcom; \?done; \?if test "$dot_seen" = "no"; then \?  make  "$target-am" || exit 1; \?fi; test -z "$fail"
portage    337  0.0  0.1   4748   696 tty4     TN   22:22   0:00                                                              \_ /bin/sh -c failcom='exit 1'; \?for f in x $MAKEFLAGS; do \?  case $f in \?    *=* | --[!k]*);; \?    *k*) failcom='fail=yes';; \?  esac; \?done; \?dot_seen=no; \?target=`echo all-recursive | sed s/-recursive//`; \?list='imap imf maildir mbox mh mime nntp pop3 smtp feed'; for subdir in $list; do \?  echo "Making $target in $subdir"; \?  if test "$subdir" = "."; then \?    dot_seen=yes; \?    local_target="$target-am"; \?  else \?    local_target="$target"; \?  fi; \?  (cd $subdir && make  $local_target) \?  || eval $failcom; \?done; \?if test "$dot_seen" = "no"; then \?  make  "$target-am" || exit 1; \?fi; test -z "$fail"
portage    338  0.0  0.2   3944  1064 tty4     TN   22:22   0:00                                                                  \_ make all
portage    342  0.0  0.2   3844  1004 tty4     TN   22:22   0:00                                                                      \_ make all-am
portage    653  0.0  0.4   5532  2176 tty4     TN   22:22   0:00                                                                          \_ /bin/sh ../../../libtool --tag=CC --mode=compile i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I../../.. -I../../../include -I../../../src/low-level/imf -I../../../src/data-types -DDEBUG -D_REENTRANT -O2 -march=athlon-xp -pipe -O2 -g -W -Wall -MT mailmime_content.lo -MD -MP -MF .deps/mailmime_content.Tpo -c -o mailmime_content.lo mailmime_content.c
portage    927  0.0  0.1   1920   532 tty4     TN   22:22   0:00                                                                          |   \_ /usr/i686-pc-linux-gnu/gcc-bin/4.4.5/i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I../../.. -I../../../include -I../../../src/low-level/imf -I../../../src/data-types -DDEBUG -D_REENTRANT -O2 -march=athlon-xp -pipe -O2 -g -W -Wall -MT mailmime_content.lo -MD -MP -MF .deps/mailmime_content.Tpo -c mailmime_content.c -o mailmime_content.o
portage    930  0.0  0.7  11692  3620 tty4     TN   22:22   0:00                                                                          |       \_ /usr/libexec/gcc/i686-pc-linux-gnu/4.4.5/cc1 -quiet -I. -I../../.. -I../../../include -I../../../src/low-level/imf -I../../../src/data-types -MD mailmime_content.d -MF .deps/mailmime_content.Tpo -MP -MT mailmime_content.lo -DHAVE_CONFIG_H -DDEBUG -D_REENTRANT mailmime_content.c -D_FORTIFY_SOURCE=2 -quiet -dumpbase mailmime_content.c -march=athlon-xp -auxbase-strip mailmime_content.o -g -O2 -O2 -W -Wall -o -
portage    932  0.0  0.6   5280  3108 tty4     TN   22:22   0:00                                                                          |       \_ /usr/lib/gcc/i686-pc-linux-gnu/4.4.5/../../../../i686-pc-linux-gnu/bin/as -Qy -o mailmime_content.o -
portage    891  0.0  0.4   5400  2156 tty4     TN   22:22   0:00                                                                          \_ /bin/sh ../../../libtool --tag=CC --mode=compile i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I../../.. -I../../../include -I../../../src/low-level/imf -I../../../src/data-types -DDEBUG -D_REENTRANT -O2 -march=athlon-xp -pipe -O2 -g -W -Wall -MT mailmime_disposition.lo -MD -MP -MF .deps/mailmime_disposition.Tpo -c -o mailmime_disposition.lo mailmime_disposition.c
portage    938  0.0  0.2   5400  1244 tty4     TN   22:22   0:00                                                                              \_ /bin/sh ../../../libtool --tag=CC --mode=compile i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I../../.. -I../../../include -I../../../src/low-level/imf -I../../../src/data-types -DDEBUG -D_REENTRANT -O2 -march=athlon-xp -pipe -O2 -g -W -Wall -MT mailmime_disposition.lo -MD -MP -MF .deps/mailmime_disposition.Tpo -c -o mailmime_disposition.lo mailmime_disposition.c
portage    939  0.0  0.1   5400   944 tty4     TN   22:22   0:00                                                                                  \_ /bin/sh ../../../libtool --tag=CC --mode=compile i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I../../.. -I../../../include -I../../../src/low-level/imf -I../../../src/data-types -DDEBUG -D_REENTRANT -O2 -march=athlon-xp -pipe -O2 -g -W -Wall -MT mailmime_disposition.lo -MD -MP -MF .deps/mailmime_disposition.Tpo -c -o mailmime_disposition.lo mailmime_disposition.c
portage    940  0.0  0.1   5400   944 tty4     TN   22:22   0:00                                                                                  \_ /bin/sh ../../../libtool --tag=CC --mode=compile i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I../../.. -I../../../include -I../../../src/low-level/imf -I../../../src/data-types -DDEBUG -D_REENTRANT -O2 -march=athlon-xp -pipe -O2 -g -W -Wall -MT mailmime_disposition.lo -MD -MP -MF .deps/mailmime_disposition.Tpo -c -o mailmime_disposition.lo mailmime_disposition.c
root      1380  0.0  0.3   4876  1728 tty5     Ss   22:14   0:00 -bash
root      1792  2.6  0.2   2420  1156 tty5     S+   22:16   0:15  \_ top
root      1381  0.0  0.1   1892   768 tty6     Ss+  22:14   0:00 /sbin/agetty 38400 tty6 linux
root      1521  0.0  0.0   1928   356 ?        Ss   22:14   0:00 dhcpcd -m 2 eth0
root      1562  0.0  0.1   5128   544 ?        S    22:14   0:00 supervising syslog-ng
root      1563  0.0  0.4   5408  1968 ?        Ss   22:14   0:00  \_ /usr/sbin/syslog-ng
ntp       1587  0.0  0.2   4360  1352 ?        Ss   22:14   0:00 /usr/sbin/ntpd -p /var/run/ntpd.pid -u ntp:ntp
collectd  1605  0.6  0.7  49924  3748 ?        SNLsl 22:14   0:04 /usr/sbin/collectd -P /var/run/collectd/collectd.pid -C /etc/collectd.conf
root      1623  0.0  0.1   1944   508 ?        Ss   22:14   0:00 /usr/sbin/gpm -m /dev/input/mice -t ps2
root      1663  0.0  0.1   2116   760 ?        Ss   22:14   0:00 /sbin/rpcbind
root      1677  0.0  0.2   2188   968 ?        Ss   22:14   0:00 /sbin/rpc.statd --no-notify
root      1737  0.0  0.2   4204   988 ?        Ss   22:15   0:00 /usr/sbin/sshd
root       942  0.0  0.4   6872  2252 ?        Ss   22:23   0:00  \_ sshd: root@pts/2 
root       944  0.0  0.3   4876  1780 pts/2    Ss   22:23   0:00      \_ -bash
root       961  0.0  0.2   4124   964 pts/2    R+   22:26   0:00          \_ ps auxf
root      1766  0.0  0.1   1892   780 tty1     Ss+  22:15   0:00 /sbin/agetty 38400 tty1 linux
root      1767  0.0  0.1   1892   784 ttyS0    Ss+  22:15   0:00 /sbin/agetty 115200 ttyS0 vt100

--MP_/V_HaME=lljP0azEEVHMWr2P
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename=1-slabinfo

slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
squashfs_inode_cache   1900   1900    384   10    1 : tunables    0    0    0 : slabdata    190    190      0
nfs_direct_cache       0      0     88   46    1 : tunables    0    0    0 : slabdata      0      0      0
nfs_write_data        40     40    480    8    1 : tunables    0    0    0 : slabdata      5      5      0
nfs_read_data         36     36    448    9    1 : tunables    0    0    0 : slabdata      4      4      0
nfs_inode_cache       70     70    576   14    2 : tunables    0    0    0 : slabdata      5      5      0
nfs_page              42     42     96   42    1 : tunables    0    0    0 : slabdata      1      1      0
rpc_buffers           15     15   2080   15    8 : tunables    0    0    0 : slabdata      1      1      0
rpc_tasks             25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
rpc_inode_cache       36     36    448    9    1 : tunables    0    0    0 : slabdata      4      4      0
fib6_nodes            64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
ip6_dst_cache         29     42    192   21    1 : tunables    0    0    0 : slabdata      2      2      0
ndisc_cache           21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
RAWv6                 12     12    672   12    2 : tunables    0    0    0 : slabdata      1      1      0
UDPLITEv6              0      0    672   12    2 : tunables    0    0    0 : slabdata      0      0      0
UDPv6                 12     12    672   12    2 : tunables    0    0    0 : slabdata      1      1      0
tw_sock_TCPv6          0      0    160   25    1 : tunables    0    0    0 : slabdata      0      0      0
request_sock_TCPv6     32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
TCPv6                 12     12   1312   12    4 : tunables    0    0    0 : slabdata      1      1      0
aoe_bufs               0      0     64   64    1 : tunables    0    0    0 : slabdata      0      0      0
scsi_sense_cache      32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
scsi_cmd_cache        25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
sd_ext_cdb            85     85     48   85    1 : tunables    0    0    0 : slabdata      1      1      0
cfq_io_context       102    102     80   51    1 : tunables    0    0    0 : slabdata      2      2      0
cfq_queue             41     50    160   25    1 : tunables    0    0    0 : slabdata      2      2      0
mqueue_inode_cache      8      8    512    8    1 : tunables    0    0    0 : slabdata      1      1      0
xfs_buf                0      0    192   21    1 : tunables    0    0    0 : slabdata      0      0      0
fstrm_item             0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_mru_cache_elem      0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_ili                0      0    168   24    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_inode              0      0    608   13    2 : tunables    0    0    0 : slabdata      0      0      0
xfs_efi_item           0      0    296   13    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_efd_item           0      0    296   13    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_buf_item           0      0    184   22    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_log_item_desc      0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_trans              0      0    240   17    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_ifork              0      0     72   56    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_dabuf              0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_da_state           0      0    352   11    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_btree_cur          0      0    160   25    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_bmap_free_item      0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_log_ticket         0      0    192   21    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_ioend             51     51     80   51    1 : tunables    0    0    0 : slabdata      1      1      0
reiser_inode_cache  12780  12780    400   10    1 : tunables    0    0    0 : slabdata   1278   1278      0
configfs_dir_cache     64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
kioctx                 0      0    224   18    1 : tunables    0    0    0 : slabdata      0      0      0
kiocb                  0      0    128   32    1 : tunables    0    0    0 : slabdata      0      0      0
inotify_event_private_data    128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
inotify_inode_mark     46     46     88   46    1 : tunables    0    0    0 : slabdata      1      1      0
fasync_cache           0      0     40  102    1 : tunables    0    0    0 : slabdata      0      0      0
khugepaged_mm_slot      0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
nsproxy                0      0     40  102    1 : tunables    0    0    0 : slabdata      0      0      0
posix_timers_cache      0      0    128   32    1 : tunables    0    0    0 : slabdata      0      0      0
uid_cache             42     42     96   42    1 : tunables    0    0    0 : slabdata      1      1      0
UNIX                  25     27    448    9    1 : tunables    0    0    0 : slabdata      3      3      0
UDP-Lite               0      0    544   15    2 : tunables    0    0    0 : slabdata      0      0      0
tcp_bind_bucket      128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
inet_peer_cache       21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
ip_fib_trie          102    102     40  102    1 : tunables    0    0    0 : slabdata      1      1      0
ip_fib_alias         102    102     40  102    1 : tunables    0    0    0 : slabdata      1      1      0
ip_dst_cache          50     50    160   25    1 : tunables    0    0    0 : slabdata      2      2      0
arp_cache             21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
RAW                    8      8    512    8    1 : tunables    0    0    0 : slabdata      1      1      0
UDP                   15     15    544   15    2 : tunables    0    0    0 : slabdata      1      1      0
tw_sock_TCP           32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
request_sock_TCP      42     42     96   42    1 : tunables    0    0    0 : slabdata      1      1      0
TCP                   13     13   1184   13    4 : tunables    0    0    0 : slabdata      1      1      0
eventpoll_pwq          0      0     48   85    1 : tunables    0    0    0 : slabdata      0      0      0
eventpoll_epi          0      0     96   42    1 : tunables    0    0    0 : slabdata      0      0      0
sgpool-128            12     12   2592   12    8 : tunables    0    0    0 : slabdata      1      1      0
sgpool-64             12     12   1312   12    4 : tunables    0    0    0 : slabdata      1      1      0
sgpool-32             12     12    672   12    2 : tunables    0    0    0 : slabdata      1      1      0
sgpool-16             11     11    352   11    1 : tunables    0    0    0 : slabdata      1      1      0
sgpool-8              21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
scsi_data_buffer       0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
blkdev_queue          17     17    936   17    4 : tunables    0    0    0 : slabdata      1      1      0
blkdev_requests       26     36    224   18    1 : tunables    0    0    0 : slabdata      2      2      0
blkdev_ioc            73     73     56   73    1 : tunables    0    0    0 : slabdata      1      1      0
fsnotify_event_holder      0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
fsnotify_event        56     56     72   56    1 : tunables    0    0    0 : slabdata      1      1      0
bio-0                 27     50    160   25    1 : tunables    0    0    0 : slabdata      2      2      0
biovec-256            10     10   3104   10    8 : tunables    0    0    0 : slabdata      1      1      0
biovec-128             0      0   1568   10    4 : tunables    0    0    0 : slabdata      0      0      0
biovec-64             10     10    800   10    2 : tunables    0    0    0 : slabdata      1      1      0
biovec-16             18     18    224   18    1 : tunables    0    0    0 : slabdata      1      1      0
sock_inode_cache      70     77    352   11    1 : tunables    0    0    0 : slabdata      7      7      0
skbuff_fclone_cache     11     11    352   11    1 : tunables    0    0    0 : slabdata      1      1      0
skbuff_head_cache    511    546    192   21    1 : tunables    0    0    0 : slabdata     26     26      0
file_lock_cache       36     36    112   36    1 : tunables    0    0    0 : slabdata      1      1      0
shmem_inode_cache    894    910    408   10    1 : tunables    0    0    0 : slabdata     91     91      0
Acpi-Operand         949    949     56   73    1 : tunables    0    0    0 : slabdata     13     13      0
Acpi-ParseExt         64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
Acpi-Parse            85     85     48   85    1 : tunables    0    0    0 : slabdata      1      1      0
Acpi-State            73     73     56   73    1 : tunables    0    0    0 : slabdata      1      1      0
Acpi-Namespace       612    612     40  102    1 : tunables    0    0    0 : slabdata      6      6      0
proc_inode_cache    4393   4393    344   23    2 : tunables    0    0    0 : slabdata    191    191      0
sigqueue              32     50    160   25    1 : tunables    0    0    0 : slabdata      2      2      0
bdev_cache            13     18    448    9    1 : tunables    0    0    0 : slabdata      2      2      0
sysfs_dir_cache    13696  13696     64   64    1 : tunables    0    0    0 : slabdata    214    214      0
mnt_cache             50     50    160   25    1 : tunables    0    0    0 : slabdata      2      2      0
filp              209184 209184    128   32    1 : tunables    0    0    0 : slabdata   6537   6537      0
inode_cache         3972   3972    320   12    1 : tunables    0    0    0 : slabdata    331    331      0
dentry             35700  35700    144   28    1 : tunables    0    0    0 : slabdata   1275   1275      0
names_cache            7      7   4128    7    8 : tunables    0    0    0 : slabdata      1      1      0
buffer_head        13166  37856     72   56    1 : tunables    0    0    0 : slabdata    676    676      0
vm_area_struct      2508   2535    104   39    1 : tunables    0    0    0 : slabdata     65     65      0
mm_struct             68     72    448    9    1 : tunables    0    0    0 : slabdata      8      8      0
fs_cache             128    128     64   64    1 : tunables    0    0    0 : slabdata      2      2      0
files_cache         4240   4242    192   21    1 : tunables    0    0    0 : slabdata    202    202      0
signal_cache        7040   7040    512    8    1 : tunables    0    0    0 : slabdata    880    880      0
sighand_cache        102    108   1312   12    4 : tunables    0    0    0 : slabdata      9      9      0
task_xstate          350    350    576   14    2 : tunables    0    0    0 : slabdata     25     25      0
task_struct         7049   7049    832   19    4 : tunables    0    0    0 : slabdata    371    371      0
cred_jar           18496  18496    128   32    1 : tunables    0    0    0 : slabdata    578    578      0
anon_vma_chain      2371   2448     40  102    1 : tunables    0    0    0 : slabdata     24     24      0
anon_vma            1432   1536     32  128    1 : tunables    0    0    0 : slabdata     12     12      0
pid                 7104   7104     64   64    1 : tunables    0    0    0 : slabdata    111    111      0
radix_tree_node     6422   6422    312   13    1 : tunables    0    0    0 : slabdata    494    494      0
idr_layer_cache      273    275    160   25    1 : tunables    0    0    0 : slabdata     11     11      0
dma-kmalloc-8192       0      0   8208    3    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-4096       0      0   4112    7    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-2048       0      0   2064   15    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-1024       0      0   1040   15    4 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-512        0      0    528   15    2 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-256        0      0    272   15    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-128        0      0    144   28    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-64         0      0     80   51    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-32         0      0     48   85    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-16         0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-8          0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-192        0      0    208   19    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-96         0      0    112   36    1 : tunables    0    0    0 : slabdata      0      0      0
kmalloc-8192          12     12   8208    3    8 : tunables    0    0    0 : slabdata      4      4      0
kmalloc-4096         300    301   4112    7    8 : tunables    0    0    0 : slabdata     43     43      0
kmalloc-2048         556    570   2064   15    8 : tunables    0    0    0 : slabdata     38     38      0
kmalloc-1024        2984   2985   1040   15    4 : tunables    0    0    0 : slabdata    199    199      0
kmalloc-512          431    435    528   15    2 : tunables    0    0    0 : slabdata     29     29      0
kmalloc-256           44     45    272   15    1 : tunables    0    0    0 : slabdata      3      3      0
kmalloc-128          336    336    144   28    1 : tunables    0    0    0 : slabdata     12     12      0
kmalloc-64          3822   3825     80   51    1 : tunables    0    0    0 : slabdata     75     75      0
kmalloc-32          4505   4505     48   85    1 : tunables    0    0    0 : slabdata     53     53      0
kmalloc-16          2363   5248     32  128    1 : tunables    0    0    0 : slabdata     41     41      0
kmalloc-8           3569   3570     24  170    1 : tunables    0    0    0 : slabdata     21     21      0
kmalloc-192          133    133    208   19    1 : tunables    0    0    0 : slabdata      7      7      0
kmalloc-96          1008   1008    112   36    1 : tunables    0    0    0 : slabdata     28     28      0
kmem_cache            32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
kmem_cache_node      192    192     64   64    1 : tunables    0    0    0 : slabdata      3      3      0

--MP_/V_HaME=lljP0azEEVHMWr2P
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename=2-meminfo

MemTotal:         480420 kB
MemFree:          233396 kB
Buffers:           38816 kB
Cached:            34944 kB
SwapCached:          128 kB
Active:            53088 kB
Inactive:          28216 kB
Active(anon):       1844 kB
Inactive(anon):     4924 kB
Active(file):      51244 kB
Inactive(file):    23292 kB
Unevictable:          32 kB
Mlocked:              32 kB
SwapTotal:        524284 kB
SwapFree:         524156 kB
Dirty:                32 kB
Writeback:             0 kB
AnonPages:          6580 kB
Mapped:             5456 kB
Shmem:               112 kB
Slab:              97772 kB
SReclaimable:      19920 kB
SUnreclaim:        77852 kB
KernelStack:       62800 kB
PageTables:          460 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:      764492 kB
Committed_AS:      56340 kB
VmallocTotal:     548548 kB
VmallocUsed:        8392 kB
VmallocChunk:     534328 kB
AnonHugePages:         0 kB
DirectMap4k:       16320 kB
DirectMap4M:      475136 kB

--MP_/V_HaME=lljP0azEEVHMWr2P
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename=2-ps_auxf

USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         2  0.0  0.0      0     0 ?        S    22:14   0:00 [kthreadd]
root         3  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [ksoftirqd/0]
root         6  0.0  0.0      0     0 ?        R    22:14   0:00  \_ [rcu_kthread]
root         7  0.0  0.0      0     0 ?        R    22:14   0:00  \_ [watchdog/0]
root         8  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [khelper]
root       138  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [sync_supers]
root       140  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [bdi-default]
root       142  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [kblockd]
root       230  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [ata_sff]
root       237  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [khubd]
root       365  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [kswapd0]
root       464  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [fsnotify_mark]
root       486  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfs_mru_cache]
root       489  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfslogd]
root       490  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfsdatad]
root       491  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfsconvertd]
root       554  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scsi_eh_0]
root       559  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scsi_eh_1]
root       573  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scsi_eh_2]
root       576  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scsi_eh_3]
root       579  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [kworker/u:4]
root       580  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [kworker/u:5]
root       589  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scsi_eh_4]
root       592  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scsi_eh_5]
root       655  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [kpsmoused]
root       706  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [reiserfs]
root      1486  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [flush-8:0]
root      1692  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [rpciod]
root      1693  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [nfsiod]
root      1697  0.0  0.0      0     0 ?        S    22:15   0:00  \_ [lockd]
root       976  0.0  0.0      0     0 ?        S    22:30   0:00  \_ [kworker/0:0]
root      1004  0.0  0.0      0     0 ?        S    22:38   0:00  \_ [kworker/0:1]
root         1  0.1  0.1   1740   588 ?        Ss   22:14   0:02 init [3]  
root       823  0.0  0.1   2132   824 ?        S<s  22:14   0:00 /sbin/udevd --daemon
root      1778  0.0  0.1   2128   696 ?        S<   22:15   0:00  \_ /sbin/udevd --daemon
root      1377  0.0  0.3   4876  1780 tty2     Ss   22:14   0:00 -bash
root      1145  0.0  0.2   2276   988 tty2     S+   22:40   0:00  \_ slabtop
root      1381  0.0  0.1   1892   768 tty6     Ss+  22:14   0:00 /sbin/agetty 38400 tty6 linux
root      1521  0.0  0.0   1928   356 ?        Ss   22:14   0:00 dhcpcd -m 2 eth0
root      1562  0.0  0.1   5128   544 ?        S    22:14   0:00 supervising syslog-ng
root      1563  0.0  0.4   5408  1968 ?        Ss   22:14   0:00  \_ /usr/sbin/syslog-ng
ntp       1587  0.0  0.2   4360  1352 ?        Ss   22:14   0:00 /usr/sbin/ntpd -p /var/run/ntpd.pid -u ntp:ntp
collectd  1605  0.6  0.7  49924  3748 ?        SNLsl 22:14   0:14 /usr/sbin/collectd -P /var/run/collectd/collectd.pid -C /etc/collectd.conf
root      1623  0.0  0.1   1944   508 ?        Ss   22:14   0:00 /usr/sbin/gpm -m /dev/input/mice -t ps2
root      1663  0.0  0.1   2116   760 ?        Ss   22:14   0:00 /sbin/rpcbind
root      1677  0.0  0.2   2188   968 ?        Ss   22:14   0:00 /sbin/rpc.statd --no-notify
root      1737  0.0  0.2   4204   988 ?        Ss   22:15   0:00 /usr/sbin/sshd
root       942  0.0  0.4   7004  2264 ?        Ss   22:23   0:00  \_ sshd: root@pts/2 
root       944  0.0  0.3   4876  1812 pts/2    Ss   22:23   0:00      \_ -bash
root      1791  0.0  0.1   4124   960 pts/2    R+   22:53   0:00          \_ ps auxf
root      1766  0.0  0.1   1892   780 tty1     Ss+  22:15   0:00 /sbin/agetty 38400 tty1 linux
root      1767  0.0  0.1   1892   784 ttyS0    Ss+  22:15   0:00 /sbin/agetty 115200 ttyS0 vt100
root       982  0.0  0.1   1892   784 tty5     Ss+  22:38   0:00 /sbin/agetty 38400 tty5 linux
root      1011  0.0  0.3   4876  1748 tty3     Ss+  22:38   0:00 -bash
root      1126  0.0  0.1   1892   780 tty4     Ss+  22:38   0:00 /sbin/agetty 38400 tty4 linux

--MP_/V_HaME=lljP0azEEVHMWr2P
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename=2-slabinfo

slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
squashfs_inode_cache   1920   1920    384   10    1 : tunables    0    0    0 : slabdata    192    192      0
nfs_direct_cache       0      0     88   46    1 : tunables    0    0    0 : slabdata      0      0      0
nfs_write_data        40     40    480    8    1 : tunables    0    0    0 : slabdata      5      5      0
nfs_read_data         36     36    448    9    1 : tunables    0    0    0 : slabdata      4      4      0
nfs_inode_cache       70     70    576   14    2 : tunables    0    0    0 : slabdata      5      5      0
nfs_page              42     42     96   42    1 : tunables    0    0    0 : slabdata      1      1      0
rpc_buffers           15     15   2080   15    8 : tunables    0    0    0 : slabdata      1      1      0
rpc_tasks             25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
rpc_inode_cache       36     36    448    9    1 : tunables    0    0    0 : slabdata      4      4      0
fib6_nodes            64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
ip6_dst_cache         29     42    192   21    1 : tunables    0    0    0 : slabdata      2      2      0
ndisc_cache           21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
RAWv6                 12     12    672   12    2 : tunables    0    0    0 : slabdata      1      1      0
UDPLITEv6              0      0    672   12    2 : tunables    0    0    0 : slabdata      0      0      0
UDPv6                 12     12    672   12    2 : tunables    0    0    0 : slabdata      1      1      0
tw_sock_TCPv6          0      0    160   25    1 : tunables    0    0    0 : slabdata      0      0      0
request_sock_TCPv6     32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
TCPv6                 12     12   1312   12    4 : tunables    0    0    0 : slabdata      1      1      0
aoe_bufs               0      0     64   64    1 : tunables    0    0    0 : slabdata      0      0      0
scsi_sense_cache      32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
scsi_cmd_cache        25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
sd_ext_cdb            85     85     48   85    1 : tunables    0    0    0 : slabdata      1      1      0
cfq_io_context       153    153     80   51    1 : tunables    0    0    0 : slabdata      3      3      0
cfq_queue             36     50    160   25    1 : tunables    0    0    0 : slabdata      2      2      0
mqueue_inode_cache      8      8    512    8    1 : tunables    0    0    0 : slabdata      1      1      0
xfs_buf                0      0    192   21    1 : tunables    0    0    0 : slabdata      0      0      0
fstrm_item             0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_mru_cache_elem      0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_ili                0      0    168   24    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_inode              0      0    608   13    2 : tunables    0    0    0 : slabdata      0      0      0
xfs_efi_item           0      0    296   13    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_efd_item           0      0    296   13    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_buf_item           0      0    184   22    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_log_item_desc      0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_trans              0      0    240   17    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_ifork              0      0     72   56    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_dabuf              0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_da_state           0      0    352   11    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_btree_cur          0      0    160   25    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_bmap_free_item      0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_log_ticket         0      0    192   21    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_ioend             51     51     80   51    1 : tunables    0    0    0 : slabdata      1      1      0
reiser_inode_cache  13050  13050    400   10    1 : tunables    0    0    0 : slabdata   1305   1305      0
configfs_dir_cache     64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
kioctx                 0      0    224   18    1 : tunables    0    0    0 : slabdata      0      0      0
kiocb                  0      0    128   32    1 : tunables    0    0    0 : slabdata      0      0      0
inotify_event_private_data    128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
inotify_inode_mark     46     46     88   46    1 : tunables    0    0    0 : slabdata      1      1      0
fasync_cache           0      0     40  102    1 : tunables    0    0    0 : slabdata      0      0      0
khugepaged_mm_slot      0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
nsproxy                0      0     40  102    1 : tunables    0    0    0 : slabdata      0      0      0
posix_timers_cache      0      0    128   32    1 : tunables    0    0    0 : slabdata      0      0      0
uid_cache             42     42     96   42    1 : tunables    0    0    0 : slabdata      1      1      0
UNIX                  25     27    448    9    1 : tunables    0    0    0 : slabdata      3      3      0
UDP-Lite               0      0    544   15    2 : tunables    0    0    0 : slabdata      0      0      0
tcp_bind_bucket      128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
inet_peer_cache       21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
ip_fib_trie          102    102     40  102    1 : tunables    0    0    0 : slabdata      1      1      0
ip_fib_alias         102    102     40  102    1 : tunables    0    0    0 : slabdata      1      1      0
ip_dst_cache          50     50    160   25    1 : tunables    0    0    0 : slabdata      2      2      0
arp_cache             21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
RAW                    8      8    512    8    1 : tunables    0    0    0 : slabdata      1      1      0
UDP                   15     15    544   15    2 : tunables    0    0    0 : slabdata      1      1      0
tw_sock_TCP           32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
request_sock_TCP      42     42     96   42    1 : tunables    0    0    0 : slabdata      1      1      0
TCP                   13     13   1184   13    4 : tunables    0    0    0 : slabdata      1      1      0
eventpoll_pwq          0      0     48   85    1 : tunables    0    0    0 : slabdata      0      0      0
eventpoll_epi          0      0     96   42    1 : tunables    0    0    0 : slabdata      0      0      0
sgpool-128            12     12   2592   12    8 : tunables    0    0    0 : slabdata      1      1      0
sgpool-64             12     12   1312   12    4 : tunables    0    0    0 : slabdata      1      1      0
sgpool-32             12     12    672   12    2 : tunables    0    0    0 : slabdata      1      1      0
sgpool-16             11     11    352   11    1 : tunables    0    0    0 : slabdata      1      1      0
sgpool-8              21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
scsi_data_buffer       0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
blkdev_queue          17     17    936   17    4 : tunables    0    0    0 : slabdata      1      1      0
blkdev_requests       26     36    224   18    1 : tunables    0    0    0 : slabdata      2      2      0
blkdev_ioc            73     73     56   73    1 : tunables    0    0    0 : slabdata      1      1      0
fsnotify_event_holder      0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
fsnotify_event        56     56     72   56    1 : tunables    0    0    0 : slabdata      1      1      0
bio-0                 25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
biovec-256            10     10   3104   10    8 : tunables    0    0    0 : slabdata      1      1      0
biovec-128             0      0   1568   10    4 : tunables    0    0    0 : slabdata      0      0      0
biovec-64             10     10    800   10    2 : tunables    0    0    0 : slabdata      1      1      0
biovec-16             18     18    224   18    1 : tunables    0    0    0 : slabdata      1      1      0
sock_inode_cache      70     77    352   11    1 : tunables    0    0    0 : slabdata      7      7      0
skbuff_fclone_cache     11     11    352   11    1 : tunables    0    0    0 : slabdata      1      1      0
skbuff_head_cache    517    567    192   21    1 : tunables    0    0    0 : slabdata     27     27      0
file_lock_cache       36     36    112   36    1 : tunables    0    0    0 : slabdata      1      1      0
shmem_inode_cache    910    910    408   10    1 : tunables    0    0    0 : slabdata     91     91      0
Acpi-Operand         949    949     56   73    1 : tunables    0    0    0 : slabdata     13     13      0
Acpi-ParseExt         64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
Acpi-Parse            85     85     48   85    1 : tunables    0    0    0 : slabdata      1      1      0
Acpi-State            73     73     56   73    1 : tunables    0    0    0 : slabdata      1      1      0
Acpi-Namespace       612    612     40  102    1 : tunables    0    0    0 : slabdata      6      6      0
proc_inode_cache    6256   6256    344   23    2 : tunables    0    0    0 : slabdata    272    272      0
sigqueue              25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
bdev_cache            13     18    448    9    1 : tunables    0    0    0 : slabdata      2      2      0
sysfs_dir_cache    13696  13696     64   64    1 : tunables    0    0    0 : slabdata    214    214      0
mnt_cache             50     50    160   25    1 : tunables    0    0    0 : slabdata      2      2      0
filp              422592 422592    128   32    1 : tunables    0    0    0 : slabdata  13206  13206      0
inode_cache         3954   3972    320   12    1 : tunables    0    0    0 : slabdata    331    331      0
dentry             39312  39312    144   28    1 : tunables    0    0    0 : slabdata   1404   1404      0
names_cache            7      7   4128    7    8 : tunables    0    0    0 : slabdata      1      1      0
buffer_head        13560  37856     72   56    1 : tunables    0    0    0 : slabdata    676    676      0
vm_area_struct       862   1053    104   39    1 : tunables    0    0    0 : slabdata     27     27      0
mm_struct             27     54    448    9    1 : tunables    0    0    0 : slabdata      6      6      0
fs_cache              80    128     64   64    1 : tunables    0    0    0 : slabdata      2      2      0
files_cache         4325   4326    192   21    1 : tunables    0    0    0 : slabdata    206    206      0
signal_cache        7848   7848    512    8    1 : tunables    0    0    0 : slabdata    981    981      0
sighand_cache         64    108   1312   12    4 : tunables    0    0    0 : slabdata      9      9      0
task_xstate          392    392    576   14    2 : tunables    0    0    0 : slabdata     28     28      0
task_struct         7866   7866    832   19    4 : tunables    0    0    0 : slabdata    414    414      0
cred_jar           21792  21792    128   32    1 : tunables    0    0    0 : slabdata    681    681      0
anon_vma_chain      1033   1632     40  102    1 : tunables    0    0    0 : slabdata     16     16      0
anon_vma             707    896     32  128    1 : tunables    0    0    0 : slabdata      7      7      0
pid                 7872   7872     64   64    1 : tunables    0    0    0 : slabdata    123    123      0
radix_tree_node     6565   6565    312   13    1 : tunables    0    0    0 : slabdata    505    505      0
idr_layer_cache      269    275    160   25    1 : tunables    0    0    0 : slabdata     11     11      0
dma-kmalloc-8192       0      0   8208    3    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-4096       0      0   4112    7    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-2048       0      0   2064   15    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-1024       0      0   1040   15    4 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-512        0      0    528   15    2 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-256        0      0    272   15    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-128        0      0    144   28    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-64         0      0     80   51    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-32         0      0     48   85    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-16         0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-8          0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-192        0      0    208   19    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-96         0      0    112   36    1 : tunables    0    0    0 : slabdata      0      0      0
kmalloc-8192          12     12   8208    3    8 : tunables    0    0    0 : slabdata      4      4      0
kmalloc-4096         285    294   4112    7    8 : tunables    0    0    0 : slabdata     42     42      0
kmalloc-2048         547    555   2064   15    8 : tunables    0    0    0 : slabdata     37     37      0
kmalloc-1024        3690   3690   1040   15    4 : tunables    0    0    0 : slabdata    246    246      0
kmalloc-512          422    435    528   15    2 : tunables    0    0    0 : slabdata     29     29      0
kmalloc-256           44     45    272   15    1 : tunables    0    0    0 : slabdata      3      3      0
kmalloc-128          336    336    144   28    1 : tunables    0    0    0 : slabdata     12     12      0
kmalloc-64          4486   4488     80   51    1 : tunables    0    0    0 : slabdata     88     88      0
kmalloc-32          5354   5355     48   85    1 : tunables    0    0    0 : slabdata     63     63      0
kmalloc-16          2351   5248     32  128    1 : tunables    0    0    0 : slabdata     41     41      0
kmalloc-8           3566   3570     24  170    1 : tunables    0    0    0 : slabdata     21     21      0
kmalloc-192          152    152    208   19    1 : tunables    0    0    0 : slabdata      8      8      0
kmalloc-96          1038   1044    112   36    1 : tunables    0    0    0 : slabdata     29     29      0
kmem_cache            32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
kmem_cache_node      192    192     64   64    1 : tunables    0    0    0 : slabdata      3      3      0

--MP_/V_HaME=lljP0azEEVHMWr2P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
