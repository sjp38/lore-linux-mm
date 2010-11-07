Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DEC816B0085
	for <linux-mm@kvack.org>; Sun,  7 Nov 2010 12:27:45 -0500 (EST)
Date: Sun, 7 Nov 2010 18:16:26 +0100 (CET)
From: Jesper Juhl <jj@chaosbits.net>
Subject: Re: 2.6.36 io bring the system to its knees
In-Reply-To: <20101105014334.GF13830@dastard>
Message-ID: <alpine.LNX.2.00.1011071753560.26056@swampdragon.chaosbits.net>
References: <AANLkTikRKVBzO=ruy=JDmBF28NiUdJmAqb4-1VhK0QBX@mail.gmail.com> <AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com> <AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com> <AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
 <20101028090002.GA12446@elte.hu> <AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com> <20101028133036.GA30565@elte.hu> <20101028170132.GY27796@think> <alpine.LNX.2.00.1011050032440.16015@swampdragon.chaosbits.net>
 <alpine.LNX.2.00.1011050047220.16015@swampdragon.chaosbits.net> <20101105014334.GF13830@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Nov 2010, Dave Chinner wrote:

> On Fri, Nov 05, 2010 at 12:48:17AM +0100, Jesper Juhl wrote:
> > On Fri, 5 Nov 2010, Jesper Juhl wrote:
> > 
> > > On Thu, 28 Oct 2010, Chris Mason wrote:
> > > 
> > > > On Thu, Oct 28, 2010 at 03:30:36PM +0200, Ingo Molnar wrote:
> > > > > 
> > > > > "Many seconds freezes" and slowdowns wont be fixed via the VFS scalability patches 
> > > > > i'm afraid.
> > > > > 
> > > > > This has the appearance of some really bad IO or VM latency problem. Unfixed and 
> > > > > present in stable kernel versions going from years ago all the way to v2.6.36.
> > > > 
> > > > Hmmm, the workload you're describing here has two special parts.  First
> > > > it dramatically overloads the disk, and then it has guis doing things
> > > > waiting for the disk.
> > > > 
> > > 
> > > Just want to chime in with a 'me too'.
> > > 
> > > I see something similar on Arch Linux when doing 'pacman -Syyuv' and there 
> > > are many (as in more than 5-10) updates to apply. While the update is 
> > > running (even if that's all the system is doing) system responsiveness is 
> > > terrible - just starting 'chromium' which is usually instant (at least 
> > > less than 2 sec at worst) can take upwards of 10 seconds and the mouse 
> > > cursor in X starts to jump a bit as well and switching virtual desktops 
> > > noticably lags when redrawing the new desktop if there's a full screen app 
> > > like gimp or OpenOffice open there. This is on a Lenovo Thinkpad R61i 
> > > which has a 'Intel(R) Core(TM)2 Duo CPU T7250 @ 2.00GHz' CPU, 2GB of 
> > > memory and 499996 kilobytes of swap.
> > > 
> > Forgot to mention the kernel I currently experience this with : 
> > 
> > [jj@dragon ~]$ uname -a
> > Linux dragon 2.6.35-ARCH #1 SMP PREEMPT Sat Oct 30 21:22:26 CEST 2010 x86_64 Intel(R) Core(TM)2 Duo CPU T7250 @ 2.00GHz GenuineIntel GNU/Linux
> 
> I think anyone reporting a interactivity problem also needs to
> indicate what their filesystem is, what mount paramters they are
> using, what their storage config is, whether barriers are active or
> not, what elevator they are using, whether one or more of the
> applications are issuing fsync() or sync() calls, and so on.
>
Some details below.

[jj@dragon ~]$ mount
proc on /proc type proc (rw,relatime)
sys on /sys type sysfs (rw,relatime)
udev on /dev type devtmpfs 
(rw,nosuid,relatime,size=10240k,nr_inodes=255749,mode=755)
/dev/disk/by-uuid/61d104a5-4f7b-40ef-a9c8-44ad2765513e on / type ext4 (rw,commit=0)
devpts on /dev/pts type devpts (rw)
shm on /dev/shm type tmpfs (rw,nosuid,nodev)

[root@dragon ~]# hdparm -v /dev/disk/by-uuid/61d104a5-4f7b-40ef-a9c8-44ad2765513e

/dev/disk/by-uuid/61d104a5-4f7b-40ef-a9c8-44ad2765513e:
 multcount     = 16 (on)
 IO_support    =  1 (32-bit)
 readonly      =  0 (off)
 readahead     = 256 (on)
 geometry      = 9729/255/63, sectors = 25220160, start = 119644560

[root@dragon ~]# dmesg | grep -i ext4
EXT4-fs (sda4): mounted filesystem with ordered data mode. Opts: (null)
EXT4-fs (sda4): re-mounted. Opts: (null)
EXT4-fs (sda4): re-mounted. Opts: (null)
EXT4-fs (sda4): re-mounted. Opts: commit=0

The elevator in use is CFQ.

The app that's causing the system to behave this way (the 'pacman' package 
manager in Arch Linux) makes a few calls (2-4)  to fsync() during its run, 
but that's all.


-- 
Jesper Juhl <jj@chaosbits.net>             http://www.chaosbits.net/
Plain text mails only, please      http://www.expita.com/nomime.html
Don't top-post  http://www.catb.org/~esr/jargon/html/T/top-post.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
