Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5CB736B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 11:10:51 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id u62so89796523pfk.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 08:10:51 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0091.outbound.protection.outlook.com. [104.47.38.91])
        by mx.google.com with ESMTPS id p79si15498166pfj.282.2017.02.27.08.10.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 27 Feb 2017 08:10:48 -0800 (PST)
From: Zi Yan <zi.yan@cs.rutgers.edu>
Subject: Re: Is MADV_HWPOISON supposed to work only on faulted-in pages?
Date: Mon, 27 Feb 2017 10:10:40 -0600
Message-ID: <687984BF-0EE0-42DB-B414-F93CACD72F27@cs.rutgers.edu>
In-Reply-To: <20170227063308.GA14387@hori1.linux.bs1.fc.nec.co.jp>
References: <6a445beb-119c-9a9a-0277-07866afe4924@redhat.com>
 <20170220050016.GA15533@hori1.linux.bs1.fc.nec.co.jp>
 <20170223032342.GA18740@hori1.linux.bs1.fc.nec.co.jp>
 <1ba376aa-5e7c-915f-35d1-2d4eef0cad88@huawei.com>
 <20170227012029.GA28934@hori1.linux.bs1.fc.nec.co.jp>
 <22763879-C335-41E6-8102-2022EED75DAE@cs.rutgers.edu>
 <20170227063308.GA14387@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed;
	boundary="=_MailMate_52DA8606-C8B7-4990-9456-EBB18ABCFDD1_=";
	micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Yisheng Xie <xieyisheng1@huawei.com>, Jan Stancek <jstancek@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "ltp@lists.linux.it" <ltp@lists.linux.it>

--=_MailMate_52DA8606-C8B7-4990-9456-EBB18ABCFDD1_=
Content-Type: text/plain; charset=utf-8; markup=markdown
Content-Transfer-Encoding: quoted-printable

On 27 Feb 2017, at 0:33, Naoya Horiguchi wrote:

> On Sun, Feb 26, 2017 at 10:27:02PM -0600, Zi Yan wrote:
>> On 26 Feb 2017, at 19:20, Naoya Horiguchi wrote:
>>
>>> On Sat, Feb 25, 2017 at 10:28:15AM +0800, Yisheng Xie wrote:
>>>> hi Naoya,
>>>>
>>>> On 2017/2/23 11:23, Naoya Horiguchi wrote:
>>>>> On Mon, Feb 20, 2017 at 05:00:17AM +0000, Horiguchi Naoya(=E5=A0=80=
=E5=8F=A3 =E7=9B=B4=E4=B9=9F) wrote:
>>>>>> On Tue, Feb 14, 2017 at 04:41:29PM +0100, Jan Stancek wrote:
>>>>>>> Hi,
>>>>>>>
>>>>>>> code below (and LTP madvise07 [1]) doesn't produce SIGBUS,
>>>>>>> unless I touch/prefault page before call to madvise().
>>>>>>>
>>>>>>> Is this expected behavior?
>>>>>>
>>>>>> Thank you for reporting.
>>>>>>
>>>>>> madvise(MADV_HWPOISON) triggers page fault when called on the addr=
ess
>>>>>> over which no page is faulted-in, so I think that SIGBUS should be=

>>>>>> called in such case.
>>>>>>
>>>>>> But it seems that memory error handler considers such a page as "r=
eserved
>>>>>> kernel page" and recovery action fails (see below.)
>>>>>>
>>>>>>   [  383.371372] Injecting memory failure for page 0x1f10 at 0x7ef=
cdc569000
>>>>>>   [  383.375678] Memory failure: 0x1f10: reserved kernel page stil=
l referenced by 1 users
>>>>>>   [  383.377570] Memory failure: 0x1f10: recovery action for reser=
ved kernel page: Failed
>>>>>>
>>>>>> I'm not sure how/when this behavior was introduced, so I try to un=
derstand.
>>>>>
>>>>> I found that this is a zero page, which is not recoverable for memo=
ry
>>>>> error now.
>>>>>
>>>>>> IMO, the test code below looks valid to me, so no need to change.
>>>>>
>>>>> I think that what the testcase effectively does is to test whether =
memory
>>>>> handling on zero pages works or not.
>>>>> And the testcase's failure seems acceptable, because it's simply no=
t-implemented yet.
>>>>> Maybe recovering from error on zero page is possible (because there=
's no data
>>>>> loss for memory error,) but I'm not sure that code might be simple =
enough and/or
>>>>> it's worth doing ...
>>>> I question about it,  if a memory error happened on zero page, it wi=
ll
>>>> cause all of data read from zero page is error, I mean no-zero, righ=
t?
>>>
>>> Hi Yisheng,
>>>
>>> Yes, the impact is serious (could affect many processes,) but it's po=
ssibility
>>> is very low because there's only one page in a system that is used fo=
r zero page.
>>> There are many other pages which are not recoverable for memory error=
 like
>>> slab pages, so I'm not sure how I prioritize it (maybe it's not a
>>> top-priority thing, nor low-hanging fruit.)
>>>
>>>> And can we just use re-initial it with zero data maybe by memset ?
>>>
>>> Maybe it's not enoguh. Under a real hwpoison, we should isolate the e=
rror
>>> page to prevent the access on the broken data.
>>> But zero page is statically defined as an array of global variable, s=
o
>>> it's not trival to replace it with a new zero page at runtime.
>>>
>>> Anyway, it's in my todo list, so hopefully revisited in the future.
>>>
>>
>> Hi Naoya,
>>
>> The test case tries to HWPOISON a range of virtual addresses that do n=
ot
>> map to any physical pages.
>>
>
> Hi Yan,
>
>> I expected either madvise should fail because HWPOISON does not work o=
n
>> non-existing physical pages or madvise_hwpoison() should populate
>> some physical pages for that virtual address range and poison them.
>
> The latter is the current behavior. It just comes from get_user_pages_f=
ast()
> which not only finds the page and takes refcount, but also touch the pa=
ge.
>
> madvise(MADV_HWPOISON) is a test feature, and calling it for address ba=
cked
> by no page doesn't simulate anything real. IOW, the behavior is undefin=
ed.
> So I don't have a strong opinion about how it should behave.
>
>>
>> As I tested it on kernel v4.10, the test application exited at
>> madvise, because madvise returns -1 and error message is
>> "Device or resource busy". I think this is a proper behavior.
>
> yes, maybe we see the same thing, you can see in dmesg "recovery action=

> for reserved kernel page: Failed" message.
>
>>
>> There might be some confusion in madvise's man page on MADV_HWPOISON.
>> If you add some text saying madvise fails if any page is not mapped in=

>> the given address range, that can eliminate the confusion*
>
> Writing it down to man page makes readers think this behavior is a part=
 of
> specification, that might not be good now because the failure in error
> handling of zero page is not the eventually fixed behavior.
> I mean that if zero page handles hwpoison properly in the future, madvi=
se
> will succeed without any confusion.
> So I feel that we don't have to update man page for this issue.

You are right, I missed the part that get_user_pages_fast() will actually=
 fault
in the madvised pages with zero_page.

Thanks for clarifying this.

--
Best Regards
Yan Zi

--=_MailMate_52DA8606-C8B7-4990-9456-EBB18ABCFDD1_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJYtE+BAAoJEEGLLxGcTqbM9IQIAJacxBcd5g7Qku5Y7sUTdc4j
K20yeyLkylaWjcUv5KvsstM2ntOxSl/gwx2+pk2jI2XZdASm2kbQOrEsZzT80UFU
Eg++nj5lYRkD3vFSehXPKOCi8lXyhRJtNtn5XkZaw4WKG+/BIlQd0BuGjFTEi9LE
8jQWkQtfL28d+CTzuSwV+jAS1dpSHykEWZJzOgS1z+0/NOqIIfkO/BIA6QM5Gat/
UlvZKlOOusDEmPqBpDQF2r5BiMnYDoaibO3Q3wBQIvNfc2dwmHlSU1zvg6hK2Gs+
+aFym1wLYPXjL5+rqExgpOXxU8Q888NZmqjy7JcpsmDc7HS1QunJUrdBS36J5as=
=PqwV
-----END PGP SIGNATURE-----

--=_MailMate_52DA8606-C8B7-4990-9456-EBB18ABCFDD1_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
