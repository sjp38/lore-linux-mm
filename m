Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 57C146B00AB
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 13:47:48 -0500 (EST)
From: Markus <M4rkusXXL@web.de>
Subject: Re: drop_caches ...
Date: Wed, 4 Mar 2009 19:47:41 +0100
References: <200903041057.34072.M4rkusXXL@web.de> <200903041447.49534.M4rkusXXL@web.de> <49AE8BA8.3080504@redhat.com>
In-Reply-To: <49AE8BA8.3080504@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Message-Id: <200903041947.41542.M4rkusXXL@web.de>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Zdenek Kabelac <zkabelac@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Am Mittwoch, 4. M=E4rz 2009 schrieb Zdenek Kabelac:
> Markus napsal(a):
> >>>>>>> The memory mapped pages won't be dropped in this way.
> >>>>>>> "cat /proc/meminfo" will show you the number of mapped pages.
> >>>>>> # sync ; echo 3 > /proc/sys/vm/drop_caches ; free -m ;=20
> >>>> cat /proc/meminfo
> >>>>>>              total       used       free     shared    buffers    =
=20
> >>>>>> cached
> >>>>>> Mem:          3950       3262        688          0          0    =
   =20
> >>>>>> 359
> >>>>>> -/+ buffers/cache:       2902       1047
> >>>>>> Swap:         5890       1509       4381
> >>>>>> MemTotal:        4045500 kB
> >>>>>> MemFree:          705180 kB
> >>>>>> Buffers:             508 kB
> >>>>>> Cached:           367748 kB
> >>>>>> SwapCached:       880744 kB
> >>>>>> Active:          1555032 kB
> >>>>>> Inactive:        1634868 kB
> >>>>>> Active(anon):    1527100 kB
> >>>>>> Inactive(anon):  1607328 kB
> >>>>>> Active(file):      27932 kB
> >>>>>> Inactive(file):    27540 kB
> >>>>>> Unevictable:         816 kB
> >>>>>> Mlocked:               0 kB
> >>>>>> SwapTotal:       6032344 kB
> >>>>>> SwapFree:        4486496 kB
> >>>>>> Dirty:                 0 kB
> >>>>>> Writeback:             0 kB
> >>>>>> AnonPages:       2378112 kB
> >>>>>> Mapped:            52196 kB
> >>>>>> Slab:              65640 kB
> >>>>>> SReclaimable:      46192 kB
> >>>>>> SUnreclaim:        19448 kB
> >>>>>> PageTables:        28200 kB
> >>>>>> NFS_Unstable:          0 kB
> >>>>>> Bounce:                0 kB
> >>>>>> WritebackTmp:          0 kB
> >>>>>> CommitLimit:     8055092 kB
> >>>>>> Committed_AS:    4915636 kB
> >>>>>> VmallocTotal:   34359738367 kB
> >>>>>> VmallocUsed:       44580 kB
> >>>>>> VmallocChunk:   34359677239 kB
> >>>>>> DirectMap4k:     3182528 kB
> >>>>>> DirectMap2M:     1011712 kB
> >>>>>>
> >>>>>> The cached reduced to 359 MB (after the dropping).
> >>>>>> I dont know where to read the "number of mapped pages".
> >>>>>> "Mapped" is about 51 MB.
> >>>>> Does your tmpfs store lots of files?
> >>>> Dont think so:
> >>>>
> >>>> # df -h
> >>>> Filesystem            Size  Used Avail Use% Mounted on
> >>>> /dev/md6               14G  8.2G  5.6G  60% /
> >>>> udev                   10M  304K  9.8M   3% /dev
> >>>> cachedir              4.0M  100K  4.0M   3% /lib64/splash/cache
> >>>> /dev/md4               19G   15G  3.1G  83% /home
> >>>> /dev/md3              8.3G  4.5G  3.9G  55% /usr/portage
> >>>> shm                   2.0G     0  2.0G   0% /dev/shm
> >>>> /dev/md1               99M   19M   76M  20% /boot
> >>>>
> >>>> I dont know what exactly all that memory is used for. It varies=20
> > from=20
> >>>> about 300 MB to up to one GB.
> >>>> Tell me where to look and I will!
> >>> So you don't have lots of mapped pages(Mapped=3D51M) or tmpfs files. =
=20
> > It's
> >>> strange to me that there are so many undroppable cached=20
> > pages(Cached=3D359M),
> >>> and most of them lie out of the LRU queue(Active+Inactive=20
> > file=3D53M)...
> >>> Anyone have better clues on these 'hidden' pages?
> >> Maybe try this:
> >>
> >> cat /proc/`pidof X`/smaps | grep drm | wc -l
> >>
> >> you will see some growing numbers.
> >>
> >> Also check  cat /proc/dri/0/gem_objects
> >> there should be some number  # object bytes - which should be close=20
to=20
> > your=20
> >> missing cached pages.
> >>
> >>
> >> If you are using Intel GEM driver - there is some unlimited caching=20
> > issue
> >> see: http://bugs.freedesktop.org/show_bug.cgi?id=3D20404
> >>
> > # cat /proc/`pidof X`/smaps | grep drm | wc -l
> > 0
> > # cat /proc/dri/0/gem_objects
> > cat: /proc/dri/0/gem_objects: No such file or directory
> >=20
> > I use Xorg 1.3 with an nvidia gpu. Dont know if I use a "Intel GEM=20
> > driver".
> >=20
>=20
>=20
> Are you using binary  driver from NVidia ??
> Maybe you should ask authors of this binary blob ?
>=20
> Could you try to use for a while Vesa driver to see, if you are able=20
to get=20
> same strange results ?

I rebooted in console without the nvidia-module loaded and have the same=20
results (updated to 2.6.28.7 btw):
# sync ; echo 3 > /proc/sys/vm/drop_caches ; free -m ; cat /proc/meminfo
             total       used       free     shared    buffers    =20
cached
Mem:          3950       1647       2303          0          0       =20
924
=2D/+ buffers/cache:        722       3228
Swap:         5890          0       5890
MemTotal:        4045444 kB
MemFree:         2358944 kB
Buffers:             544 kB
Cached:           946624 kB
SwapCached:            0 kB
Active:          1614756 kB
Inactive:           7632 kB
Active(anon):    1602476 kB
Inactive(anon):        0 kB
Active(file):      12280 kB
Inactive(file):     7632 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:       6032344 kB
SwapFree:        6032344 kB
Dirty:                72 kB
Writeback:            32 kB
AnonPages:        675224 kB
Mapped:            17756 kB
Slab:              19936 kB
SReclaimable:       9652 kB
SUnreclaim:        10284 kB
PageTables:         8296 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     8055064 kB
Committed_AS:    3648088 kB
VmallocTotal:   34359738367 kB
VmallocUsed:       10616 kB
VmallocChunk:   34359716459 kB
DirectMap4k:        6080 kB
DirectMap2M:     4188160 kB

Thanks!
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
