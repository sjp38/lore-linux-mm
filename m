Date: Mon, 21 Aug 2000 01:36:27 +0200 (CEST)
From: Jelle Foks <jelle@flying.demon.nl>
Subject: Re: memory file system on linux
In-Reply-To: <20000820171034.21395.qmail@web6405.mail.yahoo.com>
Message-ID: <Pine.LNX.4.21.0008210118170.14289-100000@bang.batnet>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ramesh Panuganty <rameshpanuganty@yahoo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 20 Aug 2000, Ramesh Panuganty wrote:

> Hi,
> 
> I am new to this group and came here while looking for
> a specific information. Can someone help me in getting
> the information (please reply to me directly).
> 
> Are there any memory file systems on linux with which
> I can maitain the entire file system on RAM?

What you can do is use use any filesystem on top of the RAM block device
(CONFIG_BLK_DEV_RAM).

>     - will /dev/ram come to of any help for me?

Yes, probably. Just choose a filesystem to run on top of it. 'initrd' is
probably the magic word you're looking for. initrd stands for (I
think) 'INITial RamDisk'...

>     - I had read about something like 'tmpfs' on SunOS
> which is a virtual filesystem that is entirely
> resident in the memory (probably shares the space with
> swap)

tmpfs does require a partition on the harddisk, and basically is a kludge
because the regular filesystem for sunos was not fast enough for temporary
files such as those placed in '/tmp'. Therefore, sun designed a new
filesystem that was faster for small, short-lived files, and combined it
with their paging (swap disk space). The current default Linux filesystem
(ext2fs) has been benchmarked in the past to be equivalent or better than
both tmpfs and the regular solaris filesystem for any application (you can
probably find it in the linux-kernel archives, in a thread related to
tmpfs), so Linux does not require anything such as a 'tmpfs' because
ext2fs does not has the shortcomings that make it necessary (there are
some shortcomings (hence ext2fs, reiserfs, etc...), but they're
different).

> Actually, I will tell you what I am looking for...
> 
> I have a 32MB IDE-disc and a 64MB RAM on my machine.
> But these small IDE-discs support very limited number
> of I/O Operations in their life time. Hence to limit
> the I/O, I want to keep the 32MB file system itself on
> RAM and do a read-write only once during bootup and
> shutdown.

There is a cramfs, ROMfs, and also I read somewhere about somebody
having implemented a filesystem specifically for FLASH ROMs.

I also suggest that you look into 'initrd', which basically is just a
compressed RAMdisk image loaded together with the kernel (in your case,
you could store the kernel plus an initrd image on the 32MB disk, and then
do everything from RAM). The initrd is loaded from the storage medium by
the same bootloader that loads the kernel, then the initrd is decompressed
into RAM to be used as RAMdisk (of any filesystem, minix is an often-used
choice because of it's relatively low filesystem overhead). Btw, If your
disk is FLASH-based, then only the the limit for the medium lifetime are
just the number of writes to the medium (FLASH is as good as ROM for
reads, except sometimes it's a lot slower), so ROMfs or possibly even
iso9660 might be interesing for you, saving some more precious RAM by
having a lot of your files available read-only directly from the 32MB
medium instead of RAM.

> Is there anyway, I can achieve this?
> 

Cya,

Jelle.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
