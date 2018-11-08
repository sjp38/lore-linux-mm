Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 394ED6B05C1
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 04:46:35 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id x2so6223569vsc.6
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 01:46:35 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 88sor1931156uaw.67.2018.11.08.01.46.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 01:46:34 -0800 (PST)
MIME-Version: 1.0
References: <CAOuPNLjuM5qq3go9ZFZcK0G5pQxTQb0DY36xu+8SL4vC4zJntw@mail.gmail.com>
 <40880.1541434328@turing-police.cc.vt.edu>
In-Reply-To: <40880.1541434328@turing-police.cc.vt.edu>
From: Pintu Agarwal <pintu.ping@gmail.com>
Date: Thu, 8 Nov 2018 15:16:22 +0530
Message-ID: <CAOuPNLiHowVGDdLi=FwAVZRRsO=NnLk4=PnTqYAXF97G1QrkRQ@mail.gmail.com>
Subject: Re: Creating compressed backing_store as swapfile
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Valdis Kletnieks <valdis.kletnieks@vt.edu>
Cc: linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, kernelnewbies@kernelnewbies.org

On Mon, Nov 5, 2018 at 9:42 PM <valdis.kletnieks@vt.edu> wrote:
>
> On Mon, 05 Nov 2018 20:31:46 +0530, Pintu Agarwal said:
> > I wanted to have a swapfile (64MB to 256MB) on my system.
> > But I wanted the data to be compressed and stored on the disk in my swapfile.
> > [Similar to zram, but compressed data should be moved to disk, instead of RAM].
>
> What platform are you on that you're both storage constrained enough to need
> swap, and also so short on disk space that compressing it makes sense?
> Understanding the hardware constraints here would help in advising you.
>

Currently, I am using the minimal platform such as busybox for arm
(kind of a ubuntu based debian platform).
Also I am trying to do this on an arm based embedded board with 8 GB
MMC card and 1 GB RAM.
And I am using the ext4 filesystem with Linux Kernel version 4.9.x.
So, with 8 GB SD card I have 2 GB left on the storage space. Out of
which 64MB - 128MB would be used for swapfile.
However, note that this is not the final end product requirement.
I am just trying to demonstrate a prototype and use cases.
Performance requirement is not that strict right now, as I don't know
the end product. However, the system requirement is as minimal as
this.

The main requirement is, creating a RAM snapshot image, then
compressing some of its data and moving to swapfile, so that snapshot
image size can be reduced.
I guess, ZRAM is not useful here, so I thought to explore some other
option such as zswap, etc. ?
BTRFS is not an option, though, as we use ext4 and vfat filesystem (only).

> > Note: I wanted to optimize RAM space, so performance is not important
> > right now for our requirement.
> >
> > So, what are the options available, to perform this in 4.x kernel version.
> > My Kernel: 4.9.x
>
> Given that this is a greenfield development, why are you picking a kernel
> that's 2 years out of date?  You *do* realize that 4.9.135 does *not* contain
> all the bugfixes since then, only that relatively small subset that qualify for
> 'stable' (see Documentation/process/stable-kernel-rules.rst for the gory
> details).
>
Yes, we want to stick to 4.9 right now, as the end product might be
based on this version.
However, if higher kernel version have some fixes or good features, we
can back port it.

> One possible total hack would be to simply use a file-based swap area,
> but put the file on a filesystem that supports automatic inline compression.
>
I know, squashfs is a compressed filesystem, but it is read-only. So
its ruled out.

> Note that this will probably *totally* suck on performance, because there's
> no good way to find where 4K block 11,493 starts inside the compressed
> file, so it would have to read/decompress from the file beginning.  Also,
> if you write data to a previously unused location (or even a previously used
> spot that compressed the 4K page to a different length), you have a bad time
> inserting it.  (Note that zram can avoid most of this because it can (a) keep
> a table of pointers to where each page starts and (b) it isn't constrained to
> writing to 4K blocks on disk, so if the current compression takes a 4K page down
> to 1,283 bytes, it doesn't have to care *too* much if it stores that someplace
> that crosses a page boundary.
>
> Another thing that you will need to worry about is what happens in low-memory
> situations - the time you *most* need to do a swap operation, you may not have
> enough memory to do the I/O.  zram basically makes sure it *has* the memory
> needed beforehand, and swap directly to pre-allocated disk doesn't need much
> additional memory.
Swap storage requirement would be mostly between 64MB to 256MB (pre-configured).
Yes it can be something similar on ZRAM line, may be zram + zswap ?
Not sure if this right combination ?
