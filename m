Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id C1BC96B004D
	for <linux-mm@kvack.org>; Sat,  8 Feb 2014 14:27:38 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so4564317pab.3
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 11:27:38 -0800 (PST)
Received: from smtp.gentoo.org (smtp.gentoo.org. [140.211.166.183])
        by mx.google.com with ESMTPS id yy4si9530456pbc.159.2014.02.08.11.27.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Feb 2014 11:27:37 -0800 (PST)
Message-ID: <52F68528.30104@gentoo.org>
Date: Sat, 08 Feb 2014 14:27:36 -0500
From: Richard Yao <ryao@gentoo.org>
MIME-Version: 1.0
Subject: Re: [V9fs-developer] finit_module broken on 9p because kernel_read
 doesn't work?
References: <CALCETrWu6wvb4M7UwOdqxNUfSmKV2eZ96qMufAQPF7cJD1oz2w@mail.gmail.com> <20140207195555.GA18916@nautica> <CALCETrWZvz85hxPGYhgHoF4yp06QkP4SxWQBSxFqmTyCqhE3LA@mail.gmail.com> <52F66641.4040405@gentoo.org> <CALCETrVrnX6gWNBOdVTbLZKYWXRWiOYFNgLb0+Sk-bqXsbPc7Q@mail.gmail.com> <52F671D0.1060907@gentoo.org> <CALCETrW5Uh9VgYo6vKVWZtK_yVxEyL6B3V2a2HVxY6H+3dSrRQ@mail.gmail.com> <52F68299.1040305@gentoo.org> <CALCETrUOPPSb9cOgz1NMqR63Y=kXL1r8nw_WnPyZqTAuweLuaA@mail.gmail.com>
In-Reply-To: <CALCETrUOPPSb9cOgz1NMqR63Y=kXL1r8nw_WnPyZqTAuweLuaA@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="Tl3VEM0hldUTkQWmCKRBbsMQVW46Rpeep"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dominique Martinet <dominique.martinet@cea.fr>, Will Deacon <will.deacon@arm.com>, V9FS Developers <v9fs-developer@lists.sourceforge.net>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Rusty Russell <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--Tl3VEM0hldUTkQWmCKRBbsMQVW46Rpeep
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 02/08/2014 02:20 PM, Andy Lutomirski wrote:
> On Sat, Feb 8, 2014 at 11:16 AM, Richard Yao <ryao@gentoo.org> wrote:
>> On 02/08/2014 02:13 PM, Andy Lutomirski wrote:
>>> On Sat, Feb 8, 2014 at 10:05 AM, Richard Yao <ryao@gentoo.org> wrote:=

>>>> On 02/08/2014 12:55 PM, Andy Lutomirski wrote:
>>>>> On Sat, Feb 8, 2014 at 9:15 AM, Richard Yao <ryao@gentoo.org> wrote=
:
>>>>>> On 02/08/2014 01:51 AM, Andy Lutomirski wrote:
>>>>>>> On Fri, Feb 7, 2014 at 11:55 AM, Dominique Martinet
>>>>>>> <dominique.martinet@cea.fr> wrote:
>>>>>>> Hi,
>>>>>>>>
>>>>>>>> Andy Lutomirski wrote on Fri, Feb 07, 2014:
>>>>>>>>> I can't get modules to load from 9p.  The problem seems to be t=
hat a call like:
>>>>>>>>>
>>>>>>>>> kernel_read(f.file, 0, (char *)(info->hdr),, 115551);
>>>>>>>>>
>>>>>>>>> is filling the buffer with mostly zeros (or, more likely, just =
doing
>>>>>>>>> nothing at all).  The call is in module.c, and the fs is mounte=
d with:
>>>>>>>>>
>>>>>>>>> mount -t 9p -o ro,version=3D9p2000.L,trans=3Dvirtio,access=3Dan=
y hostroot /newroot/
>>>>>>>>>
>>>>>>>>> This is really easy to test: grab a copy of virtme
>>>>>>>>> (https://git.kernel.org/cgit/utils/kernel/virtme/virtme.git/), =
build
>>>>>>>>> an appropriate kernel, and run it with virtme-runkernel.  Then =
try to
>>>>>>>>> insmod any module built for that kernel.  It won't work.
>>>>>>>>>
>>>>>>>>> Oddly, running executables from the same fs works, and *copying=
* a
>>>>>>>>> module to tmpfs and insmoding it there also works.
>>>>>>>>>
>>>>>>>>> I'm kind of at a loss debugging this myself.  I'd expect that i=
f
>>>>>>>>> kernel_read were that broken on 9p, then I'd see more obvious
>>>>>>>>> problems.
>>>>>>>>>
>>>>>>>>> This problem exists in at least 3.12 and a recent -linus tree.
>>>>>>>>
>>>>>>>> That's been reported a couple of times[1] since two months ago, =
there's a
>>>>>>>> fix that might or might or might not make it in the tree (Eric?)=
 there:
>>>>>>>> http://www.spinics.net/lists/linux-virtualization/msg21716.html
>>>>>>>>
>>>>>>>> I'm pretty confident that will do it for you, but would be good =
to hear
>>>>>>>> you confirm it again :)
>>>>>>>
>>>>>>> That fixes it for me.  I think it can't be a module address in
>>>>>>> finit_module, though -- it's an intermediate vmalloc buffer.  It
>>>>>>> could, however (in principle) be an address in module data, so th=
e
>>>>>>> full check is probably good.
>>>>>>>
>>>>>>> Can one of you send this to Linus and tag it for -stable?  I can
>>>>>>> trigger this bug without getting an OOPS, which means that 9p is
>>>>>>> overwriting random memory, which puts it in the category of rathe=
r bad
>>>>>>> bugs.  I suspect that this is because I don't have
>>>>>>> CONFIG_DEBUG_VIRTUAL set.
>>>>>>>
>>>>>>> (I can't immediately spot any code that would trigger this from u=
ser
>>>>>>> space without being root, so it's probably not a security bug.)
>>>>>>>
>>>>>>> --Andy
>>>>>>>
>>>>>>
>>>>>> I have already submitted it for inclusion a couple of times.
>>>>>>
>>>>>> The first time was my first time doing any sort of Linux patch
>>>>>> submission. At the time, I was unaware of ./scripts/get_maintainer=
=2Epl
>>>>>> and sent the patch to only a subset of the correct people. Consequ=
ently,
>>>>>> it was not submitted properly for acceptance by the subsystem main=
tainer.
>>>>>>
>>>>>> The second time was a week ago. I had taken advice from Greg
>>>>>> Koah-Hartman to use ./scripts/get_maintainer.pl to determine the c=
orrect
>>>>>> recipients. It was initially accepted by the subsystem maintainer =
and
>>>>>> then rejected. This patch uses is_vmalloc_or_module_addr(), which =
is not
>>>>>> exported for use in kernel modules. Using it causes a build failur=
e when
>>>>>> CONFIG_NET_9P_VIRTIO=3Dm is set in .config.
>>>>>>
>>>>>> I will make a third attempt to mainline this over the next week. L=
ater
>>>>>> today, I will submit a patch exporting is_vmalloc_or_module_addr()=
=2E
>>>>>> After it has been accepted into mainline, I will resubmit this pat=
ch,
>>>>>> which should then be accepted. This should bring this patch into L=
inus'
>>>>>> tree sometime in the next few weeks.
>>>>>
>>>>> I would consider asking some mm people (cc'd) how this is supposed =
to
>>>>> work -- that is, what the appropriate way of mapping a kernel virtu=
al
>>>>> address to a struct page is.
>>>>>
>>>>> I suspect that the answer might be unpleasant: what happens if the
>>>>> address is neither in the linear map nor in vmalloc space?  For
>>>>> example, it could be ioremapped.  (I have no idea under what useful=

>>>>> conditions the 9pnet code wants to zero-copy a buffer, but I suspec=
t
>>>>> that there are exactly zero performance-critical users of kernel_re=
ad
>>>>> and kernel_write.  Presumably this is for skbs or something.)  I
>>>>> suspect that the right fix is to just fall back to non-zero-copy if=

>>>>> the page is neither vmalloc'd nor linear-mapped, which should be
>>>>> doable without new exports.
>>>>>
>>>>> --Andy
>>>>>
>>>>
>>>> That is only possible if someone calls
>>>> p9_client_read()/p9_client_write() on an ioremapped address, which i=
s an
>>>> entirely different problem.
>>>>
>>>
>>> At the very least, calling vmalloc_to_page on a non-vmalloc module
>>> address sounds wrong, so I don't think that exporting
>>> is_vmalloc_or_module_address buys you anything.
>>>
>>> --Andy
>>>
>> The patch does not do what you describe, so we are okay.
>=20
> Are we looking at the same patch?
>=20
> + if (is_vmalloc_or_module_addr(data))
> + pages[index++] =3D vmalloc_to_page(data);
>=20
> if (is_vmalloc_or_module_addr(data) && !is_vmalloc_addr(data)), the
> vmalloc_to_page(data) sounds unhealthy.
>=20
> --Andy
>=20

Mainline loads all Linux kernel modules into virtual memory. No
architecture is known to me where this is not the case.


--Tl3VEM0hldUTkQWmCKRBbsMQVW46Rpeep
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJS9oUqAAoJECDuEZm+6ExkuooP/1IF7iCJORj882MlCa5zsvFh
M7gX8/bIjheKmS9mKKA9U8ZrSxh8ywnE9jyxv/0El3671sc16Lw4nlKa7hlXQADs
6TkkM8408Y9fHx/4ZHLL+kyZnnkD+xTswODwX61kG0SIl96FKD20IEwZNUyWGNYO
sJG1NeK18TUAZMK9xYsHWFYJt9WMTwBCWL4cyIKPiquj4G9Mf8Y1GC5IzMiKRN3f
qTglSZz6mb8ckVeFkx8zBT55jANMHyAGXlBS5JZmvwY48h1cSGQ//HAagFOV3Mym
bbhY1Q+vVZpm9E/UFxt9v1OJrdw4ARSoORsjngHiq70e/O8sQ/O1u8pOUQJOxhce
qbsXtikvr3AIPdTuIsAt8KpyQpZ5pvip5zz34W2SfY5pArO36Mcufckf/rHRtaoF
+UPNdQDgEa2FYiL/S68AEi3/R26SiyBTDGTm4UdFG/g3uYjQQ38rniUnHUFve8ri
P2g3QkDycNeuvPYLgl/xWyFY3DnzYA+EoLfMnhhkbEHWNU01qotI2gARG8l9wUDJ
EuHSv0VhsrJC2aOaxk6sg3+5zAgDkGhptcv9xlumI0pJoh77AYWfqayvwi9eiBpT
OZGmOEJEmSJEQczRRCfunbq7lX+VMhuJfE8IxBzXYcOu15iwYZhCAmHBkLnO/Lbu
1XI/S2LB0SBzuH98N84I
=EiPA
-----END PGP SIGNATURE-----

--Tl3VEM0hldUTkQWmCKRBbsMQVW46Rpeep--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
