Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 08CF92808A4
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 10:26:52 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id j2so3827302qti.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 07:26:52 -0700 (PDT)
Received: from out2-smtp.messagingengine.com (out2-smtp.messagingengine.com. [66.111.4.26])
        by mx.google.com with ESMTPS id m19si4184069qkm.244.2017.08.24.07.26.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 07:26:50 -0700 (PDT)
From: "Zi Yan" <zi.yan@sent.com>
Subject: Re: [RFC PATCH 1/4] mm: madvise: read loop's step size beforehand in
 madvise_inject_error(), prepare for THP support.
Date: Thu, 24 Aug 2017 10:26:49 -0400
Message-ID: <3840667D-BE51-44AB-A895-DE6F5E2E5C92@sent.com>
In-Reply-To: <20170824042608.GA30150@hori1.linux.bs1.fc.nec.co.jp>
References: <20170815015216.31827-1-zi.yan@sent.com>
 <20170815015216.31827-2-zi.yan@sent.com>
 <20170823074933.GA3527@hori1.linux.bs1.fc.nec.co.jp>
 <41F3B393-6FDA-4CF9-A790-A1B4B4FDFA58@sent.com>
 <20170824042608.GA30150@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_EFCA1392-DD1E-48A7-B08E-B445F432EE75_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_EFCA1392-DD1E-48A7-B08E-B445F432EE75_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 24 Aug 2017, at 0:26, Naoya Horiguchi wrote:

> On Wed, Aug 23, 2017 at 10:20:02AM -0400, Zi Yan wrote:
>> On 23 Aug 2017, at 3:49, Naoya Horiguchi wrote:
>>
>>> On Mon, Aug 14, 2017 at 09:52:13PM -0400, Zi Yan wrote:
>>>> From: Zi Yan <zi.yan@cs.rutgers.edu>
>>>>
>>>> The loop in madvise_inject_error() reads its step size from a page
>>>> after it is soft-offlined. It works because the page is:
>>>> 1) a hugetlb page: the page size does not change;
>>>> 2) a base page: the page size does not change;
>>>> 3) a THP: soft-offline always splits THPs, thus, it is OK to use
>>>>    PAGE_SIZE as step size.
>>>>
>>>> It will be a problem when soft-offline supports THP migrations.
>>>> When a THP is migrated without split during soft-offlining, the THP
>>>> is split after migration, thus, before and after soft-offlining page=

>>>> sizes do not match. This causes a THP to be unnecessarily soft-lined=
,
>>>> at most, 511 times, wasting free space.
>>>
>>> Hi Zi Yan,
>>>
>>> Thank you for the suggestion.
>>>
>>> I think that when madvise(MADV_SOFT_OFFLINE) is called with some rang=
e
>>> over more than one 4kB page, the caller clearly intends to call
>>> soft_offline_page() over all 4kB pages within the range in order to
>>> simulate the multiple soft-offline events. Please note that the calle=
r
>>> only knows that specific pages are half-broken, and expect that all s=
uch
>>> pages are offlined. So the end result should be same, whether the giv=
en
>>> range is backed by thp or not.
>>>
>>
>> But if the given virtual address is backed by a THP and the THP is sof=
t-offlined
>> without splitting (enabled by following patches), the old for-loop wil=
l cause extra
>> 511 THPs being soft-offlined.
>>
>> For example, the caller wants to offline VPN 0-511, which is backed by=
 a THP whose
>> address range is PFN 0-511. In the first iteration of the for-loop,
>> get_user_pages_fast(VPN0, ...) will return the THP and soft_offline_pa=
ge() will offline the THP,
>> replacing it with a new THP, say PFN 512-1023, so VPN 0-511 is backed =
by PFN 512-1023.
>> But the original THP will be split after it is freed, thus, for-loop w=
ill not end
>> at this moment, but continues to offline VPN1, which leads to PFN 512-=
1023 being offlined
>> and replaced by another THP, say 1024-1535. This will go on and end up=
 with
>> 511 extra THPs are offlined. That is why we need to this patch to tell=

>> whether the THP is offlined as a whole or just its head page is offlin=
ed.
>
> Thanks for elaborating this. I understand your point.
> But I still not sure what the best behavior is.
>
> madvise(MADV_SOFT_OFFLINE) is a test feature and giving multi-page rang=
e
> on the call works like some stress testing. So multiple thp migrations
> seem to me an expected behavior. At least it behaves in the same manner=

> as calling madvise(MADV_SOFT_OFFLINE) 512 times on VPN0-VPN511 separate=
ly,
> which is consistent.
>
> So I still feel like leaving the current behavior as long as your later=

> patches work without this change.

Sure. I will drop Patch 1 and 2 in the next version.

Thanks for your explanation.

--
Best Regards
Yan Zi

--=_MailMate_EFCA1392-DD1E-48A7-B08E-B445F432EE75_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJZnuIpAAoJEEGLLxGcTqbMm9IH/A/FYIxdXbFIqfewIHXI59gc
5eS/E8uqXe9Rqd6nzQw7ETcL4S8VuUPjd4Co39+wwViGQCMRzwLqDVFYF/nqZk2B
5VoWflWvUuV4PqXLuRwNGuOpPYNweStMeW92Jy6wMnb/oBM8iBtpsuR0pVvsHbfK
0A+WeIkFzgueW6lwiWyzJCVtq7Ors51mwGBjEwUI0wtZifqEUigItIde8B0Ekg1a
rT9CmA3xMNnSae9mmVjBiuFFtwcfCp2vya3VuEwS7s+4xJK2oHf6bPMb1xsva94s
/CyNAq3RHWqeNigGa/Vy8fYfFFm+lxGRDQSK9/IAj36ZZ8Zv6ytqQ/mnuPTqGHU=
=WADX
-----END PGP SIGNATURE-----

--=_MailMate_EFCA1392-DD1E-48A7-B08E-B445F432EE75_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
