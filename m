Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 1D6F46B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 23:09:26 -0400 (EDT)
Date: Tue, 9 Jun 2009 11:28:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first
	class citizen
Message-ID: <20090609032823.GC7875@localhost>
References: <20090608091044.880249722@intel.com> <20090608091201.953724007@intel.com> <alpine.DEB.1.10.0906081126260.5754@gentwo.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="yrj/dFKFPuw6o+aM"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0906081126260.5754@gentwo.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>


--yrj/dFKFPuw6o+aM
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Jun 08, 2009 at 11:34:06PM +0800, Christoph Lameter wrote:
> On Mon, 8 Jun 2009, Wu Fengguang wrote:
>
> > 1.2) test scenario
> >
> > - nfsroot gnome desktop with 512M physical memory
> > - run some programs, and switch between the existing windows
> >   after starting each new program.
>
> Is there a predefined sequence or does this vary between tests? Scripted?

Yes it's scripted testing and has a predefined sequence.
The scripts are attached for your reference.

> What percentage of time is saved in the test after due to the
> modifications?
> Around 20%?

It's 50%, hehe. I've posted the startup times for each program:

  before       after    programs
    0.02        0.02    N xeyes
    0.75        0.76    N firefox
    2.02        1.88    N nautilus
    3.36        3.17    N nautilus --browser
    5.26        4.89    N gthumb
    7.12        6.47    N gedit
    9.22        8.16    N xpdf /usr/share/doc/shared-mime-info/shared-mime-info-spec.pdf
   13.58       12.55    N xterm
   15.87       14.57    N mlterm
   18.63       17.06    N gnome-terminal
   21.16       18.90    N urxvt
   26.24       23.48    N gnome-system-monitor
   28.72       26.52    N gnome-help
   32.15       29.65    N gnome-dictionary
   39.66       36.12    N /usr/games/sol
   43.16       39.27    N /usr/games/gnometris
   48.65       42.56    N /usr/games/gnect
   53.31       47.03    N /usr/games/gtali
   58.60       52.05    N /usr/games/iagno
   65.77       55.42    N /usr/games/gnotravex
   70.76       61.47    N /usr/games/mahjongg
   76.15       67.11    N /usr/games/gnome-sudoku
   86.32       75.15    N /usr/games/glines
   92.21       79.70    N /usr/games/glchess
  103.79       88.48    N /usr/games/gnomine
  113.84       96.51    N /usr/games/gnotski
  124.40      102.19    N /usr/games/gnibbles
  137.41      114.93    N /usr/games/gnobots2
  155.53      125.02    N /usr/games/blackjack
  179.85      135.11    N /usr/games/same-gnome
  224.49      154.50    N /usr/bin/gnome-window-properties
  248.44      162.09    N /usr/bin/gnome-default-applications-properties
  282.62      173.29    N /usr/bin/gnome-at-properties
  323.72      188.21    N /usr/bin/gnome-typing-monitor
  363.99      199.93    N /usr/bin/gnome-at-visual
  394.21      206.95    N /usr/bin/gnome-sound-properties
  435.14      224.49    N /usr/bin/gnome-at-mobility
  463.05      234.11    N /usr/bin/gnome-keybinding-properties
  503.75      248.59    N /usr/bin/gnome-about-me
  554.00      276.27    N /usr/bin/gnome-display-properties
  615.48      304.39    N /usr/bin/gnome-network-preferences
  693.03      342.01    N /usr/bin/gnome-mouse-properties
  759.90      388.58    N /usr/bin/gnome-appearance-properties
  937.90      508.47    N /usr/bin/gnome-control-center
 1109.75      587.57    N /usr/bin/gnome-keyboard-properties
 1399.05      758.16    N : oocalc
 1524.64      830.03    N : oodraw
 1684.31      900.03    N : ooimpress
 1874.04      993.91    N : oomath
 2115.12     1081.89    N : ooweb
 2369.02     1161.99    N : oowriter


> > (1) begin:     shortly after the big read IO starts;
> > (2) end:       just before the big read IO stops;
> > (3) restore:   the big read IO stops and the zsh working set restored
> > (4) restore X: after IO, switch back and forth between the urxvt and firefox
> >                windows to restore their working set.
>
> Any action done on the firefox sessions? Or just switch to a firefox
> session that needs to redraw?

After starting each new program, a new tab is opened in firefox to render a
simple web page. It's the same web page, so firefox may actually cache it.

> > The above console numbers show that
> >
> > - The startup pgmajfault of 2.6.30-rc4-mm is merely 1/3 that of 2.6.29.
> >   I'd attribute that improvement to the mmap readahead improvements :-)
>
> So there are other effects,,, You not measuring the effect only this
> patchset?

Yes there are additional effects in the .29 vs .30 comparisons.
But the following .30 vs .30 comparisons in X can lead to the same conclusions
except for this additional effect.

> > - The pgmajfault increment during the file copy is 633-630=3 vs 260-210=50.
> >   That's a huge improvement - which means with the VM_EXEC protection logic,
> >   active mmap pages is pretty safe even under partially cache hot streaming IO.
>
> Looks good.
>
> > - The absolute nr_mapped drops considerably to 1/9 during the big IO, and the
> >   dropped pages are mostly inactive ones. The patch has almost no impact in
> >   this aspect, that means it won't unnecessarily increase memory pressure.
> >   (In contrast, your 20% mmap protection ratio will keep them all, and
> >   therefore eliminate the extra 41 major faults to restore working set
> >   of zsh etc.)
>
> Good.

Thanks,
Fengguang

--yrj/dFKFPuw6o+aM
Content-Type: application/x-sh
Content-Disposition: attachment; filename="run-many-x-apps.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/zsh=0A# why zsh? bash does not support floating numbers=0A=0A# aptit=
ude install wmctrl iceweasel gnome-games gnome-control-center=0A# aptitude =
install openoffice.org # and uncomment the oo* lines=0A=0A=0Aread T0 T1 < /=
proc/uptime=0A=0Afunction progress()=0A{=0A	read t0 t1 < /proc/uptime=0A	t=
=3D$((t0 - T0))=0A	printf "%8.2f    " $t=0A	echo "$@"=0A}=0A=0Afunction swi=
tch_windows()=0A{=0A	wmctrl -l | while read a b c win=0A	do=0A		progress A =
"$win"=0A		wmctrl -a "$win"=0A	done=0A	firefox /usr/share/doc/debian/FAQ/in=
dex.html=0A}=0A=0Awhile read app args=0Ado=0A	progress N $app $args=0A	$app=
 $args &=0A	switch_windows=0Adone << EOF=0Axeyes=0Afirefox=0Anautilus=0Anau=
tilus --browser=0Agthumb=0Agedit=0Axpdf /usr/share/doc/shared-mime-info/sha=
red-mime-info-spec.pdf=0A=0Axterm=0Amlterm=0Agnome-terminal=0Aurxvt=0A=0Agn=
ome-system-monitor=0Agnome-help=0Agnome-dictionary=0A=0A/usr/games/sol=0A/u=
sr/games/gnometris=0A/usr/games/gnect=0A/usr/games/gtali=0A/usr/games/iagno=
=0A/usr/games/gnotravex=0A/usr/games/mahjongg=0A/usr/games/gnome-sudoku=0A/=
usr/games/glines=0A/usr/games/glchess=0A/usr/games/gnomine=0A/usr/games/gno=
tski=0A/usr/games/gnibbles=0A/usr/games/gnobots2=0A/usr/games/blackjack=0A/=
usr/games/same-gnome=0A=0A/usr/bin/gnome-window-properties=0A/usr/bin/gnome=
-default-applications-properties=0A/usr/bin/gnome-at-properties=0A/usr/bin/=
gnome-typing-monitor=0A/usr/bin/gnome-at-visual=0A/usr/bin/gnome-sound-prop=
erties=0A/usr/bin/gnome-at-mobility=0A/usr/bin/gnome-keybinding-properties=
=0A/usr/bin/gnome-about-me=0A/usr/bin/gnome-display-properties=0A/usr/bin/g=
nome-network-preferences=0A/usr/bin/gnome-mouse-properties=0A/usr/bin/gnome=
-appearance-properties=0A/usr/bin/gnome-control-center=0A/usr/bin/gnome-key=
board-properties=0A=0A: oocalc=0A: oodraw=0A: ooimpress=0A: oomath=0A: oowe=
b=0A: oowriter    =0A=0AEOF=0A
--yrj/dFKFPuw6o+aM
Content-Type: application/x-sh
Content-Disposition: attachment; filename="test-mmap-exec-prot.sh"
Content-Transfer-Encoding: quoted-printable

#!/bin/sh=0A=0Aprot=3D$(</proc/sys/fs/suid_dumpable)=0Aecho $prot=0A=0ADISP=
LAY=3D:0.0 ./run-many-x-apps.sh | tee progress.$prot=0A=0Acp /proc/vmstat v=
mstat.$prot=0Acp /proc/meminfo meminfo.$prot=0Afree > free.$prot=0A
--yrj/dFKFPuw6o+aM--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
