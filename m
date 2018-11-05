Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 463DA6B0007
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 11:07:44 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id w13-v6so10856889iop.2
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 08:07:44 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id l7-v6sor8290540iof.45.2018.11.05.08.07.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Nov 2018 08:07:43 -0800 (PST)
Subject: Re: Creating compressed backing_store as swapfile
References: <CAOuPNLjuM5qq3go9ZFZcK0G5pQxTQb0DY36xu+8SL4vC4zJntw@mail.gmail.com>
 <20181105155815.i654i5ctmfpqhggj@angband.pl>
From: "Austin S. Hemmelgarn" <ahferroin7@gmail.com>
Message-ID: <79d0c96a-a0a2-63ec-db91-42fd349d50c1@gmail.com>
Date: Mon, 5 Nov 2018 11:07:12 -0500
MIME-Version: 1.0
In-Reply-To: <20181105155815.i654i5ctmfpqhggj@angband.pl>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adam Borowski <kilobyte@angband.pl>, Pintu Agarwal <pintu.ping@gmail.com>
Cc: linux-mm@kvack.org, open list <linux-kernel@vger.kernel.org>, kernelnewbies@kernelnewbies.org

On 11/5/2018 10:58 AM, Adam Borowski wrote:
> On Mon, Nov 05, 2018 at 08:31:46PM +0530, Pintu Agarwal wrote:
>> Hi,
>>
>> I have one requirement:
>> I wanted to have a swapfile (64MB to 256MB) on my system.
>> But I wanted the data to be compressed and stored on the disk in my swapfile.
>> [Similar to zram, but compressed data should be moved to disk, instead of RAM].
>>
>> Note: I wanted to optimize RAM space, so performance is not important
>> right now for our requirement.
>>
>> So, what are the options available, to perform this in 4.x kernel version.
>> My Kernel: 4.9.x
>> Board: any - (arm64 mostly).
>>
>> As I know, following are the choices:
>> 1) ZRAM: But it compresses and store data in RAM itself
>> 2) frontswap + zswap : Didn't explore much on this, not sure if this
>> is helpful for our case.
>> 3) Manually creating swapfile: but how to compress it ?
>> 4) Any other options ?
> 
> Loop device on any filesystem that can compress (such as btrfs)?  The
> performance would suck, though -- besides the indirection of loop, btrfs
> compresses in blocks of 128KB while swap wants 4KB writes.  Other similar
> option is qemu-nbd -- it can use compressed disk images and expose them to a
> (local) nbd client.

Swap on any type of a networked storage device (NBD, iSCSI, ATAoE, etc) 
served from the local system is _really_ risky.  The moment the local 
server process for the storage device gets forced out to swap, you deadlock.

Performance isn't _too_ bad for the BTRFS case though (I've actually 
tested this before), just make sure you disable direct I/O mode on the 
loop device, otherwise you run the risk of data corruption.
