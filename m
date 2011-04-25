Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D428D8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 17:26:42 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3PL6KXx017174
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 17:06:20 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3PLQeGj1278056
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 17:26:40 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3PLQdka004542
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 17:26:40 -0400
Date: Mon, 25 Apr 2011 14:26:38 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110425212638.GN2468@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
 <20110425111705.786ef0c5@neptune.home>
 <BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
 <20110425180450.1ede0845@neptune.home>
 <BANLkTikSLA59tdgRL4B=cr5tvP2NbzZ=KA@mail.gmail.com>
 <20110425190032.7904c95d@neptune.home>
 <BANLkTi=hQ=HcPLCdbb1pSi+xJByMTah-gw@mail.gmail.com>
 <20110425203606.4e78246c@neptune.home>
 <20110425191607.GL2468@linux.vnet.ibm.com>
 <20110425231016.34b4293e@neptune.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20110425231016.34b4293e@neptune.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

On Mon, Apr 25, 2011 at 11:10:16PM +0200, Bruno Pr=E9mont wrote:
> On Mon, 25 April 2011 "Paul E. McKenney" wrote:
> > On Mon, Apr 25, 2011 at 08:36:06PM +0200, Bruno Pr=E9mont wrote:
> > > On Mon, 25 April 2011 Linus Torvalds wrote:
> > > > On Mon, Apr 25, 2011 at 10:00 AM, Bruno Pr=E9mont wrote:
> > > > >
> > > > > I hope tiny-rcu is not that broken... as it would mean driving any
> > > > > PREEMPT_NONE or PREEMPT_VOLUNTARY system out of memory when compi=
ling
> > > > > packages (and probably also just unpacking larger tarballs or run=
ning
> > > > > things like du).
> > > >=20
> > > > I'm sure that TINYRCU can be fixed if it really is the problem.
> > > >=20
> > > > So I just want to make sure that we know what the root cause of your
> > > > problem is. It's quite possible that it _is_ a real leak of filp or
> > > > something, but before possibly wasting time trying to figure that o=
ut,
> > > > let's see if your config is to blame.
> > >=20
> > > With changed config (PREEMPT=3Dy, TREE_PREEMPT_RCU=3Dy) I haven't rep=
roduced
> > > yet.
> > >=20
> > > When I was reproducing with TINYRCU things went normally for some time
> > > until suddenly slabs stopped being freed.
> >=20
> > Hmmm... If the system is responsive during this time, could you please
> > do the following after the slabs stop being freed?
> >=20
> > ps -eo pid,class,sched,rtprio,stat,state,sgi_p,cpu_time,cmd | grep '\[r=
cu'
>=20
> Looks like tinyrcu is not innocent (or at least it makes bug appear much
> more easily)
>=20
> With + + TREE_PREMPT_RCU system was stable compiling for over 2 hours,
> switching to TINY_RCU, filp count started increasing pretty early after b=
eginning
> compiling.
>=20
> All the relevant information attached (PREEMPT+TINY_RCU):
>   config.gz
>   ps auxf     |
>   slabinfo    |  twice, once early (1-*), the second 30 minutes later (2-=
*)
>   meminfo     |
>=20
> ls -l proc/*/fd produces 658 lines for the 1-* series of numbers, 300 for=
 2-*.
>=20
> In both cases=20
>    ps -eo pid,class,sched,rtprio,stat,state,sgi_p,cputime,cmd | grep '\[r=
cu'
> returns the same information:
>       6 FF    1      1 R    R 0 00:00:00 [rcu_kthread]

So rcu_kthread is runnable at SCHED_FIFO priority 1, but not accumulating
any CPU time.  Sedat has also seen this, and I never have been able to
reproduce it.

Anyone have any idea how this woiuld happen?

(And if rcu_kthread isn't running, I would expect exactly the symptoms
you are seeing.  I just don't understand why it isn't running if it
is runnable.)

							Thanx, Paul

> according to slabtop filp count is increasing permanentally, (about +1000
> every 3 seconds) probably because of top (1s refresh rate) and collectd (=
10s
> rate) scanning /proc (without top, increasing by about 300 every 10s).
>=20
> Running something like `for ((X=3D0; X < 200; X++)); do /bin/true; done` =
causes
> count of pid, task_struct, signal_cache slab count to increase by about 2=
00,
> but no zombies are being left behind.
>=20
> 1-*  Taken a few minutes after starting compile process, but after having
>      SIGSTOPed the compiling process tree
> 2-*  about 30 minutes later, killed compile process tree, run above for l=
oop
>      multiple times, close most terminal sessions (including top)
>=20
> Between 1-slabinfo and 2-slabinfo some values increased (a lot) while a f=
ew
> ones did decrease. Don't know which ones are RCU-affected and which ones =
are
> not.
>=20
> Bruno


> MemTotal:         480420 kB
> MemFree:          175180 kB
> Buffers:           37604 kB
> Cached:            30436 kB
> SwapCached:          128 kB
> Active:            97532 kB
> Inactive:          77776 kB
> Active(anon):      51012 kB
> Inactive(anon):    55480 kB
> Active(file):      46520 kB
> Inactive(file):    22296 kB
> Unevictable:          32 kB
> Mlocked:              32 kB
> SwapTotal:        524284 kB
> SwapFree:         524156 kB
> Dirty:                16 kB
> Writeback:             0 kB
> AnonPages:        106300 kB
> Mapped:            12732 kB
> Shmem:               112 kB
> Slab:              67580 kB
> SReclaimable:      18596 kB
> SUnreclaim:        48984 kB
> KernelStack:       56352 kB
> PageTables:         1344 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:      764492 kB
> Committed_AS:     173588 kB
> VmallocTotal:     548548 kB
> VmallocUsed:        8392 kB
> VmallocChunk:     534328 kB
> AnonHugePages:         0 kB
> DirectMap4k:       16320 kB
> DirectMap4M:      475136 kB

> USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
> root         2  0.0  0.0      0     0 ?        S    22:14   0:00 [kthread=
d]
> root         3  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [kso=
ftirqd/0]
> root         6  0.1  0.0      0     0 ?        R    22:14   0:00  \_ [rcu=
_kthread]
> root         7  0.0  0.0      0     0 ?        R    22:14   0:00  \_ [wat=
chdog/0]
> root         8  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [khe=
lper]
> root       138  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [syn=
c_supers]
> root       140  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [bdi=
-default]
> root       142  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [kbl=
ockd]
> root       230  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [ata=
_sff]
> root       237  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [khu=
bd]
> root       365  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [ksw=
apd0]
> root       464  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [fsn=
otify_mark]
> root       486  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfs=
_mru_cache]
> root       489  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfs=
logd]
> root       490  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfs=
datad]
> root       491  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfs=
convertd]
> root       554  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scs=
i_eh_0]
> root       559  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scs=
i_eh_1]
> root       573  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scs=
i_eh_2]
> root       576  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scs=
i_eh_3]
> root       579  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [kwo=
rker/u:4]
> root       580  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [kwo=
rker/u:5]
> root       589  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scs=
i_eh_4]
> root       592  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scs=
i_eh_5]
> root       655  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [kps=
moused]
> root       706  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [rei=
serfs]
> root      1485  0.1  0.0      0     0 ?        S    22:14   0:01  \_ [kwo=
rker/0:3]
> root      1486  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [flu=
sh-8:0]
> root      1692  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [rpc=
iod]
> root      1693  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [nfs=
iod]
> root      1697  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [loc=
kd]
> root     26248  0.0  0.0      0     0 ?        S    22:21   0:00  \_ [kwo=
rker/0:2]
> root     26445  0.0  0.0      0     0 ?        S    22:21   0:00  \_ [kwo=
rker/0:4]
> root         1  0.3  0.1   1740   588 ?        Ss   22:14   0:02 init [3]=
 =20
> root       823  0.0  0.1   2132   824 ?        S<s  22:14   0:00 /sbin/ud=
evd --daemon
> root      1778  0.0  0.1   2128   696 ?        S<   22:15   0:00  \_ /sbi=
n/udevd --daemon
> root      1377  0.0  0.3   4876  1780 tty2     Ss   22:14   0:00 -bash
> root      3692  0.1  0.2   2276   988 tty2     S+   22:18   0:00  \_ slab=
top
> root      1378  0.0  0.3   4876  1768 tty3     Ss+  22:14   0:00 -bash
> root      1781  1.4  6.1  34372 29736 tty3     TN   22:16   0:08  \_ /usr=
/bin/python2.7 /usr/bin/emerge --oneshot gimp
> portage  15556  0.0  0.5   5924  2696 tty3     TN   22:19   0:00      \_ =
/bin/bash /usr/lib/portage/bin/ebuild.sh compile
> portage  15655  0.0  0.4   6060  2200 tty3     TN   22:19   0:00         =
 \_ /bin/bash /usr/lib/portage/bin/ebuild.sh compile
> portage  15662  0.0  0.3   4880  1560 tty3     TN   22:19   0:00         =
     \_ /bin/bash /usr/lib/portage/bin/ebuild-helpers/emake
> portage  15667  0.0  0.1   3860   960 tty3     TN   22:19   0:00         =
         \_ make -j2
> portage  15668  0.0  0.2   3864   992 tty3     TN   22:19   0:00         =
             \_ make all-recursive
> portage  15669  0.0  0.2   4752  1420 tty3     TN   22:19   0:00         =
                 \_ /bin/sh -c fail=3D failcom=3D'exit 1'; \?for f in x $MA=
KEFLAGS; do \?  case $f in \?    *=3D* | --[!k]*);; \?    *k*) failcom=3D'f=
ail=3Dyes';; \?  esac; \?done; \?dot_seen=3Dno; \?target=3D`echo all-recurs=
ive | sed s/-recursive//`; \?list=3D'm4macros tools cursors themes po po-li=
bgimp po-plug-ins po-python po-script-fu po-tips data desktop menus libgimp=
base libgimpcolor libgimpmath libgimpconfig libgimpmodule libgimpthumb libg=
impwidgets libgimp app modules plug-ins etc devel-docs docs'; for subdir in=
 $list; do \?  echo "Making $target in $subdir"; \?  if test "$subdir" =3D =
"."; then \?    dot_seen=3Dyes; \?    local_target=3D"$target-am"; \?  else=
 \?    local_target=3D"$target"; \?  fi; \?  (CDPATH=3D"${ZSH_VERSION+.}:" =
&& cd $subdir && make  $local_target) \?  || eval $failcom; \?done; \?if te=
st "$dot_seen" =3D "no"; then \?  make  "$target-am" || exit 1; \?fi; test =
-z "$fail"
> portage  31137  0.0  0.1   4752   740 tty3     TN   22:22   0:00         =
                     \_ /bin/sh -c fail=3D failcom=3D'exit 1'; \?for f in x=
 $MAKEFLAGS; do \?  case $f in \?    *=3D* | --[!k]*);; \?    *k*) failcom=
=3D'fail=3Dyes';; \?  esac; \?done; \?dot_seen=3Dno; \?target=3D`echo all-r=
ecursive | sed s/-recursive//`; \?list=3D'm4macros tools cursors themes po =
po-libgimp po-plug-ins po-python po-script-fu po-tips data desktop menus li=
bgimpbase libgimpcolor libgimpmath libgimpconfig libgimpmodule libgimpthumb=
 libgimpwidgets libgimp app modules plug-ins etc devel-docs docs'; for subd=
ir in $list; do \?  echo "Making $target in $subdir"; \?  if test "$subdir"=
 =3D "."; then \?    dot_seen=3Dyes; \?    local_target=3D"$target-am"; \? =
 else \?    local_target=3D"$target"; \?  fi; \?  (CDPATH=3D"${ZSH_VERSION+=
=2E}:" && cd $subdir && make  $local_target) \?  || eval $failcom; \?done; =
\?if test "$dot_seen" =3D "no"; then \?  make  "$target-am" || exit 1; \?fi=
; test -z "$fail"
> portage  31138  0.0  0.2   3992  1164 tty3     TN   22:22   0:00         =
                         \_ make all
> portage    601  0.0  0.3   5012  1676 tty3     TN   22:22   0:00         =
                             \_ /bin/sh ../libtool --tag=3DCC --mode=3Dcomp=
ile i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I.. -I.. -pthread -I/usr/inc=
lude/gtk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/inclu=
de/cairo -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 -I/usr/incl=
ude/glib-2.0 -I/usr/lib/glib-2.0/include -I/usr/include/pixman-1 -I/usr/inc=
lude/freetype2 -I/usr/include/libpng14 -I/usr/include/libdrm -I/usr/include=
 -DG_LOG_DOMAIN=3D"LibGimpWidgets" -DGIMP_DISABLE_DEPRECATED -DGDK_MULTIHEA=
D_SAFE -DGTK_MULTIHEAD_SAFE -O2 -march=3Dathlon-xp -pipe -Wall -Wdeclaratio=
n-after-statement -Wmissing-prototypes -Wmissing-declarations -Winit-self -=
Wpointer-arith -Wold-style-definition -MT gimpcolordisplaystack.lo -MD -MP =
-MF .deps/gimpcolordisplaystack.Tpo -c -o gimpcolordisplaystack.lo gimpcolo=
rdisplaystack.c
> portage    616  0.0  0.1   1924   536 tty3     TN   22:22   0:00         =
                             |   \_ /usr/i686-pc-linux-gnu/gcc-bin/4.4.5/i6=
86-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I.. -I.. -pthread -I/usr/include/g=
tk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cai=
ro -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 -I/usr/include/gl=
ib-2.0 -I/usr/lib/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/f=
reetype2 -I/usr/include/libpng14 -I/usr/include/libdrm -I/usr/include -DG_L=
OG_DOMAIN=3D"LibGimpWidgets" -DGIMP_DISABLE_DEPRECATED -DGDK_MULTIHEAD_SAFE=
 -DGTK_MULTIHEAD_SAFE -O2 -march=3Dathlon-xp -pipe -Wall -Wdeclaration-afte=
r-statement -Wmissing-prototypes -Wmissing-declarations -Winit-self -Wpoint=
er-arith -Wold-style-definition -MT gimpcolordisplaystack.lo -MD -MP -MF .d=
eps/gimpcolordisplaystack.Tpo -c gimpcolordisplaystack.c -fPIC -DPIC -o .li=
bs/gimpcolordisplaystack.o
> portage    617  0.4  4.5  27296 21728 tty3     TN   22:22   0:00         =
                             |       \_ /usr/libexec/gcc/i686-pc-linux-gnu/=
4.4.5/cc1 -quiet -I. -I.. -I.. -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/in=
clude -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/gdk-pixbuf=
-2.0 -I/usr/include/pango-1.0 -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/i=
nclude -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libp=
ng14 -I/usr/include/libdrm -I/usr/include -MD .libs/gimpcolordisplaystack.d=
 -MF .deps/gimpcolordisplaystack.Tpo -MP -MT gimpcolordisplaystack.lo -D_RE=
ENTRANT -DHAVE_CONFIG_H -DG_LOG_DOMAIN=3D"LibGimpWidgets" -DGIMP_DISABLE_DE=
PRECATED -DGDK_MULTIHEAD_SAFE -DGTK_MULTIHEAD_SAFE -DPIC gimpcolordisplayst=
ack.c -D_FORTIFY_SOURCE=3D2 -quiet -dumpbase gimpcolordisplaystack.c -march=
=3Dathlon-xp -auxbase-strip .libs/gimpcolordisplaystack.o -O2 -Wall -Wdecla=
ration-after-statement -Wmissing-prototypes -Wmissing-declarations -Winit-s=
elf -Wpointer-arith -Wo
>  ld-style-definition -fPIC -o -
> portage    619  0.0  0.6   5284  3128 tty3     TN   22:22   0:00         =
                             |       \_ /usr/lib/gcc/i686-pc-linux-gnu/4.4.=
5/../../../../i686-pc-linux-gnu/bin/as -Qy -o .libs/gimpcolordisplaystack.o=
 -
> portage    632  0.0  0.3   5012  1672 tty3     TN   22:22   0:00         =
                             \_ /bin/sh ../libtool --tag=3DCC --mode=3Dcomp=
ile i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I.. -I.. -pthread -I/usr/inc=
lude/gtk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/inclu=
de/cairo -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 -I/usr/incl=
ude/glib-2.0 -I/usr/lib/glib-2.0/include -I/usr/include/pixman-1 -I/usr/inc=
lude/freetype2 -I/usr/include/libpng14 -I/usr/include/libdrm -I/usr/include=
 -DG_LOG_DOMAIN=3D"LibGimpWidgets" -DGIMP_DISABLE_DEPRECATED -DGDK_MULTIHEA=
D_SAFE -DGTK_MULTIHEAD_SAFE -O2 -march=3Dathlon-xp -pipe -Wall -Wdeclaratio=
n-after-statement -Wmissing-prototypes -Wmissing-declarations -Winit-self -=
Wpointer-arith -Wold-style-definition -MT gimpenumwidgets.lo -MD -MP -MF .d=
eps/gimpenumwidgets.Tpo -c -o gimpenumwidgets.lo gimpenumwidgets.c
> portage    647  0.0  0.1   1924   536 tty3     TN   22:22   0:00         =
                                 \_ /usr/i686-pc-linux-gnu/gcc-bin/4.4.5/i6=
86-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I. -I.. -I.. -pthread -I/usr/include/g=
tk-2.0 -I/usr/lib/gtk-2.0/include -I/usr/include/atk-1.0 -I/usr/include/cai=
ro -I/usr/include/gdk-pixbuf-2.0 -I/usr/include/pango-1.0 -I/usr/include/gl=
ib-2.0 -I/usr/lib/glib-2.0/include -I/usr/include/pixman-1 -I/usr/include/f=
reetype2 -I/usr/include/libpng14 -I/usr/include/libdrm -I/usr/include -DG_L=
OG_DOMAIN=3D"LibGimpWidgets" -DGIMP_DISABLE_DEPRECATED -DGDK_MULTIHEAD_SAFE=
 -DGTK_MULTIHEAD_SAFE -O2 -march=3Dathlon-xp -pipe -Wall -Wdeclaration-afte=
r-statement -Wmissing-prototypes -Wmissing-declarations -Winit-self -Wpoint=
er-arith -Wold-style-definition -MT gimpenumwidgets.lo -MD -MP -MF .deps/gi=
mpenumwidgets.Tpo -c gimpenumwidgets.c -fPIC -DPIC -o .libs/gimpenumwidgets=
=2Eo
> portage    648  0.1  2.3  19448 11284 tty3     TN   22:22   0:00         =
                                     \_ /usr/libexec/gcc/i686-pc-linux-gnu/=
4.4.5/cc1 -quiet -I. -I.. -I.. -I/usr/include/gtk-2.0 -I/usr/lib/gtk-2.0/in=
clude -I/usr/include/atk-1.0 -I/usr/include/cairo -I/usr/include/gdk-pixbuf=
-2.0 -I/usr/include/pango-1.0 -I/usr/include/glib-2.0 -I/usr/lib/glib-2.0/i=
nclude -I/usr/include/pixman-1 -I/usr/include/freetype2 -I/usr/include/libp=
ng14 -I/usr/include/libdrm -I/usr/include -MD .libs/gimpenumwidgets.d -MF .=
deps/gimpenumwidgets.Tpo -MP -MT gimpenumwidgets.lo -D_REENTRANT -DHAVE_CON=
FIG_H -DG_LOG_DOMAIN=3D"LibGimpWidgets" -DGIMP_DISABLE_DEPRECATED -DGDK_MUL=
TIHEAD_SAFE -DGTK_MULTIHEAD_SAFE -DPIC gimpenumwidgets.c -D_FORTIFY_SOURCE=
=3D2 -quiet -dumpbase gimpenumwidgets.c -march=3Dathlon-xp -auxbase-strip .=
libs/gimpenumwidgets.o -O2 -Wall -Wdeclaration-after-statement -Wmissing-pr=
ototypes -Wmissing-declarations -Winit-self -Wpointer-arith -Wold-style-def=
inition -fPIC -o -
> portage    649  0.0  0.6   5284  3116 tty3     TN   22:22   0:00         =
                                     \_ /usr/lib/gcc/i686-pc-linux-gnu/4.4.=
5/../../../../i686-pc-linux-gnu/bin/as -Qy -o .libs/gimpenumwidgets.o -
> root      1379  0.0  0.3   4876  1728 tty4     Ss+  22:14   0:00 -bash
> root      4015  1.2  6.1  34176 29364 tty4     TN   22:18   0:06  \_ /usr=
/bin/python2.7 /usr/bin/emerge --oneshot libetpan
> portage   7306  0.0  0.3   5136  1864 tty4     TN   22:18   0:00      \_ =
/bin/bash /usr/lib/portage/bin/ebuild.sh compile
> portage   7463  0.0  0.5   6132  2460 tty4     TN   22:18   0:00         =
 \_ /bin/bash /usr/lib/portage/bin/ebuild.sh compile
> portage  19334  0.0  0.3   4876  1556 tty4     TN   22:19   0:00         =
     \_ /bin/bash /usr/lib/portage/bin/ebuild-helpers/emake
> portage  19339  0.0  0.2   3848  1032 tty4     TN   22:19   0:00         =
         \_ make -j2
> portage  19736  0.0  0.2   3860   972 tty4     TN   22:19   0:00         =
             \_ make all-recursive
> portage  19737  0.0  0.2   4748  1404 tty4     TN   22:19   0:00         =
                 \_ /bin/sh -c failcom=3D'exit 1'; \?for f in x $MAKEFLAGS;=
 do \?  case $f in \?    *=3D* | --[!k]*);; \?    *k*) failcom=3D'fail=3Dye=
s';; \?  esac; \?done; \?dot_seen=3Dno; \?target=3D`echo all-recursive | se=
d s/-recursive//`; \?list=3D'build-windows include src tests doc'; for subd=
ir in $list; do \?  echo "Making $target in $subdir"; \?  if test "$subdir"=
 =3D "."; then \?    dot_seen=3Dyes; \?    local_target=3D"$target-am"; \? =
 else \?    local_target=3D"$target"; \?  fi; \?  (cd $subdir && make  $loc=
al_target) \?  || eval $failcom; \?done; \?if test "$dot_seen" =3D "no"; th=
en \?  make  "$target-am" || exit 1; \?fi; test -z "$fail"
> portage  19747  0.0  0.1   4748   696 tty4     TN   22:19   0:00         =
                     \_ /bin/sh -c failcom=3D'exit 1'; \?for f in x $MAKEFL=
AGS; do \?  case $f in \?    *=3D* | --[!k]*);; \?    *k*) failcom=3D'fail=
=3Dyes';; \?  esac; \?done; \?dot_seen=3Dno; \?target=3D`echo all-recursive=
 | sed s/-recursive//`; \?list=3D'build-windows include src tests doc'; for=
 subdir in $list; do \?  echo "Making $target in $subdir"; \?  if test "$su=
bdir" =3D "."; then \?    dot_seen=3Dyes; \?    local_target=3D"$target-am"=
; \?  else \?    local_target=3D"$target"; \?  fi; \?  (cd $subdir && make =
 $local_target) \?  || eval $failcom; \?done; \?if test "$dot_seen" =3D "no=
"; then \?  make  "$target-am" || exit 1; \?fi; test -z "$fail"
> portage  19748  0.0  0.2   3848  1052 tty4     TN   22:19   0:00         =
                         \_ make all
> portage  19749  0.0  0.2   3848   980 tty4     TN   22:19   0:00         =
                             \_ make all-recursive
> portage  19750  0.0  0.2   4748  1404 tty4     TN   22:19   0:00         =
                                 \_ /bin/sh -c failcom=3D'exit 1'; \?for f =
in x $MAKEFLAGS; do \?  case $f in \?    *=3D* | --[!k]*);; \?    *k*) fail=
com=3D'fail=3Dyes';; \?  esac; \?done; \?dot_seen=3Dno; \?target=3D`echo al=
l-recursive | sed s/-recursive//`; \?list=3D'bsd  data-types low-level driv=
er main engine'; for subdir in $list; do \?  echo "Making $target in $subdi=
r"; \?  if test "$subdir" =3D "."; then \?    dot_seen=3Dyes; \?    local_t=
arget=3D"$target-am"; \?  else \?    local_target=3D"$target"; \?  fi; \?  =
(cd $subdir && make  $local_target) \?  || eval $failcom; \?done; \?if test=
 "$dot_seen" =3D "no"; then \?  make  "$target-am" || exit 1; \?fi; test -z=
 "$fail"
> portage  23219  0.0  0.1   4748   696 tty4     TN   22:20   0:00         =
                                     \_ /bin/sh -c failcom=3D'exit 1'; \?fo=
r f in x $MAKEFLAGS; do \?  case $f in \?    *=3D* | --[!k]*);; \?    *k*) =
failcom=3D'fail=3Dyes';; \?  esac; \?done; \?dot_seen=3Dno; \?target=3D`ech=
o all-recursive | sed s/-recursive//`; \?list=3D'bsd  data-types low-level =
driver main engine'; for subdir in $list; do \?  echo "Making $target in $s=
ubdir"; \?  if test "$subdir" =3D "."; then \?    dot_seen=3Dyes; \?    loc=
al_target=3D"$target-am"; \?  else \?    local_target=3D"$target"; \?  fi; =
\?  (cd $subdir && make  $local_target) \?  || eval $failcom; \?done; \?if =
test "$dot_seen" =3D "no"; then \?  make  "$target-am" || exit 1; \?fi; tes=
t -z "$fail"
> portage  23220  0.0  0.2   3840  1040 tty4     TN   22:20   0:00         =
                                         \_ make all
> portage  23225  0.0  0.2   3860   968 tty4     TN   22:20   0:00         =
                                             \_ make all-recursive
> portage  23227  0.0  0.2   4748  1404 tty4     TN   22:20   0:00         =
                                                 \_ /bin/sh -c failcom=3D'e=
xit 1'; \?for f in x $MAKEFLAGS; do \?  case $f in \?    *=3D* | --[!k]*);;=
 \?    *k*) failcom=3D'fail=3Dyes';; \?  esac; \?done; \?dot_seen=3Dno; \?t=
arget=3D`echo all-recursive | sed s/-recursive//`; \?list=3D'imap imf maild=
ir mbox mh mime nntp pop3 smtp feed'; for subdir in $list; do \?  echo "Mak=
ing $target in $subdir"; \?  if test "$subdir" =3D "."; then \?    dot_seen=
=3Dyes; \?    local_target=3D"$target-am"; \?  else \?    local_target=3D"$=
target"; \?  fi; \?  (cd $subdir && make  $local_target) \?  || eval $failc=
om; \?done; \?if test "$dot_seen" =3D "no"; then \?  make  "$target-am" || =
exit 1; \?fi; test -z "$fail"
> portage    337  0.0  0.1   4748   696 tty4     TN   22:22   0:00         =
                                                     \_ /bin/sh -c failcom=
=3D'exit 1'; \?for f in x $MAKEFLAGS; do \?  case $f in \?    *=3D* | --[!k=
]*);; \?    *k*) failcom=3D'fail=3Dyes';; \?  esac; \?done; \?dot_seen=3Dno=
; \?target=3D`echo all-recursive | sed s/-recursive//`; \?list=3D'imap imf =
maildir mbox mh mime nntp pop3 smtp feed'; for subdir in $list; do \?  echo=
 "Making $target in $subdir"; \?  if test "$subdir" =3D "."; then \?    dot=
_seen=3Dyes; \?    local_target=3D"$target-am"; \?  else \?    local_target=
=3D"$target"; \?  fi; \?  (cd $subdir && make  $local_target) \?  || eval $=
failcom; \?done; \?if test "$dot_seen" =3D "no"; then \?  make  "$target-am=
" || exit 1; \?fi; test -z "$fail"
> portage    338  0.0  0.2   3944  1064 tty4     TN   22:22   0:00         =
                                                         \_ make all
> portage    342  0.0  0.2   3844  1004 tty4     TN   22:22   0:00         =
                                                             \_ make all-am
> portage    653  0.0  0.4   5532  2176 tty4     TN   22:22   0:00         =
                                                                 \_ /bin/sh=
 ../../../libtool --tag=3DCC --mode=3Dcompile i686-pc-linux-gnu-gcc -DHAVE_=
CONFIG_H -I. -I../../.. -I../../../include -I../../../src/low-level/imf -I.=
=2E/../../src/data-types -DDEBUG -D_REENTRANT -O2 -march=3Dathlon-xp -pipe =
-O2 -g -W -Wall -MT mailmime_content.lo -MD -MP -MF .deps/mailmime_content.=
Tpo -c -o mailmime_content.lo mailmime_content.c
> portage    927  0.0  0.1   1920   532 tty4     TN   22:22   0:00         =
                                                                 |   \_ /us=
r/i686-pc-linux-gnu/gcc-bin/4.4.5/i686-pc-linux-gnu-gcc -DHAVE_CONFIG_H -I.=
 -I../../.. -I../../../include -I../../../src/low-level/imf -I../../../src/=
data-types -DDEBUG -D_REENTRANT -O2 -march=3Dathlon-xp -pipe -O2 -g -W -Wal=
l -MT mailmime_content.lo -MD -MP -MF .deps/mailmime_content.Tpo -c mailmim=
e_content.c -o mailmime_content.o
> portage    930  0.0  0.7  11692  3620 tty4     TN   22:22   0:00         =
                                                                 |       \_=
 /usr/libexec/gcc/i686-pc-linux-gnu/4.4.5/cc1 -quiet -I. -I../../.. -I../..=
/../include -I../../../src/low-level/imf -I../../../src/data-types -MD mail=
mime_content.d -MF .deps/mailmime_content.Tpo -MP -MT mailmime_content.lo -=
DHAVE_CONFIG_H -DDEBUG -D_REENTRANT mailmime_content.c -D_FORTIFY_SOURCE=3D=
2 -quiet -dumpbase mailmime_content.c -march=3Dathlon-xp -auxbase-strip mai=
lmime_content.o -g -O2 -O2 -W -Wall -o -
> portage    932  0.0  0.6   5280  3108 tty4     TN   22:22   0:00         =
                                                                 |       \_=
 /usr/lib/gcc/i686-pc-linux-gnu/4.4.5/../../../../i686-pc-linux-gnu/bin/as =
-Qy -o mailmime_content.o -
> portage    891  0.0  0.4   5400  2156 tty4     TN   22:22   0:00         =
                                                                 \_ /bin/sh=
 ../../../libtool --tag=3DCC --mode=3Dcompile i686-pc-linux-gnu-gcc -DHAVE_=
CONFIG_H -I. -I../../.. -I../../../include -I../../../src/low-level/imf -I.=
=2E/../../src/data-types -DDEBUG -D_REENTRANT -O2 -march=3Dathlon-xp -pipe =
-O2 -g -W -Wall -MT mailmime_disposition.lo -MD -MP -MF .deps/mailmime_disp=
osition.Tpo -c -o mailmime_disposition.lo mailmime_disposition.c
> portage    938  0.0  0.2   5400  1244 tty4     TN   22:22   0:00         =
                                                                     \_ /bi=
n/sh ../../../libtool --tag=3DCC --mode=3Dcompile i686-pc-linux-gnu-gcc -DH=
AVE_CONFIG_H -I. -I../../.. -I../../../include -I../../../src/low-level/imf=
 -I../../../src/data-types -DDEBUG -D_REENTRANT -O2 -march=3Dathlon-xp -pip=
e -O2 -g -W -Wall -MT mailmime_disposition.lo -MD -MP -MF .deps/mailmime_di=
sposition.Tpo -c -o mailmime_disposition.lo mailmime_disposition.c
> portage    939  0.0  0.1   5400   944 tty4     TN   22:22   0:00         =
                                                                         \_=
 /bin/sh ../../../libtool --tag=3DCC --mode=3Dcompile i686-pc-linux-gnu-gcc=
 -DHAVE_CONFIG_H -I. -I../../.. -I../../../include -I../../../src/low-level=
/imf -I../../../src/data-types -DDEBUG -D_REENTRANT -O2 -march=3Dathlon-xp =
-pipe -O2 -g -W -Wall -MT mailmime_disposition.lo -MD -MP -MF .deps/mailmim=
e_disposition.Tpo -c -o mailmime_disposition.lo mailmime_disposition.c
> portage    940  0.0  0.1   5400   944 tty4     TN   22:22   0:00         =
                                                                         \_=
 /bin/sh ../../../libtool --tag=3DCC --mode=3Dcompile i686-pc-linux-gnu-gcc=
 -DHAVE_CONFIG_H -I. -I../../.. -I../../../include -I../../../src/low-level=
/imf -I../../../src/data-types -DDEBUG -D_REENTRANT -O2 -march=3Dathlon-xp =
-pipe -O2 -g -W -Wall -MT mailmime_disposition.lo -MD -MP -MF .deps/mailmim=
e_disposition.Tpo -c -o mailmime_disposition.lo mailmime_disposition.c
> root      1380  0.0  0.3   4876  1728 tty5     Ss   22:14   0:00 -bash
> root      1792  2.6  0.2   2420  1156 tty5     S+   22:16   0:15  \_ top
> root      1381  0.0  0.1   1892   768 tty6     Ss+  22:14   0:00 /sbin/ag=
etty 38400 tty6 linux
> root      1521  0.0  0.0   1928   356 ?        Ss   22:14   0:00 dhcpcd -=
m 2 eth0
> root      1562  0.0  0.1   5128   544 ?        S    22:14   0:00 supervis=
ing syslog-ng
> root      1563  0.0  0.4   5408  1968 ?        Ss   22:14   0:00  \_ /usr=
/sbin/syslog-ng
> ntp       1587  0.0  0.2   4360  1352 ?        Ss   22:14   0:00 /usr/sbi=
n/ntpd -p /var/run/ntpd.pid -u ntp:ntp
> collectd  1605  0.6  0.7  49924  3748 ?        SNLsl 22:14   0:04 /usr/sb=
in/collectd -P /var/run/collectd/collectd.pid -C /etc/collectd.conf
> root      1623  0.0  0.1   1944   508 ?        Ss   22:14   0:00 /usr/sbi=
n/gpm -m /dev/input/mice -t ps2
> root      1663  0.0  0.1   2116   760 ?        Ss   22:14   0:00 /sbin/rp=
cbind
> root      1677  0.0  0.2   2188   968 ?        Ss   22:14   0:00 /sbin/rp=
c.statd --no-notify
> root      1737  0.0  0.2   4204   988 ?        Ss   22:15   0:00 /usr/sbi=
n/sshd
> root       942  0.0  0.4   6872  2252 ?        Ss   22:23   0:00  \_ sshd=
: root@pts/2=20
> root       944  0.0  0.3   4876  1780 pts/2    Ss   22:23   0:00      \_ =
-bash
> root       961  0.0  0.2   4124   964 pts/2    R+   22:26   0:00         =
 \_ ps auxf
> root      1766  0.0  0.1   1892   780 tty1     Ss+  22:15   0:00 /sbin/ag=
etty 38400 tty1 linux
> root      1767  0.0  0.1   1892   784 ttyS0    Ss+  22:15   0:00 /sbin/ag=
etty 115200 ttyS0 vt100

> slabinfo - version: 2.1
> # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesp=
erslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_s=
labs> <num_slabs> <sharedavail>
> squashfs_inode_cache   1900   1900    384   10    1 : tunables    0    0 =
   0 : slabdata    190    190      0
> nfs_direct_cache       0      0     88   46    1 : tunables    0    0    =
0 : slabdata      0      0      0
> nfs_write_data        40     40    480    8    1 : tunables    0    0    =
0 : slabdata      5      5      0
> nfs_read_data         36     36    448    9    1 : tunables    0    0    =
0 : slabdata      4      4      0
> nfs_inode_cache       70     70    576   14    2 : tunables    0    0    =
0 : slabdata      5      5      0
> nfs_page              42     42     96   42    1 : tunables    0    0    =
0 : slabdata      1      1      0
> rpc_buffers           15     15   2080   15    8 : tunables    0    0    =
0 : slabdata      1      1      0
> rpc_tasks             25     25    160   25    1 : tunables    0    0    =
0 : slabdata      1      1      0
> rpc_inode_cache       36     36    448    9    1 : tunables    0    0    =
0 : slabdata      4      4      0
> fib6_nodes            64     64     64   64    1 : tunables    0    0    =
0 : slabdata      1      1      0
> ip6_dst_cache         29     42    192   21    1 : tunables    0    0    =
0 : slabdata      2      2      0
> ndisc_cache           21     21    192   21    1 : tunables    0    0    =
0 : slabdata      1      1      0
> RAWv6                 12     12    672   12    2 : tunables    0    0    =
0 : slabdata      1      1      0
> UDPLITEv6              0      0    672   12    2 : tunables    0    0    =
0 : slabdata      0      0      0
> UDPv6                 12     12    672   12    2 : tunables    0    0    =
0 : slabdata      1      1      0
> tw_sock_TCPv6          0      0    160   25    1 : tunables    0    0    =
0 : slabdata      0      0      0
> request_sock_TCPv6     32     32    128   32    1 : tunables    0    0   =
 0 : slabdata      1      1      0
> TCPv6                 12     12   1312   12    4 : tunables    0    0    =
0 : slabdata      1      1      0
> aoe_bufs               0      0     64   64    1 : tunables    0    0    =
0 : slabdata      0      0      0
> scsi_sense_cache      32     32    128   32    1 : tunables    0    0    =
0 : slabdata      1      1      0
> scsi_cmd_cache        25     25    160   25    1 : tunables    0    0    =
0 : slabdata      1      1      0
> sd_ext_cdb            85     85     48   85    1 : tunables    0    0    =
0 : slabdata      1      1      0
> cfq_io_context       102    102     80   51    1 : tunables    0    0    =
0 : slabdata      2      2      0
> cfq_queue             41     50    160   25    1 : tunables    0    0    =
0 : slabdata      2      2      0
> mqueue_inode_cache      8      8    512    8    1 : tunables    0    0   =
 0 : slabdata      1      1      0
> xfs_buf                0      0    192   21    1 : tunables    0    0    =
0 : slabdata      0      0      0
> fstrm_item             0      0     24  170    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_mru_cache_elem      0      0     32  128    1 : tunables    0    0   =
 0 : slabdata      0      0      0
> xfs_ili                0      0    168   24    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_inode              0      0    608   13    2 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_efi_item           0      0    296   13    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_efd_item           0      0    296   13    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_buf_item           0      0    184   22    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_log_item_desc      0      0     32  128    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_trans              0      0    240   17    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_ifork              0      0     72   56    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_dabuf              0      0     32  128    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_da_state           0      0    352   11    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_btree_cur          0      0    160   25    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_bmap_free_item      0      0     32  128    1 : tunables    0    0   =
 0 : slabdata      0      0      0
> xfs_log_ticket         0      0    192   21    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_ioend             51     51     80   51    1 : tunables    0    0    =
0 : slabdata      1      1      0
> reiser_inode_cache  12780  12780    400   10    1 : tunables    0    0   =
 0 : slabdata   1278   1278      0
> configfs_dir_cache     64     64     64   64    1 : tunables    0    0   =
 0 : slabdata      1      1      0
> kioctx                 0      0    224   18    1 : tunables    0    0    =
0 : slabdata      0      0      0
> kiocb                  0      0    128   32    1 : tunables    0    0    =
0 : slabdata      0      0      0
> inotify_event_private_data    128    128     32  128    1 : tunables    0=
    0    0 : slabdata      1      1      0
> inotify_inode_mark     46     46     88   46    1 : tunables    0    0   =
 0 : slabdata      1      1      0
> fasync_cache           0      0     40  102    1 : tunables    0    0    =
0 : slabdata      0      0      0
> khugepaged_mm_slot      0      0     32  128    1 : tunables    0    0   =
 0 : slabdata      0      0      0
> nsproxy                0      0     40  102    1 : tunables    0    0    =
0 : slabdata      0      0      0
> posix_timers_cache      0      0    128   32    1 : tunables    0    0   =
 0 : slabdata      0      0      0
> uid_cache             42     42     96   42    1 : tunables    0    0    =
0 : slabdata      1      1      0
> UNIX                  25     27    448    9    1 : tunables    0    0    =
0 : slabdata      3      3      0
> UDP-Lite               0      0    544   15    2 : tunables    0    0    =
0 : slabdata      0      0      0
> tcp_bind_bucket      128    128     32  128    1 : tunables    0    0    =
0 : slabdata      1      1      0
> inet_peer_cache       21     21    192   21    1 : tunables    0    0    =
0 : slabdata      1      1      0
> ip_fib_trie          102    102     40  102    1 : tunables    0    0    =
0 : slabdata      1      1      0
> ip_fib_alias         102    102     40  102    1 : tunables    0    0    =
0 : slabdata      1      1      0
> ip_dst_cache          50     50    160   25    1 : tunables    0    0    =
0 : slabdata      2      2      0
> arp_cache             21     21    192   21    1 : tunables    0    0    =
0 : slabdata      1      1      0
> RAW                    8      8    512    8    1 : tunables    0    0    =
0 : slabdata      1      1      0
> UDP                   15     15    544   15    2 : tunables    0    0    =
0 : slabdata      1      1      0
> tw_sock_TCP           32     32    128   32    1 : tunables    0    0    =
0 : slabdata      1      1      0
> request_sock_TCP      42     42     96   42    1 : tunables    0    0    =
0 : slabdata      1      1      0
> TCP                   13     13   1184   13    4 : tunables    0    0    =
0 : slabdata      1      1      0
> eventpoll_pwq          0      0     48   85    1 : tunables    0    0    =
0 : slabdata      0      0      0
> eventpoll_epi          0      0     96   42    1 : tunables    0    0    =
0 : slabdata      0      0      0
> sgpool-128            12     12   2592   12    8 : tunables    0    0    =
0 : slabdata      1      1      0
> sgpool-64             12     12   1312   12    4 : tunables    0    0    =
0 : slabdata      1      1      0
> sgpool-32             12     12    672   12    2 : tunables    0    0    =
0 : slabdata      1      1      0
> sgpool-16             11     11    352   11    1 : tunables    0    0    =
0 : slabdata      1      1      0
> sgpool-8              21     21    192   21    1 : tunables    0    0    =
0 : slabdata      1      1      0
> scsi_data_buffer       0      0     32  128    1 : tunables    0    0    =
0 : slabdata      0      0      0
> blkdev_queue          17     17    936   17    4 : tunables    0    0    =
0 : slabdata      1      1      0
> blkdev_requests       26     36    224   18    1 : tunables    0    0    =
0 : slabdata      2      2      0
> blkdev_ioc            73     73     56   73    1 : tunables    0    0    =
0 : slabdata      1      1      0
> fsnotify_event_holder      0      0     24  170    1 : tunables    0    0=
    0 : slabdata      0      0      0
> fsnotify_event        56     56     72   56    1 : tunables    0    0    =
0 : slabdata      1      1      0
> bio-0                 27     50    160   25    1 : tunables    0    0    =
0 : slabdata      2      2      0
> biovec-256            10     10   3104   10    8 : tunables    0    0    =
0 : slabdata      1      1      0
> biovec-128             0      0   1568   10    4 : tunables    0    0    =
0 : slabdata      0      0      0
> biovec-64             10     10    800   10    2 : tunables    0    0    =
0 : slabdata      1      1      0
> biovec-16             18     18    224   18    1 : tunables    0    0    =
0 : slabdata      1      1      0
> sock_inode_cache      70     77    352   11    1 : tunables    0    0    =
0 : slabdata      7      7      0
> skbuff_fclone_cache     11     11    352   11    1 : tunables    0    0  =
  0 : slabdata      1      1      0
> skbuff_head_cache    511    546    192   21    1 : tunables    0    0    =
0 : slabdata     26     26      0
> file_lock_cache       36     36    112   36    1 : tunables    0    0    =
0 : slabdata      1      1      0
> shmem_inode_cache    894    910    408   10    1 : tunables    0    0    =
0 : slabdata     91     91      0
> Acpi-Operand         949    949     56   73    1 : tunables    0    0    =
0 : slabdata     13     13      0
> Acpi-ParseExt         64     64     64   64    1 : tunables    0    0    =
0 : slabdata      1      1      0
> Acpi-Parse            85     85     48   85    1 : tunables    0    0    =
0 : slabdata      1      1      0
> Acpi-State            73     73     56   73    1 : tunables    0    0    =
0 : slabdata      1      1      0
> Acpi-Namespace       612    612     40  102    1 : tunables    0    0    =
0 : slabdata      6      6      0
> proc_inode_cache    4393   4393    344   23    2 : tunables    0    0    =
0 : slabdata    191    191      0
> sigqueue              32     50    160   25    1 : tunables    0    0    =
0 : slabdata      2      2      0
> bdev_cache            13     18    448    9    1 : tunables    0    0    =
0 : slabdata      2      2      0
> sysfs_dir_cache    13696  13696     64   64    1 : tunables    0    0    =
0 : slabdata    214    214      0
> mnt_cache             50     50    160   25    1 : tunables    0    0    =
0 : slabdata      2      2      0
> filp              209184 209184    128   32    1 : tunables    0    0    =
0 : slabdata   6537   6537      0
> inode_cache         3972   3972    320   12    1 : tunables    0    0    =
0 : slabdata    331    331      0
> dentry             35700  35700    144   28    1 : tunables    0    0    =
0 : slabdata   1275   1275      0
> names_cache            7      7   4128    7    8 : tunables    0    0    =
0 : slabdata      1      1      0
> buffer_head        13166  37856     72   56    1 : tunables    0    0    =
0 : slabdata    676    676      0
> vm_area_struct      2508   2535    104   39    1 : tunables    0    0    =
0 : slabdata     65     65      0
> mm_struct             68     72    448    9    1 : tunables    0    0    =
0 : slabdata      8      8      0
> fs_cache             128    128     64   64    1 : tunables    0    0    =
0 : slabdata      2      2      0
> files_cache         4240   4242    192   21    1 : tunables    0    0    =
0 : slabdata    202    202      0
> signal_cache        7040   7040    512    8    1 : tunables    0    0    =
0 : slabdata    880    880      0
> sighand_cache        102    108   1312   12    4 : tunables    0    0    =
0 : slabdata      9      9      0
> task_xstate          350    350    576   14    2 : tunables    0    0    =
0 : slabdata     25     25      0
> task_struct         7049   7049    832   19    4 : tunables    0    0    =
0 : slabdata    371    371      0
> cred_jar           18496  18496    128   32    1 : tunables    0    0    =
0 : slabdata    578    578      0
> anon_vma_chain      2371   2448     40  102    1 : tunables    0    0    =
0 : slabdata     24     24      0
> anon_vma            1432   1536     32  128    1 : tunables    0    0    =
0 : slabdata     12     12      0
> pid                 7104   7104     64   64    1 : tunables    0    0    =
0 : slabdata    111    111      0
> radix_tree_node     6422   6422    312   13    1 : tunables    0    0    =
0 : slabdata    494    494      0
> idr_layer_cache      273    275    160   25    1 : tunables    0    0    =
0 : slabdata     11     11      0
> dma-kmalloc-8192       0      0   8208    3    8 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-4096       0      0   4112    7    8 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-2048       0      0   2064   15    8 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-1024       0      0   1040   15    4 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-512        0      0    528   15    2 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-256        0      0    272   15    1 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-128        0      0    144   28    1 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-64         0      0     80   51    1 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-32         0      0     48   85    1 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-16         0      0     32  128    1 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-8          0      0     24  170    1 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-192        0      0    208   19    1 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-96         0      0    112   36    1 : tunables    0    0    =
0 : slabdata      0      0      0
> kmalloc-8192          12     12   8208    3    8 : tunables    0    0    =
0 : slabdata      4      4      0
> kmalloc-4096         300    301   4112    7    8 : tunables    0    0    =
0 : slabdata     43     43      0
> kmalloc-2048         556    570   2064   15    8 : tunables    0    0    =
0 : slabdata     38     38      0
> kmalloc-1024        2984   2985   1040   15    4 : tunables    0    0    =
0 : slabdata    199    199      0
> kmalloc-512          431    435    528   15    2 : tunables    0    0    =
0 : slabdata     29     29      0
> kmalloc-256           44     45    272   15    1 : tunables    0    0    =
0 : slabdata      3      3      0
> kmalloc-128          336    336    144   28    1 : tunables    0    0    =
0 : slabdata     12     12      0
> kmalloc-64          3822   3825     80   51    1 : tunables    0    0    =
0 : slabdata     75     75      0
> kmalloc-32          4505   4505     48   85    1 : tunables    0    0    =
0 : slabdata     53     53      0
> kmalloc-16          2363   5248     32  128    1 : tunables    0    0    =
0 : slabdata     41     41      0
> kmalloc-8           3569   3570     24  170    1 : tunables    0    0    =
0 : slabdata     21     21      0
> kmalloc-192          133    133    208   19    1 : tunables    0    0    =
0 : slabdata      7      7      0
> kmalloc-96          1008   1008    112   36    1 : tunables    0    0    =
0 : slabdata     28     28      0
> kmem_cache            32     32    128   32    1 : tunables    0    0    =
0 : slabdata      1      1      0
> kmem_cache_node      192    192     64   64    1 : tunables    0    0    =
0 : slabdata      3      3      0

> MemTotal:         480420 kB
> MemFree:          233396 kB
> Buffers:           38816 kB
> Cached:            34944 kB
> SwapCached:          128 kB
> Active:            53088 kB
> Inactive:          28216 kB
> Active(anon):       1844 kB
> Inactive(anon):     4924 kB
> Active(file):      51244 kB
> Inactive(file):    23292 kB
> Unevictable:          32 kB
> Mlocked:              32 kB
> SwapTotal:        524284 kB
> SwapFree:         524156 kB
> Dirty:                32 kB
> Writeback:             0 kB
> AnonPages:          6580 kB
> Mapped:             5456 kB
> Shmem:               112 kB
> Slab:              97772 kB
> SReclaimable:      19920 kB
> SUnreclaim:        77852 kB
> KernelStack:       62800 kB
> PageTables:          460 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:      764492 kB
> Committed_AS:      56340 kB
> VmallocTotal:     548548 kB
> VmallocUsed:        8392 kB
> VmallocChunk:     534328 kB
> AnonHugePages:         0 kB
> DirectMap4k:       16320 kB
> DirectMap4M:      475136 kB

> USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
> root         2  0.0  0.0      0     0 ?        S    22:14   0:00 [kthread=
d]
> root         3  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [kso=
ftirqd/0]
> root         6  0.0  0.0      0     0 ?        R    22:14   0:00  \_ [rcu=
_kthread]
> root         7  0.0  0.0      0     0 ?        R    22:14   0:00  \_ [wat=
chdog/0]
> root         8  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [khe=
lper]
> root       138  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [syn=
c_supers]
> root       140  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [bdi=
-default]
> root       142  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [kbl=
ockd]
> root       230  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [ata=
_sff]
> root       237  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [khu=
bd]
> root       365  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [ksw=
apd0]
> root       464  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [fsn=
otify_mark]
> root       486  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfs=
_mru_cache]
> root       489  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfs=
logd]
> root       490  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfs=
datad]
> root       491  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [xfs=
convertd]
> root       554  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scs=
i_eh_0]
> root       559  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scs=
i_eh_1]
> root       573  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scs=
i_eh_2]
> root       576  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scs=
i_eh_3]
> root       579  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [kwo=
rker/u:4]
> root       580  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [kwo=
rker/u:5]
> root       589  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scs=
i_eh_4]
> root       592  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [scs=
i_eh_5]
> root       655  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [kps=
moused]
> root       706  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [rei=
serfs]
> root      1486  0.0  0.0      0     0 ?        S    22:14   0:00  \_ [flu=
sh-8:0]
> root      1692  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [rpc=
iod]
> root      1693  0.0  0.0      0     0 ?        S<   22:14   0:00  \_ [nfs=
iod]
> root      1697  0.0  0.0      0     0 ?        S    22:15   0:00  \_ [loc=
kd]
> root       976  0.0  0.0      0     0 ?        S    22:30   0:00  \_ [kwo=
rker/0:0]
> root      1004  0.0  0.0      0     0 ?        S    22:38   0:00  \_ [kwo=
rker/0:1]
> root         1  0.1  0.1   1740   588 ?        Ss   22:14   0:02 init [3]=
 =20
> root       823  0.0  0.1   2132   824 ?        S<s  22:14   0:00 /sbin/ud=
evd --daemon
> root      1778  0.0  0.1   2128   696 ?        S<   22:15   0:00  \_ /sbi=
n/udevd --daemon
> root      1377  0.0  0.3   4876  1780 tty2     Ss   22:14   0:00 -bash
> root      1145  0.0  0.2   2276   988 tty2     S+   22:40   0:00  \_ slab=
top
> root      1381  0.0  0.1   1892   768 tty6     Ss+  22:14   0:00 /sbin/ag=
etty 38400 tty6 linux
> root      1521  0.0  0.0   1928   356 ?        Ss   22:14   0:00 dhcpcd -=
m 2 eth0
> root      1562  0.0  0.1   5128   544 ?        S    22:14   0:00 supervis=
ing syslog-ng
> root      1563  0.0  0.4   5408  1968 ?        Ss   22:14   0:00  \_ /usr=
/sbin/syslog-ng
> ntp       1587  0.0  0.2   4360  1352 ?        Ss   22:14   0:00 /usr/sbi=
n/ntpd -p /var/run/ntpd.pid -u ntp:ntp
> collectd  1605  0.6  0.7  49924  3748 ?        SNLsl 22:14   0:14 /usr/sb=
in/collectd -P /var/run/collectd/collectd.pid -C /etc/collectd.conf
> root      1623  0.0  0.1   1944   508 ?        Ss   22:14   0:00 /usr/sbi=
n/gpm -m /dev/input/mice -t ps2
> root      1663  0.0  0.1   2116   760 ?        Ss   22:14   0:00 /sbin/rp=
cbind
> root      1677  0.0  0.2   2188   968 ?        Ss   22:14   0:00 /sbin/rp=
c.statd --no-notify
> root      1737  0.0  0.2   4204   988 ?        Ss   22:15   0:00 /usr/sbi=
n/sshd
> root       942  0.0  0.4   7004  2264 ?        Ss   22:23   0:00  \_ sshd=
: root@pts/2=20
> root       944  0.0  0.3   4876  1812 pts/2    Ss   22:23   0:00      \_ =
-bash
> root      1791  0.0  0.1   4124   960 pts/2    R+   22:53   0:00         =
 \_ ps auxf
> root      1766  0.0  0.1   1892   780 tty1     Ss+  22:15   0:00 /sbin/ag=
etty 38400 tty1 linux
> root      1767  0.0  0.1   1892   784 ttyS0    Ss+  22:15   0:00 /sbin/ag=
etty 115200 ttyS0 vt100
> root       982  0.0  0.1   1892   784 tty5     Ss+  22:38   0:00 /sbin/ag=
etty 38400 tty5 linux
> root      1011  0.0  0.3   4876  1748 tty3     Ss+  22:38   0:00 -bash
> root      1126  0.0  0.1   1892   780 tty4     Ss+  22:38   0:00 /sbin/ag=
etty 38400 tty4 linux

> slabinfo - version: 2.1
> # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesp=
erslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_s=
labs> <num_slabs> <sharedavail>
> squashfs_inode_cache   1920   1920    384   10    1 : tunables    0    0 =
   0 : slabdata    192    192      0
> nfs_direct_cache       0      0     88   46    1 : tunables    0    0    =
0 : slabdata      0      0      0
> nfs_write_data        40     40    480    8    1 : tunables    0    0    =
0 : slabdata      5      5      0
> nfs_read_data         36     36    448    9    1 : tunables    0    0    =
0 : slabdata      4      4      0
> nfs_inode_cache       70     70    576   14    2 : tunables    0    0    =
0 : slabdata      5      5      0
> nfs_page              42     42     96   42    1 : tunables    0    0    =
0 : slabdata      1      1      0
> rpc_buffers           15     15   2080   15    8 : tunables    0    0    =
0 : slabdata      1      1      0
> rpc_tasks             25     25    160   25    1 : tunables    0    0    =
0 : slabdata      1      1      0
> rpc_inode_cache       36     36    448    9    1 : tunables    0    0    =
0 : slabdata      4      4      0
> fib6_nodes            64     64     64   64    1 : tunables    0    0    =
0 : slabdata      1      1      0
> ip6_dst_cache         29     42    192   21    1 : tunables    0    0    =
0 : slabdata      2      2      0
> ndisc_cache           21     21    192   21    1 : tunables    0    0    =
0 : slabdata      1      1      0
> RAWv6                 12     12    672   12    2 : tunables    0    0    =
0 : slabdata      1      1      0
> UDPLITEv6              0      0    672   12    2 : tunables    0    0    =
0 : slabdata      0      0      0
> UDPv6                 12     12    672   12    2 : tunables    0    0    =
0 : slabdata      1      1      0
> tw_sock_TCPv6          0      0    160   25    1 : tunables    0    0    =
0 : slabdata      0      0      0
> request_sock_TCPv6     32     32    128   32    1 : tunables    0    0   =
 0 : slabdata      1      1      0
> TCPv6                 12     12   1312   12    4 : tunables    0    0    =
0 : slabdata      1      1      0
> aoe_bufs               0      0     64   64    1 : tunables    0    0    =
0 : slabdata      0      0      0
> scsi_sense_cache      32     32    128   32    1 : tunables    0    0    =
0 : slabdata      1      1      0
> scsi_cmd_cache        25     25    160   25    1 : tunables    0    0    =
0 : slabdata      1      1      0
> sd_ext_cdb            85     85     48   85    1 : tunables    0    0    =
0 : slabdata      1      1      0
> cfq_io_context       153    153     80   51    1 : tunables    0    0    =
0 : slabdata      3      3      0
> cfq_queue             36     50    160   25    1 : tunables    0    0    =
0 : slabdata      2      2      0
> mqueue_inode_cache      8      8    512    8    1 : tunables    0    0   =
 0 : slabdata      1      1      0
> xfs_buf                0      0    192   21    1 : tunables    0    0    =
0 : slabdata      0      0      0
> fstrm_item             0      0     24  170    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_mru_cache_elem      0      0     32  128    1 : tunables    0    0   =
 0 : slabdata      0      0      0
> xfs_ili                0      0    168   24    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_inode              0      0    608   13    2 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_efi_item           0      0    296   13    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_efd_item           0      0    296   13    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_buf_item           0      0    184   22    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_log_item_desc      0      0     32  128    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_trans              0      0    240   17    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_ifork              0      0     72   56    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_dabuf              0      0     32  128    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_da_state           0      0    352   11    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_btree_cur          0      0    160   25    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_bmap_free_item      0      0     32  128    1 : tunables    0    0   =
 0 : slabdata      0      0      0
> xfs_log_ticket         0      0    192   21    1 : tunables    0    0    =
0 : slabdata      0      0      0
> xfs_ioend             51     51     80   51    1 : tunables    0    0    =
0 : slabdata      1      1      0
> reiser_inode_cache  13050  13050    400   10    1 : tunables    0    0   =
 0 : slabdata   1305   1305      0
> configfs_dir_cache     64     64     64   64    1 : tunables    0    0   =
 0 : slabdata      1      1      0
> kioctx                 0      0    224   18    1 : tunables    0    0    =
0 : slabdata      0      0      0
> kiocb                  0      0    128   32    1 : tunables    0    0    =
0 : slabdata      0      0      0
> inotify_event_private_data    128    128     32  128    1 : tunables    0=
    0    0 : slabdata      1      1      0
> inotify_inode_mark     46     46     88   46    1 : tunables    0    0   =
 0 : slabdata      1      1      0
> fasync_cache           0      0     40  102    1 : tunables    0    0    =
0 : slabdata      0      0      0
> khugepaged_mm_slot      0      0     32  128    1 : tunables    0    0   =
 0 : slabdata      0      0      0
> nsproxy                0      0     40  102    1 : tunables    0    0    =
0 : slabdata      0      0      0
> posix_timers_cache      0      0    128   32    1 : tunables    0    0   =
 0 : slabdata      0      0      0
> uid_cache             42     42     96   42    1 : tunables    0    0    =
0 : slabdata      1      1      0
> UNIX                  25     27    448    9    1 : tunables    0    0    =
0 : slabdata      3      3      0
> UDP-Lite               0      0    544   15    2 : tunables    0    0    =
0 : slabdata      0      0      0
> tcp_bind_bucket      128    128     32  128    1 : tunables    0    0    =
0 : slabdata      1      1      0
> inet_peer_cache       21     21    192   21    1 : tunables    0    0    =
0 : slabdata      1      1      0
> ip_fib_trie          102    102     40  102    1 : tunables    0    0    =
0 : slabdata      1      1      0
> ip_fib_alias         102    102     40  102    1 : tunables    0    0    =
0 : slabdata      1      1      0
> ip_dst_cache          50     50    160   25    1 : tunables    0    0    =
0 : slabdata      2      2      0
> arp_cache             21     21    192   21    1 : tunables    0    0    =
0 : slabdata      1      1      0
> RAW                    8      8    512    8    1 : tunables    0    0    =
0 : slabdata      1      1      0
> UDP                   15     15    544   15    2 : tunables    0    0    =
0 : slabdata      1      1      0
> tw_sock_TCP           32     32    128   32    1 : tunables    0    0    =
0 : slabdata      1      1      0
> request_sock_TCP      42     42     96   42    1 : tunables    0    0    =
0 : slabdata      1      1      0
> TCP                   13     13   1184   13    4 : tunables    0    0    =
0 : slabdata      1      1      0
> eventpoll_pwq          0      0     48   85    1 : tunables    0    0    =
0 : slabdata      0      0      0
> eventpoll_epi          0      0     96   42    1 : tunables    0    0    =
0 : slabdata      0      0      0
> sgpool-128            12     12   2592   12    8 : tunables    0    0    =
0 : slabdata      1      1      0
> sgpool-64             12     12   1312   12    4 : tunables    0    0    =
0 : slabdata      1      1      0
> sgpool-32             12     12    672   12    2 : tunables    0    0    =
0 : slabdata      1      1      0
> sgpool-16             11     11    352   11    1 : tunables    0    0    =
0 : slabdata      1      1      0
> sgpool-8              21     21    192   21    1 : tunables    0    0    =
0 : slabdata      1      1      0
> scsi_data_buffer       0      0     32  128    1 : tunables    0    0    =
0 : slabdata      0      0      0
> blkdev_queue          17     17    936   17    4 : tunables    0    0    =
0 : slabdata      1      1      0
> blkdev_requests       26     36    224   18    1 : tunables    0    0    =
0 : slabdata      2      2      0
> blkdev_ioc            73     73     56   73    1 : tunables    0    0    =
0 : slabdata      1      1      0
> fsnotify_event_holder      0      0     24  170    1 : tunables    0    0=
    0 : slabdata      0      0      0
> fsnotify_event        56     56     72   56    1 : tunables    0    0    =
0 : slabdata      1      1      0
> bio-0                 25     25    160   25    1 : tunables    0    0    =
0 : slabdata      1      1      0
> biovec-256            10     10   3104   10    8 : tunables    0    0    =
0 : slabdata      1      1      0
> biovec-128             0      0   1568   10    4 : tunables    0    0    =
0 : slabdata      0      0      0
> biovec-64             10     10    800   10    2 : tunables    0    0    =
0 : slabdata      1      1      0
> biovec-16             18     18    224   18    1 : tunables    0    0    =
0 : slabdata      1      1      0
> sock_inode_cache      70     77    352   11    1 : tunables    0    0    =
0 : slabdata      7      7      0
> skbuff_fclone_cache     11     11    352   11    1 : tunables    0    0  =
  0 : slabdata      1      1      0
> skbuff_head_cache    517    567    192   21    1 : tunables    0    0    =
0 : slabdata     27     27      0
> file_lock_cache       36     36    112   36    1 : tunables    0    0    =
0 : slabdata      1      1      0
> shmem_inode_cache    910    910    408   10    1 : tunables    0    0    =
0 : slabdata     91     91      0
> Acpi-Operand         949    949     56   73    1 : tunables    0    0    =
0 : slabdata     13     13      0
> Acpi-ParseExt         64     64     64   64    1 : tunables    0    0    =
0 : slabdata      1      1      0
> Acpi-Parse            85     85     48   85    1 : tunables    0    0    =
0 : slabdata      1      1      0
> Acpi-State            73     73     56   73    1 : tunables    0    0    =
0 : slabdata      1      1      0
> Acpi-Namespace       612    612     40  102    1 : tunables    0    0    =
0 : slabdata      6      6      0
> proc_inode_cache    6256   6256    344   23    2 : tunables    0    0    =
0 : slabdata    272    272      0
> sigqueue              25     25    160   25    1 : tunables    0    0    =
0 : slabdata      1      1      0
> bdev_cache            13     18    448    9    1 : tunables    0    0    =
0 : slabdata      2      2      0
> sysfs_dir_cache    13696  13696     64   64    1 : tunables    0    0    =
0 : slabdata    214    214      0
> mnt_cache             50     50    160   25    1 : tunables    0    0    =
0 : slabdata      2      2      0
> filp              422592 422592    128   32    1 : tunables    0    0    =
0 : slabdata  13206  13206      0
> inode_cache         3954   3972    320   12    1 : tunables    0    0    =
0 : slabdata    331    331      0
> dentry             39312  39312    144   28    1 : tunables    0    0    =
0 : slabdata   1404   1404      0
> names_cache            7      7   4128    7    8 : tunables    0    0    =
0 : slabdata      1      1      0
> buffer_head        13560  37856     72   56    1 : tunables    0    0    =
0 : slabdata    676    676      0
> vm_area_struct       862   1053    104   39    1 : tunables    0    0    =
0 : slabdata     27     27      0
> mm_struct             27     54    448    9    1 : tunables    0    0    =
0 : slabdata      6      6      0
> fs_cache              80    128     64   64    1 : tunables    0    0    =
0 : slabdata      2      2      0
> files_cache         4325   4326    192   21    1 : tunables    0    0    =
0 : slabdata    206    206      0
> signal_cache        7848   7848    512    8    1 : tunables    0    0    =
0 : slabdata    981    981      0
> sighand_cache         64    108   1312   12    4 : tunables    0    0    =
0 : slabdata      9      9      0
> task_xstate          392    392    576   14    2 : tunables    0    0    =
0 : slabdata     28     28      0
> task_struct         7866   7866    832   19    4 : tunables    0    0    =
0 : slabdata    414    414      0
> cred_jar           21792  21792    128   32    1 : tunables    0    0    =
0 : slabdata    681    681      0
> anon_vma_chain      1033   1632     40  102    1 : tunables    0    0    =
0 : slabdata     16     16      0
> anon_vma             707    896     32  128    1 : tunables    0    0    =
0 : slabdata      7      7      0
> pid                 7872   7872     64   64    1 : tunables    0    0    =
0 : slabdata    123    123      0
> radix_tree_node     6565   6565    312   13    1 : tunables    0    0    =
0 : slabdata    505    505      0
> idr_layer_cache      269    275    160   25    1 : tunables    0    0    =
0 : slabdata     11     11      0
> dma-kmalloc-8192       0      0   8208    3    8 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-4096       0      0   4112    7    8 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-2048       0      0   2064   15    8 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-1024       0      0   1040   15    4 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-512        0      0    528   15    2 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-256        0      0    272   15    1 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-128        0      0    144   28    1 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-64         0      0     80   51    1 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-32         0      0     48   85    1 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-16         0      0     32  128    1 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-8          0      0     24  170    1 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-192        0      0    208   19    1 : tunables    0    0    =
0 : slabdata      0      0      0
> dma-kmalloc-96         0      0    112   36    1 : tunables    0    0    =
0 : slabdata      0      0      0
> kmalloc-8192          12     12   8208    3    8 : tunables    0    0    =
0 : slabdata      4      4      0
> kmalloc-4096         285    294   4112    7    8 : tunables    0    0    =
0 : slabdata     42     42      0
> kmalloc-2048         547    555   2064   15    8 : tunables    0    0    =
0 : slabdata     37     37      0
> kmalloc-1024        3690   3690   1040   15    4 : tunables    0    0    =
0 : slabdata    246    246      0
> kmalloc-512          422    435    528   15    2 : tunables    0    0    =
0 : slabdata     29     29      0
> kmalloc-256           44     45    272   15    1 : tunables    0    0    =
0 : slabdata      3      3      0
> kmalloc-128          336    336    144   28    1 : tunables    0    0    =
0 : slabdata     12     12      0
> kmalloc-64          4486   4488     80   51    1 : tunables    0    0    =
0 : slabdata     88     88      0
> kmalloc-32          5354   5355     48   85    1 : tunables    0    0    =
0 : slabdata     63     63      0
> kmalloc-16          2351   5248     32  128    1 : tunables    0    0    =
0 : slabdata     41     41      0
> kmalloc-8           3566   3570     24  170    1 : tunables    0    0    =
0 : slabdata     21     21      0
> kmalloc-192          152    152    208   19    1 : tunables    0    0    =
0 : slabdata      8      8      0
> kmalloc-96          1038   1044    112   36    1 : tunables    0    0    =
0 : slabdata     29     29      0
> kmem_cache            32     32    128   32    1 : tunables    0    0    =
0 : slabdata      1      1      0
> kmem_cache_node      192    192     64   64    1 : tunables    0    0    =
0 : slabdata      3      3      0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
