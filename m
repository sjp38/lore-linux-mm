Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 008E46B0038
	for <linux-mm@kvack.org>; Sun, 26 Feb 2017 23:27:15 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id m124so26201389oig.3
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 20:27:15 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0128.outbound.protection.outlook.com. [104.47.38.128])
        by mx.google.com with ESMTPS id r18si1605099otc.62.2017.02.26.20.27.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 26 Feb 2017 20:27:12 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: Is MADV_HWPOISON supposed to work only on faulted-in pages?
Date: Sun, 26 Feb 2017 22:27:02 -0600
Message-ID: <22763879-C335-41E6-8102-2022EED75DAE@cs.rutgers.edu>
In-Reply-To: <20170227012029.GA28934@hori1.linux.bs1.fc.nec.co.jp>
References: <6a445beb-119c-9a9a-0277-07866afe4924@redhat.com>
 <20170220050016.GA15533@hori1.linux.bs1.fc.nec.co.jp>
 <20170223032342.GA18740@hori1.linux.bs1.fc.nec.co.jp>
 <1ba376aa-5e7c-915f-35d1-2d4eef0cad88@huawei.com>
 <20170227012029.GA28934@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_1523C952-EB8A-4F67-AF55-E5482DFF313B_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Jan Stancek <jstancek@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ltp@lists.linux.it" <ltp@lists.linux.it>

--=_MailMate_1523C952-EB8A-4F67-AF55-E5482DFF313B_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 26 Feb 2017, at 19:20, Naoya Horiguchi wrote:

> On Sat, Feb 25, 2017 at 10:28:15AM +0800, Yisheng Xie wrote:
>> hi Naoya,
>>
>> On 2017/2/23 11:23, Naoya Horiguchi wrote:
>>> On Mon, Feb 20, 2017 at 05:00:17AM +0000, Horiguchi Naoya(=E5=A0=80=E5=
=8F=A3 =E7=9B=B4=E4=B9=9F) wrote:
>>>> On Tue, Feb 14, 2017 at 04:41:29PM +0100, Jan Stancek wrote:
>>>>> Hi,
>>>>>
>>>>> code below (and LTP madvise07 [1]) doesn't produce SIGBUS,
>>>>> unless I touch/prefault page before call to madvise().
>>>>>
>>>>> Is this expected behavior?
>>>>
>>>> Thank you for reporting.
>>>>
>>>> madvise(MADV_HWPOISON) triggers page fault when called on the addres=
s
>>>> over which no page is faulted-in, so I think that SIGBUS should be
>>>> called in such case.
>>>>
>>>> But it seems that memory error handler considers such a page as "res=
erved
>>>> kernel page" and recovery action fails (see below.)
>>>>
>>>>   [  383.371372] Injecting memory failure for page 0x1f10 at 0x7efcd=
c569000
>>>>   [  383.375678] Memory failure: 0x1f10: reserved kernel page still =
referenced by 1 users
>>>>   [  383.377570] Memory failure: 0x1f10: recovery action for reserve=
d kernel page: Failed
>>>>
>>>> I'm not sure how/when this behavior was introduced, so I try to unde=
rstand.
>>>
>>> I found that this is a zero page, which is not recoverable for memory=

>>> error now.
>>>
>>>> IMO, the test code below looks valid to me, so no need to change.
>>>
>>> I think that what the testcase effectively does is to test whether me=
mory
>>> handling on zero pages works or not.
>>> And the testcase's failure seems acceptable, because it's simply not-=
implemented yet.
>>> Maybe recovering from error on zero page is possible (because there's=
 no data
>>> loss for memory error,) but I'm not sure that code might be simple en=
ough and/or
>>> it's worth doing ...
>> I question about it,  if a memory error happened on zero page, it will=

>> cause all of data read from zero page is error, I mean no-zero, right?=

>
> Hi Yisheng,
>
> Yes, the impact is serious (could affect many processes,) but it's poss=
ibility
> is very low because there's only one page in a system that is used for =
zero page.
> There are many other pages which are not recoverable for memory error l=
ike
> slab pages, so I'm not sure how I prioritize it (maybe it's not a
> top-priority thing, nor low-hanging fruit.)
>
>> And can we just use re-initial it with zero data maybe by memset ?
>
> Maybe it's not enoguh. Under a real hwpoison, we should isolate the err=
or
> page to prevent the access on the broken data.
> But zero page is statically defined as an array of global variable, so
> it's not trival to replace it with a new zero page at runtime.
>
> Anyway, it's in my todo list, so hopefully revisited in the future.
>

Hi Naoya,

The test case tries to HWPOISON a range of virtual addresses that do not
map to any physical pages.

I expected either madvise should fail because HWPOISON does not work on
non-existing physical pages or madvise_hwpoison() should populate
some physical pages for that virtual address range and poison them.

As I tested it on kernel v4.10, the test application exited at
madvise, because madvise returns -1 and error message is
"Device or resource busy". I think this is a proper behavior.

There might be some confusion in madvise's man page on MADV_HWPOISON.
If you add some text saying madvise fails if any page is not mapped in
the given address range, that can eliminate the confusion.


--
Best Regards
Yan Zi

--=_MailMate_1523C952-EB8A-4F67-AF55-E5482DFF313B_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYs6qXAAoJEEGLLxGcTqbMi+cH/2LydO8wB9pA2qI+hQha6zT7
inLGbVPinD8VxXr/pYCSNUq/D9tvRD2JPR4YLv4syaHYB6V3so31nyyG0oUlniEZ
Rpw4wWwuBDa8T556XFKbgQgka7INSvPmepdqSeUjSSPvD0KoDMSOcuPLfZfrgZwT
T+Y+FXkiwz7SpQDjb7puT4yJDc3mTeq0W73S4udqPq24CIVjIi2jxate3v9aqYsL
v5WCUjOeU1AiYgAgkJ3Sb3xPyHdxJZ1+uD3W2YxW0AwQRryFAtGw/pQdNHOMx4BS
uFYQNsD2569EoaPR+Z+KTY23TP6wRil59/QLGv1l9jF9La4MIMs7bCmGn5ueiAA=
=QLzN
-----END PGP SIGNATURE-----

--=_MailMate_1523C952-EB8A-4F67-AF55-E5482DFF313B_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
