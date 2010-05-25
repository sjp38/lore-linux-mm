Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F36286B01B2
	for <linux-mm@kvack.org>; Tue, 25 May 2010 19:52:54 -0400 (EDT)
Received: by gyg4 with SMTP id 4so2530298gyg.14
        for <linux-mm@kvack.org>; Tue, 25 May 2010 16:52:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BFA59F7.2020606@cesarb.net>
References: <4BF81D87.6010506@cesarb.net>
	<20100523140348.GA10843@barrios-desktop>
	<4BF974D5.30207@cesarb.net>
	<AANLkTil1kwOHAcBpsZ_MdtjLmCAFByvF4xvm8JJ7r7dH@mail.gmail.com>
	<4BF9CF00.2030704@cesarb.net>
	<AANLkTin_BV6nWlmX6aXTaHvzH-DnsFIVxP5hz4aZYlqH@mail.gmail.com>
	<4BFA59F7.2020606@cesarb.net>
Date: Wed, 26 May 2010 08:52:52 +0900
Message-ID: <AANLkTikMTwzXt7-vQf9AG2VhwFIGs1jX-1uFoYAKSco7@mail.gmail.com>
Subject: Re: [PATCH 0/3] mm: Swap checksum
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

Hi, Cesar.

On Mon, May 24, 2010 at 7:50 PM, Cesar Eduardo Barros <cesarb@cesarb.net> w=
rote:
> Em 23-05-2010 23:05, Minchan Kim escreveu:
>>
>> On Mon, May 24, 2010 at 9:57 AM, Cesar Eduardo Barros<cesarb@cesarb.net>
>> =C2=A0wrote:
>>>
>>> The internal ECC of the disk will not save you - a quick Google search
>>> found
>>> an instance of someone with silent data corruption caused by a faulty
>>> *power
>>> supply*.[1]
>>>
>>> And if it is silent corruption, without the checksums you will not noti=
ce
>>> it
>>> - it will just be dismissed as "oh, Firefox just crashed again" or
>>> similar
>>> (the same as bit flips on RAM without ECC).
>>
>> When I read your comment, suddenly some thought occurred to me.
>> If we can't believe ECC of the disk, why do we separate error
>> detection logic between file system and swap disk?
>>
>> I mean it make sense that put crc detection into block layer?
>> It can make sure any block I/O.
>
> There are differences as to where the checksum will be stored.
>
> For the filesystem (and for the software suspend image), you have to stor=
e
> the checksums in the disk itself, and the correct place (and ordering
> requirements) depends on the filesystem. Also, most filesystems do not
> currently have on-disk checksums.
>
> For the swap, it is much simpler; the checksums can be stored in memory
> (since they do not matter after a reboot; the swap contents are simply
> discarded). This also gives better performance, since the checksums do no=
t
> have to be separately written, and more flexibility, since the kernel can
> use whatever kind of checksum it wants and can store the checksum in
> whatever data structure it choses, without worrying about compatibility.
>
> And, in fact, there is a CRC code in the block layer; it is
> CONFIG_BLK_DEV_INTEGRITY. However, it is not a generic solution; it needs
> some extra prerequisites (like a disk low-level formatted with sectors wi=
th
>>512 bytes).

Thanks for good information.

You mean BLK_DEV_INTEGRITY has a dependency with block device driver?
If you want to support checksum into suspend, At last, should we put
the checksum on disk?

I mean could we extend BLK_DEV_INTEGRITY by more generic solution?
As you said, in case of swap, we don't need to put checksum on disk.

If swap case, let it put the one on memory. If non-swap case, let it
put checksum on disk,
I am not sure it's possible.

When we have a unreliable disk, your point is that let's solve it with
(btrfs + swap) which both supports checksum. And my point is that
let's solve it with (any file system + swap) which is put on block
layer which supports checksum.

I am not a expert of block layer. so whatever i says might be nonsense.
And any mm guys don't oppose this idea until now(except Nick).
Could we regard it as ack of others?

If others don't oppose the idea, I will be not against, either.

Thanks, Cesar.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
