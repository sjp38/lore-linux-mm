Message-ID: <20020405182738.19092.qmail@london.rubylane.com>
From: jim@rubylane.com
Subject: Re: 2.2.20 suspends everything then recovers during heavy I/O
Date: Fri, 5 Apr 2002 10:27:38 -0800 (PST)
In-Reply-To: <3CAD3632.E14560B@zip.com.au> from "Andrew Morton" at Apr 04, 2002 09:29:22 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

 
> Jim Wilcoxson wrote:
> > 
> > I'm setting up a new system with 2.2.20, Ingo's raid patches, plus
> > Hedrick's IDE patches.
> > 
> > When doing heavy I/O, like copying partitions between drives using tar in a
> > pipeline, I've noticed that things will just stop for long periods of time,
> > presumably while buffers are written out to the destination disk.  The
> > destination drive light is on and the system is not exactly hung, because I
> > can switch consoles and stuff, but a running vmstat totally suspends for
> > 10-15 seconds.
> > 
> > Any tips or patches that will avoid this?  If our server hangs for 15
> > seconds, we're going to have tons of web requests piled up for it when it
> > decides to wakeup...
> > 
> 
> Which filesystem are you using?

ext2

> First thing to do is to ensure that your disks are achieving
> the expected bandwidth.  Measure them with `hdparm -t'.
> If the throughput is poor, and they're IDE, check the
> chipset tuning options in your kernel config and/or
> tune the disks with hdparm.

# hdparm -tT /dev/hdg /dev/hdg:
Timing buffer-cache reads:   128 MB in  0.65 seconds =196.92 MB/sec
Timing buffered disk reads:  64 MB in  1.78 seconds = 35.96 MB/sec             

Is this fast?  I dunno - seems fast.  The Promise cards are in a 66MHz
bus slot, so I thought about using the idebus= thing to tell it that,
but I'm gun shy.  Probably not worth it for real-world accesses.  All
the drives are in UDMA5 mode:

# hdparm -i /dev/hdg

/dev/hdg:

 Model=Maxtor 5T060H6, FwRev=TAH71DP0, SerialNo=T6HMF4EC
 Config={ Fixed }
 RawCHS=16383/16/63, TrkSize=0, SectSize=0, ECCbytes=57
 BuffType=DualPortCache, BuffSize=2048kB, MaxMultSect=16, MultSect=off
 CurCHS=16383/16/63, CurSects=16514064, LBA=yes, LBAsects=120103200
 IORDY=on/off, tPIO={min:120,w/IORDY:120}, tDMA={min:120,rec:120}
 PIO modes: pio0 pio1 pio2 pio3 pio4 
 DMA modes: mdma0 mdma1 mdma2 udma0 udma1 udma2 udma3 udma4 *udma5 
 Drive Supports : Reserved : ATA-1 ATA-2 ATA-3 ATA-4 ATA-5 ATA-6 
 Kernel Drive Geometry LogicalCHS=119150/16/63 PhysicalCHS=119150/16/63


> If all that fails, you can probably smooth things
> out by tuning the writeback parameters in /proc/sys/vm/bdflush
> (if that's there in 2.2.  It's certainly somewhere :))
> Set the `interval' value smaller than the default five
> seconds, set `nfract' higher.  Set `age_buffer' lower..

Thanks, I'll try these tips.  IMO, one of Linux's weaknesses is that
it is not easy to run I/O bound jobs without killing the performance
of everything on the machine because of buffer cacheing.  I know lots
of people are working on solving this and that 2.4 is much better in
this regard.  It just takes time for a production site to have the
warm fuzzies about changing their OS.


> And finally: don't go copying entire partitions around
> on a live web server :)

What would be really great is some way to indicate, maybe with an
O_SEQ flag or something, that an application is going to sequentially
access a file, so cacheing it is a no-win proposition.  Production
servers do have situations where lots of data has to be copied or
accessed, for example, to do a backup, but doing a backup shouldn't
mean that all of the important stuff gets continuously thrown out of
memory while the backup is running.  Saving metadata during a backup
is useful.  Saving file data isn't.  It's seems hard to do this
without an application hint because I may scan a database
sequentially but I'd still want those buffers to stay resident.

Linux's I/O strategy (2.2.20), IMO, is kinda flawed because a very
high priority process (kswapd) is used to cleanup the mess that other
I/O-bound processes leave behind.  To me, it would be better to
penalize the applications that are causing the phsical I/O and slow
them down rather than letting them have free reign when there is
buffer space available, they instantly fill it, and then invoke this
high-priority process in quasi-emergency mode to flush the buffers.

The other thing I suggested to Alan Cox is a new ulimit that limits
how many file buffers a process can acquire.  If the buffer is
referenced by another process other than the one that caused it to be
created, then maybe it isn't counted in the limit (sharing).  This
way, without changing any applications, I can set the ulimit before a
backup procedure w/o having to change any applications.  Another
suggestion is to limit disk and network I/O bandwidth by process using
ulimits.  If I have a 1GB link between machines, I don't necessarily
want to kill two computers to transfer a large file across the link.
Maybe I don't care how long it takes.  I know some applications are
adding support for throttling, and there are various other ways to do
it - shaper, QOS, throttled pipes, etc. - but a general, easy-to-use
mechanism would be very helpful to production sites.  We don't always
have a lot of time to learn the ins and outs of setting up complex (to
us) things like QOS.  Hell, I couldn't even wade through all the
kernel build options for QOS. :) It's a great feature for sites using
Linux as routers, but too complex for general purpose use, IMO.

I've been reading some about the new O(1) CPU scheduler and it sounds
interesting.  Scheduling CPUs is only part of the problem.  In an I/O
bound situation, there is plenty of CPU to go around.  The problem
becomes fair, smooth access to the drives for all processes that need
that resource, also recognizing that different processes have
different completion constraints.  Right now I have to copy a 30GB
partition to another drive in order to do an upgrade for RAID.  I
don't care if it takes 3 days cause I still have to rsync it
afterwards, but I do have to run it on a live server.  I had to write
a pipe throttling thingy to run tar data through so it didn't kill our
server.

Okay, end of my rant.  I have my raid running now, my IDE problems
have subsided, and I'm a happy Linux camper again.  THanks again for
the tips.

Jim
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
