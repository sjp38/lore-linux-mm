Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 321696B003B
	for <linux-mm@kvack.org>; Sat,  8 Feb 2014 14:16:45 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so4620038pbc.13
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 11:16:44 -0800 (PST)
Received: from smtp.gentoo.org (dev.gentoo.org. [2001:470:ea4a:1:214:c2ff:fe64:b2d3])
        by mx.google.com with ESMTPS id ot3si9531643pac.79.2014.02.08.11.16.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Feb 2014 11:16:44 -0800 (PST)
Message-ID: <52F68299.1040305@gentoo.org>
Date: Sat, 08 Feb 2014 14:16:41 -0500
From: Richard Yao <ryao@gentoo.org>
MIME-Version: 1.0
Subject: Re: [V9fs-developer] finit_module broken on 9p because kernel_read
 doesn't work?
References: <CALCETrWu6wvb4M7UwOdqxNUfSmKV2eZ96qMufAQPF7cJD1oz2w@mail.gmail.com> <20140207195555.GA18916@nautica> <CALCETrWZvz85hxPGYhgHoF4yp06QkP4SxWQBSxFqmTyCqhE3LA@mail.gmail.com> <52F66641.4040405@gentoo.org> <CALCETrVrnX6gWNBOdVTbLZKYWXRWiOYFNgLb0+Sk-bqXsbPc7Q@mail.gmail.com> <52F671D0.1060907@gentoo.org> <CALCETrW5Uh9VgYo6vKVWZtK_yVxEyL6B3V2a2HVxY6H+3dSrRQ@mail.gmail.com>
In-Reply-To: <CALCETrW5Uh9VgYo6vKVWZtK_yVxEyL6B3V2a2HVxY6H+3dSrRQ@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="LsdgpADssBh6gNLkwiwluDulaRtaHa4j4"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dominique Martinet <dominique.martinet@cea.fr>, Will Deacon <will.deacon@arm.com>, V9FS Developers <v9fs-developer@lists.sourceforge.net>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Rusty Russell <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--LsdgpADssBh6gNLkwiwluDulaRtaHa4j4
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 02/08/2014 02:13 PM, Andy Lutomirski wrote:
> On Sat, Feb 8, 2014 at 10:05 AM, Richard Yao <ryao@gentoo.org> wrote:
>> On 02/08/2014 12:55 PM, Andy Lutomirski wrote:
>>> On Sat, Feb 8, 2014 at 9:15 AM, Richard Yao <ryao@gentoo.org> wrote:
>>>> On 02/08/2014 01:51 AM, Andy Lutomirski wrote:
>>>>> On Fri, Feb 7, 2014 at 11:55 AM, Dominique Martinet
>>>>> <dominique.martinet@cea.fr> wrote:
>>>>> Hi,
>>>>>>
>>>>>> Andy Lutomirski wrote on Fri, Feb 07, 2014:
>>>>>>> I can't get modules to load from 9p.  The problem seems to be tha=
t a call like:
>>>>>>>
>>>>>>> kernel_read(f.file, 0, (char *)(info->hdr),, 115551);
>>>>>>>
>>>>>>> is filling the buffer with mostly zeros (or, more likely, just do=
ing
>>>>>>> nothing at all).  The call is in module.c, and the fs is mounted =
with:
>>>>>>>
>>>>>>> mount -t 9p -o ro,version=3D9p2000.L,trans=3Dvirtio,access=3Dany =
hostroot /newroot/
>>>>>>>
>>>>>>> This is really easy to test: grab a copy of virtme
>>>>>>> (https://git.kernel.org/cgit/utils/kernel/virtme/virtme.git/), bu=
ild
>>>>>>> an appropriate kernel, and run it with virtme-runkernel.  Then tr=
y to
>>>>>>> insmod any module built for that kernel.  It won't work.
>>>>>>>
>>>>>>> Oddly, running executables from the same fs works, and *copying* =
a
>>>>>>> module to tmpfs and insmoding it there also works.
>>>>>>>
>>>>>>> I'm kind of at a loss debugging this myself.  I'd expect that if
>>>>>>> kernel_read were that broken on 9p, then I'd see more obvious
>>>>>>> problems.
>>>>>>>
>>>>>>> This problem exists in at least 3.12 and a recent -linus tree.
>>>>>>
>>>>>> That's been reported a couple of times[1] since two months ago, th=
ere's a
>>>>>> fix that might or might or might not make it in the tree (Eric?) t=
here:
>>>>>> http://www.spinics.net/lists/linux-virtualization/msg21716.html
>>>>>>
>>>>>> I'm pretty confident that will do it for you, but would be good to=
 hear
>>>>>> you confirm it again :)
>>>>>
>>>>> That fixes it for me.  I think it can't be a module address in
>>>>> finit_module, though -- it's an intermediate vmalloc buffer.  It
>>>>> could, however (in principle) be an address in module data, so the
>>>>> full check is probably good.
>>>>>
>>>>> Can one of you send this to Linus and tag it for -stable?  I can
>>>>> trigger this bug without getting an OOPS, which means that 9p is
>>>>> overwriting random memory, which puts it in the category of rather =
bad
>>>>> bugs.  I suspect that this is because I don't have
>>>>> CONFIG_DEBUG_VIRTUAL set.
>>>>>
>>>>> (I can't immediately spot any code that would trigger this from use=
r
>>>>> space without being root, so it's probably not a security bug.)
>>>>>
>>>>> --Andy
>>>>>
>>>>
>>>> I have already submitted it for inclusion a couple of times.
>>>>
>>>> The first time was my first time doing any sort of Linux patch
>>>> submission. At the time, I was unaware of ./scripts/get_maintainer.p=
l
>>>> and sent the patch to only a subset of the correct people. Consequen=
tly,
>>>> it was not submitted properly for acceptance by the subsystem mainta=
iner.
>>>>
>>>> The second time was a week ago. I had taken advice from Greg
>>>> Koah-Hartman to use ./scripts/get_maintainer.pl to determine the cor=
rect
>>>> recipients. It was initially accepted by the subsystem maintainer an=
d
>>>> then rejected. This patch uses is_vmalloc_or_module_addr(), which is=
 not
>>>> exported for use in kernel modules. Using it causes a build failure =
when
>>>> CONFIG_NET_9P_VIRTIO=3Dm is set in .config.
>>>>
>>>> I will make a third attempt to mainline this over the next week. Lat=
er
>>>> today, I will submit a patch exporting is_vmalloc_or_module_addr().
>>>> After it has been accepted into mainline, I will resubmit this patch=
,
>>>> which should then be accepted. This should bring this patch into Lin=
us'
>>>> tree sometime in the next few weeks.
>>>
>>> I would consider asking some mm people (cc'd) how this is supposed to=

>>> work -- that is, what the appropriate way of mapping a kernel virtual=

>>> address to a struct page is.
>>>
>>> I suspect that the answer might be unpleasant: what happens if the
>>> address is neither in the linear map nor in vmalloc space?  For
>>> example, it could be ioremapped.  (I have no idea under what useful
>>> conditions the 9pnet code wants to zero-copy a buffer, but I suspect
>>> that there are exactly zero performance-critical users of kernel_read=

>>> and kernel_write.  Presumably this is for skbs or something.)  I
>>> suspect that the right fix is to just fall back to non-zero-copy if
>>> the page is neither vmalloc'd nor linear-mapped, which should be
>>> doable without new exports.
>>>
>>> --Andy
>>>
>>
>> That is only possible if someone calls
>> p9_client_read()/p9_client_write() on an ioremapped address, which is =
an
>> entirely different problem.
>>
>=20
> At the very least, calling vmalloc_to_page on a non-vmalloc module
> address sounds wrong, so I don't think that exporting
> is_vmalloc_or_module_address buys you anything.
>=20
> --Andy
>=20
The patch does not do what you describe, so we are okay.


--LsdgpADssBh6gNLkwiwluDulaRtaHa4j4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJS9oKcAAoJECDuEZm+6ExkcdYP/2sBAYDOcdqHSJL/+rAQtS5Q
Wi8m+9yZVqMqfBhBiw4XugQ7mvPdBnJU0sJc4bEZdopMPsEDc2owRG0Qmi0f/0F3
DeaNJojdM/yW4jPvBehn4hVMqab7K52oROEA97UMwkjuM4/gN7YxMKaoz7pJc1t9
pkMJAmQ5wA2FKiKI5XihXBMi0ibZzQ3wcQkype0HioWQBNirqtr/R7xqQcZ+nBJm
fkh/Ijc+vifukig4izS4MEYF+E2/+gL8ynjgE4WA7jGwApFVnVoe7yyA1UFOuiRJ
p3PS9QiXmsqcnkpy9kQAUhNmA9yzHi9Czsh4rkfbW2lNnYvG5lHDCiwp5maNG7LI
fAtFpp+s5Xf0gs9iWPb8rT5tuypkY5hoHKm593smEz3kU1z3r4T0FMmihWIegbfG
XMhxwnXsGEGZI4E+gYnyU17cQ8tVZPT784jUGfEQqv0L4UP0YI85ZP36H1xCYM+L
XD8i/DMcT0y3pilr6Vgr7fj2a+QSSNhSoY8QDQMCK8pC0SH7oTII32LtEChdRaTf
AjmidK5ILfmkkEtw5hUfLoSlkZ1KvZyrdy0zqlnc4O7+yb6HoV2PnsVqQl0JMA2S
5FxkB++mZ3CDwjZW7Osu+8p3lpkFR+Ry7sby+SY+xZhdIErNU8vXj/Enb/VDaobV
rW2mJ5U7CEibVfaQfHIY
=36ly
-----END PGP SIGNATURE-----

--LsdgpADssBh6gNLkwiwluDulaRtaHa4j4--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
