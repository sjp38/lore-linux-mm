Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id AEA956B05C3
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 04:52:10 -0500 (EST)
Received: by mail-vk1-f198.google.com with SMTP id c80so5254312vke.22
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 01:52:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h23sor1959210vsa.30.2018.11.08.01.52.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 01:52:09 -0800 (PST)
MIME-Version: 1.0
References: <CAOuPNLjuM5qq3go9ZFZcK0G5pQxTQb0DY36xu+8SL4vC4zJntw@mail.gmail.com>
 <20181105155815.i654i5ctmfpqhggj@angband.pl> <79d0c96a-a0a2-63ec-db91-42fd349d50c1@gmail.com>
In-Reply-To: <79d0c96a-a0a2-63ec-db91-42fd349d50c1@gmail.com>
From: Pintu Agarwal <pintu.ping@gmail.com>
Date: Thu, 8 Nov 2018 15:21:58 +0530
Message-ID: <CAOuPNLi4GS_xbqugQSbQJygSeKFnaNyq1e7DguSpPbY2TfMyaw@mail.gmail.com>
Subject: Re: Creating compressed backing_store as swapfile
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ahferroin7@gmail.com
Cc: kilobyte@angband.pl, linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, kernelnewbies@kernelnewbies.org

On Mon, Nov 5, 2018 at 9:37 PM Austin S. Hemmelgarn
<ahferroin7@gmail.com> wrote:
>
> On 11/5/2018 10:58 AM, Adam Borowski wrote:
> > On Mon, Nov 05, 2018 at 08:31:46PM +0530, Pintu Agarwal wrote:
> >> Hi,
> >>
> >> I have one requirement:
> >> I wanted to have a swapfile (64MB to 256MB) on my system.
> >> But I wanted the data to be compressed and stored on the disk in my swapfile.
> >> [Similar to zram, but compressed data should be moved to disk, instead of RAM].
> >>
> >> Note: I wanted to optimize RAM space, so performance is not important
> >> right now for our requirement.
> >>
> >> So, what are the options available, to perform this in 4.x kernel version.
> >> My Kernel: 4.9.x
> >> Board: any - (arm64 mostly).
> >>
> >> As I know, following are the choices:
> >> 1) ZRAM: But it compresses and store data in RAM itself
> >> 2) frontswap + zswap : Didn't explore much on this, not sure if this
> >> is helpful for our case.
> >> 3) Manually creating swapfile: but how to compress it ?
> >> 4) Any other options ?
> >
> > Loop device on any filesystem that can compress (such as btrfs)?  The
> > performance would suck, though -- besides the indirection of loop, btrfs
> > compresses in blocks of 128KB while swap wants 4KB writes.  Other similar
> > option is qemu-nbd -- it can use compressed disk images and expose them to a
> > (local) nbd client.
>
> Swap on any type of a networked storage device (NBD, iSCSI, ATAoE, etc)
> served from the local system is _really_ risky.  The moment the local
> server process for the storage device gets forced out to swap, you deadlock.
>
> Performance isn't _too_ bad for the BTRFS case though (I've actually
> tested this before), just make sure you disable direct I/O mode on the
> loop device, otherwise you run the risk of data corruption.

Sorry, btrfs is not an option for us. We want something more lighter
weight as our requirement is just < 200 MBs.
