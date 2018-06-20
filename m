Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 946B96B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 13:13:02 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id g15-v6so117044pfh.10
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 10:13:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m21-v6sor543969pgn.22.2018.06.20.10.13.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Jun 2018 10:13:01 -0700 (PDT)
From: Nadav Amit <nadav.amit@gmail.com>
Message-Id: <3FA297CB-2475-498A-8372-3955FBB87AE1@gmail.com>
Content-Type: multipart/signed;
	boundary="Apple-Mail=_D08CC230-0835-452A-83AB-719FA45AFAB1";
	protocol="application/pgp-signature";
	micalg=pgp-sha512
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [RFC v2 PATCH 2/2] mm: mmap: zap pages with read mmap_sem for
 large mapping
Date: Wed, 20 Jun 2018 10:12:56 -0700
In-Reply-To: <20180620071817.GJ13685@dhcp22.suse.cz>
References: <1529364856-49589-1-git-send-email-yang.shi@linux.alibaba.com>
 <1529364856-49589-3-git-send-email-yang.shi@linux.alibaba.com>
 <3DDF2672-FCC4-4387-9624-92F33C309CAE@gmail.com>
 <158a4e4c-d290-77c4-a595-71332ede392b@linux.alibaba.com>
 <BFD6A249-B1D7-43D5-8D7C-9FAED4A168A1@gmail.com>
 <20180620071817.GJ13685@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, Matthew Wilcox <willy@infradead.org>, ldufour@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, acme@kernel.org, alexander.shishkin@linux.intel.com, jolsa@redhat.com, namhyung@kernel.org, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, linux-kernel@vger.kernel.org


--Apple-Mail=_D08CC230-0835-452A-83AB-719FA45AFAB1
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=utf-8

at 12:18 AM, Michal Hocko <mhocko@kernel.org> wrote:

> On Tue 19-06-18 17:31:27, Nadav Amit wrote:
>> at 4:08 PM, Yang Shi <yang.shi@linux.alibaba.com> wrote:
>>=20
>>> On 6/19/18 3:17 PM, Nadav Amit wrote:
>>>> at 4:34 PM, Yang Shi <yang.shi@linux.alibaba.com>
>>>> wrote:
>>>>=20
>>>>=20
>>>>> When running some mmap/munmap scalability tests with large memory =
(i.e.
>>>>>=20
>>>>>> 300GB), the below hung task issue may happen occasionally.
>>>>> INFO: task ps:14018 blocked for more than 120 seconds.
>>>>>      Tainted: G            E 4.9.79-009.ali3000.alios7.x86_64 #1
>>>>> "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this
>>>>> message.
>>>>> ps              D    0 14018      1 0x00000004
>>>> (snip)
>>>>=20
>>>>=20
>>>>> Zapping pages is the most time consuming part, according to the
>>>>> suggestion from Michal Hock [1], zapping pages can be done with =
holding
>>>>> read mmap_sem, like what MADV_DONTNEED does. Then re-acquire write
>>>>> mmap_sem to manipulate vmas.
>>>> Does munmap() =3D=3D MADV_DONTNEED + munmap() ?
>>>=20
>>> Not exactly the same. So, I basically copied the page zapping used =
by munmap instead of calling MADV_DONTNEED.
>>>=20
>>>> For example, what happens with userfaultfd in this case? Can you =
get an
>>>> extra #PF, which would be visible to userspace, before the munmap =
is
>>>> finished?
>>>=20
>>> userfaultfd is handled by regular munmap path. So, no change to =
userfaultfd part.
>>=20
>> Right. I see it now.
>>=20
>>>> In addition, would it be ok for the user to potentially get a =
zeroed page in
>>>> the time window after the MADV_DONTNEED finished removing a PTE and =
before
>>>> the munmap() is done?
>>>=20
>>> This should be undefined behavior according to Michal. This has been =
discussed in https://lwn.net/Articles/753269/.
>>=20
>> Thanks for the reference.
>>=20
>> Reading the man page I see: "All pages containing a part of the =
indicated
>> range are unmapped, and subsequent references to these pages will =
generate
>> SIGSEGV.=E2=80=9D
>=20
> Yes, this is true but I guess what Yang Shi meant was that an =
userspace
> access racing with munmap is not well defined. You never know whether
> you get your data, #PTF or SEGV because it depends on timing. The user
> visible change might be that you lose content and get zero page =
instead
> if you hit the race window while we are unmapping which was not =
possible
> before. But whouldn't such an access pattern be buggy anyway? You need
> some form of external synchronization AFAICS.

It seems to follow the specifications, so it is not clearly buggy IMHO. =
I
don=E2=80=99t know of such a use-case, but if somebody does so - the =
proposed change
might even cause a security vulnerability.

> But maybe some userspace depends on "getting right data or get SEGV"
> semantic. If we have to preserve that then we can come up with a =
VM_DEAD
> flag set before we tear it down and force the SEGV on the #PF path.
> Something similar we already do for MMF_UNSTABLE.

That seems reasonable.

Regards,
Nadav

--Apple-Mail=_D08CC230-0835-452A-83AB-719FA45AFAB1
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEE0YCJM4pMIpzxUdmOK4dOkxJsY0AFAlsqixgACgkQK4dOkxJs
Y0CLohAAzDqyXV2YQ9gTS3P5ug+gfWrJEIkshCcVsiybRqoVD0zqDRZHADnxpfa3
/yM5+HGNTizMA5+8/kYR0WF5iT0HudVxYwsCNWPFkroVKwFio5znLPQ9fl1ZHBah
Gu+hFWP/TbkACKhn3TmnkvS8/7LkZlCvU+sBBGCo0++LH+rM6a+9E5T/+4h77f9v
Ckjs9ncKlCvwI/zzTFa7aD7IDNUNSjzzC8asuytyGr6HrOjt8BOPSrkoknVa7d8P
rw6nwi7v11Sni1ZkbhlomQus0EKCk+eJ6OxhMEqLHSQXVVqxZBNDVAR755iu0fwD
aG5cseIaKSjycw23Go7iIYLS6ge2HRqEC5LX79wVfgLyjzKNQdEQu/kQpFIQgPYX
kMNnrNmhHTEzmfYcR8vOgWYazInKJO5ECuCogg9SL/M1dHoSb7ocTdiBaBTS5M3i
F/iKmBMzMFBf+r751wYDFkmFyvQVl6k/WXJvvvudB8U0D2hn6A4qBpt+tHj5LR4Q
mnxlarsEfxnja/UEXdUktZsF8RrEVBLBC6lIvndX3qWP31coBcrk+dStN8FDklpI
r/3pfIlK9ydfpVvYp6+wjuCBIMRqkVPQHHe8Xfv5GdlyOXQwWv8UnkMX95A8vUb5
TojMmwoL/FHqSUKW+kh17NQ2jG+WGEVUwIBFVPmqH9jP0KXAWYU=
=hifR
-----END PGP SIGNATURE-----

--Apple-Mail=_D08CC230-0835-452A-83AB-719FA45AFAB1--
