Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0880B6B0031
	for <linux-mm@kvack.org>; Sat,  8 Feb 2014 13:05:08 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id um1so4546131pbc.19
        for <linux-mm@kvack.org>; Sat, 08 Feb 2014 10:05:08 -0800 (PST)
Received: from smtp.gentoo.org (woodpecker.gentoo.org. [2001:470:ea4a:1:214:c2ff:fe64:b2d3])
        by mx.google.com with ESMTPS id gj4si9385775pac.2.2014.02.08.10.05.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Feb 2014 10:05:07 -0800 (PST)
Message-ID: <52F671D0.1060907@gentoo.org>
Date: Sat, 08 Feb 2014 13:05:04 -0500
From: Richard Yao <ryao@gentoo.org>
MIME-Version: 1.0
Subject: Re: [V9fs-developer] finit_module broken on 9p because kernel_read
 doesn't work?
References: <CALCETrWu6wvb4M7UwOdqxNUfSmKV2eZ96qMufAQPF7cJD1oz2w@mail.gmail.com> <20140207195555.GA18916@nautica> <CALCETrWZvz85hxPGYhgHoF4yp06QkP4SxWQBSxFqmTyCqhE3LA@mail.gmail.com> <52F66641.4040405@gentoo.org> <CALCETrVrnX6gWNBOdVTbLZKYWXRWiOYFNgLb0+Sk-bqXsbPc7Q@mail.gmail.com>
In-Reply-To: <CALCETrVrnX6gWNBOdVTbLZKYWXRWiOYFNgLb0+Sk-bqXsbPc7Q@mail.gmail.com>
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="mBNfagCvGsEupI7w5sXnxnS0BMxFUqdlq"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dominique Martinet <dominique.martinet@cea.fr>, Will Deacon <will.deacon@arm.com>, V9FS Developers <v9fs-developer@lists.sourceforge.net>, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, Rusty Russell <rusty@rustcorp.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--mBNfagCvGsEupI7w5sXnxnS0BMxFUqdlq
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 02/08/2014 12:55 PM, Andy Lutomirski wrote:
> On Sat, Feb 8, 2014 at 9:15 AM, Richard Yao <ryao@gentoo.org> wrote:
>> On 02/08/2014 01:51 AM, Andy Lutomirski wrote:
>>> On Fri, Feb 7, 2014 at 11:55 AM, Dominique Martinet
>>> <dominique.martinet@cea.fr> wrote:
>>> Hi,
>>>>
>>>> Andy Lutomirski wrote on Fri, Feb 07, 2014:
>>>>> I can't get modules to load from 9p.  The problem seems to be that =
a call like:
>>>>>
>>>>> kernel_read(f.file, 0, (char *)(info->hdr),, 115551);
>>>>>
>>>>> is filling the buffer with mostly zeros (or, more likely, just doin=
g
>>>>> nothing at all).  The call is in module.c, and the fs is mounted wi=
th:
>>>>>
>>>>> mount -t 9p -o ro,version=3D9p2000.L,trans=3Dvirtio,access=3Dany ho=
stroot /newroot/
>>>>>
>>>>> This is really easy to test: grab a copy of virtme
>>>>> (https://git.kernel.org/cgit/utils/kernel/virtme/virtme.git/), buil=
d
>>>>> an appropriate kernel, and run it with virtme-runkernel.  Then try =
to
>>>>> insmod any module built for that kernel.  It won't work.
>>>>>
>>>>> Oddly, running executables from the same fs works, and *copying* a
>>>>> module to tmpfs and insmoding it there also works.
>>>>>
>>>>> I'm kind of at a loss debugging this myself.  I'd expect that if
>>>>> kernel_read were that broken on 9p, then I'd see more obvious
>>>>> problems.
>>>>>
>>>>> This problem exists in at least 3.12 and a recent -linus tree.
>>>>
>>>> That's been reported a couple of times[1] since two months ago, ther=
e's a
>>>> fix that might or might or might not make it in the tree (Eric?) the=
re:
>>>> http://www.spinics.net/lists/linux-virtualization/msg21716.html
>>>>
>>>> I'm pretty confident that will do it for you, but would be good to h=
ear
>>>> you confirm it again :)
>>>
>>> That fixes it for me.  I think it can't be a module address in
>>> finit_module, though -- it's an intermediate vmalloc buffer.  It
>>> could, however (in principle) be an address in module data, so the
>>> full check is probably good.
>>>
>>> Can one of you send this to Linus and tag it for -stable?  I can
>>> trigger this bug without getting an OOPS, which means that 9p is
>>> overwriting random memory, which puts it in the category of rather ba=
d
>>> bugs.  I suspect that this is because I don't have
>>> CONFIG_DEBUG_VIRTUAL set.
>>>
>>> (I can't immediately spot any code that would trigger this from user
>>> space without being root, so it's probably not a security bug.)
>>>
>>> --Andy
>>>
>>
>> I have already submitted it for inclusion a couple of times.
>>
>> The first time was my first time doing any sort of Linux patch
>> submission. At the time, I was unaware of ./scripts/get_maintainer.pl
>> and sent the patch to only a subset of the correct people. Consequentl=
y,
>> it was not submitted properly for acceptance by the subsystem maintain=
er.
>>
>> The second time was a week ago. I had taken advice from Greg
>> Koah-Hartman to use ./scripts/get_maintainer.pl to determine the corre=
ct
>> recipients. It was initially accepted by the subsystem maintainer and
>> then rejected. This patch uses is_vmalloc_or_module_addr(), which is n=
ot
>> exported for use in kernel modules. Using it causes a build failure wh=
en
>> CONFIG_NET_9P_VIRTIO=3Dm is set in .config.
>>
>> I will make a third attempt to mainline this over the next week. Later=

>> today, I will submit a patch exporting is_vmalloc_or_module_addr().
>> After it has been accepted into mainline, I will resubmit this patch,
>> which should then be accepted. This should bring this patch into Linus=
'
>> tree sometime in the next few weeks.
>=20
> I would consider asking some mm people (cc'd) how this is supposed to
> work -- that is, what the appropriate way of mapping a kernel virtual
> address to a struct page is.
>=20
> I suspect that the answer might be unpleasant: what happens if the
> address is neither in the linear map nor in vmalloc space?  For
> example, it could be ioremapped.  (I have no idea under what useful
> conditions the 9pnet code wants to zero-copy a buffer, but I suspect
> that there are exactly zero performance-critical users of kernel_read
> and kernel_write.  Presumably this is for skbs or something.)  I
> suspect that the right fix is to just fall back to non-zero-copy if
> the page is neither vmalloc'd nor linear-mapped, which should be
> doable without new exports.
>=20
> --Andy
>=20

That is only possible if someone calls
p9_client_read()/p9_client_write() on an ioremapped address, which is an
entirely different problem.


--mBNfagCvGsEupI7w5sXnxnS0BMxFUqdlq
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJS9nHUAAoJECDuEZm+6ExkijsQAJV9/1fj9fb3CrJNY2Ua+RxQ
Pz/QeGIkyZ8ZxZdT7DeqpbST/3foxOCyK8b4H3x1xpOK2faJKZgds1B9vdLVkXYO
RqxpMpEpQCmR1DV11XDKDzkuCyX9sTNKGwfBJgmJBSNf+VXICEwAqHUgGqcSGcqj
ZfHeAZJk2Ok9m2coSfyFXJTbPxWbMXl+to3LRaaV8EBRFZ56gAJD2Y7yqCe0ZlO4
DqaqigTdRfI9H+VRQ0aOVfM4mOgvcQTzJpBFB48X+npJU7zIM7uz6W/AUBlnW0AF
7ypmmkMxjn5W6uH8xBnT4Q60/byEW2cNGsctDIe+1m7DHdRkndLo8Ic5BE332s6g
5ujCpq0acdNlrru30doRcNZOzCdGtUkP59OPKSjoIwglo83IqJbw3mg/Du4C7oP9
qI5+OBeHYcYZihll2FJRHhW4noHFpIgDCTk0KPzsQO/WYOsi3ZtqHoPEeO1GjGJG
BaXP3YxGp0RpWpLFhehK/5iCkqyO5SHdxQvSGyRbkKDujcikDFZRttgX7rM+m+jE
2wjh5ugT0OrDHmc2kvbkyp55tsoJ5iHW4xW+VlmgoydkrI876ZqzOAeB9a+JEWV2
PfrWP0DvAXN6icr/uZRg8hdQ3O95ITSReEV0VJ6eFQKWqPIughYHg6W/dQp8Ek9O
YAYmWBADT/MXtnT5om9a
=gFmm
-----END PGP SIGNATURE-----

--mBNfagCvGsEupI7w5sXnxnS0BMxFUqdlq--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
