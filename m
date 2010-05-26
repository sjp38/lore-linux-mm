Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8AC016B01C3
	for <linux-mm@kvack.org>; Wed, 26 May 2010 06:22:03 -0400 (EDT)
Message-ID: <4BFCF645.2050400@cesarb.net>
Date: Wed, 26 May 2010 07:21:57 -0300
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] mm: Swap checksum
References: <4BF81D87.6010506@cesarb.net>	<20100523140348.GA10843@barrios-desktop>	<4BF974D5.30207@cesarb.net>	<AANLkTil1kwOHAcBpsZ_MdtjLmCAFByvF4xvm8JJ7r7dH@mail.gmail.com>	<4BF9CF00.2030704@cesarb.net>	<AANLkTin_BV6nWlmX6aXTaHvzH-DnsFIVxP5hz4aZYlqH@mail.gmail.com>	<4BFA59F7.2020606@cesarb.net> <AANLkTikMTwzXt7-vQf9AG2VhwFIGs1jX-1uFoYAKSco7@mail.gmail.com>
In-Reply-To: <AANLkTikMTwzXt7-vQf9AG2VhwFIGs1jX-1uFoYAKSco7@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

Em 25-05-2010 20:52, Minchan Kim escreveu:
> On Mon, May 24, 2010 at 7:50 PM, Cesar Eduardo Barros<cesarb@cesarb.net>  wrote:
>> And, in fact, there is a CRC code in the block layer; it is
>> CONFIG_BLK_DEV_INTEGRITY. However, it is not a generic solution; it needs
>> some extra prerequisites (like a disk low-level formatted with sectors with
>>> 512 bytes).
>
> You mean BLK_DEV_INTEGRITY has a dependency with block device driver?
> If you want to support checksum into suspend, At last, should we put
> the checksum on disk?
>
> I mean could we extend BLK_DEV_INTEGRITY by more generic solution?
> As you said, in case of swap, we don't need to put checksum on disk.

CONFIG_BLK_DEV_INTEGRITY writes the checksum to the same sector as the 
data. However, for that to be possible, the sector size is increased on 
the disk itself, from 512 bytes to 520 bytes (and not all disks can do 
that). It is not a generic solution. It also, as far as I can see, does 
nothing against the disk simply failing to write and later returning 
stale data, since the stale checksum would match the stale data.

See the LWN article [1] and the presentations [2] for more detail.

For suspend, the swap checksum pages would be saved together with the 
rest of the memory (they are in the memory, after all), and the suspend 
snapshot would have its own separate checksum (written directly to the 
disk after the image).

> If swap case, let it put the one on memory. If non-swap case, let it
> put checksum on disk,
> I am not sure it's possible.
>
> When we have a unreliable disk, your point is that let's solve it with
> (btrfs + swap) which both supports checksum. And my point is that
> let's solve it with (any file system + swap) which is put on block
> layer which supports checksum.

A generic "checksumming block device" would be less efficient.

For the swap case, it cannot exploit the fact that its state tracking is 
within the swapfile code. Avi Kivity's idea of storing the checksum in 
otherwise wasted bits of the pte is an example of how this could be 
exploited in the future. In fact, the reason I did it on the swap layer 
(instead of interposing something in the block layer) was precisely to 
make it easier to enhance the state tracking in the future (and also 
because it felt the most natural layer to do it).

It would also complicate adding checksums to the software suspend 
snapshot. While normally you do not want to write the swap checksums to 
the disk, you do want to write them when saving the memory snapshot - 
which is written to the same block device. However, the checksums for 
the rest of the swap pages are already being saved as part of the memory 
snapshot (since the checksums were in the memory).

For the generic ("any file system") case, it is worse, since you 
actually have to write the checksum to the disk, and unlike in the 
software suspend case you cannot simply write them all in one pass at 
the end. In the worst case, you would have to write twice for each 
sector/page - once for the data, and once for the checksums 
(CONFIG_BLK_DEV_INTEGRITY completely avoids this issue since with it the 
checksum is together with the data in the same sector). Not to mention 
fun things like write amplification.

A filesystem with data checksums can write the checksum as part of its 
normal metadata updates (which it already has to do anyway).

A generic "checksumming block device" could be a way of "updating" a 
filesystem without checksums (or with only metadata checksums) to have 
them. However, I believe it would be more productive to add them 
directly to the filesystem itself. Even more since the only way I can 
see of doing it efficiently in a generic block layer is by using lots of 
filesystem-style tricks (things like a log-structured list of CRC 
values, dividing the device in "block groups" to keep the checksum close 
to the data, and so on).


[1] Block layer: integrity checking and lots of partitions
     http://lwn.net/Articles/290141/
[2] http://oss.oracle.com/projects/data-integrity/documentation/

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
