Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3EBFC6B00A8
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 08:47:54 -0500 (EST)
From: Markus <M4rkusXXL@web.de>
Subject: Re: drop_caches ...
Date: Wed, 4 Mar 2009 14:47:45 +0100
References: <200903041057.34072.M4rkusXXL@web.de> <20090304115702.GA17565@localhost> <49AE74E6.1060008@redhat.com>
In-Reply-To: <49AE74E6.1060008@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903041447.49534.M4rkusXXL@web.de>
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: Zdenek Kabelac <zkabelac@redhat.com>, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >>>>> The memory mapped pages won't be dropped in this way.
> >>>>> "cat /proc/meminfo" will show you the number of mapped pages.
> >>>> # sync ; echo 3 > /proc/sys/vm/drop_caches ; free -m ; 
> >> cat /proc/meminfo
> >>>>              total       used       free     shared    buffers     
> >>>> cached
> >>>> Mem:          3950       3262        688          0          0        
> >>>> 359
> >>>> -/+ buffers/cache:       2902       1047
> >>>> Swap:         5890       1509       4381
> >>>> MemTotal:        4045500 kB
> >>>> MemFree:          705180 kB
> >>>> Buffers:             508 kB
> >>>> Cached:           367748 kB
> >>>> SwapCached:       880744 kB
> >>>> Active:          1555032 kB
> >>>> Inactive:        1634868 kB
> >>>> Active(anon):    1527100 kB
> >>>> Inactive(anon):  1607328 kB
> >>>> Active(file):      27932 kB
> >>>> Inactive(file):    27540 kB
> >>>> Unevictable:         816 kB
> >>>> Mlocked:               0 kB
> >>>> SwapTotal:       6032344 kB
> >>>> SwapFree:        4486496 kB
> >>>> Dirty:                 0 kB
> >>>> Writeback:             0 kB
> >>>> AnonPages:       2378112 kB
> >>>> Mapped:            52196 kB
> >>>> Slab:              65640 kB
> >>>> SReclaimable:      46192 kB
> >>>> SUnreclaim:        19448 kB
> >>>> PageTables:        28200 kB
> >>>> NFS_Unstable:          0 kB
> >>>> Bounce:                0 kB
> >>>> WritebackTmp:          0 kB
> >>>> CommitLimit:     8055092 kB
> >>>> Committed_AS:    4915636 kB
> >>>> VmallocTotal:   34359738367 kB
> >>>> VmallocUsed:       44580 kB
> >>>> VmallocChunk:   34359677239 kB
> >>>> DirectMap4k:     3182528 kB
> >>>> DirectMap2M:     1011712 kB
> >>>>
> >>>> The cached reduced to 359 MB (after the dropping).
> >>>> I dont know where to read the "number of mapped pages".
> >>>> "Mapped" is about 51 MB.
> >>> Does your tmpfs store lots of files?
> >> Dont think so:
> >>
> >> # df -h
> >> Filesystem            Size  Used Avail Use% Mounted on
> >> /dev/md6               14G  8.2G  5.6G  60% /
> >> udev                   10M  304K  9.8M   3% /dev
> >> cachedir              4.0M  100K  4.0M   3% /lib64/splash/cache
> >> /dev/md4               19G   15G  3.1G  83% /home
> >> /dev/md3              8.3G  4.5G  3.9G  55% /usr/portage
> >> shm                   2.0G     0  2.0G   0% /dev/shm
> >> /dev/md1               99M   19M   76M  20% /boot
> >>
> >> # mount
> >> /dev/md6 on / type ext3 (rw,noatime,nodiratime,barrier=0)
> >> /proc on /proc type proc (rw,noexec,nosuid,noatime,nodiratime)
> >> sysfs on /sys type sysfs (rw,nosuid,nodev,noexec)
> >> udev on /dev type tmpfs (rw,nosuid,size=10240k,mode=755)
> >> devpts on /dev/pts type devpts (rw,nosuid,noexec,gid=5,mode=620)
> >> cachedir on /lib64/splash/cache type tmpfs (rw,size=4096k,mode=644)
> >> /dev/md4 on /home type ext3 (rw,noatime,nodiratime,barrier=0)
> >> /dev/md3 on /usr/portage type ext4 
(rw,noatime,nodiratime,barrier=0)
> >> shm on /dev/shm type tmpfs (rw,noexec,nosuid,nodev)
> >> usbfs on /proc/bus/usb type usbfs 
> >> (rw,noexec,nosuid,devmode=0664,devgid=85)
> >> automount(pid6507) on /mnt/.autofs/misc type autofs 
> >> (rw,fd=4,pgrp=6507,minproto=2,maxproto=4)
> >> automount(pid6521) on /mnt/.autofs/usb type autofs 
> >> (rw,fd=4,pgrp=6521,minproto=2,maxproto=4)
> >> /dev/md1 on /boot type ext2 (rw,noatime,nodiratime)
> >>
> >> I dont know what exactly all that memory is used for. It varies 
from 
> >> about 300 MB to up to one GB.
> >> Tell me where to look and I will!
> > 
> > So you don't have lots of mapped pages(Mapped=51M) or tmpfs files.  
It's
> > strange to me that there are so many undroppable cached 
pages(Cached=359M),
> > and most of them lie out of the LRU queue(Active+Inactive 
file=53M)...
> > 
> > Anyone have better clues on these 'hidden' pages?
> 
> Maybe try this:
> 
> cat /proc/`pidof X`/smaps | grep drm | wc -l
> 
> you will see some growing numbers.
> 
> Also check  cat /proc/dri/0/gem_objects
> there should be some number  # object bytes - which should be close to 
your 
> missing cached pages.
> 
> 
> If you are using Intel GEM driver - there is some unlimited caching 
issue
> 
> see: http://bugs.freedesktop.org/show_bug.cgi?id=20404
> 
# cat /proc/`pidof X`/smaps | grep drm | wc -l
0
# cat /proc/dri/0/gem_objects
cat: /proc/dri/0/gem_objects: No such file or directory

I use Xorg 1.3 with an nvidia gpu. Dont know if I use a "Intel GEM 
driver".

Btw I am running a 2.6.28.2.

Thanks.
Markus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
