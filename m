Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DBD966B01B0
	for <linux-mm@kvack.org>; Mon, 24 May 2010 06:50:38 -0400 (EDT)
Message-ID: <4BFA59F7.2020606@cesarb.net>
Date: Mon, 24 May 2010 07:50:31 -0300
From: Cesar Eduardo Barros <cesarb@cesarb.net>
MIME-Version: 1.0
Subject: Re: [PATCH 0/3] mm: Swap checksum
References: <4BF81D87.6010506@cesarb.net>	<20100523140348.GA10843@barrios-desktop>	<4BF974D5.30207@cesarb.net>	<AANLkTil1kwOHAcBpsZ_MdtjLmCAFByvF4xvm8JJ7r7dH@mail.gmail.com>	<4BF9CF00.2030704@cesarb.net> <AANLkTin_BV6nWlmX6aXTaHvzH-DnsFIVxP5hz4aZYlqH@mail.gmail.com>
In-Reply-To: <AANLkTin_BV6nWlmX6aXTaHvzH-DnsFIVxP5hz4aZYlqH@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

Em 23-05-2010 23:05, Minchan Kim escreveu:
> On Mon, May 24, 2010 at 9:57 AM, Cesar Eduardo Barros<cesarb@cesarb.net>  wrote:
>> The internal ECC of the disk will not save you - a quick Google search found
>> an instance of someone with silent data corruption caused by a faulty *power
>> supply*.[1]
>>
>> And if it is silent corruption, without the checksums you will not notice it
>> - it will just be dismissed as "oh, Firefox just crashed again" or similar
>> (the same as bit flips on RAM without ECC).
>
> When I read your comment, suddenly some thought occurred to me.
> If we can't believe ECC of the disk, why do we separate error
> detection logic between file system and swap disk?
>
> I mean it make sense that put crc detection into block layer?
> It can make sure any block I/O.

There are differences as to where the checksum will be stored.

For the filesystem (and for the software suspend image), you have to 
store the checksums in the disk itself, and the correct place (and 
ordering requirements) depends on the filesystem. Also, most filesystems 
do not currently have on-disk checksums.

For the swap, it is much simpler; the checksums can be stored in memory 
(since they do not matter after a reboot; the swap contents are simply 
discarded). This also gives better performance, since the checksums do 
not have to be separately written, and more flexibility, since the 
kernel can use whatever kind of checksum it wants and can store the 
checksum in whatever data structure it choses, without worrying about 
compatibility.

And, in fact, there is a CRC code in the block layer; it is 
CONFIG_BLK_DEV_INTEGRITY. However, it is not a generic solution; it 
needs some extra prerequisites (like a disk low-level formatted with 
sectors with >512 bytes).

> And what's BER of disk?
> Is it usual to meet the problem?

It is unusual enough that most people who meet it will not notice.

And the filesystem developers (who understand about these things more 
than me) seem to be trending towards adding checksums to their 
filesystems. The point of this patch is to meet the same level of safety 
as btrfs (thus the choice of crc32c, which is what btrfs uses).

> In normal desktop, some app killed are not critical. If the
> application is critical, maybe app have to logic fault handling.
> Firefox has session restore feature and Office program has temporal
> save feature.

In fact, crashing is the "best" outcome here. The worst outcome is your 
application silently corrupting the data you then save to disk.

> On the other hand, in server, does it designed well to use swap disk
> until we meet bit error of disk?

Servers are the ones which would benefit the most, as their RAM is 
usually very reliable (they tend to use ECC memory). Their disk 
subsystems, however, are also more reliable.

Desktop systems (especially "no-name" brand ones) do not gain as much, 
since their RAM is usually unprotected; however, they are also the ones 
which have better chance of having low-quality power supplies, uncommon 
storage media (USB flash drives as the root disk is an example), and 
problematic I/O subsystems.

> My feel is that it seem to be rather overkill.

Yes, it is a bit overkill, except when you are using software suspend. 
While the software suspend image is not protected by this patch (I am 
already thinking of a separate patch to add checksums to it), the 
swapped out pages are (software suspend uses both a memory image saved 
to the swap partition and the normal swapped out pages).

But you do not have to use it if you think it is overkill - I even added 
a kernel parameter to easily disable it.

>> The swap checksum only protects the page against being silently corrupted
>> while on the disk and at least to some degree on the I/O path between the
>> memory and the disk. It does not protect against broken kernel-mode code
>> writing to the wrong address, nor against broken hardware (or hardware
>> misconfigured by broken drivers) doing DMA to wrong addresses. It also does
>> not protect against hardware errors in the RAM itself (you have ECC memory
>> for that).
>>
>> That is, the code assumes the memory containing the checksums will not be
>> corrupted, because if it is, you have worse problems (and the CRC error here
>> would be a *good* thing, since it would make you notice something is not
>> quite right).
>>
>
> Which is high between BER of RAM and disk?
> It's a just question. :)

I have no idea.

However, we can do nothing in software against RAM errors; it would kill 
performance too much. Against disk errors, however, we can do a lot 
(software RAID-1 is just one of the simplest examples).

-- 
Cesar Eduardo Barros
cesarb@cesarb.net
cesar.barros@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
