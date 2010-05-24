Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 8133F6B01B0
	for <linux-mm@kvack.org>; Sun, 23 May 2010 22:05:51 -0400 (EDT)
Received: by iwn39 with SMTP id 39so3300253iwn.14
        for <linux-mm@kvack.org>; Sun, 23 May 2010 19:05:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4BF9CF00.2030704@cesarb.net>
References: <4BF81D87.6010506@cesarb.net>
	<20100523140348.GA10843@barrios-desktop>
	<4BF974D5.30207@cesarb.net>
	<AANLkTil1kwOHAcBpsZ_MdtjLmCAFByvF4xvm8JJ7r7dH@mail.gmail.com>
	<4BF9CF00.2030704@cesarb.net>
Date: Mon, 24 May 2010 11:05:47 +0900
Message-ID: <AANLkTin_BV6nWlmX6aXTaHvzH-DnsFIVxP5hz4aZYlqH@mail.gmail.com>
Subject: Re: [PATCH 0/3] mm: Swap checksum
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Cesar Eduardo Barros <cesarb@cesarb.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, May 24, 2010 at 9:57 AM, Cesar Eduardo Barros <cesarb@cesarb.net> w=
rote:
> Em 23-05-2010 21:09, Minchan Kim escreveu:
>>
>> Hi, Cesar.
>> I am not sure Cesar is first name. :)
>
> Yes, it is.
>
>> On Mon, May 24, 2010 at 3:32 AM, Cesar Eduardo Barros<cesarb@cesarb.net>
>> =C2=A0wrote:
>>>
>>> Em 23-05-2010 11:03, Minchan Kim escreveu:
>>>>
>>>> We have been used swap pages without checksum.
>>>>
>>>> First of all, Could you explain why you need checksum on swap pages?
>>>> Do you see any problem which swap pages are broken?
>>>
>>> The same reason we need checksums in the filesystem.
>>>
>>> If you use btrfs as your root filesystem, you are protected by checksum=
s
>>> from damage in the filesystem, but not in the swap partition (which is
>>> often
>>> in the same disk, and thus as vulnerable as the filesystem). It is bett=
er
>>> to
>>> get a checksum error when swapping in than having a silently corrupted
>>> page.
>>
>> Do you mean "vulnerable" is other file system or block I/O operation
>> invades swap partition and breaks data of swap?
>
> Vulnerable in that the same kind of hardware problems which can silently
> damage filesystem data in the disk can damage swap pages in the disk.
>
> This is the reason both btrfs and zfs checksum all their data and metadat=
a.
> However, the swap partition is still vulnerable (using a swap file is not=
 a
> solution, since the swap code bypasses the filesystem). And silent data
> corruption in the swap partition could be even worse than in the filesyst=
em
> - while a program might not trust a file it is reading to not be corrupte=
d,
> almost all programs will trust their *memory* to not be corrupted.
>
> The internal ECC of the disk will not save you - a quick Google search fo=
und
> an instance of someone with silent data corruption caused by a faulty *po=
wer
> supply*.[1]
>
> And if it is silent corruption, without the checksums you will not notice=
 it
> - it will just be dismissed as "oh, Firefox just crashed again" or simila=
r
> (the same as bit flips on RAM without ECC).

Thanks for kind explanation.

When I read your comment, suddenly some thought occurred to me.
If we can't believe ECC of the disk, why do we separate error
detection logic between file system and swap disk?

I mean it make sense that put crc detection into block layer?
It can make sure any block I/O.

And what's BER of disk?
Is it usual to meet the problem?

In normal desktop, some app killed are not critical. If the
application is critical, maybe app have to logic fault handling.
Firefox has session restore feature and Office program has temporal
save feature.

On the other hand, in server, does it designed well to use swap disk
until we meet bit error of disk?

My feel is that it seem to be rather overkill.

>
>> If it is, I think it's the problem of them. so we have to fix it
>> before merged into mainline. But I admit human being always take a
>> mistake so that we can miss it at review time. In such case, it would
>> be very hard bug when swap pages are broken. I haven't hear about such
>> problem until now but it might be useful if the problem happens.
>> (Maybe they can't notice that due to hard bug to find)
>>
>> But I have a concern about breaking memory which includes crc by
>> dangling pointer. In this case, swap block is correct but it would
>> emit crc error.
>>
>> Do you have an idea making sure memory includes crc is correct?
>
> The swap checksum only protects the page against being silently corrupted
> while on the disk and at least to some degree on the I/O path between the
> memory and the disk. It does not protect against broken kernel-mode code
> writing to the wrong address, nor against broken hardware (or hardware
> misconfigured by broken drivers) doing DMA to wrong addresses. It also do=
es
> not protect against hardware errors in the RAM itself (you have ECC memor=
y
> for that).
>
> That is, the code assumes the memory containing the checksums will not be
> corrupted, because if it is, you have worse problems (and the CRC error h=
ere
> would be a *good* thing, since it would make you notice something is not
> quite right).
>

Which is high between BER of RAM and disk?
It's a just question. :)

>
> [1] http://blogs.sun.com/elowe/entry/zfs_saves_the_day_ta
>
> --
> Cesar Eduardo Barros
> cesarb@cesarb.net
> cesar.barros@gmail.com
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
